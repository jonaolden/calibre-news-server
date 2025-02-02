#!/bin/bash

# Define paths
LOG_FILE=/opt/record.sqlite

# Ensure the SQLite database exists with a 'records' table
sqlite3 $LOG_FILE "CREATE TABLE IF NOT EXISTS records (id INTEGER PRIMARY KEY, news_outlet TEXT, article_name TEXT, file_date DATE, file_path TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP);"

for filename in ${RECIPES_FOLDER}/*.recipe; do
    echo "Processing recipe $filename"

    # Extract articles — replace with the actual method of getting articles from the recipe
    articles=$(your_command_to_fetch_articles --recipe $filename)

    news_outlet="${filename##*/}" # Extract news outlet's name from filename
    news_outlet="${news_outlet%.recipe}"

    # Directory for the news outlet
    outlet_dir="${LIBRARY_FOLDER}/${news_outlet}"
    mkdir -p "$outlet_dir"

    for article in $articles; do
        article_name="unique_article_identifier" # Replace with actual identifier e.g., title or date
        current_date=$(date +%Y-%m-%d)
        epub_path="${outlet_dir}/${news_outlet}-${article_name}-${current_date}.epub"

        # Convert each article separately to EPUB
        echo "Converting article $article to EPUB"
        ebook-convert "$article" "$epub_path" --output-profile=tablet

        # Annotate the EPUB file with a tag
        ebook-meta "$epub_path" --tag "dailynews"

        # Add the EPUB file to the library
        calibredb add "$epub_path" --library-path "$1" --username "admin" --password "admin" --automerge ${DUPLICATE_STRATEGY}

        # Log the record in the SQLite database
        sqlite3 $LOG_FILE "INSERT INTO records (news_outlet, article_name, file_date, file_path) VALUES ('$news_outlet', '$article_name', '$current_date', '$epub_path');"

        # Enforce retention policy based on date - remove older entries if new ones exist for the same date
        sqlite3 $LOG_FILE "DELETE FROM records WHERE news_outlet = '$news_outlet' AND article_name = '$article_name' AND file_date != '$current_date';"
    done
done
