RED=$fg[red]
YELLOW=$fg[yellow]
GREEN=$fg[green]
WHITE=$fg[white]
BLUE=$fg[blue]
LIGHT_BLUE=$fg[cyan]
MAGENTA=$fg[magenta]
RED_BOLD=$fg_bold[red]
YELLOW_BOLD=$fg_bold[yellow]
GREEN_BOLD=$fg_bold[green]
WHITE_BOLD=$fg_bold[white]
BLUE_BOLD=$fg_bold[blue]
LIGHT_BLUE_BOLD=$fg_bold[cyan]
MAGENTA_BOLD=$fg_bold[magenta]
RESET=$reset_color

# Nicer grey: #acc6e0
GREY=$'\e[38;2;172;198;224m'
GREY_BOLD=$'\e[1;38;2;172;198;224m'

# Main accent color: @accent_rgb@
MAIN_COLOR=$'\e[38;2;@accent_rgb@m'
MAIN_COLOR_BOLD=$'\e[1;38;2;@accent_rgb@m'

ZSH_THEME_GIT_PROMPT_DIRTY="%{$YELLOW%}~%{$RESET%}"
ZSH_THEME_GIT_PROMPT_AHEAD=" %{$BLUE%}↑%{$RESET%}"
ZSH_THEME_GIT_PROMPT_BEHIND=" %{$BLUE%}↓%{$RESET%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT_COLOR_SUCCESS=$MAIN_COLOR
PROMPT_COLOR_SUCCESS_BOLD=$MAIN_COLOR_BOLD
PROMPT_COLOR_FAILURE=$RED
PROMPT_COLOR_FAILURE_BOLD=$RED_BOLD

jj_prompt() {
    local workspace
    command -v jj >/dev/null 2>&1 || return
    workspace=$(jj workspace root 2>/dev/null) || return

    local revision bookmark distance file_status display

    revision=$(jj log --repository "$workspace" --ignore-working-copy \
        --no-graph --limit 1 --color always \
        --revisions @ -T 'separate(" ", change_id.shortest(4), commit_id.shortest(4), if(empty, label("empty", "(empty)"), ""), if(description == "", label("description placeholder", "(no description)"), ""), if(conflict, label("conflict", "(conflict)"), ""))' 2>/dev/null)

    [[ -z "$revision" ]] && return

    display=$revision

    if [[ "${EXTENDED_JJ_PROMPT:-false}" == true ]]; then
        bookmark=$(jj log --repository "$workspace" --ignore-working-copy \
            --no-graph --limit 1 --color never \
            -r 'heads(::@ & bookmarks())' -T 'bookmarks.join(" ")' 2>/dev/null)

        if [[ -n "$bookmark" ]]; then
            distance=$(jj log --repository "$workspace" --ignore-working-copy \
                --no-graph --color never \
                -r 'heads(::@ & bookmarks())..@' \
                -T 'change_id ++ "\n"' 2>/dev/null | wc -l | tr -d ' ')
        fi

        file_status=$(jj log --repository "$workspace" --ignore-working-copy \
            --no-graph --color never --revisions @ \
            -T 'self.diff().files().map(|f| f.status()).join("\n")' 2>/dev/null | \
            sort | uniq -c | awk '
                /modified/ { parts[++i] = "%F{cyan}±" $1 "%f" }
                /added/ { parts[++i] = "%F{green}+" $1 "%f" }
                /removed/ { parts[++i] = "%F{red}-" $1 "%f" }
                /copied/ { parts[++i] = "%F{yellow}⧉" $1 "%f" }
                /renamed/ { parts[++i] = "%F{magenta}↻" $1 "%f" }
                END { for (j=1; j<=i; j++) printf "%s%s", parts[j], (j<i ? " " : "") }
            ')

        if [[ -n "$bookmark" ]]; then
            display+=" $bookmark"
            if [[ "$distance" -gt 0 ]]; then
                display+=" %F{white}⇡${distance}%f"
            fi
        fi

        if [[ -n "$file_status" ]]; then
            display+=" ${file_status}"
        fi
    fi

    # Wrap jj's ANSI color escapes so zsh counts them as zero-width
    print -n " ${display}" | sed 's/\x1b\[[0-9;]*m/%{&%}/g'
}

vcs_prompt() {
    local jj_output
    jj_output=$(jj_prompt 2>/dev/null)
    if [[ -n "$jj_output" ]]; then
        print -n "$jj_output"
        return
    fi

    if git rev-parse --git-dir >/dev/null 2>&1; then
        print -n "%{$GREY%} on $(git_current_branch)$(parse_git_dirty)$(git_commits_ahead)$(git_commits_behind)%{$RESET%}"
    fi
}

NIX_SHELL=""
if [[ -n $IN_NIX_SHELL ]]; then
  NIX_SHELL=" %{$BLUE%} %{$RESET%} "
fi

SSH_SHELL=""
if [[ -n $SSH_CONNECTION ]]; then
  SSH_SHELL=" %{$LIGHT_BLUE%}⇄%{$RESET%} "
fi

# Keep the duration on the next prompt, but only for commands that took more
# than ten seconds. EPOCHREALTIME gives us enough precision to show millis.
zmodload zsh/datetime 2>/dev/null
_BASILEB_COMMAND_START=""
BASILEB_COMMAND_DURATION=""
BASILEB_PROMPT_COLOR=$PROMPT_COLOR_SUCCESS_BOLD

_basileb_preexec() {
    _BASILEB_COMMAND_START=$EPOCHREALTIME
    BASILEB_COMMAND_DURATION=""
}

_basileb_precmd() {
    local command_status=$?
    if (( command_status == 0 )); then
        BASILEB_PROMPT_COLOR=$PROMPT_COLOR_SUCCESS_BOLD
    else
        BASILEB_PROMPT_COLOR=$PROMPT_COLOR_FAILURE_BOLD
    fi

    [[ -z $_BASILEB_COMMAND_START ]] && return

    local -F 6 elapsed
    integer total_ms minutes seconds milliseconds
    elapsed=$(( EPOCHREALTIME - _BASILEB_COMMAND_START ))
    _BASILEB_COMMAND_START=""

    total_ms=$(( elapsed * 1000 ))
    if (( elapsed > 10 )); then
        minutes=$(( total_ms / 60000 ))
        seconds=$(( (total_ms / 1000) % 60 ))
        milliseconds=$(( total_ms % 1000 ))
        if (( minutes > 0 )); then
            BASILEB_COMMAND_DURATION="${minutes}min "
        else
            BASILEB_COMMAND_DURATION=""
        fi
        BASILEB_COMMAND_DURATION+="${seconds}sec ${milliseconds}ms"
    else
        BASILEB_COMMAND_DURATION=""
    fi
}

# add-zsh-hook preserves any hooks installed by zsh or other plugins.
autoload -Uz add-zsh-hook
add-zsh-hook preexec _basileb_preexec
add-zsh-hook precmd _basileb_precmd

basileb_prompt_prefix() {
    if [[ -n $BASILEB_COMMAND_DURATION ]]; then
        print -n "┌┤ %{$MAGENTA_BOLD%}${BASILEB_COMMAND_DURATION}%{$RESET%}%{$BASILEB_PROMPT_COLOR%} ├─ "
    else
        print -n "┌─── "
    fi
}

PROMPT='%(?.%{$PROMPT_COLOR_SUCCESS_BOLD%}.%{$PROMPT_COLOR_FAILURE_BOLD%})$(basileb_prompt_prefix)%~%u%{$RESET%}%{$SSH_SHELL%}%{$NIX_SHELL%}%{$RESET%}$(vcs_prompt)%{$RESET%}
%(?.%{$PROMPT_COLOR_SUCCESS%}.%{$PROMPT_COLOR_FAILURE%})│ %{$RESET%}'
