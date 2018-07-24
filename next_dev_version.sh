#!/bin/bash

set -euxo pipefail

advance_version () {
  local v=$1
  # Get the last number. First remove any suffixes (such as '-SNAPSHOT').
  local cleaned=$(echo $v | sed -e 's/[^0-9][^0-9]*$//')
  local last_num=$(echo $cleaned | sed -e 's/[0-9]*\.//g')
  local next_num=$(($last_num+1))
  # Finally replace the last number in version string with the new one.
  echo $v | sed -e "s/[0-9][0-9]*\([^0-9]*\)$/$next_num/"
}

advance_version_rh () {
  local v=$1
  # Get the last number. First remove any suffixes (such as '-SNAPSHOT').
  local cleaned=$(echo $v | sed -e 's/[^0-9][^0-9]*$//')
  local last_num=$(echo $cleaned | sed -e 's/[0-9]*\.[0-9]*\.[0-9]*-redhat-*//g')
  local next_num=$(($last_num+1))
  # Finally replace the last number in version string with the new one.
  echo $v | sed -e "s/[0-9][0-9]*\([^0-9]*\)$/$next_num/"
}

version=$(../current_version.sh)
cleaned_version=$(echo $version | sed -e 's/[^0-9][^0-9]*$//')

case "$(basename $(pwd))" in
  *-redhat)
    new_version=$(advance_version_rh $version)
    ;;
  *)
    new_version=$(advance_version $version)
    ;;
esac

echo "$cleaned_version -> $new_version"

git clean -fd
snapshot="$new_version-SNAPSHOT"
echo $snapshot
mvn versions:set -DnewVersion=$snapshot

case "$(basename $(pwd))" in
  *-redhat)
    git commit -a -m "Next product development version"
    ;;
  *)
    git commit -a -m "Next community development version"
    ;;
esac
