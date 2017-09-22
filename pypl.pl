#!/usr/bin/perl -w

# COMP2041 assignment 1:  http://www.cse.unsw.edu.au/~cs2041/assignments/pypl
# written by Ka Wing Ho z5087077 18th September 2017

our %variables = ();
our $closingExpected = 0;

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

#Look for print statements in a string and FORMAT them !
sub formatPrint {
	my $in = shift(@_);
	$in =~ /print\((.*)\)/ or die;
	if($1 ne "") {
		my $t = $1;
		$in =~ s/print\(.*\);/print\"$t\\n\";/g;
	}
	
   return $in;
}

#adds extra brackets if number of brackets in a line are mismatched
sub checkBrace {
	my $in = shift(@_);
	my $openCount = 0;
	my $closeCount = 0;
	
	foreach $char (split "",$in) {
		$openCount++ if ($char eq "(");
		
		$closeCount++ if ($char eq ")");
	}
	
	if($openCount != $closeCount) {
		while ($openCount < $closeCount) {
			$in = "(".$in;
			$openCount++;
		}
		
		while ($closeCount < $openCount) {
			$in = $in.")";
			$closeCount++;
		}
	}
	
	return $in;
}


while ($line = <>) {

	 # translate #! line
    if ($line =~ /^#!/ && $. == 1) { print "#!/usr/bin/perl -w\n";
	
	 # Blank & comment lines can be passed unchanged
	 # if a blank line is read in and a closing brace expected add one
    } elsif ($line =~ /^\s*(#|$)/) {
    	if($line =~ /$/ && $closingExpected > 0) {
    	  print "}\n";
    	  $closingExpected--;
    	} else { print $line; }

	 # print(...) statements
    } elsif ($line =~ /^(\s*)print\s*\(([\"\']?[^\)\'\"]+[\"\']?)\)/) {
    	  
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
    	  		} elsif ($op eq "*") {
    	  			$printz = $variables{$v1} * $variables{$v2};
    	  		} elsif ($op eq "**") {
    	  			$printz = $variables{$v1} ** $variables{$v2};
    	  		} elsif ($op eq "-") {
    	  			$printz = $variables{$v1} - $variables{$v2};
    	  		} elsif ($op eq "/") {
    	  			$printz = $variables{$v1} / $variables{$v2};
    	  		} elsif ($op eq "%") {
    	  			$printz = $variables{$v1} % $variables{$v2};
    	  		} else { print"# Unknown operator $op\n"; }
    	  }
    	  
    	  #remove extra quotes
    	  $printz =~ s/^[\"\']//g; $printz =~ s/[\"\']$//g;
    	  print "$space"."print"." \""."$printz"."\\n\";\n";
        
    #if statements
    #need to support logical operators as well
    } elsif ($line =~ /^(\s*)if\(?([^\:]+):\s*(.*)/) {
    	 $space = $1;
    	 $condition = addDollar($2);
    	 $statement = addDollar($3);
    	 
    	 $condition =~ s/and/\&\&/g; $condition =~ s/or/\|\|/g;
    	 $condition = checkBrace($condition); 
    	 
    	 if(!defined $s3 || $s3 eq "") {   #on different line
    	 	print "$space"."if($condition) "."\{\n";
    	 	$closingExpected++;
    	 } else {          #on same line
    	 	$statement = formatPrint($statement);
    	 	print "$space"."if($condition) "."\{ \n$1\t"."$statement\; \n$1"."\}\n";
    	 }
    
    #while loop
    #need to support logical operators as well
    } elsif ($line =~ /^(\s*)while\(?([^\:]*)\)?:\s*(.*)/) {
    	 $condition = addDollar($2);
    	 $statement = addDollar($3);
    	 $condition =~ s/and/\&\&/g; $condition =~ s/or/\|\|/g;
    	 $condition = checkBrace($condition);
    	 
    	 if($3 eq "") {   #on different line
    	 	print "$1"."while($condition) "."\{\n";
    	 } else {			#on same line
    	 	$statement = formatPrint($statement);
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
