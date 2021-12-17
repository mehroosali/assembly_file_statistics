# File Name: program2.asm
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - intial code for file input and reading was written and tested on 18th October 2021 by Mehroos Ali.
# - code for computing uppercase and lowercase characters was added on 19th October by Mehroos Ali.
# - code for computing NumberSymbols and OtherSymbols was added on 19th October by Mehroos Ali.
# - This code was modified on 21st October 2021 by Mehroos Ali to add signed number interpretation functionality.

# Procedures:
# main: Reads the input filename name from user, initializes counters, calls procedures to read the file and iterate through it.  
# intializeCounters: this procedure initialized muliple loop counters for filename, buffer and output file statistics.
# return: procedure to return to the callee which is shared between multiple other procedures.
# modifyFileName: Procedure to remove the line feed character from the end of the user given filename.
# fileNameCounterIncrement: Procedure to increment filename loop counter.
# fileRead: Procedure for opening and reading the file.
# bufferLoop: Procedure for looping though the file buffer string.
# checkUpper: Procedure for checking uppercase character by comparing hexadecimal ASCII values.
# checkLower: Procedure for checking lowercase character by comparing hexadecimal ASCII values.
# checkNumberSymbols: Procedure for checking number symbols by comparing hexadecimal ASCII values.
# checkOtherSymbols: Procedure for checking other symbols by subtrating the uppercase, lowercase and number characters from total characters.
# checkLinesOfText: Procedure for checking number of lines of text by comparing hexadecimal ASCII values.
# checkPositiveSignedNumbers: Procedure for checking positive signed numbers like +1,+2, etc.
# checkNegativeSignedNumbers: Procedure for checking negative signed numbers like -1,-2, etc.
# end: Procedure which runs after the file buffer loop ends by calling output procedures and file close procedures.
# output: Procedure for display output results.
# fileClose: Procedure for closing the open file.

	.data
fileName:		.ascii ""									# input filename
inputPrompt:   		.asciiz "Enter the input file name (less than 30 characters) : "		# Input prompt to enter filename.
totalChars:		.asciiz "Total Number of Characters: "						# Output String to show result for total number of Characters.
outputUpperChars:	.asciiz "Number of Uppercase Characters: "					# Output String to show result for number of Uppercase Characters.
outputLowerChars:   	.asciiz "Number of Lowercase Characters: "					# Output String to show result for number of Lowercase Characters.
outputNumberSymbols:   	.asciiz "Number of Number Symbols: "						# Output String to show result for number of Number Symbols.
outputOtherSymbols:   	.asciiz "Number of Other Symbols: "						# Output String to show result for number of Other Symbols.
outputLinesOfText:   	.asciiz "Number of Lines of Text: "						# Output String to show result for number of Lines of Text.
outputSignedNumbers:   	.asciiz "Number of Signed Numbers: "						# Output String to show result for number of Signed Numbers.
newLine:  		.asciiz "\n"									# String for newline.
buffer: 		.asciiz ""									# String holding the file buffer contents.
header: 		.asciiz "CS5330 Program - 2"							# header string.

	.text
# main:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 18th October 2021 by Mehroos Ali.
# Description: Reads the input filename name from user, initializes counters, calls procedures to read the file and iterate through it.
# Arguments: None
main: 	li $v0, 4		# call print_string service.
	la $a0, header		# load address of directive header.              
	syscall			# print header.	
	
	li $v0, 4		# System call for printing string newLine.
    	la $a0, newLine		# Load address of newLine string.
    	syscall			# Print string newLine.
    
	li $v0, 4		# call print_string service.
	la $a0, inputPrompt	# load address of directive inputPrompt.              
	syscall			# print inputPrompt to enter filename.      
	                 
	li $v0, 8		# call read_string service  
	la $a0, fileName	# load address of directive fileName to store the input filename into it.
	li $a1, 30		# specify the filename length argument in register $a1.                  
	syscall			# reads the input filename from user and stores the filename in fileName directive.  
	
	jal intializeCounters	# jump to procedure fileNameCounter.
	jal modifyFileName	# jump to procedure modifyFileName.
	jal fileRead		# jump to procedure fileRead. 
	
	move $s1, $v0		# Storing total number of file bytes in $s1.   
	
	li $t0, 0		# reinitialize the loop counter to 0.
	jal bufferLoop	        # jump to procedure bufferLoop.

# intializeCounters:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 18th October 2021 by Mehroos Ali.
# Description: this procedure initialized muliple loop counters for filename, buffer and output file statistics. 
# Arguments: None
intializeCounters:
	li $t0, 0		# Loop start counter
	li $t1, 30      	# max length of filename string.
	li $t2, 0   		# Uppercase counter
	li $t3, 0   		# Lowercase counter 
	li $t4, 0   		# Number Symbols counter
	li $t5, 0   		# Other Symbols counter
	li $t6, 0   		# Lines of Text counter
	li $t7, 0   		# Signed Numbers counter

# return:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 18th October 2021 by Mehroos Ali.
# Description: procedure to return to the callee which is shared between multiple other procedures.
return:
	jr $ra

# modifyFileName:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 18th October 2021 by Mehroos Ali.
# Description: Procedure to remove the line feed character from the end of the user given filename. 		
modifyFileName:
	beq $t0, $t1, return			# If the loop counter reaches the end of the file name length branch thenjump to procedure return
	lb $s2, fileName($t0)			# Trversing the file name byte by byte.		
	bne $s2, 0x0a, fileNameCounterIncrement	# If not equal to line feed branch and increment the loop counter.
	sb $zero, fileName($t0)			# If line feed found, replace it will null character.
fileNameCounterIncrement:
	addi $t0, $t0, 1			# Increment loop counter.
	j modifyFileName			# jump to procedure modifyFileName.

# fileRead:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 18th October 2021 by Mehroos Ali.
# Description: Procedure for opening and reading the file.	   	       	                     	       	                
fileRead:
	li $v0, 13				# system call for opening the file.
	la $a0, fileName			# load address of input filename.
	li $a1, 0				# set the flag for reading.
	li $a2, 0				# set the file mode.
	syscall					# open the file. 
	move $s0, $v0				# save the file descriptor in $t0. 

	li $v0, 14				# system call for reading from the file.
	move $a0, $s0				# move the file descriptor in $a0.
	la $a1, buffer				# load address of buffer from which to read.
	li $a2, 1000000				# hardcode the buffer length.
	syscall					# read from the file.
    
    	jr $ra					# return to procedure bufferLoop.

# bufferLoop:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 18th October 2021 by Mehroos Ali.
# Description: Procedure for looping though the file buffer string.
bufferLoop:
	beq $t0, $s1, end			# If the loop counter reaches the end of the file buffer branch then jump to procedure end.
	lb $t1, buffer($t0)         		# load next byte from file buffer.
	jal checkUpper              		# jump to procedure to check for upper case characters.
	jal checkLower              		# jump to procedure to check for lower case characters.
	jal checkNumberSymbols			# jump to procedure to check for number Symbols.
	jal checkLinesOfText			# jump to procedure to check for lines of text.
	jal checkPositiveSignedNumbers		# jump to procedure to check for Positive Signed Numbers.
	jal checkNegativeSignedNumbers		# jump to procedure to check for Negative Signed Numbers.
	addi $t0, $t0, 1            		# increment loop counter.
	j bufferLoop				# move to the next byte in the loop.

# checkUpper:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 19th October 2021 by Mehroos Ali.
# Description: Procedure for checking uppercase character by comparing hexadecimal ASCII values.
checkUpper:
	blt  $t1, 0x41, return			# branch if less than 'A' then return.
	bgt  $t1, 0x5a, return			# branch if greater than 'Z' then return.
	addi $t2, $t2, 1			# increment Uppercase counter.

# checkLower:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 19th October 2021 by Mehroos Ali.
# Description: Procedure for checking lowercase character by comparing hexadecimal ASCII values.
checkLower:
	blt $t1, 0x61, return			# branch if less than 'a' then return
	bgt $t1, 0x7a, return			# branch if greater than 'z' then return
	addi $t3, $t3, 1			# increment Lowercase counter.

# checkNumberSymbols:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 19th October 2021 by Mehroos Ali.
# Description: Procedure for checking number symbols by comparing hexadecimal ASCII values. 
checkNumberSymbols:
	blt $t1, 0x30, return			# branch if less than 0 then return.          
	bgt $t1, 0x39, return			# branch if greater than 9 then return.          
	addi $t4, $t4, 1			# increment NumberSymbols counter.

# checkLinesOfText:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 19th October 2021 by Mehroos Ali.
# Description: Procedure for checking lines of text by comparing hexadecimal ASCII values.
checkLinesOfText:
	bne $t1, 0x0a, return			# branch if not equal to '\n' then return
	addi $t6, $t6, 1			# increment LinesOfText counter

# checkPositiveSignedNumbers:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 21st October 2021 by Mehroos Ali.
# Description: Procedure for checking positive signed numbers like +1,+2, etc.   
checkPositiveSignedNumbers: 
	bne $t1, 0x2b, return			# branch if not equal to '+' then return.
	move $t8, $t0				# Else copy the current position of character in file to $t8.
	addi $t8, $t8, 1			# Increment $t8 to find the next character in file.
	lb $t9, buffer($t8)			# Load the character at $t8.
	blt $t9, 0x31, return			# branch if less than 1 then return.
	bgt $t9, 0x39, return			# branch if greater than 9 then return.
	addi $t7, $t7, 1			# Else increment the signed number counter.

# checkNegativeSignedNumbers:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 21st October 2021 by Mehroos Ali.
# Description: Procedure for checking negative signed numbers like -1,-2, etc.  
checkNegativeSignedNumbers: 
	bne $t1, 0x2d, return1			# branch if not equal to '-' then return.
	move $t8, $t0				# Else copy the current position of character in file to $t8.
	addi $t8, $t8, 1			# Increment $t8 to find the next character in file.s 
	lb $t9, buffer($t8)			# Load the character at $t8.
	blt $t9, 0x31, return			# branch if less than 1 then return.			
	bgt $t9, 0x39, return			# branch if greater than 9 then return.
	addi $t7, $t7, 1			# Else increment the signed number counter.
return1:
jr $ra	

# end:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 18th October 2021 by Mehroos Ali.
# Description: Procedure which runs after the file buffer loop ends by calling output procedures and file close procedures.
end:
    	jal checkOtherSymbols			# jump to procedure to check for other Symbols.
    	addi $t6, $t6, 1			# increment number of '\n' characters by 1 to get the total number of lines of text.
    	jal output				# jump to procedure to print the output results.
    	jal fileClose				# jump to procedure to close the file.

    	li $v0, 10				# system call to end the program.
    	syscall					# end the program.        

# checkOtherSymbols:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 19th October 2021 by Mehroos Ali.
# Description: Procedure for checking other symbols by subtrating the uppercase, lowercase and number characters from total characters.
checkOtherSymbols:
    	sub $t5, $t0, $t2			# subtract number of upper case characters from total characters and store in $t5. 
    	sub $t5, $t5, $t3			# subtract number of lower case characters from $t5.  
    	sub $t5, $t5, $t4			# subtract total number of number symbols from $t5.    
    	jr $ra					# returns back to end procedure.

# output:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 18th October 2021 by Mehroos Ali.
# Description: Procedure for display output results.   
output:  
	
    	li $v0, 4				# System call for printing string newLine.
    	la $a0, newLine				# Load address of newLine string.
    	syscall					# Print string newLine.
    
    	li $v0, 4				# System call for printing string outputUpperChars.
    	la $a0, totalChars			# Load address of outputUpperChars string.
    	syscall					# Print string outputUpperChars.

    	li $v0, 1				# System call for printing integer.
    	move $a0, $s1				# Move value of register $t2 to $a0 for output.
    	syscall					# Print value of register $a0.
    					
    	li $v0, 4				# System call for printing string newLine.
    	la $a0, newLine				# Load address of newLine string.
    	syscall					# Print string newLine.
    
    	li $v0, 4				# System call for printing string outputUpperChars.
    	la $a0, outputUpperChars		# Load address of outputUpperChars string.
    	syscall					# Print string outputUpperChars.

    	li $v0, 1				# System call for printing integer.
    	move $a0, $t2				# Move value of register $t2 to $a0 for output.
    	syscall					# Print value of register $a0.
    
    	li $v0, 4				# System call for printing string newLine.
    	la $a0, newLine				# Load address of newLine string.
    	syscall					# Print string newLine.

    	li $v0, 4				# System call for printing string outputLowerChars.
    	la $a0, outputLowerChars		# Load address of outputLowerChars string.
    	syscall					# Print string outputLowerChars.

    	li $v0, 1				# System call for printing integer.
    	move $a0, $t3				# Move value of register $t3 to $a0 for output.
    	syscall					# Print value of register $a0.
    
    	li $v0, 4				# System call for printing string newLine.
    	la $a0, newLine				# Load address of newLine string.
    	syscall					# Print string newLine.
    
    	li $v0, 4				# System call for printing string outputNumberSymbols.
    	la $a0, outputNumberSymbols		# Load address of outputNumberSymbols string.
    	syscall					# Print string outputNumberSymbols.

    	li $v0, 1				# System call for printing integer.
    	move $a0, $t4				# Move value of register $t4 to $a0 for output.
    	syscall					# Print value of register $a0.
    
    	li $v0, 4				# System call for printing string newLine.
    	la $a0, newLine				# Load address of newLine string.
    	syscall					# Print string newLine.
    
    	li $v0, 4				# System call for printing string outputOtherSymbols.
    	la $a0, outputOtherSymbols		# Load address of outputOtherSymbols string.
    	syscall					# Print string outputOtherSymbols.

    	li $v0, 1				# System call for printing integer.
    	move $a0, $t5				# Move value of register $t5 to $a0 for output.
    	syscall					# Print value of register $a0.
    
    	li $v0, 4				# System call for printing string newLine.
    	la $a0, newLine				# Load address of newLine string.
    	syscall					# Print string newLine.
    
    	li $v0, 4				# System call for printing string outputLinesOfText.
    	la $a0, outputLinesOfText		# Load address of outputLinesOfText string.
    	syscall					# Print string outputLinesOfText.

    	li $v0, 1				# System call for printing integer.
    	move $a0, $t6				# Move value of register $t6 to $a0 for output.
    	syscall					# Print value of register $a0.
    
    	li $v0, 4				# System call for printing string newLine.
    	la $a0, newLine				# Load address of newLine string.
    	syscall					# Print string newLine.
    
    	li $v0, 4				# System call for printing string outputSignedNumbers.
    	la $a0, outputSignedNumbers		# Load address of outputSignedNumbers string.
    	syscall					# Print string outputSignedNumbers.

    	li $v0, 1				# System call for printing integer.
    	move $a0, $t7				# Move value of register $t7 to $a0 for output.
    	syscall					# Print value of register $a0.
    
    	li $v0, 4				# System call for printing string newLine.
    	la $a0, newLine				# Load address of newLine string.
    	syscall					# Print string newLine.
      
    	jr $ra					# return to procedure end.

# fileClose:	
# Author: Mehroos Ali - mehroos.ali@utdallas.edu
# Modification History
# - This code was first written on 18th October 2021 by Mehroos Ali.
# Description: Procedure for closing the open file.                                    
fileClose:
	li $v0, 16       			# system call to close the file.
    	move $a0, $s0      			# file descriptor to close.
    	syscall            			# close file.
    
    	jr $ra	       				# return to procedure end.	
        

        



    

          
	



