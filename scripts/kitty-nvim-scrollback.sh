#!/usr/bin/env bash

TMPFILE=$(mktemp /tmp/kitty-scrollback-XXXXXX.txt)
cat > "$TMPFILE"

INPUT_LINE_NUMER=$1 nvim \
  -u ~/.config/nvim/scrollback.lua \
  --cmd 'set eventignore=FileType' \
  +'nnoremap q ZQ' \
  +'set nomodified nolist' \
  "$TMPFILE"
