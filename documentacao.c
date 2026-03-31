/* 
 ===========================================================================
 DOCUMENTAÇÃO DIDÁTICA: LINGUAGEM C COMO BASE PARA MIPS ASSEMBLY
 ===========================================================================
 
 Por que estudar C antes/junto com Assembly MIPS?
 A linguagem C é uma abstração muito próxima do hardware. Diferente de 
 linguagens modernas (Python, Java), em C você gerencia a memória manualmente,
 entende o que são endereços (ponteiros) e como arrays e strings são 
 organizados fisicamente na RAM. Isso é exatamente o que o processador 
 faz no nível do Assembly!
*/

#include <stdio.h>

int main() {
    /* ---------------------------------------------------------------------
       1. VARIÁVEIS E TIPOS BÁSICOS
       Em Assembly, os dados ficam em "Registradores" (ex: $t0, $s1) ou na 
       memória RAM. Em C, declaramos variáveis que o compilador alocará.
       --------------------------------------------------------------------- */
    int inteiro = 42;       // Ocupa 4 bytes (1 word no MIPS)
    char caractere = 'A';   // Ocupa 1 byte  (útil para 'lb'/'sb' no MIPS)
    
    printf("=== 1. Variaveis ===\n");
    printf("Inteiro (word): %d\n", inteiro);
    printf("Caractere (byte): %c\n\n", caractere);

    /* ---------------------------------------------------------------------
       2. CONTROLE DE FLUXO (IF/ELSE, WHILE)
       Em MIPS, não existe "while" pronto estruturado. Existem "Branches" 
       (desvios, ex: beq, bne) e "Jumps" (ex: j). O 'while' abaixo vira 
       um bloco de instruções com uma verificação e um pulo (jump).
       --------------------------------------------------------------------- */
    printf("=== 2. Controle de Fluxo ===\n");
    int contador = 0;
    
    while (contador < 3) {  // Teste de condição (Assembly: bge $t0, 3, FIM_LOOP)
        printf("Contador no while: %d\n", contador);
        contador++;         // Incremento (Assembly: addi $t0, $t0, 1)
    }                       // Retorno ao início (Assembly: j INICIO_LOOP)
    printf("\n");

    /* ---------------------------------------------------------------------
       3. PONTEIROS E MEMÓRIA
       Um ponteiro é uma variável que guarda um ENDEREÇO de memória.
       No MIPS, usamos endereços o tempo todo com as instruções 
       'lw' (load word) e 'sw' (store word).
       --------------------------------------------------------------------- */
    printf("=== 3. Ponteiros e Memoria ===\n");
    int valor = 100;
    int *ponteiro_para_valor = &valor; // '&' pega o endereço na RAM

    printf("Valor: %d\n", valor);
    printf("Endereco (ponteiro): %p\n", (void*)ponteiro_para_valor);
    printf("Acessando o valor (dereferenciando): %d\n\n", *ponteiro_para_valor);

    /* ---------------------------------------------------------------------
       4. ARRAYS (VETORES)
       Na memória, um array é um bloco contínuo. Em MIPS, acessamos os 
       elementos somando deslocamentos (offsets) ao endereço base.
       Ex: array[2] = Endereco_Base + (2 * 4 bytes).
       --------------------------------------------------------------------- */
    printf("=== 4. Arrays (Ponteiros Disfarcados) ===\n");
    int vetor[4] = {10, 20, 30, 40};
    
    // Repare como o endereço pula de 4 em 4 bytes (tamanho de int/word)
    for (int i = 0; i < 4; i++) {
        // Calculo de Endereço MIPS: add $dst, $base, $offset
        printf("vetor[%d] = %d | Endereco na RAM: %p\n", i, vetor[i], (void*)&vetor[i]);
    }
    printf("\n");

    /* ---------------------------------------------------------------------
       5. STRINGS (CADEIAS DE CARACTERES)
       Aqui está o segredo para Assembly: não existe o tipo "String" nativo!
       Uma string é apenas um array de caracteres (char de 1 byte cada) que 
       obrigatoriamente termina com o valor zero absoluto ('\0' ou NUL).
       Isso também é chamado de ASCIIZ (ASCII terminado em zero) no MIPS.
       --------------------------------------------------------------------- */
    printf("=== 5. Strings e Manipulacao ===\n");
    
    // Forma 1: Sintaxe de array explícito
    char texto_array[] = {'M', 'I', 'P', 'S', '\0'}; 
    
    // Forma 2: Sintaxe em C facilitada ("") que coloca o '\0' automaticamente no final
    char texto[] = "MIPS";
    
    printf("Valor do texto_array: %s\n", texto_array);
    printf("Valor do texto      : %s\n\n", texto);

    /* --- Lendo uma string byte a byte (igual ao Assembly) ---
       Isso simula o processo tradicional do loop em Assembly:
       1) Ler 1 byte (lb $t1, 0($t0))
       2) Verifica se é zero (beqz $t1, fim_da_string)
       3) Avança o ponteiro (addi $t0, $t0, 1)
       4) Repete (j inicio_loop)
    */
    printf("Lendo a string '%s' do jeito classico de Baixo Nivel:\n", texto);
    int indice = 0;
    while (texto[indice] != '\0') {
        printf("Posicao %d: '%c' (Codigo Decimal ASCII: %d)\n", 
                indice, texto[indice], texto[indice]);
        indice++;
    }
    
    // Exibindo o caractere nulo ('\0') que marca o fim:
    printf("Posicao %d: Fim de String (Codigo Decimal ASCII: %d)\n", 
            indice, texto[indice]);

    return 0; // Termina o programa informando sucesso (no MIPS syscall exit ou return)
}
