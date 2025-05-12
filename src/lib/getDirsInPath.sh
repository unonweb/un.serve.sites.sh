function getDirsInPath() { # result ${path}
    local -n result=${1}
    local path=${2}
    local dirs=()
    local feedback=true
    local funcName=${FUNCNAME[0]}

    if [[ ${feedback} == true ]]; then
        echo "--- ${funcName}()"
    fi

    mapfile dirs < <(find ${path} -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)

    if [[ ${#dirs[@]} -gt 0 ]]; then
        if [[ ${feedback} == true ]]; then
            echo "${#dirs[@]} directories found"
        fi
        result=("${dirs[@]}")
        return 0
    else
        return 1
    fi
}
