This is a project of ECE341 course

Our task is simulate polish notation in mips.

Given an input file, we should generate a Prefix.txt/Postfix.txt for storing the decode expression

and Result.txt for storing calculated result.

Eg:Given a input.txt with format below
#----------------------------------------------------------#
Prefix

(2+3)*5

4*12/3+1

5*(2+3)

*Output

Prefix.txt 

\* + 2 3 5 

\* 4 + / 12 3 1 
\* 5 + 2 3 
#----------------------------------------------------------#
Result.txt

25

17

25
