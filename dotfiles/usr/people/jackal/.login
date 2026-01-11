#
# This is the default standard .login provided to csh users.
# They are expected to edit it to meet their own needs.
#
# The commands in this file are executed when a csh user first
# logs in.  This file is processed after .cshrc.
#
# $Revision: 1.1 $
#

if (! $?ENVONLY) then
	# Set the interrupt character to Ctrl-c and do clean backspacing.
	if (-t 0) then
	    stty intr '^C' echoe 
	endif

	# Set the TERM environment variable
	eval `tset -s -Q`
endif

# Set the default X server.
if ($?DISPLAY == 0) then
    if ($?REMOTEHOST) then
        setenv DISPLAY ${REMOTEHOST}:0
    else
        setenv DISPLAY :0
    endif
endif

# git-isms
setenv SSH_AUTH_SOCK ~/.ssh/ssh-agent.`hostname`.sock
ssh-add -l >& /dev/null
if ( $status >= 2 ) then
  rm -f "$SSH_AUTH_SOCK" && ssh-agent -a "$SSH_AUTH_SOCK" >& /dev/null
endif
ssh-add ~/.ssh/id_jackal_coyote >& /dev/null
