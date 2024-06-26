#!/bin/bash

# Checking if is running in Repo Folder
if [[ "$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')" =~ ^scripts$ ]]; then
    echo "You are running this in ArchTitus Folder."
    echo "Please use ./archtitus.sh instead"
    exit
fi

sudo -S mount -o remount,size=8G /run/archiso/cowspace

# Installing git
echo "Installing git."
pacman -Sy --noconfirm --needed git glibc

echo "Cloning the ArchTitus Project"
git clone https://github.com/ArcExp/Installer

echo "Executing ArcExp Script"

cd Installer/

exec ./arcexp.sh
