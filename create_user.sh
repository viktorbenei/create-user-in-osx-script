#!/bin/bash

#
# based on: https://gist.github.com/taylor/1380946
#  fork: https://gist.github.com/viktorbenei/9920634
#

# NOTE: GID 20 is staff group -- see more with: dscl . list groups gid
DEFAULT_GID=20
DEFAULT_GROUP=staff
DEFAULT_SHELL=/bin/bash
DEFAULT_HOME_BASE=/Users

_DEBUG_ON=""

me=$(basename $0)

usage() {
  printf "
Usage  
  $me <username>

Note: Probably have to run with sudo
"
  #$me <username> [-home <path>] [-uid <id>] [-gid <id>] [-shell <path>]
}

_create_user() {
  new_user="$1"
  new_home="$2"
  new_shell="$3"
  new_uid="$4"
  new_gid="$5"
  new_name="$6"

  OSX_USER="/Users/$new_user"
  dscl . -create "${OSX_USER}" && \
    dscl . -create "${OSX_USER}" NFSHomeDirectory "$new_home" && \
    dscl . -create "${OSX_USER}" UserShell "$new_shell" && \
    dscl . -create "${OSX_USER}" UniqueID "$new_uid" && \
    dscl . -create "${OSX_USER}" PrimaryGroupID "$new_gid" && \
    ( [ ! -z "$new_name" ] &&  dscl . -create "${OSX_USER}" RealName "$new_name" )
  return $?
}

log()  { printf "$*\n" ; return $? ;  }
fail() { log "\nERROR: $*\n" ; exit 1 ; }

# TODO: accept more options
if [ -z "$1" ] ; then
  usage
  exit 0
fi

new_user="$1"
new_shell=$DEFAULT_SHELL
new_uid=$(($(dscl . -list /Users uid | sort -nk2 | tail -n 1 | awk '{print $2}')+1))
new_gid=${DEFAULT_GID}
new_name="Auto User $RANDOM"
home_base=$DEFAULT_HOME_BASE
new_home="${home_base}/$new_user"
new_group="${DEFAULT_GROUP}"


[ "$_DEBUG_ON" ] && set -x
_create_user "$new_user" "$new_home" "$new_shell" "$new_uid" "$new_gid" "$new_name"
[ "$?" = 0 ] && mkdir -p "$new_home"

if [ "$?" = 0 -a "$new_home" != "/" ] ; then
  chown -R "${new_user}:${new_group}" "${new_home}"
fi

set +x