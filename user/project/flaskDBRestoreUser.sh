#!/bin/bash
#Author: skondla@me.com , Date: 10/21/2019
#Purpose: Admin interface for restoring database from snapshot using flask web framework & dB authentication

CURR_DIR=/data2/api/database/restore/user/project
export FLASK_APP=${CURR_DIR}/__init__.py
export FLASK_ENV=USER
export FLASK_DEBUG=1

/usr/local/bin/flask run -h `hostname -i` -p 50443 --with-threads \
 --cert /Users/skondla/flaskLoginWebApp/admin/project/certs/certificate.pem \
 --key /Users/skondla/flaskLoginWebApp/admin/project/certs/key.pem --debugger > flask_user.log

