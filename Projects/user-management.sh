#!/bin/bash

create_user(){
        echo "User will be created"
	
	if ! grep -q "$username" /etc/passwd ; then
	      sudo useradd -m $username
	      echo "User created"
	else 
		echo "User exist in /etc/passwd file.."
		 cat /etc/passwd | grep "$username"

	fi 
}

delete_user(){
        echo "User will be deleted"
	if grep -q "$username" /etc/passwd ; then
              sudo userdel $username
              echo "User Deleted"
        else
                echo "User not exist.."

        fi
}

lock_user(){
        echo "User will be locked"
	if grep -q "$username" /etc/passwd ; then
              sudo usermod -l $username
              echo "User is locked"
        else
                echo "User not exist.."

        fi
}

unlock_user(){
        echo "User will be unlocked"

	if grep -q "$username" /etc/passwd ; then
              sudo usermod -U $username
              echo "User Unlocked"
        else
                echo "User not exist.."

        fi
}

echo " =============== User Management ==============="
echo "1. create user"
echo "2. delete user"
echo "3. lock user"
echo "4. unlock user"

read -p " Enter your choice [1-4] : " choise
read -p "enter username :" username

case $choise in
	1)
		create_user 
		;;
	2)
		delete_user 
		;;
	3) 
		lock_user 
		;;
	4) 
		unlock_user 
		;;
	*)
		echo " Wrong choice please enter valid choice "
		exit 0
		;;
esac
