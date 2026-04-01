.globl __start
.ent __start

.data
a: .word 1              # Reserva o valor 1 em "a"
b: .word 3              # Reserva o valor 3 em "b"

.text
__start:
lw $a0, a               # Carrega o valor de "a" no registrador $a0
lw $a1, b               # Carrega o valor de "b" no registrador $a1
jal sum                 # Chama a função sum(a, b)

li $v0, 1               # Define o código de syscall para imprimir um número inteiro em $v0
move $a0, $v1           # Move o resultado de sum(a, b) para $a0
syscall                 # Chama a syscall para imprimir o valor de $a0

li $v0, 10              # Define o código de syscall para finalizar o programa
syscall                 # Chama a syscall para terminar o programa

sum:
addi $sp, $sp, -8       # Move o ponteiro da pilha para baixo por 2 palavras (reservando espaço na pilha)
sw $s0, 4($sp)          # Armazena o registrador $s0 na pilha
sw $ra, 0($sp)          # Armazena o endereço de retorno ($ra) na pilha

bgt $a0, $a1, fail      # Se a > b, pula para a label "fail"

beq $a0, $a1, return    # Se a == b, pula para a label "return"

move $s0, $a1           # Move o valor de b para $s0 (variável auxiliar)
addi $a1, $a1, -1       # Decrementa b (b = b - 1)
jal sum                 # Chama sum(a, b - 1)
add $v1, $s0, $v1       # Soma b com o resultado de sum(a, b - 1) e armazena no registrador $v1
j cleanup               # Pula para a label "cleanup" para limpar a pilha e retornar

return:
move $v1, $a0           # Retorna o valor de a no registrador $v1
j cleanup               # Pula para a label "cleanup" para limpar a pilha e retornar

fail:
li $v1, 1               # Retorna 1 no registrador $v1 (caso de erro: a > b)
j cleanup               # Pula para a label "cleanup" para limpar a pilha e retornar

cleanup:
lw $ra, 0($sp)          # Restaura o endereço de retorno da pilha
lw $s0, 4($sp)          # Restaura o valor do registrador $s0 da pilha
addi $sp, $sp, 8        # Move o ponteiro da pilha de volta (libera o espaço usado na pilha)
jr $ra                  # Retorna para o chamador (endereço armazenado em $ra)

