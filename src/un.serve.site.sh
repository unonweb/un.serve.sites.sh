#!/bin/bash

# DEPS
# ----
# - wds

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE}")"
SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")
SCRIPT_NAME=$(basename -- "$(readlink -f "${BASH_SOURCE}")")

ESC=$(printf "\e")
BOLD="${ESC}[1m"
RESET="${ESC}[0m"
RED="${ESC}[31m"
UNDERLINE="${ESC}[4m"
GREEN="${ESC}[32m"
GREY="${ESC}[38;5;248m"

# IMPORTS
source "${SCRIPT_DIR}/lib/readFileToArray.sh"
source "${SCRIPT_DIR}/lib/getDirsInPath.sh"

declare -A CONFIG=(
  [wdsOptions]="--port 3000 --node-resolve --watch"
  [feedback]=false
)

declare -A FILES=(
  [sitesDirs]="${SCRIPT_DIR}/sites_parent_paths.txt"
)
declare -A PATHS=(
  [sitesParentDir]=""
  [sitePath]=""
  [siteRoot]=""
)
declare -a SITES_PARENTS=()
declare -a SITES=()

function selectSitesParentDir() {
  local -n result=${1}
  local -n sitesParentPaths=${2}
  local sitesParentDir
  local opt
  local funcName=${FUNCNAME[0]}
  local feedback=${CONFIG[feedback]}

  # -- get path containing sites
  if [[ ${feedback} == true ]]; then
    echo "--- ${funcName}()"
  fi

  echo -e "${RESET}${BOLD}Choose parent dir containing websites:${RESET}"
  select opt in "${sitesParentPaths[@]}"; do
    if [[ -n ${opt} ]]; then
      sitesParentDir=${opt}
      break
    fi
  done

  if [ ! -d ${sitesParentDir} ]; then
    echo "Error: path does not exist: ${GREEN}${sitesParentDir}${RESET}"
    return 1
  else
    result=${sitesParentDir}
    return 0
  fi
}

function selectSiteDir() {
  local -n result=${1}
  local -n sites=${2}
  local pathSites=${3}
  local siteDir
  local funcName=${FUNCNAME[0]}
  local feedback=${CONFIG[feedback]}

  if [[ ${feedback} == true ]]; then
    echo "--- ${funcName}()"
  fi

  # return the site path
  echo "Choose a site to serve: "
  for ((i = 0; i < ${#sites[@]}; i++)); do
    echo -ne "${GREEN}$i${RESET}) ${sites[${i}]}"
  done
  read -p ">> " index
  echo ""

  siteDir="${pathSites}/${sites[${index}]}"
  siteDir=${siteDir%"${siteDir##*[![:space:]]}"} # removes trailing whitespaces

  if [ ! -d ${siteDir} ]; then
    echo "Error: path does not exist: ${siteDir}"
    return 1
  else
    result=${siteDir}
    return 0
  fi
}

function selectSiteRoot {

  local -n result=${1}
  local siteDir=${2}
  local subDirs
  local siteRoot
  local funcName=${FUNCNAME[0]}
  local feedback=${CONFIG[feedback]}

  if [[ ${feedback} == true ]]; then
    echo "--- ${funcName}()"
  fi

  getDirsInPath subDirs ${siteDir}

  echo "Choose subpath: "
  for ((i = 0; i < ${#subDirs[@]}; i++)); do
    echo -ne "${GREEN}$i${RESET}) ${subDirs[${i}]}"
  done
  read -p ">> " index
  echo ""

  siteRoot="${siteDir}/${subDirs[${index}]}"
  if [ ! -d ${siteRoot} ]; then
    echo "Error: path does not exist: ${siteRoot}"
    return 1
  else
    result=${siteRoot}
    return 0
  fi
}

function main() {

  # 1. set SITES_PARENTS
  # 2. set SITES_PARENT_DIR
  # 3. set SITES
  # 4. set SITE_PATH
  # 5. set SITE_ROOT_PATH
  readFileToArray SITES_PARENTS "${FILES[sitesDirs]}" && \
  selectSitesParentDir PATHS[sitesParentDir] SITES_PARENTS && \
  getDirsInPath SITES ${PATHS[sitesParentDir]} && \
  selectSiteDir PATHS[sitePath] SITES ${PATHS[sitesParentDir]} && \
  selectSiteRoot PATHS[siteRoot] ${PATHS[sitePath]}

  if [[ ${?} -eq 0 ]]; then
    read -p "Serve ${GREEN}${PATHS[siteRoot]}${RESET}? (yes)"
    echo ""
    if [[ -z ${REPLY} ]]; then
      npx -g wds ${CONFIG[wdsOptions]} --root-dir ${PATHS[siteRoot]}
    fi
  else
    echo "Exit on error"
    exit
  fi

}

main
