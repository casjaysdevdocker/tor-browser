#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202210152122-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.pro
# @@License          :  WTFPL
# @@ReadME           :  entrypoint-tor-browser.sh --help
# @@Copyright        :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @@Created          :  Saturday, Oct 15, 2022 21:22 EDT
# @@File             :  entrypoint-tor-browser.sh
# @@Description      :
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  other/docker-entrypoint
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
[ -n "$DEBUG" ] && set -x
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="$(basename "$0" 2>/dev/null)"
VERSION="202210152122-git"
HOME="${USER_HOME:-$HOME}"
USER="${SUDO_USER:-$USER}"
RUN_USER="${SUDO_USER:-$USER}"
SCRIPT_SRC_DIR="${BASH_SOURCE%/*}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__exec_command() {
  local exitCode=0
  local cmd="${*:-bash -l}"
  echo "Executing command: $cmd"
  eval $cmd || exitCode=10
  [ "$exitCode" = 0 ] || exitCode=10
  return ${exitCode:-$?}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__heath_check() {
  local status=0
  local health="Good"
  #__pgrep "bash" || status=$(($status + 1))
  #__curl "http://localhost/server-health" || status=$(($status + 1))
  [ "$status" -eq 0 ] || health="Errors reported see docker logs --follow $CONTAINER_NAME"
  echo "$(uname -s) $(uname -m) is running and the health is: $health"
  return ${status:-$?}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional functions
__pgrep() { ps aux 2>/dev/null | grep -F "$@" | grep -qv 'grep' || return 10; }
__find() { find "$1" -mindepth 1 -type f,d 2>/dev/null | grep '^' || return 10; }
__curl() { curl -q -LSsf -o /dev/null -s -w "200" "$@" 2>/dev/null || return 10; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__certbot() {
  [ -n "$SSL_CERT_BOT" ] && type -P certbot &>/dev/null || { export SSL_CERT_BOT="" return 10; }
  certbot certonly --webroot -w "${WWW_ROOT_DIR:-/data/htdocs/www}" -d $DOMANNAME -d $DOMANNAME \
    --put-all-related-files-into "$SSL_DIR" –key-path "$SSL_KEY" –fullchain-path "$SSL_CERT"
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__heath_check() {
  local status=0 health="Good"
  __pgrep "$SERVICE" || status=$(($status + 1))
  #__curl "http://localhost/server-health" || status=$(($status + 1))
  [ "$status" -eq 0 ] || health="Errors reported see docker logs --follow $CONTAINER_NAME"
  echo "$(uname -s) $(uname -m) is running and the health is: $health"
  return ${status:-$?}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define default variables - do not change these - redifine with -e or set under Additional
SERVICE="$CONTAINER_NAME"
LANG="${LANG:-C.UTF-8}"
DOMANNAME="${DOMANNAME:-}"
DISPLAY="${DISPLAY:-:0.0}"
TZ="${TZ:-America/New_York}"
HTTP_PORT="${HTTP_PORT:-80}"
HTTPS_PORT="${HTTPS_PORT:-443}"
SERVICE_PORT="${SERVICE_PORT:-}"
HOSTNAME="${HOSTNAME:-casjaysdev-bin}"
HOSTADMIN="${HOSTADMIN:-root@${DOMANNAME:-$HOSTNAME}}"
SSL_CERT_BOT="${SSL_CERT_BOT:-false}"
SSL_ENABLED="${SSL_ENABLED:-false}"
SSL_DIR="${SSL_DIR:-/config/ssl}"
SSL_CA="${SSL_CA:-$SSL_DIR/ca.crt}"
SSL_KEY="${SSL_KEY:-$SSL_DIR/server.key}"
SSL_CERT="${SSL_CERT:-$SSL_DIR/server.crt}"
SSL_CONTAINER_DIR="${SSL_CONTAINER_DIR:-/etc/ssl/CA}"
WWW_ROOT_DIR="${WWW_ROOT_DIR:-/data/htdocs}"
LOCAL_BIN_DIR="${LOCAL_BIN_DIR:-/usr/local/bin}"
DEFAULT_DATA_DIR="${DEFAULT_CONF_DIR:-/usr/local/share/template-files/data}"
DEFAULT_CONF_DIR="${DEFAULT_CONF_DIR:-/usr/local/share/template-files/config}"
DEFAULT_TEMPLATE_DIR="${DEFAULT_TEMPLATE_DIR:-/usr/local/share/template-files/defaults}"
CONTAINER_IP_ADDRESS="$(ip a | grep 'inet' | grep -v '127.0.0.1' | awk '{print $2}' | sed 's|/*||g')"
export DISPLAY
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ "$(whoami)" = "root" ] && cd "/root" || cd "${HOME:-/tmp}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set timezone
[ -n "${TZ}" ] && echo "${TZ}" | sudo tee "/etc/timezone"
[ -f "/usr/share/zoneinfo/${TZ}" ] && sudo ln -sf "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set hostname
if [ -n "${HOSTNAME}" ]; then
  echo "${HOSTNAME}" | sudo tee "/etc/hostname"
  echo "127.0.0.1 ${HOSTNAME} localhost ${HOSTNAME}.local" | sudo tee "/etc/hosts"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Add domain to hosts file
if [ -n "$DOMANNAME" ]; then
  echo "${HOSTNAME}.${DOMANNAME:-local}" | sudo tee "/etc/hostname"
  echo "127.0.0.1 ${HOSTNAME} localhost ${HOSTNAME}.local" | sudo tee "/etc/hosts"
  echo "${CONTAINER_IP_ADDRESS:-127.0.0.1} ${HOSTNAME}.${DOMANNAME}" | sudo tee -a "/etc/hosts"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional commands
[ -f "/tmp/.Xauthority" ] && ln -sf "/tmp/.Xauthority" "$HOME/.Xauthority"
[ -f "/home/user/.Xauthority" ] && ln -sf "/home/user/.Xauthority" "$HOME/.Xauthority"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
case "$1" in
--help) # Help message
  echo 'Docker container for '$APPNAME''
  echo "Usage: $APPNAME [healthcheck, bash, command]"
  echo "Failed command will have exit code 10"
  echo ""
  exit ${exitCode:-$?}
  ;;

healthcheck) # Docker healthcheck
  __heath_check || exitCode=10
  exit ${exitCode:-$?}
  ;;

*/bin/sh | */bin/bash | bash | shell | sh) # Launch shell
  shift 1
  __exec_command "${@:-/bin/bash}"
  exit ${exitCode:-$?}
  ;;

*) # Execute primary command
    exec tor-browser "$@"
    [ -f "/tmp/init.pid" ] ||{ touch "/tmp/init.pid" && bash -l; }

  ;;
esac
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# end of entrypoint
exit ${exitCode:-$?}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
