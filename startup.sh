#!/usr/bin/env bash

CLAMD_CONFIG="/etc/clamav/clamd.conf"
FRESHCLAM_CONFIG="/etc/clamav/freshclam.conf"

configureClamd(){
  echo "Modifying clamd.conf"

  echo "Disabling LocalSocket"
  sed -ri "s|LocalSocket /run/clamav/clamd.sock|#LocalSocket /run/clamav/clamd.sock|g" ${CLAMD_CONFIG}

  echo "Enabling listening on port ${CLAMD_PORT}"
  sed -ri "s|#TCPSocket 3310|TCPSocket ${CLAMD_PORT}|g" ${CLAMD_CONFIG}

  echo "Enabling listening on all interfaces..."
  sed -ri "s|#TCPAddr 127.0.0.1|TCPAddr 0.0.0.0|g" ${CLAMD_CONFIG}

  echo "Switching to foreground"
  sed -ri "s|#Foreground yes|Foreground yes|g" ${CLAMD_CONFIG}
}

configureFreshClam(){
  if [ -n "$MIRRORS" ] ; then
    echo "Using Mirrors: ${MIRRORS}"

    OLD_IFS=$IFS
    IFS=","

    for MIRROR in ${MIRRORS}
    do
      echo "PrivateMirror ${MIRROR}" >> ${FRESHCLAM_CONFIG}
    done

    IFS=${OLD_IFS}
  fi

  if [ -n "$PROXY_HOST" ] ; then
    echo "Using Proxy Host: ${PROXY_HOST}"
    sed -ri "s|#HTTPProxyServer myproxy.com|HTTPProxyServer ${PROXY_HOST}|g" ${FRESHCLAM_CONFIG}
  fi

  if [ -n "$PROXY_PORT" ] ; then
    echo "Using Proxy Port: ${PROXY_PORT}"
    sed -ri "s|#HTTPProxyPort 1234|HTTPProxyPort ${PROXY_PORT}|g" ${FRESHCLAM_CONFIG}
  fi

  if [ -n "$PROXY_USER" ] ; then
    echo "Proxy is using a username..."
    sed -ri "s|#HTTPProxyUsername myusername|HTTPProxyUsername ${PROXY_USER}|g" ${FRESHCLAM_CONFIG}
  fi

  if [ -n "$PROXY_PASS" ] ; then
    echo "Proxy is using a password..."
    sed -ri "s|#HTTPProxyPassword mypass|HTTPProxyPassword ${PROXY_PASS}}|g" ${FRESHCLAM_CONFIG}
  fi
}

runFreshClam(){
  freshclam --quiet
}

startClamAV(){
  clamd --foreground=true
}

enableCron(){
  HOURS=$1
  echo "Freshclam will update every ${HOURS} hours"
  (crontab -l ; echo "0 */${HOURS} * * * /usr/bin/freshclam")| crontab -
}

configureClamd
configureFreshClam
freshclam
enableCron 6
startClamAV
