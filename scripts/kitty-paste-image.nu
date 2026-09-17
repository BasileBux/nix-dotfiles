#!/usr/bin/env nu

# Paste a clipboard image into the focused kitty window, over SSH.
# Wire up with: map ctrl+alt+v remote_control_script <path>
# remote_control_script sets KITTY_LISTEN_ON, so `kitten @` works
# even with allow_remote_control = false.

const PNG_MAGIC = 0x[89 50 4E 47]

def show-error [msg: string] {
  try { ^kitten @ launch --type=overlay --hold --env $"PASTE_ERR=($msg)" bash -c 'printf "%s\n" "$PASTE_ERR"; read -r' } catch {|e|
    print $"paste-image error: ($msg) ($e.msg)"
  }
}

def send-to-focused [text: string] {
  try { ^kitten @ send-text --match state:focused -- $text } catch {|e|
    show-error $"paste-image: send-text failed: ($e.msg)"
  }
}

# Read the local desktop clipboard image into `out`. Returns true on success.
def read-image [out: string] {
  if (which wl-paste | is-not-empty) {
    try { ^wl-paste --type image/png out> $out e> /dev/null } catch { return false }
  } else if (which xclip | is-not-empty) {
    try { ^xclip -selection clipboard -t image/png -o out> $out e> /dev/null } catch { return false }
  } else {
    return false
  }
  (open --raw $out | into binary | bytes at 0..3) == $PNG_MAGIC
}

def read-text [] {
  if (which wl-paste | is-not-empty) {
    let t = (^wl-paste --list-types | lines | where {|x| $x =~ 'text/|STRING|UTF8_STRING' } | first)
    if ($t | is-empty) { return "" }
    try { ^wl-paste --type $t | complete | get stdout | str trim } catch { "" }
  } else if (which xclip | is-not-empty) {
    try { ^xclip -selection clipboard -o | complete | get stdout | str trim } catch { "" }
  } else {
    ""
  }
}

# Find the ssh remote of the focused window from foreground process cmdlines.
# Assumes `kitten ssh <target>` (also handles plain `ssh <target>` and ssh's
# rewritten process title as fallbacks).
def ssh-target [cmdlines: list] {
  for c in $cmdlines {
    let argv0 = ($c | get 0? | default "" | path basename)
    # kitten ssh <target>   (or kitty +kitten ssh ...)
    if ($argv0 in ["kitten", "kitty"]) and (($c | get 1? | default "") == "ssh") {
      let t = ($c | skip 2 | where {|a| not ($a | str starts-with "-") })
      if not ($t | is-empty) { return ($t | first) }
    }
    # plain ssh <target>
    if ($argv0 == "ssh") {
      let t = ($c | skip 1 | where {|a| not ($a | str starts-with "-") })
      if not ($t | is-empty) { return ($t | first) }
    }
    # OpenSSH rewrites its process title to "ssh: user@host ..."
    if ($argv0 | str starts-with "ssh:") {
      let t = ($c | get 0 | parse -r 'ssh:\s*(?<t>\S+)' | get 0?.t?)
      if $t != null { return $t }
    }
  }
  null
}

def foreground-cmdlines [] {
  let ls = (do { ^kitten @ ls --match state:focused } | complete | get stdout | from json)
  $ls | each {|os| $os.tabs | each {|tab| $tab.windows } } | flatten
  | each {|w| $w.foreground_processes? | default [] } | flatten
  | get cmdline | flatten
}

def main [] {
  let local = (mktemp --tmpdir --suffix .png 'clip-XXXXXX')
  let fname = ($local | path basename)

  # Not an image: fall back to typing the clipboard text (acts like a paste)
  if not (read-image $local) {
    rm $local
    let text = (read-text)
    if ($text | is-not-empty) {
      send-to-focused $text
    }
    exit 0
  }

  let target = (foreground-cmdlines | ssh-target $in)
  if $target == null {
    rm $local
    show-error 'paste-image: image on clipboard, but no ssh session found in the focused window'
    exit 1
  }

  try { ^scp -q $local $"($target):/tmp/($fname)" } catch {
    rm $local
    show-error $'paste-image: scp to ($target) failed'
    exit 1
  }
  rm $local

  send-to-focused $'/tmp/($fname)'
}
