#!/bin/bash

# Define paths
LOG_FILE=/opt/record.sqlite

# Ensure the SQLite database exists with a 'records' table
sqlite3 $LOG_FILE "CREATE TABLE IF NOT EXISTS records (id INTEGER PRIMARY KEY, file_path TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP);"

for filename in ${RECIPES_FOLDER}/*.recipe; do
    echo "Processing recipe $filename"

    # Convert recipe to EPUB format only
    ebook-convert $filename $filename.epub --output-profile=tablet

    # Annotate the EPUB file with a tag
    ebook-meta $filename.epub --tag dailynews

    # Add the EPUB file to the library
    calibredb add $filename.epub --library-path $1 --username "admin" --password "admin" --automerge ${DUPLICATE_STRATEGY}

    # Log the record in the SQLite database
    sqlite3 $LOG_FILE "INSERT INTO records (file_path) VALUES ('$filename.epub');"

    # Enforce retention policy: Keep only the latest 50 entries
    MAX_ENTRIES=50
    sqlite3 $LOG_FILE "DELETE FROM records WHERE id NOT IN (SELECT id FROM records ORDER BY timestamp DESC LIMIT $MAX_ENTRIES);"
done

# Clean up old files no longer in the database
for old_file in $(sqlite3 $LOG_FILE "SELECT file_path FROM records WHERE id NOT IN (SELECT id FROM records ORDER BY timestamp DESC LIMIT $MAX_ENTRIES);"); do
    echo "Removing old file: $old_file"
    rm -f $old_file
done
