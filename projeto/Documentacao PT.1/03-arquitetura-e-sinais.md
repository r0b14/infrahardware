# 03 — Extensão do circuito e sinais

[Índice](README.md) · [Catálogo](02-catalogo-23-instrucoes.md) · [PUSH/POP](04-maquina-de-estados.md) · [Mermaid](08-atlas-mermaid.md)

## 1. Ideia central

SP é **R29 do banco existente**, não um novo registrador independente. A extensão lê R29, calcula mais ou menos quatro e escreve R29 pela porta que já escreve os demais registradores.

Durante a captura de PUSH, **A recebe SP antigo e B recebe R[rs] antigo**. POP reutiliza A, a memória e o MDR. A/B já faziam parte da estrutura.

## 2. Seletores e habilitações


| Sinal                | Largura         | Seleções relevantes                   | Uso                                                    |
| -------------------- | --------------- | ------------------------------------- | ------------------------------------------------------ |
| Read1Sel             | 1               | 0=rs; 1=29                            | 1 na captura de PUSH/POP                               |
| Read2Sel             | 1               | 0=rt; 1=rs                            | 1 na captura de PUSH                                   |
| RegDst               | 2               | 0=rt; 1=rd; 2=31; 3=29                | 3 escreve SP; 1 escreve o destino de POP               |
| MemtoReg             | 4 após extensão | 0=ALUOut; 1=MDR; 8=227                | As fontes anteriores 0–7 foram mantidas                |
| DataSource           | 2               | 0=fonte A anterior; 1=MergeBytes; 2=B | 2 fornece o dado de PUSH e também o dado correto de SW |
| IorD                 | 1 útil          | 0=PC; 1=ALUOut                        | 1 nos acessos da pilha                                 |
| ALUSrcA              | 1               | 0=PC; 1=A                             | 1 opera sobre SP antigo                                |
| ALUSrcB              | 2               | 0=B; 1=4; 2=SE16; 3=SE16<<2           | 1 para SP±4                                            |
| ALUControl / F       | 3               | 000=passa A; 001=soma; 010=subtrai    | Códigos da ALU fornecida                               |
| AWrite/BWrite        | 1 cada          | 1=captura; 0=conserva                 | Capturar na decodificação e conservar durante execução |
| ALUOutWrite/MDRWrite | 1 cada          | 1=captura; 0=conserva                 | Reter endereço e leitura                               |
| RegWrite             | 1               | Uma escrita no banco                  | rd e SP em estados separados                           |
| wr da memória        | 1               | 0=lê; 1=escreve                       | 1 somente em PUSH_STORE nesta extensão                 |


Se IorD já for declarado com dois bits na UC, pode-se manter a largura e reservar os códigos 2/3. A retirada dos fios não exige renumerar os estados anteriores.

## 3. Fontes do mux de escrita preservadas


| MemtoReg | Fonte no quadro                                                  | Uso/conferência                                           |
| -------- | ---------------------------------------------------------------- | --------------------------------------------------------- |
| 0        | ALUOut                                                           | Também escreve SP±4                                       |
| 1        | MDR                                                              | Também escreve o destino de POP                           |
| 2        | HI                                                               | MFHI                                                      |
| 3        | LO                                                               | MFLO                                                      |
| 4        | SHIFT                                                            | SLL/SRA; LUI se os muxes forem adequados                  |
| 5        | Bloco ligado a LT                                                | Conferir a formação de 0/1, A01                           |
| 6        | Derivação anterior próxima ao barramento do extensor de imediato | Preservada; não foi atribuída arbitrariamente a PC ou LUI |
| 7        | MergeBytes                                                       | Conferir operação interna de bytes                        |
| 8        | Constante 227                                                    | Nova entrada INIT_SP                                      |


## 4. Por que POP copia SP para ALUOut

O IorD preservado já seleciona ALUOut como endereço. POP_ADDR usa `ALUSrcA=1` e `F=000` para executar `ALUOut ← A`. Dessa forma, lê M32[SP antigo] sem um novo caminho direto A → memória.

Depois, POP_INC reutiliza a ALU para A+4. Como A ficou retido, a atualização de SP não depende do valor escrito em rd.

## 5. Operações anteriores e retenção

- Demais instruções: Read1Sel=0 e Read2Sel=0, mantendo A=R[rs] e B=R[rt].
- PUSH: Read1Sel=1 e Read2Sel=1, capturando A=R29 e B=R[rs].
- POP: Read1Sel=1; B não é necessário e pode ficar sem habilitação.
- Após a captura: AWrite=BWrite=0 durante PUSH/POP. Isso protege inclusive PUSH R29.

## 6. Inicialização e interface de controle

**29 é um índice de 5 bits; 227 é um dado de 32 bits.** INIT_SP usa RegDst=3, MemtoReg=8 e RegWrite=1 antes da primeira busca. A exigência durante reset precisa da conferência D02, pois o banco fornecido é descrito como limpando todos os registradores.

Os sinais nomeados no circuito são saídas da UC a implementar conforme 04. MemRead no esquema não cria um pino adicional na memória: a interface fornecida tem apenas wr. Manter wr=0 e desabilitar IRWrite/MDRWrite fora de leituras úteis impede capturas indevidas.

## 7. Ligação entre a UC e ALUControl

Os valores F=000/001/010 documentados são os códigos que devem chegar à ALU fornecida. Se a UC passa por ALUControl, sua saída ALUOp deve produzir esses códigos **de acordo com o estado**, sem decodificar funct=5/6 como uma operação aritmética fixa.


| Estado   | Operação exigida | F na entrada da ALU |
| -------- | ---------------- | ------------------- |
| PUSH_DEC | A−4              | 010                 |
| POP_ADDR | Passar A         | 000                 |
| POP_INC  | A+4              | 001                 |


O mesmo POP precisa de F=000 e depois F=001, embora o conteúdo de IR permaneça igual. Portanto, funct sozinho não determina a operação em todos os ciclos. A codificação interna de ALUOp deve ser conciliada com o módulo existente; não foi inventada uma nova tabela de ALUOp sem seu código.

Ao implementar a entrada 8 de MemtoReg, ampliar também a declaração do seletor na UC e no mux para quatro bits. Truncar 1000 para três bits selecionaria a entrada 0, gravando ALUOut no lugar de 227.