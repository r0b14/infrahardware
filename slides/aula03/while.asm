# criação de laço while

main:
    li $s2, 0          # variável h
    li $s3, 5          # variável i -> contador
    li $s4, 0          # endereço base de save

loop:
    sll $t1, $s3, 2      # Calcula o deslocamento para acessar save[i] (i * 4 bytes)
    add $t1, $t1, $s4      # Calcula o endereço de save[i] end_base + $t1
    lw $t0, 0($t1)       # Carrega o valor de save[i] para $t0
    bne $t0, $s2, exit
    addi $s3, $s3, 1  # Incrementa o contador i ($s3) em 1
    j loop             # Desvia para o início do laço (loop)
exit:
    # Código a ser executado após o laço
    # (pode ser uma mensagem ou outra operação)
    li $v0, 10          # Código da syscall para terminar a execução (exit)
    syscall