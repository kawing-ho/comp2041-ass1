#!/usr/bin/python3
# nested while loops


i = 0  # i should not have a dollar here
j = 0
k = 0
l = 5

print(i + j + k + l)  #this doesn't work yet

i = 5
while (i > 0):
	j = 4
	while (j > 0):
		k = 3
		while (k > 0):
			print("*")
			k = k - 1
		j = j -1
	i = i -1
