.data
a: .word 3
b: .word 4
c: .word 3

s: .space 4   # saida

str_not: .asciiz "not"
str_eq: .asciiz "eq"
str_iso: .asciiz "iso"
str_esc: .asciiz "esc" 

.text
.globl main

main:
    # Carregar valores
    lw $s1, a
    lw $s2, b
    lw $s3, c
    
    # Check 1 
    add $t0, $s1, $s2
    slt $t1, $s3, $t0     
    beq $t1, $zero, NOTCODE

    # Check 2
    add $t0, $s2, $s3
    slt $t1, $s1, $t0
    beq $t1, $zero, NOTCODE

    # Check 3
    add $t0, $s1, $s3
    slt $t1, $s2, $t0
    beq $t1, $zero, NOTCODE
    
    # Adds
    add $t0, $s1, $s2
    add $t1, $s1, $s3
    add $t2 , $s2, $s3

CHECKEQ:    
    # Check eq
    bne $s1, $s2, CHECKISO
    bne $s1, $s3, CHECKISO
    j EQCODE
    

CHECKISO:	
    beq $s1,$s2, ISOCODE
    beq $s2, $s3, ISOCODE
    beq $s1, $s3, ISOCODE
    J NOTCODE
    
CHECKESC:	
    beq $s1,$s2, NOTCODE
    beq $s2, $s3, NOTCODE
    beq $s1, $s3, NOTCODE
    J ESCCODE
    
ISOCODE:
    la $a0, str_iso
    j COPY

ESCCODE:
    la $a0, str_esc
    j COPY
      

EQCODE:
    la $a0, str_eq
    j COPY

# Caso n�o seja um triangulo
NOTCODE:
    la $a0, str_not
    j COPY

COPY:
    la $a1, s

# Salva a string em um espa�o de memoria
LOOP:
    lb $t5, 0($a0)
    sb $t5, 0($a1)

    beq $t5, $zero, END

    addi $a0, $a0, 1
    addi $a1, $a1, 1
    j LOOP

END:
    li $v0, 10
    syscall