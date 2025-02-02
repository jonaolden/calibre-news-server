# Calibre News Server
This server is a news server that automatically pulls Calibre news recipes and publishes them using the calibre server.

## Prerequisites
Execution:
- `docker`

Development:
- `docker`
- `bash`

## Running the server
To run the server, execute `docker compose up`.
This will do a couple of things:
1. Download and install a `calibre` server
2. Initialize a dummy library using a dummy book from `https://www.gutenberg.org/ebooks`
3. Remove the book
4. Create a Cron-Job that downloads the news recipes
5. Add a default user `admin:admin`
6. Expose port `8080`

Afterwards, any recipe stored in `recipes/` (no subdirectories!) will be downloaded periodically and added to the library.

## Configuration
Any configuration, except for the default user, can be done using environment variables.
The most important one is `CRON_TIME`, which uses cron to specify when the news are downloaded.
It is recommended to configure the server using a `.env` file.


This was written by Goose.