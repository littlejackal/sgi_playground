#!/bin/csh -f
# rmpath - Remove a directory from PATH

if ($#argv != 1) then
    echo "Usage: rmpath <directory>"
    exit 1
endif

set dir_to_remove = "$1"
set newpath = ()

foreach dir ($path)
    if ("$dir" != "$dir_to_remove") then
        set newpath = ($newpath $dir)
    endif
end

set path = ($newpath)
