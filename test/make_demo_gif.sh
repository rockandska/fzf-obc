#!/usr/bin/env bash
set -euo pipefail

TESTS_RECORDING=1 TESTS_KEYS_DELAY=1 bundle exec ruby test-fzf-obc.rb -n '/test_vi|test_cat|test_insmod|test_git|test_docker/'
( cd /tmp; docker run --rm -v $PWD:/data asciinema/asciicast2gif -w 80 -h 12 -S 1 fzf-obc.cast fzf-obc.gif )
cp /tmp/fzf-obc.gif ../docs/img/demo.gif
