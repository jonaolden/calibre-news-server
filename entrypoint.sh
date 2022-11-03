#!/bin/bash
bash /opt/download_news.sh ${LIBRARY_FOLDER}
calibre-server ${LIBRARY_FOLDER} --enable-auth --userdb ${USER_DB}
