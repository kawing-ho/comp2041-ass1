#!/usr/bin/perl -w

# COMP2041 assignment 1:  http://www.cse.unsw.edu.au/~cs2041/assignments/pypl
# written by Ka Wing Ho z5087077 18th September 2017

#Todo / Haven't supported
# - bitwise operators: | ^ & << >> ~


our %variables = ();
our $closingExpected = 0;

#finding variables and adding '$' to them
sub addDollar {
	my $in = shift(@_);
	#print "#addDollar to $in\n";
	my $QUOTE = 0;
	
	my @buff = split(" ",$in);
	foreach $item (@buff) {
		
		#if quote detected toggle on/off
		if ($item =~ /[\'\"]/) {
			next if $item =~ /^[\'\"].*?[\'\"]$/;
			#print "#$item matched quote\n";
			if($QUOTE == 0) { $QUOTE = 1; } else { $QUOTE = 0; }
			next;
		}
		
		#if($QUOTE == 1) { print "skipping $item \n";}
		next if($QUOTE == 1);
		
		foreach $var (keys %variables) {
			next if $item =~ /^\$.*/;
			next if $item =~ /[a-zA-Z]$var/;
			next if $item =~ /$var[a-zA-Z]/;
			$item =~ s/$var/\$$var/g;
		}
	}
	$in = join(" ",@buff);
	#print "#addDollar out $in\n";
	return $in;
}

#Look for print statements in a string and FORMAT them !
sub formatPrint {
	my $in = shift(@_);
	my $out = "";
	my @buff = split ';' , $in;
	
	foreach $i (@buff) {
		#print "#format print: $i\n";
		#format if its print statement
		if($i =~ /print\s*\((.*)\)/) {
			my $t = $1;
			$t =~ s/^[\'\"]//; $t =~ s/[\'\"]$//g;
			$i = "print \"$t\\n\""
		}
		
		if($out eq "") { $out = $i; } else { $out = $out.";".$i; }
		#print "#\$out = $out\n";
	}
	
   return $out;
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
sub checkCondition {
	my $in = shift(@_);
	
	#print "# \$in = $in\n";
	#if u have any operators followed by "/' substitute !
	$in =~ s/\s*==\s*\"/ eq \"/g; $in =~ s/\"\s*==\s*/\" eq /g;
	$in =~ s/\s*==\s*\'/ eq \'/g; $in =~ s/\'\s*==\s*/\' eq /g;
	$in =~ s/\s*!=\s*\"/ ne \"/g; $in =~ s/\"\s*!=\s*/\" ne /g;
	$in =~ s/\s*!=\s*\'/ ne \'/g; $in =~ s/\'\s*!=\s*/\' ne /g;
	
	#if comparing between variable check that the variable stores a string
	my @buff = split(/[\&\|]{2}/,$in);
	foreach $check (@buff) {  #check example $a == $b
		my ($var1, $op, $var2) = $check =~ /\$(\w+)\s*([!=]{2})\s*\$(\w+)/ or next;
		#print "### \$v1:$var1//$variables{$var1}, \$op:$op, \$v2:$var2//$variables{$var2}\n";
		
		#if either var1 or var2 is a string var have to change
		if($variables{$var1} =~ /[\"\']/ || $variables{$var2} =~ /[\"\']/) {
			#print "#should be replacing for $check\n";
			my $check2 = $check;
			if($op =~ m/==/) { $check2 =~ s/==/eq/; }
			if($op =~ m/!=/) { $check2 =~ s/!=/ne/; }
			print "#\$in = $in\n";
			$in =~ s/\Q$check\E/$check2/;
			print "#\$out = $in\n";
		}
	
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
    } elsif ($line =~ /^(\s*)print\s*\(([\"\']?[^\)]+[\"\']?)\)$/) {
    	  
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
    } elsif ($line =~ /^(\s*)if\(?([^\:]+)\)?:\s*(.*)/) {
    	 $space = $1;
    	 $condition = addDollar($2);
    	 $statement = addDollar($3);
    	 
    	 $condition =~ s/and/\&\&/g; $condition =~ s/or/\|\|/g; $condition =~ s/not/\!/g;
    	 $condition = checkCondition($condition);
    	 $condition = checkBrace($condition); 
    	 
    	 if(!defined $statement || $statement eq "") {   #on different line
    	 	print "$space"."if($condition) "."\{\n";
    	 	$closingExpected++;
    	 } else {          #on same line
    	 	$statement = formatPrint($statement);
    	 	print "$space"."if($condition) "."\{ "."$statement\;"." \}\n";
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
     
    #for loops
    } elsif ($line =~ /^(\s*)for\s*(\w+)\s*in\s*(.*?):\s*(.*)/) {
    	$space = $1;
    	$loop  = $2;
    	$iterable = $3;
    	$variables{$loop} = 0;
    	$statement = $4;
    	
    	print "#\$loop = $loop,  \$iterable = $iterable\n";
    	#$i in range
    	if($iterable =~ /range/) {
    		$printz = "$space foreach $loop ($new)"
    	
    	}
    	 
    # Lines we can't translate are turned into comments
    } else { print "#(x) $line"; }
}
