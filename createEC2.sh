#!/bin/bash

#==============================================
# Author : Sangeeta
# Date : 14/06/2026
# This script will create EC2-instance
# ============================================

check_cli(){
	if ! command -v awscli > /dev/null ; then
		echo "AWS CLI is not installed. Please install" >&2
		return 1
	fi
}

install_cli(){
	echo "Installing AWS CLI "
        if ! aws --version > /dev/null ; then
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                ./aws/install
	 fi

	#verify 
        aws --version

	# cleanup
        rm -rf awscliv2.zip ./aws

	echo " AWS CLI is installed successfully "
}

create_EC2(){
	local image_id=$1
	local instance_type=$2
	local key_name=$3
	local security_group=$4
	local subnet_id=$5
	local instance_name=$6

	instance_id=$( aws ec2 run-instances \
	--image-id $image_id \
	--instance-type $instance_type \
	--key-name $key_name \
	--security-group-ids $security_group \
	--subnet-id $subnet_id \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
        --query "Instances[0].InstanceId" \
	--output text	
        )
        
	if [ -z $instance_id ]; then
             echo "Failed to create EC2 instance"
	     exit
	fi
	
	echo "EC2 instance is created with the id : $instance_id "

	wait_till_run $instance_id
}

wait_till_run(){

        local instance_id=$1

	while true; do
		state=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].State.Name' --output text )
         	if [[ "$state" == "running" ]]; then
	        	echo " EC2 instance $instance_id is in $state state"
			break;
		fi
	sleep 5
	echo $state
        done

}
 
main(){
	if ! check_cli ; then
		install_cli || exit
	fi
        
        echo "Creating EC2 instance...."
	amiid="ami-023b6eace47afd3b4"
	instancetype="t3.nano"
        keyname="aws-login"
	securitygroup="sg-08b2f85616a962878"
	subnetid="subnet-096a3ef139a451f0c"
        instance_name="AWS-Shell-demo"

	# Passing arguments to create_EC2 function
	create_EC2 $amiid $instancetype $keyname $securitygroup $subnetid $instance_name


        echo "EC2 Instance Created Successfully"
}

main



