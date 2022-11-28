# start from an official image
# FROM python:3.9.6-alpine
FROM python:3.9.6
# This line is to solve Alpine Python Docker Base image problem with gcc, if there is no build problem, this line can be avoided
# RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
 # && pip install cython \
 # && apk del .build-deps

 
# RUN apt-get -qq update && apt-get -qq install libmariadb-dev unixodbc-dev libffi-dev gcc libc-dev g++ libc-dev libxml2
# arbitrary location choice: you can change the directory
RUN mkdir -p /opt/services/project/src
WORKDIR /opt/services/project/src



# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install our dependencies
# We can use pipfile and pipfilelock to lock the specific dependency version of our project alothou we are not doin here
# we use --system flag because we don't need an extra virtualenv
# COPY Pipfile Pipfile.lock /opt/services/project/src/
# RUN pip install pipenv && pipenv install --system

# install psycopg2 dependencies
# RUN apk update \
     #&& apk add postgresql-dev gcc python3-dev musl-dev

# install psycopg2 dependencies
RUN apt-get update \
    && apt-get install -y postgresql-server-dev-all gcc python3-dev musl-dev



RUN pip install --upgrade pip
RUN pip install backports.zoneinfo
COPY ./packaging/requirements.txt .
RUN pip install -r requirements.txt


# copy entrypoint.sh
COPY ./db-entrypoint.sh .
RUN sed -i 's/\r$//g' /opt/services/project/src/db-entrypoint.sh
RUN chmod +x /opt/services/project/src/db-entrypoint.sh

# copy our project code
COPY . /opt/services/project/src
RUN cd packaging && python manage.py collectstatic --no-input -v 2 




# expose the port 8000
EXPOSE 80

# define the default command to run when starting the container
CMD ["gunicorn", "--chdir", "packaging", "--bind", ":80", "packaging.wsgi:application"]

# docker-compose build
# docker-compose up -d
# docker-compose up -d --build

# run db-entrypoint.sh
ENTRYPOINT ["./db-entrypoint.sh"]


# Bring the container down and associated volumes with it (docker-compose down -v)
# default password required for superuser to initialize the postgresdb( We are giving user, db and pwd with POSTGRES prefix.)
# Create postgresql database, user and password
# docker-compose exec db psql --username=django_dev_user --dbname=django_dev_db
# add created postgresql details to development environment (dev.env)
# check container error logs (docker-compose logs -f)
# docker-compose exec web python manage.py migrate --noinput
# docker volume inspect project_packaging_postgres_data
# docker-compose exec db psql --username=django_dev_user --dbname=django_dev_db
# \l , \c django_dev_db ,  \dt, \q
# Check that the volume has been created correctly(docker volume inspect project_packaging_postgres_data)
# docker ps -a check the docker process with id
# docker exec {7c27810f3d85} ls -la /var {id} to list the files in docker
# docker start {project_packaging-db-1} can start the db container with container name
# docker exec -ti container_id python manage.py createsuperuser
# docker run -e POSTGRES_USER=docker -e POSTGRES_PASSWORD=docker -e POSTGRES_DB=docker 
# docker exec -ti <container-id> bash , after this check with ls -al
