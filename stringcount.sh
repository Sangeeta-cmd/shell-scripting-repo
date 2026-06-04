#!/bin/bash

word=mississipi

grep -o 's' <$word | wc -l
