.text
.globl main

main:
    # ---------------------------------------------
    # Inicializando registradores com valores base
    # ---------------------------------------------
    li $t0, 20          # Carrega o valor 20 no registrador $t0
    li $t1, 4           # Carrega o valor 4 no registrador $t1

    # ---------------------------------------------
    # 1. Soma (Addition)
    # ---------------------------------------------
    add $t2, $t0, $t1   # $t2 = $t0 + $t1 (Soma)

    # ---------------------------------------------
    # 2. Subtração (Subtraction)
    # ---------------------------------------------
    sub $t3, $t0, $t1   # $t3 = $t0 - $t1 (Subtração)

    # ---------------------------------------------
    # 3. Multiplicação (Multiplication)
    # ---------------------------------------------
    mult $t0, $t1       # Multiplica $t0 por $t1. O resultado vai pros registradores especiais HI e LO
    mflo $t4            # Copia o resultado (parte baixa) de LO para $t4

    # ---------------------------------------------
    # 4. Divisão (Division)
    # ---------------------------------------------
    div $t0, $t1        # Divide $t0 por $t1. Quociente vai pro LO, Resto vai pro HI
    mflo $t5            # Copia o quociente de LO para $t5
    mfhi $t6            # Copia o resto de HI para $t6

    # ---------------------------------------------
    # Encerramento do Programa (Syscall)
    # ---------------------------------------------
    li $v0, 10          # Código da syscall para terminar a execução (exit)
    syscall
