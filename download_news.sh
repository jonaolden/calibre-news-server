#!/bin/bash

for filename in ${RECIPES_FOLDER}/*.recipe; do
    echo "Converting recipe $filename to EPUB $filename.epub"
    ebook-convert $filename $filename.epub --output-profile=kindle

    echo "Annotating EPUB $filename.epub with the dailynews\$\$ tag"
    ebook-meta $filename.epub --tag dailynews

    echo "Adding EPUB $filename.epub to the library"
    calibredb add $filename.epub --library-path "http://127.0.0.1:8080" --username "admin" --password "admin" --automerge ${DUPLICATE_STRATEGY}
done
rm ${RECIPES_FOLDER}/*.epub
