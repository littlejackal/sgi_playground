#
# This is the default standard .profile provided to sh users.
# They are expected to edit it to meet their own needs.
#
# The commands in this file are executed when an sh user first
# logs in.
#
# $Revision: 1.1 $
#

if [ -z "$ENVONLY" ]
then
	# Set the interrupt character to Ctrl-c and do clean backspacing.
	if [ -t 0 ]
	then
		stty intr '^C' echoe 
		stty susp '^Z' echoe
	fi

	# Set the TERM environment variable
	eval `tset -s -Q`

	# save tty state in a file where wsh can find it
        if [ ! -f $HOME/.wshttymode -a -t 0 ]
        then
            stty -g > $HOME/.wshttymode
        fi
fi

# Set the default X server.
if [ ${DISPLAY:-setdisplay} = setdisplay ]
then
    if [ ${REMOTEHOST:-islocal} != islocal ]
    then
        DISPLAY=${REMOTEHOST}:0
    else
        DISPLAY=:0
    fi
    export DISPLAY
fi

PS1="\\u@\\h: \\w\\$ "
export PS1
