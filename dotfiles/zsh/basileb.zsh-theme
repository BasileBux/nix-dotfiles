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

NIX_SHELL=""
if [[ -n $IN_NIX_SHELL ]]; then
  NIX_SHELL=" %{$BLUE%}%{$RESET%} "
fi

SSH_SHELL=""
if [[ -n $SSH_CONNECTION ]]; then
  SSH_SHELL=" %{$LIGHT_BLUE%}⇄%{$RESET%} "
fi

PROMPT='%(?.%{$PROMPT_COLOR_SUCCESS_BOLD%}.%{$PROMPT_COLOR_FAILURE_BOLD%})┌─── %~%u%{$RESET%}%{$SSH_SHELL%}%{$NIX_SHELL%}%{$GREY%}${$(git rev-parse --git-dir 2>/dev/null):+ on $(git_current_branch)$(parse_git_dirty)$(git_commits_ahead)$(git_commits_behind)}%{$RESET%}
%(?.%{$PROMPT_COLOR_SUCCESS%}.%{$PROMPT_COLOR_FAILURE%})│ %{$RESET%}'
