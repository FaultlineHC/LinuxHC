#!/bin/bash

proton_path=~/.local/share/Steam/steamapps/common
homecoming_path=~/Games/Homecoming
desktop_path=~/Desktop

ge_proton_path=~/.local/share/Steam/compatibilitytools.d
ge_proton_url=https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton7-43/GE-Proton7-43.tar.gz
ge_proton_file=GE-Proton7-43.tar.gz

function get_proton_rt () {
    if [ ! -f "$homecoming_path/hc-proton.cfg" ]; then
        find "$ge_proton_path" -iname "proton" > "$homecoming_path/hc-list.tmp"
        find "$proton_path" -iname "proton" >> "$homecoming_path/hc-list.tmp"

        if [ -s "$homecoming_path/hc-list.tmp" ]; then
            IFS=$'[\n]';
            proton_rt=$(zenity --list --title="Homecoming Installer" --text="Select Proton Runtime:" --width 640 --height 480 \
                --column="Path" $(cat "$homecoming_path/hc-list.tmp"))
            unset IFS;
            rm "$homecoming_path/hc-list.tmp"

            if [ ! -f "$proton_rt" ]; then
                exit 1;
            fi
        else
            rm "$homecoming_path/hc-list.tmp"
            if [ "$1" = "required" ]; then
                zenity --error --title="Homecoming Installer" --text="Unable to find any Proton runtimes!\n\nMake sure at least one version of Proton is installed in\n$proton_path" --width=480
                exit 101;
            else
                zenity --question --title="Homecoming Installer" --text="Unable to find any Proton runtimes!\n\nDo you want me to try to install $ge_proton_file?" --width=480
                if [ "$?" = 1 ]; then
                    exit 201;
                fi
                mkdir -p "$ge_proton_path"
                curl -o "$homecoming_path/$ge_proton_file" -L "$ge_proton_url"
                tar -xvzf "$homecoming_path/$ge_proton_file" -C "$ge_proton_path"
                rm "$homecoming_path/$ge_proton_file"
                return 0;
            fi
        fi

        echo $proton_rt > "$homecoming_path/hc-proton.cfg"
    fi

    proton_rt=$(cat "$homecoming_path/hc-proton.cfg")
}

function get_hc_launcher () {
    if [ ! -f "$homecoming_path/hc-launcher.cfg" ]; then
        find "$homecoming_path" -iname "launcher.exe" > "$homecoming_path/hc-list.tmp"

        if [ -s "$homecoming_path/hc-list.tmp" ]; then
            IFS=$'[\n]';
            hc_launcher=$(zenity --list --title="Homecoming Installer" --text="Select Homecoming Launcher:" --width 640 --height 480 \
                --column="Path" $(cat "$homecoming_path/hc-list.tmp"))
            unset IFS;
            rm "$homecoming_path/hc-list.tmp"

            if [ ! -f "$hc_launcher" ]; then
                exit 2;
            fi
        else
            rm "$homecoming_path/hc-list.tmp"
            if [ "$1" = "required" ]; then
                zenity --error --title="Homecoming Installer" --text="Unable to find the Homecoming Launcher!\n\nDid you cancel the installation before selecting a path?" --width=480
                exit 102;
            else
                return 0;
            fi
        fi

        echo $hc_launcher > "$homecoming_path/hc-launcher.cfg"
    fi

    hc_launcher=$(cat "$homecoming_path/hc-launcher.cfg")
}

function run_hc_installer () {
    if [ ! -f "$homecoming_path/hcinstall.exe" ]; then
        curl -o "$homecoming_path/hcinstall.exe" https://manifest.cohhc.gg/launcher/hcinstall.exe
    fi
    "$proton_rt" run "$homecoming_path/hcinstall.exe"
}

function create_desktop_icon () {
    if [ ! -f "$homecoming_path/hc-launcher.sh" ]; then
        echo \#!/bin/bash > "$homecoming_path/hc-launcher.sh"
        echo export STEAM_COMPAT_DATA_PATH=$homecoming_path >> "$homecoming_path/hc-launcher.sh"
        echo export STEAM_COMPAT_CLIENT_INSTALL_PATH=$homecoming_path >> "$homecoming_path/hc-launcher.sh"
        echo \"$proton_rt\" run \"$hc_launcher\" >> "$homecoming_path/hc-launcher.sh"
        chmod 0755 "$homecoming_path/hc-launcher.sh"
    fi

    if [ ! -f "$homecoming_path/launcher.ico" ]; then
        curl -o "$homecoming_path/launcher.ico" https://raw.githubusercontent.com/FaultlineHC/LinuxHC/main/launcher.ico
    fi

    if [ ! -f "$desktop_path/hc-launcher.desktop" ]; then
        echo \#!/usr/bin/env xdg-open > "$desktop_path/hc-launcher.desktop"
        echo [Desktop Entry] >> "$desktop_path/hc-launcher.desktop"
        echo Name=HC Launcher >> "$desktop_path/hc-launcher.desktop"
        echo Exec="$homecoming_path/hc-launcher.sh" >> "$desktop_path/hc-launcher.desktop"
        echo Icon="$homecoming_path/launcher.ico" >> "$desktop_path/hc-launcher.desktop"
        echo Terminal=false >> "$desktop_path/hc-launcher.desktop"
        echo Type=Application >> "$desktop_path/hc-launcher.desktop"
        echo StartupNotify=false >> "$desktop_path/hc-launcher.desktop"
        chmod 0755 "$desktop_path/hc-launcher.desktop"
    fi
}

mkdir -p "$homecoming_path"
if [ "$1" = "clean" ]; then
    rm "$desktop_path/hc-launcher.desktop"
    rm "$homecoming_path/hc-launcher.sh"
    rm "$homecoming_path/hc-proton.cfg"
    rm "$homecoming_path/hc-launcher.cfg"
    rm "$homecoming_path/hcinstall.exe"
    rm "$homecoming_path/launcher.ico"
fi

if [ ! "$2" = "" ]; then
    proton_path=$2
fi

export STEAM_COMPAT_DATA_PATH=$homecoming_path
export STEAM_COMPAT_CLIENT_INSTALL_PATH=$homecoming_path

get_proton_rt
if [ "$proton_rt" = "" ]; then
    get_proton_rt required
fi

get_hc_launcher
if [ "$hc_launcher" = "" ]; then
    run_hc_installer
    get_hc_launcher required
    create_desktop_icon
else
    create_desktop_icon
    "$proton_rt" run "$hc_launcher"
fi
