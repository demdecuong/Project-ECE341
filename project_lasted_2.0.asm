.data

file_loc: .asciiz "input.txt" 
buffer: .space 1024 #buffer of 1024
infix:	.word 1:50 
new_line: .asciiz "\n"  #whesre would I actually use this?
.align 2
input:  .space 2048 
.align 2
output: .space	2048
.align 2
stack: .space 2048
.align 2
res: .space 2048
.align 2
exp: .space 2048
	
temp_arr: .space 2048	
output2print: .space	2048 	#array for print
result2print:	.space	2048	#result arr for print
fout:   .asciiz "result.txt"      # filename for output
prefix_file: .asciiz "prefix.txt"
postfix_file: .asciiz "postfix.txt"


.text
main:
#jal openFile

openFile:
#Open file for for reading purposes
li $v0, 13          #syscall 13 - open file
la $a0, file_loc        #passing in file name
li $a1, 0               #set to read mode
li $a2, 0               #mode is ignored
syscall
move $s7, $v0           #else save the file descriptor

#Read input from file
li $v0, 14              #syscall 14 - read filea
move $a0, $s7           #sets $s0 as file descriptor
la $a1, buffer          #stores read info into buffer
li $a2, 1024            #hardcoded size of buffer
syscall         

la $s4,input
init:
	addi $t5,$zero,1 #isMinus = false
	la $t1,buffer    #t1 = buffer
	addi $s5,$zero,0 #s5 = input length
	addi $t1,$t1,6   #t1 = '\n' if buffer = Prefix or t1 = 'x' if buffer = 'Postfix'
	lb $t2,($t1)     
	seq $k0,$t2,'\n' #k0=1 if prefix
	beq $t2,'\n',inputFunc
	addi $t1,$t1,1   
inputFunc:
	addi $t1,$t1,1	   #buffer + 1
	lb $t2,($t1)       #t2 = a character
	#if isNum
	slti $t3,$t2,48	   #if t2 < 48 --> t3 = 1
	beq $t3,0,whileNum
	beq $t2,'\0',checkType     
	#addi $t2,$t2,24	   # operator r in dec
	beq $t2,45,isMinusCase
	sw $t2,($s4)
	addi $s4,$s4,4
	addi $s5,$s5,1     	#input length + 1	
	j inputFunc
isMinusCase:
	#beq ($s4),0,isMinusCaseManipulate
	addi $s4,$s4,-4 	# take input[i - 1]
	lw $t4,($s4)		
	addi $s4,$s4,4		
	beq $t4,'(' ,isMinusCaseManipulate
	beq $t4,'\n',isMinusCaseManipulate
	j inputFunc
isMinusCaseManipulate:
	addi $t4,$zero,'('
	sw $t4,($s4)		#Save "("
	addi $t4,$zero,100
	addi $t5,$zero,0	#isMinus = true
	addi $s4,$s4,4
	sw $t4,($s4)
	addi $s4,$s4,4
	sw $t2,($s4)		#Save "-"
	addi $s5,$s5,3     	#input length + 3
	addi $s4,$s4,4
	j inputFunc
endMinusCase:
	addi $t4,$zero,')'
	sw   $t4,($s4)
	addi $s5,$s5,1
	addi $s4,$s4,4
	addi $t5,$t5,1     	#isMinus = false	
	sw $t2,($s4)		#store operator ),+,-,/,(,*,/
	addi $s4,$s4,4
	addi $s5,$s5,1     	#input length + 1
	j inputFunc
endisNum:
	addi $t3,$t3,100
	sw $t3,($s4)
	addi $t3,$zero,0	#clear t3
	addi $s4,$s4,4
	addi $s5,$s5,1     	#input length + 1
	beq $t2,'0',checkType
	beq $t5,0,endMinusCase	#isMinus = true	
	sw $t2,($s4)		#store operator ),+,-,/,(,*,/
	addi $s4,$s4,4
	addi $s5,$s5,1     	#input length + 1
	j inputFunc
isNum:
	addi $t1,$t1,1		# buffer + 1
	lb $t2,($t1)		# buffer[t1]
	beq $t2,'\0',checkType
	slti $t6,$t2,48	   #if t2 < 48 --> t3 = 1
	beq $t6,1,endisNum
whileNum:	
	addi $t4,$zero,10
	sub $t2,$t2,48
	mul $t3,$t3,$t4 	#t3 *= 10
	add $t3,$t3,$t2		#t3 += ($t2)
	sw $t3,($s4)	
	j isNum
checkType:
	la $t1,buffer    #push buffer -> $t1    
	addi $t1,$t1,6
	lb $t2,($t1) 
	beq $t2,'\n',Prefix	#Prefix
	j Postfix

reverseStr:
	addi $sp,$sp,-28
	sw $ra,24($sp)
	sw $t4,20($sp)
	sw $t3,16($sp)
	sw $t2,12($sp)
	sw $t1,8($sp)
	sw $t0,4($sp)
	sw $s0,($sp)
	la $s4,input

	addi $t0,$zero,0	#t0 = left = 0
	add $t1,$zero,$s5	#t1 = right = s5
	mul $t1,$t1,4
	addi $t1,$t1,-4
	while:
	slt $s0,$t0,$t1		#t0 == t1
	beq $s0,0,returnRevStr
	lb $t4,input($t0)	#t4 = input[left]
	lb $t3,input($t1)  	#t3 = input[right]
	jal isBracket_left
	jal isBracket_right
	add $t2,$zero,$t4	#t2 = temp = input[left]
	sb $t3, input($t0)	#input[left] = input[right]
	sb $t2, input($t1)	#input[right] = temp
	addi $t0,$t0,4
	addi $t1,$t1,-4
	j while
isBracket_left:
	beq $t4,')',isBracket_l1
	beq $t4,'(',isBracket_l2
	jr $ra
isBracket_l1:
	addi $t4,$zero,'('
	jr $ra
isBracket_l2:
	addi $t4,$zero,')'
	jr $ra
isBracket_right:
	beq $t3,')',isBracket_r1
	beq $t3,'(',isBracket_r2
	jr $ra
isBracket_r1:
	addi $t3,$zero,'('
	jr $ra
isBracket_r2:
	addi $t3,$zero,')'
	jr $ra
	
returnRevStr:
	la $s0,input
	lw $ra,24($sp)
	lw $t4,20($sp)
	lw $t3,16($sp)
	lw $t2,12($sp)
	lw $t1,8($sp)
	lw $t0,4($sp)
	lw $s0,($sp)
	addi $sp,$sp,28
	add $v0,$s0,$zero
	jr $ra
# Algorithm section
	#jal reverseStr
#----------------------------Prefix-----------------------------------------#
Prefix:
la $t0,input
addi $a0,$s5,0
jal revStr
jal Postfix

#------------------------------revStr--------------------------------------#
revStr:#t0=begin of string,a0 length
mul $a0,$a0,4
add $a0,$t0,$a0 # a0=end of string
revl3:
addi $t1,$t0,0 #t1=t0
revl0:#while t1!=\n next t1
addi $t1,$t1,4 #next t1
lw $t2,($t1)
bne $t2,'\n',revl0
addi $t1,$t1,-4
#at this time t0 begin t1 end 
#revl1: swap string between t0 and t1
revl1:
lw $t2,($t0) #t2=a[t0]
lw $t3,($t1) #t3=a[t1]
beq $t2,'(',t20
beq $t2,')',t21
revi1:
beq $t3,'(',t30
beq $t3,')',t31
revi2:
sw $t2,($t1) #a[t1]=t2=a[t0] 
sw $t3,($t0) #a[t0]=t3=a[t1]
#swap end 
addi $t0,$t0,4
addi $t1,$t1,-4
#move t0 and t1
blt $t0,$t1,revl1 #loop revl1 if t0<t1
revl2:#while t0!=\n next t0
addi $t0,$t0,4 #next t0
lw $t2,($t0)
bne $t2,'\n',revl2
addi $t0,$t0,4
#at this time t0=begin of next experssion
blt $t0,$a0,revl3 # $t0<$a0 loop revl3
jr $ra

t20:
li $t2,')'
j revi1
t21:
li $t2,'('
j revi1
t30:
li $t3,')'
j revi2
t31:
li $t3,'('
j revi2
#--------------------------------------------------------------------------#
#----------------------Cal---------------------------------------------------#
cal:#input an expression string end with '\n' result store at -4($t6)
addi $sp,$sp,-8
sw $t0,-4($sp)
sw $ra,($sp)
la $t0,output
la $t6,stack
addi $t0,$t0,-4 # t0= begin of bieu thuc-1
loopCal:
addi $t0,$t0,4
lw $t1,($t0)
beq $t1,'\n',exitL2
beq $t1,'+',cplus
beq $t1,'-',cminus
beq $t1,'*',cmul
beq $t1,'/',cdiv
sw $t1,($t6) #push2stack 
addi $t6,$t6,4
j loopCal
exitL2:
lw $ra,($sp)
lw $t0,-4($sp)
addi $sp,$sp,8
addi $t6,$t6,-4
lw $t6,($t6)
sw $t6,($t9)
addi $t9,$t9,4
jr $ra

#helper functions for cal:
cplus:
jal loadOP
add $t2,$t2,$t3
jal pushResult
j loopCal
cminus:
jal loadOP
sub $t2,$t2,$t3
jal pushResult
j loopCal
cmul:
jal loadOP
mul $t2,$t2,$t3
jal pushResult
j loopCal
cdiv:
jal loadOP
div $t2,$t2,$t3
jal pushResult
j loopCal

loadOP:#load 2 operand and decoded
lw $t2,-8($t6)
lw $t3,-4($t6)
addi $t6,$t6,-8
blez $t2,lO1
addi $t2,$t2,-100
j lO11
lO1:
addi $t2,$t2,100
lO11:
blez $t3,lO2
addi $t3,$t3,-100
j lO21
lO2:
addi $t3,$t3,100
lO21:
jr $ra

pushResult:
bgez $t2,pR
addi $t2,$t2,-100
j pR1
pR:
addi $t2,$t2,100
pR1:
sw $t2,($t6)
addi $t6,$t6,4
jr $ra
#------------------Postfix-----------------------------------#

#input an infix string end with '\n', store postfix result at output
Postfix:#a0=vi tri bat dau bieu thuc,t1 & t2 doc token,t6 cur stack t7 cur output,t8 exp,t9 res
la $t8,exp
la $t9,res
mul $s5,$s5,4
addi $sp,$sp,-4
sw $ra,($sp)
la $t0,input #test
la $s2,stack
la $s3,output
add $s5,$s5,$t0
addi $t0,$t0,-4 # t0= begin of bieu thuc-1
loopB:
la $t6,stack
la $t7,output
loop:
addi $t0,$t0,4
bge $t0,$s5,endPos
lw $t1,($t0)
beq $t1,'\n',exitL
beq $t1,'+',pm
beq $t1,'-',pm
beq $t1,'*',md
beq $t1,'/',md
beq $t1,'(',lB
beq $t1,')',rB
sw $t1,($t7)
addi $t7,$t7,4
sw $t1,($t8)
addi $t8,$t8,4
j loop
exitL:#pop until stack empty:
ble $t6,$s2,finish
addi $t6,$t6,-4 #pop stack
lw $t2,($t6) #load top stack
sw $t2,($t7) #push to output
addi $t7,$t7,4
sw $t2,($t8)
addi $t8,$t8,4
j exitL
finish:
addi $t2,$zero,10 #add \n to end
sw $t2,($t7)
addi $t7,$t7,4
sw $t2,($t8)
addi $t8,$t8,4
jal cal
j loopB
endPos:
lw $ra,($sp)
addi $sp,$sp,4
la $t3,exp #t8=length exp
sub $t8,$t8,$t3
div $t8,$t8,4
la $t3,res #t9=length res
sub $t9,$t9,$t3
div $t9,$t9,4
beqz $k0,COND #if postfix than do nothing else rev output
la $t0,exp
addi $a0,$t8,0
jal revStr
COND:
j convert2Str#1 time function call no need 2 push $ra

#helper function for Postix:

pm: # plusminus
ble $t6,$s2,Push2stack #if stack empty then push t1 to stack
lw $t2,-4($t6) #load top stack
beq $t2,'(',Push2stack # high precedence => push t1 to stack 
addi $t6,$t6,-4 #pop stack
sw $t2,($t7) #push to output
addi $t7,$t7,4
sw $t2,($t8)
addi $t8,$t8,4
j pm #loop

md: # multiplydiv
ble $t6,$s2,Push2stack #if stack empty then push t1 to stack
lw $t2,-4($t6) #load top stack
beq $t2,'(',Push2stack # high precedence => push t1 to stack 
beq $t2,'+',Push2stack # high precedence => push t1 to stack
beq $t2,'-',Push2stack # high precedence => push t1 to stack
addi $t6,$t6,-4 #pop stack
sw $t2,($t7) #push to output
addi $t7,$t7,4
sw $t2,($t8)
addi $t8,$t8,4
j pm #loop

Push2stack:
sw $t1,($t6)
addi $t6,$t6,4
j loop

lB:
j Push2stack

rB:
looprB:
addi $t6,$t6,-4
lw $t2,($t6)
beq $t2,'(',exitrB
sw $t2,($t7)
addi $t7,$t7,4
sw $t2,($t8)
addi $t8,$t8,4
j looprB
exitrB:
j loop
#----------------------------------------------------------------------------#
#----------------------------------------------------------------------------#
#Print section
convert2Str:
	la $t4,temp_arr		#t4 = address[ temp_arr[0] ] 
	la $s6,output2print	#s6 = output2print
	addi $s2,$zero,0		#s2 = output length
	addi $t6,$zero,0	#t6 = i for temp_arr
	addi $t0,$zero,0
while1:
	beq $t0,$t8,endProgram	#t8 is exp length
	sll $t0,$t0,2
	lw $t2,exp($t0)		#exp[i]
	jal isOperator		# check character
	li $v0,4
	la $a0,exp($t0)
	srl $t0,$t0,2
	addi $t0,$t0,1
	j while1
	syscall
isOperand:
	beq $t2,100,operand_is_zero	#special case
	addi $t2,$t2,-100	#t2 -= 100
whileOperand:
	beq $t2,0,exitOperand 
	addi $t3,$zero,10
	div $t2, $t3		# t2/t3
  	mfhi $t5 		# reminder to $t2 ---- t5 = t2 % t3
  	mflo $t2	 	# quotient to $t5 ---- t2 = t2 / t3
  	sb $t5,($t4)		# temp_arr[i] = t5
  	addi $t4,$t4,1		# update temp_arr
  	addi $t6,$t6,1		# i += 1
	j whileOperand
operand_is_zero:
	addi $t2,$t2,-100	#t2 -= 100
	sb   $t2,($t4)
	addi $t4,$t4,1
	addi $t6,$t6,1
	j exitOperand
exitOperand: 			#this function POP number from temp_arr and PUSH into output
while_temp_arr_not_empty:
	beq $t6,0,returnOperand
	addi $t6,$t6,-1
	addi $t4,$t4,-1
	lb $t3,($t4)		# t3 = temp_arr[i-1]
	addi $t3,$t3,48		# change into ascii
	sb $t3,($s6)		# output2print[j] = t3
	addi $s6,$s6,1		# j += 1
	addi $s2,$s2,1		#s2 = output length
	j while_temp_arr_not_empty 
returnOperand:
	addi $t2,$zero,' '
	sb $t2,($s6)
	addi $s6,$s6,1
	addi $s2,$s2,1		#s2 = output length
	jr $ra
isOperator:
	beq $t2,'(',isOperatorTrue
	beq $t2,')',isOperatorTrue
	beq $t2,'+',isOperatorTrue
	beq $t2,'-',isOperatorTrue
	beq $t2,'*',isOperatorTrue
	beq $t2,'/',isOperatorTrue
	beq $t2,'\n',isOperatorTrue
	j   isOperand
isOperatorTrue:
	sb $t2,($s6)
	addi $s6,$s6,1
	addi $s2,$s2,1		#s2 = output length
	addi $t2,$zero,' '
	sb $t2,($s6)
	addi $s6,$s6,1
	addi $s2,$s2,1		#s2 = output length
	jr $ra


#After we get the result
endProgram:
# Open (for writing) a file that does not exist
  li   $v0, 13       # system call for open file
  la   $a0, postfix_file
  beqz $k0,COND1
  la   $a0, prefix_file   # output file name
  COND1:

  li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
  li   $a2, 0        # mode is ignored
  syscall            # open a file (file descriptor returned in $v0)
  move $s7, $v0      # save the file descriptor 
  
# Write to file just opened
  li   $v0, 15       # system call for write to file
  move $a0, $s7      # file descriptor 
  la   $a1, output2print   # address of buffer from which to write
  add  $a2,$zero,$s2 # hardcoded buffer length
  syscall            # write to file
  
# Close the file 
  li   $v0, 16       # system call for close file
  move $a0, $s6      # file descriptor to close
  syscall            # close file

#-----------------------RESULT ARRAY FOR PRINT -------------------------#
res2Str:
	la $t4,temp_arr		#t4 = address[ temp_arr[0] ] 
	la $s1,result2print	#s6 = result2print
	addi $s3,$zero,0	#s3 = output length
	addi $t6,$zero,0	#t6 = i for temp_arr
	addi $t0,$zero,0
while2:
	beq $t0,$t9,endProgram2	#t9 is res length
	sll $t0,$t0,2
	lw $t2,res($t0)		#exp[i]
	jal isOperand2		# check character
	li $v0,4
	la $a0,exp($t0)
	srl $t0,$t0,2
	addi $t0,$t0,1
	j while2
	syscall
isOperand2:
	slti $t5,$t2,99		# if t2 is NEGATIVE
	beq $t5,1,isNegative
	beq $t2,100,operand_is_zero2	#special case
	addi $t2,$t2,-100	#t2 -= 100
whileOperand2:
	beq $t2,0,exitOperand2 
	addi $t3,$zero,10
	div $t2, $t3		# t2/t3
  	mfhi $t5 		# reminder to $t2 ---- t5 = t2 % t3
  	mflo $t2	 	# quotient to $t5 ---- t2 = t2 / t3
  	sb $t5,($t4)		# temp_arr[i] = t5
  	addi $t4,$t4,1		# update temp_arr
  	addi $t6,$t6,1		# i += 1
	j whileOperand2
isNegative:
	addi $t5,$zero,-1
	mul $t2,$t2,$t5
	addi $t5,$t5,46		# t5 = '-'
	sb $t5,($s1)
	addi $s1,$s1,1
	addi $s3,$s3,1
	addi $t2,$t2,-100	#t2 -= 100
	j whileOperand2
operand_is_zero2:
	addi $t2,$t2,-100	#t2 -= 100
	sb   $t2,($t4)
	addi $t4,$t4,1
	addi $t6,$t6,1
	j exitOperand2
exitOperand2: 			#this function POP number from temp_arr and PUSH into output
while_temp_arr_not_empty2:
	beq $t6,0,returnOperand2
	addi $t6,$t6,-1
	addi $t4,$t4,-1
	lb $t3,($t4)		# t3 = temp_arr[i-1]
	addi $t3,$t3,48		# change into ascii
	sb $t3,($s1)		# result2print[j] = t3
	addi $s1,$s1,1		# j += 1
	addi $s3,$s3,1		#s3 = output length
	j while_temp_arr_not_empty2 
returnOperand2:
	addi $t7,$zero,'\n'
	sb $t7,($s1)
	addi $s1,$s1,1
	addi $s3,$s3,1
	jr $ra
endProgram2:
# Open (for writing) a file that does not exist
  li   $v0, 13       # system call for open file
  la   $a0, fout     # output file name
  li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
  li   $a2, 0        # mode is ignored
  syscall            # open a file (file descriptor returned in $v0)
  move $s7, $v0      # save the file descriptor 
  
# Write to file just opened
  li   $v0, 15       # system call for write to file
  move $a0, $s7      # file descriptor 
  la   $a1,result2print       # address of buffer from which to write
  add  $a2,$zero,$s3 # hardcoded buffer length
  syscall            # write to file
  
# Close the file 
  li   $v0, 16       # system call for close file
  move $a0, $s6      # file descriptor to close
  syscall            # close file


li $v0, 10
syscall
