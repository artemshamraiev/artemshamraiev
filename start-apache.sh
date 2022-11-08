#/bin/bash

TEXT_MESSAGE="Artem Shamraiev"

function f_os_identify() {
  local ID_LIKE os

  eval "$(cat /etc/os-release | grep ID_LIKE)"

  case "$ID_LIKE" in
    *rhel*)
      echo "rhel"
      ;;
    *debian*)
      echo "debian"
      ;;
    *)
      echo "none"
      ;;
  esac

}

function f_setup_apache_rhel() {
  local apache_daemon_name="httpd"

  dnf -y install ${apache_daemon_name}
  systemctl enable ${apache_daemon_name} --now

  firewall-cmd --permanent --add-service=http
  firewall-cmd --permanent --add-service=https
  firewall-cmd --reload

  echo ${TEXT_MESSAGE} > /var/www/html/index.html

}

function f_setup_apache_debian() {
  local apache_daemon_name="apache2"

  apt-get update
  apt-get -y install ${apache_daemon_name}
  systemctl enable ${apache_daemon_name} --now

  if [ -f /var/www/html/index.html ] && [ -n /var/www/html/index.bak ]; then
    mv /var/www/html/index.html /var/www/html/index.bak
  fi
  echo ${TEXT_MESSAGE} > /var/www/html/index.html

}


os=$(f_os_identify)
if [ "${os}" != "none" ]; then
  eval f_setup_apache_${os}
else
  echo "Err: OS not identified"
  exit 1
fi

exit $?
