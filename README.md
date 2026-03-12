# Infraestrutura de Hardware (IF674) - UFPE

Repositório de estudos e práticas da disciplina **IF674 - Infraestrutura de Hardware** do Centro de Informática da UFPE. Este espaço é dedicado ao aprofundamento e organização de tópicos essenciais sobre arquitetura de computadores, implementação em hardware e programação em baixo nível.

## 📚 Assuntos Abordados

- Assembly
- Implementação em hardware
- Arquitetura e organização de computadores
- Processador MIPS
- Verilog
- Projeto em CPU

## 🧠 Assembly para MIPS

### Extensões de arquivo usadas

Para criar programas em assembly para processadores MIPS, as extensões mais comuns são:

- `.s`: extensão tradicional para arquivos de código-fonte em assembly. É amplamente aceita em montadores, simuladores e ambientes acadêmicos.
- `.asm`: também é bastante usada para indicar arquivos assembly, especialmente em materiais didáticos e algumas ferramentas.

Na prática, ambas podem ser usadas para código MIPS, desde que a ferramenta adotada no ambiente de estudo aceite o formato. Em contextos de disciplina e simuladores como MARS e QtSpim, é comum encontrar exemplos com `.asm`, enquanto `.s` também aparece com frequência em toolchains mais próximas de sistemas Unix.

### Exemplos de código e uso

Exemplo simples de soma entre registradores:

```asm
.text
.globl main

main:
    add $t0, $t1, $t2   # $t0 = $t1 + $t2
```

Exemplo com carregamento imediato e syscall para encerramento:

```asm
.text
.globl main

main:
    li $t0, 10          # carrega 10 em $t0
    li $t1, 20          # carrega 20 em $t1
    add $t2, $t0, $t1   # $t2 = 30

    li $v0, 10          # codigo da syscall de saida
    syscall
```

Exemplo com acesso à memória:

```asm
.data
valor: .word 25

.text
.globl main

main:
    lw $t0, valor       # carrega o valor da memoria em $t0
    addi $t1, $t0, 5    # soma constante ao valor lido
```

Usos mais comuns em MIPS assembly:

- manipulação direta de registradores;
- operações aritméticas e lógicas;
- controle de fluxo com desvios e saltos;
- acesso a memória com `lw` e `sw`;
- estudo do funcionamento interno da CPU e da ISA.

### Formatos de instrução R, I e J

As instruções do MIPS possuem formatos fixos de 32 bits. Os três formatos principais são `R`, `I` e `J`.

#### Formato R

O formato `R` é usado em instruções entre registradores, como soma, subtração e operações lógicas.

Estrutura:

```text
opcode (6) | rs (5) | rt (5) | rd (5) | shamt (5) | funct (6)
```

- `opcode`: normalmente vale `0` nesse formato;
- `rs` e `rt`: registradores de origem;
- `rd`: registrador de destino;
- `shamt`: quantidade de deslocamento, usada em instruções de shift;
- `funct`: define a operação exata.

Exemplo:

```asm
add $t0, $t1, $t2
```

Nesse caso, a operação usa os valores de `$t1` e `$t2` e grava o resultado em `$t0`.

#### Formato I

O formato `I` é usado para instruções com valor imediato, acesso à memória e desvios condicionais.

Estrutura:

```text
opcode (6) | rs (5) | rt (5) | immediate (16)
```

- `opcode`: identifica a instrução;
- `rs`: registrador base ou primeiro operando;
- `rt`: registrador destino ou segundo operando;
- `immediate`: constante de 16 bits ou deslocamento.

Exemplos:

```asm
addi $t0, $t1, 4
lw $t0, 8($sp)
beq $t0, $t1, fim
```

Esse formato é muito usado quando a instrução depende de constantes pequenas ou de endereçamento relativo.

#### Formato J

O formato `J` é usado em instruções de salto incondicional.

Estrutura:

```text
opcode (6) | address (26)
```

- `opcode`: identifica a operação de salto;
- `address`: campo com o endereço alvo do salto.

Exemplos:

```asm
j loop
jal funcao
```

O formato `J` é utilizado para transferir o fluxo de execução para outro ponto do programa. No caso de `jal`, além do salto, o endereço de retorno é salvo para permitir a volta da subrotina.

## 📖 Ementa da Disciplina

1. **Funcionamento Básico de um Computador**: Como o hardware entende um programa, níveis de abstração de linguagens, compilação x interpretação. Interface hw/sw: ISA (arquitetura de repertório de instruções). Ilustrar a execução de um programa utilizando os diferentes componentes de um computador.
2. **Operações e Linguagem de Montagem**: Como são feitas operações aritméticas em um computador e onde são armazenados os operandos. Apresentação da linguagem de montagem do processador MIPS. Operações lógicas e desvios. Representação das instruções do MIPS.
3. **Repertório Avançado do MIPS**: Subrotinas. Representação de diferentes tipos de dados. Diferentes modos de endereçamento.
4. **Ciclo de Processamento**: Ciclo de processamento de uma instrução. Implementação monociclo de um processador MIPS e implementação multiciclo de um processador MIPS.
5. **Diagrama de Blocos**: Apresentação do diagrama de blocos do processador.
6. **Desempenho e Prática**: Parâmetros que afetam o desempenho de um computador. Aula prática – Verilog, ambiente de projeto.
7. **Pipeline**: Implementação pipeline de uma CPU. Conceito e filosofia de pipeline. Comparação com implementações monociclo e multiciclo. Conflitos em um pipeline (estrutural, controle e dado). Resolução de conflitos. Tratamento de exceções em pipelines.

## 🎯 Propósito e Metas de Estudo

- Construir resumos técnicos e bem estruturados sobre os temas solicitados.
- Incorporar pensamentos críticos e reflexões sobre limitações e aplicações práticas das arquiteturas estudadas.
- Relacionar o conteúdo teórico com a aplicação prática na computação sempre que possível.
- Documentar exemplos de código e resoluções detalhadas (baseadas em exercícios, provas anteriores e projetos).
- Manter um acervo de questões práticas e resoluções (fáceis, médias e difíceis) com gabaritos detalhados para fixação.

## 🔗 Links Úteis

- [Site da Disciplina (Material de Aula)](https://sites.google.com/a/cin.ufpe.br/if674cc/material-de-aula?authuser=0)

---

_Este repositório visa dar suporte aos estudos de Engenharia da Computação, orientando a evolução na construção e entendimento de arquiteturas computacionais._
