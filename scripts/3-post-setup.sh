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
  sudo -u "$USERNAME" "$AUR_HELPER" -S --noconfirm noisetorch steam-acolyte
  echo "[Theme]" >> /etc/sddm.conf
  echo "Current=sugar-dark" >> /etc/sddm.conf

if [[ ${line} == '--END OF MINIMAL INSTALL--' ]] then
  flatpak install flathub com.github.tchx84.Flatseal
fi

  # Path to the kde.txt file
  KDE_FILE="$HOME/Installer/pkg-files/kde.txt"

  # Function to check if a package is installed
  is_installed() {
      pacman -Q "$1" &>/dev/null
  }

  # Read the package names from kde.txt and install any missing packages
  while IFS= read -r package; do
      if ! is_installed "$package"; then
          echo "Installing $package"
          sudo -u "$USERNAME" "$AUR_HELPER" -S --noconfirm "$package"
      fi
  done < "$KDE_FILE"
fi

if [[ "${DESKTOP_ENV}" == "gnome" ]]; then
  systemctl enable gdm.service

  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]] then
  flatpak install flathub com.github.tchx84.Flatseal
  fi

    # Path to the gnome.txt file
  GNOME_FILE="$HOME/Installer/pkg-files/gnome.txt"

  # Function to check if a package is installed
  is_installed() {
      pacman -Q "$1" &>/dev/null
  }

  # Read the package names from gnome.txt and install any missing packages
  while IFS= read -r package; do
      if ! is_installed "$package"; then
          echo "Installing $package"
          sudo -u "$USERNAME" "$AUR_HELPER" -S --noconfirm "$package"
      fi
  done < "$GNOME_FILE"
fi

if [[ "${DESKTOP_ENV}" == "xfce" ]]; then
  systemctl enable sddm.service
  echo "[Theme]" >> /etc/sddm.conf
  echo "Current=sugar-dark" >> /etc/sddm.conf

  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]] then
  flatpak install flathub com.github.tchx84.Flatseal
fi

 # Path to the xfce.txt file
  XFCE_FILE="$HOME/Installer/pkg-files/xfce.txt"

  # Function to check if a package is installed
  is_installed() {
      pacman -Q "$1" &>/dev/null
  }

  # Read the package names from xfce.txt and install any missing packages
  while IFS= read -r package; do
      if ! is_installed "$package"; then
          echo "Installing $package"
          sudo -u "$USERNAME" "$AUR_HELPER" -S --noconfirm "$package"
      fi
  done < "$XFCE_FILE"
fi

if [[ "${DESKTOP_ENV}" == "hypr" ]]; then
  systemctl enable sddm.service
  LC_ALL=C xdg-user-dirs-update --force
  
  echo "[Theme]" >> /etc/sddm.conf
  echo "Current=sugar-dark" >> /etc/sddm.conf

  mkdir -p "/home/$USERNAME/Desktop" \
    "/home/$USERNAME/Documents" \
    "/home/$USERNAME/Downloads" \
    "/home/$USERNAME/Music" \
    "/home/$USERNAME/Pictures" \
    "/home/$USERNAME/Public" \
    "/home/$USERNAME/Templates" \
    "/home/$USERNAME/Videos"

  shopt -s dotglob
  cp -R "$HOME/Installer/configs/.config" "/home/$USERNAME/"
  mkdir -p "/home/$USERNAME/.wallpaper"
  
  cp "$HOME/Installer/configs/wallpapers/"* "/home/$USERNAME/.wallpaper"
  chmod +x -R "/home/$USERNAME/.config/scripts"
  chmod +x -R "/home/$USERNAME/.config/hypr/scripts/"

  cp -R "$HOME/Installer/configs/.local" "/home/$USERNAME/"
  shopt -u dotglob

  # Set ownership of the home directory
  chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"

    # Install Fish shell and set it as the default shell
  if ! which fish &>/dev/null; then
    pacman -S --noconfirm fish
    chsh -s /usr/bin/fish "$USERNAME"
  fi

  echo -ne "Verify Packages Are Installed\n"

  # Path to the hypr.txt file
  HYPR_FILE="$HOME/Installer/pkg-files/hypr.txt"

  # Function to check if a package is installed
  is_installed() {
      pacman -Q "$1" &>/dev/null
  }

  # Read the package names from hypr.txt and install any missing packages
  while IFS= read -r package; do
      if ! is_installed "$package"; then
          echo "Installing $package"
          sudo -u "$USERNAME" "$AUR_HELPER" -S --noconfirm "$package"
      fi
  done < "$HYPR_FILE"

else
  if [[ "${DESKTOP_ENV}" == "server"  ]]; then
    sudo pacman -S --noconfirm --needed sddm
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
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl stop dhcpcd.service
echo "  DHCP stopped"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
systemctl enable bluetooth
echo "  Bluetooth enabled"
systemctl enable avahi-daemon.service
echo "  Avahi enabled"

if [[ "${FS}" == "btrfs" ]]; then
echo -ne "
-------------------------------------------------------------------------
                    Creating Snapper Config
-------------------------------------------------------------------------
"

SNAPPER_CONF="$HOME/Installer/configs/etc/snapper/configs/root"
mkdir -p /etc/snapper/configs/
cp -rfv ${SNAPPER_CONF} /etc/snapper/configs/

SNAPPER_CONF_D="$HOME/Installer/configs/etc/conf.d/snapper"
mkdir -p /etc/conf.d/
cp -rfv ${SNAPPER_CONF_D} /etc/conf.d/

fi

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
sed -i 's/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf # add plymouth after base udev
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
