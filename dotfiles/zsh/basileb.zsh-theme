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

# Bloomberg orange: #fb8b1e
BLOOMBERG=$'\e[38;2;251;139;30m'
BLOOMBERG_BOLD=$'\e[1;38;2;251;139;30m'

ZSH_THEME_GIT_PROMPT_DIRTY="%{$YELLOW%}~%{$RESET%}"
ZSH_THEME_GIT_PROMPT_AHEAD=" %{$BLUE%}↑%{$RESET%}"
ZSH_THEME_GIT_PROMPT_BEHIND=" %{$BLUE%}↓%{$RESET%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT_COLOR_SUCCESS=$BLOOMBERG
PROMPT_COLOR_SUCCESS_BOLD=$BLOOMBERG_BOLD
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

    display=$revision

    if [[ -n "$bookmark" ]]; then
        display+=" $bookmark"
        if [[ "$distance" -gt 0 ]]; then
            display+=" %F{white}⇡${distance}%f"
        fi
    fi

    if [[ -n "$file_status" ]]; then
        display+=" ${file_status}"
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
  NIX_SHELL=" %{$BLUE%}%{$RESET%} "
fi

SSH_SHELL=""
if [[ -n $SSH_CONNECTION ]]; then
  SSH_SHELL=" %{$LIGHT_BLUE%}⇄%{$RESET%} "
fi

PROMPT='%(?.%{$PROMPT_COLOR_SUCCESS_BOLD%}.%{$PROMPT_COLOR_FAILURE_BOLD%})┌─── %~%u%{$RESET%}%{$SSH_SHELL%}%{$NIX_SHELL%}%{$RESET%}$(vcs_prompt)%{$RESET%}
%(?.%{$PROMPT_COLOR_SUCCESS%}.%{$PROMPT_COLOR_FAILURE%})│ %{$RESET%}'
