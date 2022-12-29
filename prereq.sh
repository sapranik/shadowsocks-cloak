MBEDTLS_VER=2.28.0
LIBSODIUM_VER=1.0.18

function printlog() {
  echo -e "$1"
}

function purge() {
   rm -rf /tmp/ssck
}

printlog "Installing packages..."
apt-get -qq -y install --no-install-recommends git nano unzip wget nginx certbot python3-certbot-nginx gettext build-essential autoconf libtool libpcre3-dev asciidoc xmlto libev-dev libc-ares-dev automake libmbedtls-dev libsodium-dev pkg-config > /dev/null
purge
mkdir -p /tmp/ssck

# Installing libsodium
if [ ! -f /usr/lib/libsodium.a ]; then
  printlog "Installing libsodium..."
  wget -q https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz
  tar -C /tmp/ssck/ -xzf libsodium-$LIBSODIUM_VER.tar.gz
  pushd /tmp/ssck/libsodium-$LIBSODIUM_VER &> /dev/null
  ./configure --prefix=/usr &> /dev/null && make &> /dev/null
  make install &> /dev/null
  popd &> /dev/null
  ldconfig
fi

# Installing of MbedTLS
if [ ! -f /usr/lib/libmbedtls.a ]; then
  printlog "Installing MbedTLS..."
  wget -q https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/v$MBEDTLS_VER.tar.gz -O /tmp/ssck/mbedtls.tar.gz
  tar -C /tmp/ssck/ -xzf /tmp/ssck/mbedtls.tar.gz
  pushd /tmp/ssck/mbedtls-$MBEDTLS_VER &> /dev/null
  make SHARED=1 CFLAGS="-O2 -fPIC" &> /dev/null
  make DESTDIR=/usr install &> /dev/null
  popd &> /dev/null
  ldconfig
fi

purge
