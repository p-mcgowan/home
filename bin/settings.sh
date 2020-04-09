#!/bin/bash

usage="dump and load dconf settings
usage: $(basename $0) mode [file]
eg:
  $(basename $0) export settings.dconf
  $(basename $0) import settings.dconf

options:
  -h, --help    show this menu
"

file=

while [ -n "$1" ]; do
  case $1 in
    -e | --export | export) export=true ;;
    -i | --import | import) import=true ;;
    -h | --help | help) echo "$usage"; exit 0 ;;
    *) file=$1;;
  esac
  shift
done

if [ -z "$file" ]; then
  echo "file required"
  exit 1
fi

if [ ! -f "$file" ] && [ -n "$import" ]; then
  echo "file '$file' not found"
  exit 1
fi

if [ -z "$export$import" ]; then
  echo "Either import or export required"
  exit 1
fi

dump() {
  local setting="$1"
  dconf dump $setting | while read line; do
    if [[ $line =~ ^\[(.*)\]$ ]]; then
      if [ ${BASH_REMATCH[0]} == "[/]" ]; then
        echo "[${setting:1:-1}]"
      else
        echo "[${setting:1:-1}/${BASH_REMATCH[1]}]"
      fi
    else
      echo "$line"
    fi
  done
  echo "" >>$file
}

settings_export() {
  if [ -f "$file" ]; then
    read -p "$file exists, overwrite? [y/N] " ans
    if [ "${ans,,}" != "y" ] && [ "${ans,,}" != "yes" ]; then
      exit 0
    fi
  fi

  echo -n >$file
  settings="\
  /org/gnome/settings-daemon/plugins/power/ \
  /org/gnome/settings-daemon/plugins/media-keys/  \
  /org/gnome/settings-daemon/plugins/xsettings/ \
  /org/gnome/settings-daemon/peripherals/keyboard/ \
  /org/gnome/shell/extensions/ \
  /org/gnome/desktop/interface/ \
  /org/gnome/desktop/notifications/application/org-gnome-software/ \
  /org/gnome/desktop/screensaver/ \
  /org/gnome/desktop/peripherals/touchpad/ \
  /org/gnome/desktop/peripherals/mouse/ \
  /org/gnome/desktop/wm/preferences/ \
  /org/gnome/desktop/background/ \
  /org/gnome/desktop/input-sources/ \
  "

  for setting in $settings; do
    dump $setting >>$file
  done
}

settings_import() {
  dconf load / <$file
}

if [ -n "$import" ]; then
  settings_import
elif [ -n "$export" ]; then
  settings_export
fi
