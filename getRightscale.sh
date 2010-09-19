#!/bin/bash
# Copyright (c) 2010 ...
# author: Satoshi OHKI<satoshi@unoh.net>

# Declaration of variables
readonly COOKIES_NAME="${HOME}/.rsCookies"
readonly ACCOUNT_ID=22329
readonly API_VERSION=1.0
readonly API_VERSION_HEADER="X-API-VERSION:${API_VERSION}"
readonly API_BASEURI="https://my.rightscale.com/api/acct/${ACCOUNT_ID}"
readonly FORMAT="js"

usage() {
  echo "Usage: $0 <funcname1[:opt1[=val1],opts2[=val2]] funcname2[:opt1[=val1],opt2[=val2]] ...>"
  echo
  echo "Defined funtions:"

cat <<_END_OF_STRING
    get_cookie:
        Use basic authentication to get the cookie and store it in the cookie jar.

        command: $0 get_cookie:username,[password]
            username: Rightscale's username(required)
            password: user's password (optional)

    servers:
        Find a specific server based on a <param>(<name>=<value>).

        command: $0 servers:[<name>=<value>]
            <param>: Rightscale's parameter(optional)

    actions:
        in order to perform actions on the server.

        command: $0 actions:<action>=<href>
            <action>: perform action[ex: start, stop](required)
            <href>: server's <href> tag[see XML Output: $0 servers ...](required)

    usage:
        print usage
_END_OF_STRING
} 1>&2

_terminate() {
  echo "${1}: $2" 1>&2
  echo 1>&2
  usage
  exit 1
}

_is_cookie() {
  [ ! -e $COOKIES_NAME ] && return 1 || return 0
}

servers() {
  _is_cookie || _terminate $FUNCNAME "##### Cannot read cookie!! execute $0 getcookies... #####"

  local api="${API_BASEURI}/servers"
  [ $# -ne 0 ] && api="${api}?filter=${1}"

  curl -H $API_VERSION_HEADER -b $COOKIES_NAME $api

  return $?
}

actions() {
  [ $# -eq 0 ] && _terminate "##### NO ARGUMENTS!! #####"
  _is_cookie || _terminate $FUNCNAME "##### Cannot read cookie!! execute $0 getcookies... #####"

  local api=$(echo $* | awk -F'=' '{printf("%s/%s\n", $2, $1)}')

  curl -d api_version=${API_VERSION} -H $API_VERSION_HEADER -b $COOKIES_NAME $api

  return $?
}

get_cookie() {
  [ -z "$1" ] && _terminate $FUNCNAME "##### Input Rightscale's username!! #####"

  local api="${API_BASEURI}/login"
  local userpass
  [ -n "$2" ] && userpass=$1:$2 || userpass=$1

  curl -H $API_VERSION_HEADER -c $COOKIES_NAME -u $userpass $api

  return $?
}

main() {
  [ $# -eq 0 ] && _terminate $FUNCNAME "##### NO ARGUMENTS!! #####"

  for f in $@
  do
    _func=$(echo ${f%%:*})
    _opts=($(echo ${f#${_func}} | sed -e 's/://;s/,/ /g'))
    $_func ${_opts[@]}
  done

  return 0
}

# Entry point
main $@
