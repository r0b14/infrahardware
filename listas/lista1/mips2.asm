.data
newline: .asciiz "\n"

.text
.globl main
main: 
    li $s0, 0
    li $t1, 1664525       
    li $t2, 1013904223    
    
    li $v0, 30          # Syscall 30: get system time
    syscall             # Retorna o tempo em $a0 e $a1
    move $t0, $a0

    
LOOP:
    beq $s0, 10, OUTLOOP
    mulu $s2, $t0, $t1
    addu $t0, $s2, $t2
    
    move $a0, $t0
    li $v0, 1          
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    addi $s0, $s0,1
    
    j LOOP
            
OUTLOOP:
    li $v0, 10
    syscall
    