# 08 — Atlas Mermaid

[Índice](README.md) · [Catálogo](02-catalogo-23-instrucoes.md) · [PUSH/POP](04-maquina-de-estados.md) · [Mermaid](08-atlas-mermaid.md)

Os diagramas ficam neste Markdown como material didático. Não representam seções adicionais no FigJam nem substituem o circuito original. M01–M06 explicam a extensão de pilha; M07–M13 organizam as demais famílias e seus pontos de conferência.

## Índice

- [M01 — Extensão sobre os blocos existentes](#m01-extensao)
- [M02 — Decodificação de PUSH, POP e BNE](#m02-decodificacao)
- [M03 — PUSH: decrementa, atualiza SP e grava](#m03-push)
- [M04 — POP: lê, escreve rd e incrementa SP](#m04-pop)
- [M05 — Exemplo 227 → 223 → 227](#m05-exemplo)
- [M06 — Latência da leitura](#m06-latencia)
- [M07 — Aritmética, AND e SLT](#m07-aritmetica)
- [M08 — BEQ e BNE](#m08-desvios)
- [M09 — SLL, SRA e LUI](#m09-shift)
- [M10 — MULT, DIV, MFHI e MFLO](#m10-hilo)
- [M11 — LW, LB, SW e SB](#m11-memoria)
- [M12 — Exceções exigidas](#m12-excecoes)
- [M13 — J, JAL e JR](#m13-saltos)

<a id="m01-extensao"></a>

## M01 — Extensão sobre os blocos existentes

Recorte didático da extensão. SP continua sendo R29. No FigJam, os blocos mantêm suas posições originais.

```mermaid
flowchart LR
  IR["IR existente"] -->|rs: seleção 0| R1["Read1Sel"]
  K29["29: índice SP"] -->|seleção 1| R1
  IR -->|rt: seleção 0| R2["Read2Sel"]
  IR -->|rs: seleção 1| R2
  R1 --> RF["Banco existente"]
  R2 --> RF
  RF --> A["A: SP antigo"]
  RF --> B["B: dado de PUSH"]
  A --> ALU["ALU: passa A ou calcula A mais/menos 4"]
  ALU --> AO["ALUOut existente"]
  AO --> ADR["IorD: entrada 1"]
  ADR --> MEM["Memória existente"]
  B --> DS["DataSource: entrada 2"]
  DS --> MEM
  MEM --> MDR["MDR existente"]
  MDR -->|MemtoReg 1| WB["Escrita do banco"]
  AO -->|MemtoReg 0| WB
  K227["227: dado inicial"] -->|MemtoReg 8| WB
  WB --> RF
  K29 -->|RegDst 3| DST["Destino da escrita"]
  IR -->|rd: RegDst 1| DST
  DST --> RF
```

<a id="m02-decodificacao"></a>

## M02 — Decodificação de PUSH, POP e BNE

PUSH funct 5 e BNE opcode 5 não conflitam: opcode é examinado primeiro.

```mermaid
flowchart TD
  D["Decodificar IR"] --> OP{"opcode = 0?"}
  OP -->|Sim| FN{"funct"}
  FN -->|0x05| PS["Capturar A=R29 e B=R rs"]
  FN -->|0x06| PP["Capturar A=R29"]
  FN -->|Outro R válido| R["Fluxo R existente"]
  FN -->|Inválido| X["Exceção de instrução inválida"]
  OP -->|Não| OI{"opcode"}
  OI -->|0x05| BNE["BNE"]
  OI -->|0x01 antiga SRAM| X
  OI -->|Outro I ou J válido| IJ["Fluxo I ou J existente"]
  OI -->|Inválido| X
  PS --> PUSH["PUSH_DEC"]
  PP --> POP["POP_ADDR"]
```

<a id="m03-push"></a>

## M03 — PUSH: decrementa, atualiza SP e grava

Ordem do exemplo oficial: SP=227 → SP=223 → gravação em M32[223].

```mermaid
flowchart TD
  D["DECODE_PUSH: A recebe R29; B recebe R rs"] --> DEC["PUSH_DEC: ALUOut recebe A menos 4"]
  DEC --> SP["PUSH_SP: R29 recebe ALUOut"]
  SP --> ST["PUSH_STORE: memória em ALUOut recebe B"]
  ST --> F["Voltar à busca"]
  H["AWrite=0 e BWrite=0 durante execução"] -.-> SP
  H -.-> ST
```

<a id="m04-pop"></a>

## M04 — POP: lê, escreve rd e incrementa SP

POP_ADDR reutiliza ALUOut → IorD → memória. As duas escritas do banco ocupam estados distintos.

```mermaid
flowchart TD
  D["DECODE_POP: A recebe R29"] --> AD["POP_ADDR: ALUOut recebe A"]
  AD --> R["POP_REQ: requisitar leitura em ALUOut"]
  R --> W["POP_WAIT: conservar endereço e aguardar"]
  W --> C["POP_CAP: MDR recebe dado válido"]
  C --> RD["POP_RD: R rd recebe MDR"]
  RD --> INC["POP_INC: ALUOut recebe A mais 4"]
  INC --> SP["POP_SP: R29 recebe ALUOut"]
  SP --> F["Voltar à busca"]
  H["A conserva SP antigo até POP_INC"] -.-> INC
```

<a id="m05-exemplo"></a>

## M05 — Exemplo 227 → 223 → 227

A palavra passa de R8 à memória e retorna em R9. O SP volta ao ponto inicial.

```mermaid
sequenceDiagram
  participant UC as Controle
  participant RF as Banco de registradores
  participant MEM as Memória
  Note over RF,MEM: Início: R29=227 e R8=0xAABBCCDD
  UC->>RF: Capturar A=227 e B=R8
  Note over UC: ALUOut=227-4=223
  UC->>RF: PUSH_SP: R29=223
  UC->>MEM: PUSH_STORE: M32 em 223 = B
  Note over MEM: Bytes 223..226: DD CC BB AA
  UC->>RF: POP: capturar A=223
  UC->>MEM: Requisitar leitura no endereço 223
  Note over UC,MEM: Manter endereço e aguardar latência
  MEM-->>UC: Capturar 0xAABBCCDD em MDR
  UC->>RF: POP_RD: R9=MDR
  Note over UC: ALUOut=A+4=227
  UC->>RF: POP_SP: R29=227
```

<a id="m06-latencia"></a>

## M06 — Latência da leitura

Modelo conservador para o contrato do PDF. Conferir E0/E1/E2 com o HDL real antes de otimizar.

```mermaid
sequenceDiagram
  participant UC as UC e endereço
  participant M as Memória síncrona
  participant D as MDR
  UC->>M: E0: requisição, wr=0
  Note over UC,M: Endereço mantido
  M-->>M: E1: saída recebe a palavra
  Note over D: Evitar captura na borda que atualiza Data_out
  M->>D: E2: capturar saída já estável
  Note over UC,D: Escrita em rd vem depois da captura
```

<a id="m07-aritmetica"></a>

## M07 — Aritmética, AND e SLT

Estudo dos caminhos anteriores. A formação de 0/1 de SLT exige a conferência A01.

```mermaid
flowchart TD
  D["Capturar rs e rt em A/B"] --> K{"Instrução"}
  K -->|ADD ou ADDI| ADD["Somar A a B ou imediato com sinal"]
  K -->|SUB| SUB["Subtrair B de A"]
  K -->|AND| AND["AND entre A e B"]
  K -->|SLT| LT["Comparar com sinal; formar palavra 0 ou 1"]
  ADD --> OV{"Overflow habilitado e detectado?"}
  SUB --> OV
  OV -->|Sim| EX["Exceção; bloquear escrita normal"]
  OV -->|Não| AO["Capturar ALUOut"]
  AND --> AO
  AO --> WB["Escrever rd; ADDI escreve rt"]
  LT --> LWB["Escrever rd pelo caminho LT"]
  WB --> F["Busca"]
  LWB --> F
```

<a id="m08-desvios"></a>

## M08 — BEQ e BNE

O alvo é comum; muda a condição que habilita o PC.

```mermaid
flowchart TD
  D["A=R rs; B=R rt"] --> T["Guardar T=P+4+4 vezes offset com sinal"]
  T --> CMP["Comparar A e B; preservar T"]
  CMP --> INS{"Instrução"}
  INS -->|BEQ| EQ{"A = B?"}
  INS -->|BNE| NE{"A diferente de B?"}
  EQ -->|Sim| TAKE["PC recebe T"]
  NE -->|Sim| TAKE
  EQ -->|Não| KEEP["PC permanece P+4"]
  NE -->|Não| KEEP
  TAKE --> F["Busca"]
  KEEP --> F
```

<a id="m09-shift"></a>

## M09 — SLL, SRA e LUI

LUI pelo SHIFT depende da conferência das fontes dos muxes, A07. Nenhum novo bloco de LUI foi acrescentado nesta revisão. MDR deixou de alimentar N para SRAM.

```mermaid
flowchart TD
  D{"Instrução"} -->|SLL| SL["Carregar R rt no SHIFT; N=shamt"]
  D -->|SRA| SR["Carregar R rt no SHIFT; N=shamt"]
  D -->|LUI| LU["Carregar imediato no SHIFT; N=16"]
  SL --> L["Outro ciclo: deslocar à esquerda"]
  SR --> R["Outro ciclo: deslocar à direita com sinal"]
  LU --> LL["Outro ciclo: deslocar 16 à esquerda"]
  L --> RD["Escrever rd pela saída SHIFT"]
  R --> RD
  LL --> RT["Escrever rt pela saída SHIFT"]
  RD --> F["Busca"]
  RT --> F
```

<a id="m10-hilo"></a>

## M10 — MULT, DIV, MFHI e MFLO

MULT/DIV produzem HI/LO. MFHI/MFLO transferem esses valores ao banco.

```mermaid
flowchart TD
  I{"Instrução"} -->|MULT| M["Iniciar multiplicador separado com A/B"]
  I -->|DIV| Z{"Divisor é zero?"}
  Z -->|Sim| E["Exceção de divisão por zero"]
  Z -->|Não| V["Iniciar divisor separado com A/B"]
  M --> MW{"Multiplicação concluiu?"}
  MW -->|Não| MW
  MW -->|Sim| MC["HI recebe produto alto; LO recebe produto baixo"]
  V --> VW{"Divisão concluiu?"}
  VW -->|Não| VW
  VW -->|Sim| VC["HI recebe resto; LO recebe quociente"]
  I -->|MFHI| HI["Escrever HI em rd"]
  I -->|MFLO| LO["Escrever LO em rd"]
  MC --> F["Busca"]
  VC --> F
  HI --> F
  LO --> F
```

<a id="m11-memoria"></a>

## M11 — LW, LB, SW e SB

Conferir MergeBytes e a interface real. Um eventual alinhamento para LB/SB não deve alterar o endereço exato de PUSH/POP.

```mermaid
flowchart TD
  EA["Calcular EA=R rs + offset com sinal"] --> I{"Instrução"}
  I -->|SW| SW["Gravar B=R rt como palavra em EA"]
  I -->|LW ou LB ou SB| R["Requisitar leitura no endereço apropriado"]
  R --> W["Aguardar saída válida; capturar MDR"]
  W --> K{"Instrução"}
  K -->|LW| LW["Escrever palavra em rt"]
  K -->|LB| LB["Escolher byte endereçado; estender sinal; escrever rt"]
  K -->|SB| SB["Substituir só o byte alvo por B baixo"]
  SB --> ST["Gravar palavra combinada; preservar vizinhos"]
  SW --> F["Busca"]
  LW --> F
  LB --> F
  ST --> F
```

<a id="m12-excecoes"></a>

## M12 — Exceções exigidas

Requisito para conferir a UC existente: PC recebe o conteúdo do byte do vetor, não 253/254/255 diretamente.

```mermaid
flowchart TD
  E{"Causa"} -->|Instrução inválida| I["Endereço do vetor = 253"]
  E -->|Overflow| O["Endereço do vetor = 254"]
  E -->|Divisão por zero| Z["Endereço do vetor = 255"]
  I --> EPC["Salvar P da instrução causadora em EPC"]
  O --> EPC
  Z --> EPC
  EPC --> REQ["Ler byte no endereço do vetor"]
  REQ --> WAIT["Aguardar leitura válida"]
  WAIT --> EXT["Estender byte com zeros para 32 bits"]
  EXT --> PC["PC recebe valor estendido"]
  PC --> F["Busca na rotina de tratamento"]
```

<a id="m13-saltos"></a>

## M13 — J, JAL e JR

Os exemplos sem delay slot usam link=P+4; confirmar D01.

```mermaid
flowchart TD
  I{"Instrução"} -->|JR| JR["Passar R rs por A e pela ALU"]
  JR --> PCR["PC recebe saída da ALU"]
  I -->|J| J["Formar alvo com PC alto e target deslocado 2"]
  I -->|JAL| LINK["Conservar link em ALUOut e escrever R31"]
  LINK --> J
  J --> PCJ["PC recebe alvo de salto"]
  PCR --> F["Busca"]
  PCJ --> F
```
