#!/bin/sh

# Remove snaps completely from Ubuntu
# Tested on Ubuntu 22.04

# WARNING: This script will remove ALL snap applications. (Includning Firefox and the Software store).
# Make backups of your configurations, bookmarks, etc. You should also make sure to have replacements
# ready for software that you use. (Like Firefox for example.)

# Lists all installed snap applications and then uninstalls them.
for p in $(snap list | awk '{print $1}'); do
  sudo snap remove $p
done

# Stops snapd and unmounts as many snaps as it can.
sudo systemctl stop snapd
for m in /snap/core/*; do
   sudo umount $m
done
sudo snap remove core
# If anything remains, the steps below will take care of it.

sudo apt autoremove --purge snapd

rm -rf ~/snap
sudo rm -rf /snap
sudo rm -rf /var/snap
sudo rm -rf /var/lib/snapd
sudo rm -rf /var/cache/snapd

# (OPTIONAL) The following command will make sure snapd does not get installed again as a dependency.
# Downside is that it will show an error if you try to install certain packages that only comes as snap.
# Uncomment the below line if that is what you want.

 sudo apt-mark hold snapd
