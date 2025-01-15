#!/bin/bash

# Ensure the recipes folder exists
if [ ! -d "${RECIPES_FOLDER}" ]; then
  echo "Error: Recipes folder does not exist: ${RECIPES_FOLDER}"
  exit 1
fi

for filename in ${RECIPES_FOLDER}/*.recipe; do
    echo "Converting recipe $filename to MOBI $filename.mobi"
    ebook-convert $filename $filename.mobi --output-profile=kindle

    echo "Annotating MOBI $filename.mobi with the dailynews\$\$ tag"
    ebook-meta $filename.mobi --tag dailynews

    echo "Adding MOBI $filename.mobi to the library"
    calibredb add $filename.mobi --library-path $1 --username "${CALIBRE_USER:-admin}" --password "${CALIBRE_PASS:-admin}" --automerge ${DUPLICATE_STRATEGY:-new_record}
done

# Cleanup any .epub files left over
rm ${RECIPES_FOLDER}/*.epub
