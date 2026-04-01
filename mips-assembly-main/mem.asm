.data
resposta: 0             # Reserva um espaço de memória para a variável "resposta" inicializada com 0

.text
li $t0, 10              # Carrega o valor 10 no registrador $t0
sw $t0, resposta        # Armazena o valor de $t0 na variável "resposta" na memória
lw $a0, resposta        # Carrega o conteúdo da variável "resposta" no registrador $a0
li $v0, 1               # Carrega o código de syscall para imprimir um número inteiro em $v0
syscall                 # Chama a syscall para imprimir o valor de $a0 (que é o conteúdo de "resposta", ou seja, 10)

