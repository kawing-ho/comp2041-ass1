#!/usr/bin/python3
#various if statements with strings / ints
#testing inline comments

#I just realised that string comparison is part of subset 5 and not subset 2 ...

a = 1   #cooooo
b = 2 #cooooo
#print ( a == b )  #boolean expr
#print (a!=b)

name = "John"#cooooo
age = 23#cooooo

var = "test"   #cooooo

#Integer comparisons
if(a == 1) and (b == 2):   #cooooo
	print('a = 1 and b = 2')  #cooooo

if(a != 2) and (b != 1): #cooooo
	print('a != 2 and b != 1') #cooooo

#Integer comparison within variables
if a < b:   print('a < b')   #cooooo
if(a <= b): print('a <= b')    #cooooo
if(a != b): print ('a != b') #cooooo
if b != a : print ('b != a')	#cooooo
if a == b : print ('a == b')		#cooooo
if a != b : print ('a != b')	#cooooo

#String comparisons
if name == "John" and age == 23:		#cooooo
	print("Your name is John, and you're 23 years old")	#cooooo

if name == "John" or name == "Rick":	#cooooo
	print("Your name is either John or Rick")		#cooooo

if name != "Rick" and name != "Dan":		#cooooo
	print("Your name isn't Rick or Dan")		#coo a b name age var

#String comparisons within variables
if name == var: print("name == 'var'") #cooooo
if name != var and name != b or name == a: print("name != 'var'")  #since name contains string but a/b are numerical it does string comparison anyways
if name == var or name != var: print('This evaluates to True')  #cooooo

