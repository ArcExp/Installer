#!/usr/bin/env bash
#github-action genshdoc
#
# @file Post-Setup
# @brief Finalizing installation configurations and cleaning up after script.
echo -ne "
-------------------------------------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
                        SCRIPTHOME: Installer
-------------------------------------------------------------------------

Final Setup and Configurations
GRUB EFI Bootloader Install & Check
"
source ${HOME}/Installer/configs/setup.conf

if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "
-------------------------------------------------------------------------
               Creating (and Theming) Grub Boot Menu
-------------------------------------------------------------------------
"
# set kernel parameter for decrypting the drive
if [[ "${FS}" == "luks" ]]; then
sed -i "s%GRUB_CMDLINE_LINUX_DEFAULT=\"%GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${ENCRYPTED_PARTITION_UUID}:ROOT root=/dev/mapper/ROOT %g" /etc/default/grub
fi
# set kernel parameter for adding splash screen
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash /' /etc/default/grub

echo -e "Installing Grub theme..."
THEME_DIR="/boot/grub/themes"
THEME_NAME=Arch
echo -e "Creating the theme directory..."
mkdir -p "${THEME_DIR}/${THEME_NAME}"
echo -e "Copying the theme..."
cd ${HOME}/Installer
cp -a configs${THEME_DIR}/${THEME_NAME}/* ${THEME_DIR}/${THEME_NAME}
echo -e "Backing up Grub config..."
cp -an /etc/default/grub /etc/default/grub.bak
echo -e "Setting the theme as the default..."
grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub
echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
-------------------------------------------------------------------------
               Enabling (and Theming) Login Display Manager
-------------------------------------------------------------------------
"
if [[ "${DESKTOP_ENV}" == "kde" ]]; then
  systemctl enable sddm.service
  if [[ "${INSTALL_TYPE}" == "FULL" ]]; then
    echo "[Theme]" >> /etc/sddm.conf
    echo "Current=Nordic" >> /etc/sddm.conf
  fi

elif [[ "${DESKTOP_ENV}" == "gnome" ]]; then
  systemctl enable gdm.service

elif [[ "${DESKTOP_ENV}" == "hypr" ]]; then
  systemctl enable sddm.service
  systemctl --user enable --now pipewire.service pipewire.socket pipewire-pulse.service wireplumber.service
  LC_ALL=C xdg-user-dirs-update --force
  
  gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3
  gsettings set org.gnome.desktop.interface icon-theme Papirus
  gsettings set org.gnome.desktop.interface font-name "JetBrains Mono Regular 11"
  
  	mkdir -p "/home/$USERNAME/Desktop" \
    		"/home/$USERNAME/Documents" \
    		"/home/$USERNAME/Downloads" \
    		"/home/$USERNAME/Music" \
    		"/home/$USERNAME/Pictures" \
    		"/home/$USERNAME/Public" \
    		"/home/$USERNAME/Templates" \
    		"/home/$USERNAME/Videos" \

		shopt -s dotglob
		cp -R "$HOME/Installer/configs/hyprland-dots/.config" "/home/$USERNAME/"
  		cp -R "$HOME/Installer/configs/hyprland-dots/.wallpaper" "/home/$USERNAME/"
    		cp -R "$HOME/Installer/configs/hyprland-dots/.icons" "/home/$USERNAME/"
		shopt -u dotglob

	        # Set ownership of the home directory
		chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"

    		mkdir /usr/share
      		mkdir /usr/share/wayland-sessions/
	
		cp "$HOME/Installer/configs/usr/share/wayland-sessions/Hyprland.desktop" "/usr/share/wayland-sessions/"

else
  if [[ "${DESKTOP_ENV}" == "server"  ]]; then
  sudo pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter
  systemctl set-default graphical.target
  systemctl enable lightdm.service
  fi
fi

echo -ne "
-------------------------------------------------------------------------
                    Enabling Essential Services
-------------------------------------------------------------------------
"
systemctl enable cups.service
echo "  Cups enabled"
ntpd -qg
systemctl enable ntpd.service
echo "  NTP enabled"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
systemctl enable bluetooth
echo "  Bluetooth enabled"
systemctl enable avahi-daemon.service
echo "  Avahi enabled"

if [[ "${FS}" == "btrfs" ]]; then
echo -ne "
-------------------------------------------------------------------------
                    Installing Timeshift-Autosnap
-------------------------------------------------------------------------
"

$AUR_HELPER -S --noconfirm timeshift-bin timeshift-autosnap

echo -ne "
-------------------------------------------------------------------------
               Enabling (and Theming) Plymouth Boot Splash
-------------------------------------------------------------------------
"
PLYMOUTH_THEMES_DIR="$HOME/Installer/configs/usr/share/plymouth/themes"
PLYMOUTH_THEME="arch-glow" # can grab from config later if we allow selection
mkdir -p /usr/share/plymouth/themes
echo 'Installing Plymouth theme...'
cp -rf ${PLYMOUTH_THEMES_DIR}/${PLYMOUTH_THEME} /usr/share/plymouth/themes
if  [[ $FS == "luks" ]]; then
  sed -i 's/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf # add plymouth after base udev
  sed -i 's/HOOKS=(base udev \(.*block\) /&plymouth-/' /etc/mkinitcpio.conf # create plymouth-encrypt after block hook
else
  sed -i 's/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf # add plymouth after base udev
fi
plymouth-set-default-theme -R arch-glow # sets the theme and runs mkinitcpio
echo 'Plymouth theme installed'

echo -ne "
-------------------------------------------------------------------------
                    Cleaning
-------------------------------------------------------------------------
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

rm -r $HOME/Installer
rm -r /home/$USERNAME/Installer

# Replace in the same state
cd $pwd
