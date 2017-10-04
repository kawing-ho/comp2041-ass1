#!/usr/bin/python3
#math and bitwise operators 

#!/usr/bin/python3

a = 1
b = 2
c = 3

print("Next value should be 2")
print( a + 1)
print("Next value should be 0")
print (a + 1 - 2)
print("Next value should be 1")
print( b - a )
print("Next value should be 2")
print( b * a )
print("Next value should be 3")
print( c ** 1)
print("Next value should be 3")
print ( c **a )
print("Next value should be 1")
print( b / 2)
print("Next value should be 1")
print( b / b )
print("Next value should be 6")
print(a + b + c)
print("Next value should be 6")
print(a * b * c) 
print("Next value should be 9")
print( (a+b) * c)#top () ) ( ) (kek
print("Next value should be 5")
print( ((b+a) / c) + (c+b-a))    #ayyy top kek
print("Next value should be 1")
print( b // 2 )
print("Next value should be 1")
print( (a+b+1) % c)
print("Next value should be 1")
print( (a+b+1) % 3)
print("Next value should be 0")
print( (a*4) % b)

print("\nBitwise\n")
# - bitwise operators: | ^ & << >> ~

a =  1000
b = 10000
c = a & b
d = 23
e = 32
f = d | e
g = a ^ b
h = (f ^ d) | e & (f ^ g)
#h = f ^ d | e & f ^ g  #different precedence maybe !

print(c)
print(f)
print(g)
print(h)
