#! /bin/bash

proxyDir=/opt/nginx_proxy_map
repo='https://github.com/jessed/nginx_proxy_map.git'
branch='main'

cd $proxyDir

git checkout
git remote update

UPSTREAM=${1:-@{u}}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

if [[ $LOCAL == $REMOTE ]]; then
  echo "Up-to-date"
elif [[ $LOCAL == $BASE ]]; then
  echo "Need to pull ($LOCAL -> $REMOTE)"
  echo git reset --hard origin/$branch
  echo git pull branch-name
fi

DATE=$(date +%s)
sudo mv /etc/nginx/proxy_map.conf.* /etc/nginx/old
sudo mv -f /etc/nginx/proxy_map.conf /etc/nginx/old/proxy_map.conf-${DATE}
sudo cp proxy_map.conf /etc/nginx

sudo nginx -t 2>/dev/null
if [[ $? == 0 ]]; then sudo systemctl reload nginx; fi
