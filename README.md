# 🧩 Dotfiles – i3 + Arch Linux

Personal Linux environment based on **i3**, **MPD**, and a minimal X11 stack.
Designed to work on both **desktop and laptop** systems.

---

## ✨ Features

- i3 window manager
- Polybar
- MPD + ncmpcpp
- Kitty terminal
- Rofi / Impala
- Betterlockscreen
- X11 (no Wayland)
- Laptop & desktop aware setup
- GNU Stow–based dotfile management

---

## 📁 Repository Structure

dotfiles/
├── i3/ → ~/.config/i3
├── polybar/ → ~/.config/polybar
├── mpd/ → ~/.config/mpd
├── ncmpcpp/ → ~/.config/ncmpcpp
├── kitty/ → ~/.config/kitty
├── scripts/ → ~/.local/bin
├── packages/ → package lists
├── install.sh → install script
└── README.md

## 🧰 Requirements

- Arch Linux (or Arch-based)
- git
- sudo
- systemd (user services)

---

## 🚀 Installation

### 1. Clone repository

```bash
git clone https://github.com/USERNAME/dotfiles.git
cd dotfiles
