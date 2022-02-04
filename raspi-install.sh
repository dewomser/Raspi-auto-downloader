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
-f64        raspios_full_arm64
-l64        raspios_lite_arm64
-d64        raspios_arm64
" && exit
elif [[ "$attribut" = "-f" ]]
then
rimage="raspios_full_armhf"
elif [[ "$attribut" = "-l" ]]
then
rimage="raspios_lite_armhf"

elif [[ "$attribut" = "-d" ]]
then
rimage="raspios_armhf"

elif [[ "$attribut" = "-f64" ]]
then
rimage="raspios_full_arm64"

elif [[ "$attribut" = "-l64" ]]
then
rimage="raspios_lite_arm64"

elif [[ "$attribut" = "-d64" ]]
then
rimage="raspios_arm64"

else
echo "Kein Pi-Image ausgewählt. \"raspi-install.sh -h \" für Hilfe!" &&  exit
fi
#rimage ="raspios_lite_armhf"
#rimage="raspios_full_armhf"

cd "$HOME/Downloads" || echo"Downloads Ordner nicht vorhanden"


dirr=$(curl --silent https://downloads.raspberrypi.org/$rimage/images/ | grep -o -E "$rimage-$datum" | tail -1 )
echo dirr :: $dirr
pathr="https://downloads.raspberrypi.org/$rimage/images/$dirr/"
echo pathr :: $pathr
#rname=$(curl --silent "$pathr" | grep -o -E -w "$datum-[[:lower:]-]*\.zip" | head -1)
rname=$(curl --silent "$pathr" | grep -o -E "$datum-[[:alnum:]-]*\.zip" | head -1)

echo rname :: $rname
wget -c "$pathr""$rname" -O "raspi$attribut".zip
echo Test kompletter Pfad :: "$pathr""$rname"
shaname=$(curl --silent "$pathr" | grep -o -E -w "$datum-[[:alnum:]-]*\.zip\.sha256" | head -1) 
echo Test kompletter sha256-Pfad :: $pathr$shaname
wget "$pathr""$shaname" -O raspi"$attribut".sha256
echo "Bitte ein paar Sekunden warten. Der Hash wird erzeugt."
sha1=$(shasum -a 256 raspi"$attribut".zip | grep -o -P "[0-9a-z]{40,}")
sha2=$( grep -o -P "[0-9a-z]{40,}" < raspi"$attribut".sha256 )
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
zahl_laufwerke="${#laufwerke2[@]}"
echo neu erkannte Laufwerke "$zahl_laufwerke"
if [ "$zahl_laufwerke" -eq 1 ]; then
echo Es gibt jetzt dieses neue serielle Blockdevice: "${laufwerke2[0]}"
else
echo "Es kann nicht geschrieben werden. Es wurden mehr oder weniger als 1 SD-Karte erkannt" ; exit
fi
else
exit
fi

echo Ich bin mir SICHER und will auf SD-Karte schreiben : /dev/"${laufwerke2[0]}" \"y\" oder \"n\"

read -r endgueltigja
if [ "$endgueltigja" == "y" ]; then
# das hier aktivieren --TOTENKOPF--- zum Schreiben
#unzip -p raspi"attribut".zip | dd of=/dev/${laufwerke2[0]} bs=4M conv=fsync status=progress
echo "Tatatatah ! fertig"
else
exit
fi
else
echo "Achtung,Prüfsumme stimmt nicht überein !"
fi 

#http://downloads.raspberrypi.org/raspios_full_armhf/images/raspios_full_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-full.zip
