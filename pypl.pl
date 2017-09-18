#!/usr/bin/perl -w

# COMP2041 assignment 1:  http://www.cse.unsw.edu.au/~cs2041/assignments/pypl
# written by Ka Wing Ho z5087077 18th September 2017

while ($line = <>) {
    if ($line =~ /^#!/ && $. == 1) {

        # translate #! line

        print "#!/usr/bin/perl -w\n";

    } elsif ($line =~ /^\s*(#|$)/) {

        # Blank & comment lines can be passed unchanged

        print $line;

    } elsif ($line =~ /^\s*print\("(.*)"\)$/) {

        # Python's print outputs a new-line character by default
        # so we need to add it explicitly to the Perl print statement

        print "print \"$1\\n\";\n";

    } else {

        # Lines we can't translate are turned into comments

        print "#$line\n";
    }
}
