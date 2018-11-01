addi $t0,$t0,1
addi $t1,$t1,1
addi $t2,$t2,6
addi $t4,$t4,0
addi $t3,$t3,0
label1:

add1 $t4, $t1,0
add $t1, $t1, $t0
addi $t0, $t4,0
addi $t3,$t3, 1
bne $t3 $t2 label1


add $v0, $t1,0
