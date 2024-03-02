#!/bin/bash

sudo apt install nautilus&&i3blocks&&feh&&rofi&&fonts-font-awesome&&kitty

cp config/* ~.config/
mkdir ~/.fonts
cp fonts/* ~/.fonts/
cp -f bashrc ~/.bashrc
cp -f vimrc ~/.vimrc
cp -f xinitrc ~/.xinitrc


#remove the # if u want the color scheme in the terminal
#bash -c "$(wget -qO- https://git.io/vQgMr)" | grep -n "Cobalt 2";

