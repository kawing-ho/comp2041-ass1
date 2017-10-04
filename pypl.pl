#!/usr/bin/perl -w

# COMP2041 assignment 1:  http://www.cse.unsw.edu.au/~cs2041/assignments/pypl
# written by Ka Wing Ho z5087077 18th September 2017

use Text::Tabs;

our %variables = ();
our $closingExpected = 0;
our $previousIndent = "";
my $previousIf = "";

#finding variables and adding '$' to them (ignore things in quotes)
sub findVariables {
	my $in = shift(@_);
	
	#flag for checking if a quote has currently been opened/closed
	my $QUOTE = 0;
	
	my @buff = split(" ",$in);
	foreach $item (@buff) {
		
		#if quote detected toggle on/off
		if ($item =~ /[\'\"]/) {
			next if $item =~ /^[\'\"].*?[\'\"]$/;  #skip if quotes appear twice (double negative)
			if($QUOTE == 0) { $QUOTE = 1; } else { $QUOTE = 0; }
			next;
		}
		
		next if($QUOTE == 1); #skip any variables found within quotes
		
		foreach $var (keys %variables) {    #do not add $ to an item if
			next if $item =~ /^\$.*/;        # if already has a $ infront
			next if $item =~ /[a-zA-Z]$var/; # if the var is connected to another word
			next if $item =~ /$var[a-zA-Z]/; # eg. $a -> and / banana  ($and b$an$an$a is wrong)
			$item =~ s/$var/\$$var/g;
		}
	}
	$in = join(" ",@buff);
	
	#checking $in for int() function calls
	if($in =~ /\bint\((.*?)\)/) {
		my $arg = $1;
		my $rep = "int($arg)";
		my $name = $arg; $name =~ s/^\$//;
		
		$in =~ s/\Q$rep\E/int $arg/g;
		
	}
	
	return $in;
}

#Look for print statements in a string and FORMAT them !
#only useful if bad style is used eg. if( a > 1): print(a); print(b)
sub formatPrint {
	my $in = shift(@_);
	my $out = "";
	my @buff = split ';' , $in;
	
	foreach $i (@buff) {

		#format if its print statement
		if($i =~ /print\s*\((.*)\)/) {
			my $t = $1;
			$t =~ s/^[\'\"]//; $t =~ s/[\'\"]$//g;
			$i = "print \"$t\\n\""
		}
		
		#semicolon check 
		if($out eq "") { $out = $i; } else { $out = $out.";".$i; }

	}
	
   return $out;
}

#adds extra brackets ( ( ) ) if number of brackets in a line are mismatched
#could've used a stack but its too late now
sub checkBrace {
	my $in = shift(@_);
	my $openCount = 0;
	my $closeCount = 0;
	
	foreach $char (split "",$in) {
		$openCount++ if ($char eq "(");
		
		$closeCount++ if ($char eq ")");
	}
	
	#DO replacing for brackets if the counts do not match
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
	
	#this wall of regex basically says:
	#if you have an operator followed by a open/close quote 
	#its most likely for a string, so change == to eq , != to ne
	$in =~ s/\s*==\s*\"/ eq \"/g; $in =~ s/\"\s*==\s*/\" eq /g;
	$in =~ s/\s*==\s*\'/ eq \'/g; $in =~ s/\'\s*==\s*/\' eq /g;
	$in =~ s/\s*!=\s*\"/ ne \"/g; $in =~ s/\"\s*!=\s*/\" ne /g;
	$in =~ s/\s*!=\s*\'/ ne \'/g; $in =~ s/\'\s*!=\s*/\' ne /g;
	
	#if comparing between variable check that the variable stores a string
	my @buff = split(/[\&\|]{2}/,$in);
	foreach $check (@buff) {  #for example $a == $b where a and b are both strings
		my ($var1, $op, $var2) = $check =~ /\$(\w+)\s*([!=]{2})\s*\$(\w+)/ or next;  #skip if no match
		
		#if either var1 or var2 is a string var have to change
		if($variables{$var1} =~ /[\"\']/ || $variables{$var2} =~ /[\"\']/) {

			my $check2 = $check;
			if($op =~ m/==/) { $check2 =~ s/==/eq/; }
			if($op =~ m/!=/) { $check2 =~ s/!=/ne/; }

			$in =~ s/\Q$check\E/$check2/;
		}
	}
	return $in;
}

#looks at indent and decides whether a bracket needs to be added or not
sub checkIndent {
	my $in = shift(@_);

	#check for indentation + length of indent
	my ($indent) = $in =~ /^(\s*)/;
	my $li = length $indent;
	
	if($previousIndent ne "") {
		$pli = length $previousIndent;
	 	
		#previous indent 
		if($li < $pli && $closingExpected > 0) {
		
			while($li < $pli) {

				$closingIndent = $previousIndent;
				
				#very brute force way of "removing indents for next line"
				if($closingIndent =~ /^ /) {    #add support for tabs/4space/3space later
					$closingIndent =~ s/^ {4}//;
				} elsif ($closingIndent =~ /^\t/) { 
					$closingIndent =~ s/^\t//;
				} else { print "#error in indentations!\n";}
				
				$previousIndent = $closingIndent;
				$pli = length $previousIndent;
				if($pli != $li || $line !~ /^\s*elif|else/) {  
				   #prints a { if the line read from stdin isn't elif/else
				   #since these statements come with their own close brace (eg. } else { )
				   #so printing another brace would be extra 
					print "$closingIndent}\n";
					#$closingExpected--;
				}
				$closingExpected--;
				
			}
	 		
		}
	}
	 
	#Don't count blank lines for previousIndent
	$previousIndent = $indent if($line !~ /^\s*$/);
}





while ($line = <>) {

	 #skip comment and blank lines after first hashbang line
	 print "$line" and next if($line =~ /^\s*(#|$)/ && $. != 1);
	 
	 #check Indentation/brackets at the start of line 
	 checkIndent($line);
	
	 #comment out import statements
	 print "#".$line and next if $line =~/^import/;
	 
	 #change all instances of readline to STDIN (yes its not the most stable way to do it I know)
	 $line =~ s/sys.stdin.readline\(\)/<STDIN>/g;

	 # translate #! line
    if ($line =~ /^#!/ && $. == 1) { print "#!/usr/bin/perl -w\n";
	 
	 # =====print(...) statements / sys.stdout.write statements=====
	 #regex says: if the line matches print/sys.stdout.write with ( ... ) and optional comment
	 #this regex is pretty much the same for all others below
    } elsif ($line =~ /^(\s*)(print|sys.stdout.write)\s*\(([\"\']?.*[\"\']?)\)\s*(#.*)*$/) {
    	  
    	  #var substitution
    	  $space  = $1;
    	  $stdout = $2;
		  $printz = findVariables($3);
		  $comment = $4 || "";
    	  
    	  #doing math in printz (regex: no quotes and contains math operators)
    	  if($printz !~ /^[\"\'][^\'\"]*[\'\"]$/ && $printz =~/[\*\+\-\/\%]+/) {
    	  		
    	  		#interpolate the values of variables into the printz string
    	  		#eg: print( $a + $b) -> print( 1 + 2)
    	  		foreach $var (keys %variables) {
    	  			next if $printz !~ m/\$$var/;
    	  			$value = $variables{$var};
    	  			$replace = "$value";
    	  			$printz =~ s/(\$$var)/$replace/g;
    	  		}
    	  		
    	  		#substitue // for /
    	  		$printz =~ s/\/\//\//g;
    	  		$printz = eval $printz;  #math magic done here
    	  }
    	  
    	  #remove extra quotes
    	  $printz =~ s/^[\"\']//g; $printz =~ s/[\"\']$//g;
    	  
    	  
    	  #print vs sys.stdout
    	  if($stdout =~ /print/) {
    	  		print "$space"."print"." \""."$printz"."\\n\"; $comment\n";
    	  } else {
    	  		print "$space"."print"." \""."$printz"."\"; $comment\n";
    	  }
    
    #=====else statements======
    } elsif ($line =~ /^(\s*)else\s*:\s*(.*?)\s*(#.*)*$/) {
    	$space = $1;
    	$statement = findVariables($2);
    	$comment = $3 || "";
    	
    	
    	#if the previous if statement already closed the brace on the same line then
    	#the current line doesn't need to have one as well 
    	#eg. if( a == b) { ... }    VS     if( a == b) { 
      #												  . . .
    	#eg. else { ... }                  } else { ... }
    	if(!defined $statement || $statement eq "") {   #on different line
    		$closingExpected++;
    		if($previousIf =~ /\}\s*$/) { print "$space"."else "."\{ $comment\n";
    		} else { print "$space"."} else "."\{ $comment\n"; }
    	 } else {          #on same line
    	 	$statement = formatPrint($statement);
    	 	if($previousIf =~ /\}\s*$/) { print "$space"."else "."\{ "."$statement\;"." \} $comment\n";
    	 	} else { print "$space"."} else "."\{ "."$statement\;"." \} $comment\n"; $closingExpected--;}
    	 }
        
    #=====if/elif statements=====
    } elsif ($line =~ /^(\s*)(if|elif)\(?([^\:]+)\)?:\s*(.*?)\s*(#.*)*$/) {
    	 $space = $1;
    	 $if = $2;
    	 $comment = $5 || "";
    	 
    	 if($if eq "elif") {
    	 	if($previousIf =~ /\}\s*$/) { $if = "elsif" } else { $if = "} elsif"; }
    	 }
    	 
    	 $condition = findVariables($3);
    	 $statement = findVariables($4);
    	 
    	 $condition =~ s/and/\&\&/g; $condition =~ s/or/\|\|/g; $condition =~ s/not/\!/g;
    	 $condition = checkCondition($condition);
    	 $condition = checkBrace($condition); 
    	 
    	 #same case as the "else" statement
    	 if(!defined $statement || $statement eq "") {   #on different line
    	 	print "$space"."$if($condition) "."\{ $comment\n";
    	 	#if($if eq "if") {$closingExpected++;}
    	 	$closingExpected++;
    	 	
    	 	$previousIf = "$space"."$if($condition) "."\{ $comment\n";
    	 	
    	 } else {          #on same line
    	 	$statement = formatPrint($statement);
    	 	print "$space"."$if($condition) "."\{ "."$statement\;"." \} $comment\n";
    	 	if($if eq "elsif") {$closingExpected--;}
    	 	
    	 	$previousIf = "$space"."$if($condition) "."\{ "."$statement\;"." \} $comment\n";
    	 }
    
    #=====while loop=====
    } elsif ($line =~ /^(\s*)while\s*\(?([^\:]*)\)?:\s*(.*?)\s*(#.*)*$/) {
    	 $condition = findVariables($2);
    	 $statement = findVariables($3);
    	 $comment = $4 || "";
    	 $condition =~ s/and/\&\&/g; $condition =~ s/or/\|\|/g; $condition =~ s/not/\!/g;
    	 $condition = checkCondition($condition);
    	 $condition = checkBrace($condition);
    	 
    	 if(!defined $statement || $statement eq "") {   #on different line
    	 	print "$1"."while($condition) "."\{ $comment\n";
    	 	$closingExpected++;
    	 } else {			#on same line
    	 	$statement = formatPrint($statement);
    	 	print "$1"."while($condition) "."\{ "."$statement\;"." \} $comment\n";
    	 }
    
    
    #=====variables=====
    } elsif ($line =~ /(\s*)([\w]+)\s*=\s*(.*?)\s*(#.*)*$/) {
    	  $space = $1;
    	  $varname = $2;
    	  $comment = $4 || "";
    	  $t = findVariables($3);
    	  
    	  #if the RHS isn't a string (no quotes which implies its math) replace // with /
    	  if($t !~ /^[\"\'][^\'\"]*[\'\"]$/) {$t =~ s/\/\//\//g;}
    	  
    	  #special treatment for int( $xxx )
    	  if($t =~ /int\s*\$(\w+)/) { $t = int $variables{$1};}
    	  
    	  if(!defined $variables{$varname}) {$declare = "my ";} else {$declare = '';}
    	  $variables{$varname} = $t;  #Hash variable to values
    	  print "$space"."$declare\$"."$varname = $t; $comment"."\n";
     
    #=====for loops=====
    } elsif ($line =~ /^(\s*)for\s*(\w+)\s*in\s*(.*?):\s*(.*?)\s*(#.*)*$/) {
    	$space = $1;
    	$loop  = $2;
    	$iterable = $3;
    	$comment = $5 || "";
    	$variables{$loop} = 0;  #add to list of variables
    	$loop = findVariables($loop);
    	$statement = findVariables($4);
    	
    	#$i in range
    	if($iterable =~ /range/) {
    		#find out which type of range it is  -> regex to catch range(x) , range(x,x) , range(x,x,x)
    		($start,$stop,$step) = $iterable =~ /range\(\s*([^\,]+)\s*,?\s*([^\,]+)?\s*,?\s*([^\)]*)?\s*\)/;
    		
    		$start = findVariables($start); $stop = findVariables($stop); $step = findVariables($step);
    		#print "\$start = $start, \$stop = $stop, \$step = $step\n";
    		
    		if(defined $start && !defined $stop && (!defined $step || $step eq "")) {
    			$start--; $newIter = "(0..$start)";
    		} elsif (defined $start && defined $stop && (!defined $step || $step eq "")) {
    			if ($stop =~ m/^\d+$/) {$stop--;} else { $stop = $stop." -1 "; }
    			$newIter = "($start..$stop)";
    			
    		} else {  #not handled in subset3 yet
    			$stop--; $newIter = "($start..$stop)";
    			my $increment = "$loop = $loop + $step;"  #this has to be added at end of loop
    		}
    		
    		
    		if(!defined $statement || $statement eq "") { #on different line
    			print "$space"."foreach my $loop "."$newIter "."\{ $comment\n";
    			$closingExpected++;
    		} else { #on same line
    			$statement = formatPrint($statement);
    			print "$space"."foreach my $loop "."$newIter "."\{ "."$statement\;"." \} $comment\n";
    		}
    		
    	
    	} #else if its an array/list (didn't reach subset4 unfortunately)
    	
    #=====continue and break=====
    } elsif ($line =~ /continue|break/ && $line !~ /^\#/) {
    		$line =~ s/continue/next\;/g;
    		$line =~ s/break/last\;/g;
    		print $line;
    	 
    # Lines we can't translate are turned into comments
    } else { print "#(x) $line"; }
    
}

#if no more STDIN but closing brace still expected add them !
#special case where the last few lines of the program are if statement
while ($closingExpected > 0) {
	#print "#$previousIndent/previousIndent\n";
	$closingIndent = $previousIndent;
	
	#brute force removal of indent again
	if($closingIndent =~ /^ /) {    $closingIndent =~ s/^ {4}//;
	} elsif ($closingIndent =~ /^\t/) { $closingIndent =~ s/^\t//;
	} else { print "#error in indentations!\n";}
	
	#print "#$closingIndent/closingIndent\n";
	print "$closingIndent}\n";
	$previousIndent = $closingIndent;
	$closingExpected--;
}

