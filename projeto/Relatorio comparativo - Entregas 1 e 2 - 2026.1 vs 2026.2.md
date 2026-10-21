# Relatório comparativo das especificações do Projeto IF674

## Entregas 1 e 2 - 2026.1 versus 2026.2

Data da análise: 7 de setembro de 2026

## 1. Objetivo e escopo

Este relatório compara integralmente as especificações do projeto de Infra-Estrutura de Hardware dos períodos 2026.1 e 2026.2, com ênfase nas duas primeiras entregas:

1. projeto da arquitetura do processador; e
2. máquina de estados da unidade de controle.

A comparação considerou o texto, as tabelas de instruções, a numeração das seções e a apresentação visual dos dois documentos.

## 2. Resumo executivo

As instruções formais das Entregas 1 e 2, descritas no Capítulo 1, são textualmente iguais nos dois semestres. Continuam sendo exigidos uma cartolina com o diagrama completo da arquitetura e outra cartolina com a máquina de estados da unidade de controle, além da apresentação presencial por todos os integrantes.

A alteração substantiva está no conjunto de instruções da CPU:

- em 2026.1, o projeto exigia `xchg` e `sram`;
- em 2026.2, `xchg` e `sram` foram removidas;
- em 2026.2, foram acrescentadas `push` e `pop`.

O total permanece em 23 instruções listadas, mas a distribuição muda: 2026.1 possui 12 instruções do formato R, 9 do formato I e 2 do formato J; 2026.2 possui 13 do formato R, 8 do formato I e 2 do formato J.

Essa troca exige revisão do caminho de dados, dos sinais de controle e dos estados da FSM. Não é seguro reutilizar sem alterações as cartolinas de 2026.1.

## 3. Divergências encontradas

| Item | Especificação 2026.1 | Especificação 2026.2 | Consequência |
|---|---|---|---|
| Identificação | Capa indica 2026.1 | Capa indica 2026.2 | Mudança administrativa |
| Quantidade de páginas | 18 páginas | 19 páginas | A nova seção de `push` e `pop` acrescenta uma página |
| `xchg` | Presente no formato R | Removida | Excluir datapath, controle e estados exclusivos da troca entre duas posições de memória |
| `sram` | Presente no formato I | Removida | Excluir datapath, controle e estados exclusivos do deslocamento aritmético cujo número de posições vem da memória |
| `push` | Ausente | Adicionada ao formato R | Incluir decremento do SP e escrita de uma palavra na pilha |
| `pop` | Ausente | Adicionada ao formato R | Incluir leitura de uma palavra da pilha, escrita em `rd` e incremento do SP |
| Explicação da pilha | Somente regras gerais da pilha e do reset | Mantém as regras gerais e adiciona a seção 2.7, com exemplos de `push` e `pop` | A pilha passa a ser manipulada também por instruções próprias |
| Numeração posterior | Componentes: 2.7; exceções: 2.8; relatório inicia na p. 14 | Componentes: 2.8; exceções: 2.9; relatório inicia na p. 15 | Renumeração editorial, sem mudança de conteúdo técnico nessas seções |
| Anotações visuais | A página 7 contém anotações manuscritas azuis sobre os campos da instrução e uma nota parcial | Essas anotações não aparecem | Marcação não normativa; não deve ser tratada como requisito |

Fora dos itens acima, o comparativo textual não identificou mudanças de conteúdo nos procedimentos das Entregas 1 e 2, nos componentes fornecidos, no tratamento de exceções ou na especificação do relatório final.

## 4. Comparação exata das instruções alteradas

### 4.1 Instruções removidas em 2026.2

| Instrução de 2026.1 | Formato/codificação | Semântica especificada | Impacto que deixa de existir em 2026.2 |
|---|---|---|---|
| `xchg rs, rt` | R; opcode `0x0`; `rs`; `rt`; funct `0x5` | `Mem[rs]` troca de conteúdo com `Mem[rt]` | A CPU não precisa mais executar duas leituras e duas escritas para trocar posições de memória, nem manter temporariamente os dois valores |
| `sram rt, offset(rs)` | I; opcode `0x1`; `rs`; `rt`; `offset` | `rt <- rt >> Mem[offset + rs]`, com deslocamento aritmético | A CPU não precisa mais buscar na memória a quantidade do deslocamento e encaminhá-la ao registrador de deslocamento |

### 4.2 Instruções adicionadas em 2026.2

| Instrução de 2026.2 | Formato/codificação | Semântica especificada |
|---|---|---|
| `push rs` | R; opcode `0x0`; `rs` em `[25:21]`; funct `0x5` | Primeiro faz `SP <- SP - 4`; depois grava `Mem[SP] <- rs`, usando o novo valor de SP |
| `pop rd` | R; opcode `0x0`; `rd` em `[15:11]`; funct `0x6` | Primeiro lê `rd <- Mem[SP]`; depois faz `SP <- SP + 4` |

O código de função `0x5`, antes usado por `xchg`, foi reaproveitado por `push`. O opcode `0x1`, antes usado por `sram`, fica sem instrução correspondente na nova tabela.

## 5. Requisitos comuns às duas entregas

Os requisitos a seguir permanecem iguais em 2026.1 e 2026.2.

### 5.1 Regras gerais

- As duas etapas devem ser feitas em cartolinas, preferencialmente brancas.
- As dúvidas devem ser encaminhadas aos monitores.
- As cartolinas devem ser guardadas após as apresentações, pois servem de base para a implementação em Verilog.
- A apresentação ocorre em aula de laboratório, na data indicada na página da disciplina.
- Todos os integrantes devem estar presentes e podem ser questionados individualmente.

### 5.2 Entrega 1 - projeto da arquitetura

A primeira cartolina deve apresentar:

- todos os circuitos que compõem o processador;
- todas as ligações relevantes para compreender a execução das instruções;
- obrigatoriamente, todos os sinais que chegam à unidade de controle ou partem dela;
- os sinais de controle de saída devidamente nomeados;
- as interligações entre as demais unidades;
- uma arquitetura coerente, econômica e capaz de executar rapidamente o conjunto de instruções.

Não é necessário desenhar os sinais de clock e reset presentes na maioria das unidades. Cada integrante deve conseguir explicar quais unidades participam de cada estágio de uma instrução e como elas se comportam.

### 5.3 Entrega 2 - máquina de estados

A segunda cartolina deve apresentar:

- todos os estados usados pela unidade de controle durante a execução das instruções;
- o nome e o valor dos sinais de saída modificados em cada estado;
- as transições entre os estados;
- o caminho percorrido pela FSM para cada instrução.

Não é necessário repetir em todo estado os sinais que não sofreram alteração. Na apresentação, cada integrante deve conseguir explicar os estados e identificar quais deles são percorridos por uma instrução solicitada pelo professor.

## 6. Relatório da Entrega 1 - impacto no projeto da arquitetura

### 6.1 O que deve ser removido ao migrar um projeto de 2026.1

Um diagrama herdado de 2026.1 deve ter removidos ou justificados quaisquer caminhos e registradores temporários usados somente por:

- leitura de `Mem[rs]` e `Mem[rt]`, armazenamento temporário dos dois valores e escrita cruzada de `xchg`;
- cálculo de `rs + offset`, leitura da memória e uso do resultado como quantidade de deslocamento em `sram`.

Blocos compartilhados com outras instruções não devem ser removidos. É preciso eliminar apenas a lógica que ficou sem função no conjunto de 2026.2.

### 6.2 O que deve ser acrescentado ou verificado para 2026.2

O caminho de dados deve permitir, no mínimo:

1. selecionar o registrador 29 como SP, mesmo que ele não apareça explicitamente no campo `rs` ou `rt` da instrução;
2. encaminhar o SP à ALU;
3. somar ou subtrair a constante 4;
4. escrever o valor atualizado de volta no registrador 29;
5. usar o SP decrementado como endereço de memória em `push`;
6. encaminhar o conteúdo de `rs` para a entrada de dados da memória em `push`;
7. usar o SP atual como endereço de leitura em `pop`;
8. encaminhar a palavra lida da memória para a escrita de `rd` em `pop`;
9. preservar os valores intermediários durante a latência da memória, cuja leitura só fica disponível no pulso de clock seguinte.

É provável que esses requisitos sejam atendidos com novos seletores de multiplexadores, rotas para a constante 4 e novos sinais de controle, reutilizando ALU, banco de registradores, memória, ALUOut/MDR ou registradores equivalentes. A topologia exata depende da arquitetura do grupo.

### 6.3 Sequências funcionais que o grupo deve saber explicar

#### `push rs`

1. buscar e decodificar a instrução;
2. obter `rs` e o registrador 29;
3. calcular `SP - 4`;
4. atualizar o registrador 29;
5. escrever o conteúdo original de `rs` na memória no endereço do novo SP.

#### `pop rd`

1. buscar e decodificar a instrução;
2. obter o registrador 29;
3. requisitar a leitura da memória no endereço do SP atual;
4. aguardar/disponibilizar o dado conforme a temporização da memória;
5. escrever o dado lido em `rd`;
6. calcular `SP + 4` e atualizar o registrador 29.

Algumas dessas operações podem ser combinadas se a arquitetura preservar corretamente o endereço antigo do SP e respeitar a temporização dos componentes. O comportamento observável, entretanto, deve ser exatamente o definido acima.

### 6.4 Checklist da Entrega 1 para 2026.2

- [ ] `xchg` não aparece no diagrama nem na explicação das instruções.
- [ ] `sram` não aparece no diagrama nem na explicação das instruções.
- [ ] `push` usa `rs` como dado a ser empilhado.
- [ ] `pop` usa `rd` como destino.
- [ ] O registrador 29 é selecionável como SP.
- [ ] O reset inicializa o SP com o endereço 227.
- [ ] A pilha cresce de endereços maiores para menores.
- [ ] `push` usa pré-decremento de 4 bytes.
- [ ] `pop` usa pós-incremento de 4 bytes.
- [ ] A leitura da memória respeita a latência de um ciclo.
- [ ] Todos os sinais ligados à unidade de controle estão desenhados e nomeados.
- [ ] Não existem componentes sem uma função clara.

## 7. Relatório da Entrega 2 - impacto na máquina de estados

### 7.1 Estados que deixam de ser necessários

A FSM de 2026.2 não deve possuir ramificações exclusivas para `xchg` ou `sram`. Se estados dessas instruções tiverem sido compartilhados com outras operações, eles podem permanecer, desde que as transições e os sinais sem uso sejam revisados.

### 7.2 Estados necessários para `push`

Uma decomposição possível, a ser adaptada ao datapath do grupo, é:

| Estado funcional | Operação principal | Sinais/seletores a evidenciar no diagrama |
|---|---|---|
| Decodificação de `push` | Reconhecer opcode `0x0` e funct `0x5` | condição de transição da FSM |
| Leitura de operandos | Ler `rs` e selecionar `r29` | seletores das portas do banco e cargas dos registradores temporários |
| Cálculo do novo SP | `SP - 4` | operação da ALU, fontes da ALU e carga do registrador de resultado |
| Atualização do SP | `r29 <- SP - 4` | `RegWrite`, destino fixo 29 e fonte do dado |
| Escrita na pilha | `Mem[novo SP] <- rs` | fonte do endereço, fonte de `Data_in` e sinal de escrita da memória |

### 7.3 Estados necessários para `pop`

Uma decomposição possível é:

| Estado funcional | Operação principal | Sinais/seletores a evidenciar no diagrama |
|---|---|---|
| Decodificação de `pop` | Reconhecer opcode `0x0` e funct `0x6` | condição de transição da FSM |
| Leitura do SP | Selecionar `r29` | seletor do banco e carga do registrador temporário |
| Requisição de memória | Ler `Mem[SP]` | fonte do endereço e modo de leitura |
| Captura/escrita do dado | `rd <- Mem[SP]` | carga do MDR, `RegWrite`, destino `rd` e fonte do dado |
| Cálculo do novo SP | `SP + 4` | operação e fontes da ALU |
| Atualização do SP | `r29 <- SP + 4` | `RegWrite`, destino fixo 29 e fonte do dado |

A FSM pode executar o incremento do SP em paralelo com parte da leitura se o datapath preservar o endereço original e não violar a latência da memória. Se isso não estiver garantido, os estados devem permanecer separados.

### 7.4 Checklist da Entrega 2 para 2026.2

- [ ] A decodificação distingue `push` (`funct = 0x5`) de `pop` (`funct = 0x6`).
- [ ] Não existem transições exclusivas para `xchg` ou `sram`.
- [ ] Os estados de `push` deixam explícito que o SP é decrementado antes da escrita.
- [ ] Os estados de `pop` deixam explícito que a memória é lida antes do incremento do SP.
- [ ] A latência de leitura da memória foi considerada.
- [ ] Todo estado mostra os nomes e valores dos sinais que mudam.
- [ ] O estado seguinte de cada transição está inequívoco.
- [ ] O grupo consegue percorrer verbalmente a FSM de todas as 23 instruções.
- [ ] O reset conduz a CPU ao estado inicial e estabelece `r29 = 227`.

## 8. Pontos de atenção que não são divergências

- O texto sobre exceções menciona a instrução `rte`, embora ela não apareça nas tabelas-resumo de instruções. Isso ocorre nos dois documentos e deve ser confirmado com professor ou monitor caso sua implementação ainda não esteja esclarecida.
- As exigências do relatório final são idênticas. A única mudança é o deslocamento do início do Capítulo 3 da página 14 para a página 15.
- As instruções `addi`, `lui`, `lw` e `lb` continuam destacadas como essenciais para carregar dados.
- Permanecem as três exceções: opcode inexistente, overflow e divisão por zero.
- Os seis componentes fornecidos continuam os mesmos.

## 9. Conclusão

A especificação de 2026.2 preserva o formato das duas primeiras entregas e quase toda a CPU de 2026.1. A única mudança técnica substantiva é a substituição de `xchg` e `sram` por `push` e `pop`.

Para adaptar um projeto anterior, a prioridade é revisar três pontos: decodificação das funções/opcodes, caminhos de dados envolvendo memória e registrador 29, e sequência de estados da unidade de controle. O restante do projeto pode ser reaproveitado desde que cada componente e sinal mantenha uma função necessária no conjunto atual.

## 10. Fontes e páginas-chave

- Especificação 2026.1: Entregas 1 e 2 nas páginas 4-5; conjunto de instruções nas páginas 7-8; componentes e exceções nas páginas 11-14; relatório final nas páginas 14-18.
- Especificação 2026.2: Entregas 1 e 2 nas páginas 4-5; conjunto de instruções nas páginas 7-8; `push` e `pop` nas páginas 10-11; componentes e exceções nas páginas 11-14; relatório final nas páginas 15-19.
