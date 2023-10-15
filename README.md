Arch Titus with my own tweaks

Changes: different grub bootloader theme, removal of snapper configuration in favour of timeshift autosnap (for btrfs only, luks is not considered as I don't use it and I'm not certain of compatibility with that filesystem regardless), working dotfiles for hyprland instead of the defaults hyprland provides, use of alacritty and sddm-git instead of lightdm and the removal of a number of other packages previously included (such as zoom) across all DE installs.

bash <(curl -L https://tinyurl.com/silvchef)
