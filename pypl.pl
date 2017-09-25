#!/usr/bin/perl -w

# COMP2041 assignment 1:  http://www.cse.unsw.edu.au/~cs2041/assignments/pypl
# written by Ka Wing Ho z5087077 18th September 2017

#Todo / Haven't supported
# - comparison operators: <, <=, >, >=, !=, ==
# - bitwise operators: | ^ & << >> ~


our %variables = ();
our $closingExpected = 0;


#All this work just for adding '$'
#find a way to ignore any variables in quotes

#split by space will give things like print('a 
#need to avoid anything in quotes as well

sub addDollar {
	my $in = shift(@_);
	print "#addDollar to $in\n";
	my $QUOTE = 0;
	
	my @buff = split(" ",$in);
	foreach $item (@buff) {
		
		#if quote detected toggle on/off
		if ($item =~ /[\'\"]/) {
			print "$item matched quote\n";
			if($QUOTE == 0) { $QUOTE = 1; } else { $QUOTE = 0; }
		}
		
		if($QUOTE == 1) { print "skipping $item \n";}
		next if($QUOTE == 1);
		
		foreach $var (keys %variables) {
			next if $item =~ /^\$.*/;
			next if $item =~ /[a-zA-Z]$var/;
			next if $item =~ /$var[a-zA-Z]/;
			$item =~ s/$var/\$$var/g;
		}
	}
	$in = join(" ",@buff);
	print "#addDollar out $in\n";
	return $in;
}

#Look for print statements in a string and FORMAT them !
sub formatPrint {
	my $in = shift(@_);
	print "#format print: $in\n";
	$in =~ /print\((.*)\)/;
	print "\$1 = $1\n";
	if($1 ne "") {
		my $t = $1;
		$t =~ s/^[\'\"]//; $t =~ s/[\'\"]$//g;
		$in = "print \"$t \\n \""
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

#check for correct operator in any conditions
#example: if name == "John" and age == 23:
# string operations must be eq/ne for string
# all numeric stays the same !


sub checkCondition {
	my $in = shift(@_);
	
	my @c = split(/and|or/, $in);
	foreach $condition (@c) {
		my ($lhs,$op,$rhs) = $condition =~ //;
		
	
	
	}
	
	
	
	return $in;

}


while ($line = <>) {

	 #Continue and break
	 if ($line =~ /continue/ && $line !~ /^\#/) {
	 	  $line =~ s/continue/next\;/g;
	 	  print STDERR "--Replacing continue--\n";
	 	  print $line;
	 }
	 
	 if ($line =~ /break/ && $line !~ /^\#/) {
	 	 $line =~ s/break/last\;/g;
	 	 print STDERR "--Replacing break--\n";
	 	 print $line;
	 }


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
    	 
    	 $condition =~ s/and/\&\&/g; $condition =~ s/or/\|\|/g; $condition =~ s/not/\!/g;
    	 $condition = checkCondition($condition);
    	 $condition = checkBrace($condition); 
    	 
    	 if(!defined $3 || $3 eq "") {   #on different line
    	 	print "$space"."if($condition) "."\{\n";
    	 	$closingExpected++;
    	 } else {          #on same line
    	 	$statement = formatPrint($statement);
    	 	print "$space"."if($condition) "."\{ $1"."$statement\; $1"."\}\n";
    	 }
    
    #while loop
    #need to support logical operators as well
    } elsif ($line =~ /^(\s*)while\(?([^\:]*)\)?:\s*(.*)/) {
    	 $condition = addDollar($2);
    	 $statement = addDollar($3);
    	 $condition =~ s/and/\&\&/g; $condition =~ s/or/\|\|/g; $condition =~ s/not/\!/g;
    	 $condition = checkCondition($condition);
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
