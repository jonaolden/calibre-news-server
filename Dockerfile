FROM --platform=linux/arm64 ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update && apt-get install -y calibre wget

RUN mkdir /opt/library

ENV LIBRARY_FOLDER=/opt/library/
ENV EBOOK_EXAMPLE_FOLDER=/opt/example
ENV EBOOK_EXAMPLE=${EBOOK_EXAMPLE_FOLDER}/zarathustra.mobi

RUN mkdir ${EBOOK_EXAMPLE_FOLDER}
RUN wget https://www.gutenberg.org/ebooks/1998.kf8.images -O ${EBOOK_EXAMPLE}
RUN calibredb add ${EBOOK_EXAMPLE} --with-library ${LIBRARY_FOLDER}

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]
