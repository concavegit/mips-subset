li $t0,1
li $t1,1
li $t2,6
li $t4,0
li $t3,0
label1:

add $t4, $t1,0
add $t1, $t1, $t0
add $t0, $t4,0
add $t3,$t3, 1
bne $t3 $t2 label1


add $v1, $t1,0
