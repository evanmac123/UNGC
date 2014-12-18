#!/usr/bin/env bash
unset UCF_FORCE_CONFFOLD

export UCF_FORCE_CONFFNEW="YES"
export DEBIAN_FRONTEND="noninteractive"

set -e
set -u

SYSTEM_TIMEZONE="Etc/UTC"
SYSTEM_LOCALE="en_US.UTF-8"

set-locale() {
  export LANGUAGE=$1
  export LANG=$1
  export LC_ALL=$1
  locale-gen $1
  dpkg-reconfigure -f noninteractive locales
  update-locale
}

set-timezone() {
  echo $1 > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
}

prepare-system() {
  ucf --purge /boot/grub/menu.lst

  # Update sources
  sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list
  apt-get -qq -y update

  # Upgrade packages
  apt-get -qq -y install aptitude
  aptitude -q -y -o Dpkg::Options::="--force-confnew" full-upgrade

  set-locale $SYSTEM_LOCALE
  set-timezone $SYSTEM_TIMEZONE
}

install-base-packages() {
  apt-get -qq -y install curl ntp vim-nox less htop build-essential libc6-dev \
    libc6-dev-i386 make libreadline-gplv2-dev openssl libssl-dev zlib1g-dev \
    git-core tree python-software-properties debconf-utils
}

RVM_CHANNEL="stable"
RVM_RUBY_VERSION="2.1.5"

install-rvm() {
  su - vagrant -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3"
  su - vagrant -c "curl -sSL https://get.rvm.io | bash -s $RVM_CHANNEL --autolibs=install-packages --ruby=$RVM_RUBY_VERSION"
  su - vagrant -c "rvm --default use $RVM_RUBY_VERSION"
  su - vagrant -c "gem install bundler pry -N"
}

install-node() {
  curl -sL https://deb.nodesource.com/setup | bash -
  apt-get install -y nodejs
}

install-redis() {
  add-apt-repository ppa:chris-lea/redis-server
  apt-get -qq -y update
  apt-get -qq -y install redis-server
}

install-mysql() {
  apt-get -qq -y install mysql-server mysql-client libmysql++-dev

  # Allow external connections (safe because this is a development VM)
  sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/my.cnf
  mysql -uroot -e 'USE mysql; UPDATE `user` SET `Host`="%" WHERE `User`="root" AND `Host`="localhost"; DELETE FROM `user` WHERE `Host` != "%" AND `User`="root"; FLUSH PRIVILEGES;'
}

install-java() {
  apt-get -qq -y install default-jdk
}

install-sphinx() {
  apt-get -qq -y install sphinxsearch
}

install-pdfminer() {
  apt-get -qq -y install python-pdfminer pdfminer-data
}

install-imagemagick() {
  apt-get -qq -y install imagemagick libmagickwand-dev
}

VAGRANT_DATA_DIR="/vagrant"

install-vagrant-profile() {
  tee -a /home/vagrant/.profile <<EOT
alias pdf2txt.py="pdf2txt"
alias be="bundle exec"
alias r="bin/rails"
alias f="bundle exec foreman"
alias v="cd $VAGRANT_DATA_DIR"
cd $VAGRANT_DATA_DIR
EOT
}

main() {
  prepare-system

  install-base-packages
  install-rvm
  install-java
  install-node
  install-redis
  install-mysql
  install-sphinx
  install-pdfminer
  install-imagemagick
  install-vagrant-profile

  shutdown -r now
}

main
