#!/bin/bash

#numbers disible by  3, 5 but not by 15

for  i in {1..50}; do
	if (((i % 3 == 0 || i % 5 == 0) && i % 15 != 0 ));
	then
		echo $i
	fi
done
