#!/usr/bin/perl -w

# COMP2041 assignment 1:  http://www.cse.unsw.edu.au/~cs2041/assignments/pypl
# written by Ka Wing Ho z5087077 18th September 2017

use Text::Tabs;

#Todo / Haven't supported
# - bitwise operators: | ^ & << >> ~


our %variables = ();
our $closingExpected = 0;
my $previousIndent = "";

#finding variables and adding '$' to them
#ignore things in quotes
#find arrays and adding '@' to them
sub process {
	my $in = shift(@_);
	#print "#process to $in\n";
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
	
	#checking $in for int() function calls
	if($in =~ /\bint\((.*?)\)/) {
		my $arg = $1;
		my $rep = "int($arg)";
		
		$in =~ s/\Q$rep\E/int $arg/;
		
	}
	
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
			#print "#\$in = $in\n";
			$in =~ s/\Q$check\E/$check2/;
			#print "#\$out = $in\n";
		}
	}
	return $in;
}


while ($line = <>) {

	 #check for indentation
	 my ($indent) = $line =~ /^(\s*)/;
	 my $li = length $indent;
	 
	 if($previousIndent ne "") {
	 	$pli = length $previousIndent;
	 	
	 	#previous indent 
	 	if($li < $pli && $closingExpected > 0 && $line !~ /elif|else/) {
	 		print "$indent}\n";
	 		$closingExpected--;
	 	}
	 }
	 $previousIndent = $indent;
	
	 #skip import statements
	 print "\n" and next if $line =~/^import/;
	 
	 #change all instances of readline to STDIN
	 $line =~ s/sys.stdin.readline\(\)/<STDIN>/;

	 # translate #! line
    if ($line =~ /^#!/ && $. == 1) { print "#!/usr/bin/perl -w\n";
	
	 # Blank & comment lines can be passed unchanged
	 # if a blank line is read in and a closing brace expected add one
    } elsif ($line =~ /^\s*(#|$)/) { print $line;
	 
	 # print(...) statements / sys.stdout.write statements
    } elsif ($line =~ /^(\s*)(print|sys.stdout.write)\s*\(([\"\']?[^\)]*[\"\']?)\)$/) {
    	  
    	  #var substitution
    	  $stdout = $2;
		  $printz = process($3);
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
    	  
    	  
    	  #print vs sys.stdout
    	  if($stdout =~ /print/) {
    	  		print "$space"."print"." \""."$printz"."\\n\";\n";
    	  } else {
    	  		print "$space"."print"." \""."$printz"."\";\n";
    	  }
    
    #else statements
    } elsif ($line =~ /^(\s*)else\s*:\s*(.*)/) {
    	$space = $1;
    	$statement = process($2);
    	$closingExpected--;
    	
    	if(!defined $statement || $statement eq "") {   #on different line
    	 	print "$space"."} else "."\{\n";
    	 	$closingExpected++;
    	 } else {          #on same line
    	 	$statement = formatPrint($statement);
    	 	print "$space"."} else "."\{ "."$statement\;"." \}\n";
    	 }
        
    #if/elif statements
    #need to support logical operators as well
    } elsif ($line =~ /^(\s*)(if|elif)\(?([^\:]+)\)?:\s*(.*)/) {
    	 $space = $1;
    	 $if = $2;
    	 
    	 if($if eq "elif") { $if = "} elsif"; $closingExpected--;}
    	 
    	 $condition = process($3);
    	 $statement = process($4);
    	 
    	 $condition =~ s/and/\&\&/g; $condition =~ s/or/\|\|/g; $condition =~ s/not/\!/g;
    	 $condition = checkCondition($condition);
    	 $condition = checkBrace($condition); 
    	 
    	 if(!defined $statement || $statement eq "") {   #on different line
    	 	print "$space"."$if($condition) "."\{\n";
    	 	$closingExpected++;
    	 } else {          #on same line
    	 	$statement = formatPrint($statement);
    	 	print "$space"."$if($condition) "."\{ "."$statement\;"." \}\n";
    	 }
    
    #while loop
    #need to support logical operators as well
    } elsif ($line =~ /^(\s*)while\(?([^\:]*)\)?:\s*(.*)/) {
    	 $condition = process($2);
    	 $statement = process($3);
    	 $condition =~ s/and/\&\&/g; $condition =~ s/or/\|\|/g; $condition =~ s/not/\!/g;
    	 $condition = checkCondition($condition);
    	 $condition = checkBrace($condition);
    	 
    	 if(!defined $statement || $statement eq "") {   #on different line
    	 	print "$1"."while($condition) "."\{\n";
    	 	$closingExpected++;
    	 } else {			#on same line
    	 	$statement = formatPrint($statement);
    	 	print "$1"."while($condition) "."\{ "."$statement\;"." \}\n";
    	 }
    
    
    #variables
    #needs to be upgraded to handle math operations in variables as well
    #needs to be upgraded to handle other variables as well ...
    } elsif ($line =~ /(\s*)([\w]+)\s*=\s*([\w \_\*\/\+\%\"\'\\\(\)\<\>-]+)/) {
    	  $t = process($3);
    	  
    	  if(!defined $variables{$2}) {
    	  		$variables{$2} = $t;  #Hash variable to values
    	  		print "$1"."my \$"."$2 = $t;"."\n";
    	  } else {
    	  		$variables{$2} = $t;  #Hash variable to values
    	  		print "$1"."\$"."$2 = $t;"."\n"; 
    	  }
     
    #for loops
    } elsif ($line =~ /^(\s*)for\s*(\w+)\s*in\s*(.*?):\s*(.*)/) {
    	$space = $1;
    	$loop  = $2;
    	$iterable = $3;
    	$variables{$loop} = 0;  #add to list of variables
    	$loop = process($loop);
    	$statement = process($4);
    	
    	#$i in range
    	if($iterable =~ /range/) {
    		#find out which type of range it is
    		($start,$stop,$step) = $iterable =~ /range\(\s*(\d+)\s*,?\s*(\d+)?\s*,?\s*(\d+)?\s*\)/;
    		
    		if(defined $start && !defined $stop && !defined $step) {
    			$start--; $newIter = "(0..$start)";
    		} elsif (defined $start && defined $stop && !defined $step) {
    			$stop--; $newIter = "($start..$stop)";
    		} else {  #not handled in subset3 yet
    			$stop--; $newIter = "($start..$stop)";
    			my $increment = "$loop = $loop + $step;"  #this has to be added at end of loop
    		}
    		
    		
    		if(!defined $statement || $statement eq "") { #on different line
    			print "$space"."foreach my $loop "."$newIter "."\{\n";
    			$closingExpected++;
    		} else { #on same line
    			$statement = formatPrint($statement);
    			print "$space"."foreach my $loop "."$newIter "."\{ "."$statement\;"." \}\n";
    		
    		}
    		#printz = "$space foreach $loop ($new)"
    		
    	
    	} #else if its an array/list 
    	
    #continue and break
    } elsif ($line =~ /continue|break/ && $line !~ /^\#/) {
    		$line =~ s/continue/next\;/g;
    		$line =~ s/break/last\;/g;
    		print $line;
    	 
    # Lines we can't translate are turned into comments
    } else { print "#(x) $line"; }
}

#if no more STDIN but closing brace still expected add one !
while ($closingExpected > 0) {
	#print "#$previousIndent/previousIndent\n";
	$closingIndent = $previousIndent;
	
	if($closingIndent =~ /^ /) {    $closingIndent =~ s/^ {4}//;
	} elsif ($closingIndent =~ /^\t/) { $closingIndent =~ s/^\t//;
	} else { print "#error in indentations!\n";}
	
	#print "#$closingIndent/closingIndent\n";
	print "$closingIndent}\n";
	$previousIndent = $closingIndent;
	$closingExpected--;
}


