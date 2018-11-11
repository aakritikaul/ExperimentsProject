#!/bin/bash

NAME="app"                              #Name of the application (*)
DJANGODIR=/opt/finalproject             # Django project directory (*)
SOCKFILE=/opt/finalproject/run/gunicorn.sock        # we will communicate using this unix socket (*)
USER=ubuntu                                        # the user to run as (*)
GROUP=webdata                                     # the group to run as (*)
NUM_WORKERS=1                                     # how many worker processes should Gunicorn spawn (*)
DJANGO_SETTINGS_MODULE=app.settings             # which settings file should Django use (*)
DJANGO_WSGI_MODULE=app.wsgi                     # WSGI module name (*)

echo "Starting $NAME as `whoami`"

# Activate the virtual environment
cd $DJANGODIR
#source /opt/finalproject/venv/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec /opt/finalproject/venv/bin/gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user $USER \
  --bind=unix:$SOCKFILE

[Unit]
Description=FinalProject gunicorn daemon

[Service]
Type=simple
User=root
ExecStart=/opt/finalproject/gunicorn_start.sh

[Install]
WantedBy=multi-user.target