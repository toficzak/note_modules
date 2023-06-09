#!/bin/bash
# Author: Toficzak
# Desc: create directory structure to keep notes, adds new file per day if it does not exists, sets properly shortcut
# to current day and performs additional operations if requested (these are considered as environment sensitive,
# will not be stored in vcs).
#
# Configurable (thorough envs):
# - NM_DAYS_FOLDER_NAME - name of folder which keeps files per days
# - NM_TEMPLATE_DAY_FILE_NAME - template to be used as a base day
# - NM_NOTE_LINK_NAME - name of the link in home folder
# - NM_ADDITIONAL_SCRIPT_PATH - path to script which should be performed after day note creation
#
# Variables stating with '_' are local and should not be published.

set -e

_REPO_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
_DAYS_FOLDER_NAME="${NM_DAYS_FOLDER_NAME:-days}"
_DAYS_FOLDER_PATH="${_REPO_PATH}/${_DAYS_FOLDER_NAME}"

if [[ ! -d ${_DAYS_FOLDER_PATH} ]]; then
	echo "Creating folder ${_DAYS_FOLDER_NAME} on path ${_DAYS_FOLDER_PATH}'..."
	mkdir -p "${_DAYS_FOLDER_PATH}"
  	echo "Created ✅"
	ls -l | grep -w "${_DAYS_FOLDER_NAME}"
	echo ""
fi

_CURRENT_DATE=$(date)
_CURRENT_DATE_FORMATTED=$(date +%Y%m%d)
_DAY_FILE_PATH="${_DAYS_FOLDER_PATH}/${_CURRENT_DATE_FORMATTED}"
_TEMPLATE_DAY_FILE_NAME="${NM_TEMPLATE_DAY_FILE_NAME:-.template_day}"
_TEMPLATE_DAY_FILE_PATH="${_REPO_PATH}/${_TEMPLATE_DAY_FILE_NAME}"

if [[ ! -f ${_DAY_FILE_PATH} ]]; then
	echo "Creating file for day: ${_CURRENT_DATE}"
	if [[ -f ${_TEMPLATE_DAY_FILE_PATH} ]]; then
		cp "${_TEMPLATE_DAY_FILE_PATH}" "${_DAY_FILE_PATH}"
		# replace date in template
    sed -i "s/today_date/$(date +%d-%m-%Y)/g" "${_DAY_FILE_PATH}"
	else
		touch "${_DAY_FILE_PATH}"
	fi
	echo "Created file: ${_DAY_FILE_PATH} ✅"
fi

_NOTE_LINK_NAME="${NM_NOTE_LINK_NAME:-note}"
_CURRENT_NOTE_LINK="${HOME}/${_NOTE_LINK_NAME}"

_CURRENT_LINK_POINT_TO=$(readlink -f "${_CURRENT_NOTE_LINK}" | xargs basename)

if [[ "${_CURRENT_DATE_FORMATTED}" != "${_CURRENT_LINK_POINT_TO}" ]]; then
  if [[ -f ${_CURRENT_NOTE_LINK} ]]; then
  	rm "${_CURRENT_NOTE_LINK}"
  fi
  echo "Setting link: ${_CURRENT_NOTE_LINK} -> ${_DAY_FILE_PATH}"
  ln -s "${_DAY_FILE_PATH}" "${_CURRENT_NOTE_LINK}"
  echo "Set properly: "
  ls -l "${HOME}" | grep -w "${_NOTE_LINK_NAME}"
  echo ""
fi

_ADDITIONAL_SCRIPT_PATH="${NM_ADDITIONAL_SCRIPT_PATH:-${_REPO_PATH}/additional_commands.sh}"
if [[ -f ${_ADDITIONAL_SCRIPT_PATH} ]]; then
	echo "Performing additional operations from: ${_ADDITIONAL_SCRIPT_PATH}"
	. ${_ADDITIONAL_SCRIPT_PATH}
fi

echo "Done 😺"