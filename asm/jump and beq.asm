addi $t1,$t1,5
addi $t3,$t3,8

label1:
beq $t1,$t3,label2
add $t1,$t1,1

j label1
label2:
add $v0, $t1,0