#______________________________________________________________________________________________________________________________
#QUESTAO 1
#______________________________________________________________________________________________________________________________
.data
a: .word 3
b: .word 4
c: .word 3

s: .space 4   # saída

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

# Caso não seja um triangulo
NOTCODE:
    la $a0, str_not
    j COPY

COPY:
    la $a1, s

# Salva a string em um espaço de memoria
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
#______________________________________________________________________________________________________________________________    
# QUESTAO 2 
#______________________________________________________________________________________________________________________________ 
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
#______________________________________________________________________________________________________________________________
# QUESTAO 3
#______________________________________________________________________________________________________________________________
.data
str: .asciiz "ExemploDeSTRING"
dest: .space 1000

.text
.globl main

main:
    la $t0, str
    la $t1, dest
    add $v1, $zero, $zero

loop:
    lb $t2, 0($t0)
    beq $t2, $zero, fim

    addi $t3, $t2, -65
    slt $t3, $t3, $zero
    bnq $t3, $zero, prox

    addi $t3, $t2, -90
    slt $t3, $zero, $t3
    bnq $t3, $zero, prox

    sb $t2, 0($t1)
    addi $t1, $t1, 1
    addi $v1, $v1, 1

prox:
    addi $t0, $t0, 1
    j loop

fim:
    li $v0, 10
    syscall
#______________________________________________________________________________________________________________________________
#   QUESTAO 4
#______________________________________________________________________________________________________________________________

#______________________________________________________________________________________________________________________________
#   QUESTAO 5
#______________________________________________________________________________________________________________________________
.text
.globl main

main:
    li $a0, 14             #teste: a = 14
    li $a1, 3              #teste: b = 3
    jal mod_recursao
    # o voltar, o resultado de 14 mod 3 vai ta em $v0
    li $v0, 10             # encerrar
    syscall
mod_recursao:
   				 # checa erro a < 0
    bltz $a0, erro_negativo
    		# caso Base: se a < b, chegamos ao resto
    slt $t0, $a0, $a1
    beq $t0, $zero, faz_recursao
    					# se chegou aqui, a e o resto!
    move $v0, $a0          # coloca o resto em $v0
    jr $ra                 # volta uma camada da pilha

faz_recursao:
  			  # salva o endereço de retorno na pilha
    addi $sp, $sp, -4
    sw $ra, 0($sp)
  			  #  chama a função de novo: mod(a - b, b)
    sub $a0, $a0, $a1      
    jal mod_recursao      #ao voltar daqui, o $v0 ja vai tero valor correto
    # restaura e volta
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra                 #esse jr $ra faz o valor de $v0 subir
fim_mod:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra
erro_negativo:
    li $v1, 1    #segundo valor de retorno conforme sua imagem e enunciado
    li $v0, 10  #encerra o programa Exit
    syscall