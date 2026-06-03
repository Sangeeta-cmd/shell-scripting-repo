#!/bin/bash

<< normal-for-loop 
for (( num = 1; num <= 5; num++ ));
do
	mkdir "demo$num"
done
normal-for-loop

#Passing-Args

for (( num = $2; num <= $3; num++  ))
do 
	mkdir "$1$num"
done
