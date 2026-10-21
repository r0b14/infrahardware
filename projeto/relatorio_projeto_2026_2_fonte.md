---
title: Relatório de Projeto
subtitle: Processador multiciclo de 32 bits da disciplina IF674
date: Recife, outubro de 2026
lang: pt-BR
geometry: margin=2.5cm
fontsize: 11pt
---

**Universidade Federal de Pernambuco**  
**Centro de Informática**  
**Infra-Estrutura de Hardware — IF674**  
**Equipe EQ01**  

**Integrantes e logins:** inserir os dados oficiais da equipe antes da entrega.  
**Data de entrega:** inserir a data definida pela disciplina.

\newpage

# Índice

1. Introdução  
2. Unidade de processamento  
3. Descrição das entidades  
4. Descrição dos estados do controle  
5. Conjunto de simulações e critérios de verificação  
6. Conclusão  
7. Referências  
Apêndice A. Catálogo das instruções

\newpage

# 1 Introdução

Este relatório descreve a arquitetura e o controle de um processador multiciclo de 32 bits para o conjunto de 23 instruções definido na especificação do projeto de IF674 de 2026.2. O objetivo é relacionar a semântica das instruções aos blocos do caminho de dados, aos sinais da unidade de controle (UC) e à sequência de estados necessária para executar cada operação. A atenção principal recai sobre `push` e `pop`, que substituem `xchg` e `sram` da versão anterior e exigem acesso explícito ao registrador de pilha R29.

A organização multiciclo permite reutilizar a ALU, o banco de registradores e a memória em ciclos diferentes. Registradores intermediários conservam resultados entre etapas, enquanto a UC escolhe fontes, destinos e habilitações em cada estado. Esse princípio, trabalhado nas aulas de implementação multiciclo, explica por que uma instrução de memória precisa de estados distintos para calcular endereço, acessar a memória e escrever o resultado. Também explica a separação entre as duas escritas de `pop`: uma no registrador de destino e outra em R29.

O material de projeto registra o circuito da equipe em um quadro FigJam, a análise das 23 instruções, uma proposta de extensão de sinais, os estados de `push` e `pop` e um plano de validação. Esses registros sustentam a descrição arquitetural aqui apresentada. Até o momento desta versão, não há módulos HDL, testbenches ou capturas de simulação do processador na pasta consultada. Assim, as operações e os resultados esperados das seções seguintes constituem especificação e critérios de aceitação; não são apresentados como comprovação de execução em hardware. A seção de simulações identifica precisamente o que deverá ser anexado após a implementação.

## 1.1 Requisitos e escopo

A CPU tem 32 registradores gerais de 32 bits, instruções dos formatos R, I e J e uma memória unificada de 256 bytes, endereçada por byte. A memória lê de forma síncrona, escreve em um ciclo e usa ordem *little-endian*. O conjunto inclui 13 instruções R, oito I e duas J. A especificação exige que R29 funcione como ponteiro de pilha (SP), inicialmente apontando para o endereço decimal 227, e que as exceções de opcode inexistente, overflow e divisão por zero preservem o endereço da instrução em EPC.

O projeto deve explicitar todos os sinais que chegam à UC ou dela partem. Os estados precisam indicar a ação realizada, os sinais modificados e as transições. A memória, o banco, a ALU e o deslocador fornecidos pela disciplina têm comportamentos próprios que devem prevalecer sobre convenções genéricas do MIPS. Por exemplo, a leitura síncrona da memória não permite assumir que o dado requisitado possa ser capturado imediatamente no mesmo pulso.

## 1.2 Relação com os conteúdos da disciplina

Aula de instruções e representação: os campos `opcode`, `rs`, `rt`, `rd`, `shamt`, `funct` e imediato selecionam operações e operandos. Aula de implementação monociclo: uma instrução pode ser vista como um caminho completo entre estado inicial e efeito arquitetural. Aula de implementação multiciclo: esse caminho é repartido em etapas, com armazenamento em IR, A, B, ALUOut e MDR e controle por máquina de estados. Aula de desempenho: reutilizar hardware reduz recursos, mas pode aumentar o número de ciclos por instrução; a comparação correta de desempenho depende também do período de clock e da mistura de instruções, e não apenas da contagem de estados de uma operação isolada.

# 2 Unidade de processamento

## 2.1 Organização funcional

O caminho de dados possui três regiões: busca e atualização do PC; leitura de operandos e execução; acesso à memória e escrita de resultados. A memória unificada atende tanto à busca de instruções quanto às cargas e aos armazenamentos. O seletor IorD apresenta PC para busca e ALUOut para acesso a dados. IR preserva a instrução decodificada; A e B preservam operandos lidos do banco; ALUOut preserva endereços e resultados; MDR preserva a palavra lida.

```text
                     +------------------ UC ------------------+
                     | seleção, enables, próximo estado       |
                     +----+-----------+-----------+-----------+
                          |           |           |
 PC --> IorD --> MEMÓRIA --> IR --> BANCO --> A/B --> ALU --> ALUOut
  ^                    |                 |          |          |
  |                    +----> MDR --------+---------> escrita <--+
  |                                 HI/LO, SHIFT, LT, MergeBytes
  +-------------------------- PCSource / EPC -------------------+
```

**Figura 1 — Visão funcional simplificada.** O quadro da equipe é a referência para as ligações completas; a figura destaca o reaproveitamento temporal dos blocos. Cada seta representa um caminho de dados possível, não a ativação simultânea de todos os componentes.

Em toda instrução, a busca coloca o endereço P no acesso à memória, registra a palavra em IR quando ela estiver válida e produz P+4 para o fluxo sequencial. A decodificação escolhe uma família de estados. Para instruções aritméticas, a ALU ou o comparador gera o resultado; para cargas, a ALU calcula o endereço efetivo e MDR recebe a leitura; para desvios e saltos, a lógica de PC escolhe o destino. O estado de execução retorna à busca após confirmar seus efeitos arquiteturais.

## 2.2 Dados, endereços e temporização

Nos formatos R, I e J, os campos são respectivamente `opcode|rs|rt|rd|shamt|funct`, `opcode|rs|rt|imediato` e `opcode|target`. A ALU trabalha com palavras de 32 bits em complemento de dois. O deslocamento de `sra` conserva o sinal; `sll` preenche com zeros. O imediato de `addi` recebe extensão de sinal antes da soma. Para cargas e armazenamentos, o endereço efetivo é `R[rs] + SE16(offset)`.

A memória tem entrada de endereço de 32 bits, mas capacidade de 256 bytes. Uma leitura requisitada só fica disponível no pulso seguinte ao da requisição; uma escrita leva um ciclo. Por isso, o endereço e a seleção IorD devem permanecer estáveis durante a espera e a captura da leitura. O valor de 32 bits `0xAABBCCDD` escrito a partir do endereço 223 ocupa os bytes 223, 224, 225 e 226 com `DD`, `CC`, `BB` e `AA`, nessa ordem. Não há base no exemplo oficial para arredondar 223 para 220. A compatibilidade desse acesso com o módulo HDL deverá ser verificada.

## 2.3 Pilha e extensão do circuito

O SP é o próprio R29 do banco, e não um registrador externo. A pilha cresce para endereços menores. `push rs` conserva o dado antigo de R[rs], calcula SP−4, escreve o novo valor em R29 e grava a palavra nesse novo endereço. `pop rd` lê a palavra no SP antigo, escreve-a em R[rd] e somente depois incrementa R29 em quatro. A ordem é necessária para cumprir os exemplos da seção 2.7 da especificação.

Para permitir essa sequência sem duplicar as unidades principais, foram documentados `Read1Sel` para escolher `rs` ou R29 na primeira porta de leitura, `Read2Sel` para escolher `rt` ou `rs` na segunda porta, a entrada R29 em RegDst, a fonte B em DataSource e a constante 227 em MemtoReg. Os enables AWrite e BWrite preservam os operandos antigos durante vários ciclos. A ampliação de MemtoReg para quatro bits é necessária porque a nova entrada tem índice 8.

| Sinal ou seletor | Escolha usada em `push` e `pop` | Razão |
|:--|:--|:--|
| Read1Sel | `1 = R29` | Capturar o SP antigo em A. |
| Read2Sel | `1 = rs` no `push` | Capturar o valor a empilhar em B. |
| RegDst | `3 = R29`; `1 = rd` | Atualizar SP ou o destino de `pop`. |
| MemtoReg | `0 = ALUOut`; `1 = MDR`; `8 = 227` | Escrever endereço calculado, dado lido ou valor inicial. |
| DataSource | `2 = B` | Fornecer à memória o dado antigo de `push`; também é a fonte adequada para `sw`. |
| IorD | `1 = ALUOut` | Endereçar a memória de dados. |
| ALUSrcA / ALUSrcB | `A` e constante 4 | Calcular SP−4 ou SP+4. |

## 2.4 Outras famílias de instruções

As operações `add`, `and`, `sub`, `slt` e `addi` compartilham leitura do banco, produção de resultado e retorno ao banco. `slt` requer uma palavra de 32 bits com valor exatamente 0 ou 1, obtida por comparação com sinal. `sll`, `sra` e `lui` usam o deslocador, com fonte e quantidade selecionadas conforme a instrução. `lw` e `lb` compartilham o cálculo de endereço e a leitura; `lb` ainda seleciona um byte e deve estendê-lo com sinal. `sw` e `sb` compartilham o cálculo de endereço; `sb` deve preservar os outros três bytes da palavra, pois a memória não oferece habilitação individual de bytes.

`beq` e `bne` calculam `P+4 + (SE16(offset)<<2)` e distinguem igualdade de desigualdade. `j` e `jal` formam o destino pela concatenação dos quatro bits altos do PC especificado com `target<<2`; `jr` usa diretamente R[rs]. A especificação não fixa de modo inequívoco o endereço de retorno de `jal` nem um *delay slot*. A documentação da equipe usa, provisoriamente, ausência de *delay slot* e link P+4; a convenção precisa ser confirmada antes de finalizar a UC.

`mult` e `div` usam componentes separados da ALU. A multiplicação com sinal deve seguir Booth, produzir 64 bits e terminar em 32 a 40 ciclos; HI e LO guardam as metades alta e baixa. A divisão com sinal põe resto em HI e quociente em LO e precisa indicar divisão por zero à UC. `mfhi` e `mflo` movem o conteúdo correspondente para um registrador geral. O algoritmo interno e a temporização efetiva dessas unidades só poderão ser descritos como implementação depois de examinados os módulos HDL.

# 3 Descrição das entidades

Esta seção registra o papel e a interface funcional das entidades do projeto. As unidades efetivamente construídas pela equipe deverão ter portas e algoritmo interno conciliados com o código antes da entrega final, conforme o capítulo 3 da especificação.

| Entidade | Entradas principais | Saídas e função |
|:--|:--|:--|
| PC, IR, A, B, ALUOut, MDR e EPC | clock, reset, dado e habilitação, conforme o registrador | Conservam endereço, instrução, operandos, resultado, leitura ou endereço da instrução causadora de exceção. |
| Banco de registradores | dois índices de leitura, índice e dado de escrita, RegWrite, clock e reset | Duas leituras combinacionais e uma escrita; R29 é SP, R31 recebe link de `jal` quando aplicável. |
| ALU e ALUControl | operandos de 32 bits, código F ou comando de controle | Executam passagem, soma, subtração e operações lógicas; F deve variar por estado. |
| Memória | `add[31:0]`, `Data_in[31:0]`, clock, `wr` | `Data_out[31:0]`; `wr=0` lê, `wr=1` escreve; acesso síncrono e *little-endian*. |
| SHIFT | dado de 32 bits, quantidade de cinco bits, modo de três bits, clock e reset | Resultado de deslocamento; atende `sll`, `sra` e, com seleção adequada, `lui`. |
| MULT e DIV | operandos, início, clock e reset | Resultado HI/LO, conclusão; DIV também informa divisão por zero. |
| Comparador e MergeBytes | operandos ou palavra antiga, byte novo e posição | Formam 0/1 em `slt` e preservam bytes não escritos em `sb`. |
| Unidade de controle | opcode, funct, condições da ALU, fim das unidades e erros | Seletores, enables, comando da ALU, escrita da memória e próximo estado. |

Multiplexadores selecionam fontes, mas não precisam de descrição algorítmica individual no relatório final, conforme a especificação. Os sinais de controle e as larguras da extensão da pilha estão resumidos na seção 2.3. Na implementação, deve-se conferir especialmente a largura de MemtoReg, a origem B para `sw`, a inversão da condição de `bne`, a formação de 0/1 de `slt` e a semântica do tratamento de bytes.

O reset expõe uma incompatibilidade que exige decisão de implementação: a especificação da pilha pede R29=227 quando o reset é ativado, mas a descrição do banco fornecido diz que o reset assíncrono limpa todos os registradores. A proposta `INIT_SP` escreve 227 após a liberação do reset e antes da primeira busca. Ela garante o valor de operação inicial, mas não demonstra R29=227 enquanto o reset está ativo. Essa diferença deve ser resolvida com o módulo real e a orientação da disciplina.

# 4 Descrição dos estados do controle

## 4.1 Regra de leitura da máquina de estados

Cada caixa de estado representa uma etapa temporal; dentro dela, muxes e circuitos combinacionais podem funcionar em paralelo. Na borda do clock, apenas os registradores com enable ativo capturam os novos valores. Assim, o fluxo correto de explicação é: identificar entradas estáveis, ativar seletores, calcular saídas combinacionais, registrar na borda e seguir para o próximo estado. Essa distinção entre paralelismo dentro do estado e sequência entre estados é a base do mapa preparado para a segunda parte da documentação.

```text
RESET -> INIT_SP -> BUSCA -> DECODE --+--> ALU / SHIFT / HI-LO -> ESCRITA -> BUSCA
                                     +--> ENDEREÇO -> MEMÓRIA -> ESCRITA -> BUSCA
                                     +--> DESVIO / SALTO ----------------> BUSCA
                                     +--> PUSH_DEC -> PUSH_SP -> PUSH_STORE -> BUSCA
                                     +--> POP_ADDR -> POP_REQ -> POP_WAIT -> POP_CAP
                                                    -> POP_RD -> POP_INC -> POP_SP -> BUSCA
```

**Figura 2 — Mapa lógico resumido da UC.** As transições mostram famílias de estados. O mapa completo do quadro deve ser inserido em tamanho legível na versão final do relatório, depois de conciliado com a UC implementada.

## 4.2 Estados compartilhados

`BUSCA` coloca PC na memória, aguarda a leitura síncrona quando necessário, grava IR e produz P+4. `DECODE` examina `opcode` e, no formato R, `funct`; seleciona a família de execução e captura operandos em A e B quando a leitura do banco está estável. Estados de ALU calculam e retêm resultados em ALUOut; estados de acesso a dados preservam o endereço, aguardam a memória e usam MDR; estados de escrita selecionam o registrador de destino e habilitam RegWrite. Desvios e saltos atualizam PC apenas sob sua condição específica. Os nomes exatos e a codificação binária dos estados antigos pertencem à UC existente e não foram inventados neste relatório.

`INIT_SP`, proposto após a liberação do reset, seleciona R29 como destino e a constante 227 como dado de escrita. `DECODE_PUSH` captura A=R29 e B=R[rs]; `DECODE_POP` captura A=R29 e não precisa reescrever B. Se a UC só reconhece `funct` depois da borda do estado de decodificação, deve existir um estado adicional de captura para manter essa ordem temporal.

## 4.3 Estados de `push`

| Estado | Microoperação e efeito na borda | Seleções e habilitações essenciais |
|:--|:--|:--|
| PUSH_DEC | `ALUOut <- A−4` | ALUSrcA=A, ALUSrcB=4, F=010, ALUOutWrite=1. |
| PUSH_SP | `R29 <- ALUOut` | RegDst=3, MemtoReg=0, RegWrite=1. |
| PUSH_STORE | `M32[ALUOut] <- B` | IorD=1, DataSource=2, wr=1. |

A e B não são reescritos nesses estados. Portanto, `push R29` grava o SP antigo, preservado em B, mesmo depois da atualização de R29. PCWrite, PCWriteCond e IRWrite ficam desabilitados durante a extensão; o PC já avançou na busca.

## 4.4 Estados de `pop`

| Estado | Microoperação e efeito na borda | Seleções e habilitações essenciais |
|:--|:--|:--|
| POP_ADDR | `ALUOut <- A` | ALUSrcA=A, F=000, ALUOutWrite=1. |
| POP_REQ | Requisitar leitura em ALUOut | IorD=1, wr=0, MDRWrite=0. |
| POP_WAIT | Manter endereço e aguardar saída válida | IorD=1, wr=0, MDRWrite=0. |
| POP_CAP | `MDR <- Data_out` válido | IorD=1, wr=0, MDRWrite=1. |
| POP_RD | `R[rd] <- MDR` | RegDst=1, MemtoReg=1, RegWrite=1. |
| POP_INC | `ALUOut <- A+4` | ALUSrcA=A, ALUSrcB=4, F=001, ALUOutWrite=1. |
| POP_SP | `R29 <- ALUOut` | RegDst=3, MemtoReg=0, RegWrite=1. |

REQ, WAIT e CAP compõem uma sequência conservadora para a memória síncrona. O endereço permanece o mesmo até MDR capturar a saída. Se o módulo HDL demonstrar outra relação temporal, a quantidade de estados poderá ser reavaliada com uma forma de onda. `POP_RD` e `POP_SP` são separados porque o banco possui uma só porta de escrita. A permanece com o SP antigo até `POP_INC`.

## 4.5 Exemplo completo de pilha

Considere inicialmente R29=227 e R8=`0xAABBCCDD`. Em `push R8`, A recebe 227 e B recebe a palavra de R8; a ALU calcula 223; R29 recebe 223; a memória recebe `0xAABBCCDD` em M32[223]. Em seguida, `pop R9` lê M32[223], aguarda a saída, guarda-a em MDR, escreve R9 e finalmente escreve 227 em R29. O resultado é R9=`0xAABBCCDD` e R29=227. A memória pode continuar contendo a palavra: o incremento do SP retira o elemento logicamente da pilha.

O caso `pop R29` cria duas escritas no mesmo registrador, em ciclos diferentes. Na sequência proposta, o incremento final prevalece sobre o dado lido. A especificação não explicita essa colisão; o comportamento deverá ser acordado antes de usá-lo como caso normativo.

## 4.6 Exceções

Em opcode inexistente, overflow ou divisão por zero, a UC deve preservar em EPC o endereço P da instrução causadora. Em seguida, lê o byte no endereço 253, 254 ou 255, respectivamente, estende-o com zeros para 32 bits e carrega esse valor em PC. Os números 253–255 são endereços que contêm os bytes dos vetores, não destinos diretos do PC. A especificação menciona `rte` como retorno `PC <- EPC`, mas não fornece codificação para ela nas tabelas das 23 instruções; por isso, não foi acrescentada uma 24ª instrução ao catálogo.

# 5 Conjunto de simulações e critérios de verificação

## 5.1 Situação da evidência

A especificação do relatório exige ao menos uma captura de simulação Quartus e explicação detalhada para cada instrução, além de simulações isoladas das entidades implementadas pela equipe. As capturas ainda não estão disponíveis. Esta seção oferece o plano de execução e os resultados esperados, sem atribuir aprovação a testes não realizados. Para concluir a versão de entrega, cada linha do Apêndice A deverá receber forma de onda, valores observados e comparação com a expectativa.

Em cada simulação de instrução devem aparecer clock, reset, estado da UC, PC, EPC, IR, MDR, R29, R31 e os registradores envolvidos. Acrescentam-se endereço e dados da memória, seletores e enables pertinentes. A figura da forma de onda deve ficar imediatamente após a descrição dos sinais e dos passos, conforme o capítulo 3 da especificação. Entidades criadas pela equipe, como UC, MULT, DIV ou MergeBytes se implementadas por ela, também exigem teste isolado; multiplexadores e componentes fornecidos são dispensados nos termos da especificação.

## 5.2 Casos prioritários para a pilha

| Teste | Preparação | Resultado esperado |
|:--|:--|:--|
| Inicialização | Liberar reset e executar INIT_SP | R29=227 antes da primeira busca; comportamento durante reset avaliado separadamente. |
| `push R8` | R29=227; R8=`0xAABBCCDD` | R29=223; M32[223]=`0xAABBCCDD`; R8 preservado. |
| `pop R9` | R29=223; M32[223]=`0xAABBCCDD` | R9=`0xAABBCCDD`; R29=227. |
| LIFO | `push R8; push R9; pop R10; pop R11` | SP: 227, 223, 219, 223, 227; R10 recebe R9 antigo; R11 recebe R8 antigo. |
| Fonte igual ao SP | `push R29` com R29=227 | M32[223]=227, não 223. |
| Endianidade | Gravar `0x12345678` em 223 | Bytes 223–226: `78 56 34 12`. |
| Escritas de `pop` | Observar POP_RD e POP_SP | RegWrite escreve primeiro rd e depois R29, em bordas diferentes. |
| Memória síncrona | Observar POP_REQ, WAIT e CAP | Endereço estável; MDRWrite apenas em CAP. |

Palavras de instrução úteis para o teste são `push R8 = 0x01000005`, `pop R9 = 0x00004806` e `push R29 = 0x03A00005`, conforme os campos definidos na documentação. Como `push` e `pop` são extensões da disciplina, um montador MIPS genérico pode não reconhecê-las. A validação deve usar a codificação binária do projeto.

## 5.3 Regressão das demais instruções

O Apêndice A especifica uma observação central para cada uma das 23 operações. Além do caso nominal, testar overflow em `add`, `addi` e `sub`; igualdade e desigualdade em `beq` e `bne`; quatro posições de byte em `lb` e `sb`; operandos positivos, negativos e extremos em `slt`, `mult` e `div`; deslocamentos zero e 31 em `sll` e `sra`; saltos e retorno de `jal` segundo a convenção confirmada; exceções e EPC. Para `sw`, verificar que o dado vem de B=R[rt], e não do registrador-base A.

Nenhuma métrica de CPI ou tempo de CPU pode ser inferida apenas do mapa lógico. Depois da simulação, o número medido de ciclos por instrução e o período do clock podem alimentar a relação `tempo de CPU = número de instruções × CPI médio × período do clock`, apresentada nas aulas de desempenho.

# 6 Conclusão

O projeto documental descreve um processador multiciclo capaz de acomodar o conjunto de 23 instruções de 2026.2 mediante reaproveitamento de ALU, memória, banco e registradores intermediários. A substituição de `xchg` e `sram` por `push` e `pop` foi traduzida em seleções adicionais do banco, caminhos de escrita e estados que respeitam a ordem exigida pela pilha. O exemplo oficial de SP 227→223→227 é reproduzido sem alterar o endereço calculado, e a leitura síncrona da memória é tratada com estados de requisição, espera e captura.

Os objetivos de análise da arquitetura, detalhamento da extensão da pilha e preparação da validação foram atendidos no nível de especificação. A conclusão sobre funcionamento efetivo da CPU permanece condicionada à implementação da UC e das entidades, à simulação das 23 instruções e à inclusão das formas de onda exigidas. Antes disso, devem ser resolvidas a compatibilidade entre reset e R29=227, a leitura exata da palavra iniciada em 223, a convenção de `jal` e o comportamento de `pop R29`. Essas verificações decorrem diretamente das interfaces e das lacunas identificadas nos documentos do projeto.

# 7 Referências

1. UNIVERSIDADE FEDERAL DE PERNAMBUCO. **Especificação de Projeto — Infra-Estrutura de Hardware, 2026.2**. Capítulos 1 a 3. Arquivo local `Projeto/Especificacao Projeto 2026-2.pdf`.
2. EQUIPE EQ01. **Documentação PT.1**. Análise do quadro, catálogo das 23 instruções, arquitetura e sinais, máquina de estados, plano de validação e decisões. Arquivos Markdown da pasta `Projeto/Documentacao PT.1`.
3. EQUIPE EQ01. **Documentação PT.2**. Roteiro de apresentação e guia lógico do mapa de estados. Arquivos Markdown da pasta `Projeto/Documentacao PT.2`.
4. IF674. **Aula Instruções; Aula InfraHW Monociclo; Aula InfraHW Multiciclo; Aula InfraHW Desempenho**. Slides consolidados da disciplina, pasta `Aulas/Slides consolidados`.
5. EQUIPE EQ01. **Quadro do circuito e mapa de estados**. FigJam: <https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=0-1>.

# Apêndice A Catálogo das 23 instruções

| Formato | Instrução | Codificação | Efeito principal e foco da verificação |
|:--|:--|:--|:--|
| R | `add rd,rs,rt` | funct 0x20 | Soma com sinal; resultado em rd; observar overflow. |
| R | `and rd,rs,rt` | funct 0x24 | AND bit a bit em rd. |
| R | `div rs,rt` | funct 0x1A | Quociente em LO, resto em HI; divisão por zero gera exceção. |
| R | `mult rs,rt` | funct 0x18 | Produto de 64 bits com sinal; HI/LO e término da unidade Booth. |
| R | `jr rs` | funct 0x08 | PC recebe R[rs]. |
| R | `mfhi rd` | funct 0x10 | rd recebe HI sem alterá-lo. |
| R | `mflo rd` | funct 0x12 | rd recebe LO sem alterá-lo. |
| R | `sll rd,rt,shamt` | funct 0x00 | Deslocamento lógico à esquerda; testar 0 e 31. |
| R | `slt rd,rs,rt` | funct 0x2A | Comparação com sinal; rd recebe somente 0 ou 1. |
| R | `sra rd,rt,shamt` | funct 0x03 | Deslocamento aritmético à direita; preservar sinal. |
| R | `sub rd,rs,rt` | funct 0x22 | Subtração com sinal; observar overflow. |
| R | `push rs` | funct 0x05 | R29−4 e gravação do valor antigo de R[rs] no novo topo. |
| R | `pop rd` | funct 0x06 | Leitura no SP antigo; escrita de rd; R29+4. |
| I | `addi rt,rs,imm` | opcode 0x08 | Soma com imediato estendido com sinal; observar overflow. |
| I | `beq rs,rt,off` | opcode 0x04 | Desviar quando iguais; alvo relativo a P+4. |
| I | `bne rs,rt,off` | opcode 0x05 | Desviar quando diferentes; condição inversa de `beq`. |
| I | `lb rt,off(rs)` | opcode 0x20 | Ler byte e estender sinal. |
| I | `lui rt,imm` | opcode 0x0F | Posicionar imediato nos 16 bits altos. |
| I | `lw rt,off(rs)` | opcode 0x23 | Ler palavra via endereço efetivo e MDR. |
| I | `sb rt,off(rs)` | opcode 0x28 | Gravar byte sem alterar os outros três. |
| I | `sw rt,off(rs)` | opcode 0x2B | Gravar palavra proveniente de R[rt]. |
| J | `j target` | opcode 0x02 | Atualizar PC para o alvo formado. |
| J | `jal target` | opcode 0x03 | Saltar e gravar link em R31, após definir a convenção de retorno. |

Em todas as linhas R, o opcode é `0x00`. A codificação e a semântica específicas desta disciplina prevalecem sobre a aceitação por ferramentas MIPS genéricas.
