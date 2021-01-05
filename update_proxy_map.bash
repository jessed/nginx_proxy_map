#! /bin/bash

proxyDir=/opt/nginx_proxy_map
repo='https://github.com/jessed/nginx_proxy_map.git'
branch='main'

cd $proxyDir

git checkout >/dev/null
git remote update >/dev/null

UPSTREAM=${1:-@{u}}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

if [[ $LOCAL == $REMOTE ]]; then
  echo "Up-to-date"
elif [[ $LOCAL == $BASE ]]; then
  echo "Need to pull ($LOCAL -> $REMOTE)"
  git reset --hard origin/$branch
  git pull branch-name
fi

# See if the proxy_map.conf file has been updated
diff -q proxy_map.conf /etc/nginx/proxy_map.conf

# If it has been updated, backup the current file, move the new one into place
# and reload nginx
if [[ $? != 0 ]]; then
  DATE=$(date +%s)
  sudo mv /etc/nginx/proxy_map.conf-* /etc/nginx/old
  sudo mv -f /etc/nginx/proxy_map.conf /etc/nginx/proxy_map.conf-${DATE}
  sudo cp proxy_map.conf /etc/nginx

  sudo nginx -t 2>/dev/null
  if [[ $? == 0 ]]; then sudo systemctl reload nginx; fi
fi
