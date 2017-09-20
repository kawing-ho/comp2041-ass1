#!/usr/bin/python3
# unconventional (maybe even ugly?) style
import sys; count = 0;
for line in sys.stdin: sys.stdout.write("Line {}: {}".format(count,line)); count = count+1;
print(count, "lines in total >:)");
