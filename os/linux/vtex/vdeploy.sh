#!/bin/bash

progress_bar() {
  SLEEP_DURATION=${SLEEP_DURATION:=1}
  local duration
  local columns
  local space_available
  local fit_to_screen  
  local space_reserved

  space_reserved=6   # reserved width for the percentage value
  duration=${1}
  columns=$(tput cols)
  space_available=$(( columns-space_reserved ))

  if (( duration < space_available )); then 
  	fit_to_screen=1; 
  else 
    fit_to_screen=$(( duration / space_available )); 
    fit_to_screen=$((fit_to_screen+1)); 
  fi

  already_done() { for ((done=0; done<(elapsed / fit_to_screen) ; done=done+1 )); do printf "▇"; done }
  remaining() { for (( remain=(elapsed/fit_to_screen) ; remain<(duration/fit_to_screen) ; remain=remain+1 )); do printf " "; done }
  percentage() { printf "| %s%%" $(( ((elapsed)*100)/(duration)*100/100 )); }
  clean_line() { printf "\r"; }

  for (( elapsed=1; elapsed<=duration; elapsed=elapsed+1 )); do
      already_done; remaining; percentage
      sleep "$SLEEP_DURATION"
      clean_line
  done
  clean_line
}

parse_vtex_json() {
    TOOLBELT_CFG_FILE="$HOME/.config/configstore/vtex.json"
    cat "$TOOLBELT_CFG_FILE" | grep $1 | sed -n "s/^.*\"$1\": \"\(.*\)\".*$/\1/p"
}

get_vtex_account() {
    parse_vtex_json "account"
}

get_vtex_workspace() {
    parse_vtex_json "workspace"
}

parse_manifest_json() {
  cat manifest.json | grep $1 | sed -n "s/^.*\"$1\": \"\(.*\)\".*$/\1/p"
}

get_release_app_name() {
  parse_manifest_json "name"
}

get_release_app_vendor() {
  parse_manifest_json "vendor"
}

get_release_app_version() {
  parse_manifest_json "version"
}

check_account_credentials() {
  local -n credentials_ref=$1
  read -n1 -p "Do you want deploy ${credentials_ref[app_vendor]}.${credentials_ref[app_name]}@${credentials_ref[app_version]} in ${credentials_ref[account]}@${credentials_ref[workspace]}? [y,n]: " input 
  if [ ${input^^} != "Y" ]; then
    echo
    exit 1
  fi
}

vdeploy() {
  declare -A credentials
  credentials[account]=$(get_vtex_account)
  credentials[workspace]=$(get_vtex_workspace)
  credentials[app_name]=$(get_release_app_name)
  credentials[app_vendor]=$(get_release_app_vendor)
  credentials[app_version]=$(get_release_app_version)

  check_account_credentials credentials

  vtex publish -y
  if [ $? -ne 0 ]; then
    exit 1
  fi

  progress_bar 720
  vtex deploy -y
  if [ $? -eq 0 ]; then
    notify-send "$account: Deploy $release_version realizado" "El deploy se ha realizado satisfactoriamente"
  else
    notify-send "$account: Deploy $release_version fallido" "Algo no ha salido bien, revisa la consola"
  fi

}

vdeploy