#!/usr/bin/env bash

export DOCKER_CLI_HINTS=false

for v in $(jq -r '.[][1]|select((.|split(".")[1]|tonumber) >= 19)' versions.json); do
  release=${v%.*}
  echo "## $v"
  docker pull --disable-content-trust kindest/node:v$v
  kind create cluster --config <(sed "s,image: kindest/node,&:v$v," config.yaml)
  kubectl version
  kubectl api-resources | awk '{if ($2 ~ /\//) print $1,"-",$2,$3,$4; else print $1,$2,$3,$4,$5}' | LC_ALL=C sort > api-resources-$release.txt
  if [[ -n $previous ]]; then 
    diff -u api-resources-$previous.txt api-resources-$release.txt
  fi
  kind delete cluster
  previous=$release
done
