# Guia lógico para entender e explicar o mapa de estados

## 1. A regra mais importante

Leia o mapa em duas escalas diferentes:

- **entre caixas:** sequência temporal; normalmente uma caixa corresponde a um ciclo;
- **dentro de uma caixa:** sinais e caminhos de hardware que podem atuar simultaneamente naquele ciclo.

Em uma frase:

> **Paralelismo dentro do estado; sequência entre estados.**

Esse princípio elimina a maior parte da sensação de que “tudo acontece ao mesmo tempo”.

## 2. O que cada elemento visual significa

| Elemento | Significado | Pergunta que responde |
|---|---|---|
| Caixa | Um estado da UC | “O que está habilitado neste ciclo?” |
| Texto da caixa | Microoperação e sinais de controle | “Que caminho de dados está ativo?” |
| Seta | Próximo estado | “Para onde vamos após a borda?” |
| Bifurcação | Decisão da UC | “Qual condição escolhe o próximo caminho?” |
| Cor | Grupo de instruções com caminho predominante comum | “Que família reutiliza este tipo de hardware?” |
| Laço de retorno | Volta à busca | “A instrução terminou?” |

## 3. Como simular mentalmente um estado

Use sempre os mesmos cinco passos. Não pule diretamente para a caixa seguinte.

1. **Congele o tempo.** Diga qual é o estado atual.
2. **Leia as fontes.** Quais registradores ou saídas já possuem valores estáveis?
3. **Ative os sinais.** Quais muxes, unidades e enables a UC seleciona?
4. **Calcule o que é combinacional.** ALU, comparador, muxes e endereço podem produzir valores durante o ciclo.
5. **Aplique a borda do clock.** Apenas agora registradores habilitados recebem seus novos valores; em seguida, avance pela seta.

Modelo de fala:

> “Estamos em `NOME_DO_ESTADO`. As entradas estáveis são ____. A UC ativa ____. Durante o ciclo, o hardware produz ____. Na borda, ____ é registrado. Então seguimos para ____.”

## 4. O que realmente pode ocorrer em paralelo

Vários fios podem carregar valores ao mesmo tempo e várias unidades combinacionais podem trabalhar juntas. Isso não significa que vários estados foram executados de uma vez.

Exemplos:

- em `FETCH`, a memória pode fornecer a instrução enquanto a ALU calcula PC+4;
- em `CAPTURA PUSH`, as duas portas do banco permitem ler R29 e `R[rs]` no mesmo ciclo;
- em um estado de escrita, endereço, dado e enable ficam estáveis juntos antes da borda.

O que não deve ser misturado:

- `PUSH_DEC`, `PUSH_SP` e `PUSH_STORE` são três estados sucessivos;
- `POP_REQ`, `POP_WAIT` e `POP_CAP` são três etapas temporais da memória síncrona;
- `POP_RD` e `POP_SP` são escritas diferentes no banco e não acontecem na mesma borda.

## 5. Por que R8 não aparece como um bloco explícito

O banco possui registradores numerados de R0 a R31. O diagrama não desenha 32 caixas separadas; ele desenha uma única abstração, o **banco de registradores**.

Uma instrução contém campos que selecionam registradores:

- `rs`: registrador-fonte;
- `rt`: segunda fonte ou destino, dependendo da instrução;
- `rd`: destino das instruções tipo R.

No exemplo `PUSH R8`, o campo `rs` contém o número 8. Portanto:

```text
R[rs] = R[8] = R8
```

O mapa escreve `B ← R[rs]` porque ele descreve qualquer `PUSH rs`. Para o exemplo concreto, leia essa expressão como `B ← R8`.

R29 aparece nominalmente porque a arquitetura fixou esse registrador como **SP**, o ponteiro da pilha. `Read1Sel=1` força a porta 1 do banco a ler R29.

## 6. Como percorrer o mapa inteiro sem se perder

### Etapa A — Comece em G0

Toda instrução passa pela busca:

```text
PC → IorD → memória → IR
          ALU → PC + 4
```

Explique G0 uma única vez. Não repita a busca em cada instrução.

### Etapa B — Pare em DECODE

DECODE é o entroncamento. A UC examina:

1. o opcode;
2. o funct, quando o opcode indica uma instrução tipo R.

Depois, siga apenas a seta da instrução que está sendo explicada.

### Etapa C — Escolha uma cor

| Grupo | Cor no mapa | Instruções | Ideia dominante |
|---|---|---|---|
| G0 | cinza | todas | buscar e identificar |
| G1 | azul | ADD, AND, SUB, SLT, ADDI | calcular e escrever no banco |
| G2 | violeta | SLL, SRA, LUI | deslocar ou formar constante |
| G3 | ciano | LW, LB | memória → MDR → banco |
| G4 | laranja | SW, SB | banco → memória |
| G5 | amarelo | BEQ, BNE | comparar e decidir o PC |
| G6 | rosa | J, JAL, JR | escolher diretamente outro PC |
| G7 | verde | MULT, DIV, MFHI, MFLO | produzir ou consumir HI/LO |
| G8 | cinza-escuro | PUSH, POP | manipular a pilha por R29 |

### Etapa D — Volte à busca

Ao chegar ao fim de um caminho, mostre o laço de retorno. Isso fecha a história de uma instrução antes de iniciar outra.

## 7. Padrão lógico de cada grupo

### G1 — resultado de ALU no banco

```text
operandos → ALU/comparador → resultado → banco
```

Explique ADD por completo. Nas demais, diga somente o que muda: operação, fonte do segundo operando ou registrador-destino.

### G2 — deslocamento e LUI

```text
fonte → SHIFT/formador de constante → MemtoReg → banco
```

SLL e SRA diferem no tipo de deslocamento. LUI monta a metade alta da palavra.

### G3 — cargas

```text
base + offset → ALUOut → memória → MDR → banco
```

O MDR separa a temporização da memória da escrita no banco.

### G4 — armazenamentos

```text
base + offset → ALUOut → memória
                       ↑ dado do banco
```

SW grava a palavra. SB combina o byte novo com os bytes que devem ser preservados.

### G5 — desvios

```text
alvo calculado + comparação → PCWriteCond → PC
```

BEQ aceita a igualdade; BNE aceita a desigualdade.

### G6 — saltos

```text
destino montado ou registrador → PCSource → PC
```

JAL também grava o endereço de retorno em R31.

### G7 — HI/LO

```text
MULT/DIV: A e B → unidade especial → HI/LO
MFHI/MFLO: HI/LO → banco
```

Separe produtores de consumidores.

### G8 — pilha

```text
R29 → A → ALU/ALUOut → endereço da memória
R[rs] → B → dado de PUSH
memória → MDR → rd em POP
```

PUSH e POP compartilham hardware, mas não a ordem dos efeitos.

## 8. PUSH explicado ciclo a ciclo

Semântica:

```text
SP ← SP antigo − 4
M32[SP] ← R[rs] antigo
```

Exemplo: `R29=227`, `R8=0xAABBCCDD`, instrução `PUSH R8`.

| Ordem | Estado | Valores durante o ciclo | Efeito na borda |
|---:|---|---|---|
| 1 | CAPTURA | porta 1 seleciona R29; porta 2 seleciona `rs=8` | A=227; B=0xAABBCCDD |
| 2 | PUSH_DEC | ALU calcula A−4 | ALUOut=223 |
| 3 | PUSH_SP | ALUOut vai à porta de escrita; destino é R29 | R29=223 |
| 4 | PUSH_STORE | endereço=ALUOut; dado=B | M32[223]=0xAABBCCDD |

Por que B é importante: ele preserva o valor-fonte antigo. Isso também protege o caso `PUSH R29`, no qual o dado empilhado deve ser o SP anterior, não o SP já decrementado.

Resumo verbal:

> **Captura → calcula SP−4 → atualiza SP → grava o dado.**

## 9. POP explicado ciclo a ciclo

Semântica:

```text
R[rd] ← M32[SP antigo]
SP ← SP antigo + 4
```

Exemplo: `R29=223`, `M32[223]=0xAABBCCDD`, instrução `POP R9`.

| Ordem | Estado | Valores durante o ciclo | Efeito na borda |
|---:|---|---|---|
| 1 | CAPTURA | porta 1 seleciona R29 | A=223 |
| 2 | POP_ADDR | ALU passa A | ALUOut=223 |
| 3 | POP_REQ | memória recebe endereço 223 e pedido de leitura | requisição iniciada |
| 4 | POP_WAIT | endereço 223 permanece estável | saída da memória amadurece |
| 5 | POP_CAP | saída válida está disponível | MDR=0xAABBCCDD |
| 6 | POP_RD | MDR vai à porta de escrita; destino é `rd=9` | R9=0xAABBCCDD |
| 7 | POP_INC | ALU calcula A+4 | ALUOut=227 |
| 8 | POP_SP | ALUOut vai à porta de escrita; destino é R29 | R29=227 |

Resumo verbal:

> **Captura → fixa endereço → pede → espera → captura → entrega → calcula SP+4 → atualiza SP.**

## 10. Como explicar o exemplo 227 → 223 → 227

Use uma linha do tempo, não uma descrição solta:

```text
antes do PUSH       após PUSH              após POP
R29=227             R29=223                R29=227
R8 =AABBCCDD        M32[223]=AABBCCDD       R9=AABBCCDD
```

Se a memória for apresentada em bytes little-endian:

```text
endereço: 223  224  225  226
byte:      DD   CC   BB   AA
```

Não arredonde 223 para 220: a especificação usa o endereço calculado exatamente.

## 11. Erros de explicação a evitar

- Dizer que POP é uma consulta. POP recupera o valor, escreve em `rd` e avança o SP.
- Tratar R8 como um sinal de controle. R8 é um registrador selecionado pelo campo `rs=8`.
- Dizer que todas as caixas acontecem em paralelo. Apenas ações internas do estado podem coexistir no mesmo ciclo.
- Incrementar o SP antes da leitura do POP. Isso faria a memória usar o endereço seguinte.
- Gravar `rd` e R29 na mesma borda no POP. O banco possui uma única porta de escrita; por isso existem estados separados.
- Eliminar `POP_WAIT` sem verificar a memória síncrona do HDL.
- Usar `rt` como destino do POP. A instrução escreve em `rd`.
- Procurar um registrador SP separado. O SP é R29.
- Manter XCHG ou SRAM como instruções válidas. Elas foram substituídas por PUSH e POP nesta revisão.

## 12. Checklist antes de apresentar

- [ ] Consigo apontar FETCH, DECODE e o retorno à busca.
- [ ] Consigo explicar a diferença entre paralelismo interno e sequência de estados.
- [ ] Sei dizer por que G0 não entra na contagem das 23 instruções.
- [ ] Sei usar uma instrução representante por grupo, sem ler todos os sinais.
- [ ] Consigo explicar `R[rs] = R8` no exemplo `PUSH R8`.
- [ ] Consigo percorrer `227 → 223 → 227` sem trocar a ordem dos efeitos.
- [ ] Consigo justificar REQ, WAIT e CAP no POP.
- [ ] Sei afirmar que XCHG e SRAM não pertencem à revisão atual.

## 13. Fórmula curta para responder perguntas no quadro

Quando alguém perguntar “o que acontece aqui?”, responda nesta ordem:

1. **Estado:** “Estamos em...”
2. **Entradas:** “Já temos...”
3. **Sinais:** “A UC habilita...”
4. **Resultado do ciclo:** “O hardware produz...”
5. **Borda:** “No clock, fica registrado...”
6. **Próximo estado:** “Depois seguimos para...”

Essa fórmula obriga a explicação a respeitar o tempo e impede que sinais de caixas diferentes sejam misturados.
