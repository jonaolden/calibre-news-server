# Pull image
FROM --platform=linux/arm64 ubuntu:latest

# Set up non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

# Install packages
RUN apt-get update && apt-get install -y calibre wget cron

# Set up environment variables
ENV LIBRARY_FOLDER=/opt/library/
ENV EBOOK_EXAMPLE_FOLDER=/opt/example
ENV RECIPES_FOLDER=/opt/recipes
ENV USER_DB=/opt/users.sqlite
# One of: overwrite, new_record, ignore. See: https://manual.calibre-ebook.com/en/generated/en/calibredb.html
ENV DUPLICATE_STRATEGY=new_record

# Create folders
RUN mkdir ${LIBRARY_FOLDER}
RUN mkdir ${RECIPES_FOLDER}
RUN mkdir ${EBOOK_EXAMPLE_FOLDER}

# Initialize library with a dummy book and remove it
RUN wget https://www.gutenberg.org/ebooks/100.kf8.images -O ${EBOOK_EXAMPLE_FOLDER}/example.mobi
RUN calibredb add ${EBOOK_EXAMPLE_FOLDER}/* --with-library ${LIBRARY_FOLDER}
RUN calibredb remove 1 --with-library ${LIBRARY_FOLDER}

# Initialize Recipes
COPY ./recipes ${RECIPES_FOLDER}

# Define Cronjob
ENV CRON_TIME="0 0 * * *"
COPY ./download_news.sh /opt/download_news.sh
RUN crontab -l | { cat; echo "${CRON_TIME} bash /opt/download_news.sh"; } | crontab -

# Copy basic user
COPY ./users.sqlite ${USER_DB}

# Configure start
EXPOSE 8080
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]
