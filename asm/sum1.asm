##Sum of N natural numbers only with commands executable by our single cycle cpu
#Using the sum of n =n(n+1)/2


addi $t0 ,$zero,15# N being declared
addi $t1 ,$t0,1# N+1 being created
addi $t2, $zero, 0
addi $t3 ,$zero, 0 # Counter for repeated addition
addi $t4, $zero, 0 #Counter for repeated substraction
addi $t5 ,$zero,0# Just a zero value
label1:
add $t2, $t0, $t2 # where N(N+1) is stored
addi $t3, $t3, 1
bne $t1, $t3 label1 #BNE to check completeness of N(N+1) using the counter
label2:
addi  $t2, $t2, -2#Repeated subtraction of 2 to divivide N(N+1) by 2
addi $t4, $t4, 1#Divison counter
bne $t2, $t5 label2 # BNE to check completion of division.
add $v0, $t4,0 #Answer pushed to $v0
