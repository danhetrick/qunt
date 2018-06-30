# qunt

QUNT (pronounced "kyūnt", not...the other way) is an esoteric programming language influenced by Brainfuck.  It features 26 different commands, uses a "queue" metaphor for data manipulation, and has very terse syntax.  It features 26 different commands, uses a "queue" metaphor for data manipulation, and has very terse syntax.  For example, here's a Fibonacci sequence generator written in QUNT.  It will generate and display the first 10 iterations of the sequence:

    >0&?>1&?+?:{7<+?:}

The official QUNT Compiler/Interpreter, qunt.pl, is written in Perl, and requires a default installation of Perl to run it and the compiled code produced by it. If called without any arguments, qunt.pl enters shell mode, where you can enter QUNT commands or statements and have them immediately executed.

The shell is the easiest way to write, debug, and test QUNT code. Tools are provided to execute code, view code that has been previously written, and write entered code to file.

	localhost:~ user$ qunt.pl
	 _____ _____ _____ _____
	|     |  |  |   | |_   _|
	|  |  |  |  | | | | | |  
	|__  _|_____|_|___| |_|
	   |__|            v0.053

	QUNT Interactive Shell
	Enter QUNT commands to be executed, or "dump" to show entered code
	To write entered code to file, pass a filename as an argument to "dump"
	Use the command "clear" to delete entered code from memory
	.

If qunt.pl is executed with the word "debug" as the only argument, it will still enter shell mode, only it will display the Perl code generated by each QUNT command/statement, as well as executing the compiled code.  For example, given the QUNT statement >1>1+? (which adds 1 and 1 together, and prints the result), this would be displayed in the shell:

	. >1>1+?
	*     push(@QUEUE,1);
	*     push(@QUEUE,1);
	*     $BUFFER = 0;
	*     foreach my $e (@QUEUE){
	*     $BUFFER += $e; * }
	*     if($BUFFER){}else{ $BUFFER = 0; }
	*     print $BUFFER."\n";
	 
	2

blah