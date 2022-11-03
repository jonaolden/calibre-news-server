#!/bin/bash

for filename in ${RECIPES_FOLDER}/*.recipe; do
    echo "Converting recipe $filename to MOBI $filename.mobi"
    ebook-convert $filename $filename.mobi --output-profile=kindle

    echo "Annotating MOBI $filename.mobi with the dailynews\$\$ tag"
    ebook-meta $filename.mobi --tag dailynews

    echo "Adding MOBI $filename.mobi to the library"
    calibredb add $filename.mobi --library-path $1 --username "admin" --password "admin" --automerge ${DUPLICATE_STRATEGY}
done
rm ${RECIPES_FOLDER}/*.epub
