# Pull image
FROM --platform=linux/arm64 ubuntu:latest

# Set up non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

# Install packages
RUN apt-get update && apt-get install -y calibre wget cron sqlite3

# Set up environment variables
ENV LIBRARY_FOLDER=/opt/library/
ENV RECIPES_FOLDER=/opt/recipes
ENV USER_DB=/opt/users.sqlite
ENV DUPLICATE_STRATEGY=new_record

# Create folders with appropriate permissions
RUN mkdir -p ${LIBRARY_FOLDER} && chmod 777 ${LIBRARY_FOLDER}
RUN mkdir -p ${RECIPES_FOLDER} && chmod 777 ${RECIPES_FOLDER}

# Initialize library with a dummy book and remove it
RUN wget https://www.gutenberg.org/ebooks/100.kf8.images -O /tmp/example.mobi
RUN calibredb add /tmp/example.mobi --with-library ${LIBRARY_FOLDER}
RUN calibredb remove 1 --with-library ${LIBRARY_FOLDER}
RUN rm -f /tmp/example.mobi

# Copy Recipes
COPY ./recipes ${RECIPES_FOLDER}

# Define Cronjob
ENV CRON_TIME="0 0 * * *"
COPY ./download_news.sh /opt/download_news.sh
RUN crontab -l | { cat; echo "${CRON_TIME} bash /opt/download_news.sh 'http://127.0.0.1:8081'"; } | crontab -

# Copy user database
COPY ./users.sqlite ${USER_DB}

# Configure start
EXPOSE 8081
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]
