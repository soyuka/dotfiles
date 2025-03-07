#!/bin/bash

from=$(cat ~/.config/sway/current_scheme)

if [ "$from" = "black" ]; then
    from=black
    to=white
    sed -i -e "s/background = \"dark\"/background = \"light\"/" ~/.config/nvim/init.lua
else
    from=white
    to=black
    sed -i -e "s/background = \"light\"/background = \"dark\"/" ~/.config/nvim/init.lua
fi

alacritty="s/color.${from}.toml/color.${to}.toml/"

sed -i -e $alacritty ~/.config/alacritty/alacritty.toml

echo $to > ~/.config/sway/current_scheme
