#!/usr/bin/env bash

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

HELM_BINARY="$(command -v helm)"
if ! "${HELM_BINARY}" version | grep -q 'Version:"v3' ; then
    HELM_BINARY="$(command -v helmv3)"
fi

if [[ ! -x "${HELM_BINARY}" || $(helm &>/dev/null ; echo ${?}) -ne 0 ]]; then
    echo "Helm v3 is required!"
    exit 1
fi

CHART_DESTINATION="${1}"
if [[ -z "${CHART_DESTINATION}" ]]; then
    echo "\${CHART_DESTINATION} is empty"
    exit 1
fi
mkdir -p "${CHART_DESTINATION}"

CHART_REPOS=(${@:2})
if [[ ${#CHART_REPOS[@]} -eq 0 ]]; then
    echo "\${CHART_REPOS} is empty"
    exit 1
fi

TMP_DIR="/tmp/$(date +%s)"
mkdir -p "${TMP_DIR}"

OUTFILE="${TMP_DIR}/out"

function cleanUp() {
    rm -rf "${TMP_DIR}"
    echo "cleaned up directory ${TMP_DIR}"
}

trap cleanUp 0 1 2 3 6 15

for cR in ${CHART_REPOS[@]}; do
    GITHUB_REPOSITORY="$(echo "${cR}" | cut -d ':' -f 1)"
    GITHUB_URL="https://github.com/${GITHUB_REPOSITORY}.git"

    CHART_PATH="$(echo "${cR}" | cut -d ':' -f 2)"

    GITHUB_REPOSITORY_TEMP="${TMP_DIR}/${GITHUB_REPOSITORY}/"
    GITHUB_REPOSITORY_TEMP_CHART="${TMP_DIR}/${GITHUB_REPOSITORY}/${CHART_PATH}"

    mkdir -p "${GITHUB_REPOSITORY_TEMP}"
    git clone "${GITHUB_URL}" "${GITHUB_REPOSITORY_TEMP}" &>${OUTFILE}
    RET_CODE="${?}"
    if [[ ${RET_CODE} -ne 0 ]]; then
        cat "${OUTFILE}"
        exit ${RET_CODE}
    fi

    cp -a "${GITHUB_REPOSITORY_TEMP_CHART}" "${CHART_DESTINATION}/."
done

exit 0