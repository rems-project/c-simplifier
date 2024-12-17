#!/usr/bin/env bash

# This is a helper script to build and run LLVM docs locally with an indexed
# search feature, which is invaluable for developing on a specific version.

set -euo pipefail

# export PS4="\$LINENO: "
# set -xv

mkdir -p build
cd build
addr=$(ip addr | grep eth0 | tail -n 1 | cut -d' ' -f6 | cut -d'/' -f1)
[ -e Makefile ] || cmake \
    -DLLVM_ENABLE_PROJECTS='clang' \
    -DLLVM_ENABLE_DOXYGEN=ON \
    -DLLVM_DOXYGEN_EXTERNAL_SEARCH=ON \
    -DLLVM_DOXYGEN_SEARCHENGINE_URL="http://${addr}:8000/cgi-bin/doxysearch.cgi" \
    -DDOXYGEN_EXECUTABLE="/usr/local/bin/doxygen" \
    ../llvm
[ -d tools/clang/docs/doxygen ] || make doxygen-clang
cd tools/clang/docs/doxygen
mkdir -p cgi-bin
[ -e cgi-bin/doxysearch.cgi ] || cp $HOME/doxygen-1.9.4/bin/doxysearch.cgi cgi-bin
[ -d doxysearch.db ] || $HOME/doxygen-1.9.4/bin/doxyindexer searchdata.xml
# update URL incase it's changed
sed -i "s~172.*:~${addr}:~g" html/search/search.js
python3 -m http.server --cgi &
echo "http://${addr}:8000/html"
