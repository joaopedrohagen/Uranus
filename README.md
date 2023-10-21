<h1 align="center">
  <br>
  <img src="urano.png" width="200">
  <br>
  Uranus
  <br>
</h1>

<h4 align="center"> My repository of scripts useful for server administration </h4>

---
This repository is for storing scripts that assist me in configuring, conducting analyses, and managing the servers I work with.

## Autocloud - autocloud.rb
Allows running commands and scripts on batch servers. If you have already added your key to the server, you can leave the password as nil in the response method; otherwise, include your password as a string.

## IP Geolocation - geolocation_ip.rb
This code uses 2 APIs to pinpoint the exact location of the IP address you're searching for. One API complements the other to make the data more accurate.

## Linode Distro Upgrade - dist_upgrade_linode.sh
This Script makes the distro upgrade safely. It integrates Linode's API by taking a Snapshot before starting the upgrade and, if it doesn't work, it returns to the previous configuration through the Snapshot.

#### More code will come. Stay tuned for updates.

#


> **Note**
> These scripts were designed to be used on Ubuntu-based Linux servers.
