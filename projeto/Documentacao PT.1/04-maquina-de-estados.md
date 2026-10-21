# 04 — Estados de PUSH e POP

[Índice](README.md) · [Catálogo](02-catalogo-23-instrucoes.md) · [PUSH/POP](04-maquina-de-estados.md) · [Mermaid](08-atlas-mermaid.md)

## 1. Semântica da seção 2.7

As instruções usam a pilha em memória e atualizam R29. A pilha cresce dos endereços maiores para os menores.

```text
push rs:
    dado = R[rs] antigo
    SP = SP antigo - 4
    M32[SP] = dado

pop rd:
    dado = M32[SP antigo]
    R[rd] = dado
    SP = SP antigo + 4
```

A seção 2.7 começa na página 10 do PDF local; os exemplos continuam na página 11. O trecho enviado pelo usuário confirma a referência central: **227 → 223 no PUSH; 223 → 227 no POP**.

## 2. Integração com a UC existente

Os nomes abaixo são simbólicos, para acrescentar estados à UC da equipe. Não foi inventada uma nova codificação numérica para todos os estados anteriores.

`busca existente → decodificação → extensão PUSH/POP → busca existente`

A busca termina com a instrução em IR e PC apontando para a próxima. Durante a execução de PUSH/POP, manter PCWrite=0 e IRWrite=0. O avanço normal do PC pertence à busca.

| Estado | Condição | Operação na borda | Seleções |
|---|---|---|---|
| INIT_SP | Após liberação do reset, antes da primeira busca | R29 ← 227 | RegDst=3; MemtoReg=8; RegWrite=1 |
| DECODE_PUSH | opcode=0 e funct=5 | A ← R29; B ← R[rs] | Read1Sel=1; Read2Sel=1; AWrite=BWrite=1 |
| DECODE_POP | opcode=0 e funct=6 | A ← R29 | Read1Sel=1; Read2Sel=0; AWrite=1; BWrite=0 |
| DECODE_NORMAL | Demais instruções válidas | Captura anterior preservada | Read1Sel=0; Read2Sel=0; fluxo anterior |

A seleção das portas de leitura deve estar estável **antes** da borda que captura A/B. Se a UC só classifica a instrução ao final de um estado, inserir um estado de captura da pilha antes de usar A/B.

## 3. PUSH — três estados após a captura

| Estado | Microoperação | Controles ativos | Próximo |
|---|---|---|---|
| PUSH_DEC | ALUOut ← A−4 | ALUSrcA=1; ALUSrcB=1; F=010; ALUOutWrite=1 | PUSH_SP |
| PUSH_SP | R29 ← ALUOut | RegDst=3; MemtoReg=0; RegWrite=1 | PUSH_STORE |
| PUSH_STORE | M32[ALUOut] ← B | IorD=1; DataSource=2; wr=1 | Busca |

A e B ficam retidos nos três estados; ALUOut permanece retido depois de PUSH_DEC. PUSH_SP atualiza SP **antes** do ciclo de escrita da memória.

O endereço da escrita vem de ALUOut=SP antigo−4. O dado vem de B=R[rs] antigo. Se a instrução for PUSH R29, não trocar esse dado pelo SP já decrementado.

## 4. POP — sete estados após a captura

| Estado | Microoperação | Controles ativos | Próximo |
|---|---|---|---|
| POP_ADDR | ALUOut ← A | ALUSrcA=1; F=000; ALUOutWrite=1 | POP_REQ |
| POP_REQ | Requisitar leitura em ALUOut | IorD=1; wr=0; MDRWrite=0 | POP_WAIT |
| POP_WAIT | Manter endereço e aguardar leitura | IorD=1; wr=0; MDRWrite=0 | POP_CAP |
| POP_CAP | MDR ← Data_out válido | IorD=1; wr=0; MDRWrite=1 | POP_RD |
| POP_RD | R[rd] ← MDR | RegDst=1; MemtoReg=1; RegWrite=1 | POP_INC |
| POP_INC | ALUOut ← A+4 | ALUSrcA=1; ALUSrcB=1; F=001; ALUOutWrite=1 | POP_SP |
| POP_SP | R29 ← ALUOut | RegDst=3; MemtoReg=0; RegWrite=1 | Busca |

**A conserva SP antigo até POP_INC.** O banco escreve primeiro rd e depois R29, em estados diferentes. Não é necessária outra porta de escrita.

Em POP_ADDR, ALUSrcB é indiferente porque F=000 passa A. O endereço ALUOut deve ficar retido de POP_ADDR até a conclusão da leitura.

## 5. Valores padrão

Nos estados de execução desta extensão, todo enable não listado nas tabelas fica em zero: RegWrite, AWrite, BWrite, ALUOutWrite, MDRWrite, IRWrite, PCWrite, PCWriteCond e escritas HI/LO. `wr=0` fora de PUSH_STORE.

PCWriteCond também deve estar em zero: desabilitar apenas PCWrite não impede que o caminho condicional atualize o PC. Não iniciar MULT/DIV e manter SHIFT no comando de retenção 000 durante a execução de PUSH/POP. As regras e os controles das demais instruções continuam pertencendo aos seus estados anteriores.

Um seletor indiferente só pode ser ignorado quando a escrita que depende dele estiver desabilitada. Os cálculos SP±4 são de endereço; não habilitar a exceção aritmética de ADD/SUB apenas por usar a mesma ALU.

## 6. Leitura síncrona

A memória disponibiliza a leitura no pulso seguinte ao da requisição. Se o MDR também amostra na borda, ele não pode depender, nessa mesma borda, de um valor que a memória acabou de atualizar.

A sequência conservadora é:

1. E0: POP_REQ apresenta a requisição à memória.
2. E1: a saída passa a conter a palavra; POP_WAIT evita captura prematura.
3. E2: POP_CAP captura em MDR a saída já estável.

REQ/WAIT/CAP conservam **o mesmo endereço**. Conferir a temporização com o módulo HDL antes de reduzir estados.

## 7. Exemplo 227 → 223 → 227

Inicialmente: `SP=227`, `R8=0xAABBCCDD`; executar `push r8; pop r9`.

| Instante | A | B/MDR | ALUOut | Efeito visível |
|---|---|---|---|---|
| DECODE_PUSH | 227 | B=0xAABBCCDD | — | Operandos capturados |
| PUSH_DEC | 227 | B preservado | 223 | Endereço calculado |
| PUSH_SP | 227 | B preservado | 223 | SP=223 |
| PUSH_STORE | 227 | B preservado | 223 | M32[223]=0xAABBCCDD |
| DECODE_POP | 223 | B não usado | — | SP atual capturado |
| POP_ADDR | 223 | — | 223 | Endereço da leitura |
| POP_CAP | 223 | MDR=0xAABBCCDD | 223 | Dado válido retido |
| POP_RD | 223 | MDR preservado | 223 | R9 recebe a palavra; SP ainda 223 |
| POP_INC | 223 | MDR preservado | 227 | Novo SP calculado |
| POP_SP | 223 | — | 227 | SP=227 |

Little-endian: os bytes nos endereços **223, 224, 225 e 226** são **DD, CC, BB e AA**. POP recompõe a mesma palavra. POP não precisa apagar a memória: o incremento de SP remove logicamente o elemento da pilha.

## 8. Casos especiais

- **PUSH R29:** armazenar SP antigo; conservar B durante a atualização de R29.
- **POP R29:** o PDF não resolve explicitamente a colisão entre destino e SP. Nesta sequência, a escrita final de SP antigo+4 prevalece; confirmar a convenção.
- **Endereço 223:** não arredondar para 220; conferir o acesso exato no HDL.
- **Reset:** INIT_SP inicializa após a liberação do reset; não comprova SP=227 enquanto reset=1. Ver D02.
- **Pilha vazia/cheia:** não foram inventadas novas exceções ou instruções para esses casos.

Diagramas: [M03 — PUSH](08-atlas-mermaid.md#m03-push) e [M04 — POP](08-atlas-mermaid.md#m04-pop).
