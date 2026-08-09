# Based almost verbatim on RGBCube's nushell prompt
# from https://github.com/RGBCube/ncc/tree/dentride
# Copyright (c) 2023-present RGBCube, MIT licensed

{ pkgs, accentColor, ... }:
pkgs.writeText "prompt.nu" /* nu */ ''
  do --env {
    use std null_device
    def highlight_color [] { ansi -e { fg: "${accentColor}" attr: b } }

    def prompt-header [
      --left-char: string
    ]: nothing -> string {
      let code = $env.LAST_EXIT_CODE

      let jj_workspace_root = try {
        jj workspace root err> $null_device
      } catch {
        ""
      }

      let hostname = if ($env.SSH_CONNECTION? | is-not-empty) {
        $"(ansi light_green_bold)@(sys host | get hostname)(ansi reset) "
      } else {
        ""
      }

      let nix_shell = if ($env.IN_NIX_SHELL? | is-not-empty) {
        $"(ansi blue)  (ansi reset)"
      } else {
        ""
      }

      let body = if ($jj_workspace_root | is-not-empty) {
        let subpath = pwd | path relative-to $jj_workspace_root
        let subpath = if ($subpath | is-not-empty) {
          $"(ansi magenta_bold) → (ansi reset)(ansi blue)($subpath)"
        }

        $"($hostname)(highlight_color)($jj_workspace_root | path basename)($subpath)(ansi reset)($nix_shell)"
      } else {
        $"($hostname)(highlight_color)(
          if (pwd | str starts-with $env.HOME) {
            "~" | path join (pwd | path relative-to $env.HOME)
          } else {
            pwd
          }
        )(ansi reset)($nix_shell)"
      }

      let command_duration = ($env.CMD_DURATION_MS | into int) * 1ms
      let command_duration = if $command_duration <= 2sec {
        ""
      } else {
        $"┤(ansi light_magenta_bold)($command_duration)(highlight_color)├─"
      }

      let exit_code = if $code == 0 {
        ""
      } else {
        $"┤(ansi light_red_bold)($code)(highlight_color)├─"
      }

      let middle = if $command_duration == "" and $exit_code == "" {
        "─"
      } else {
        ""
      }

      let jj_status = try {
        jj --quiet --color always --ignore-working-copy log --no-graph --revisions @ --template '
          separate(
            " ",
            if(empty, label("empty", "(empty)")),
            coalesce(
              surround(
                "\"",
                "\"",
                if(
                  description.first_line().substr(0, 24).starts_with(description.first_line()),
                  description.first_line().substr(0, 24),
                  description.first_line().substr(0, 23) ++ "…"
                )
              ),
              label(if(empty, "empty"), description_placeholder)
            ),
            bookmarks.join(", "),
            change_id.shortest(),
            commit_id.shortest(),
            if(conflict, label("conflict", "(conflict)")),
            if(divergent, label("divergent prefix", "(divergent)")),
            if(hidden, label("hidden prefix", "(hidden)")),
          )
        ' err> $null_device
      } catch {
        ""
      }
      $"(highlight_color)($left_char)($exit_code)($middle)($command_duration)(ansi reset) ($body) ($jj_status)(char newline)"
    }

    $env.PROMPT_INDICATOR = $"(highlight_color)│(ansi reset) "
    $env.PROMPT_INDICATOR_VI_NORMAL = $env.PROMPT_INDICATOR
    $env.PROMPT_INDICATOR_VI_INSERT = $env.PROMPT_INDICATOR
    $env.PROMPT_MULTILINE_INDICATOR = $env.PROMPT_INDICATOR
    $env.PROMPT_COMMAND = {||
      prompt-header --left-char "┌"
    }
    $env.PROMPT_COMMAND_RIGHT = {||}

    $env.TRANSIENT_PROMPT_INDICATOR = "  "
    $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = $env.TRANSIENT_PROMPT_INDICATOR
    $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = $env.TRANSIENT_PROMPT_INDICATOR
    $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = $env.TRANSIENT_PROMPT_INDICATOR
    $env.TRANSIENT_PROMPT_COMMAND = {||
      prompt-header --left-char "─"
    }
  }
''
