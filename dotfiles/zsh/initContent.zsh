mann() { man "$1" | bat -l man -p -; }

ba() {
  local school_dir="$HOME/ba6"
  if [ $# -eq 0 ]; then
    cd "$school_dir" || return
  else
    cd "$school_dir/$1" || return
  fi
}

# Create a repo hosted on the NAS and add it as a remote
git_init() {
	repo_name="$1"
	if [[ -z "$repo_name" ]]; then
		echo "Usage: git_init <repo_name>"
		return 1
	fi
	git remote add origin gitt@buxtorf-synology:"$repo_name".git

	ssh gitt@buxtorf-synology "mkdir -p ${repo_name}.git && cd ${repo_name}.git && git init --bare && git branch -M main"
	git branch -M main
	git branch --set-upstream-to=origin/main main
}

# Create a repo hosted on GitHub and add it as a remote
github_init() {
	repo_name="$1"
	if [[ -z "$repo_name" ]]; then
		echo "Usage: git_init <repo_name> [public|private]"
		return 1
	fi
	repo_visibility="${2:-public}"
	if [[ "$repo_visibility" != "public" && "$repo_visibility" != "private" ]]; then
		echo "Invalid repository visibility: $repo_visibility. Use 'public' or 'private'."
		return 1
	fi
	gh repo create "$repo_name" --"$repo_visibility"
	git remote add gh git@github.com:BasileBux/"$repo_name".git
	git branch -M main
}

# Push to all remotes
jj_pushall() {
  for r in $(git remote);
  do
    jj git push --remote $r
  done
}

# Uselessly complex completion for the `remote` command (see ./dotfiles/kitty.nix)
_remote_complete() {
  local state
  _arguments \
    '1:host:->host' \
    '2:session name:(main ssh dev)'

  case $state in
    host)
      local hosts userprefix

      if [[ "$PREFIX" == *@* ]]; then
        userprefix="${PREFIX%@*}@"
      else
        userprefix=""
      fi

      hosts=(
        $(grep -oE '^[^, ]+' ~/.ssh/known_hosts 2>/dev/null | grep -v '^\[')
        $(grep -oP '(?<=^Host )[\w.\-]+' ~/.ssh/config 2>/dev/null)
      )

      _wanted hosts expl 'remote host' compadd -P "$userprefix" -a hosts
      ;;
  esac
}
compdef _remote_complete remote

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^a' edit-command-line
