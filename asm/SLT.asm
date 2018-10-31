li $t1,5
li $t3,8
beq $t3 $t1 label1
sub $t3,$t1,$t3
slt $t2, $t3, $t1
label1:
slt $t2, $t3, $t1
