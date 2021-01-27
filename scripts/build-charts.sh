#!/usr/bin/env bash

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

CHART_DESTINATION="${1}"
if [[ -z "${CHART_DESTINATION}" ]]; then
    echo "\${CHART_DESTINATION} is empty"
    exit 1
fi
mkdir -p "${CHART_DESTINATION}"

CHART_REPOS="${2}"
if [[ ! -f "${CHART_REPOS}" ]]; then
    echo "\${CHART_REPOS} is not a file"
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

for cR in $(jq -r '.[] | @base64' "${CHART_REPOS}"); do
    _jq() {
     echo "${cR}" | base64 --decode | jq -r "${1}"
    }

    GITHUB_REPOSITORY="$(_jq '.repository')"
    if [[ -z "${GITHUB_REPOSITORY}" ]]; then
        echo "unable to determine '.repository'-key in ${CHART_REPOS}"
        continue
    fi
    GITHUB_URL="https://github.com/${GITHUB_REPOSITORY}.git"

    CHART_PATH="$(_jq '.chartPath')"

    GITHUB_REPOSITORY_TEMP="${TMP_DIR}/${GITHUB_REPOSITORY}/"
    GITHUB_REPOSITORY_TEMP_CHART="${TMP_DIR}/${GITHUB_REPOSITORY}/${CHART_PATH}"

    mkdir -p "${GITHUB_REPOSITORY_TEMP}"
    git clone "${GITHUB_URL}" "${GITHUB_REPOSITORY_TEMP}" &>"${OUTFILE}"
    RET_CODE="${?}"
    if [[ ${RET_CODE} -ne 0 ]]; then
        cat "${OUTFILE}"
        exit ${RET_CODE}
    fi

    rm -rf "${CHART_DESTINATION}/*"

    cp -avL "${GITHUB_REPOSITORY_TEMP_CHART}" "${CHART_DESTINATION}/."
done

exit 0