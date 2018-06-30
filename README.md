qunt
====

QUNT (pronounced "kyūnt", not...the other way) is an esoteric programming language influenced by Brainfuck.  It features 26 different commands, uses a "queue" metaphor for data manipulation, and has very terse syntax.  It features 26 different commands, uses a "queue" metaphor for data manipulation, and has very terse syntax.  For example, here's a Fibonacci sequence generator written in QUNT.  It will generate and display the first 10 iterations of the sequence:

    >0&?>1&?+?:{7<+?:}

The official QUNT Compiler/Interpreter, qunt.pl, is written in Perl, and requires a default installation of Perl to run it and the compiled code produced by it.  If called without any arguments, qunt.pl enters shell mode, where you can enter QUNT commands or statements and have them immediately executed.

The shell is the easiest way to write, debug, and test QUNT code.  Tools are provided to execute code, view code that has been previously written, and write entered code to file.


