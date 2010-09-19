#!/usr/bin/env python
# coding:utf-8
# Copyright (c) 2010 ...
# author: Satoshi OHKI<satoshi@unoh.net>

import os
import sys
import urllib2
from optparse import OptionParser


# Declaration of variables
COOKIES_NAME = os.path.join(os.getenv('HOME'), ".rsCookies")
#ACCOUNT_ID = 22329
API_VERSION = 1.0
API_VERSION_HEADER = "X-API-VERSION:%(ver)s" % {'ver': API_VERSION}
API_BASEURI = "https://my.rightscale.com/api/acct"
FORMAT = "js"


def _optparse():
    """OptionParserを生成し、パラメータを設定する
    """
    parser = OptionParser()
    parser.add_option("-a", "--account", dest="accountid",
        help="RightScale account id")
    parser.add_option("-u", "--username", dest="username",
        help="Rightscale username")
    parser.add_option("-p", "--password", dest="password",
        help="User's password")
    parser.add_option("-c", "--cookie-jar", dest="cookiejar",
        help="Write cookies to this file after operation")
    parser.add_option("-b", "--cookie", dest="cookie",
        help="Cookie string or file to read cookies from")

    return parser


def _is_cookie():
    if COOKIES_NAME:
        return True
    else:
        return None


#def get_servers(options, filter=None):
#    """インスタンス一覧を取得する
#    """
#    if _is_cookie():
#        sys.stderr.write(
#            "Cannot read cookie!! execute $0 getcookies...")
#        sys.exit(1)
#
#    _api = "%(base)s/%(acct)s/servers" % {'base': API_BASEURI,
#        'acct': options.account}
#    if filter:
#        _api += "?filter=%(fil)s" % {'fil': filter}
#
#    auth_handler = urllib2.AbstractBasicAuthHandler()

#servers() {
#  _iscookies || (usage; exit 1)
#
#  local api="${API_BASEURI}/servers"
#  [ $# -ne 0 ] && api="${api}?filter=${1}"
#
#  curl -H $API_VERSION_HEADER -b $COOKIES_NAME $api
#
#  return $?
#}
#
#actions() {
#  [ $# -eq 0 ] && (usage; exit 1)
#  _iscookies || (usage; exit 1)
#
#  local api=$(echo $* | awk -F'=' '{printf("%s/%s\n", $2, $1)}')
#
#  curl -d api_version=${API_VERSION} -H $API_VERSION_HEADER
#   -b $COOKIES_NAME $api
#
#  return $?
#}
#
#getcookies() {
#  if [ -z "$1" ]; then
#    echo "##### Input Rightscale's username!! #####"
#    usage
#    exit 1
#  fi
#
#  local api="${API_BASEURI}/login"
#  local userpass
#  [ -n "$2" ] && userpass=$1:$2 || userpass=$1
#
#  curl -H $API_VERSION_HEADER -c $COOKIES_NAME -u $userpass $api
#
#  return $?
#}

#for f in $@
#do
#  _func=$(echo ${f%%:*})
#  _opts=($(echo ${f#${_func}} | sed -e 's/://;s/,/ /g'))
#  $_func ${_opts[@]}
#done


def main():
    parser = _optparse()
    (options, args) = parser.parse_args()

if __name__ == "__main__":
    main()
