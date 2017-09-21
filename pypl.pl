#!/usr/bin/perl -w

# COMP2041 assignment 1:  http://www.cse.unsw.edu.au/~cs2041/assignments/pypl
# written by Ka Wing Ho z5087077 18th September 2017

our @variables = ();

#All this work just for adding '$'
sub addDollar {
	my $in = shift(@_);
	
	my @buff = split(" ",$in);   
	foreach $item (@buff) {
		foreach $var (@variables) {
			next if $item =~ /^\$.*/;
			$item =~ s/$var/\$$var/g;
		}
	}
	return join(" ",@buff);
}


while ($line = <>) {

	 # translate #! line
    if ($line =~ /^#!/ && $. == 1) { print "#!/usr/bin/perl -w\n";
	
	 # Blank & comment lines can be passed unchanged
    } elsif ($line =~ /^\s*(#|$)/) { print $line;

	 # print(...) statements
    } elsif ($line =~ /(\s*)print\(([\"\']?[^\)\'\"]+[\"\']?)\)/) {
    	  
    	  #var substitution
    	  $printz = addDollar($2);
    	  $space  = $1;
    	  
    	  #doing math in printz (no quotes and contains math operators)
    	  if($printz !~ /^[\"\'][^\'\"]*[\'\"]$/ && $printz =~/[\*\+\-\/\%]+/) {
#    	  		$operator = $2;
#    	  		print "operator is $operator\n";
#    	  		if($operator eq "+") {
#    	  			$printz = $1 + $3;
#    	  		} elsif ( $operator eq "*") {
#    	  			$printz = $1 * $3;
#    	  		} elsif ($operator eq "-") {   #don't forget exponentiation
#    	  			$printz = $1 - $3;
#    	  		} elsif ($operator eq "/") {
#    	  			$printz = $1 / $3;
#    	  		}
    	  }
    	  
        print "$space"."print"." \""."$printz"."\\n\";\n";
        
    #variables
    } elsif ($line =~ /(\s*)([\w]+)\s*=\s*([\w _*\/\+\"\'\\-]+)/) {
    	  push @variables, $2;  #Add variables to list
    	  $t = addDollar($3);
    	  print "$1"."\$"."$2 = $t;"."\n";
    	  
    #if statements
    } elsif ($line =~ /^\s*print\(([^\)]*)\)$/) { next;
    
    #while loops
    #} elsif (1 eq 1){ next;
    
    #for loops
    #} elsif (0 eq 0){ next;
    
    	  #print "print \$$1\n;"."\n";
    	 
    # Lines we can't translate are turned into comments
    } else { print "#$line\n"; }
}
