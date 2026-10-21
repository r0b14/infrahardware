# Avaliação das 23 instruções do Projeto IH 2026.2

Avaliação da especificação e do estado observado no FigJam em 11/09/2026, no horário de Brasília. As conclusões sobre o quadro correspondem à versão consultada nesta análise.

A especificação exige **23 instruções: 13 do formato R, 8 do formato I e 2 do formato J**. O projeto já tem um datapath multiciclo desenhado, incluindo ALU, memória, banco de registradores, HI/LO e deslocador. Há estados específicos esboçados para **ADD, SUB, AND, ADDI, BEQ e BNE**. As outras 17 instruções ainda não têm suas sequências de estados representadas no quadro consultado.

Essa contagem descreve o desenho, não comprova execução. A avaliação foi documental e estrutural: leitura do PDF, inspeção dos elementos e conectores do FigJam e conferência visual das áreas do quadro. Não foram fornecidos nem encontrados arquivos HDL ou simulações na pasta `Projeto`; portanto, não há validação funcional do processador nesta análise.

## 1. Fontes e critério de avaliação

- [Especificação Projeto 2026-2](<C:/Users/Robso/OneDrive/Documentos/Faculdade - Engenharia da Computação - UFPE/12Período 2026.2/IF674 - INFRAHARDWARE/Projeto/Especificacao Projeto 2026-2.pdf>): páginas 7-8, Figure 2 e Tables 1-3, para a lista e os campos das instruções; páginas 8-14 para as seções às quais as tabelas remetem, a temporização dos componentes e as exceções; páginas 4-5 para os requisitos do desenho e da FSM.
- [Projeto-IH-26.2 no FigJam](https://www.figma.com/board/pro2Vf1Yxoh7zA1LZp3uCN/Projeto-IH-26.2?node-id=0-1): datapath e áreas `FETCH & DECODE`, `ULA OP`, `BRANCHES` e `LOADS`.
- [Manual MIPS32, Volume II-A, revisão 3.00, da MIPS Technologies, disponibilizado pela HMC](https://pages.hmc.edu/harris/class/e155/11/MIPS32InstructionSet.pdf): referência complementar para a extensão de sinal de `lb` e para distinguir a convenção de retorno de `jal` em arquiteturas com delay slot. As regras particulares da disciplina prevalecem.

**Esboçada** significa que há estado de execução identificado no quadro. **Caminho parcial** significa que existem componentes aproveitáveis, mas faltam estados, conexões ou ambos. **Ausente** se refere à função necessária não representada, e não à inexistência de todo o hardware básico.

## 2. Avaliação individual das 23 instruções

Nas tabelas, `R[x]` é um registrador de 32 bits, `SE16` é extensão de sinal de 16 para 32 bits, `SE8` é extensão de sinal de 8 para 32 bits, `M8` é um byte da memória e `M32` é a palavra formada pelos quatro bytes do acesso. `P` é o endereço da instrução em execução e `PCseq = P + 4`.

### Table 1 da especificação: formato R, página 7

Todas estas instruções usam `opcode = 0x00`; o campo `funct = IR[5:0]` distingue as operações. `rs = IR[25:21]`, `rt = IR[20:16]`, `rd = IR[15:11]` e `shamt = IR[10:6]`.

| Instrução | funct | Comportamento exigido | Avaliação do projeto existente e trabalho restante |
|---|---|---|---|
| `add rd, rs, rt` | `0x20` | `R[rd] <- R[rs] + R[rt]` | **Esboçada.** Fontes A/B, operação de soma e write-back em `rd` são coerentes. Falta fechar os controles comuns, a captura de ALUOut e o tratamento de overflow antes de escrever o resultado. |
| `and rd, rs, rt` | `0x24` | `R[rd] <- R[rs] & R[rt]` | **Esboçada.** Operação AND e write-back em `rd` são coerentes. Falta completar fetch/decode, transições por `funct` e habilitações dos registradores. |
| `div rs, rt` | `0x1A` | Divisão com sinal; `LO <- quociente`, `HI <- resto` | **Caminho parcial.** O bloco Mult/Div recebe A/B e alimenta HI/LO. Faltam estados de início, espera e conclusão, indicação de término à UC e ligação de divisão por zero às exceções. O algoritmo interno não está mostrado. |
| `mult rs, rt` | `0x18` | Produto com sinal de 64 bits em `HI:LO` | **Caminho parcial.** Pode aproveitar o bloco Mult/Div e HI/LO. Falta explicitar o multiplicador de Booth, o controle de conclusão e a escrita do resultado. A seção 2.4 exige 32 a 40 ciclos para o componente multiplicador. |
| `jr rs` | `0x08` | `PC <- R[rs]` | **Sem estado.** Pode reutilizar A e a ALU na operação `F=000`, que copia A, encaminhando o resultado ao PC. Não é obrigatório criar uma nova entrada no mux de PC para isso. Falta fechar o retorno desse mux ao PC. |
| `mfhi rd` | `0x10` | `R[rd] <- HI` | **Caminho parcial.** HI já chega ao mux de write-back. Falta estado com seleção de HI, destino `rd` e `RegWrite=1`; HI/LO devem ser preservados. |
| `mflo rd` | `0x12` | `R[rd] <- LO` | **Caminho parcial.** LO já chega ao mux de write-back. Falta estado com seleção de LO, destino `rd` e `RegWrite=1`; HI/LO devem ser preservados. |
| `sll rd, rt, shamt` | `0x00` | `R[rd] <- R[rt] << shamt` | **Caminho parcial.** Há deslocador e retorno ao banco. Falta identificar a seleção do operando `rt`, a fatia `IR[10:6]` para N e os estados de carga, deslocamento lógico à esquerda e write-back em `rd`. |
| `slt rd, rs, rt` | `0x2A` | `R[rd] <- 1` se `R[rs] < R[rt]`, senão `0`, com comparação com sinal | **Função incompleta.** LT aparece na ALU, mas não está demonstrada a formação do resultado de 32 bits e seu caminho até `rd`. Usar `{31'b0, LT}` ou comprovar que a saída S da ALU já fornece exatamente 0/1. Falta a FSM. |
| `sra rd, rt, shamt` | `0x03` | Deslocamento à direita preservando o sinal | **Caminho parcial.** Reutiliza o deslocador. Falta selecionar `rt` e `shamt`, usar o modo aritmético e escrever em `rd`. Não usar o modo lógico à direita. |
| `sub rd, rs, rt` | `0x22` | `R[rd] <- R[rs] - R[rt]` | **Esboçada.** Fontes A/B, subtração e write-back em `rd` são coerentes. Falta overflow e o fechamento dos controles comuns. |
| `push rs` | `0x05` | `SP <- SP - 4`; `M32[SP] <- R[rs]` | **Suporte específico ausente.** Faltam seleção do registrador 29 para leitura e escrita, leitura simultânea do dado de `rs` e estados para pré-decrementar SP e escrever na pilha. A ALU, a constante 4 e a memória existentes são reaproveitáveis. |
| `pop rd` | `0x06` | `R[rd] <- M32[SP]`; `SP <- SP + 4` | **Suporte específico ausente.** Faltam seleção de SP, preservação do endereço antigo durante a leitura e estados para duas escritas no banco: uma em `rd` e outra em `r29`. Com uma porta de escrita, essas escritas precisam ocorrer em ciclos distintos. |

### Table 2 da especificação: formato I, página 7

O destino das instruções I que escrevem no banco é `rt = IR[20:16]`. Os bits `[15:11]` pertencem ao imediato e não representam `rd` nesse formato.

| Instrução | Opcode | Comportamento exigido | Avaliação do projeto existente e trabalho restante |
|---|---|---|---|
| `addi rt, rs, imm` | `0x08` | `R[rt] <- R[rs] + SE16(imm)` | **Esboçada com duas inconsistências.** O quadro usa `011 (ADD)`, mas a soma da ALU fornecida é `001` e `011` é AND. O write-back comum seleciona `rd`; ADDI deve selecionar `rt`. Falta também conectar o imediato ao extensor de sinal e tratar overflow. |
| `beq rs, rt, offset` | `0x04` | Se iguais: `PC <- PCseq + (SE16(offset) << 2)`; caso contrário, seguir em `PCseq` | **Esboçada com revisão necessária.** A comparação é aproveitável, mas o uso posterior de ALUOut e PCWriteCond não fecha a temporização. Falta demonstrar a condição EQ chegando ao controle do PC. |
| `bne rs, rt, offset` | `0x05` | Se diferentes: mesmo cálculo de alvo; caso contrário, seguir em `PCseq` | **Esboçada com revisão necessária.** Precisa testar `!EQ`. O quadro encaminha BEQ e BNE ao mesmo IS_TRUE, ambos com o rótulo ALU_EQ, sem distinguir as condições. Também herda o problema temporal de ALUOut. |
| `lb rt, offset(rs)` | `0x20` | `EA <- R[rs] + SE16(offset)`; `R[rt] <- SE8(M8[EA])` | **Sem estados.** A área LOADS está vazia. Falta cálculo de endereço, leitura com a latência correta, extração do byte e extensão de sinal para write-back em `rt`. O extensor do imediato, de 16 bits, não substitui automaticamente o extensor do byte, de 8 bits. |
| `lui rt, imm` | `0x0F` | `R[rt] <- {imm[15:0], 16'b0}` | **Caminho específico ausente.** Falta levar esse valor ao banco e criar o estado de escrita em `rt`. Pode usar concatenação fixa; se reutilizar o deslocador, será preciso selecionar o imediato como dado e a constante 16 como quantidade. |
| `lw rt, offset(rs)` | `0x23` | `EA <- R[rs] + SE16(offset)`; `R[rt] <- M32[EA]` | **Caminho parcial, sem estados.** ALUOut, memória, MDR e retorno ao banco já existem. Falta conectar o imediato, controlar a leitura e a captura no MDR e escrever em `rt`. |
| `sb rt, offset(rs)` | `0x28` | `M8[EA] <- R[rt][7:0]`, preservando os outros bytes | **Função incompleta.** Falta seleção/mesclagem de byte ou mecanismo equivalente, além da FSM. Uma escrita comum de 32 bits com o byte seguido de zeros não atende à especificação. |
| `sw rt, offset(rs)` | `0x2B` | `EA <- R[rs] + SE16(offset)`; `M32[EA] <- R[rt]` | **Caminho parcial, sem estados.** A rota de dados até a memória está desenhada, mas deve ser identificada explicitamente como B/`rt`. Faltam cálculo e preservação do endereço, controle de escrita e retorno ao fetch. |

Para `lb`, a Table 2 é sucinta: ela diz carregar um byte, sem detalhar a extensão. A extensão de sinal indicada acima corresponde a LB no [manual MIPS32, página 142](https://pages.hmc.edu/harris/class/e155/11/MIPS32InstructionSet.pdf#page=142); LBU é a variante que estende com zeros.

### Table 3 da especificação: formato J, página 8

| Instrução | Opcode | Comportamento exigido | Avaliação do projeto existente e trabalho restante |
|---|---|---|---|
| `j target` | `0x02` | Salto para o endereço formado pelos 4 bits altos do PC de referência e `{IR[25:0], 2'b00}`, conforme seção 2.5 | **Caminho parcial, sem estado.** Há um Shift Left 2 de salto e entrada no mux PCSource, mas não aparece sua entrada `IR[25:0]`, a concatenação dos 4 bits altos nem o retorno do mux ao PC. |
| `jal target` | `0x03` | Mesmo salto de `j`, com gravação do endereço de retorno em `R[31]` | **Função incompleta.** Além dos pontos de `j`, faltam destino fixo 31, caminho do endereço de retorno e estado de escrita. É possível passar o PC sequencial pela ALU/ALUOut já existentes, se a temporização preservar esse valor. A convenção exata do retorno precisa ser definida conforme a observação abaixo. |

A especificação não explicita a execução de delay slot nem o valor do link de `jal`. Neste relatório, as sugestões de FSM usam o modelo didático sem delay slot, no qual o retorno é `P+4`. Isso é uma **hipótese de projeto**, não uma frase da Table 3. No [MIPS32 clássico documentado, página 130](https://pages.hmc.edu/harris/class/e155/11/MIPS32InstructionSet.pdf#page=130), JAL usa delay slot e salva `P+8`. Convém confirmar a convenção da disciplina antes de fechar JAL; a referência genérica não deve impor delay slot a este projeto.

## 3. Correções prioritárias no que já está desenhado

### 3.1 ADDI: confirmar a anotação que vocês já fizeram

A anotação vermelha em [ULA OP](https://www.figma.com/board/pro2Vf1Yxoh7zA1LZp3uCN/Projeto-IH-26.2?node-id=2005-354) está correta: o write-back de ADDI não deve usar o mesmo destino fixo dos tipos R.

Pelo mux atualmente desenhado:

- `RegDst=0` seleciona `IR[20:16]`, isto é, `rt`.
- `RegDst=1` seleciona `IR[15:11]`, isto é, `rd` nas instruções R.
- `MemtoReg=0` seleciona ALUOut.

| Etapa | ADD/SUB/AND | ADDI |
|---|---|---|
| Operando A | A, contendo `R[rs]` | A, contendo `R[rs]` |
| Operando B | B, contendo `R[rt]` | Imediato de 16 bits estendido com sinal |
| Função da ALU | `001` / `010` / `011` | `001` |
| Escrita no banco | `RegWrite=1`, `RegDst=1`, `MemtoReg=0` | `RegWrite=1`, `RegDst=0`, `MemtoReg=0` |

Podem criar `WB_R` e `WB_I`, ou um write-back compartilhado cujo seletor de destino seja definido pela instrução. Apenas deixar `RegDst=1` fixo não resolve.

Os quadros usam o nome ALUOp para os códigos de três bits da ALU fornecida. Como o datapath também contém um bloco ALU Control, documentem se ALUOp é o código final F ou um código intermediário. O mapeamento entre os dois precisa ser explícito; `011` identificado simultaneamente como AND e ADD é uma inconsistência no quadro atual.

### 3.2 FETCH e DECODE: fechar o caminho comum antes de ampliar a FSM

Na área [FETCH & DECODE](https://www.figma.com/board/pro2Vf1Yxoh7zA1LZp3uCN/Projeto-IH-26.2?node-id=2011-514), FETCH contém apenas MemRead, IRWrite e IorD. DECODE seleciona PC e imediato deslocado, mas deixa `ALUOp=XX`.

Faltam definições comuns a todas as instruções:

1. Requisitar a leitura da instrução no endereço P e capturá-la quando o dado estiver válido. A memória da seção 2.8.1 não é combinacional: o texto descreve o dado disponível no pulso seguinte ao da requisição. Documentar requisição, espera e captura conforme o módulo fornecido; `IRWrite=1` no mesmo estado da primeira requisição, sem temporização adicional, não demonstra uma busca correta.
2. Atualizar o PC sequencial uma única vez: `PC <- P+4`. Usar a ALU com PC, constante 4 e soma; o PC recebe o resultado com habilitação de escrita.
3. Capturar os operandos em A e B e preservar os valores quando usados em estados posteriores.
4. Se DECODE antecipar o endereço de branch, fazer `ALUOut <- PCseq + (SE16(imm)<<2)` com soma definida, e não `XX`.
5. Decodificar opcode e, nas instruções R, funct. No desenho, funct chega ao ALU Control, mas a classificação entre aritmética, JR, HI/LO, deslocamento, PUSH e POP também precisa chegar à FSM.
6. Definir os sinais de carga/hold de IR, MDR, A, B e ALUOut, ou documentar precisamente onde a carga é incondicional e segura.

A quantidade final de estados de espera depende da implementação e das bordas dos componentes fornecidos. É necessário conferir o HDL desses componentes antes de afirmar um número exato de ciclos de leitura ou de captura.

### 3.3 BEQ e BNE: separar a condição do cálculo do endereço

Na área [BRANCHES](https://www.figma.com/board/pro2Vf1Yxoh7zA1LZp3uCN/Projeto-IH-26.2?node-id=2009-636), ambos os estados usam comparação `111`, o que é compatível com a ALU fornecida. Entretanto:

- BEQ deve tomar o desvio com `EQ=1`; BNE, com `EQ=0`. O IS_TRUE comum precisa receber essa condição já distinguida ou identificar explicitamente a instrução.
- A ALU fornecida entrega EQ/GT/LT no modo de comparação. Não se deve presumir que a saída Zero tenha o mesmo contrato nesse modo.
- Os estados PC WRITE calculam uma soma e selecionam ALUOut simultaneamente. **ALUOut é um registrador: sua saída durante o ciclo contém o resultado armazenado anteriormente.** O PC não recebe automaticamente a soma que será gravada em ALUOut na mesma borda.
- A comparação do ciclo anterior não permanece disponível como flag combinacional se a ALU já mudou para soma. Se a decisão for usada em outro estado, ela precisa estar preservada ou já incorporada à transição da FSM.
- Se o PC já avançou no fetch, o caminho de branch não tomado não deve somar 4 novamente.

Uma solução compatível com o datapath multiciclo é calcular o alvo em DECODE e usar um único estado posterior de comparação e atualização condicional:

| Fase | Ação |
|---|---|
| Fetch | Estabelecer `PCseq=P+4` e buscar IR com a temporização correta |
| Decode | Armazenar `ALUOut=PCseq+(SE16(offset)<<2)` e capturar operandos |
| Branch | Comparar A/B e, apenas se a condição da instrução for verdadeira, carregar PC com o alvo já armazenado em ALUOut |
| Continuação | Voltar ao fetch; se não tomou o desvio, PC permanece em PCseq |

Uma expressão possível para habilitar o PC é:

```text
PC_enable = PCWrite
          OR (BranchEQ AND EQ)
          OR (BranchNE AND NOT EQ)
```

Essa é uma proposta de organização. Também é possível manter comparação e salto em estados separados, desde que a decisão e o alvo sejam preservados e o estado de salto utilize a fonte temporalmente correta.

### 3.4 Conexões essenciais que ainda faltam ou estão ambíguas

| Ponto no datapath | Evidência observada | Correção necessária |
|---|---|---|
| Retorno ao PC | O mux PCSource `1:412` tem entradas, mas não há conector de saída para a entrada de dados do PC `1:6` | Desenhar `saída PCSource -> entrada de dados PC`, com 32 bits |
| Imediato | O extensor de sinal `1:150` tem saída, mas não tem entrada desenhada | Conectar `IR[15:0] -> extensão 16/32`; necessário a ADDI, loads, stores e branches |
| Salto J | Shift Left 2 `1:430` sem entrada; sua saída está rotulada como 28 bits | Conectar `IR[25:0]`, deslocar 2 e concatenar os quatro bits altos do PC de referência, formando 32 bits |
| Resultado versus flag da ALU | A ligação para PCSource=0 sai visualmente da região do rótulo Zero | Identificar a origem como **ALU Result[31:0]**; uma flag de 1 bit não pode fornecer o novo PC |
| Habilitação de IR | IRWrite aparece no estado FETCH, mas não como entrada de controle desenhada no IR | Mostrar esse sinal no datapath |
| Retornos à UC | Não aparecem rotas explícitas para EQ/LT/Overflow, término de Mult/Div e DIV0 | Acrescentar os retornos usados pela FSM e pelo controle de exceções |
| Campos da instrução | Há derivações sem rótulo saindo da região `IR[15:0]` | Identificar separadamente imediato `[15:0]`, rd `[15:11]`, shamt `[10:6]` e funct `[5:0]` |
| Sinais e seletores | Vários controles aparecem como rótulos locais e as larguras variam entre os quadros | Associar os sinais à UC e usar uma tabela única de seleção e largura de cada mux |

Um conector ligado ao canvas pode representar uma derivação intencional de barramento. Isso não foi classificado automaticamente como erro elétrico. Os problemas acima foram apontados onde falta a conexão funcional inteira ou a identificação necessária para compreender a execução.

## 4. Extensões necessárias aproveitando o circuito existente

### 4.1 Pilha: PUSH, POP e reset

A seção 2.2 define **SP como o registrador 29 e seu valor inicial como 227 decimal**. A seção 2.7 determina crescimento para endereços menores, com passos de 4 bytes. O retorno em `r31` é salvo/restaurado na pilha por software; JAL não deve empilhá-lo automaticamente.

Uma organização possível das leituras, aproveitando A, B e a rota B para a memória:

| Caso | Porta de leitura 1 / A | Porta de leitura 2 / B |
|---|---|---|
| Instruções comuns | `R[rs]` | `R[rt]` |
| PUSH | `R[29]` | `R[rs]`, dado a empilhar |
| POP | `R[29]` | Não utilizada pela operação |

Isso pode ser feito acrescentando seleção `rs/29` à primeira porta e `rt/rs` à segunda. O destino da escrita precisa poder selecionar também **29**, além de `rt` e `rd`; **31** será necessário a JAL.

Sequências funcionais sugeridas, após a busca e a decodificação:

| Instrução | Sequência |
|---|---|
| PUSH | Capturar SP e dado; `ALUOut <- SP-4`; escrever `R[29] <- ALUOut`; escrever o dado preservado em `M32[ALUOut]`; voltar ao fetch |
| POP | Capturar SP antigo; encaminhá-lo ao endereço da memória; requisitar/aguardar/capturar a leitura; escrever o dado em `rd`; calcular `SP_antigo+4`; escrever em `r29`; voltar ao fetch |

Algumas operações podem compartilhar um ciclo se não disputarem recursos e preservarem os valores necessários. O essencial é respeitar o pré-decremento de PUSH, o pós-incremento de POP e as duas escritas distintas de POP.

O banco fornecido é descrito como zerando todos os registradores no reset, enquanto a regra especial da pilha exige SP=227. O projeto precisa resolver explicitamente essa inicialização, por exemplo estabelecendo 227 antes da primeira instrução por uma sequência de inicialização compatível com o módulo, ou usando o mecanismo de reset específico adotado pela disciplina.

**Não arredondar SP para múltiplo de 4:** o exemplo oficial usa 227 e 223. Ambos têm os dois bits baixos iguais a `11`. O acesso à palavra da pilha deve seguir o endereçamento por byte da memória fornecida e preservar o endereço exigido.

### 4.2 Memória: LW/SW como base, LB/SB com tratamento de byte

LW/SW podem compartilhar o estado `EA=R[rs]+SE16(offset)` e aproveitar ALUOut. O fluxo de leitura acrescenta espera e captura em MDR; a escrita usa o valor original de `rt`.

A memória fornecida tem `add`, `Data_in`, `clock`, `wr` e `Data_out`. `wr=0` significa leitura e `wr=1`, escrita. O MemRead do desenho pode continuar como sinal interno de controle, mas sua relação com a interface real deve ser explicada.

Para SB, a interface descrita não oferece byte enable. Uma solução é ler a palavra, substituir somente o byte selecionado e escrever a palavra mesclada. Não se deve supor um pino de máscara de bytes que o componente fornecido não tem.

Antes de fixar a lógica de seleção do byte, verificar se o componente retorna quatro bytes a partir do endereço solicitado ou uma palavra alinhada. No primeiro caso, o byte do endereço solicitado pode estar em `MDR[7:0]`; no segundo, será preciso selecionar a posição correspondente. Essa decisão afeta LB, SB e os acessos à pilha. Testar preservação dos bytes vizinhos e little-endian.

### 4.3 Deslocador: SLL, SRA e a alternativa para LUI

O componente da Figure 7 é um registrador de deslocamento síncrono, com modos de carga e deslocamento distintos:

| Operação no componente | Shift |
|---|---|
| Manter valor | `000` |
| Carregar entrada | `001` |
| Deslocar à esquerda N vezes | `010` |
| Deslocar à direita aritmeticamente N vezes | `100` |

Uma sequência conservadora para SLL/SRA é **carregar `rt` -> deslocar por `shamt` -> escrever em `rd`**. A FSM não deve tratar esse componente como um deslocador puramente combinacional nem presumir carga e deslocamento na mesma operação.

LUI pode ser implementada diretamente com concatenação fixa e uma rota de write-back. Se a equipe preferir compartilhar o deslocador, deve adicionar as fontes imediato e N=16 e respeitar as mesmas etapas síncronas.

### 4.4 Multiplicação, divisão e HI/LO

Os registradores HI/LO e seus caminhos para o banco já estão desenhados e podem ser reaproveitados por MULT, DIV, MFHI e MFLO. Falta explicitar:

- início e seleção da operação, com operandos preservados;
- indicação de conclusão e espera da UC;
- escrita de HI/LO quando o resultado estiver pronto;
- informação DIV0 encaminhada ao tratamento de exceções;
- limpeza de todos os registradores internos, inclusive temporários, no reset;
- multiplicação de Booth com sinal, resultado de 64 bits e duração permitida de 32 a 40 ciclos do multiplicador;
- divisão com sinal, com resto em HI e quociente em LO.

O bloco único chamado Mult/Div pode representar um módulo que encapsula os componentes. Sua existência no desenho não comprova o algoritmo nem a temporização exigidos. O limite de 40 ciclos citado é da multiplicação; a especificação não estabelece esse mesmo limite para o divisor.

## 5. Exceções e pontos não resolvidos pela tabela de instruções

Embora não sejam novas linhas nas páginas 7-8, as exceções fazem parte da correção do processador e afetam ADD, ADDI, SUB e DIV. A seção 2.9 exige:

| Evento | Endereço do byte que contém o destino da rotina |
|---|---|
| Opcode inexistente | 253 |
| Overflow | 254 |
| Divisão por zero | 255 |

O fluxo deve salvar o endereço da instrução causadora em EPC, ler o byte no endereço correspondente, estendê-lo **com zeros** e carregar o PC com esse valor. Esses três endereços são posições dos vetores, e não os endereços finais das rotinas. No quadro consultado, EPC e esse caminho não aparecem.

Se o PC já avançou para P+4, salvar o PC atual sem ajuste salva o endereço errado em EPC. Preservar P durante a busca ou recuperá-lo de maneira coerente. A escrita normal do resultado não deve ser concluída quando a exceção de overflow correspondente for acionada.

Pontos para alinhamento com a disciplina antes da implementação final:

- **JAL:** valor do retorno e existência ou não de delay slot, como discutido na avaliação individual.
- **RTE:** a página 14 a menciona e descreve `PC <- EPC`, mas as Tables 1-3 não a incluem nem fornecem codificação. Não foi contada como uma 24ª instrução; sua exigência e opcode/funct precisam ser esclarecidos.
- **Casos especiais de divisão e POP:** o texto não detalha a divisão do menor inteiro de 32 bits por -1 nem a semântica quando `pop` tem o próprio `r29` como destino. Documentar a convenção antes de definir testes para esses casos.

## 6. Ordem recomendada para concluir o projeto

1. **Fechar o datapath comum:** retorno ao PC, entrada do extensor de sinal, campos da instrução, habilitações e tabela dos seletores.
2. **Concluir fetch/decode e ADD/SUB/AND/ADDI:** corrigir os dois pontos de ADDI, definir temporização de memória e encaminhamento de overflow.
3. **Implementar LW/SW, depois LB/SB e LUI:** essas operações permitem carregar e verificar dados para testar as demais instruções. A especificação destaca ADDI, LUI, LW e LB como essenciais.
4. **Corrigir BEQ/BNE e concluir J/JAL/JR:** uma convenção única de atualização do PC e preservação do endereço de retorno.
5. **Concluir SLL/SRA, SLT e HI/LO:** criar os estados dos componentes e demonstrar os resultados de 32 bits no write-back.
6. **Integrar PUSH/POP e inicialização do SP:** ampliar seleção de registradores e verificar a pilha com chamadas e retornos.
7. **Completar os caminhos de exceção e a decodificação inválida:** suas interfaces devem ser previstas desde o início, evitando retrabalho nos muxes e no controle.
8. **Validar todas as 23 instruções e os componentes novos:** percorrer a FSM, conferir resultados e produzir as simulações exigidas pelo relatório.

Essa ordem é uma proposta de implementação, não uma dependência rígida entre equipes. O desenho atual deve ser aproveitado; a prioridade é completar e tornar coerentes as rotas e os estados já existentes.

## 7. Casos de teste propostos, ainda não executados

Os exemplos abaixo são critérios de aceitação para a futura implementação. Não são resultados de simulação deste projeto. Os bytes escritos sem prefixo na tabela estão em hexadecimal; os endereços 227 e 223 da pilha estão em decimal.

| Instrução | Caso mínimo e resultado esperado |
|---|---|
| `add` | `7 + (-2) = 5`; acrescentar caso de overflow e verificar ausência de write-back normal |
| `and` | `0xF0F0F0F0 & 0x0F0F0F0F = 0x00000000`; acrescentar caso com bits em comum |
| `div` | `7 / 3`: LO=2 e HI=1; testar sinais dos operandos e divisão por zero |
| `mult` | `-3 * 7`: HI=`0xFFFFFFFF`, LO=`0xFFFFFFEB`; medir ciclos e testar operandos extremos |
| `jr` | `R[rs]=0x80`: próximo endereço de instrução igual a `0x80` |
| `mfhi` | HI=`0x12345678`: `rd` recebe esse valor sem modificar HI ou LO |
| `mflo` | LO=`0x89ABCDEF`: `rd` recebe esse valor sem modificar HI ou LO |
| `sll` | `3 << 4 = 48`; repetir com shamt=0 e shamt=31 |
| `slt` | `-1 < 0` produz 1; operandos iguais produzem 0; testar mínimo versus máximo com sinal |
| `sra` | `0x80000000 >> 4` aritmético produz `0xF8000000` |
| `sub` | `7 - (-2) = 9`; acrescentar caso de overflow |
| `push` | SP=227 e dado `0xAABBCCDD`: SP final=223; bytes 223..226 iguais a DD, CC, BB, AA |
| `pop` | SP=223 e palavra `0xAABBCCDD`: `rd` recebe a palavra e SP final=227 |
| `addi` | `addi r2,r1,-1` com r1=5: r2=4; r31 deve permanecer intacto, embora o imediato tenha `[15:11]=11111` |
| `beq` | P=`0x40`, offset=2: com igualdade, alvo=`0x4C`; sem igualdade, próximo PC=`0x44`; repetir com offset negativo |
| `bne` | Mesmo exemplo: com diferença, alvo=`0x4C`; com igualdade, próximo PC=`0x44` |
| `lb` | Byte `0x80` no endereço acessado: rt=`0xFFFFFF80`; testar também `0x7F` |
| `lui` | Imediato `0x1234`: rt=`0x12340000` |
| `lw` | Bytes 78, 56, 34, 12 em endereços consecutivos: rt=`0x12345678` |
| `sb` | Bytes iniciais 11, 22, 33, 44; guardar o byte baixo de `0xAABBCCDD` no segundo endereço: resultado 11, DD, 33, 44 |
| `sw` | Gravar `0x12345678`: verificar bytes 78, 56, 34, 12 em endereços consecutivos |
| `j` | Campo target=`0x20` com os quatro bits altos do PC de referência zerados: alvo=`0x80` |
| `jal` | Mesmo salto de J; verificar r31 e retorno por JR. Para P=`0x40`, retorno=`0x44` na hipótese sem delay slot; ajustar à convenção confirmada da disciplina |

Testar ainda: reset antes da primeira instrução, reset durante MULT/DIV, branches tomados e não tomados, instruções consecutivas com destinos diferentes, preservação dos bytes vizinhos em SB e chamada com `jal -> push r31 -> pop r31 -> jr r31`.

A seção 3.2.7 exige ao menos uma simulação de cada instrução, com explicação. Entre os sinais observados devem estar PC, EPC, MDR, IR, r29, r31, registradores envolvidos, clock, reset e estado da FSM. Os componentes novos também precisam de simulação própria, com as dispensas previstas no documento para componentes fornecidos e multiplexadores.
