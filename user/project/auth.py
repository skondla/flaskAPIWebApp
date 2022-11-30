#!/usr/bin/env python
#Author: skondla@me.com
#purpose: Build a simple python WebApp & REST API to call database service requests
# -*- coding: utf-8 -*-
# auth.py

from flask import Blueprint, render_template, redirect, url_for, request, flash
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import login_user, logout_user, login_required
from .models import User
from . import db
from rdsAdmin import RDSDescribe, RDSCreate, RDSDelete, rdsRestore
import json
import requests
import simplejson
import datetime
import functools
from flask import session

#from flask_httpauth import HTTPBasicAuth
#from app import login_manager, flask_bcrypt

auth = Blueprint('auth', __name__)
#auth = HTTPBasicAuth()


#def login_required(view):
#    @functools.wraps(view)
#    def wrapped_view(**kwargs):
#        if g.user is None:
#            return redirect(url_for('auth.login'))
#        return view(**kwargs)
#    return wrapped_view
#@login_manager.user_loader
#def load_user(user_id):
#    return models.User.get(models.User.id == user_id)

@auth.route('/login')
def login():
    return render_template('login.html')

@auth.route('/login', methods=['POST'])
def login_post():
    email = request.form.get('email')
    password = request.form.get('password')
    remember = True if request.form.get('remember') else False

    user = User.query.filter_by(email=email).first()

    # check if user actually exists
    # take the user supplied password, hash it, and compare it to the hashed password in database
    if not user or not check_password_hash(user.password, password): 
        flash('Please check your login details and try again.')
        return redirect(url_for('auth.login')) # if user doesn't exist or password is wrong, reload the page

    # if the above check passes, then we know the user has the right credentials
    login_user(user, remember=remember)
    #return redirect(url_for('main.restoreDB'))
    return redirect(url_for('main.restore'))

@auth.route('/signup')
def signup():
    return render_template('signup.html')

@auth.route('/signup', methods=['POST'])
def signup_post():

    email = request.form.get('email')
    name = request.form.get('name')
    password = request.form.get('password')
    user = User.query.filter_by(email=email).first() # if this returns a user, then the email already exists in database
    if user: # if a user is found, we want to redirect back to signup page so user can try again  
        flash('Email address already exists')
        return redirect(url_for('auth.signup'))
    # create new user with the form data. Hash the password so plaintext version isn't saved.
    new_user = User(email=email, name=name, password=generate_password_hash(password, method='sha256'))
    # add the new user to the database
    db.session.add(new_user)
    db.session.commit()
    return redirect(url_for('auth.login'))

@auth.route('/logout')
@login_required
def logout():
    logout_user()
    session.clear()
    return redirect(url_for('main.index'))

@auth.route('/restore')
@login_required
def restore():
    #logout_user()
    return render_template('restore.html')
    #return render_template('main.index')

#@app.route('/restore/db')
#def backup_create():
#    return render_template('create-backup.html')

#@auth.route('/restore', methods=['GET', 'POST'])
@auth.route('/restore', methods=['GET','POST'])
def restore_post():
    snapshotName = request.form['snapshotname']
    snapshotName = snapshotName.strip()
    endPoint = request.form['endpoint']
    endPoint = endPoint.strip()
    restoreStatus = dbRestore(snapshotName,endPoint)
    dbState = dbStatus(endPoint,snapshotName)
    slackPost(snapshotName,endPoint,dbState, "Restoring")
    #sendEmail(snapshotName,endPoint,snapStatus)
    return "Database: " + str(snapshotName) + " is being restored from " + str(snapshotName) + \
        " DB Restore status: " + str(dbState), 202

def dbStatus(endPoint,newEndPoint):
    #dbInstance = newEndPoint.split('.')[0]
    if 'cluster' in endPoint:
        return RDSDescribe().getDBClusterStatus(newEndPoint)
    else:
        return RDSDescribe().getDBInstanceStatus(newEndPoint)
        
def dbRestore(snapshotName,dBURL):
    if 'cluster' in dBURL:
        getDBInfo = list()
        getDBInfo = RDSDescribe().dbInstanceInfo(dBURL)
        dbSecurityGroup = str(getDBInfo[0])
        dbSubNet = str(getDBInfo[1])
        engine = str(getDBInfo[2])
        database = str(getDBInfo[3])
        engineVersion = str(getDBInfo[4])
        endpoint = dBURL.split('.')[0]
        print (dBURL + ' is a cluster')
        print ('snapshotName: ' + snapshotName)
        print ('getDBInfo: ' + str(getDBInfo))
        #return RDSDescribe().dbInstanceInfo(dBURL)
        return rdsRestore().restore_db_cluster_from_snapshot(
            snapshotName,snapshotName,dbSubNet,dbSecurityGroup,engine,engineVersion)
    else:
        getDBInfo = list()
        getDBInfo = RDSDescribe().dbInstanceInfo(dBURL)
        dbSecurityGroup = str(getDBInfo[0])
        dbSubNet = str(getDBInfo[1])
        engine = str(getDBInfo[2])
        database = str(getDBInfo[3])
        engineVersion = str(getDBInfo[4])
        instanceClass = str(getDBInfo[5])
        print (dBURL + ' is NOT a cluster')
        print ('snapshotName: ' + snapshotName)
        print ('getDBInfo: ' + str(getDBInfo))
        #return RDSDescribe().dbInstanceInfo(dBURL)
        return rdsRestore().restore_db_instance_from_db_snapshot(
            snapshotName,snapshotName,dbSubNet,dbSecurityGroup,engine,instanceClass)

def dbAttach(dBURL,instanceClass):
        instanceName = dBURL.split('.')[0]
        clusterName = instanceName
        #today = datetime.datetime.now().strftime("%Y%m%d-%H%M")
        today = datetime.datetime.now().strftime("%m%d-%H%M")
        instanceName = str(instanceName) + "-" + str(today)
        getDBInfo = list()
        getDBInfo = RDSDescribe().dbInstanceInfo(dBURL)
        dbSecurityGroup = str(getDBInfo[0])
        dbSubNet = str(getDBInfo[1])
        engine = str(getDBInfo[2])
        database = str(getDBInfo[3])
        engineVersion = str(getDBInfo[4])
        endpoint = dBURL.split('.')[0]
        print('instanceName: ' + instanceName)
        print('engine: ' + engine)
        print('engineVersion: ' + engineVersion)
        #print('dbSubNet: ' + dbSubNet)
        #print('dbSecurityGroup: ' + dbSecurityGroup)
        print('instanceClass: ' + instanceClass)
        print('clusterName: ' + clusterName)
        return RDSCreate().create_db_cluster_instance(
            instanceName,clusterName,engine,engineVersion,instanceClass)
        
def slackPost(*args):
    today = datetime.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    webhook_url = 'https://hooks.slack.com/services/XXXX/XXXX/xyyyybbbbssssrm01' 
    slack_data = {"channel": "@yourname", "username": "dbSnapshot", 'text': today + ": " + args[3] + " Database: " + \
            args[0] + " is " + args[2] + \
            " for dB Endpoint: "  + args[1], "icon_emoji": ":man-biking:"}
    region = 'us-east-1'
  
    response = requests.post(
    webhook_url, data=json.dumps(slack_data),
    headers={'Content-Type': 'application/json'}
    )
    if response.status_code != 200:
       raise ValueError(
        'Request to slack returned an error %s, the response is:\n%s'
        % (response.status_code, response.text)
       )    

def sendEmail(*args):
        with open('/data2/api/db/email_distro', 'r') as f:
	        email_distro = f.read()
        os.system("echo dbSnapshot: " + args[0] + " is " + args[2] + \
                 " for dB: "  + args[1] + "|mailx -s 'dB snapshot'" + email_distro)

@auth.route('/status')
@login_required
#@auth.login_required
def status():
    #logout_user()
    #session.clear()
    return render_template('status.html')
    #return render_template('main.index')

@auth.route('/status', methods=['GET','POST'])
#@login_required
def status_post():
    snapshotName = request.form['snapshotname']
    snapshotName = snapshotName.strip()
    endPoint = request.form['endpoint']
    endPoint = endPoint.strip()
    dbState = dbStatus(endPoint,snapshotName)
    slackPost(snapshotName,endPoint,dbState, "Status of")
    #sendEmail(snapshotName,endPoint,snapStatus)
    return "Database: " + str(snapshotName) + " status: " + str(dbState), 202


@auth.route('/attachdb')
@login_required
def attachdb():
    return render_template('attachdb.html')

@auth.route('/attachdb', methods=['GET','POST'])
def attachdb_post():
    endPoint = request.form['endpoint']
    endPoint = endPoint.strip()
    instanceClass = request.form['instanceclass']
    instanceClass = instanceClass.strip()
    attachStatus = dbAttach(endPoint,instanceClass)
    clusterName = endPoint.split('.')[0]
    today = datetime.datetime.now().strftime("%Y%m%d-%H%M")
    instanceName = str(clusterName) + "-" + str(today)
    slackPost(instanceName,clusterName, "being attached","Attaching")
    #sendEmail(snapshotName,endPoint,snapStatus)
    return "Database Instance: " + str(instanceName) + " is being added to cluser: " + str(clusterName), 202
