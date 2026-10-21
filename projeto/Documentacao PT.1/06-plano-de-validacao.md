# 06 — Plano de validação

[Índice](README.md) · [Catálogo](02-catalogo-23-instrucoes.md) · [PUSH/POP](04-maquina-de-estados.md) · [Mermaid](08-atlas-mermaid.md)

## 1. Conferência realizada

Foram conferidos a lista/codificação das 23 instruções, a semântica da seção 2.7, a preservação de 38 blocos principais e a remoção dos caminhos exclusivos de XCHG/SRAM. As tabelas, os fluxos de PUSH/POP e o exemplo usam a mesma ordem de microoperações.

**Não executado:** simulação do processador, síntese ou teste em FPGA. Não estavam disponíveis módulos HDL na pasta do projeto. As tabelas abaixo são o oráculo esperado para esses testes.

## 2. Testes prioritários

| ID | Preparação/execução | Resultado esperado |
|---|---|---|
| P01 | Inicialização | R29=227 antes da primeira busca; verificar comportamento durante reset separadamente, D02. |
| P02 | SP=227; R8=0xAABBCCDD; PUSH R8 | SP=223; M32[223]=0xAABBCCDD; R8 preservado. |
| P03 | SP=223; M32[223]=0xAABBCCDD; POP R9 | R9=0xAABBCCDD; SP=227; memória pode ficar igual. |
| P04 | R8=0x11111111; R9=0x22222222; PUSH R8; PUSH R9; POP R10; POP R11 | SP: 227→223→219→223→227; R10=0x22222222; R11=0x11111111. |
| P05 | SP=227; PUSH R29 | SP=223; M32[223]=227 (0x000000E3), e não 223. |
| P06 | rs e rt distintos em uma instrução PUSH | O dado salvo vem de rs; rt não é operando. |
| P07 | rd e rt distintos em uma instrução POP | O destino da palavra é rd, além da atualização de R29. |
| P08 | Observar POP_RD e POP_SP | RegWrite em estados diferentes: primeiro rd, depois 29. |
| P09 | Leitura com a latência especificada | MDRWrite apenas em POP_CAP; endereço estável em REQ/WAIT/CAP. |
| P10 | Salvar 0x12345678 no endereço 223 | Bytes 223..226: 78 56 34 12; não arredondar endereço. |
| P11 | Observar PC e IR após a busca | Permanecem estáveis durante os estados de execução de PUSH/POP. |
| P12 | Executar ADDI, LW e SLL antes/depois da pilha | Read1Sel/Read2Sel retornam à seleção normal. |
| P13 | opcode=0/funct=5; opcode=0/funct=6; opcode=5 | Despachar PUSH, POP e BNE, respectivamente. |
| P14 | Opcode 1 da antiga SRAM | Instrução inválida; não usar MDR como quantidade de SHIFT. |
| P15 | POP R29 | Caso a confirmar: a sequência proposta faz SP antigo+4 prevalecer. |
| P16 | Antes de INIT_SP, colocar um valor diferente de 227 em ALUOut | MemtoReg=1000 seleciona a constante 227, sem truncar o seletor para três bits. |
| P17 | Observar F em PUSH_DEC, POP_ADDR e POP_INC | F=010, 000 e 001, respectivamente; POP muda a operação sem modificar IR. |
| P18 | Executar um desvio antes de PUSH/POP e observar os estados da pilha | PCWrite=PCWriteCond=0 durante execução; MULT/DIV não iniciam e SHIFT mantém o valor. |

## 3. Palavras de instrução para uma demonstração

PUSH/POP são extensões da disciplina e podem não ser aceitas por um montador MIPS genérico. As palavras abaixo seguem os campos das tabelas.

| Instrução | Palavra hexadecimal | Objetivo |
|---|---|---|
| lui r8, 0xAABB | 0x3C08AABB | Metade alta |
| addi r8, r8, 0x7FFF | 0x21087FFF | Primeira parcela da metade baixa |
| addi r8, r8, 0x4CDE | 0x21084CDE | 0x7FFF+0x4CDE=0xCCDD; R8=0xAABBCCDD |
| push r8 | 0x01000005 | rs=8 em [25:21], funct=5 |
| pop r9 | 0x00004806 | rd=9 em [15:11], funct=6 |
| push r29 | 0x03A00005 | Teste de preservação de SP antigo |

Dois imediatos positivos evitam interpretar 0xCCDD como imediato negativo de ADDI. A inicialização deve preparar R29=227. O testbench pode parar depois da instrução alvo; não foi inventada uma instrução HALT.

## 4. Regressão das outras 21 instruções

Os casos de cada instrução estão no [catálogo](02-catalogo-23-instrucoes.md). Cobrir também:

- ADD/ADDI/SUB: caso normal e overflow, sem escrita indevida.
- BEQ/BNE: condição verdadeira/falsa e offsets positivos/negativos.
- LW/SW: endereço efetivo, endianidade e origem rt do dado; usar B em SW.
- LB/SB: quatro posições de byte e preservação dos vizinhos.
- SLT: negativos, positivos, igualdade e extremos; resultado apenas 0/1.
- SLL/SRA: shamt=0 e 31; separar carga e deslocamento síncrono.
- MULT/DIV: combinações de sinais, conclusão e resultados HI/LO.
- MFHI/MFLO: transferência sem alterar a origem.
- J/JR/JAL: alvo e retorno conforme a convenção D01.
- Exceções: EPC=P; leitura dos bytes 253/254/255 e extensão com zeros.

## 5. Sinais da forma de onda

`state, clock, reset, PCWrite, PCWriteCond, PC, IR, Read1Sel, Read2Sel, AWrite, BWrite, A, B, ALUOp, F, ALUOutWrite, ALUOut, IorD, DataSource, MemtoReg, wr, mem_addr, mem_data_in, mem_data_out, MDRWrite, MDR, RegWrite, WriteRegister, WriteData, R29`.

Mostrar valores antes/depois da borda, com escala suficiente para distinguir POP_RD de POP_SP. Registrar expectativas separadamente dos resultados medidos.

## 6. Verificação documental final — 12/09/2026

- 11 arquivos Markdown organizados e 106 links internos conferidos, sem destinos ausentes.
- 23 entradas de instruções conferidas, na ordem das tabelas da especificação.
- 13 blocos Mermaid renderizados sem erros; os diagramas principais de PUSH/POP e do exemplo foram inspecionados visualmente.
- Seis palavras de instrução da demonstração conferidas pelos campos binários; valores e bytes do exemplo 227 → 223 → 227 conferidos aritmeticamente.
- Revisão de continuidade acrescentada em 00; conferidos os controles de PCWriteCond, a seleção de F por estado e a largura de MemtoReg na documentação.

Essa verificação valida o material e os exemplos; não substitui uma simulação HDL da CPU.
