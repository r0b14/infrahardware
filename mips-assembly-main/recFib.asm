.globl __start
.ent __start

.data
n: .word 4              # Reserva o valor 4 em "n"

.text
__start:
lw $a0, n               # Carrega o valor de "n" no registrador $a0
jal fib                 # Chama a função fib(n)

li $v0, 1               # Define o código de syscall para imprimir um número inteiro em $v0
move $a0, $v1           # Move o resultado de fib(n) para $a0
syscall                 # Chama a syscall para imprimir o valor de $a0 (fib(n))

li $v0, 10              # Define o código de syscall para terminar o programa
syscall                 # Chama a syscall para finalizar o programa

fib:
addi $sp, $sp, -12      # Move o ponteiro da pilha para baixo por 3 palavras (reservando espaço na pilha)
sw $a0, 8($sp)          # Armazena o argumento (n) na pilha
sw $s0, 4($sp)          # Armazena o registrador $s0 na pilha
sw $ra, 0($sp)          # Armazena o endereço de retorno ($ra) na pilha

beq $a0, $zero, return  # Se n == 0, pula para "return"
li $t0, 1
beq $a0, $t0, return    # Se n == 1, pula para "return"

addi $a0, $a0, -1       # Decrementa n (n - 1)
jal fib                 # Chama fib(n-1)
move $s0, $v1           # Move o resultado de fib(n-1) para $s0

addi $a0, $a0, -1       # Decrementa n novamente (n - 2)
jal fib                 # Chama fib(n-2)
add $v1, $s0, $v1       # Soma os resultados de fib(n-1) e fib(n-2) para obter fib(n)

j cleanup               # Pula para "cleanup" para limpar a pilha e retornar

return:
move $v1, $a0           # Se n == 0 ou n == 1, retorna n (fib(0) = 0, fib(1) = 1)
j cleanup               # Pula para "cleanup" para limpar a pilha e retornar

cleanup:
lw $ra, 0($sp)          # Restaura o endereço de retorno da pilha
lw $s0, 4($sp)          # Restaura o valor do registrador $s0 da pilha
lw $a0, 8($sp)          # Restaura o argumento (n) da pilha
addi $sp, $sp, 12       # Move o ponteiro da pilha de volta (libera o espaço usado na pilha)
jr $ra                  # Retorna para o chamador (endereço armazenado em $ra)

