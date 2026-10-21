# Roteiro lúdico — apresentação do mapa de estados em 30 minutos

## Objetivo da apresentação

Explicar o mapa de estados como uma **viagem guiada pelo processador**, sem tentar ler todos os sinais de uma só vez. A plateia deve sair sabendo:

1. por que toda instrução começa em **G0 — busca comum**;
2. como as 23 instruções foram organizadas em grupos de caminhos semelhantes;
3. que os blocos do mapa são executados **estado após estado**, embora vários sinais possam ficar ativos dentro do mesmo ciclo;
4. por que `PUSH` e `POP` usam **R29 como SP** e têm ordens diferentes;

Mapa da apresentação: [frame Mapa-de-Estado no FigJam](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=91-660).

## Ideia lúdica central

Apresente o mapa como um **metrô do processador**:

- a estação central é **G0 — Busca e Decodificação**;
- as cores são linhas diferentes do metrô;
- cada caixa é uma estação de um ciclo;
- cada seta indica a próxima estação;
- os sinais escritos na caixa são as ações autorizadas enquanto o trem está naquela estação;
- a borda do clock é o instante em que as ações são registradas e o trem avança.

Frase-guia: **“As luzes podem acender juntas dentro da estação; o trem, porém, visita uma estação por ciclo.”**

## Como apontar no board sem parecer que está apenas lendo

Em todos os grupos, use sempre a mesma ordem de apontamento. Ela cria um método visual e ajuda a plateia a acompanhar seu raciocínio:

1. **Mostre a cor e o nome do grupo.** Diga qual família de instruções está sendo discutida.
2. **Mostre a seta que chega da decodificação.** Isso deixa claro que aquele caminho só começa depois de `FETCH` e `DECODE`.
3. **Aponte a primeira caixa.** Identifique de onde vêm os operandos.
4. **Desça pelas setas, uma caixa por vez.** Não mova o cursor para a caixa seguinte antes de concluir o efeito da atual.
5. **Dentro da caixa, aponte primeiro a microoperação e depois os sinais.** Por exemplo: primeiro “ALUOut recebe A−4”; depois `ALUSrcA`, `ALUSrcB`, `F` e `ALUOutWrite`.
6. **Mostre onde o resultado fica guardado.** Pode ser ALUOut, MDR, banco, PC, HI/LO ou memória.
7. **Finalize apontando o retorno à busca.** Diga explicitamente: “a instrução terminou; a UC volta para buscar a próxima”.

Use o cursor como se fosse o trem da analogia. Se estiver explicando uma caixa, deixe o cursor parado nela. Isso transmite controle do fluxo e evita que a plateia misture estados diferentes.

> **Nota de ensaio:** os tópicos “O que mostrar no board” são uma base de domínio. Você não precisa falar cada linha durante a apresentação. Use os detalhes para saber o que está vendo e escolha os mais importantes conforme o tempo.

---

## 0:00–2:00 — Abertura: entregar o mapa à plateia

### No quadro

Mostre o frame inteiro, sem dar zoom nos sinais.

### O que mostrar no board — passo a passo

1. Contorne visualmente o quadro inteiro com o cursor, sem entrar nas caixas.
2. Aponte a região central superior, onde estão `FETCH` e `DECODE`.
3. Desça o cursor até o ponto em que o fluxo se abre para as várias instruções.
4. Percorra rapidamente as colunas coloridas da esquerda para a direita.
5. Mostre a linha de retorno na parte inferior e siga-a até a busca.

O objetivo aqui não é explicar sinais. É mostrar a arquitetura geral do mapa:

```text
BUSCA → DECODIFICAÇÃO → CAMINHO DA INSTRUÇÃO → RETORNO À BUSCA
```

Ao terminar, diga: **“Agora que vimos o contexto geral, vamos agora ver o comportamento das instruções.”**

### Fala sugerida

> “Este desenho parece uma cidade vista de cima. Se tentarmos ler todas as ruas ao mesmo tempo, ficamos perdidos. Então hoje vamos tratá-lo como um metrô: primeiro entendemos a estação central e as linhas coloridas; depois viajamos por uma linha de cada vez.”

> 1. “O mapa representa a **máquina de estados da unidade de controle**. Cada caixa é um estado. A seta não significa que tudo acontece junto: ela significa ‘no próximo ciclo, siga para cá ou pra lá’.”

---

## 2:00–5:00 — A legenda: nove cores, uma lógica

### No quadro

Aponte a legenda G0–G8 no canto superior esquerdo.

### O que mostrar no board — passo a passo

1. Aponte `G0` e depois a região central de `FETCH/DECODE`. Mostre que a cor da legenda corresponde à parte comum do mapa.
2. Passe por `G1` até `G8`, apontando simultaneamente a cor da legenda e a mesma cor no fluxo abaixo.
3. Em cada item, diga apenas **verbo + destino**:

   - G1: “calcula e escreve no banco”;
   - G2: “desloca ou monta constante”;
   - G3: “traz da memória”;
   - G4: “leva para a memória”;
   - G5: “compara e decide”;
   - G6: “troca o PC diretamente”;
   - G7: “produz ou lê HI/LO”;
   - G8: “move o topo da pilha”.

4. Volte o cursor para G0 antes de iniciar a explicação detalhada. Isso prepara a transição para a busca comum.

Não leia os nomes das 23 instruções neste momento.

### Fala sugerida

> “Como eu tinha explicado anteriormente, as cores não indicam prioridade nem velocidade. Elas identificam famílias de instruções que reutilizam caminhos parecidos.”

Faça uma leitura rápida:

- **G0, cinza:** busca comum;
- **G1, azul:** resultado de ALU voltando ao banco;
- **G2, violeta:** deslocamento e LUI;
- **G3, ciano:** cargas da memória;
- **G4, laranja:** armazenamentos;
- **G5, amarelo:** desvios condicionais;
- **G6, rosa:** saltos;
- **G7, verde:** família HI/LO;
- **G8, cinza-escuro:** pilha, com PUSH e POP.

### Mensagem que precisa ficar

> “G0 é transversal: todas as 23 instruções passam por ele. G1 a G8 dividem o trabalho específico.”

---

## 5:00–8:00 — G0: a estação central

### No quadro

Dê zoom na região superior central: `FETCH` e `DECODE`.

### O que mostrar no board — passo a passo

1. **Comece em `FETCH`.** Aponte, nesta ordem:

   - `MemRead=1`: a memória está sendo lida;
   - `IorD=0`: o endereço escolhido é o PC, pois ainda estamos buscando uma instrução;
   - `IRWrite=1`: a palavra lida será registrada no IR.

2. Enquanto ainda aponta `FETCH`, explique que a ALU também prepara `PC+4`. Destaque que isso ocorre no mesmo ciclo porque memória e ALU são blocos de hardware diferentes.
3. Siga a seta horizontal de `FETCH` para `DECODE`.
4. **Em `DECODE`,** aponte a preparação do possível alvo de desvio e diga que a UC examina o opcode da instrução que já está no IR.
5. Aponte a saída inferior da região central e abra o cursor em direção às várias colunas. Diga: “a partir daqui, a decodificação escolhe apenas uma linha”.
6. Mostre rapidamente o grande laço de retorno que chega novamente à busca.

### Demonstração de domínio

Se perguntarem por que `IorD=0` em `FETCH`, responda:

> “IorD escolhe a origem do endereço da memória. Zero seleciona o PC para buscar instrução; nos acessos a dados, como LW, SW, PUSH e POP, usamos ALUOut como endereço efetivo.”

Se perguntarem se `IRWrite` permanece ligado durante a execução, responda:

> “Não. IRWrite fica ativo na busca. Durante os estados específicos, o IR deve permanecer estável para que opcode, funct e campos de registradores não mudem no meio da instrução.”

### Fala sugerida

> “Antes de saber qual instrução chegou, o processador precisa buscá-la. Em FETCH, a memória é lida com o PC como endereço, a instrução entra no IR e a ALU prepara PC+4.”

> “Algumas coisas realmente ocorrem no mesmo ciclo: a memória pode ser lida enquanto a ALU calcula PC+4. Isso é paralelismo de sinais e de hardware dentro de um estado. A passagem de FETCH para DECODE, entretanto, só acontece na borda do clock.”

> “Em DECODE, a UC olha primeiro o opcode. Se for tipo R, o funct termina de identificar a instrução. Depois disso, apenas um caminho específico é seguido.”

### Analogia curta

> “FETCH é a catraca; DECODE é a placa que diz qual linha pegar.”

---

## 8:00–12:00 — G1 e G2: calcular e transformar

### G1 — azul

Use `ADD` como representante.

> “ADD, AND, SUB, SLT e ADDI têm um roteiro dominante parecido: buscar operandos, produzir um resultado e escrevê-lo no banco.”

Mostre apenas as diferenças:

- ADD, AND e SUB mudam a operação da ALU;
- SLT transforma a comparação em 0 ou 1;
- ADDI troca o segundo registrador pelo imediato e escreve em `rt`.

#### O que mostrar no board em G1 — passo a passo

1. Aponte a área azul e identifique as colunas `AND`, `ADD`, `SUB` e `ADDI`; depois mostre `SLT`, que aparece como um ramo azul separado.
2. Comece pela **primeira caixa de ADD**:

   - aponte `ALUSrcA` e diga que a primeira entrada vem do registrador A;
   - aponte `ALUSrcB` e diga que a segunda entrada vem de B;
   - aponte a operação de soma;
   - conclua apontando `ALUOut`: “o resultado não vai direto ao banco; ele fica preservado em ALUOut”.

3. Desça pela seta até a caixa de **write back** de ADD:

   - `RegWrite=1` autoriza a escrita;
   - `RegDst` escolhe o campo de destino;
   - `MemtoReg` escolhe ALUOut como dado a escrever.

4. Volte à primeira linha e deslize horizontalmente por AND e SUB. Não repita o caminho inteiro. Aponte apenas o campo da operação e diga: “mesmas fontes, mesmo registrador intermediário e mesmo write back; muda a função executada”.
5. Em `SLT`, aponte a comparação e depois o estado que escreve 0 ou 1 no banco. Diga: “o resultado representa uma condição, mas continua terminando no banco”.
6. Em `ADDI`, aponte a seleção do imediato e depois o destino `rt`. Diga: “a estrutura permanece ALU → ALUOut → banco; mudam a segunda fonte e o campo de destino”.

#### O que você precisa concluir antes de sair de G1

> “O elemento comum do grupo não é a operação específica. É o formato do percurso: operandos entram na unidade de cálculo, ALUOut segura o resultado e um estado posterior escreve no banco.”

### G2 — violeta

Use `SLL` como representante.

> “SLL e SRA passam pela unidade de deslocamento; LUI forma uma constante na metade alta. O destino continua sendo o banco, mas o produtor do valor já não é o caminho normal da ALU.”

#### O que mostrar no board em G2 — passo a passo

1. Aponte primeiro a coluna `SLL` e percorra suas caixas de cima para baixo.
2. Na primeira caixa, destaque:

   - a origem do valor que será deslocado;
   - a origem da quantidade de deslocamento (`shamt`);
   - `ShiftControl`, que determina o tipo de deslocamento.

3. Aponte o estado final de escrita e diga: “o resultado do shifter é selecionado para entrar no banco”.
4. Mova o cursor para `SRA` e compare visualmente com `SLL`. Mostre que o caminho é quase idêntico e a diferença está no comando de deslocamento:

   - SLL preenche com zeros à direita lógica;
   - SRA preserva o sinal ao deslocar para a direita.

5. Aponte `LUI` separadamente. Mostre que ele não precisa realizar uma conta entre dois registradores: o imediato é colocado na metade alta da palavra e depois escrito no destino.

#### O que você precisa concluir antes de sair de G2

> “G2 também termina no banco, como G1. A diferença é quem fabrica o valor: em G1 é a ALU ou o comparador; em G2 é o shifter ou o formador de constante.”

### Transição lúdica

> “A linha azul fabrica um resultado aritmético. A violeta pega bits e muda sua posição ou monta uma constante.”

---

## 12:00–16:00 — G3 e G4: memória como entrada e como saída

### G3 — ciano: LW e LB

> “Na carga, o processador calcula `base + offset`, usa ALUOut como endereço, lê a memória, guarda o retorno em MDR e só depois escreve no banco.”

> “LW traz uma palavra; LB traz um byte e faz a extensão definida pelo projeto. O esqueleto do trajeto é o mesmo.”

#### O que mostrar no board em G3 — passo a passo

1. Aponte o topo da coluna `LW`, na caixa `RS + OFFSET`.
2. Destaque a seleção de A como base, do imediato como offset e da soma como operação. Conclua: “ALUOut agora guarda um endereço, não um resultado aritmético para o programa”.
3. Desça para `ReadMem` e aponte:

   - `IorD=1`: a memória recebe ALUOut como endereço de dado;
   - `MemRead=1`: o acesso é de leitura;
   - a captura em MDR: o retorno da memória precisa ser preservado.

4. Desça para `WriteReg`:

   - `MemtoReg` seleciona MDR;
   - `RegDst` seleciona o destino da carga;
   - `RegWrite=1` conclui a instrução.

5. Vá até a coluna `LB` e repita apenas os três títulos visuais: calcular endereço, ler memória, escrever registrador.
6. Na última caixa de LB, aponte a seleção/adequação do byte e diga que a diferença em relação a LW está na largura do dado e na extensão antes do write back.

#### O que você precisa concluir antes de sair de G3

> “Uma carga não escreve no banco no mesmo estado em que pede a memória. Primeiro calcula o endereço, depois lê e captura em MDR, e somente então faz o write back.”

### G4 — laranja: SW e SB

> “No armazenamento, o início é parecido: também calculamos `base + offset`. Mas agora o fluxo termina na memória. SW grava uma palavra; SB preserva os outros bytes e substitui apenas o byte escolhido.”

#### O que mostrar no board em G4 — passo a passo

1. Aponte a caixa `RS + OFFSET` de `SW` e compare-a com a primeira caixa de LW. Diga: “o cálculo do endereço é compartilhado”.
2. Desça para `WriteMem` e destaque:

   - `IorD=1`: ALUOut fornece o endereço;
   - `MemWrite=1`: agora a memória recebe uma escrita;
   - `DataSource`: seleciona o dado vindo do caminho do registrador B.

3. Aponte que o caminho termina na memória e não possui uma caixa posterior de `WriteReg`.
4. Vá para `SB`. Mostre os três momentos visuais:

   - calcular o endereço;
   - ler/preservar a palavra existente;
   - gravar a palavra combinada com apenas o byte substituído.

5. Aponte `MergeBytes`/seleção equivalente na última caixa de SB. Diga: “SB não deve destruir os outros três bytes da palavra”.

#### Comparação visual que demonstra domínio

Coloque o cursor alternadamente em LW e SW:

```text
LW: memória → MDR → banco
SW: banco/B → memória
```

Depois faça o mesmo com LB e SB:

```text
LB: escolhe um byte e o leva ao banco
SB: troca um byte e preserva os demais na memória
```

### Pergunta para a plateia

**“Qual é a diferença visual mais importante?”**

Resposta esperada: em G3 o dado volta ao banco; em G4 o dado sai do banco e termina na memória.

### Frase de fixação

> “Carga traz; armazenamento leva.”

---

## 16:00–20:00 — G5 e G6: quem muda o PC?

### G5 — amarelo: BEQ e BNE

> “O desvio é uma pergunta. BEQ pergunta ‘são iguais?’; BNE pergunta ‘são diferentes?’. O comparador decide se o PC recebe o alvo ou mantém o fluxo normal.”

Aponte a decisão e seus dois ramos.

#### O que mostrar no board em G5 — passo a passo

1. Aponte as duas caixas superiores, `BEQ` e `BNE`, e diga que ambas usam A e B como operandos da comparação.
2. Destaque que a operação compara os valores; não é um resultado destinado ao banco.
3. Siga as duas setas até o nó de decisão central.
4. Aponte os rótulos `TRUE` e `FALSE` das saídas. Explique que a interpretação muda entre BEQ e BNE:

   - BEQ aceita o ramo quando A e B são iguais;
   - BNE aceita o ramo quando A e B são diferentes.

5. No ramo que altera o fluxo, aponte `PCWriteCond` e `PCSource`. Diga que um sinal autoriza condicionalmente a escrita e o outro escolhe o alvo já calculado.
6. No ramo que não altera o PC, diga: “nenhuma escrita condicional é aceita; o PC já aponta para a instrução sequencial preparada na busca”.

#### O que você precisa concluir antes de sair de G5

> “BEQ e BNE compartilham alvo, comparador e escrita condicional do PC. O que muda é qual resultado lógico da comparação autoriza o desvio.”

### G6 — rosa: J, JAL e JR

> “O salto não pergunta: ele escolhe um destino. J usa o endereço montado da instrução; JR usa um registrador; JAL também preserva o endereço de retorno em R31.”

#### O que mostrar no board em G6 — passo a passo

1. Comece em `J`. Aponte a caixa rosa e destaque `PCSource`: ela seleciona o endereço de salto montado a partir da instrução.
2. Aponte `PCWrite=1` e diga: “diferentemente de BEQ/BNE, não dependemos do resultado de uma comparação”.
3. Vá para `JR`. Aponte que a origem do novo PC é o valor lido de um registrador, normalmente preservado em A.
4. Vá para `JAL` e percorra suas duas responsabilidades:

   - alterar o PC como J;
   - selecionar R31 e gravar o endereço de retorno.

5. Aponte a caixa de write back de JAL e destaque `RegDst`/seleção de R31, `MemtoReg`/fonte do endereço de retorno e `RegWrite=1`.

#### Comparação de uma frase

> “J escolhe um endereço da instrução; JR recebe o endereço de um registrador; JAL salta e deixa uma trilha de volta em R31.”

### Analogia curta

> “G5 é uma bifurcação com semáforo. G6 é uma mudança direta de linha.”

---

## 20:00–23:00 — G7: a família HI/LO

### No quadro

Percorra MULT, DIV, MFHI e MFLO na cor verde.

### O que mostrar no board — passo a passo

1. Aponte `MULT` e `DIV` primeiro. Diga que as duas caixas recebem operandos do caminho A/B e iniciam unidades que podem levar mais de um ciclo.
2. Em MULT, destaque as escritas em `HI` e `LO`. Explique:

   - LO recebe a parte baixa do produto;
   - HI recebe a parte alta.

3. Em DIV, destaque novamente HI e LO, mas mude a interpretação:

   - LO recebe o quociente;
   - HI recebe o resto.

4. Se o mapa mostrar estado de espera/conclusão, percorra-o e diga: “a UC não pode consumir o resultado antes de a unidade sinalizar que terminou”.
5. Depois aponte `MFHI` e `MFLO`. Mostre que são caminhos curtos porque não recalculam nada:

   - MFHI seleciona HI;
   - MFLO seleciona LO;
   - `RegWrite` copia o valor escolhido para `rd`.

6. Faça o movimento visual de ida e volta: MULT/DIV entram em HI/LO; MFHI/MFLO saem de HI/LO para o banco.

### O que você precisa concluir antes de sair de G7

> “HI e LO desacoplam uma operação que produz dois resultados do banco, que só possui uma porta normal de escrita. Primeiro produzimos e guardamos; depois uma instrução MF move o valor desejado.”

### Fala sugerida

> “MULT e DIV são produtores: colocam resultados em HI e LO. MFHI e MFLO são transportadores: copiam um desses registradores especiais para o banco.”

> “Uma boa dupla para lembrar é MULT seguido de MFLO: primeiro produzimos em HI/LO; depois retiramos o valor de LO.”

### Atenção

Não tente explicar todos os sinais de MULT e DIV. Destaque o padrão produtor/consumidor e siga adiante.

---

## 23:00–29:00 — G8: a viagem completa de PUSH e POP

### Preparação: o que significa R8?

Antes do exemplo, diga:

> “R8 não é um bloco novo da arquitetura. O banco já possui R0 até R31. Na instrução `push R8`, o campo `rs` contém o número 8. Por isso o mapa escreve `R[rs]`: para essa instrução concreta, `R[rs]` significa R8.”

> “R29 é diferente apenas por convenção: ele é o registrador usado como SP, o ponteiro da pilha.”

### Exemplo numérico

Estado inicial:

```text
R29 = 227
R8  = 0xAABBCCDD
instrução = PUSH R8
```

### PUSH — quatro paradas contando a captura

Percorra a coluna `PUSH` de cima para baixo.

#### O que mostrar no board antes de falar os quatro estados

1. Aponte o título `G8 • PUSH — push rs`.
2. Mostre a seta que chega da decodificação até a coluna.
3. Passe o cursor pelas quatro caixas, sem explicar ainda, e antecipe o roteiro:

   ```text
   capturar → calcular 223 → atualizar R29 → gravar memória
   ```

4. Volte à caixa `CAPTURA` e só então inicie a explicação estado a estado.

1. **CAPTURA**

   > “Read1Sel escolhe R29 e A guarda 227. Read2Sel usa o campo `rs`; como a instrução diz R8, B guarda o valor antigo de R8. Duas portas de leitura permitem capturar A e B no mesmo ciclo.”

   No board, aponte primeiro `A ← R29`, depois `B ← R[rs]` e por último os enables `AWrite` e `BWrite`. Conclua: **“A e B só recebem os valores na borda; depois continuam preservando-os.”**

2. **PUSH_DEC**

   > “A ALU calcula 227 − 4. ALUOut guarda 223. Ainda não houve escrita na memória.”

   No board, siga a ordem `ALUSrcA` → `ALUSrcB` → `F=010` → `ALUOutWrite`. Diga que os três primeiros configuram o cálculo e o último registra o resultado.

3. **PUSH_SP**

   > “O banco recebe 223 em R29. O topo da pilha desceu.”

   No board, aponte `RegDst=3`, que seleciona R29; depois `MemtoReg=0`, que seleciona ALUOut; por fim `RegWrite=1`, que efetiva a escrita na borda.

4. **PUSH_STORE**

   > “ALUOut fornece o endereço 223 e B fornece o valor antigo de R8. A memória grava `0xAABBCCDD` em M32[223].”

   No board, aponte `IorD=1` para o endereço, `DataSource=2` para o dado B e `MemWrite=1` para a escrita. Depois mostre a saída `→ BUSCA`.

Faça a plateia repetir:

> **“PUSH primeiro desce o SP; depois grava.”**

Resultado:

```text
R29 = 223
M32[223] = 0xAABBCCDD
```

Explique o caso que costuma confundir:

> “Se fosse `PUSH R29`, B já teria preservado o R29 antigo. Atualizar o SP antes da memória não destruiria o dado que será empilhado.”

### POP — captura mais sete estados

Agora suponha `POP R9` com `R29 = 223`.

#### O que mostrar no board antes de falar os oito estados

1. Aponte o título `G8 • POP — pop rd`.
2. Passe o cursor por toda a coluna e divida-a verbalmente em três blocos:

   - **preparar o endereço:** CAPTURA e POP_ADDR;
   - **ler a memória:** POP_REQ, POP_WAIT e POP_CAP;
   - **entregar e liberar o topo:** POP_RD, POP_INC e POP_SP.

3. Volte ao topo e percorra uma seta por vez.

1. **CAPTURA:** A recebe o SP atual, 223.
2. **POP_ADDR:** ALUOut recebe A; o endereço continua sendo 223.
3. **POP_REQ:** a leitura é solicitada.
4. **POP_WAIT:** o endereço fica estável enquanto a memória responde.
5. **POP_CAP:** MDR captura `0xAABBCCDD`.
6. **POP_RD:** R9 recebe MDR; R29 ainda vale 223.
7. **POP_INC:** a ALU calcula 223 + 4 = 227.
8. **POP_SP:** R29 recebe 227 e o fluxo volta à busca.

#### O que apontar em cada estado de POP

- **CAPTURA:** `Read1Sel=1` e `AWrite=1`. Diga: “A congela o endereço original da pilha”.
- **POP_ADDR:** `ALUSrcA=1`, `F=000` e `ALUOutWrite=1`. Diga: “a ALU apenas passa A; não incrementamos ainda”.
- **POP_REQ:** `IorD=1`, `MemRead=1` e `MDRWrite=0`. Diga: “o pedido começou, mas ainda não capturamos”.
- **POP_WAIT:** aponte os mesmos sinais e ressalte `MDRWrite=0`. Diga: “o endereço permanece; damos tempo à memória”.
- **POP_CAP:** aponte `MDRWrite=1`. Diga: “agora a saída estável entra em MDR”.
- **POP_RD:** `RegDst=1`, `MemtoReg=1` e `RegWrite=1`. Traduza: “destino é rd; dado vem de MDR; escrita autorizada”.
- **POP_INC:** `ALUSrcA=1`, `ALUSrcB=1`, `F=001` e a escrita em ALUOut. Diga: “usamos o A antigo para calcular SP+4”.
- **POP_SP:** `RegDst=3`, `MemtoReg=0` e `RegWrite=1`. Traduza: “destino é R29; dado vem de ALUOut; o novo SP é registrado”.

#### Demonstração de domínio: por que A ainda contém 223?

> “A só foi escrito na captura. Nenhum estado intermediário ativa AWrite novamente. Portanto, mesmo depois de escrever R9, A continua preservando o SP antigo e pode ser usado em POP_INC.”

Faça a plateia repetir:

> **“POP primeiro lê; depois sobe o SP.”**

### Por que REQ, WAIT e CAP não são redundantes?

> “A memória do projeto é síncrona. REQ apresenta a solicitação; WAIT dá tempo para a saída ficar válida; CAP registra o valor estável em MDR. Juntar esses estados sem verificar a temporização poderia capturar um dado antigo.”

### Fechamento do grupo

> “PUSH e POP compartilham R29, A, ALU, ALUOut, IorD e memória. A diferença decisiva é a ordem: PUSH calcula e atualiza antes de gravar; POP lê e entrega o dado antes de incrementar.”

---

## 29:00–30:00 — Fechamento e teste de memória

Volte ao mapa inteiro e faça três perguntas rápidas:

1. **“Toda instrução começa onde?”** — G0, busca comum.
2. **“PUSH altera o SP para qual lado?”** — diminui de 4.
3. **“POP incrementa antes ou depois da leitura?”** — depois.

Feche com:

> “O mapa não é uma parede de sinais. É uma história temporal: buscar, identificar, executar e voltar. As cores mostram famílias; as setas mostram a ordem; o clock transforma cada caixa em um passo.”

### O que mostrar no board durante o fechamento

1. Aponte G0 enquanto pergunta onde toda instrução começa.
2. Aponte a seta descendente de PUSH ao perguntar para que lado o SP se move.
3. Aponte `POP_CAP` antes de `POP_INC` ao perguntar quando o POP incrementa.
4. Faça um último percurso rápido: G0 → um grupo colorido → linha inferior → G0.
5. Termine com o cursor parado em `FETCH`, reforçando que o processador está pronto para a próxima instrução.

---

## Plano de contingência de tempo

Se restarem apenas 20 minutos:

- mantenha G0 em 3 minutos;
- resuma G1–G7 em 8 minutos, um padrão por cor;
- preserve 7 minutos para PUSH/POP;
- use 2 minutos para abertura e fechamento.

Se houver perguntas durante a apresentação, responda primeiro indicando no mapa **qual caixa** e **qual borda de clock** estão sendo discutidas. Isso evita misturar ciclos diferentes.

## Perguntas prováveis e respostas curtas

**“Push é inserir e pop é só consultar?”**  
Não. PUSH insere um valor na pilha; POP retira logicamente o valor, escreve-o em um registrador e atualiza o SP. A memória não precisa ser apagada: mudar o SP já remove o item da pilha do ponto de vista lógico.

**“Onde está R8 no hardware?”**  
R8 é uma das 32 entradas do banco de registradores. O campo `rs=8` da instrução seleciona essa entrada; por isso o mapa usa a forma genérica `R[rs]`.

**“Os sinais acontecem em paralelo?”**  
Dentro de um estado, vários sinais ficam ativos simultaneamente. Os estados, porém, são percorridos em sequência, um por ciclo, e as escritas ficam registradas na borda do clock.

**“Por que POP tem mais estados?”**  
Porque precisa respeitar a leitura síncrona da memória e ainda fazer duas escritas no banco em momentos diferentes: primeiro `rd`, depois R29.

**“Por que XCHG e SRAM sumiram?”**  
Porque eram extensões da versão anterior. Nesta revisão, as extensões válidas são PUSH e POP.
