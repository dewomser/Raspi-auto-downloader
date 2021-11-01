#!/bin/bash
# gemacht von Stefan Höhn
#https://github.com/dewomser/Raspi-auto-downloader

attribut=$1
datum="[0-9]{4}-[0-9]{2}-[0-9]{2}"


if [[ "$attribut" = "-h" ]]
then
echo "
Aufruf raspi-install.sh [OPTION]

Option      Bedeutung
-f          raspios_full_armhf  Raspberry Pi OS with desktop and recommended software
-l          raspios_lite_armhf  Raspberry Pi OS Lite
-d          raspios_armhf       Raspberry Pi OS with desktop
-h          Diese Hilfe
" && exit
elif [[ "$attribut" = "-l" ]]
then
rimage="raspios_lite_armhf"
elif [[ "$attribut" = "-d" ]]
then
rimage="raspios_armhf"
else
rimage="raspios_full_armhf"
fi
#rimage ="raspios_lite_armhf"
#rimage="raspios_full_armhf"

cd ~/Downloads || exit

dirr=$(curl --silent https://downloads.raspberrypi.org/$rimage/images/ | grep -o -E "$rimage-$datum" | tail -1 )
pathr="https://downloads.raspberrypi.org/$rimage/images/$dirr/"
rname=$(curl --silent "$pathr" | grep -o -E -w "$datum-[[:lower:]-]*\.zip" | head -1)
wget -erobots=off "$pathr""$rname" -O raspi.zip
#echo Test kompletter Pfad :: "$pathr""$rname"
shaname=$(curl --silent "$pathr" | grep -o -E -w "$datum-[[:lower:]-]*\.zip\.sha256" | head -1) 
#echo Test kompletter sha256-Pfad :: $pathr$shaname
wget "$pathr""$shaname" -O raspi.sha256
echo "Bitte ein paar Sekunden warten. Der Hash wird erzeugt."
sha1=$(shasum -a 256 raspi.zip | grep -o -P "[0-9a-z]{40,}")
sha2=$( grep -o -P "[0-9a-z]{40,}" < raspi.sha256 )
sleep 1
echo Prüfsumme aus Download "$sha1"
echo Prüfsumme von Webseite "$sha2"

if [ "$sha1" == "$sha2" ]; then
echo "Prüfsumme stimmt."
echo "-----------------"
echo "SD-Karte auf die geschrieben werden soll ENTFERNEN !" \"y\"
read -r input
if [ "$input" == "y" ];  then
mapfile -t laufwerke < <(lsblk -l -o Name | grep -E -v "[0-9]" | grep -E "sd[a-z]")
else
exit
fi

echo Es gibt diese seriellen Blockdevices "${laufwerke[*]}"
echo "SD-Karte auf die geschrieben werden soll EINSCHIEBEN !" \"y\"
read -r input
if [ "$input" == "y" ];  then
mapfile -t laufwerke1 < <(lsblk -l -o Name | grep -E -v "[0-9]" | grep -E "sd[a-z]")

mapfile -t laufwerke2 < <({ printf "%s\n" "${laufwerke[@]}" | sort -u; printf "%s\n" "${laufwerke1[@]}" "${laufwerke[@]}"; } | sort | uniq -u)

echo Es gibt jetzt dieses neue serielle Blockdevice: "${laufwerke2[0]}"
else
exit
fi

echo Ich bin mir SICHER und will auf SD-Karte schreiben : /dev/"${laufwerke2[0]}" \"y\" oder \"n\"

read -r endgueltigja
if [ "$endgueltigja" == "y" ]; then
# das hier aktivieren --TOTENKOPF--- zum Schreiben
#unzip -p raspi.zip | dd of=/dev/${laufwerke2[0]} bs=4M conv=fsync status=progress
echo "Tatatatah ! fertig"
else
exit
fi
else
echo "Achtung,Prüfsumme stimmt nicht überein !"
fi 

#http://downloads.raspberrypi.org/raspios_full_armhf/images/raspios_full_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-full.zip
