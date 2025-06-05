#!/usr/bin/env bash

#set -e # moved below, so we will fail only on retry
echo $0

DATE=${DATE:-$(date +'%Y%m%d%H%M%S')}

RUN_STATUS_DIR=~/.config/lod/finished

mkdir -p $RUN_STATUS_DIR

. ./001-versions.sh
. ./001-helper-functions-library.sh
export DEBIAN_FRONTEND=noninteractive

for script in 0[2-9]-*.sh [1-9][0-9]-*.sh ; do
  echo "########################################"
  echo "DATE: $(date) - $(date +'%Y%m%d%H%M%S')"
  if [[ -s $RUN_STATUS_DIR/${script}.done ]]; then
    echo "I found file: $RUN_STATUS_DIR/${script}.done , so SKIPPING $script"
  else
    if [[ -r /etc/profile.d/profile_proxy.sh ]]; then
      . /etc/profile.d/profile_proxy.sh
    fi
    echo "going to run: $script"
    ./$script > >(tee $RUN_STATUS_DIR/${script}.log ) 2> >(tee $RUN_STATUS_DIR/${script}.error >&2)
    ANS=$?
    if [[ $ANS -ne 0 ]]; then
      echo "sleep 10 & retrying ./$script"
      sleep 10
      set -e # Going to stop if fails again
      ./$script
      echo "see logs and errors in files: $RUN_STATUS_DIR/${script}.log and $RUN_STATUS_DIR/${script}.error"
    fi
    echo $DATE > $RUN_STATUS_DIR/${script}.done
  fi
  echo "#######################################"
done
