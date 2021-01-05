#! /bin/bash

proxyDir=/opt/nginx_proxy_map
repo='https://github.com/jessed/nginx_proxy_map.git'
branch='main'

cd $proxyDir
if [[ ! -d .git ]]; then
  git clone https://github.com/jessed/nginx_proxy_map.git .
fi

git checkout -b $branch
git remote update

UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

if [[ $LOCAL == $REMOTE ]]; then
  echo "Up-to-date"
elif [[ $LOCAL == $BASE ]]; then
  echo "Need to pull"
  echo git reset --hard origin/$branch
  echo git pull branch-name
fi

