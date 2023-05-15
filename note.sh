#!/bin/bash
# Author: Toficzak
# Desc: create directory structure to keep notes, adds new file per day if it does not exists, sets properly shortcut to current day and performs additional operations if requested (these are considered as environment sensitive, will not be stored in vcs)

set -e

_CURRENT_PATH=$(pwd)
_DAYS_FOLDER_NAME="${DAYS_FOLDER_NAME:-days}"
_DAYS_FOLDER_PATH="${_CURRENT_PATH}/${_DAYS_FOLDER_NAME}"

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
_TEMPLATE_DAY_FILE_NAME="${TEMPLATE_DAY_FILE_NAME:-.template_day}"
_TEMPLATE_DAY_FILE_PATH="${_CURRENT_PATH}/${_TEMPLATE_DAY_FILE_NAME}"

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

_NOTE_LINK_NAME="${NOTE_LINK_NAME:-note}"
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

_ADDITIONAL_SCRIPT_PATH="${ADDITIONAL_SCRIPT_PATH:-${_CURRENT_PATH}/additional_commands.sh}"
if [[ -f ${_ADDITIONAL_SCRIPT_PATH} ]]; then
	echo "Performing additional operations from: ${_ADDITIONAL_SCRIPT_PATH}"
	. ${_ADDITIONAL_SCRIPT_PATH}
fi

echo "Done 😺"