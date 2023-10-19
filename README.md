Arch Titus with my own tweaks

Changes: different grub bootloader theme, removal of snapper configuration in favour of timeshift autosnap (for btrfs only, luks is not considered as I don't use it and I'm not certain of compatibility with that filesystem regardless), working dotfiles for hyprland instead of the defaults hyprland provides, use of alacritty and sddm-git instead of lightdm and the removal of a number of other packages previously included (such as zoom) across all DE installs.

Another notable change was the removal of paru as it has a dependency - rust - which conflicts with rustup, which is needed by eww-tray-wayland-git, a package included in my hyprland setup. As a result, pikaur was opted for, instead.

bash <(curl -L https://tinyurl.com/silvchef)

Note: the script uses git in addition to curl. it will attempt to install it, but if the install fails, manual intervention will be required. 
