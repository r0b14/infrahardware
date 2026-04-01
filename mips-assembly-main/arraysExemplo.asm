.data
array1:      .word 2, 99, 77, 36, 42      # array1 contém os números 2, 99, 77, 36, 42
array1size:  .word 16                     # array1size contém o tamanho de array1 (em bytes, 4 elementos * 4 bytes)
array2:      .space 200                   # array2 reserva 200 bytes para armazenar números

.text
# Queremos armazenar no array2 todos os números de array1 que são iguais a 36
li $s2, 36            # Carregar o valor 36 em $s2 (valor a ser buscado)
lw $t0, array1size    # Carregar o tamanho de array1 (em bytes) em $t0
li $t1, 0             # Inicializar o índice de array1 (i) com 0
li $t2, 0             # Inicializar o índice de array2 (j) com 0
addi $t4, $t0, 4      # Ajustar $t4 para o valor de array1size + 4 (primeira posição fora de array1)

loop:
lw $t3, array1($t1)   # Carregar o valor de array1[i] em $t3
beq $t3, $s2, match   # Se $t3 == 36, pular para a label match
addi $t1, $t1, 4      # Incrementar o índice de array1 (i++)
beq $t4, $t1, end     # Se i > tamanho de array1, pular para a label end
b loop                # Continuar no loop

match:
sw $t3, array2($t2)   # Armazenar o valor de $t3 (que é igual a 36) em array2[j]
addi $t1, $t1, 4      # Incrementar o índice de array1 (i++)
addi $t2, $t2, 4      # Incrementar o índice de array2 (j++)
beq $t4, $t1, end     # Se i > tamanho de array1, pular para a label end
b loop                # Continuar no loop

end:
lw $a0, array2($zero)  # Carregar o valor de array2[0] em $a0
li $v0, 1              # Código de sistema para print (1)
syscall                # Chamar syscall para imprimir o valor de $a0
li $v0, 10             # Código de sistema para exit (10)
syscall                # Chamar syscall para sair do programa
