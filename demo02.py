#!/usr/bin/python3
# nested if/else statements (harder indentation testing)
# also testing for accidental variable interpolation in strings

true = "True"
false = "False"
zero = 0

if(true == "True"):

	if(false == "False"):
		if(false != "True"):
			if(true != "False"):
				print("True is true and false is false")
	
	if(zero == 0):
		if(zero != 1):
			if(true != zero):
				print("True is still true and zero is 0")
				
	elif(zero == 1): print('This should never print')
	else: print("yolo")

print('Byebye!')
