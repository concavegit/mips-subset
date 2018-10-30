
##Sum of N natural numbers only with commands executable by our single cycle cpu
#Using the sum of n =n(n+1)/2


add $t0 ,$t0,15# N being declared
add $t1 ,$t0 ,1# N+1 being created
add $t3 , $t3, 0 # Counter for repeated addition
add $t4, $t4,0 #Counter for repeated substraction
add $t5 ,$t5,0# Just a zero value
label1:
add $t2, $t0, $t2 # where N(N+1) is stored
add $t3, $t3, 1
bne $t1, $t3 label1 #BNE to check completeness of N(N+1) using the counter
label2:
add  $t2, $t2, -2#Repeated subtraction of 2 to divivide N(N+1) by 2
add $t4, $t4, 1#Divison counter
bne $t2, $t5 label2 # BNE to check completion of division.
add $v0, $t4,0 #Answer pushed to $v0

