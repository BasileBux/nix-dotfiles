#!/usr/bin/env bash

INPUT_LINE_NUMER=$1 nvim \
  -u ~/.config/nvim/scrollback.lua \
  --cmd 'set eventignore=FileType' \
  +'nnoremap q ZQ' \
  +'call nvim_open_term(0, {})' \
  +'set nomodified nolist' \
  -
