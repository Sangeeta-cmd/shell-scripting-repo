#!/bin/bash

<< Task
deploy django notes app with error handling
Task

clone_code(){
	echo "Cloning the code......"
	git clone https://github.com/LondheShubham153/django-notes-app.git
}

require_packages(){
	echo " Installing the dependancies............."
	sudo yum install docker
        sudo yum install -y  nginx
}

installation(){
	sudo chown $USER ///var/run/docker.sock
	sudo systemctl enable docker
	sudo systemctl enable nginx
	sudo systemctl restart docker
}

code_deploy(){
	docker build -t notes-app .
	docker run -d -p 8000:8000 notes-app:latest
}

echo "********************* DEPLOY START *****************"

if ! clone_code;then
	echo "code directory already exists..."
	cd django-notes-app
fi 
if ! require_packages;then
	echo "Installation Failed"
	exit 1
fi
if ! installation; then
	echo "System Fault"
	exit 1
fi
code_deploy

echo "******************* DEPLOY DONE ********************"
