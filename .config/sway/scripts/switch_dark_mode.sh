#!/bin/bash

from=$(cat ~/.config/sway/current_scheme)

if [ "$from" = "black" ]; then
    from=black
    to=white
else
    from=white
    to=black
fi

alacritty="s/color.${from}.yml/color.${to}.yml/g"
vim="s/color.${from}/color.${to}/g"

sed -i -e $alacritty ~/.config/alacritty/alacritty.yml
sed -i -e $vim ~/.vimrc

echo $to > ~/.config/sway/current_scheme
