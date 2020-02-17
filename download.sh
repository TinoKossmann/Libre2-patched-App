#!/bin/bash

# Color codes
NORMAL='\033[0;39m'
GREEN='\033[1;32m'
RED='\033[1;31m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'

WORKDIR=$(pwd)
FILENAME='com.freestylelibre.app.de_2019-04-22'
#FILENAME='com.freestylelibre.app.de_2020-02-15'

# wget HSTS-bugfix for debian as subsystem in Windows
touch ~/.wget-hsts
chmod 644 ~/.wget-hsts

echo -e "${WHITE}Lade original APK herunter ...${NORMAL}"
wget -O APK/apkpure.html --keep-session-cookies --save-cookies cookies.txt https://apkpure.com/de/freestyle-librelink-de/com.freestylelibre.app.de/download/4751-APK
#wget -O APK/apkpure.html --keep-session-cookies --save-cookies cookies.txt https://apkpure.com/de/freestyle-librelink-de/com.freestylelibre.app.de/download/5417-APK

URL=$(grep "hier klicken" APK/apkpure.html | sed 's#^.*https://##' | sed 's/">.*//')
wget -O APK/${FILENAME}.apk --load-cookies cookies.txt https://${URL}
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
else
  echo -e "${RED}  nicht okay.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte prüfen Sie o.a. Fehler.${NORMAL}"
  exit 1
fi
rm cookies.txt
rm APK/apkpure.html

echo -e "${WHITE}Lade 'apktool' herunter ...${NORMAL}"
echo "Info: Debian liefert eine nicht ohne weiteres funktionierende 'dirty'-Version mit. Daher der externe Download."
mkdir -p tools
wget -q -O tools/apktool https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
chmod 755 tools/apktool
wget -q -O tools/apktool.jar https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.0.jar
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
else
  echo -e "${RED}  nicht okay.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte prüfen Sie o.a. Fehler.${NORMAL}"
  exit 1
fi
