# flaskLoginWebApp
[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/skondla/flaskLoginWebApp/blob/master/LICENSE)

<<<<<<< HEAD
The web interface (HTML) or CURL command can be used to request for
1. Restoring a database instance from cluster and non-cluster database instances
2. Checking the status of the restore from step 1.
3. Attaching an instances to already existing dB cluster
4. The API app is written in Python using Flask Web Frame work and blueprints with API endpoints called routes.

Request website credentials:

1. Provide your email for web site sign up.
2. Sign up is only available to Admins through Admin console.
=======
The web interface (HTML) or CURL command can be used to request for 
1. Restoring a database instance from cluster and non-cluster database instances
2. Checking the status of the restore from step 1.
3. Attaching an instances to already existing dB cluster 
4. The API app is written in Python using Flask Web Frame work and blueprints with API endpoints called routes.

Request website credentials: 

1. Provide your email for web site sign up. 
2. Sign up is only available to Admins through Admin console. 
>>>>>>> 82d4f8b5bddb0575a54fc95a70b675ca31e22aa6
3. Apps with both Admin and User interfaces are running on dB API server(s) in a docker container mapped to different ports.
4. The web site use authentication (currently stored in Postgresql dB) can be used in two forms
5. The web site store user information for each action is performance on the web site. (user email, computer IP (real IP when available))
6. In future the web site will be added with geo location and JWT authentication

Flask Python Curl command: (how to use)
Restore backup:


```
#!/bin/bash
#Author: skondla@me.com
#Purpose: Restore DB from a Snapshot
 
if [ $# -lt 2 ];
then
    echo "Provide snapshotname , db endpoint"
    echo "example: bash getDBRestoreStatus.sh myDB
    myDB.cluster-XXXYYYYDDDD.us-east-1.rds.amazonaws.com"
exit 1
fi
 
snapshotname=${1}
endpoint=${2}
 
 
EMAIL=`cat ~/.password/mySecrets2 | grep email | awk '{print $2}'`
PASSWORD=`cat ~/.password/mySecrets2 | grep password | awk '{print $2}'`
 
 
#/usr/bin/curl -k "https://ec2-54.94.x.x.compute-1.amazonaws.com:50443/login" \
/usr/bin/curl -k "https://192.168.2.15:50443/login" \
    --data-urlencode "email=${EMAIL}" \
    --data-urlencode "password=${PASSWORD}" \
    --cookie "cookies.txt" \
    --cookie-jar "cookies.txt" \
    --verbose \
    > "login_log.html"
 
#/usr/bin/curl -k "https://ec2-54.94.x.x.compute-1.amazonaws.com:50443/restore" \
/usr/bin/curl -k "https://192.168.2.15:50443/restore" \
    --data-urlencode "snapshotname=${snapshotname}" \
    --data-urlencode "endpoint=${endpoint}" \
    --cookie "cookies.txt" \
    --verbose \
    --cookie-jar "cookies.txt"; \
    echo
rm -f cookies.txt
```
Status of Restored backup:
```
#!/bin/bash
#Author: skondla@me.com
#Purpose: Status of Restore

if [ $# -lt 2 ];
then
    echo "Provide snapshotname , db endpoint"
    echo "example: bash getDBRestoreStatus.sh myDB
    myDB.cluster-XXXYYYYDDDD.us-east-1.rds.amazonaws.com"
exit 1
fi

snapshotname=${1}
endpoint=${2}


EMAIL=`cat ~/.password/mySecrets2 | grep email | awk '{print $2}'`
PASSWORD=`cat ~/.password/mySecrets2 | grep password | awk '{print $2}'`


#/usr/bin/curl -k "https://ec2-54.94.x.x.compute-1.amazonaws.com:50443/login" \
/usr/bin/curl -k "https://192.168.2.15:50443/login" \
    --data-urlencode "email=${EMAIL}" \
    --data-urlencode "password=${PASSWORD}" \
    --cookie "cookies.txt" \
    --cookie-jar "cookies.txt" \
    --verbose \
    > "login_log.html"

#/usr/bin/curl -k "https://ec2-54.94.x.x.compute-1.amazonaws.com:50443/status" \
/usr/bin/curl -k "https://192.168.2.15:50443/restore" \
    --data-urlencode "snapshotname=${snapshotname}" \
    --data-urlencode "endpoint=${endpoint}" \
    --cookie "cookies.txt" \
    --verbose \
    --cookie-jar "cookies.txt"; \
    echo
rm -f cookies.txt
```
Attach DB instance to the cluster:

```
#!/bin/bash
#Author: skondla@me.com
#Purpose: Attach dB instance to dB cluster
 
if [ $# -lt 2 ];
then
    echo "Provide db endpoint , instanceclass"
    echo "example: bash getDBRestoreStatus.sh
          myDB.cluster-XXXYYYYDDDD.us-east-1.rds.amazonaws.com
          db.t2.small"
exit 1
fi
 
 
endpoint=${1}
instanceclass=${2}
 
 
EMAIL=`cat ~/.password/mySecrets2 | grep email | awk '{print $2}'`
PASSWORD=`cat ~/.password/mySecrets2 | grep password | awk '{print $2}'`
 
#/usr/bin/curl -k "https://ec2-54.94.x.x.compute-1.amazonaws.com:50443/login" \
/usr/bin/curl -k "https://192.168.2.15:50443/login" \
    --data-urlencode "email=${EMAIL}" \
    --data-urlencode "password=${PASSWORD}" \
    --cookie "cookies.txt" \
    --cookie-jar "cookies.txt" \
    --verbose \
    > "login_log.html"
 
#/usr/bin/curl -k "https://ec2-54.94.x.x.compute-1.amazonaws.com:50443/attachdb" \
/usr/bin/curl -k "https://192.168.2.15:50443/attachdb" \
    --data-urlencode "endpoint=${endpoint}" \
    --data-urlencode "instanceclass=${instanceclass}" \
    --cookie "cookies.txt" \
    --verbose \
    --cookie-jar "cookies.txt"; \
    echo
 
rm -f cookies.txt
```
Python Flask Web Interface:

![alt image](https://github.com/skondla/flaskAPIWebApp/tree/main/images/screen1.png)

![alt text](https://github.com/skondla/flaskAPIWebApp/tree/main/images/screen2.png)

![alt text](https://github.com/skondla/flaskAPIWebApp/tree/main/images/screen3.png)

![alt text](https://github.com/skondla/flaskAPIWebApp/tree/main/images/screen4.png)

![alt text](https://github.com/skondla/flaskAPIWebApp/tree/main/images/screen5.png)
