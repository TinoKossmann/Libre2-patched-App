#!/bin/bash

# Color codes
NORMAL='\033[0;39m'
GREEN='\033[1;32m'
RED='\033[1;31m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'

WORKDIR=$(pwd)
FILENAME='com.freestylelibre.app.de_2019-04-22'

echo -e "${WHITE}Prüfe benötigte Tools ...${NORMAL}"
MISSINGTOOL=0
echo -en "${WHITE}  apksigner ... ${NORMAL}"
which apksigner > /dev/null
if [ $? = 0 ]; then
  echo -e "${GREEN}gefunden.${NORMAL}"
else
  echo -e "${RED}nicht gefunden.${NORMAL}"
  MISSINGTOOL=1
fi
echo -en "${WHITE}  apktool ... ${NORMAL}"
if [ -x tools/apktool ]; then
  echo -e "${GREEN}gefunden.${NORMAL}"
  APKTOOL=$(pwd)/tools/apktool
else
  which apktool > /dev/null
  if [ $? = 0 ]; then
    echo -e "${GREEN}gefunden.${NORMAL} Herkunft und Kompatibilität allerdings unbekannt."
    APKTOOL=$(which apktool)
  else
    echo -e "${RED}nicht gefunden.${NORMAL}"
    MISSINGTOOL=1
  fi
fi
echo -en "${WHITE}  git ... ${NORMAL}"
which git > /dev/null
if [ $? = 0 ]; then
  echo -e "${GREEN}gefunden.${NORMAL}"
else
  echo -e "${RED}nicht gefunden.${NORMAL}"
  MISSINGTOOL=1
fi
echo -en "${WHITE}  keytool ... ${NORMAL}"
which keytool > /dev/null
if [ $? = 0 ]; then
  echo -e "${GREEN}gefunden.${NORMAL}"
else
  echo -e "${RED}nicht gefunden.${NORMAL}"
  MISSINGTOOL=1
fi
echo -en "${WHITE}  zipalign ... ${NORMAL}"
which zipalign > /dev/null
if [ $? = 0 ]; then
  echo -e "${GREEN}gefunden.${NORMAL}"
else
  echo -e "${RED}nicht gefunden.${NORMAL}"
  MISSINGTOOL=1
fi
echo
if [ ${MISSINGTOOL} = 1 ]; then
  echo -e "${YELLOW}=> Bitte installieren Sie die benötigten Tools.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Suche APK Datei '${FILENAME}.apk' ...${NORMAL}"
if [ -e APK/${FILENAME}.apk ]; then
  echo -e "${GREEN}  gefunden.${NORMAL}"
  echo
else
  echo -e "${RED}  nicht gefunden.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte laden Sie die original APK Datei von https://www.apkmonk.com/download-app/com.freestylelibre.app.de/5_com.freestylelibre.app.de_2019-04-22.apk/ herunter und legen Sie sie im Verzeichnis APK/ ab.${NORMAL}"
  exit 1
fi

if [ -f APK/${FILENAME}.apk.md5 ]; then
  echo -e "${WHITE}Prüfe MD5 Summe der APK Datei ...${NORMAL}"
  md5sum -c APK/${FILENAME}.apk.md5 > /dev/null 2>&1
elif [ -f APK/${FILENAME}.apk.sha1 ]; then
  echo -e "${WHITE}Prüfe SHA1 Summe der APK Datei ...${NORMAL}"
  sha1sum -c APK/${FILENAME}.apk.sha1 > /dev/null 2>&1
else
  echo -e "${YELLOW}Keine Prüfung der APK Datei ...${NORMAL}"
  true
fi
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
else
  echo -e "${RED}  nicht okay.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte laden Sie die korrekte, unverfälschte original APK herunter.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Enpacke original APK Datei ...${NORMAL}"
${APKTOOL} d -o /tmp/librelink APK/${FILENAME}.apk
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
else
  echo -e "${RED}  nicht okay.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte prüfen Sie o.a. Fehler.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Patche original App ...${NORMAL}"
cd /tmp/librelink/
git apply --whitespace=nowarn --verbose ${WORKDIR}/xdrip2.git.patch
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
else
  echo -e "${RED}  nicht okay.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte prüfen Sie o.a. Fehler.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Verwende neuen Sourcecode für gepatchte App ...${NORMAL}"
cp -Rv ${WORKDIR}/sources/* /tmp/librelink/smali_classes2/com/librelink/app/
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
else
  echo -e "${RED}  nicht okay.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte prüfen Sie o.a. Fehler.${NORMAL}"
  exit 1
fi
chmod 644 /tmp/librelink/smali_classes2/com/librelink/app/*.smali

echo -e "${WHITE}Verwende neue Grafiken für gepatchte App ...${NORMAL}"
cp -Rv ${WORKDIR}/graphics/* /tmp/librelink/
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
else
  echo -e "${RED}  nicht okay.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte prüfen Sie o.a. Fehler.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Kopiere original APK Datei in gepatchte App ...${NORMAL}"
cp ${WORKDIR}/APK/${FILENAME}.apk /tmp/librelink/assets/original.apk
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
else
  echo -e "${RED}  nicht okay.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte prüfen Sie o.a. Fehler.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Baue gepatchte App zusammen ...${NORMAL}"
${APKTOOL} b -o ${WORKDIR}/APK/librelink_unaligned.apk
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
else
  echo -e "${RED}  nicht okay.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte prüfen Sie o.a. Fehler.${NORMAL}"
  exit 1
fi

echo -e "${WHITE}Räume /tmp/ auf ...${NORMAL}"
cd ${WORKDIR}
rm -rf /tmp/librelink/
echo -e "${GREEN}  okay."
echo

echo -e "${WHITE}Optimiere Ausrichtung der gepatchten APK Datei...${NORMAL}"
zipalign -p 4 APK/librelink_unaligned.apk APK/${FILENAME}_patched.apk
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
  rm APK/librelink_unaligned.apk
else
  echo -e "${RED}  nicht okay.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte prüfen Sie o.a. Fehler.${NORMAL}"
  exit 1
fi

if [ ! -f tools/libre-keystore.p12 ]; then
 echo -e "${WHITE}Erstelle Keystore zum Signieren der gepatchten APK Datei ...${NORMAL}"
 keytool -genkey -v -keystore tools/libre-keystore.p12 -storetype PKCS12 -alias "Libre Signer" -keyalg RSA -keysize 2048 --validity 10000 --storepass geheim --keypass geheim -dname "cn=Libre Signer, c=de"
 if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
 else
  echo -e "${RED}  nicht okay.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte prüfen Sie o.a. Fehler.${NORMAL}"
  exit 1
 fi
else
 echo -e "${WHITE}Verwende existierenden Keystore zum Signieren der gepatchten APK Datei ...${NORMAL}"
fi

echo -e "${WHITE}Signiere gepatchte APK Datei ...${NORMAL}"
if [ -x /usr/lib/android-sdk/build-tools/debian/apksigner.jar ]; then
  java -jar /usr/lib/android-sdk/build-tools/debian/apksigner.jar sign --ks-pass pass:geheim --ks tools/libre-keystore.p12 APK/${FILENAME}_patched.apk
elif [ -x /usr/share/apksigner/apksigner.jar ]; then
  java -jar /usr/share/apksigner/apksigner.jar sign --ks-pass pass:geheim --ks tools/libre-keystore.p12 APK/${FILENAME}_patched.apk
else
  apksigner sign --ks-pass pass:geheim --ks tools/libre-keystore.p12 APK/${FILENAME}_patched.apk
fi
if [ $? = 0 ]; then
  echo -e "${GREEN}  okay.${NORMAL}"
  echo
  # libre-keystore.p12 nicht entfernen!
else
  echo -e "${RED}  nicht okay.${NORMAL}"
  echo
  echo -e "${YELLOW}=> Bitte prüfen Sie o.a. Fehler.${NORMAL}"
  exit 1
fi

if [ -d /mnt/c/ ]; then
  echo -e "${WHITE}Windows-System erkannt ...${NORMAL}"
  echo -e "${WHITE}Kopiere APK ...${NORMAL}"
  mkdir -p /mnt/c/APK
  cp APK/${FILENAME}_patched.apk /mnt/c/APK/
  if [ $? = 0 ]; then
    echo -e "${GREEN}  okay.${NORMAL}"
    echo
  echo -en "${YELLOW}Fertig! Die gepatchte und signierte APK Datei finden Sie unter C:\\APK"
  echo -en "\\"
  echo -e "${FILENAME}_patched.apk${NORMAL}"
  else
    echo -e "${RED}  nicht okay.${NORMAL}"
    echo
    echo -e "${YELLOW}=> Bitte prüfen Sie o.a. Fehler.${NORMAL}"
    exit 1
  fi
else
  echo -e "${YELLOW}Fertig! Die gepatchte und signierte APK Datei finden Sie unter APK/${FILENAME}_patched.apk${NORMAL}"
fi
