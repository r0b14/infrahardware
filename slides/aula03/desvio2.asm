# Desvio condicional

main:
    li $s1, 8          # Carrega o valor [g]8 no registrador $s1
    li $s2, 8          # Carrega o valor [h]8 no registrador $s2
    li $s3, 0          # Carrega o valor [i]0 no registrador $s3

    slt $t0, $s3, $s2  # Define $t0 como 1 se $s3 < $s2, caso contrário, define como 0
    beq $t0, $zero, else   # Se $t0 for 0, desvia para o rótulo "diferente"
    j igual               # Caso contrário, desvia para o rótulo "igual"


igual:
    # Código a ser executado se $s3 for igual a $s2
    add $s3, $s1, $s2   # soma $s1 e $s2, armazenando o resultado em $s3
    j exit               # Desvia para o rótulo "fim"

else:
    # codigo a ser executado se $s3 for diferente de $s2
    sub $s3, $s1, $s2   # subtrai $s1 de $s2, armazenando o resultado em $s3
    j exit               # Desvia para o rótulo "fim"

exit:
    # Código a ser executado após o desvio
    # (pode ser uma mensagem ou outra operação)
    li $v0, 10          # Código da syscall para terminar a execução (exit)
    syscall