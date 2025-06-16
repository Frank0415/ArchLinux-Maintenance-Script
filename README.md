# Presentation
An all-in-one script (flaovred to my needs) that simplifies system maintenance on Arch Linux and Arch-based Linux distributions.

Fastfetch is using the config in ![Frank0415/dotfiles](https://github.com/Frank0415/dotfiles) to display system information only once to show system-related things like graphics card.

This script can :
1. check for failed systemd services,
2. check for errors in the logs files,
3. upgrade official packages,
4. upgrade AUR packages,
5. check for orphaned packages,
6. clean packages cache,
7. check disks health,
8. download canvas files using ![Frank0415/sjtu_canvas_downloader](https://github.com/Frank0415/sjtu_canvas_downloader)
9. toggle monitor modes
10. toggle wacom tablet modes

on demand by configuration the user from the script's menu, do note that some features are disabled.

![Screenshot_2022-01-09_01-37-57](https://user-images.githubusercontent.com/84401519/148664681-52ff22e4-316f-4943-8853-d4191cd7eead.png)



# Requirements 

- Yet another yogurt (yay) for utility 4. The yay package can be found in the AUR at the following link : https://aur.archlinux.org/packages/yay/.
- Smartmontools for utility 7. The [smartmontools package](https://archlinux.org/packages/extra/x86_64/smartmontools/) can be manually installed by running **pacman -S smartmontools** or automatically by selecting option 7 without the package installed.
