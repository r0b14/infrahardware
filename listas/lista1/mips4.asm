.data
    # Variaveis armazenadas na memória
    dividend:   .word -17       # Dividendo 
    divisor:    .word 3         # Divisor 
    RESULT:     .word 0         # Quociente 
    REMAINDER:  .word 0         # Resto 

str_not: .asciiz "not"
str_eq: .asciiz "eq"
str_iso: .asciiz "iso"
str_esc: .asciiz "esc" 

.text
.globl main

main:
    # 1. Carregar valor da memória
    lw $t0, dividend            # $t0 = dividendo
    lw $t1, divisor             # $t1 = divisor

    # 2. Inicializar variáveis de controle e saída
    li $t2, 0                   # $t2 = quociente inicializado com 0
    li $s0, 0                   # $s0 = sinal do quociente (0=positivo, 1=negativo)
    li $s1, 0                   # $s1 = sinal do resto (0=positivo, 1=negativo)

    # Parte mais complexa
    # 3. Tratamento de sinal para o Dividendo (Considerando números negativos) 
    bgez $t0, check_divisor     # Se dividendo >= 0, pula para checar o divisor
    li $s1, 1                   # Marca que o resto será negativo
    xori $s0, $s0, 1            # Inverte a flag de sinal do quociente (0 vira 1)
    sub $t0, $zero, $t0         # Transforma o dividendo em valor absoluto

check_divisor:
    # 4. Tratamento de sinal do Divisor 
    bgez $t1, div_loop          # Se divisor >= 0, pula para o laço de divisão
    xori $s0, $s0, 1            # Inverte a flag de sinal do quociente
    sub $t1, $zero, $t1         # Transforma o divisor em valor absoluto

div_loop:
    # 5. Laço de subtrações sucessivas
    blt $t0, $t1, end_div       # Se o dividendo atual for menor que o divisor, encerra o laço
    sub $t0, $t0, $t1           # dividendo = dividendo - divisor
    addi $t2, $t2, 1            # Incrementa 1 no quociente
    j div_loop                  # Volta incondicionalmente para o início do laço

end_div:
    # 6. Aplicar o sinal correto ao quociente
    beqz $s0, apply_rem_sign    # Se a flag do quociente for 0 (positivo), não altera o sinal
    sub $t2, $zero, $t2         # quociente = -quociente

apply_rem_sign:
    # 7. Aplicar o sinal correto ao resto
    beqz $s1, store_results     # Se a flag do resto for 0 (positivo), não altera o sinal
    sub $t0, $zero, $t0         # resto = -resto

store_results:
    # 8. Salvar os resultados computados de volta na memóe final nria
    sw $t2, RESULT              # Armazena o quocienta variável RESULT
    sw $t0, REMAINDER           # Armazena o resto final na variável REMAINDER

end_program:
    # 9. Encerrar
    li $v0, 10                  # Código da syscall para exit
    syscall