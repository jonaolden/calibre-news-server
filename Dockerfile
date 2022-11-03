# Pull image
FROM --platform=linux/arm64 ubuntu:latest

# Set up non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

# Install packages
RUN apt-get update && apt-get install -y calibre wget cron

# Create folders
RUN mkdir /opt/library
RUN mkdir /opt/recipes

# Set up environment variables
ENV LIBRARY_FOLDER=/opt/library/
ENV EBOOK_EXAMPLE_FOLDER=/opt/example
ENV EBOOK_EXAMPLE=${EBOOK_EXAMPLE_FOLDER}/zarathustra.mobi
ENV RECIPES_FOLDER=/opt/recipes
ENV USER_DB=/opt/users.sqlite

# Initialize library
RUN mkdir ${EBOOK_EXAMPLE_FOLDER}
RUN wget https://www.gutenberg.org/ebooks/1998.kf8.images -O ${EBOOK_EXAMPLE}
RUN calibredb add ${EBOOK_EXAMPLE} --with-library ${LIBRARY_FOLDER}

# Initialize Recipes
RUN wget https://raw.githubusercontent.com/kovidgoyal/calibre/master/recipes/taggeschau_de.recipe -O ${RECIPES_FOLDER}/tageschau_de.recipe

# Define Cronjob
ENV CRON_TIME="* * 1 * *"
COPY ./download_news.sh /opt/download_news.sh
RUN crontab -l | { cat; echo "${CRON_TIME} bash /opt/download_news.sh"; } | crontab -

# Copy basic user
COPY ./users.sqlite ${USER_DB}

# Configure start
EXPOSE 8080
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]
