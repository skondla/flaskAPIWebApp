#!/bin/bash
#Author: skondla@me.com , Date: 10/21/2019
#Purpose: Admin interface for restoring database from snapshot using flask web framework & dB authentication
#fileName: main.py

from flask import Blueprint, render_template
from flask_login import login_required, current_user

main = Blueprint('main', __name__)

@main.route('/')
def index():
    return render_template('index.html')

@main.route('/profile')
@login_required
def profile():
    return render_template('profile.html', name=current_user.name)
