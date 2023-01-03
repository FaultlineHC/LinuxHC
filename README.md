# City of Heroes: Homecoming installer for the Steam Deck

## Basic Usage

If you have a Steam Deck and are happy installing the Homecoming Launcher in your Games home folder, you can run this script without any changes.

* Switch to Desktop mode on your Steam Deck.
* In the Applications menu, open a terminal such as Konsole.
* Run the following command: `bash <(curl -s https://raw.githubusercontent.com/FaultlineHC/LinuxHC/main/hc-install.sh)`

The script will first prompt you on which Proton runtime to use. Testing was done with Proton 7.0, but it should work with any version. If the script cannot detect any Proton versions, it will offer to install the latest version of GE-Proton and use it.

After selecting the Proton version, it will download the Homecoming installer and run it. The Windows-style path you select in the Homecoming installer doesn't matter; just click the Install button.

As soon as you click the Install button, you will be prompted for the location of Homecoming Launcher. If this is a new installation, only the 32-bit version will be available; select it and click OK to add an icon to the Desktop.

You can now add it to Steam by right-clicking this desktop icon and selecting Add to Steam.

## Troubleshooting

If the script cannot detect your Proton runtimes, but you know where they are located, you can change the command line slightly in order to tell the script where to find the Proton runtimes. For example: `bash <(curl -s https://raw.githubusercontent.com/FaultlineHC/LinuxHC/main/hc-install.sh) proton ~/Games/GE-Proton`

If the Homecoming Installer download is corrupted, the Proton version doesn't work correctly, you wish to switch to the 64-bit version of the Homecoming Launcher or the Desktop icon is broken, run the following command: `bash <(curl -s https://raw.githubusercontent.com/FaultlineHC/LinuxHC/main/hc-install.sh) clean` to remove the cached settings and recreate the launcher icon without reinstalling the Homecoming Launcher itself; it will not touch your costumes, screenshots, mods, or any other user data.

## Advanced Usage

If the default installation path doesn't work for you, you will need to download the script in order to modify it. You can do this from the terminal by running the folowing commands:

```
curl -s https://raw.githubusercontent.com/FaultlineHC/LinuxHC/main/hc-install.sh -o hc-install.sh
chmod 0755 hc-install.sh
nano hc-install.sh
```

At this point, you will be in a text editor and can change the following lines to point to the location where your Proton runtimes are located, where you want Homecoming Launcher to be installed and where to write the Desktop icon file:

```
proton_path=~/.local/share/Steam/steamapps/common
homecoming_path=~/Games/Homecoming
desktop_path=~/Desktop
```

After you are done editing the paths, hit Ctrl+O and hit Enter to save, then Ctrl+X to exit the text editor. You can now launch your modified script from the command line by running `./hc-install.sh` or, if you want to run a clean installation for troubleshooting purposes, `./hc-install.sh clean` instead.