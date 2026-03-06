#!/usr/bin/env bash
set -euo pipefail

#AutoRooter voor Android devices (BASH)
#Gemaakt door: Jens van den Hurk

#DISCLAIMER: Dit werkt vanaf Android 5 tot Android 13.
#Dit script runt een half automatische rooter van generieke android devices, dit kunnen devices zijn zoals OnePlus, Xiaomi, Samsung en soort gelijk.
#Dit blijft altijd nog een White Glove provisioning script, waarbij altijd user interaction nog vereist wordt tijdens de doorloop van dit script

#BENODIGDHEDEN:
# - Android device met minimaal Android 5.0
# - USB kabel
# - Computer met ADB en Fastboot geïnstalleerd
# - OEM Unlocking enabled in de developer options van het Android device
# - USB Debugging enabled in de developer options van het Android device
# - Magisk (of een vergelijkbare tool) voor het patchen van de boot image
# - Minimaal 50% batterij niveau op het Android device
# - Back-up van belangrijke data op het Android device (aanbevolen)

#_________________________________________________________

#Kleuren voor de variabelen
#Alle kleuren bieden zijn eigen informatie; Rood is critical/error, Yellow is warning, Green is Success en Blue is Information.
#dit biedt overzicht tijdens het proces zodat de user ook duidelijk kan zien wat er allemaal gebeurd.

# Kleuren (ANSI)
RED="\033[0;31m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

Error()   { echo -e "${RED}[ERROR]${NC} $1"; }
Warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
Success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
Info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
Header()  {
  echo -e "\n${CYAN}══════════════════════════════════════${NC}"
  echo -e "${CYAN}  $*${NC}"
  echo -e "${CYAN}══════════════════════════════════════${NC}"
}

#Dit biedt overzicht tijdens dat het script zijn werk doet, dat geeft de gebruiker een duidelijk beeld wat er allemaal gebeurd tijdens het rooten.
#Daarnaast is het ook belangrijk dat de gebruiker aan de hand van kleuren en een beetje gezond verstand ziet of het proces daadwerkelijk goed loopt of dat er iets mis gaat tijdens het runnen van dit script.
#Bronnen voor dit concept zijn: https://ioflood.com/blog/bash-color/ en https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux

#_________________________________________________________

#Pre-Check!
#In deze fase van dit script wordt gecontroleerd of de volgende componenten aanwezig zijn:
# - Device Model -> Serial Number -> Android Version + Fingerprint
# - Batterij =< 50%?
# - Debugging ON?
# - Adb en Fastboot availablity
# - OEM unlocking TRUE/FALSE?

echo "Starting AutoRooter for Android devices..."

if device=$(adb get-serialno 2>/dev/null); then
    Success "Device gevonden: $device"
else
    Error "Geen apparaat gevonden. Zorg ervoor dat je apparaat is verbonden en USB-debugging is ingeschakeld."
    exit 1
fi
Bron: https://developer.android.com/studio/command-line/adb#checkdevice

#Controle of de de benodigde apps aanwezig zijn binnen de android device.
command -v adb >/dev/null 2>&1 || { Error "adb ontbreekt. Installeer Android platform-tools."; exit 1; }
command -v fastboot >/dev/null 2>&1 || { Error "fastboot ontbreekt. Installeer Android platform-tools."; exit 1; }
Success "adb + fastboot aanwezig"
#Minimale waarden toekennen voor de checkups.

#Start controle van de android device, dit is belangrijk doordat er bovenstaande en enkeling gestelde minimum waarden zijn gedefinieerd, dit zorgt ervoor dat het proces van het rooten soepel verloopt.
DEVICE_MODEL=$(adb shell getprop ro.product.model)
SERIAL_NUMBER=$(adb get-serialno)
ANDROID_VERSION=$(adb shell getprop ro.build.version.release)
FINGERPRINT=$(adb shell getprop ro.build.fingerprint)
BATTERY_LEVEL=$(adb shell dumpsys battery | grep level | awk '{print $2}')
DEBUGGING=$(adb shell getprop ro.debuggable)
OEM_UNLOCKING=$(adb shell getprop ro.oem_unlock_supported)

MIN_BATTERY_LEVEL=50
if [ "$BATTERY_LEVEL" -gt "$MIN_BATTERY_LEVEL" ]; then
  Success "Batterij niveau is $BATTERY_LEVEL%, dit is voldoende voor het rooten."
else
  Warning "Batterij niveau is $BATTERY_LEVEL%, het wordt aanbevolen om minimaal $MIN_BATTERY_LEVEL% te hebben voor een soepel root proces."
fi
#Bron: https://tecadmin.net/bash-greater-than-or-equal-operator/

MIN_ANDROID_VERSION=5
if [ "$(echo "$ANDROID_VERSION < $MIN_ANDROID_VERSION" | bc -l)" -eq 1 ]; then
  Error "Android versie is $ANDROID_VERSION, dit is niet ondersteund. Minimaal Android $MIN_ANDROID_VERSION is vereist."
  exit 1
else
  Success "Android versie is $ANDROID_VERSION, dit is ondersteund."
fi
#Bron: https://android.stackexchange.com/questions/187829/adb-commands-to-get-the-adb-version-of-mobile-phone

#Als de Device voldoet aan de volgende eisen; Debugging ON, OEM unlocking TRUE en Batterij >= 50%, dan kan deze succesvol worden geroot.
if [ "$DEBUGGING" -eq 1 ] && [ "$OEM_UNLOCKING" -eq 1 ] && [ "$BATTERY_LEVEL" -ge "$MIN_BATTERY_LEVEL" ]; then
    Success "$DEVICE_MODEL is ready for take off."
else 
    Error "Device $DEVICE_MODEL is niet klaar voor take off, controleer de bovenstaande checks en probeer het opnieuw."
    exit 1
fi
#Bronnen voor dit concept zijn: https://android.stackexchange.com/questions/187829/adb-commands-to-get-the-adb-version-of-mobile-phone, https://developer.android.com/studio/command-line/adb#shellcmds, https://developer.android.com/studio/command-line/adb#fastbootcmds, https://developer.android.com/studio/command-line/adb#checkdebugging, https://developer.android.com/studio/command-line/adb#checkoemunlocking, https://stackoverflow.com/questions/68622119/how-to-use-if-elif-else-in-bash

#_________________________________________________________

#Pre-Flight!

Warning "Zorg ervoor dat je een back-up hebt gemaakt van de belangerijke data op dit apparaat. Dit voorkomt eventuele gegevensverlies tijdens dit proces, Risico ligt altijd bij de eindgebruiker."

#Guided Step

#First Reboot naar de bootloader

#Boot image -> flashing

#patching -> end step


#verify
#Dit is de laatste stap van dit script, waarbij alle functionaliteit gecontroleerd wordt zodat de rooting gelukt is.
