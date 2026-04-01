.data
# Inicializar array com valores
array1:   .word 2, 99, 77, 36, 42       # array1 contém 5 elementos
array2:   .space 200                    # array2 é um espaço de 200 bytes

.text
# Acessar um índice arbitrário de um array
la $s0, array1        # Carregar o ponteiro para o início de array1 no registrador $s0
lw $a0, 12($s0)       # Carregar array1[3] (3*4 = 12) no registrador $a0
li $v0, 1             # Código de sistema para print (1)
syscall               # Chamar a syscall (exibir o valor de $a0)

# Alternativamente, acessar o mesmo índice (array1[3])
addi $s0, $s0, 12     # Ajustar ponteiro: $s0 = $s0 + 3*4
lw $a0, ($s0)         # Carregar o valor de array1[3] em $a0
li $v0, 1             # Código de sistema para print (1)
syscall               # Chamar a syscall (exibir o valor de $a0)

# Alternativamente, acessar um índice utilizando um registrador $t0 para armazenar o índice
li $t0, 12            # Carregar índice desejado (12) em $t0
lw $a0, array1($t0)   # Carregar array1[$t0] (que é array1[3]) no registrador $a0
li $v0, 1             # Código de sistema para print (1)
syscall               # Chamar a syscall (exibir o valor de $a0)

# Carregar números arbitrários em um array
la $s0, array2        # Carregar o ponteiro para o início de array2 no registrador $s0

# Constantes para armazenar no array
li $t0, 42            # Carregar o valor 42 em $t0 (array2[0] = 42)
li $t1, 84            # Carregar o valor 84 em $t1 (array2[2] = 84)
li $t2, 21            # Carregar o valor 21 em $t2 (array2[4] = 21)

# Armazenar constantes no array
sw $t0, array2($zero) # Armazenar 42 em array2[0] (offset 0)
# Alternativamente, armazenar valor em outro índice
sw $t1, 8($s0)        # Armazenar 84 em array2[2] (offset 8)

# Alternativamente, ajustando ponteiro para armazenar o próximo valor
addi $s0, $s0, 16     # Ajustar ponteiro: $s0 = $s0 + 4*4
sw $t2, ($s0)         # Armazenar 21 em array2[4] (offset 16)
