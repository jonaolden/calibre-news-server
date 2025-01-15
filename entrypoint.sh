#!/bin/bash

# Run the news download script
bash /opt/download_news.sh ${LIBRARY_FOLDER}

# Start the Calibre server with authentication
calibre-server ${LIBRARY_FOLDER} --enable-auth --userdb ${USER_DB}
