#!/bin/bash

# ONLY if reinstall
file_to_rename="PharmStarLauncher_backup.sh"

if [[ -n "$file_to_rename" ]]; then
    # Renommer le fichier
    mv "$file_to_rename" "PharmStarLauncher.sh"
    echo "Reinstalling PharmStarLauncher.sh to PATH."
else
    echo "No file with _backup suffix found."
    exit 0
fi

# Backup for script
cp PharmStarLauncher.sh PharmStarLauncher_backup.sh

# Adding PharmStarLauncher to $PATH
sudo mv PharmStarLauncher.sh /usr/local/bin/PharmStarLauncher

# Adding permission to execute the script
sudo chmod +x /usr/local/bin/PharmStarLauncher

# Create symlink to desktop
if [[ -d ~/Desktop ]]; then
    ln -s /usr/local/bin/PharmStarLauncher ~/Desktop/PharmStarLauncher
elif [[ -d ~/Bureau ]]; then
    ln -s /usr/local/bin/PharmStarLauncher ~/Bureau/PharmStarLauncher
else
    echo "FATAL ERROR : Neither Desktop nor Bureau directories were found."
    exit 1
fi

#!/bin/bash

# Path to the shortcut on the desktop (or "Bureau" depending on the configuration)
shortcut_path_desktop="$HOME/Desktop/PharmStarLauncher"
shortcut_path_bureau="$HOME/Bureau/PharmStarLauncher"

# Success or not ?
if [[ -L "$shortcut_path_desktop" ]] || [[ -L "$shortcut_path_bureau" ]]; then
    echo "Installation completed successfully. An executable shortcut has been placed on your desktop."
else
    echo "Error during installation. Please contact support at: https://github.com/JC-Delmas/PharmStarLauncher/issues"
fi