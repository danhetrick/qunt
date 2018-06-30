![QUNT](https://github.com/danhetrick/qunt/blob/media/qunt_logo.png?raw=true)

	* qunt.pl
		* The QUNT Compiler/Interpreter
	* LICENSE
		* [BSD 2-Clause](#license)
	* README.md
	* docs/
		* qunt.pdf
			* A PDF version of README.md
		* cheatsheet.txt
			* A text file with a list of all 26 **QUNT** commands along with usage text.
	* examples/
		* [examples/average.q](#calculate-average)
		* [examples/celsius.q](#celsius-to-fahrenheit-converter)
		* [examples/fibonacci.q](#fibonacci-sequence-generator)
		* [examples/greater.q](#which-version-is-larger-version-one)
		* [examples/greater2.q](#which-version-is-larger-version-two)

# Summary

**QUNT** (pronounced *"kyūnt"*, not...the other way) is an esoteric programming language influenced by Brainfuck.  It features 26 different commands, uses a "queue" metaphor for data manipulation, and has very terse syntax.  For example, here's a Fibonacci sequence generator written in **QUNT**.  It will generate and display the first 10 iterations of the sequence:

    >0&?>1&?+?:{7<+?:}

**QUNT** programs can be executed with `qunt.pl`, either by using the `run` commandline argument, or by piping code to the script.  For example, if you have a **QUNT** program saved in a file named `myprogram.q`, you can execute the program with

	perl qunt.pl run myprogram.q

or

	cat myprogram.q | perl qunt.pl

**QUNT** code can also be compiled to a stand-alone Perl script (that is, a script that doesn't need `qunt.pl` to execute).  To compile, run `qunt.pl` with the program's filename as the only argument.  All compiled code is printed to STDOUT.  To compile the **QUNT** program `myprogram.q` to Perl:

	perl qunt.pl myprogram.q >> myprogram.pl

`qunt.pl` requires Perl, and will run in any environment that can run Perl.  Tested on Windows 7, Windows 8, Windows 8.1, Windows 10, Debian Linux, and Ubuntu Linux.

Compiled **QUNT** programs will run in any environment that can run Perl;  they require nothing except a Perl installation.

# Table of Contents

* [qunt.pl](#qunt.pl)
* [The QUNT Compiler](#the-qunt-compiler)
* [The Queue](#the-queue)
* [The Buffer and Conditionals](#the-buffer-and-conditionals)
* [Displaying Text](#displaying-text)
* [The QUNT Shell](#the-qunt-shell)
* [User Input](#user-input)
* [Examples](#examples)
	* [Fibonacci Sequence Generator](#fibonacci-sequence-generator)
	* [Celsius to Fahrenheit Converter](#celsius-to-fahrenheit-converter)
	* [Which Number is Larger Version One](#which-version-is-larger-version-one)
	* [Which Number is Larger Version Two](#which-version-is-larger-version-two)
	* [Calculate Average](#calculate-average)
* [QUNT Commands](#qunt-commands)
* [License](#license)

# qunt.pl

	QUNT Compiler/Interpreter 0.053

	Usage: perl qunt.pl [ARGUMENT] [FILENAME]
	Execute with "run" as the first argument, followed by a filename, to compile and run a QUNT program.

	Execute without argument to start interactive shell.

	Execute with "debug" as argument to show generated code in interactive shell.

	To convert text into QUNT code, execute with the argument "text", followed by
	the text to convert.  All compiled/generated code is printed to STDOUT.

# The QUNT Compiler

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

# The Queue

**QUNT** is based around the "queue":  a sequence of numbers, of variable length, that is manipulated and operated upon.  Besides the queue, QUNT features a "buffer";  the results of mathematical operations is stored in the buffer, buffer values can be added to the queue, and queue values can be stored in the buffer.   Initially, the buffer is set to zero.  This is the core concept of **QUNT**.  The only command that does not operate on either the queue or the buffer is the `$` command, which is used to display text (see [Displaying Text](#displaying-text), below).

Think of the queue as a list of numbers.  You can print these numbers, or perform mathematical operations on them.  Math works differently in QUNT than in other programming languages.  All math operations are performed on the entire queue, rather than on one or two values at a time.  For example, addition is fairly normal.  Given a queue with the values `[1,2,3]`, if we perform the addition operation (with the `+` command), the result "6" will be stored in the buffer;  that is, "1+2+3 = 6". Things get a little stranger when we use other mathematical operations.  Given a queue with the values `[3,2,3]`, if we were to perform the exponential operation (with the `^` command), the result "729" will be stored in the buffer.  That's because "(32)^3 = 729".  Each operation is performed on every value in the queue, in sequence.

Let's try another example, this time with the subtraction command, `-`.  Given a queue with the values `[10,5,3,2]`, if we issue the `-` command, we end up with the result "0" in the buffer, because "(((105)-3)-2) = 0".

The division command, `/`, works like the others.  Given a queue with the values `[10,5,1]`, if we issue the `/` command, we end up with "2" in the buffer, because "((10/5)/1) = 2".

# The Buffer and Conditionals

_**All command results that do not directly manipulate the contents of the queue are stored in the buffer.**_  So, the results of all mathematical operations are stored in the buffer.  Conditional statements, that is, "if...then" statements, compare a given value to the buffer.  For example, let's write a program that does a math operation, and displays text depending on what the output is.  Our program will calculate "2+2", and display a message if the answer is "4", and a different message if it is not:

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

# Displaying Text

Because all command arguments must be numbers, displaying text in **QUNT** can be difficult.  The `$` command is used for this;  the command converts its argument from an ASCII code to an ASCII character, and displays it.  To make it easier to display text, the compiler/shell has a special commandline mode.  If `qunt.pl` is passed the argument "text", followed by the text to convert, it will generate **QUNT** code to display the desired text.  For example:

	localhost:~ user$ qunt.pl text Hello, world!
	$72$101$108$108$111$44$32$119$111$114$108$100$33
	localhost:~ user$ 

The code generated will display "Hello, world!".

# The QUNT Shell

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

# User Input

**QUNT** programs can get user input by using the `.` command.  When used, this will allow the user to type in a number;  this number will be stored in the buffer, where it can be placed in the queue, displayed, etc.  For example, let's write a program that accepts user input;  it will get three numbers from the user, and then display the average of those numbers:

	$80$108$101$97$115$101$32$116$121$112$101$32$105$110$32$116$104$114$101$101$32$110
	$117$109$98$101$114$115$58$10.:.:.:+@:>3/$84$104$101$32$97$118$101$114$97$103$101
	$32$111$102$32$116$104$101$115$101$32$110$117$109$98$101$114$115$32$105$115$32?

Save the complete program to a file named `average.q`, and run it:

	localhost:~ user$ qunt.pl run average.q
	Please type in three numbers:
	1
	2
	3
	The average of these numbers is 2
	localhost:~ user$ 

# Examples

All of the programs featured here can be found in the `examples` directory.

## Fibonacci Sequence Generator

Here are some examples of **QUNT** code.  The first example is a *Fibonacci Sequence* generator.  It will display a welcome message, then generate and display the first 10 iterations of the sequence:

	$84$104$105$115$32$119$105$108$108$32$103$101$110$101$114$97$116$101$32$116$104$101
	$32$102$105$114$115$116$32$116$101$110$32$105$116$101$114$97$116$105$111$110$115
	$32$111$102$32$116$104$101$32$70$105$98$111$110$97$99$99$105$32$83$101$113$117$101
	$110$99$101$32$97$110$100$32$100$105$115$112$108$97$121$32$116$104$101$109$58$10>0&
	?>1&?+?:{7<+?:

If saved to a file named `fibonacci.q` and executed, this produces:

	localhost:~ user$ qunt.pl run fibonacci.q
	This will generate the first ten iterations of the Fibonacci Sequence and display them:
	0
	1
	1
	2
	3
	5
	8
	13
	21
	34
	localhost:~ user$

## Celsius to Fahrenheit Converter

Our second example is a program that converts a number into from Celsius to Fahrenheit degrees.  The only flaw in the program is that if you try to convert "0", it will display an error message and exit.

	$69$110$116$101$114$32$84$101$109$112$58$.
	(0$69$114$114$111$114$33$32$73$110$112$117$116$32$99$97$110$110$111$116$32$98$101
	$32$101$120$97$99$116$108$121$32$122$101$114$111$10!) $67$101$108$99$105$117$115$58
	:>32-|:>5*||;/<`% $70$97$104$114$101$110$104$101$105$116$58;>9*@;>5/@;>32+@;%!

If saved to a file named `celsius.q` and executed, this produces:

	localhost:~ user$ qunt.pl run degrees.q
	Enter Temp:32
	Celcius:32
	Fahrenheit:89.6
	localhost:~ user$

`celsius.q` was written by Will Munslow, and submitted via an Internet forum.

## Which Number is Larger Version One

Our third example is a clever program that takes two numbers in as input, and determines which one of the numbers is larger, or if the two values are equal.  This is probably the most complicated program in the manual, and was written before the comparison operator `~` was created:

	$101$110$116$101$114$32$102$105$114$115$116$32$118$97$108$117$101$46$46$46$46$32.
	$101$110$116$101$114$32$115$101$99$111$110$100$32$118$97$108$117$101$46$46$46$32
	:.:(0 $116$104$101$32$110$117$109$98$101$114$115$32$97$114$101$32$101$113$117$97
	$108$46$ 13$10! ) >0&;-:>0<< { (0 +(0 >0>0>1&|<< " >1>0&| ) ) (1 +(0 >2&|<< " >1&
	) ) (2 &(0 +$109$97$120$61?! ) `(0 +$109$97$120$61?! ) >3&||<>0 ) (3 `:<& (0 >1&|
	;&|;>4&| " >3&| ) ) (4 &| (0 >2&| " ;>4&| ) )  }

If saved to a file named `greater.q` and executed, this produces:

	localhost:~ user$ qunt.pl run greater.q
	enter first value.... 25
	enter second value... 50
	max=50 localhost:~ user$ 

Please note that if especially large numbers are entered, it may take the program some time to determine which value is greater.  However, if you let it run long enough, it will produce the right result.

`greater.q` was written by Léon Planken, and was submitted via an Internet forum.

## Which Number is Larger Version Two

Since the creation of the ~ operator, Mr. Planken has a written a newer, easier to understand version of `greater.q`:

	$101$110$116$101$114$32$102$105$114$115$116$32$118$97$108$117$101$46$46$46$46$32.:
	$101$110$116$101$114$32$115$101$99$111$110$100$32$118$97$108$117$101$46$46$46$32.:
	(0$116$104$101$32$110$117$109$98$101$114$115$32$97$114$101$32$101$113$117$97$108$4
	6$13$10!) $109$97$120$61(0~`~&)?

The performs the same thing as the previous version, only done much more simply.  It also works much faster than the previous version, even with very large numbers.  If saved to a file named `greater2.q`and executed, this produces:

	localhost:~ user$ qunt.pl run greater2.q
	enter first value.... 10
	enter second value... 9
	max=10
	localhost:~ user$

`greater2.q` was written by Léon Planken, and was submitted via an Internet forum.

## Calculate Average

The fifth example takes in any number of numbers, calculates their average, and displays it to the user.

	$101$110$116$101$114$32$110$117$109$98$101$114$115$44$32$111$110$101$32$112$101
	$114$32$108$105$110$101$44$32$101$110$100$32$119$105$116$104$32$48$13$10
	>0{.(0'):>1&|;}
	&(0$110$111$32$110$117$109$98$101$114$115$32$101$110$116$101$114$101$100$13$10)
	>0&;-:
	<{`(0')<}
	-:
	<{`(0')<}
	-:<<`<:/ $97$118$101$114$97$103$101$61?

If saved to a file named `average.q` and executed, this produces:

	localhost:~ user$ qunt.pl run average.q
	enter numbers, one per line, end with 0
	355
	123
	55
	0
	average=177.666666666667
	localhost:~ user$

`average.q` was written by Léon Planken, and was submitted via an Internet forum.

# QUNT Commands

There are 26 different commands/operators in **QUNT**.  All whitespace in a **QUNT** program is ignored.  All command arguments must be numeric.  Arguments are placed directly after the command;  for example, to initiate a loop that will execute 3 times, you would use `{3`.

	╔═════════╦═══════════════════╦══════════════════════════════════════════════════════════════════════╗
	║ Command ║ Accepts Arguments ║                              Description                             ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    .    ║ No                ║ Gets input from the user and stores it in the buffer.                ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    !    ║ No                ║ Exits the program.                                                   ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    %    ║ No                ║ Prints the contents of the queue; each queue value is followed by    ║
	║         ║                   ║ a newline.                                                           ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    $    ║ Yes               ║ The argument to this command is an ASCII code, which is converted    ║
	║         ║                   ║ to an ASCII character and printed.                                   ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    <    ║ No                ║ Removes the first value from the queue.                              ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    |    ║ No                ║ Removes the last value from the queue.                               ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    &    ║ No                ║ Sets the buffer to the last queue value.                             ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    `    ║ No                ║ Sets the buffer to the first queue value.                            ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    :    ║ No                ║ Adds the buffer value to the end of the queue, and resets the buffer ║
	║         ║                   ║ to zero.                                                             ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    ;    ║ No                ║ Adds the buffer value to the beginning of the queue, and resets the  ║
	║         ║                   ║ buffer to zero.                                                      ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    ?    ║ No                ║ Prints the buffer value, followed by a newline.                      ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    @    ║ No                ║ Clears the queue.                                                    ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    +    ║ No                ║ Adds all values in the queue in sequence.                            ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    *    ║ No                ║ Multiplies all values in the queue in sequence.                      ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    ^    ║ No                ║ Exponentiates all values in the queue in sequence.                   ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    /    ║ No                ║ Divides all values in the queue in sequence.                         ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    -    ║ No                ║ Subtracts all values in the queue in sequence.                       ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    #    ║ No                ║ Performs a modulus operation on all values in the queue in           ║
	║         ║                   ║ sequence.                                                            ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    {    ║ Optional          ║ Begins a loop.  If an argument is passed to the command,             ║
	║         ║                   ║ the loop will be repeated a number of times equal to                 ║
	║         ║                   ║ the argument. If no argument is passed, the loop will                ║
	║         ║                   ║ be infinite.                                                         ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    }    ║ No                ║ Ends a loop.                                                         ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    '    ║ No                ║ Exits a loop.                                                        ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    (    ║ Yes               ║ Begins a conditional code block.  The block will only be             ║
	║         ║                   ║ executed if the buffer is equal to the value passed as               ║
	║         ║                   ║ an argument to the command.                                          ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    )    ║ No                ║ Ends a conditional code block.                                       ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    ~    ║ No                ║ Branches a conditional code block.  The first time it is             ║
	║         ║                   ║ f the buffer is greater than the original condition. The             ║
	║         ║                   ║ second time it is called within a conditional block, the             ║
	║         ║                   ║ code following will be executed if the buffer is less than           ║
	║         ║                   ║ the original condition.                                              ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    "    ║ No                ║ Branches a conditional code block ("else").                          ║
	╠═════════╬═══════════════════╬══════════════════════════════════════════════════════════════════════╣
	║    >    ║ Yes               ║ Adds a value to the end of the queue.  The argument                  ║
	║         ║                   ║ passed to it is the value added to the queue.                        ║
	╚═════════╩═══════════════════╩══════════════════════════════════════════════════════════════════════╝

# License

Copyright (c) 2018, Daniel Hetrick
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE
