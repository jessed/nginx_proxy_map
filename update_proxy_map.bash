#! /bin/bash

proxyDir=/opt/nginx_proxy_map
repo='https://github.com/jessed/nginx_proxy_map.git'
branch='main'

cd $proxyDir

git remote update >/dev/null

UPSTREAM=${1:-@{u}}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

if [[ $LOCAL == $REMOTE ]]; then
  echo "Up-to-date"
elif [[ $LOCAL == $BASE ]]; then
  echo "Need to pull ($LOCAL -> $BASE)"
  git reset -q --hard origin/$branch
  git pull -q
fi

# See if the proxy_map.conf file has been updated
diff -q proxy_map.conf /etc/nginx/proxy_map.conf

# If it has been updated, backup the current file, move the new one into place
# and reload nginx
if [[ $? != 0 ]]; then
  DATE=$(date +%s)
  echo "Moving old backup to /etc/nginx/old"
  sudo mv /etc/nginx/proxy_map.conf-* /etc/nginx/old
  echo "Backing up current proxy map (/etc/nginx/proxy_map.conf-${DATE})"
  sudo mv -f /etc/nginx/proxy_map.conf /etc/nginx/proxy_map.conf-${DATE}
  echo "Moving new proxy may into place"
  sudo cp proxy_map.conf /etc/nginx

  echo "Reloading nginx"
  sudo nginx -tq
  if [[ $? == 0 ]]; then sudo systemctl reload nginx; fi
fi
