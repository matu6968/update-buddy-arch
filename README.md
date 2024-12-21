# update-buddy (Arch Linux edition)
Automatically check for updates on boot. If there are any, asks permission to upgrade.  
![screenshot](https://github.com/matu6968/update-buddy-arch/blob/main/screenshot.png?raw=true)
# To install:
```
sudo pacman -S yad
git clone https://github.com/matu6968/update-buddy-arch
mkdir ~/.config/autostart
echo "[Desktop Entry]
Name=Update Buddy
Exec=$HOME/update-buddy/onstartup.sh
Type=Application
X-GNOME-Autostart-enabled=true
Hidden=false
NoDisplay=false" > ~/.config/autostart/update-buddy.desktop
```
