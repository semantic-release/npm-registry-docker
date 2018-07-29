#!/bin/bash
#
# Utility functions.

###############################################################################
# Log the begining of a step.
#
# Arguments:
#   message: The message to log.
###############################################################################
function strong_echo() {
  echo ""
  echo "================ $1 ================="
}

###############################################################################
# Log an error and exit.
#
# Arguments:
#   message: The error message to log.
#   exit_code: The code to exit with. Default: 1.
###############################################################################
function error_exit() {
    echo "!!!!!!!!!!!!!!!! $1 !!!!!!!!!!!!!!!!" >&2
    exit "${2:-1}"
}
