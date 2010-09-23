#!/bin/bash
# Copyright (c) 2010 ...
# author: Satoshi OHKI<satoshi@unoh.net>

# Declaration of variables
readonly COOKIES_NAME="${HOME}/.rsCookie"
readonly API_VERSION=1.0
readonly API_VERSION_HEADER="X-API-VERSION:${API_VERSION}"
readonly API_BASEURI="https://my.rightscale.com/api/acct"
readonly FORMAT="js"
account_id=
username=
password=

_usage() {
  if [ $# -eq 0 ]; then
    cat <<_END_OF_USAGE
Usage: $0 [options] [functions]

  Options:
    -a <account_id> : Rightscale's Account id(required)
    -h : print this help message and exit
    -u <username> : Rightscale's username
    -p <password> : user password

  Defined funtions:
_END_OF_USAGE
  fi

  if [ $# -ne 0 ]; then
    cat <<_END_OF_USAGE
    account :
      Set Rightscale's Account id.

        arguments : <account_id>
          <account_id> : Rightscale's Account id(required)

_END_OF_USAGE
  fi

cat <<_END_OF_STRING
    login :
        Use basic authentication to get session and store it.

        arguments : <username>,[<password>]
            <username> : Rightscale's username(required)
            <password> : user's password (optional)

    servers :
        Find a specific server based on a filter(<key>=<value>).

        arguments : [<key>=<value>](filter)
            <filter> : Rightscale's parameter(optional)

    actions :
        in order to perform actions on the server.

        arguments : <action>=<href>
            <action> : perform action[ex: start, stop](required)
            <href> : server's <href> tag[execute function 'servers': see XML Output](required)
_END_OF_STRING

  if [ $# -ne 0 ]; then
cat <<_END_OF_STRING

    help :
        print this help message
_END_OF_STRING
  fi
} 1>&2

_help() {
  _usage $FUNCNAME
}

_logger() {
  [ $# -gt 1 ] && echo "${1}: $2" 1>&2
  echo 1>&2
}

_is_cookie() {
  [ ! -e $COOKIES_NAME ] && return 1 || return 0
}

_is_account() {
  [ -z "$account_id" ] && return 1 || return 0
}

account() {
  if [ -z "$1" ]; then
    _logger $FUNCNAME "Not setting account!! Please type 'account <account_id>'"
    return 1
  fi
  account_id="$1"
}

login() {
  _is_account || {
    _logger $FUNCNAME "Not setting account!! Please type 'account <account_id>'"
    return 1
  }
  [ -n "$1" ] && username="$1"
  if [ -z "$username" ]; then
    _logger $FUNCNAME "Input Rightscale's username!!"
    return 1
  fi

  local api="${API_BASEURI}/${account_id}/login"
  local userpass
  [ -n "$password" ] && userpass=$username:$password || userpass=$username

  curl -H $API_VERSION_HEADER -c $COOKIES_NAME -u $userpass $api

  return $?
}

servers() {
  _is_account || {
    _logger $FUNCNAME "Not setting account!! Please type 'account <account_id>'"
    return 1
  }
  _is_cookie || {
    _logger $FUNCNAME "Login expired!! Please login."
    return 1
  }

  local api="${API_BASEURI}/${account_id}/servers"
  [ $# -ne 0 ] && api="${api}?filter=${1}"

  curl -H $API_VERSION_HEADER -b $COOKIES_NAME $api

  return $?
}

actions() {
  if [ $# -eq 0 ]; then
    _logger $FUNCNAME "NO ARGUMENTS!!"
    return 1
  fi
  _is_account || {
    _logger $FUNCNAME "Not setting account!! Please input '<account_id>'"
    return 1
  }
  _is_cookie || {
    _logger $FUNCNAME "Login expired!! Please login."
    return 1
  }

  local api=$(echo $* | awk -F'=' '{printf("%s/%s\n", $2, $1)}')

  curl -d api_version=${API_VERSION} -H $API_VERSION_HEADER -b $COOKIES_NAME $api

  return $?
}

shell() {
  echo "Setting up shell [Press 'q' or 'quit' to exit]" 1>&2
  while :
  do
    local _key=
    echo -n ">> " 1>&2
    read _key
    # press "exit ", "q" or "quit"
    [ "$(echo $_key | sed -e 's/^\(quit\) */\1/g')" == "quit" ] && exit 0
    [ "$(echo $_key | sed -e 's/^\(q\) */\1/g')" == "q" ] && exit 0
    [ "$_key" == "exit" ] && exit 0

    if [ "$_key" == "help" ]; then
      _help
    else
      $_key
    fi
  done
}

main() {
  [ $# -eq 0 ] && exit 1  # No arguments
  [ "$1" == "shell" ] && shell  # run shell

  # execute from command line
  local cnt=0
  local _lines=($@)
  local max_cnt=$#

  while [ $cnt -lt $max_cnt ]
  do
    local _func=${_lines[$cnt]}
    local _args=

    # check next argument
    ((cnt++))
    case "${_lines[$cnt]}" in
      # argument is function?
      "login" | "servers" | "actions") ;;  # keep position
      # argument is not function?
      *)
        _args=${_lines[$cnt]}
        ((cnt++)) # next argument
        ;;
    esac

    $_func $_args || exit 1
  done

  return 0
}

# Entry point
if [ $# -ne 0 ]; then
  # parse options
  while getopts a:hu:p: OPT
  do
    case $OPT in
      "a") account_id="$OPTARG";;
      "h") _usage; exit 0;;
      "u") username="$OPTARG";;
      "p") password="$OPTARG";;
      *) ;;
    esac
  done
  shift $(($OPTIND - 1))

  main $@
else
  main "shell"
fi
