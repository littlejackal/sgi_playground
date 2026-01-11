#!/bin/csh -f
# rmlibpath - Remove a directory from LD_LIBRARYN32_PATH

if ($#argv != 1) then
    echo "Usage: rmlibpath <directory>"
    exit 1
endif

set dir_to_remove = "$1"
set newlibpath = ()

# Convert colon-separated string to array
foreach dir (`echo $LD_LIBRARYN32_PATH | sed 's/:/ /g'`)
    if ("$dir" != "$dir_to_remove") then
        set newlibpath = ($newlibpath $dir)
    endif
end

# Convert array back to colon-separated string
if ($#newlibpath > 0) then
    set libpath_string = "$newlibpath[1]"
    set i = 2
    while ($i <= $#newlibpath)
        set libpath_string = "${libpath_string}:$newlibpath[$i]"
        @ i++
    end
    setenv LD_LIBRARYN32_PATH "$libpath_string"
else
    echo "Warning: LD_LIBRARYN32_PATH would be empty"
    setenv LD_LIBRARYN32_PATH ""
endif
