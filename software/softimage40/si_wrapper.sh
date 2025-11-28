#!/usr/sgug/bin/env bash
# Softimage wrapper script

# If user has a copy of the file source it, otherwise source the system one
if [[ -r ~/.softimage400.sh ]]; then
    source ~/.softimage400.sh
else
    # Source the default softimage file.
    source /usr/Softimage/Soft3D_4.0/.softimage400.sh
fi

# Execute all arguments passed to the script
exec "$@"