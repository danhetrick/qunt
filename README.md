# QUNT - The Queue for Numeric Transformation

## Table of Contents

* [The QUNT Compiler](#the-qunt-compiler)
* [The Queue](#the-queue)
* [The Buffer and Conditionals](#the-buffer-and-conditionals)
* [Displaying Text](#displaying-text)
* [The Shell](#the-shell)
* [User Input](#user-input)

## Summary

**QUNT** (pronounced *"kyūnt"*, not...the other way) is an esoteric programming language influenced by Brainfuck.  It features 26 different commands, uses a "queue" metaphor for data manipulation, and has very terse syntax.  It features 26 different commands, uses a "queue" metaphor for data manipulation, and has very terse syntax.  For example, here's a Fibonacci sequence generator written in **QUNT**.  It will generate and display the first 10 iterations of the sequence:

    >0&?>1&?+?:{7<+?:}

## The QUNT Compiler

The official **QUNT Compiler/Interpreter**, `qunt.pl`, is written in Perl, and requires a default installation of Perl to run it and the compiled code produced by it. If called without any arguments, `qunt.pl` enters shell mode, where you can enter **QUNT** commands or statements and have them immediately executed.

The shell is the easiest way to write, debug, and test **QUNT** code. Tools are provided to execute code, view code that has been previously written, and write entered code to file.

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

If `qunt.pl` is executed with the word `debug` as the only argument, it will still enter shell mode, only it will display the Perl code generated by each **QUNT** command/statement, as well as executing the compiled code.  For example, given the **QUNT** statement `>1>1+?` (which adds 1 and 1 together, and prints the result), this would be displayed in the shell:

	. >1>1+?
	*     push(@QUEUE,1);
	*     push(@QUEUE,1);
	*     $BUFFER = 0;
	*     foreach my $e (@QUEUE){
	*     $BUFFER += $e; * }
	*     if($BUFFER){}else{ $BUFFER = 0; }
	*     print $BUFFER."\n";
	 
	2

If a valid filename is passed as an argument to `qunt.pl`, the **QUNT** code contained in that file is compiled to Perl, and the resulting code is printed to STDOUT.  If the code in the last example were saved to a file named `oneandone.q`, you could compile it with:

	localhost:~ user$ qunt.pl oneandone.q
	#  _____ _____ _____ _____
	# |     |  |  |   | |_   _|
	# |  |  |  |  | | | | | |  
	# |__  _|_____|_|___| |_|
	#    |__|
	# QUNT Compiler v0.053
	# This program is the output of a compiler; please don't edit it

	use strict;
	use warnings;

	my @QUEUE = (); my @WORK_QUEUE_COPY = (); my $BUFFER = 0;

	sub qunt_is_number {
		my $n = shift;

		if ($n=~/^\d+$/) { return 1; }
		if ($n=~/^-?\d+$/) { return 1; }
		if ($n=~/^[+-]?\d+$/) { return 1; }
		if ($n=~/^-?\d+\.?\d*$/) { return 1; }
		if ($n=~/^-?(?:\d+(?:\.\d*)?|\.\d+)$/) { return 1; }
		if ($n=~/\D/) { return undef; } return undef;
	}
	push(@QUEUE,1);
	push(@QUEUE,1);
	$BUFFER = 0;
	foreach my $e (@QUEUE){
		$BUFFER += $e;
	}
	if($BUFFER){}else{ $BUFFER = 0; }
	print $BUFFER."\n";

	localhost:~ user$

A **QUNT** program can also be directly interpreted, without having to pipe it to Perl, by using the `run` argument to `qunt.pl`.  Execute `qunt.pl` with the word `run` as the first argument, and the filename of the program you want to interpret as the second.  If you're having trouble remembering all these command-line options, you can execute `qunt.pl` with the world `help` as the only argument to display usage information.

Piping code to `qunt.pl` is possible.  Any code piped to `qunt.pl` is immediately interpreted, rather than compiled to source.

## The Queue

**QUNT** is based around the "queue":  a sequence of numbers, of variable length, that is manipulated and operated upon.  Besides the queue, QUNT features a "buffer";  the results of mathematical operations is stored in the buffer, buffer values can be added to the queue, and queue values can be stored in the buffer.   Initially, the buffer is set to zero.  This is the core concept of **QUNT**.  The only command that does not operate on either the queue or the buffer is the `$` command, which is used to display text (see *Displaying Text*, below).

Think of the queue as a list of numbers.  You can print these numbers, or perform mathematical operations on them.  Math works differently in QUNT than in other programming languages.  All math operations are performed on the entire queue, rather than on one or two values at a time.  For example, addition is fairly normal.  Given a queue with the values `[1,2,3]`, if we perform the addition operation (with the `+` command), the result "6" will be stored in the buffer;  that is, "1+2+3 = 6". Things get a little stranger when we use other mathematical operations.  Given a queue with the values `[3,2,3]`, if we were to perform the exponential operation (with the `^` command), the result "729" will be stored in the buffer.  That's because "(32)^3 = 729".  Each operation is performed on every value in the queue, in sequence.

Let's try another example, this time with the subtraction command, `-`.  Given a queue with the values `[10,5,3,2]`, if we issue the `-` command, we end up with the result "0" in the buffer, because "(((105)-3)-2) = 0".

The division command, `/`, works like the others.  Given a queue with the values `[10,5,1]`, if we issue the `/` command, we end up with "2" in the buffer, because "((10/5)/1) = 2".

## The Buffer and Conditionals

All command results that do not directly manipulate the queue are stored in the buffer.  Conditional statements, that is, "if...then" statements, compare a given value to the buffer.  For example, let's write a program that does a math operation, and displays text depending on what the output is.  Our program will calculate "2+2", and display a message if the answer is "4", and a different message if it is not:

	>2>2+(4$84$104$101$97$110$115$119$101$114$119$97$115$102$111$117$114$10$"@$84$104
	$101$97$110$115$119$101$114$119$97$115$110$111$116$102$111$117$114$10)

Save this to a file named `twoandtwo.q`.  If we compile and execute the program, this is what happens:

	localhost:~ user$ qunt.pl run twoandtwo.q
	The answer was four
	localhost:~ user$

If the value had *not* been four, it would have printed "The answer was not four".

The `~` command works differently depending on how many times it has been called inside a conditional statement.  The first time it is called, it will execute the code following if the buffer is greater than the original condition.  The second time it is called, it will execute the code following if the buffer is less than the original condition.  For example, let's write a program that adds 1+1;  if the result is "2", it will print the result.  If the result is greater than "2", it will print the queue contents.  If the result is less than two, it will exit without printing anything:

	>1>1+(2?~%~!)

In pseudocode:

	Push "1" onto the queue
	Push "1" onto the queue
	Perform an add operation
	If the result is 2, print the buffer
	If the result is greater than two, print the queue contents
	If the result is less than two, exit

For a simple "else" branch, use the `"` command.  For example, let's write a program that adds 1 and 1 together, and displays the queue contents if the answer is "2", and exits if not:

	>1>1+(2%"!)

## Displaying Text

Because all command arguments must be numbers, displaying text in **QUNT** can be difficult.  The $ command is used for this;  the command converts its argument from an ASCII code to an ASCII character, and displays it.  To make it easier to display text, the compiler/shell has a special commandline mode.  If `qunt.pl` is passed the argument "text", followed by the text to convert, it will generate **QUNT** code to display the desired text.  For example:

	localhost:~ user$ qunt.pl text Hello, world!
	$72$101$108$108$111$44$32$119$111$114$108$100$33
	localhost:~ user$ 

The code generated will display "Hello, world!".

## The Shell

For writing and testing **QUNT** code, the shell can be a useful asset.  With the shell, you can write code and execute it immediately, without having to compile it or write it to file.  The shell features two special commands, `dump` and `clear`.  With the `dump` command, you can display all the code you've entered before and optionally write it to file.  To simply display what code you've previously entered, enter the `dump` command without any arguments:

	. >1>1+?
	2
	. dump
	>1>1+?

To write the previously entered code to a file, just pass a filename as the first argument to the `dump` command.  For example, to write the code in the last example to a file named `oneandone.q`, you could do:

	. >1>1+?
	2
	. dump oneandone.q
	Wrote dumped code to oneandone.q 
	.

The **QUNT** shell features one more command:  `clear`.  This deletes all the code that was previously entered (every time you enter **QUNT** code into the shell, it is saved;  this makes it easier to grab a list of commands that you might want to use in a program).

## User Input
