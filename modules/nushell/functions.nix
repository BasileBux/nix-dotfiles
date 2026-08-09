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
''
