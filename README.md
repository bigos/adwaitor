# Readme

This is adwaitor for trying adwaita library.


## environment problem on old Mint

On some systems widgets and text are not displayed properly.

### fix 1

start with env variable:
> GSK_RENDERER=gl emacs


### fix 2
edit the:
file:/etc/environment::1

to look like:
> PATH="/usr/local/sbin:WHATEVER
>
> GSK_RENDERER=gl
