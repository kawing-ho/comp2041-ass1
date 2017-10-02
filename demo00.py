#!/usr/bin/python3
#various if statements with strings / ints

a = 1
b = 2
#print ( a == b )  #boolean expr
#print (a!=b)

name = "John"
age = 23

var = "test"

#Integer comparisons
if(a == 1) and (b == 2):
   print('a = 1 and b = 2')

if(a != 2) and (b != 1):
   print('a != 2 and b != 1')

#Integer comparison within variables
if a < b:   print('a < b')
if(a <= b): print('a <= b')
if(a != b): print ('a != b')
if b != a : print ('b != a')
if a == b : print ('a == b')
if a != b : print ('a != b')

#String comparisons
if name == "John" and age == 23:
    print("Your name is John, and you're 23 years old")

if name == "John" or name == "Rick":
    print("Your name is either John or Rick")

if name != "Rick" and name != "Dan":
   print("Your name isn't Rick or Dan")

#String comparisons within variables
if name == var: print("name == 'var'")
if name != var and name != b or name == a: print("name != 'var'")  #since name contains string but a/b are numerical it does string comparison anyways
if name == var or name != var: print('This evaluates to True')


#if "j" in name or "J" in name:
#   print("There's a j/J !")

#if "a" not in name:
#   print("There's no a !")



