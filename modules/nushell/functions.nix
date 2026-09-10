{ pkgs, ... }:
pkgs.writeText "functions.nu" /* nu */ ''
  # Colored man pages
  def mann [name: string] {
    man $name | bat -l man -p -
  }

  # Jump to school directory
  def --env ba [dir?: string] {
    let base = $"($env.HOME)/ba6"
    let target = if ($dir | is-not-empty) {
      $"($base)/($dir)"
    } else {
      $base
    }
    cd $target
  }

  # Create a repo hosted on the NAS and add it as a remote
  def git_init [repo_name: string] {
    git remote add origin $"gitt@buxtorf-synology:($repo_name).git"
    ssh gitt@buxtorf-synology $"mkdir -p ($repo_name).git && cd ($repo_name).git && git init --bare && git branch -M main"
    git branch -M main
    git branch --set-upstream-to=origin/main main
  }

  # Create a repo hosted on GitHub and add it as a remote
  def github_init [repo_name: string, visibility: string = "public"] {
    if $visibility not-in ["public" "private"] {
      print $"Invalid repository visibility: ($visibility). Use 'public' or 'private'."
      return
    }
    gh repo create $repo_name --$visibility
    git remote add gh $"git@github.com:BasileBux/($repo_name).git"
    git branch -M main
  }

  # Push to all git remotes
  def jj_pushall [] {
    git remote | lines | each {|r|
      print $"pushing to ($r)"
      jj git push --remote $r
    }
  }

  # Create a directory and cd into it
  def --env mkcd [path: path] {
    mkdir $path
    cd $path
  }

  # Stolen from ncc
  # `which`, but with the paths of externals canonicalized.
  def realwhich [
    ...applications: string
    --all (-a) # List all executables.
  ]: nothing -> table {
    which --all=$all ...$applications
    | update path {|row| match $row.type {
        "external" => { $row.path | path expand }
        _ => $row.path
      } }
  }

  # Deploy the current flake to any host, or to all other hosts at once
  def --env deploy [
    host: string, # a host name (kamina, genome, simon, yoko), or "all"
    --reboot (-r) # reboot the host(s) after switching
  ] {
    let here = (hostname)
    let all_hosts = [kamina genome simon yoko]
    # Never target the machine we are running on
    let targets = (
      if $host == "all" { $all_hosts } else { [$host] }
      | where {|h| $h != $here }
    )
    # Only deploy to machines that are reachable. Use ssh rather than ping:
    # some hosts (e.g. yoko) have no tailscale and are only reachable through
    # an ssh alias (asbel.xyz), which ping cannot resolve.
    let online = $targets | where {|h|
      (ssh -o ConnectTimeout=3 -o BatchMode=yes $h true | complete).exit_code == 0
    }
    let offline = $targets | where {|h| $h not-in $online }

    for h in $online {
      if $h == "genome" {
        rsync -a --delete --exclude .git --exclude .jj $"(pwd)/" genome:nixos/
        ssh genome "cd ~/nixos; nh os switch .#genome"
        ssh genome "rm -rf ~/nixos"
      } else {
        nh os switch .#($h) --target-host $"($h)" --build-host $"($h)"
        ssh $h "rm -f ~/result"
      }
      if $reboot {
        # `reboot` drops the SSH connection, so ssh exits non-zero; ignore it
        # to keep deploying to the remaining hosts.
        do -i { ssh -t $h "sudo reboot" }
      }
    }

    if ($online | is-not-empty) {
      print $"Deployed to: ($online | str join ', ')"
    } else {
      print "No machine online to deploy to."
    }
    if ($offline | is-not-empty) {
      print $"Skipped offline: ($offline | str join ', ')"
    }
  }
''
