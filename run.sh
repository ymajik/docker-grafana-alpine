#!/usr/bin/dumb-init /bin/bash
set -e

chown grafana: /grafana/conf/defaults.ini

if [ ! -z "${GF_INSTALL_PLUGINS}" ]; then
  OLDIFS=$IFS
  IFS=','
  for plugin in ${GF_INSTALL_PLUGINS}; do
    grafana-cli plugins install "${plugin}"
  done
  IFS=$OLDIFS
fi

exec gosu grafana grafana-server --homepath=/grafana
