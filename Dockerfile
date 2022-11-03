FROM --platform=linux/arm64 ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update && apt-get install -y calibre wget cron

RUN mkdir /opt/library
RUN mkdir /opt/recipes

ENV LIBRARY_FOLDER=/opt/library/
ENV EBOOK_EXAMPLE_FOLDER=/opt/example
ENV EBOOK_EXAMPLE=${EBOOK_EXAMPLE_FOLDER}/zarathustra.mobi
ENV RECIPES_FOLDER=/opt/recipes
ENV USER_DB=/opt/users.sqlite

RUN mkdir ${EBOOK_EXAMPLE_FOLDER}
RUN wget https://www.gutenberg.org/ebooks/1998.kf8.images -O ${EBOOK_EXAMPLE}
RUN calibredb add ${EBOOK_EXAMPLE} --with-library ${LIBRARY_FOLDER}

RUN wget https://raw.githubusercontent.com/kovidgoyal/calibre/master/recipes/taggeschau_de.recipe -O ${RECIPES_FOLDER}/tageschau_de.recipe
ENV CRON_TIME="* * 1 * *"
COPY ./download_news.sh /opt/download_news.sh
RUN crontab -l | { cat; echo "${CRON_TIME} bash /opt/download_news.sh"; } | crontab -

COPY ./users.sqlite ${USER_DB}

EXPOSE 8080
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]
