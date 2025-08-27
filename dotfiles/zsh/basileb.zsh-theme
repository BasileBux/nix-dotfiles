# Color shortcuts
RED=$fg[red]
YELLOW=$fg[yellow]
GREEN=$fg[green]
WHITE=$fg[white]
BLUE=$fg[blue]
MAGENTA=$fg[magenta]
RED_BOLD=$fg_bold[red]
YELLOW_BOLD=$fg_bold[yellow]
GREEN_BOLD=$fg_bold[green]
WHITE_BOLD=$fg_bold[white]
BLUE_BOLD=$fg_bold[blue]
MAGENTA_BOLD=$fg_bold[magenta]
RESET_COLOR=$reset_color

# Eva01 colors
PURPLE_BOLD=$'\e[1;38;2;150;95;212m'  # for #965fd4 
PURPLE=$'\e[38;2;150;95;212m'  # for #965fd4 
GREEN_BOLD=$'\e[1;38;2;139;212;80m'   # for #8bd450
GREEN=$'\e[38;2;139;212;80m'   # for #8bd450

# Format for git_prompt_info()
# ZSH_THEME_GIT_PROMPT_PREFIX=""
# ZSH_THEME_GIT_PROMPT_SUFFIX=""

# Format for parse_git_dirty()
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$RED%}󰫢%{$RESET_COLOR%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# Format for git_prompt_status()
ZSH_THEME_GIT_PROMPT_UNMERGED=" %{$RED%}unmerged"
ZSH_THEME_GIT_PROMPT_DELETED=" %{$RED%}deleted"
ZSH_THEME_GIT_PROMPT_RENAMED=" %{$YELLOW%}renamed"
ZSH_THEME_GIT_PROMPT_MODIFIED=" %{$YELLOW%}modified"
ZSH_THEME_GIT_PROMPT_ADDED=" %{$GREEN%}added"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$WHITE%}untracked"

PROMPT_COLOR_SUCCESS=$GREEN
PROMPT_COLOR_FAILURE=$RED

PROMPT_ICON_SUCCESS="󱚝"
PROMPT_ICON_FAILURE="󱚟"

if [[ -n $IN_NIX_SHELL ]]; then
  PROMPT_ICON_SUCCESS=""
  PROMPT_ICON_FAILURE=""
  PROMPT_COLOR_SUCCESS=$BLUE
fi

# Nice prompt icons
#   󱚟 󱚡 󱚝
# 󰜎   

# Prompt format
PROMPT='%{$PURPLE_BOLD%}%~%u%{$RESET_COLOR%}
%(?.%{$PROMPT_COLOR_SUCCESS%}%{$PROMPT_ICON_SUCCESS%}  %{$RESET_COLOR%} .%{$PROMPT_COLOR_FAILURE%}%{$PROMPT_ICON_FAILURE%}  %{$RESET_COLOR%} )'
RPROMPT='$(parse_git_dirty)$(git_current_branch)%{$RESET_COLOR%}'
