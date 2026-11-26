#!/bin/sh
set -eu

program=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
work=$(mktemp -d)
cd "$work"
printf 'shot window.png\nquit\n' >steps.txt
mkdir home
HOME="$work/home" USERPROFILE="$work/home" SALAM_WINDOW_BACKEND=headless \
    SALAM_UI_SCRIPT=steps.txt perl -e 'alarm 60; exec { $ARGV[0] } @ARGV or die "$!\n"' "$program"
test -s window.png
echo "The window opened"
