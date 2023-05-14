#!/bin/bash
# Author: Toficzak
# Desc: create directory structure to keep notes, adds new file per day if it does not exists, sets properly shortcut to current day and performs additional operations if requested (these are considered as environment sensitive, will not be stored in vcs)

set -e

_CURRENT_PATH=$(pwd)
_DAYS_FOLDER_NAME=${DAYS_FOLDER_NAME} # default
if [[ -z ${DAYS_FOLDER_NAME} ]]; then
	_DAYS_FOLDER_NAME=days
fi

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
_TEMPLATE_DAY_FILE_NAME=${TEMPLATE_DAY_FILE_NAME}

if [[ -z ${TEMPLATE_DAY_FILE_NAME} ]]; then
	_TEMPLATE_DAY_FILE_NAME=".template_day"
fi

_TEMPLATE_DAY_FILE_PATH="${_CURRENT_PATH}/${_TEMPLATE_DAY_FILE_NAME}"

if [[ ! -f ${_DAY_FILE_PATH} ]]; then
	echo "Creating file for day: ${_CURRENT_DATE}"
	if [[ -f ${_TEMPLATE_DAY_FILE_PATH} ]]; then
		cp "${_TEMPLATE_DAY_FILE_PATH}" "${_DAY_FILE_PATH}"
	else
		touch "${_DAY_FILE_PATH}"
	fi
	echo "Created file: ${_DAY_FILE_PATH} ✅"
fi

_NOTE_LINK_NAME=${NOTE_LINK_NAME}
if [[ -z ${NOTE_LINK_NAME} ]]; then
	_NOTE_LINK_NAME="note"
fi

_CURRENT_NOTE_LINK="${HOME}/${_NOTE_LINK_NAME}"

if [[ -f ${_CURRENT_NOTE_LINK} ]]; then
	rm "${_CURRENT_NOTE_LINK}"
fi

echo "Setting link: ${_CURRENT_NOTE_LINK} -> ${_DAY_FILE_PATH}"
ln -s "${_DAY_FILE_PATH}" "${_CURRENT_NOTE_LINK}"
echo "Set properly: "
ls -l "${HOME}" | grep -w "${_NOTE_LINK_NAME}"
echo ""

_ADDITIONAL_SCRIPT_PATH=${ADDITIONAL_SCRIPT_PATH}
if [[ -z ${ADDITIONAL_SCRIPT_PATH} ]]; then
	_ADDITIONAL_SCRIPT_PATH="${_CURRENT_PATH}/additional_commands.sh"
fi

if [[ -f ${_ADDITIONAL_SCRIPT_PATH} ]]; then
	echo "Performing additional operations from: ${_ADDITIONAL_SCRIPT_PATH}"
	. ${_ADDITIONAL_SCRIPT_PATH}
fi
