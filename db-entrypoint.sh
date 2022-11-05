#!/bin/sh

if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres database server..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
      #sleep 0.5
      sleep 5
    done

    echo "PostgreSQL Database Server started"
fi


 #If we want to comment out the database flush and migrate commands in the entrypoint.sh script so they do not run on every container start or re-start:
python packaging/manage.py flush --no-input
python packaging/manage.py migrate




exec "$@"