#!/bin/bash

set -ev

source ./scripts/config.sh

## AMD64 binary

OS="linux"
PKG_INSTALL_BIN_DIR="/usr/bin/"
PKG_NAME="$APP"
OUTPUT_DIR="$(pwd)/pkg/$ARCH"

DEB_VERSION="$CARGO_VERSION.b$TRAVIS_BUILD_NUMBER-1git+$GIT_VERSION"
RPM_VERSION="$CARGO_VERSION.b$TRAVIS_BUILD_NUMBER_1git+$GIT_VERSION"

if [ -d "$OUTPUT_DIR" ]
then
  echo "$OUTPUT_DIR found, skip artifacts buildings"
else
  mkdir -p $OUTPUT_DIR

  gem install fpm

  if [ "$ARCH" = "x86_64" ]
  then

    cargo build --release

    ## 64 bits deb package
    ARCH="amd64"
    BUILD_BIN_FILE="$(pwd)/target/release/gdu"

    fpm \
      -s dir \
      -t deb \
      -n $PKG_NAME \
      -p $OUTPUT_DIR \
      -v $DEB_VERSION \
      -a $ARCH \
      --vendor $VENDOR \
      $BUILD_BIN_FILE=$PKG_INSTALL_BIN_DIR

    ## 64 bits rpm package
    ARCH="x86_64"
    BUILD_BIN_FILE="$(pwd)/target/release/gdu"

    fpm \
      -s dir \
      -t rpm \
      -n $PKG_NAME \
      -p $OUTPUT_DIR \
      -v $RPM_VERSION \
      -a $ARCH \
      --vendor $VENDOR \
      $BUILD_BIN_FILE=$PKG_INSTALL_BIN_DIR

  elif [ "$ARCH" = "armv6" ]
  then
    ## ARMv6 binary for Raspbian

    ARCH="armhf"
    BUILD_BIN_FILE="$(pwd)/target/arm-unknown-linux-gnueabihf/release/gdu"

    docker run -it --rm \
      -v $(pwd):/source \
      -v ~/.cargo/git:/root/.cargo/git \
      -v ~/.cargo/registry:/root/.cargo/registry \
      dlecan/rust-crosscompiler-arm:stable \
      cargo build --release

    fpm \
      -s dir \
      -t deb \
      -n $PKG_NAME \
      -p $OUTPUT_DIR \
      -v $DEB_VERSION \
      -a $ARCH \
      --vendor $VENDOR \
      $BUILD_BIN_FILE=$PKG_INSTALL_BIN_DIR

  else
    echo "Unknown architecture!"
  fi
fi

