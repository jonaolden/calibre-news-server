#!/bin/bash

export LIBRARY_FOLDER=/opt/library/
export EBOOK_EXAMPLE_FOLDER=/opt/example
export EBOOK_EXAMPLE=${EBOOK_EXAMPLE_FOLDER}/zarathustra.mobi

mkdir ${EBOOK_EXAMPLE_FOLDER}

wget https://www.gutenberg.org/ebooks/1998.kf8.images -O ${EBOOK_EXAMPLE}

calibredb add ${EBOOK_EXAMPLE} --with-library ${LIBRARY_FOLDER}
calibre-server ${LIBRARY_FOLDER}