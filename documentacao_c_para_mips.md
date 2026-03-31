# Documentação Didática: Linguagem C como base para MIPS Assembly

## Por que estudar C antes (ou junto com) Assembly MIPS?
A linguagem C é uma abstração muito próxima do hardware. Diferente de linguagens modernas como Python ou Java, em C você gerencia a memória manualmente, entende o que são endereços (usando ponteiros) e compreende como arrays e strings são organizados fisicamente na memória RAM. Isso é exatamente o que o processador faz no nível do Assembly! Entender C facilita muito a transição mental para o MIPS.

---

## 1. Variáveis e Tipos Básicos

Em Assembly, os dados ficam temporariamente em **Registradores** (ex: `$t0`, `$s1`) ou armazenados na memória RAM. Em C, nós declaramos variáveis e o compilador decide onde alocá-las.

*   **Inteiros (`int`)**: Em MIPS, um inteiro padrão ocupa 4 bytes da memória, o que chamamos de **Word**. Para manipular inteiros, usamos instruções como `lw` (load word) e `sw` (store word).
*   **Caracteres (`char`)**: Ocupam apenas 1 byte. No MIPS, usamos instruções específicas de byte, como `lb` (load byte) e `sb` (store byte).

```c
int inteiro = 42;       // Ocupa 4 bytes (1 word no MIPS)
char caractere = 'A';   // Ocupa 1 byte  (útil para 'lb'/'sb' no MIPS)
```

---

## 2. Controle de Fluxo (If/Else, While)

Em C, temos estruturas prontas e elegantes como `while`, `for` e `if`.
No MIPS, não existe um bloco "while" estruturado. O processador trabalha com **Branches** (desvios condicionais, ex: `beq` para *branch on equal*, `bne` para *branch on not equal*) e **Jumps** (pulos incondicionais, ex: `j`).

Um laço `while` em C se torna uma verificação lógica seguida de saltos (jumps) na memória do programa em Assembly.

```c
int contador = 0;

while (contador < 3) {  // Teste (Em Assembly: bge $t0, 3, FIM_LOOP)
    contador++;         // Incremento (Em Assembly: addi $t0, $t0, 1)
}                       // Volta ao começo (Em Assembly: j INICIO_LOOP)
// FIM_LOOP:
```

---

## 3. Ponteiros e Memória

Um ponteiro nada mais é do que uma variável que **guarda um endereço de memória**. 
No MIPS, o tempo todo precisamos informar o endereço da RAM que queremos acessar. O conceito de ponteiro em C (`&` para pegar o endereço e `*` para acessar o valor naquele endereço) é a representação exata do funcionamento do MIPS ao transferir dados de/para a memória.

```c
int valor = 100;
int *ponteiro_para_valor = &valor; // '&' pega o endereço exato na RAM

// dereferenciando (acessando o dado via endereço igual faríamos com 'lw' no MIPS)
int valor_na_ram = *ponteiro_para_valor; 
```

---

## 4. Arrays (Vetores) na Memória

Na memória, um array é simplesmente um bloco contínuo de dados. Em MIPS, acessamos os elementos de um vetor somando **deslocamentos (offsets)** a um **endereço base** (o endereço do primeiro item).

```c
int vetor[4] = {10, 20, 30, 40};
// Como 'int' tem 4 bytes, o MIPS pula de 4 em 4 bytes na RAM:
// vetor[0] = Endereco_Base
// vetor[1] = Endereco_Base + 4
// vetor[2] = Endereco_Base + 8
// vetor[3] = Endereco_Base + 12
```

---

## 5. Strings (Cadeias de Caracteres)

Aqui está o grande segredo para o Assembly: **não existe o tipo nativo "String"!**

Uma string em C (e em MIPS) é apenas um array de caracteres (bytes) que termina obrigatoriamente com o **valor numérico zero absoluto (`\0` ou byte `0x00`)**. Em MIPS, costumamos chamar isso de **ASCIIZ** (ASCII finalizado em Zero).

### Declaração em C (Similar à diretiva `.asciiz` em MIPS):

```c
// Forma explícita: array de bytes terminando em zero
char texto_array[] = {'M', 'I', 'P', 'S', '\0'}; 

// Sintaxe facilitada: o compilador C coloca o '\0' oculto no final, 
// o MIPS faz o mesmo com .asciiz "MIPS"
char texto[] = "MIPS"; 
```

### Lendo uma String (A mentalidade MIPS)

Como manipulamos isso em Assembly? Lemos **byte a byte** até encontrar o byte `0`.

A lógica exata que você escreverá em assembly MIPS é esta estrutura C:

```c
int indice = 0;

// Enquanto o byte lido não for '0' (\0)
while (texto[indice] != '\0') {
    // 1. Ler 1 byte (lb $t1, 0($t0))
    // 2. Verifica se é zero (beqz $t1, fim_da_string)
    // 3. Imprime/processa o caractere
    
    indice++; // 4. Avança para o próximo byte (addi $t0, $t0, 1)
} // 5. Repete (j inicio_loop)
```

Essa base sólida vai garantir que programar em Assembly MIPS seja apenas uma tradução direta desses mesmos conceitos em instruções mais primitivas.