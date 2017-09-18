#!/usr/bin/python3
# python that has uncinventional style
# Also the use of "#" character in function calls to mimic comments

import sys
count = 0
for line in sys.stdin: sys.stdout.write("Line #{}: {}".format(count,line)); count = count+1;

print(count, "lines in total :)")

