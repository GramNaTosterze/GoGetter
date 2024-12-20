# GoGetter
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)

## :sparkles: About ##
Based on the original *Cat & Mouse, GoGetter* game by *Smart Games*
GoGetter is a simple puzzle game where the objective is to arrange nine blocks in such a way as to create the paths required to complete a level.

<p align="center">
    <img height="600" width="auto" src="https://raw.githubusercontent.com/GramNaTosterze/GoGetter/refs/heads/master/.github/metadata/screenshots/main_menu.png" />
    <img height="600" width="auto" src="https://raw.githubusercontent.com/GramNaTosterze/GoGetter/refs/heads/master/.github/metadata/screenshots/board_hints.png" />
    <img height="600" width="auto" src="https://raw.githubusercontent.com/GramNaTosterze/GoGetter/refs/heads/master/.github/metadata/screenshots/pause_menu.png" />
    <img height="600" width="auto" src="https://raw.githubusercontent.com/GramNaTosterze/GoGetter/refs/heads/master/.github/metadata/screenshots/end_screen.jpg" />
</p>

## :dart: Supported platforms ##
- Android
- Web
- Linux


## :rocket: Build steps ##

```bash
$ # dependencies - only for linux
$ sudo apt-get update -y
$ sudo apt-get install -y ninja-build libgtk-3-dev libgstreamer1.0-dev libunwind-dev libgstreamer1.0 libgstreamer-plugins-base1.0-dev

$ git clone https://github.com/GramNaTosterze/GoGetter
$ cd GoGetter
$ flutter pub get
$ flutter run # or run -d {target}
```