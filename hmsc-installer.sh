#!/data/data/com.termux/files/usr/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")
ARCHITECTURE=$(dpkg --print-architecture)
case "$ARCHITECTURE" in
  aarch64|arm64) ARCHITECTURE=aarch64;;
  arm|armel|armhf|armhfp|armv7|armv7l|armv7a|armv8l|armeabi) ARCHITECTURE=arm;;
  386|i386|i686|x86) ARCHITECTURE=i686;;
  amd64|x86_64) ARCHITECTURE=x86_64;;
  *)
    printf "ERROR]: Unknown architecture :- $ARCHITECTURE\n"
    exit 1
    ;;
esac

install(){
  if grep -q 'PHP_INI_SCAN_DIR' $PREFIX/etc/profile; then
    printf "Installation done.\n"
  else
    DEB="hmsc_2.0.0-2_${ARCHITECTURE}.deb"
    URL="https://github.com/EddieKidiw/termux-php-hmsc/releases/download/v1.0.0/${DEB}"
    cd ${TMPDIR}
    curl -sL ${URL} -o ${DEB}
    dpkg -i ${DEB}
    rm ${DEB}
    cd ${SCRIPT_DIR}
    if test -f "$PREFIX/lib/php/hmsc.so"; then
      echo -e "\n#fix php ini scan dir\nexport PHP_INI_SCAN_DIR=$PREFIX/lib/php.d" >> $PREFIX/etc/profile
      #export PHP_INI_SCAN_DIR=$PREFIX/lib/php.d
      source $PREFIX/etc/profile
      printf "Installation hmsc success ...\n"
    else
      printf "Installation hmsc error ...\n"
    fi

  fi

}

uninstall(){
  DPKGL="$(dpkg -l)"
  cat <<< "$DPKGL" > "$TMPDIR/applist.txt"
  if grep -q 'hmsc' $TMPDIR/applist.txt; then
    dpkg -r hmsc
  fi

  printf "Hmsc configuration "
  if grep -q 'PHP_INI_SCAN_DIR' $PREFIX/etc/profile; then
    BSLASH=$(echo "$PREFIX/lib/php.d" | sed "s/\//\\\\\//g")
    sed -i.bak -e 's/#fix\ php\ ini\ scan\ dir//g' -e "s/export\ PHP_INI_SCAN_DIR\=${BSLASH}//g" ${PREFIX}/etc/profile
    printf "removing ...\n"
  else
    printf "none ...\n"
  fi
  printf "Done ...\n"
  rm $TMPDIR/applist.txt
}

if [ "$1" = "install" ];then
  install
elif [ "$1" = "uninstall" ];then
  uninstall
elif [ "$1" = "" ];then
  printf "1. install hmsc\n"
  printf "2. uninstall hmsc\n"
  printf "Action (1/2) :"
  read opt
  if [ "$opt" = "1" ];then
    install
  elif [ "$opt" = "2" ];then
    uninstall
  else
    printf "Installation aborted.\n"
    exit
  fi
else
  printf "Installation aborted.\n"
fi
