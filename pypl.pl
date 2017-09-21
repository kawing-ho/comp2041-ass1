#!/usr/bin/perl -w

# COMP2041 assignment 1:  http://www.cse.unsw.edu.au/~cs2041/assignments/pypl
# written by Ka Wing Ho z5087077 18th September 2017

our %variables = ();

#All this work just for adding '$'
sub addDollar {
	my $in = shift(@_);
	
	my @buff = split(" ",$in);   
	foreach $item (@buff) {
		foreach $var (keys %variables) {
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
    } elsif ($line =~ /^(\s*)print\(([\"\']?[^\)\'\"]+[\"\']?)\)/) {
    	  
    	  #var substitution
    	  $printz = addDollar($2);
    	  $space  = $1;
    	  
    	  #doing math in printz (no quotes and contains math operators)
    	  #needs to be upgraded to handle lots more math operations
    	  
    	  if($printz !~ /^[\"\'][^\'\"]*[\'\"]$/ && $printz =~/[\*\+\-\/\%]+/) {
    	  		($v1,$op,$v2) = $printz =~ /(\$\w+)\s*([\*\+\-\/\%]+)\s*(\$\w+)/;
    	  		$v1 =~ s/^\$//g;  $v2 =~ s/^\$//g;
    	  		
    	  		if($op eq "+") {
    	  			$printz = $variables{$v1} + $variables{$v2};
    	  		} elsif ( $op eq "*") {
    	  			$printz = $variables{$v1} * $variables{$v2};
    	  		} elsif ($op eq "-") {   #don't forget exponentiation
    	  			$printz = $variables{$v1} - $variables{$v2};
    	  		} elsif ($op eq "/") {
    	  			$printz = $variables{$v1} / $variables{$v2};
    	  		} elsif ($op eq "%") {
    	  			$printz = $variables{$v1} % $variables{$v2};
    	  		} else { print"# Unknown operator $op\n"; }
    	  }
    	  
        print "$space"."print"." \""."$printz"."\\n\";\n";
        
    #if statements
    } elsif ($line =~ /^(\s*)if\(?([^\:]*)\)?:\s*(.*)/) {
    	 $condition = addDollar($2);
    	 $statement = addDollar($3);
    	 
    	 if($3 eq "") {   #on different line
    	 	print "$1"."if($condition) "."\{\n";
    	 } else {          #on same line
    	 	print "$1"."if($condition) "."\{ \n$1\t"."$statement\; \n$1"."\}\n";
    	 }
    
    #while loop
    } elsif ($line =~ /^(\s*)while\(?([^\:]*)\)?:\s*(.*)/) {
    	 $condition = addDollar($2);
    	 $statement = addDollar($3);
    	 
    	 if($3 eq "") {   #on different line
    	 	print "$1"."while($condition) "."\{\n";
    	 } else {			#on same line
    	 	print "$1"."while($condition) "."\{ \n$1\t"."$statement\; \n$1"."\}\n";
    	 }
    
    
    #variables
    #needs to be upgraded to handle math operations in variables as well
    #needs to be upgraded to handle other variables as well ...
    } elsif ($line =~ /(\s*)([\w]+)\s*=\s*([\w \_\*\/\+\"\'\\-]+)/) {
    	  $t = addDollar($3);
    	  $variables{$2} = $t;  #Hash variable to values
    	  print "$1"."my \$"."$2 = $t;"."\n";
    
    #while loops
    
    #for loops
    	 
    # Lines we can't translate are turned into comments
    } else { print "#$line\n"; }
}
