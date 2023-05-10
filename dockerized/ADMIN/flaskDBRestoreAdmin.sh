#!/bin/bash
#Author: skondla@me.com , Date: 10/21/2019
#Purpose: Admin interface for restoring database from snapshot using flask web framework & dB authentication
CURR_DIR=/app
export FLASK_APP=${CURR_DIR}/__init__.py
export FLASK_ENV=ADMIN
export FLASK_DEBUG=1
/usr/local/bin/flask run -h `hostname -i` -p 30443 --with-threads \
 --cert /app/certs/certificate.pem \
 --key /app/certs/key.pem --debugger > flask_admin.log 

 #--cert /etc/ssl/certs/star_clearleap_com-expires-2021-07.crt \
