#!/usr/bin/perl
#  _____ _____ _____ _____ 
# |     |  |  |   | |_   _|
# |  |  |  |  | | | | | |  
# |__  _|_____|_|___| |_|  
#    |__|
#
# QUeue for Numeric Transformation v0.053
# Pronounced "kyūnt", not...the other way
#
# Copyright (c) 2013, Dan Hetrick
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
#	* Redistributions of source code must retain the above copyright notice, this list of
#	conditions and the following disclaimer.
#	
#	* Redistributions in binary form must reproduce the above copyright notice, this list
#	of conditions and the following disclaimer in the documentation and/or other materials
#   provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

use strict;
use warnings;

# |---------------|
# | GLOBALS BEGIN |
# |---------------|

my $LOGO = << 'EOL';
 _____ _____ _____ _____ 
|     |  |  |   | |_   _|
|  |  |  |  | | | | | |  
|__  _|_____|_|___| |_|  
   |__|            v0.053
EOL

my $APPLICATION = "QUNT Compiler/Interpreter";
my $VERSION = "0.053";
my $DEBUG_MODE = 0;
my $SHELL_PROMPT = '. ';

# Globals needed for compilation
my @TOKENS = ();
my $COMPILED_CODE_STUB = join('',<DATA>);

# Globals needed for the interactive shell
my @QUEUE = ();
my @WORK_QUEUE_COPY = ();
my $BUFFER = 0;

# |-------------|
# | GLOBALS END |
# |-------------|

# |-----------------|
# | MAIN CODE BEGIN |
# |-----------------|

# |===================|
# | Handle piped code |
# |===================|

# piped code is compiled and interpreted
if(-t){}else{

	# grab incoming piped code
	my $CODE = <>;
	
	# clean up piped code
	$CODE=~ s/\s//g; # strip spaces
	$CODE=~ s/\n//g; # strip newlines

	# Tokenize the code
	tokenize($CODE);

	# Compile the tokenized code
	my $COMPILED = compile();

	# Execute compiled code
	eval $COMPILED;

	exit;
}

# |==============================|
# | Handle commandline arguments |
# |==============================|

# qunt.pl help
# Display usage information if -h, -help, --help, or help is passed as an argument
if($#ARGV==0){
	if( (lc($ARGV[0]) eq "-h") || (lc($ARGV[0]) eq "-help") || (lc($ARGV[0]) eq "--help") || (lc($ARGV[0]) eq "help") ) {
		usage();
		exit;
	}
}

# qunt.pl debug
# Turn on debug shell mode if "debug" is passed as an argument
if($#ARGV==0){
	if(lc($ARGV[0]) eq "debug"){
		$DEBUG_MODE = 1;
		@ARGV = ();
	}
}

# qunt.pl text TEXT
# text-to-QUNT mode
if(($#ARGV>=1)&&(lc($ARGV[0]) eq 'text')){
	shift @ARGV;
	print convert_text_to_qunt(join(' ',@ARGV))."\n";
	exit;
}

# qunt.pl run FILENAME
# interpreter mode
if(($#ARGV==1)&&(lc($ARGV[0]) eq 'run')){

	# Try to open the first argument as a file
	open(FILE,"<$ARGV[1]") or die "Error opening file \"$ARGV[1]\"";
	my $CODE = join('',<FILE>);
	close FILE;

	# clean up input code
	$CODE=~ s/\s//g; # strip spaces
	$CODE=~ s/\n//g; # strip newlines

	# Tokenize the code
	tokenize($CODE);

	# Compile the tokenized code
	my $COMPILED = compile();

	# Execute compiled code
	eval $COMPILED;

	exit;
}

# display short usage info if we've been passed an argument we don't recognize
if($#ARGV>=1){
	print "Error:  Command(s) not recognized\n";
	short_usage();
	exit 1;
}

# |========================|
# | QUNT interactive shell |
# |========================|

# If no argument is passed or debug shell mode is on, start the interactive shell
if($#ARGV!=0){

	print "$LOGO\n";
	print "QUNT Interactive Shell\n";
	print "Enter QUNT commands to be executed, or \"dump\" to show entered code\n";
	print "To write entered code to file, pass a filename as an argument to \"dump\"\n";
	print "Use the command \"clear\" to delete entered code from memory\n";
	if($DEBUG_MODE==1){ print "Debug mode ON\n"; }
	my $entered_code = '';
	while(){

		print $SHELL_PROMPT;
		my $input = <STDIN>;

		# clean up input code
		$input=~ s/\s//g; # strip spaces
		$input=~ s/\n//g; # strip newlines

		if($input eq ''){ next; }

		# |=========================|
		# | Handle special commands |
		# |=========================|

		# dump
		# display the entered code
		if(lc($input) eq "dump"){
			print "$entered_code\n";
			next;
		}

		# clear
		# delete entered code from memory
		if(lc($input) eq "clear"){
			$entered_code = '';
			next;
		}

		# dump FILENAME
		# write the entered code to file
		my @d = split(' ',$input);
		if($#d==1){
			if(lc($d[0]) eq 'dump'){
				if((-e $d[1])&&(-f $d[1])){
					print "File \"$d[1]\" already exists\n";
					next;
				} else {
					open(FILE,">$d[1]") or print "Error writing to file \"$d[1]\"" and next;
					print FILE $entered_code;
					close FILE;
					print "Wrote dumped code to \"$d[1]\"\n";
					next;
				}
			}
		}

		# |===========================================================|
		# | Add input code to entered code, and clean up entered code |
		# |===========================================================|

		$entered_code .= $input;
		$entered_code=~ s/\s//g; # strip spaces
		$entered_code=~ s/\n//g; # strip newlines

		# |======================================|
		# | Tokensize and compile the input code |
		# |======================================|

		tokenize($input);
		my $code = compile(1);

		# If we're in debug mode, display the compiled Perl code
		if($DEBUG_MODE==1){
			my @f = split("\n",$code);
			foreach my $l (@f){
				print "*\t$l\n";
			}
			print "\n";
		}

		# |===========================|
		# | Execute the compiled code |
		# |===========================|
		
		eval $code;

		# sanity check to make sure the buffer contains numerical data
		if(is_number($BUFFER)){}else{
			print "Error!  Buffer contains non-integer data.  Resetting buffer to zero.\n";
			$BUFFER = 0;
		}
	}
}

# |===============|
# | QUNT Compiler |
# |===============|

# Try to open the first argument as a file
open(FILE,"<$ARGV[0]") or die "Error opening file \"$ARGV[0]\"";
my $CODE = join('',<FILE>);
close FILE;

# clean up input code
$CODE=~ s/\s//g; # strip spaces
$CODE=~ s/\n//g; # strip newlines

# Tokenize the code
tokenize($CODE);

# Compile the tokenized code
my $OUTPUT = compile();

# Print the output code
print $OUTPUT."\n";

# |---------------|
# | MAIN CODE END |
# |---------------|

# |---------------------------|
# | SUPPORT SUBROUTINES BEGIN |
# |---------------------------|

# is_number
# short_usage
# usage
# convert_text_to_qunt
# compile
# tokenize

# is_number
# Arguments: 1 (scalar)
# Returns:  1 if the input is a number, undef if not
# Description:  Tests is a given input is a number or not.
#               This subroutine is duplicated in the QUNT executor stub
#               as "qunt_is_number".
sub is_number {
	my $n = shift;

	if ($n=~/^\d+$/) { return 1; }	# whole number
	if ($n=~/^-?\d+$/) { return 1; }	# integer
	if ($n=~/^[+-]?\d+$/) { return 1; }	# +/- integer
	if ($n=~/^-?\d+\.?\d*$/) { return 1; }	# real number
	if ($n=~/^-?(?:\d+(?:\.\d*)?|\.\d+)$/) { return 1; }	# decimal number
	if ($n=~/\D/) { return undef; }	# non-numeric data

	return undef;
}

# short_usage
# Arguments: none
# Returns: nothing
# Description:  Displays a short version of usage information.
sub short_usage {
	print "Usage: qunt.pl [FILENAME]\n";
	print "For more information, execute with \"help\" as the first argument.\n";
}

# usage
# Arguments: none
# Returns: nothing
# Description:  Displays usage information.
sub usage {
	print "$APPLICATION v$VERSION\n";
	print "Usage: qunt.pl [FILENAME]\n";
	print "Execute with \"run\" as the first argument, followed by a filename,\n";
	print "to compile and run a QUNT program.\n";
	print "Execute without argument to start interactive shell.\n";
	print "Execute with \"debug\" as argument to show generated code in interactive shell.\n";
	print "To convert text into QUNT code, execute with the argument \"text\", followed by\n";
	print "the text to convert.  All compiled/generated code is printed to STDOUT.\n";
}

# convert_text_to_qunt
# Arguments: 1 (scalar)
# Returns:  QUNT code
# Description:  Converts text into QUNT code that, if executed, prints the
#               original text.
sub convert_text_to_qunt {
	my $text = shift;

	# start the output code with a "clear queue" command
	my $c = '';

	# split the input into characters, and step through them
	foreach my $l (split('',$text)) {
		# convert the character into an ASCII code
		my $o = ord($l);
		# add the ASCII code, and a "print" command, to the output code
		$c .= '$'.$o;
	}

	# return the generated code
	return $c;
}

# compile
# Arguments: 1 optional
# Returns:  compiled QUNT code
# Description:  Compiles QUNT code into Perl.  If called with no argument
#               passed to the subroutine, an executor stub is added to
#               the code allowing for independant execution.  If called with
#               an argument ("1", or anything else that will evaluate to
#               "true"), the code is compiled in "shell mode";  the executor
#               stub is not added to compiled code, and any errors will not
#               cause the compiler to exit.  Tokens used for compilation are
#               taken from the global array @TOKENS, which is populated by
#               the tokenize() subroutine.
sub compile {

	my $shell = shift;

	my $CODE;

	# if we're not in "shell" mode, prepend the executor stub
	# to the output code
	if($shell){
		$CODE = '';
	} else {
		$CODE = $COMPILED_CODE_STUB;
	}

	my $IS_IN_LOOP = 0;
	my $IS_IN_CONDITIONAL = 0;
	my $CONDITIONAL_VALUE = 0;
	my $ELSE_COUNT = 0;

	# step through the token list and generate Perl code
	foreach my $cmd (@TOKENS){

		# |============================|
		# | COMMANDS WITHOUT ARGUMENTS |
		# |============================|

		if(length($cmd)==1){

			# |===|
			# | ! |
			# |===|
			# Exits a program or the shell
			if($cmd eq '!'){
				$CODE .= 'exit;'."\n";
				next;
			}

			# |===|
			# | . |
			# |===|
			# Gets user input and stores it in the buffer
			if($cmd eq '.'){
				$CODE .= '$BUFFER = <STDIN>;'."\n";
				$CODE .= 'chomp $BUFFER;'."\n";
				$CODE .= 'if(qunt_is_number($BUFFER)){}else{'."\n";
				$CODE .= '	print "Error!  $BUFFER is not an integer\n";'."\n";
				$CODE .= '	exit 1;'."\n";
				$CODE .= '}'."\n";
				next;
			}

			# |===|
			# | % |
			# |===|
			# Prints the queue contents
			if($cmd eq '%'){
				$CODE .= 'foreach my $e (@QUEUE){'."\n";
				$CODE .= '	print "$e\n";'."\n";
				$CODE .= '}'."\n";
				next;
			}

			# |===|
			# | < |
			# |===|
			# Removes the first entry in the queue
			if($cmd eq '<') {
				$CODE .= 'shift(@QUEUE);'."\n";
				next;
			}

			# |===|
			# | | |
			# |===|
			# Removes the last entry in the queue
			if($cmd eq '|') {
				$CODE .= 'pop(@QUEUE);'."\n";
				next;
			}

			# |===|
			# | & |
			# |===|
			# Sets the buffer to the last queue value
			if($cmd eq '&'){
				$CODE .= 'if($#QUEUE>=0){ $BUFFER = $QUEUE[$#QUEUE]; } else { $BUFFER = 0; }'."\n";
				next;
			}

			# |===|
			# | ` |
			# |===|
			# Sets the buffer to the first queue value
			if($cmd eq '`'){
				$CODE .= 'if($#QUEUE>=0){ $BUFFER = $QUEUE[0]; } else { $BUFFER = 0; }'."\n";
				next;
			}

			# |===|
			# | : |
			# |===|
			# Adds the buffer value onto the end of the queue, and sets the buffer to zero
			if($cmd eq ':'){
				$CODE .= 'push(@QUEUE,$BUFFER);  $BUFFER = 0;'."\n";
				next;
			}

			# |===|
			# | ; |
			# |===|
			# Adds the buffer value onto the beginning of the queue, and sets the buffer to zero
			if($cmd eq ';'){
				$CODE .= 'unshift(@QUEUE,$BUFFER);  $BUFFER = 0;'."\n";
				next;
			}

			# |===|
			# | ? |
			# |===|
			# Prints the buffer's contents
			if($cmd eq '?'){
				$CODE .= 'print $BUFFER."\n";'."\n";
				next;
			}

			# |===|
			# | @ |
			# |===|
			# Clears the queue (deletes all queue values)
			if($cmd eq '@'){
				$CODE .= '@QUEUE = ();'."\n";
				next;
			}

			# |===|
			# | + |
			# |===|
			# Adds all values in queue and saves result to the buffer
			if($cmd eq '+'){
				$CODE .= '$BUFFER = 0;'."\n";
				$CODE .= 'foreach my $e (@QUEUE){'."\n";
				$CODE .= '	$BUFFER += $e;'."\n";
				$CODE .= '}'."\n";
				$CODE .= 'if($BUFFER){}else{ $BUFFER = 0; }'."\n";
				next;
			}

			# |===|
			# | * |
			# |===|
			# Multiply all values in queue, in sequence, and saves result to the buffer
			if($cmd eq '*'){
				$CODE .= '@WORK_QUEUE_COPY = @QUEUE;'."\n";
				$CODE .= '$BUFFER = shift @WORK_QUEUE_COPY;'."\n";
				$CODE .= 'foreach my $we (@WORK_QUEUE_COPY){'."\n";
				$CODE .= '	$BUFFER = $BUFFER * $we;'."\n";
				$CODE .= '}'."\n";
				$CODE .= '@WORK_QUEUE_COPY = ();'."\n";
				$CODE .= 'if($BUFFER){}else{ $BUFFER = 0; }'."\n";
				next;
			}

			# |===|
			# | ^ |
			# |===|
			# Exponents all values in queue, in sequence, and saves result to the buffer
			if($cmd eq '^'){
				$CODE .= '@WORK_QUEUE_COPY = @QUEUE;'."\n";
				$CODE .= '$BUFFER = shift @WORK_QUEUE_COPY;'."\n";
				$CODE .= 'foreach my $we (@WORK_QUEUE_COPY){'."\n";
				$CODE .= '	$BUFFER = $BUFFER ** $we;'."\n";
				$CODE .= '}'."\n";
				$CODE .= '@WORK_QUEUE_COPY = ();'."\n";
				$CODE .= 'if($BUFFER){}else{ $BUFFER = 0; }'."\n";
				next;
			}

			# |===|
			# | / |
			# |===|
			# Divides all values in queue, in sequence, and saves result to buffer
			if($cmd eq '/'){
				$CODE .= '@WORK_QUEUE_COPY = @QUEUE;'."\n";
				$CODE .= '$BUFFER = shift @WORK_QUEUE_COPY;'."\n";
				$CODE .= 'foreach my $we (@WORK_QUEUE_COPY){'."\n";
				$CODE .= '	$BUFFER = $BUFFER / $we;'."\n";
				$CODE .= '}'."\n";
				$CODE .= '@WORK_QUEUE_COPY = ();'."\n";
				$CODE .= 'if($BUFFER){}else{ $BUFFER = 0; }'."\n";
				next;
			}

			# |===|
			# | - |
			# |===|
			# Subtracts all values in queue, in sequence, and saves result to buffer
			if($cmd eq '-'){
				$CODE .= '@WORK_QUEUE_COPY = @QUEUE;'."\n";
				$CODE .= '$BUFFER = shift @WORK_QUEUE_COPY;'."\n";
				$CODE .= 'foreach my $we (@WORK_QUEUE_COPY){'."\n";
				$CODE .= '	$BUFFER = $BUFFER - $we;'."\n";
				$CODE .= '}'."\n";
				$CODE .= '@WORK_QUEUE_COPY = ();'."\n";
				$CODE .= 'if($BUFFER){}else{ $BUFFER = 0; }'."\n";
				next;
			}

			# |===|
			# | # |
			# |===|
			# Performs a modulus on all values in queue, in sequence, and saves result to buffer
			if($cmd eq '#'){
				$CODE .= '@WORK_QUEUE_COPY = @QUEUE;'."\n";
				$CODE .= '$BUFFER = shift @WORK_QUEUE_COPY;'."\n";
				$CODE .= 'foreach my $we (@WORK_QUEUE_COPY){'."\n";
				$CODE .= '	$BUFFER = $BUFFER % $we;'."\n";
				$CODE .= '}'."\n";
				$CODE .= '@WORK_QUEUE_COPY = ();'."\n";
				$CODE .= 'if($BUFFER){}else{ $BUFFER = 0; }'."\n";
				next;
			}

			# |===|
			# | { |
			# |===|
			# Begins an infinite loop
			if($cmd eq '{'){
				$IS_IN_LOOP++;
				$CODE .= 'while(){'."\n";
				next;
			}

			# |===|
			# | } |
			# |===|
			# Ends a loop
			if($cmd eq '}'){
				if($IS_IN_LOOP>0){
					$IS_IN_LOOP--;
					$CODE .= '}'."\n";
					next;
				} else {
					print "Error: Loop termination symbol without loop\n";
					if($shell){}else{
						exit 1;
					}
					next;
				}
			}

			# |===|
			# | ) |
			# |===|
			# Ends a conditional block
			if($cmd eq ')'){
				if($IS_IN_CONDITIONAL>0){
					$IS_IN_CONDITIONAL--;
					$ELSE_COUNT = 0;
					$CONDITIONAL_VALUE = 0;
					$CODE .= '}'."\n";
					next;
				} else {
					print "Error: Conditional termination symbol without conditional\n";
					if($shell){}else{
						exit 1;
					}
					next;
				}
			}

			# |===|
			# | ~ |
			# |===|
			# Branches a conditional block ("else") with conditions
			if($cmd eq '~'){
				if($IS_IN_CONDITIONAL>0){
					if($ELSE_COUNT==0){
						$ELSE_COUNT++;
						$CODE .= '} elsif($BUFFER>'.$CONDITIONAL_VALUE.'){'."\n";
						next;
					}elsif($ELSE_COUNT==1){
						$ELSE_COUNT++;
						$CODE .= '} elsif($BUFFER<'.$CONDITIONAL_VALUE.'){'."\n";
						next;
					}else{
						print "Error: No more branches can be implemented\n";
						if($shell){}else{
							exit 1;
						}
						next;
					}
				} else {
					print "Error: Conditional else-if symbol without conditional\n";
					if($shell){}else{
						exit 1;
					}
					next;
				}
			}

			# |===|
			# | ' |
			# |===|
			# If we're in a loop, exit it
			if($cmd eq "'"){
				if($IS_IN_LOOP>0){
					$CODE .= 'last;'."\n";
				} else {
					print "Error: No loop to exit\n";
					if($shell){}else{
						exit 1;
					}
				}
				next;
			}

			# |===|
			# | " |
			# |===|
			# Branches a conditional block ("else")
			if($cmd eq '"'){
				if($IS_IN_CONDITIONAL>0){
					$CODE .= '} else {'."\n";
					next;
				} else {
					print "Error: Conditional else symbol without conditional\n";
					if($shell){}else{
						exit 1;
					}
					next;
				}
			}

			# |================|
			# | ERROR HANDLING |
			# |================|

			if($cmd eq '('){
				print "Error: Conditional symbol without argument (no condition to test)\n";
				if($shell){}else{
					exit 1;
				}
				next;
			}

			print "Error:  Command \"$cmd\" not recognized\n";
			if($shell){}else{
				exit 1;
			}

		} else {

			# |=========================|
			# | COMMANDS WITH ARGUMENTS |
			# |=========================|

			my $command = substr($cmd,0,1);
			my $argument = substr($cmd,1);

			# |===|
			# | ( |
			# |===|
			# Begins a conditional
			# The argument passed to this command is compared to the buffer;
			# if the argument and the buffer value are equal, the conditional
			# block is executed
			if($command eq '('){
				if(is_number($argument)){
					$CODE .= 'if ($BUFFER=='.$argument.') {'."\n";
					$IS_IN_CONDITIONAL++;
					$CONDITIONAL_VALUE = $argument;
					next;
				}else{
					print "Error:  \"$argument\" is not an integer\n";
					if($shell){}else{
						exit 1;
					}
					next;
				}
			}

			# |===|
			# | { |
			# |===|
			# Begin a loop
			# The argument passed to this command sets how many times
			# the loops is repeated
			if($command eq '{'){
				if(is_number($argument)){
					$CODE .= 'for (my $COUNTER = '.$argument.'; $COUNTER >= 1; $COUNTER--) {'."\n";
					$IS_IN_LOOP++;
					next;
				}else{
					print "Error:  \"$argument\" is not an integer\n";
					if($shell){}else{
						exit 1;
					}
					next;
				}
			}
			
			# |===|
			# | > |
			# |===|
			# Adds a value to the end of the queue
			# The argument passed to this command sets what value is added
			if($command eq '>') {
				if(is_number($argument)){
					$CODE .= 'push(@QUEUE,'.$argument.');'."\n";
					next;
				}else{
					print "Error:  \"$argument\" is not an integer\n";
					if($shell){}else{
						exit 1;
					}
					next;
				}
				
			}

			# |===|
			# | $ |
			# |===|
			# Prints text
			# The argument passed to this command is converted to ASCII and printed
			if($command eq '$') {
				if(is_number($argument)){
					if(($argument<0)||($argument>255)){
						print "Error:  \"$argument\" is not a valid ASCII code\n";
						if($shell){}else{
							exit 1;
						}
						next;
					}
					$CODE .= 'print chr('.$argument.');'."\n";
					next;
				}else{
					print "Error:  \"$argument\" is not an integer\n";
					if($shell){}else{
						exit 1;
					}
					next;
				}
				
			}

			# |================|
			# | ERROR HANDLING |
			# |================|

			print "Error:  Command \"$command\" not recognized\n";
			if($shell){}else{
				exit 1;
			}
			
		}
	}

	# "close" any open loops or conditionals

	if($IS_IN_LOOP>0){
		for (my $c = $IS_IN_LOOP; $c >= 1; $c--) {
			$CODE .= '}'."\n";
		}
	}
	if($IS_IN_CONDITIONAL>0){
		for (my $c = $IS_IN_CONDITIONAL; $c >= 1; $c--) {
			$CODE .= '}'."\n";
		}
	}

	# return the compiled code
	return $CODE;
}

# tokenize
# Arguments: 1 (scalar)
# Returns:  nothing
# Description:  Tokenizes QUNT code for compilation with the compile() subroutine.
#               Tokens are placed in the global array @TOKENS.
sub tokenize {
	my $c = shift;

	if(length($c)<0){ return; }

	my $BUFFER = '';
	my $IN_SYMBOL = undef;

	# reset the token list
	@TOKENS = ();

	# set the symbol list (the commands used by QUNT)
	my @SYMBOLS = ('?','<','>','*',':','+','-','/','&','^','@','$','%','{','}','(',')','~',';','|','`','!','.','#',"'",'"');

	# clean up the input
	$c =~ s/\s//g;	# strip all spaces
	$c =~ s/\n//g;	# strip all newlines

	# split input into individual characters, and step through them
	foreach my $l (split(//,$c)) {
		
		my $FOUND_SYMBOL = undef;

		# step through the symbol list
		foreach my $s (@SYMBOLS){
			# if we find a symbol, mark it as found
			if($l eq $s) {
				# if there's something in the buffer, push it onto the token list
				if($BUFFER ne "") { push(@TOKENS,$BUFFER); }  $BUFFER = $s;
				# mark the symbol as found
				$IN_SYMBOL = 1;
				$FOUND_SYMBOL = 1;
			}
		}
		# if we found a symbol, move to the next character
		if($FOUND_SYMBOL){
			$FOUND_SYMBOL = undef;
			next;
		}
		# add to the buffer;  this allows symbols/commands to have arguments
		$BUFFER .= $l;
	}

	# if we've got anything left in the buffer, add it to the token list
	if(length($BUFFER)>=0){ push(@TOKENS,$BUFFER); }
}

# |-------------------------|
# | SUPPORT SUBROUTINES END |
# |-------------------------|

# |------------------------------------|
# | EXECUTOR STUB FOR COMPILER FOLLOWS |
# |------------------------------------|

__DATA__
#!/usr/bin/perl
#  _____ _____ _____ _____ 
# |     |  |  |   | |_   _|
# |  |  |  |  | | | | | |  
# |__  _|_____|_|___| |_|  
#    |__|
#
# QUNT Compiler v0.053
# This program is the output of a compiler; please don't edit it

use strict;
use warnings;

my @QUEUE = (); my @WORK_QUEUE_COPY = (); my $BUFFER = 0;

sub qunt_is_number {
	my $n = shift;

	if ($n=~/^\d+$/) { return 1; } if ($n=~/^-?\d+$/) { return 1; }
	if ($n=~/^[+-]?\d+$/) { return 1; } if ($n=~/^-?\d+\.?\d*$/) { return 1; }
	if ($n=~/^-?(?:\d+(?:\.\d*)?|\.\d+)$/) { return 1; } 
	if ($n=~/\D/) { return undef; } return undef;
}


