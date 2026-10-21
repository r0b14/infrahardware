# 01 — Análise do circuito existente

[Índice](README.md) · [Catálogo](02-catalogo-23-instrucoes.md) · [PUSH/POP](04-maquina-de-estados.md) · [Mermaid](08-atlas-mermaid.md)

## 1. Escopo da alteração

O quadro recebido já contém a estrutura de um processador multiciclo. A revisão mantém essa estrutura e acrescenta os caminhos necessários para a pilha. As outras 21 instruções continuam no conjunto exigido e foram analisadas documentalmente.

**Saem:** XCHG (R) e SRAM (I). **Entram:** PUSH, opcode `0x00` e funct `0x05`; POP, opcode `0x00` e funct `0x06`. O opcode I `0x01`, antes associado a SRAM, deixa de integrar o conjunto válido. O funct `0x05` passa a despachar PUSH.

## 2. Estrutura reaproveitada


| Conjunto          | Blocos visíveis                                  | Reaproveitamento                          |
| ----------------- | ------------------------------------------------ | ----------------------------------------- |
| Busca             | PC, memória, IR, IorD e PCSource                 | Busca comum às instruções                 |
| Operandos         | Banco, A e B                                     | R29 é capturado em A; o dado de PUSH em B |
| Aritmética        | ALU, constante 4, muxes da ALU e ALUOut          | SP−4, cópia do SP e SP+4                  |
| Memória e escrita | Memória, MDR, DataSource, RegDst e MemtoReg      | Palavra da pilha, escrita de rd e de R29  |
| Outras instruções | HI/LO, MULT, DIV, SHIFT, extensores e MergeBytes | Permanecem no circuito                    |
| Controle          | UC, ALUControl, EPC e lógica de PC               | A UC recebe os estados documentados em 04 |


## 3. Alterações realizadas no desenho

- Acrescentados Read1Sel (rs/29) e Read2Sel (rt/rs) antes das portas de leitura existentes.
- Acrescentado o índice 29 à entrada 3 de RegDst.
- Reaproveitada a entrada 2 de DataSource para o barramento B usado na gravação de PUSH.
- Acrescentada a constante 227 à entrada 8 de MemtoReg para a proposta INIT_SP.
- Explicitados **AWrite** e **BWrite** para conservar os operandos.
- Alinhados os fios aos rótulos dos muxes que ganharam entradas, preservando a numeração das fontes anteriores.

## 4. Achados das demais instruções

Estes itens são conferências para implementação/validação. Não indicam alterações adicionais feitas no desenho nesta revisão.


| ID  | Tema       | Evidência e consequência                                                    | Conferência necessária                                                                                          |
| --- | ---------- | --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| A01 | SLT        | O bloco que recebe LT está rotulado Sign Extend.                            | Se replicar o bit 1, dará 0xFFFFFFFF. O correto é {31 zeros, LT}, com comparação com sinal.                     |
| A02 | SW         | A entrada 0 de DataSource deriva de A, normalmente a base rs.               | O dado de SW deve ser B=R[rt]. A entrada 2 ligada a B nesta revisão também pode atender SW; selecioná-la na UC. |
| A03 | BNE        | EQ e PCWriteCond aparecem, mas a escolha entre EQ e !EQ não está explícita. | BEQ usa EQ; BNE usa !EQ. Testar condições verdadeiras e falsas.                                                 |
| A04 | J/JAL      | O rótulo dos quatro bits altos aparenta referir-se à instrução.             | Os bits altos do alvo devem vir do PC corrente, conforme seção 2.5.                                             |
| A05 | JAL        | O destino 31 existe; o valor de retorno depende do controle.                | Proposta sem delay slot: link=P+4. Pode passar PC pela ALU/ALUOut e escrever R31.                               |
| A06 | LB/SB      | MergeBytes existe; sua operação interna não aparece.                        | Definir seleção/extensão do byte e preservação dos vizinhos. A memória não oferece byte-enable.                 |
| A07 | LUI/shifts | SHIFT e muxes já existem, com fontes parcialmente não nomeadas.             | LUI pelo SHIFT exige imediato como dado e 16 como quantidade; SLL/SRA usam rt e shamt.                          |
| A08 | Memória    | Leitura com latência, escrita de um ciclo e único wr.                       | Não capturar IR/MDR no pulso da requisição. Traduzir os rótulos MemRead/MemWrite para a interface real.         |
| A09 | MULT/DIV   | Componentes separados e HI/LO estão presentes.                              | Conferir algoritmo, sinal, início/fim, ciclos e escritas HI/LO; desenho não comprova execução.                  |
| A10 | Exceções   | EPC e constantes 253/254/255 aparecem.                                      | EPC recebe P; PC recebe o byte lido do vetor, estendido com zeros. Não saltar diretamente para 253/254/255.     |
| A11 | Reset/SP   | O banco limpa registradores; SP deve iniciar em 227.                        | INIT_SP está explícito em 04; compatibilidade durante reset é a pendência D02.                                  |
| A12 | Pilha      | O endereço oficial 223 não é múltiplo de quatro.                            | Não arredondar para 220; conferir quatro bytes consecutivos a partir do endereço exato.                         |


