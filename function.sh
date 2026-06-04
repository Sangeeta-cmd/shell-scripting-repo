#!/bin/bash

function is_loyal(){

read -p "$1 looking at :" girl
read -p "$1's love %:" love

if [ $girl ==  "$2" ];
then
	echo "$1 is loyal"
elif [ $love -ge 100 ]
then 
       echo "$1's love is loyal"
else 
       echo "$1 is not loyal"
fi       
}

#calling function -  passing arguments
is_loyal Ravi Ramya
