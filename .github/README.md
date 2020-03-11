# Soyuka's dotfiles

This repository represents a fresh ~/home/soyuka using sway (wayland powered i3), tmux and vi.

The base system is powered by archlinux, having a LUKS encrypted partition on /home.
No login manager is used, sway starts when logged in on tty1.

![Screenshot](./screen.png)

## Installation

Add this line to /etc/sway/config.d/50-systemd-user.conf (loaded by sway configuration)

```
exec systemctl --user start sway-session.target
```
