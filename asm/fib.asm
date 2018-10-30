add $t0,$t0,1
add $t1,$t0,1
add $t2,$t0,6
add $t4,$t0,0
add $t3,$t0,0
label1:

add $t4, $t1,0
add $t1, $t1, $t0
add $t0, $t4,0
add $t3,$t3, 1
bne $t3 $t2 label1


add $v1, $t1,0