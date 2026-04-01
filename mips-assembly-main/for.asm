.text
li $t1, 3                  # Define o número de iterações do loop
li $t0, 10                 # Carrega o valor 10 em $t0 (n = 10)
loop: beq $t1, $zero, end  # Verifica se o contador de iterações (t1) chegou a zero, se sim, pula para "end"
add $s0, $t0, $s0          # x = x + n (soma o valor de $t0 em $s0)
addi $t1, $t1, -1          # Decrementa o contador de iterações (t1 = t1 - 1)
j loop                     # Pula para o início do loop
end: li $v0, 10            # Define o código de syscall para finalizar o programa
syscall                    # Executa a syscall para terminar o programa

