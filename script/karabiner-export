#!/bin/sh

# Exports all the settings that are configured in the Karabiner UI (e.g., which
# remappings are enabled, key repeat settings, etc.).

# Get path to the directory where this script resides
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Export Karabiner configuration
PATH_TO_IMPORT_SCRIPT=$DIR/karabiner-import
/Applications/Karabiner.app/Contents/Library/bin/karabiner export > $PATH_TO_IMPORT_SCRIPT
