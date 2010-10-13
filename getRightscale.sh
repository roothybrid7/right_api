#!/bin/bash
# author: Satoshi Ohki <roothybrid7@gmail.com>

# Declaration of variables
readonly COOKIES_NAME="${HOME}/.rsCookie"
readonly API_VERSION=1.0
readonly API_VERSION_HEADER="X-API-VERSION:${API_VERSION}"
readonly API_BASEURI="https://my.rightscale.com/api/acct"
account_id=
username=
password=
format=

_usage() {
  if [ $# -eq 0 ]; then
    cat <<_END_OF_USAGE
Usage: $0 [options] [functions]

  Options:
    -a <account_id> : Rightscale's Account id(required)
    -h : print this help message and exit
    -u <username> : Rightscale's username(use login)
    -p <password> : user password(optional)
    -f <format_type> : Set response format(xml or js[json])

  Defined funtions:
    login :
      Use basic authentication to get session and store it.

_END_OF_USAGE
  fi

  if [ $# -ne 0 ]; then
    cat <<_END_OF_USAGE
    help :
        print this help message

    login <username> :
      Use basic authentication to get session and store it.

        arguments : <username>
            <username> : Rightscale's username(required)

    account <account_id> :
      Set Rightscale's Account id.

        arguments : <account_id>
          <account_id> : Rightscale's Account id(required)

    format <format_type> :
      Set response format.
        arguments : <format_type>
          <format_type> : Set response format(xml or js[json])

_END_OF_USAGE
  fi

  cat <<_END_OF_USAGE
  Indexes:
    deployments [<filter>] :
        Find a specific deployments based on a filter(<key>=<value>).

        arguments : [<key>=<value>](filter)
            <filter> : Rightscale's parameter(optional)

    servers [<filter>] :
        Find a specific server based on a filter(<key>=<value>).

        arguments : [<key>=<value>](filter)
            <filter> : Rightscale's parameter(optional)

    ec2_ebs_volumes :
        Listed ec2_ebs_volumes

    ec2_security_groups :
        Listed ec2_security_groups

    server_arrays :
        Listed server_arrays

    server_templates :
        Listed server_templates

    s3_buckets :
        Listed s3_buckets

    multi_cloud_images :
        Listed multi_cloud_images

    right_scripts :
        Listed right_scripts

    macros :
        Listed macros

    credentials
        Listed credentials

  Operate function:
    actions <actions> :
        in order to perform actions on the server.

        arguments : <action>=<href>(actions)
            <action> : perform action[ex: start, stop, restart](required)
            <href> : object href [execute actions for object 'servers', 'deployments', etc : see XML Output](required)
_END_OF_USAGE
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

_check_auth() {
  _is_account || {
    _logger $FUNCNAME "Not setting account!! Please type 'account <account_id>'"
    return 1
  }
  [ "$1" = "login" ] && return 0
  _is_cookie || {
    _logger $FUNCNAME "Please login!!"
    return 2
  }
}

login() {
  _check_auth $FUNCNAME || return 1
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

format() {
  if [ -z "$1" ]; then
    _logger $FUNCNAME "NO ARGUMENTS!!"
    return 1
  fi
  _check_auth || return 1
  case $1 in
    "xml" | "js") format=$1;;
    *) return;;
  esac
  format=$1
}

_open_url() {
  _check_auth || return 1

  local url="${API_BASEURI}/${account_id}/${1}"
  [ $# -eq 2 ] && url+="?filter=${2}"
  if [ -n "$format" ]; then
    echo $url | grep '?' && {
      url+="&format=$format"
    } || {
      url+="?format=$format"
    }
  fi
  curl -H $API_VERSION_HEADER -b $COOKIES_NAME $url

  return $?
}

# _INDEXES_
deployments() {
  _open_url $FUNCNAME $*
  return $?
}

servers() {
  _open_url $FUNCNAME $*
  return $?
}

ec2_ebs_volumes() {
  _open_url $FUNCNAME $*
  return $?
}

#ec2_elastic_ips() {
#  if [ $# -eq 0 ]; then
#    _logger $FUNCNAME "NO ARGUMENTS!!"
#    return 1
#  fi
#  _check_auth || return 1
#
#  local params=($(echo $* | awk -F'=' '{printf("%s/%s\n", $2, $1)}'))
#  local data="${FUNCNAME%s}[${params[0]}]=${params[1]}"
#  local url=$(_open_url $FUNCNAME)
#  curl -d api_version=${API_VERSION} -H $API_VERSION_HEADER -b $COOKIES_NAME -d $data $url
#
#  return $?
#}

ec2_security_groups() {
  _open_url $FUNCNAME $*
  return $?
}

#ec2_ssh_keys() {
#  if [ $# -eq 0 ]; then
#    _logger $FUNCNAME "NO ARGUMENTS!!"
#    return 1
#  fi
#  _open_url $FUNCNAME $*
#  return $?
#}

server_arrays() {
  _open_url $FUNCNAME $*
  return $?
}

s3_buckets() {
  _open_url $FUNCNAME $*
  return $?
}

multi_cloud_images() {
  _open_url $FUNCNAME $*
  return $?
}

server_templates() {
  _open_url $FUNCNAME $*
  return $?
}

right_scripts() {
  _open_url $FUNCNAME $*
  return $?
}

macros() {
  _open_url $FUNCNAME $*
  return $?
}

credentials() {
  _open_url $FUNCNAME $*
  return $?
}
# _END_OF_INDEXES_

#show() {
#  if [ $# -eq 0 ]; then
#    _logger $FUNCNAME "NO ARGUMENTS!!"
#    return 1
#  fi
#  _check_auth || return 1
#
#  local url=$1
#  curl -d api_version=${API_VERSION} -H $API_VERSION_HEADER -b $COOKIES_NAME $url
#
#  return $?
#}

#destory() {
#  if [ $# -eq 0 ]; then
#    _logger $FUNCNAME "NO ARGUMENTS!!"
#    return 1
#  fi
#  _check_auth || return 1
#
#  local url=$1
#  curl -d api_version=${API_VERSION} -H $API_VERSION_HEADER -b $COOKIES_NAME $url
#
#  return $?
#}

actions() {
  if [ $# -eq 0 ]; then
    _logger $FUNCNAME "NO ARGUMENTS!!"
    return 1
  fi
  _check_auth || return 1

  local url=$(echo $* | awk -F'=' '{printf("%s/%s\n", $2, $1)}')
  curl -d api_version=${API_VERSION} -H $API_VERSION_HEADER -b $COOKIES_NAME $url

  return $?
}

#settings() {
#  if [ $# -eq 0 ]; then
#    _logger $FUNCNAME "NO ARGUMENTS!!"
#    return 1
#  fi
#  _check_auth || return 1
#
#  local url=$1
#  curl -d api_version=${API_VERSION} -H $API_VERSION_HEADER -b $COOKIES_NAME $url
#
#  return $?
#}

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
  while getopts a:hu:p:f: OPT
  do
    case $OPT in
      "a") account_id="$OPTARG";;
      "h") _usage; exit 0;;
      "u") username="$OPTARG";;
      "p") password="$OPTARG";;
      "f") format="$OPTARG";;
      *) ;;
    esac
  done
  shift $(($OPTIND - 1))

  main $@
else
  main "shell"
fi
