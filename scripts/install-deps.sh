#!/bin/bash
#
# Install dependencies.

dir="${BASH_SOURCE%/*}"
if [[ ! -d $dir ]]; then dir=$PWD; fi
#shellcheck source=scripts/utils.sh
. "${dir}/utils.sh"

###############################################################################
# Main script section.
###############################################################################

set -e

strong_echo "Install Node.js"
curl -sL https://deb.nodesource.com/setup_10.x | bash
apt-get install nodejs -yq

strong_echo "Install dnsutils"
apt-get install dnsutils -yq
