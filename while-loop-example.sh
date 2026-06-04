#!/bin/bash

for (( n = 0; n <= 10; n++ ))do
	if (( n % 2 == 0)); then
		echo $n
	fi
done

count=1
while (( count <= 10 )); do
 echo $count
 ((count++))
done 
