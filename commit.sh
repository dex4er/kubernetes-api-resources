#!/usr/bin/env bash

export DOCKER_CLI_HINTS=false

git branch -D api-resources
git tag -l | xargs -n1 git tag -d
git checkout --orphan api-resources

for v in $(jq -r '.[][1]|select((.|split(".")[1]|tonumber) >= 19)' versions.json); do
  echo "## $v"
  cp -f api-resources-$v.txt api-resources.txt
  git add api-resources.txt
  git commit -m "Changes for Kubernetes v$v" api-resources.txt
  git tag -f v$v
done
