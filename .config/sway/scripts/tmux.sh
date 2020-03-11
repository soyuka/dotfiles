#!/bin/bash
tmux attach-session -t 0 2>&1 > /dev/null || tmux -u -2
