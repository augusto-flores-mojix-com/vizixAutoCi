#!/bin/bash
#
#  Rancher Updater
#  @Author : Bruno.Flores@mojix.com
#
set -e
usage() {
  cat <<USAGE >&2
usage: $0 [options]
Vizix Rancher  Version Updater.
OPTIONS:
  REQUIRED:
  -u,   --username USER              Account API Access Key (e.g. 64B06...).
  -p,   --password PASS              Account API Secret Key (e.g. ADypmL1Q...).
  -a,   --api URL                    Rancher API URL (e.g. https://rancho.test/v1/).
  -v,   --version VERSION            Update all services version (e.g. v6.18.0).

  OPTIONAL:
  -sv,  --services-version VERSION   Update services container version (e.g. v6.18.0).
  -bv,  --bridges-version VERSION    Update bridges container version (e.g. v6.18.0).
  -uv,  --ui-version VERSION         Update ui container version (e.g. v6.18.0).
  -h,   --help                       Shows this message.

USAGE
}

main(){
  # Preliminar Setup
  check_installed "python"

  # variables
  local version=""
  local username=""
  local password=""
  local api=""
  local sversion=""
  local uversion=""
  local bversion=""

  while true; do
  case "$1" in
    -v | --version)
      if [[ -z "$2" ]]; then
        fail "--version requires an argument"
      fi
      version="$2"
      shift 2
      ;;
    -u | --username)
      if [[ -z "$2" ]]; then
        fail "--username requires an argument"
      fi
      username="$2"
      shift 2
      ;;
    -p | --password)
      if [[ -z "$2" ]]; then
        fail "--password requires an argument"
      fi
      password="$2"
      shift 2
      ;;
    -a | --api)
      if [[ -z "$2" ]]; then
        fail "--api requires an argument"
      fi
      api="$2"
      shift 2
      ;;
    -sv | --services-version)
      if [[ -z "$2" ]]; then
        fail "--services-version requires an argument"
      fi
      sversion="$2"
      shift 2
      ;;
    -uv | --ui-version)
      if [[ -z "$2" ]]; then
        fail "--ui-version requires an argument"
      fi
      uversion="$2"
      shift 2
      ;;
    -bv | --bridges-version)
      if [[ -z "$2" ]]; then
        fail "--bridges-version requires an argument"
      fi
      bversion="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 1
      ;;
    *)
      break
      ;;
   esac
  done

  if [[ $# -ne 0 ]]; then
    usage
    exit 1
  fi

  echo ' --- Rancher Updater 3000  has started ---'
  DOCKER_BRANCH_SERVICES=${sversion:-version}
  DOCKER_BRANCH_UI=${uversion:-version}
  DOCKER_BRANCH_BRIDGES=${bversion:-version}
  export RANCHER_URL=${api}
  export RANCHER_ACCESS_KEY=${username}
  export RANCHER_SECRET_KEY=${password}
  # Default Variables
  SCRIPT=rancher_services.py
  BASE_SERVICES=docker:mojix/riot-core-services
  BASE_UI=docker:mojix/riot-core-ui
  BASE_BRIDGES=docker:mojix/riot-core-bridges

  info "📝 Retrieving Containers IDs"

  SERVICES=$(getID services)
  UI=$(getID ui)
  #BRIDGES
  HBRIDGE=$(getID httpbridge)
  TBRIDGE=$(getID transformbridge)
  K2M=$(getID k2m)
  M2K=$(getID m2k)
  MINJECTOR=$(getID mongoinjector)
  RPROCESSOR=$(getID rulesprocessor)
  APROCESSOR=$(getID actionprocessor)
  SIDS="$SERVICES $UI $HBRIDGE $TBRIDGE $K2M $M2K $MINJECTOR $RPROCESSOR $APROCESSOR"
  info "IDs: $SIDS"

  info ' UPDATING CONTAINERS ⏳'
  updateContainer $SERVICES $BASE_SERVICES $DOCKER_BRANCH_SERVICES

  updateContainer $UI $BASE_UI $DOCKER_BRANCH_UI

  updateContainer $HBRIDGE $BASE_BRIDGES $DOCKER_BRANCH_BRIDGES
  updateContainer $TBRIDGE $BASE_BRIDGES $DOCKER_BRANCH_BRIDGES
  updateContainer $K2M $BASE_BRIDGES $DOCKER_BRANCH_BRIDGES
  updateContainer $M2K $BASE_BRIDGES $DOCKER_BRANCH_BRIDGES
  updateContainer $MINJECTOR $BASE_BRIDGES $DOCKER_BRANCH_BRIDGES
  updateContainer $RPROCESSOR $BASE_BRIDGES $DOCKER_BRANCH_BRIDGES
  updateContainer $APROCESSOR $BASE_BRIDGES $DOCKER_BRANCH_BRIDGES

  info ' Upgrade Complete ☑️'
}

### HELPER Funtions
getID() {
  python $SCRIPT id_of $1
}
updateContainer(){
  python $SCRIPT upgrade $1 --imageUuid="$2:$3"
}
timestamp() {
  date "+%H:%M:%S.%3N"
}

info() {
  local msg=$1
  echo -e "\e[1;32m[info] $(timestamp) ${msg}\e[0m"
}

warn() {
  local msg=$1
  echo -e "\e[1;33m[warn] $(timestamp) ${msg}\e[0m"
}

fail() {
  local msg=$1
  echo -e "\e[1;31m[err] $(timestamp) ERROR: ${msg}\e[0m"
  exit 1
}

check_installed() {
  local missing=()

  for bin in "$@"; do
    if ! which "${bin}" &>/dev/null; then
      missing+=("${bin}")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    fail "this script requires: ${missing[@]}"
  fi
}

main "$@"
info "End of the script"
exit 0
