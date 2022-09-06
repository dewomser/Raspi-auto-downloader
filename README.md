# Raspi-auto-downloader

.
05.05.2022 Diese Version kann jetzt Images die mit xz gepackt wurden.


.[![Trigger: Push action](https://github.com/dewomser/Raspi-auto-downloader/actions/workflows/main.yml/badge.svg)](https://github.com/dewomser/Raspi-auto-downloader/actions/workflows/main.yml) Shellchecked

Load fresh images for the Raspberry 
Pi, check SHA256, and copy to SD-Card, a Bashscript.

Jetzt auch mit den 64er Images

## Hilfe raspi-install.sh -h

![alt text](./bilder/help.png "help")


## Copy and check SD-Image

![alt text](https://github.com/dewomser/Raspi-auto-downloader/blob/main/bilder/copy.png "copy and check")

## Fork, Issue, Pull request, Clone
Be carefull, this  script is in status Beta 0.2. !

## Bei fehlenden Rootrechten zum Schreiben auf SD-Karte

Wenn die Karte nur als Root gemountet werden kann, muss dd durch sudo dd ersetzt werden. umount -> sudo umount. Gilt ab Zeile 105

### Alternative für Ubuntu:

echo 'KERNEL=="sd*", SUBSYSTEMS=="usb", MODE="0666"' | sudo tee /etc/udev/rules.d/99-usb-storage.rules

Quelle : https://askubuntu.com/questions/828545/using-dd-without-sudo

