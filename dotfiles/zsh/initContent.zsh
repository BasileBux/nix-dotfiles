mann() { man "$1" | bat -l man -p -; }

ba() {
  local school_dir="$HOME/ba6"
  if [ $# -eq 0 ]; then
    cd "$school_dir" || return
  else
    cd "$school_dir/$1" || return
  fi
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
