# 05 — Roteiro de apresentação da primeira etapa: arquitetura do processador

[Índice](README.md) · [Dicionário](10-dicionario-de-siglas-e-termos.md) · [Catálogo das 23 instruções](02-catalogo-23-instrucoes.md) · [Arquitetura e sinais](03-arquitetura-e-sinais.md) · [Índice do Figma](09-indice-figma.md)

> **Nome correto do desenho:** trata-se da **arquitetura do processador**, ou diagrama de blocos da **unidade de processamento** e da sua interface com a **UC (unidade de controle)**.
>
> **Convenção de leitura:** na primeira ocorrência, o roteiro escreve a sigla seguida do nome por extenso entre parênteses. As definições completas estão no [dicionário de siglas e termos](10-dicionario-de-siglas-e-termos.md).



## 1. O que esta apresentação precisa demonstrar

A primeira etapa pede a apresentação do circuito que implementará o processador. Portanto, o foco é explicar:

1. quais são os módulos da arquitetura;
2. por que cada módulo existe;
3. como os módulos são conectados;
4. quais sinais saem da UC e o que cada um seleciona, habilita ou escreve;
5. como os caminhos reutilizam hardware para atender às 23 instruções;
6. como cada instrução percorre os blocos relevantes.

O [quadro no Figma](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=0-1) é a versão de referência da arquitetura.

## 2. Escopo da fala


| Deve entrar na explicação                                                                                                                                                        | Não deve ser o centro da apresentação                                                        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Datapath (caminho de dados), memória, banco de registradores, UC e sinais de controle.                                                                                           | Estados, transições e codificação da FSM (Finite State Machine, máquina de estados finitos). |
| Reuso da ALU (Arithmetic Logic Unit, unidade lógica e aritmética), memória e caminhos de escrita.                                                                                | Formas de onda ou resultados de testbench ainda não executados.                              |
| Caminho de cada família de instruções.                                                                                                                                           | Detalhes de implementação em Verilog/VHDL (linguagens de descrição de hardware).             |
| Extensões para MULT/DIV (multiplicação/divisão), SHIFT (unidade de deslocamento), HI/LO (registradores das partes alta/baixa), bytes, exceções, PUSH/POP (empilhar/desempilhar). | Alegar que o processador já está funcional somente porque o diagrama existe.                 |


Quando alguém perguntar sobre a próxima etapa, a resposta adequada é: “Nesta etapa definimos os recursos e os caminhos. Na etapa seguinte a UC será detalhada como FSM, decidindo a sequência temporal de ativação desses sinais.”

## 3. Mapa de leitura do diagrama

Use o Figma como um mapa, seguindo sempre a mesma ordem. Isso evita apontar para blocos isolados sem explicar seu papel no fluxo.


| Região do desenho         | O que mostrar                                                                                                                                                                                                                  | Ideia que deve ficar clara                                                                                |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------- |
| Entrada de instruções     | PC (Program Counter, contador de programa), mux IorD (Instruction or Data, seletor instrução ou dado), memória e IR (Instruction Register, registrador de instrução).                                                          | A mesma memória atende busca de instrução e acesso a dados; o mux define o endereço usado.                |
| Valores dos registradores | Banco de registradores, A/B (registradores intermediários de operandos) e seletores de leitura/escrita.                                                                                                                        | A e B preservam os operandos durante uma instrução multiciclo.                                            |
| Cálculo principal         | ALU, ALUSrcA (ALU Source A, fonte A da ALU), ALUSrcB (ALU Source B, fonte B da ALU), ALUOut (registrador de saída da ALU) e controle da ALU.                                                                                   | A ALU é reutilizada para PC+4, operações aritméticas, endereços, comparações e atualização do SP.         |
| Escrita de resultado      | MDR (Memory Data Register, registrador de dados da memória), RegDst (Register Destination, seletor do registrador destino), MemtoReg (Memory to Register, seletor da fonte de escrita no banco) e caminho de retorno ao banco. | O destino e a origem do dado escrito variam conforme a instrução.                                         |
| Desvios e saltos          | extensão de sinal, deslocadores, PCSource (fonte do próximo PC) e caminhos de destino.                                                                                                                                         | PC não recebe sempre PC+4; ele pode receber alvo de desvio, salto ou valor de registrador.                |
| Unidades especiais        | SHIFT, multiplicador, divisor, HI (High, registrador da parte alta), LO (Low, registrador da parte baixa), MergeBytes (combinador de bytes), EPC (Exception Program Counter, contador de programa de exceção) e vetores.       | Recursos específicos são incluídos porque alguma instrução precisa deles, sem duplicar o caminho comum.   |
| Pilha                     | constantes 29 e 227, Read1Sel (seletor da porta de leitura 1), Read2Sel (seletor da porta de leitura 2) e ramificações coloridas.                                                                                              | PUSH e POP usam R29 como SP (Stack Pointer, ponteiro da pilha) e reaproveitam o banco, a ALU e a memória. |




## 4. Roteiro sugerido — 12 a 15 minutos


| Tempo       | O que mostrar                      | Como explicar                                                                                                                                                                    |
| ----------- | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0:00–1:00   | Visão completa da arquitetura.     | “Este é o diagrama de blocos do processador. Ele reúne unidade de processamento, memória e interface de controle para as 23 instruções do projeto.”                              |
| 1:00–2:30   | Requisitos da primeira etapa.      | Dizer que cada bloco, ligação relevante e saída da UC precisa ter finalidade clara. Explicar que a equipe organizará a explicação por caminhos de dados, não por estados da FSM. |
| 2:30–4:30   | Busca de instrução.                | Percorrer PC → IorD → memória → IR; em paralelo, explicar que a ALU pode produzir PC+4 e que PCSource escolhe o próximo PC.                                                      |
| 4:30–6:30   | Operandos, ALU e escrita no banco. | Mostrar banco → A/B → muxes da ALU → ALUOut → MemtoReg/RegDst → banco. Explicar por que A, B, ALUOut e MDR são registradores intermediários.                                     |
| 6:30–9:00   | Famílias de instrução.             | Escolher uma instrução representativa de cada família e seguir o caminho correspondente: aritmética, memória, desvio/salto, SHIFT, HI/LO e bytes.                                |
| 9:00–10:30  | PUSH e POP.                        | Mostrar as conexões violetas de PUSH e âmbar de POP; destacar o que é exclusivo de cada instrução e o que é compartilhado.                                                       |
| 10:30–12:00 | Sinais da UC.                      | Agrupar os sinais por função: PC, memória, ALU, escrita no banco e unidades especiais. Para cada grupo, relacionar comando e efeito no datapath.                                 |
| 12:00–13:30 | Reuso e decisões de projeto.       | Mostrar que os mesmos componentes resolvem vários casos: ALU para endereço e cálculo, memória para instrução/dados, banco para registradores gerais e SP.                        |
| 13:30–15:00 | Fechamento e perguntas.            | Reafirmar que todos os caminhos das 23 instruções estão contemplados e que a próxima etapa definirá a sequência dos controles na FSM.                                            |


Cada integrante deve ser capaz de explicar a arquitetura inteira. A divisão de fala pode ajudar na fluidez, mas não deve limitar o conhecimento de cada pessoa a um bloco.

## 5. Fala de abertura pronta

> “Nossa primeira entrega é a arquitetura do processador, isto é, o diagrama que mostra quais unidades existem, como os dados circulam entre elas e como a UC as controla. Partimos do datapath multiciclo de referência e mantivemos a estrutura principal: PC, memória, registradores intermediários, banco de registradores, ALU e muxes. Depois acrescentamos os recursos exigidos pelo conjunto de 23 instruções, incluindo operações de bytes, deslocamentos, HI/LO, multiplicação, divisão, exceções e as instruções PUSH e POP. Durante a apresentação vamos mostrar o papel de cada bloco e percorrer os caminhos usados pelas famílias de instrução.”



## 6. Explicação dos blocos principais


| Bloco ou conjunto                                           | O que ele faz                                                         | Como apresentá-lo                                                                                                                                                                                                               |
| ----------------------------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **PC, PCSource e escrita do PC**                            | Guardam e escolhem o endereço da próxima instrução.                   | O PC recebe PC+4 no fluxo normal, alvo de desvio, alvo de salto ou valor de registrador em JR. PCWrite (habilitação de escrita do PC) e PCWriteCond (habilitação condicional de escrita do PC) controlam quando ele pode mudar. |
| **Memória e IorD**                                          | A memória fornece instruções e também armazena/lê dados.              | IorD escolhe se o endereço vem do PC, na busca, ou de ALUOut, nos acessos a dados. Esse reuso evita duplicar memória.                                                                                                           |
| **IR e IRWrite**                                            | IR retém a instrução buscada.                                         | Depois de carregada, seus campos alimentam o decodificador, os índices do banco, o imediato e o endereço de salto. IRWrite (habilitação de escrita do IR) impede sobrescrever a instrução fora da busca.                        |
| **Banco de registradores, A e B**                           | Lê operandos e recebe resultados. A e B retêm as leituras.            | O banco possui duas leituras e uma escrita. A e B são importantes no multiciclo porque o banco poderá ser usado novamente nos ciclos seguintes.                                                                                 |
| **Read1Sel, Read2Sel e constante 29**                       | Estendem a escolha das portas de leitura para a pilha.                | Para a maior parte das instruções, as portas leem rs e rt. Em PUSH/POP, os seletores também permitem obter R29, o SP arquitetural.                                                                                              |
| **ALU, ALUSrcA, ALUSrcB, ALUOp e controle da ALU**          | Executam cálculos e comparações.                                      | A mesma ALU calcula PC+4, endereço base+deslocamento, resultado aritmético, diferença para BEQ/BNE e SP−4/SP+4. Os muxes definem os operandos e a UC define a operação.                                                         |
| **ALUOut**                                                  | Retém um resultado da ALU para uso posterior.                         | Endereços de memória, resultados intermediários e alvos precisam sobreviver a ciclos seguintes; por isso não se liga a saída combinacional da ALU diretamente a tudo.                                                           |
| **Extensão de sinal e deslocadores**                        | Preparam imediatos e alvos.                                           | Imediatos assinados são estendidos antes de entrar na ALU. Para desvios, o deslocamento é multiplicado por quatro; para saltos, os campos são organizados no formato de endereço adequado.                                      |
| **MDR**                                                     | Retém o dado lido da memória.                                         | Em uma arquitetura multiciclo, a memória pode devolver o dado em outro ciclo. MDR guarda esse dado antes da escrita em registrador ou do tratamento de byte.                                                                    |
| **RegDst e MemtoReg**                                       | Escolhem destino e dado da escrita no banco.                          | RegDst escolhe entre rt, rd, R31 ou R29 conforme o caso. MemtoReg escolhe resultado da ALU, MDR, HI/LO, resultado de deslocamento, endereço de retorno ou outra fonte disponível no desenho.                                    |
| **SHIFT, multiplicador, divisor, HI e LO**                  | Atendem instruções que não cabem na operação aritmética comum.        | SHIFT atende SLL, SRA e a formação usada por LUI. MULT e DIV produzem resultados que são preservados em HI/LO; MFHI e MFLO fazem o caminho de retorno ao banco.                                                                 |
| **DataSource (fonte de dados para a memória) e MergeBytes** | Adaptam o dado que será escrito ou lido quando há operações de byte.  | Em SW/LW o caminho é uma palavra inteira. Em SB/LB, os blocos de seleção e combinação preservam ou extraem os bytes corretos.                                                                                                   |
| **EPC, vetores e controle de exceção**                      | Guardam o contexto e escolhem o destino quando uma exceção é tratada. | Apresentar como uma extensão necessária às instruções e eventos previstos: EPC preserva o endereço relevante e os vetores fornecem o endereço de atendimento.                                                                   |
| **UC**                                                      | Produz os comandos que configuram o datapath.                         | A UC não transporta dados: ela decide qual mux seleciona qual entrada, qual registrador captura valor, quando há escrita e qual operação a ALU executa.                                                                         |




## 7. Como explicar os sinais da unidade de controle

Não apresente uma lista de siglas sem contexto. Para cada sinal, diga sempre: **qual bloco recebe o sinal, que escolha ou habilitação ele produz e em que família de instruções ele é necessário**.


| Grupo               | Sinais que devem estar identificados no desenho                                                                                                                                                            | Efeito observado no caminho                                                                                    |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| Próximo PC          | **PCWrite (habilitação de escrita do PC), PCWriteCond (habilitação condicional do PC), PCSource (fonte do próximo PC)**                                                                                    | Habilitam a escrita do PC e escolhem sequência normal, desvio, salto ou JR.                                    |
| Memória e instrução | **IorD (instrução ou dado), MemRead (leitura da memória), MemWrite (escrita da memória), IRWrite (escrita do IR), DataSource (fonte de dado para a memória)**                                              | Escolhem endereço de instrução/dado, leem ou escrevem memória, capturam IR e definem o dado enviado à memória. |
| Operandos e ALU     | **ALUSrcA (fonte A da ALU), ALUSrcB (fonte B da ALU), ALUOp (operação da ALU), controle da ALU, AWrite/BWrite (escrita de A/B)**                                                                           | Escolhem entradas da ALU, definem a operação e capturam operandos para os ciclos seguintes.                    |
| Resultado e banco   | **RegWrite (habilitação de escrita no banco), RegDst (destino do registrador), MemtoReg (fonte para registrador)**                                                                                         | Habilitam a escrita no banco, escolhem o registrador destino e a fonte do resultado.                           |
| Unidades especiais  | Sinais de escrita de **ALUOut (saída preservada da ALU), MDR (dado preservado da memória), SHIFT (unidade de deslocamento), HI/LO (partes alta/baixa), EPC (PC de exceção)** e controles de bytes/exceção. | Preservam resultados intermediários e ativam somente o recurso necessário à instrução em curso.                |


Se a memória física do desenho tiver apenas uma entrada de escrita, explique **MemRead** e **MemWrite** como intenções lógicas da UC: o importante é mostrar claramente quando o datapath usa o dado de saída e quando habilita a gravação. Os rótulos devem corresponder à implementação que será feita depois.

## 8. Caminhos para as 23 instruções

A maneira mais didática de cobrir todas as instruções é agrupá-las por caminho. Não é necessário narrar estados de FSM; basta explicar a circulação lógica dos dados e as escolhas que a UC precisa fazer.


| Família e instruções                                                                                                                                                                                                     | Caminho que deve ser apontado                                                                                                         | Mensagem principal                                                                                            |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Busca comum — todas as instruções**                                                                                                                                                                                    | PC → IorD → memória → IR; ALU produz PC+4 → PCSource → PC.                                                                            | Toda instrução começa obtendo a palavra apontada pelo PC e preparando o endereço sequencial.                  |
| **R aritméticas/lógicas — ADD (soma), AND (E lógico), SUB (subtração), SLT (Set Less Than, menor que com sinal)**                                                                                                        | Banco → A/B → ALUSrcA/ALUSrcB → ALU → ALUOut → MemtoReg → RegDst → banco.                                                             | O resultado vem da ALU e normalmente é escrito em rd.                                                         |
| **I aritmética — ADDI (Add Immediate, soma com imediato)**                                                                                                                                                               | Banco/rs → A; imediato estendido → ALUSrcB → ALU → banco/rt.                                                                          | O segundo operando vem da instrução, por isso há extensão de sinal e seleção de imediato.                     |
| **Deslocamento e superior imediato — SLL (Shift Left Logical, deslocamento lógico à esquerda), SRA (Shift Right Arithmetic, deslocamento aritmético à direita), LUI (Load Upper Immediate, carregar imediato superior)** | Campos/valor do banco → muxes de SHIFT → SHIFT → caminho de escrita no banco.                                                         | O bloco de deslocamento evita forçar a ALU a executar uma função específica que já possui unidade dedicada.   |
| **Memória de palavra — LW (Load Word, carregar palavra), SW (Store Word, armazenar palavra)**                                                                                                                            | Base em A + imediato estendido → ALUOut → IorD → memória. LW segue por MDR → MemtoReg → rt; SW recebe o dado pelo caminho de escrita. | ALUOut vira endereço efetivo; a mesma memória é usada para leitura e escrita de dados.                        |
| **Memória de byte — LB (Load Byte, carregar byte), SB (Store Byte, armazenar byte)**                                                                                                                                     | Mesmo endereço efetivo de LW/SW, com DataSource/MergeBytes no caminho do dado.                                                        | O endereço é por byte; os blocos adicionais selecionam ou preservam os bytes corretos.                        |
| **Desvio condicional — BEQ (Branch if Equal, desviar se igual), BNE (Branch if Not Equal, desviar se diferente)**                                                                                                        | A/B → ALU para comparação; PC+4 e imediato deslocado formam alvo → PCSource → PC.                                                     | O resultado da comparação, combinado com PCWriteCond, decide se o PC recebe o alvo ou continua sequencial.    |
| **Saltos — J (Jump, salto), JAL (Jump and Link, salto e ligação), JR (Jump Register, salto por registrador)**                                                                                                            | J/JAL formam alvo a partir de IR e PC; JR leva rs/A para PCSource. JAL também envia PC+4 a R31.                                       | PCSource concentra as alternativas de próximo endereço, enquanto JAL aproveita o caminho de escrita no banco. |
| **Produto, divisão e resultados especiais — MULT, DIV, MFHI (Move From HI, mover de HI), MFLO (Move From LO, mover de LO)**                                                                                              | Operandos seguem para multiplicador/divisor → HI/LO; MFHI/MFLO selecionam HI/LO → MemtoReg → rd.                                      | HI e LO preservam os resultados especiais sem alterar a organização normal da ALU.                            |
| **Pilha — PUSH, POP**                                                                                                                                                                                                    | Usam R29, banco, ALU, ALUOut, IorD, memória e caminho de escrita do banco.                                                            | Não há um “SP separado”: a pilha usa o registrador geral R29 e reaproveita o datapath existente.              |


A tabela cobre o conjunto completo: 13 instruções do tipo R, 8 do tipo I e 2 do tipo J. Ao apresentar uma família, cite explicitamente as instruções que ela representa para deixar essa cobertura verificável.

### 8.1 Como transformar um caminho em uma explicação clara

Para não apenas apontar setas no Figma, use esta sequência em qualquer instrução:

1. **Diga o objetivo.** Exemplo: “LW precisa buscar uma palavra da memória e colocá-la em um registrador.”
2. **Localize os dados de entrada.** Exemplo: “A base vem de rs; o deslocamento vem da própria instrução.”
3. **Mostre a escolha feita pelos muxes.** Exemplo: “ALUSrcB escolhe o imediato, e não o conteúdo de B.”
4. **Explique o registrador intermediário.** Exemplo: “ALUOut guarda o endereço calculado até a memória poder usá-lo.”
5. **Mostre o resultado e o destino.** Exemplo: “MDR guarda a palavra lida; MemtoReg a seleciona; RegDst escolhe rt.”
6. **Feche com o motivo do reuso.** Exemplo: “Não há um somador de endereço exclusivo para LW: a ALU comum faz esse cálculo.”

Os passos abaixo são **passos lógicos de dados**, não estados da FSM. Eles servem para a equipe explicar por que cada ligação do diagrama existe.

### 8.2 Busca comum: como toda instrução entra no processador

Use um exemplo simples: suponha que **PC = 100** e que a instrução armazenada em M[100] seja a próxima a executar.

1. O **PC** fornece o valor 100.
2. O mux **IorD** seleciona o PC como endereço de memória, pois neste momento a memória está sendo usada para buscar uma instrução.
3. A memória devolve a palavra M[100], e **IRWrite** permite que ela seja registrada no **IR**.
4. Em paralelo, a ALU recebe o PC e a constante 4. Ela calcula 100 + 4 = 104.
5. **PCSource** seleciona esse resultado e **PCWrite** atualiza o PC para 104, que será o endereço sequencial.
6. O IR passa a fornecer opcode, rs, rt, rd, imediato e campo de salto para os caminhos que precisarão deles.

Fala curta: “Primeiro buscamos a instrução no endereço do PC. Ao mesmo tempo, preparamos PC+4. A partir do IR, a UC sabe quais muxes e registros serão usados pelo restante da instrução.”

### 8.3 Operação aritmética: ADD como exemplo de caminho R

Considere **ADD R10, R8, R9**, com R8 = 10 e R9 = 7.

1. O IR identifica rs = R8, rt = R9 e rd = R10.
2. O banco lê R8 e R9. Os valores 10 e 7 são preservados nos registradores **A** e **B**.
3. **ALUSrcA** seleciona A e **ALUSrcB** seleciona B; assim, a ALU recebe 10 e 7.
4. O controle da ALU seleciona soma. A saída é 17 e **ALUOut** guarda esse resultado.
5. **RegDst** escolhe rd, portanto o destino é R10.
6. **MemtoReg** escolhe ALUOut, pois o valor a escrever não veio da memória.
7. **RegWrite** permite gravar 17 em R10.

Para **AND, SUB e SLT**, o caminho é o mesmo. Muda somente a operação escolhida no controle da ALU. Para **ADDI**, A continua vindo de rs, mas ALUSrcB passa a selecionar o imediato estendido e RegDst seleciona rt.

### 8.4 Acesso à memória: LW e SW como exemplos

Considere **LW R9, 12(R8)**, com R8 = 200. O objetivo é ler M[212] e gravá-la em R9.

1. O banco lê R8; seu conteúdo, 200, fica em A.
2. O imediato 12 sai do IR e passa pela extensão de sinal.
3. ALUSrcA escolhe A e ALUSrcB escolhe o imediato. A ALU calcula 200 + 12 = 212.
4. **ALUOut** guarda 212, o endereço efetivo.
5. IorD deixa de escolher o PC e passa a escolher ALUOut. A memória recebe 212 como endereço de dado.
6. A palavra lida entra em **MDR**. MDR é necessário porque a leitura da memória pode precisar ser preservada até a escrita no banco.
7. RegDst escolhe rt, que neste exemplo é R9; MemtoReg escolhe MDR; RegWrite grava o conteúdo de M[212] em R9.

Em **SW R9, 12(R8)**, os quatro primeiros passos são idênticos: a ALU também produz o endereço 212 e ALUOut o preserva. A diferença aparece no dado e no fim do caminho:

1. O conteúdo original de R9 foi preservado em B.
2. IorD seleciona ALUOut como endereço da memória.
3. **DataSource** seleciona B como dado de escrita e **MemWrite** grava esse valor em M[212].
4. Não há RegWrite, pois SW não escreve no banco de registradores.

Para **LB** e **SB**, o endereço é obtido da mesma forma. Os blocos **MergeBytes** e de seleção de dados definem qual byte é extraído ou atualizado, respeitando que a memória é endereçada por byte.

### 8.5 Decisões de fluxo: BEQ, BNE, J, JAL e JR

Em **BEQ R8, R9, destino**, dois cálculos coexistem:

1. A e B recebem os conteúdos de R8 e R9.
2. A ALU compara os valores, normalmente por subtração. Se forem iguais, o sinal de igualdade fica ativo.
3. O imediato do IR é estendido, deslocado duas posições à esquerda e somado a PC+4 para formar o endereço de destino.
4. PCWriteCond só permite a atualização do PC quando a condição é verdadeira; PCSource seleciona o endereço de destino nesse caso.
5. Caso R8 e R9 sejam diferentes, o PC continua com o valor sequencial PC+4.

**BNE** reutiliza o mesmo comparador e o mesmo alvo; a UC apenas inverte a condição que habilita o desvio. Em **J**, PCSource recebe o endereço montado com o campo de salto do IR. Em **JAL**, além de mudar o PC, o processador usa o caminho de escrita no banco para salvar PC+4 em R31. Em **JR**, o valor lido de rs e preservado em A é selecionado por PCSource como próximo PC.

### 8.6 Unidades especiais: o que explicar sem perder o fio

- **SLL, SRA e LUI:** o dado entra no bloco SHIFT, que produz o valor deslocado ou organiza o imediato na parte superior da palavra. Depois, o resultado usa o caminho normal de escrita no banco.
- **MULT e DIV:** A e B alimentam a unidade correspondente. Os resultados são retidos em HI e LO, pois não seguem diretamente para um registrador geral. MFHI e MFLO selecionam HI ou LO e os enviam a rd pelo caminho de escrita.
- **Exceções:** EPC conserva o endereço relevante e o mux de PC recebe o vetor de tratamento. O papel desses blocos é impedir que o endereço que precisa ser retomado se perca quando o fluxo normal é interrompido.



## 9. Explicação de PUSH e POP no Figma

**SP** significa *Stack Pointer*, ou **ponteiro da pilha**. Ele é o registrador que guarda o endereço do topo atual da pilha. Neste projeto, o SP é **R29** e começa no valor indicado pela especificação, 227. Como a pilha cresce de endereços maiores para menores, PUSH diminui R29 em quatro e POP o aumenta em quatro.


| Instrução                 | Semântica arquitetural                                                                                                                                  | Como ler as cores no diagrama                                                                                                                                                        |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **PUSH rs**               | Primeiro calcula **R29 − 4**, atualiza R29 e grava o valor original de rs no endereço resultante. No exemplo, 227 passa a 223 e rs é armazenado em 223. | Os ramos exclusivos de PUSH estão em **violeta**. Eles evidenciam a seleção de rs para o dado a armazenar e o caminho que viabiliza a atualização do SP antes da escrita na memória. |
| **POP rd**                | Lê a palavra no endereço atual de R29, envia o valor para rd e depois calcula **R29 + 4**. No exemplo, o valor em 223 vai para rd e o SP volta a 227.   | Os ramos associados a POP estão em **âmbar**. Eles evidenciam a leitura da memória, a passagem por MDR e o retorno ao registrador rd.                                                |
| **Partes compartilhadas** | Banco, A/B, ALU, ALUOut, IorD, memória e a seleção de R29 são usados pelas duas instruções.                                                             | Esses trechos permanecem na cor neutra porque representam hardware reaproveitado, não um caminho exclusivo.                                                                          |




### 9.1 PUSH, passo a passo (insere no topo da pilha)

Considere R29 = 227 e **PUSH R8**, com R8 = 0xAABBCCDD.

1. **Read1Sel** seleciona R29 para a primeira leitura do banco. O valor 227 é preservado em A.
2. **Read2Sel** seleciona rs, que neste exemplo é R8. O valor 0xAABBCCDD é preservado em B.
3. A ALU recebe A e a constante 4, configurada para subtração. Ela calcula 227 − 4 = 223.
4. **ALUOut** guarda 223. Esse será o novo valor de R29 e o endereço onde o dado será armazenado.
5. RegDst seleciona R29, MemtoReg seleciona ALUOut e RegWrite atualiza o SP para 223.
6. IorD seleciona ALUOut como endereço da memória. Portanto, a memória recebe 223.
7. DataSource seleciona B, que ainda contém o valor original de R8, e MemWrite grava 0xAABBCCDD em M[223].

O detalhe importante é que B preserva R8 antes de R29 ser atualizado. Isso mantém correto até o caso limite **PUSH R29**: o valor armazenado é o SP antigo, não o valor já decrementado.

### 9.2 POP, passo a passo (remove do topo e entrega ao destino)

Considere R29 = 223, M[223] = 0xAABBCCDD e **POP R9**.

1. Read1Sel seleciona R29. O banco entrega 223 e A preserva esse valor.
2. O controle da ALU seleciona a operação **passar A**. Assim, a saída da ALU continua sendo 223, e **ALUOut** recebe 223.
3. Isso não altera o SP. A expressão “copiar SP para ALUOut” significa, de modo mais preciso, **executar ALUOut ← A**, sendo A o valor do SP que foi preservado.
4. IorD seleciona ALUOut como endereço da memória. Como ALUOut vale 223, a memória lê M[223].
5. O valor lido, 0xAABBCCDD, é preservado em MDR.
6. RegDst seleciona rd, que neste exemplo é R9; MemtoReg seleciona MDR; RegWrite grava 0xAABBCCDD em R9.
7. Depois da leitura, a ALU recebe A e a constante 4. Ela calcula 223 + 4 = 227 e grava esse resultado em R29.

ALUOut existe nesse passo porque o caminho de endereço de dados da memória já recebe ALUOut por meio de IorD. Assim, o projeto reutiliza a ALU e o caminho existente, sem criar uma ligação direta nova entre R29 e a memória. O incremento só pode ocorrer **depois** da leitura; se R29 virasse 227 antes, POP tentaria ler M[227] e deixaria de recuperar o elemento que está no topo em M[223].

Fala recomendada:

> “A cor não altera o circuito; ela é uma legenda visual. Violeta destaca as conexões usadas especificamente por PUSH, âmbar destaca as de POP e as linhas neutras mostram recursos que as duas instruções compartilham. A decisão temporal de quando cada escrita ocorre será detalhada pela FSM na segunda etapa.”

Não diga que PUSH e POP escrevem dois registradores no mesmo instante. Há uma única porta de escrita no banco, portanto as atualizações de rd e R29 precisam acontecer em momentos distintos quando a UC for implementada.

## 10. Perguntas que a equipe deve conseguir responder


| Pergunta provável                                                | Resposta curta e correta                                                                                                                                                                   |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Por que há A, B, ALUOut e MDR se os blocos de origem já existem? | Porque a arquitetura é multiciclo. Esses registradores preservam operandos, resultados e dados de memória entre etapas lógicas da instrução.                                               |
| Por que a ALU é usada para PC+4, endereços e comparações?        | Reuso de hardware reduz circuitos duplicados. Os muxes e a UC mudam as entradas e a operação conforme a instrução.                                                                         |
| Para que serve IorD?                                             | Para reutilizar a memória: PC fornece o endereço na busca de instrução e ALUOut fornece o endereço em LW, SW, LB, SB, PUSH e POP.                                                          |
| Qual é a diferença entre RegDst e MemtoReg?                      | RegDst escolhe **onde** escrever no banco; MemtoReg escolhe **qual dado** será escrito.                                                                                                    |
| Por que MDR é necessário?                                        | A leitura de memória não deve depender de a saída combinacional permanecer estável até a escrita no banco. MDR captura o dado lido.                                                        |
| Por que HI e LO existem?                                         | MULT e DIV podem produzir resultados que não cabem no caminho comum. HI/LO os preservam até MFHI ou MFLO solicitá-los.                                                                     |
| Como BEQ e BNE usam o mesmo hardware?                            | A ALU compara os operandos; a UC interpreta o resultado da comparação de modo diferente para decidir se o PC recebe o alvo.                                                                |
| Por que o SP é R29?                                              | Essa é a definição arquitetural do projeto. Reutilizar o banco evita criar um estado duplicado para a pilha.                                                                               |
| Como saber se uma ligação é necessária?                          | Ela deve participar de pelo menos uma instrução ou preservar/selecionar um valor necessário entre fases. Se não há função, deve ser questionada; se há função, ela precisa ser explicável. |
| Isto já é a máquina de estados?                                  | Não. O diagrama mostra recursos e caminhos. A FSM posterior definirá a ordem dos sinais e os estados de cada instrução.                                                                    |




## 11. Checklist antes da apresentação

- [ ] O Figma ou a cartolina mostra PC, memória, IR, MDR, banco, A, B, ALU, ALUOut, muxes e UC.
- [ ] Toda saída relevante da UC possui nome e pode ser explicada por seu efeito no datapath.
- [ ] As ligações de busca, acesso à memória, escrita no banco, desvio e salto estão visíveis.
- [ ] Cada unidade especial tem uma instrução associada: SHIFT, MULT/DIV, HI/LO, bytes, exceções e pilha.
- [ ] As 23 instruções foram citadas por família e há um caminho explicável para cada uma.
- [ ] Para cada caminho apresentado, a equipe consegue dizer entrada, mux escolhido, registrador intermediário, saída e motivo do reuso.
- [ ] As linhas violetas de PUSH e âmbar de POP possuem legenda verbal clara.
- [ ] A equipe separa corretamente a primeira etapa da etapa futura de FSM.
- [ ] Cada integrante consegue seguir um caminho completo sem depender de outro integrante.
- [ ] O desenho evita sinais sem nome ou blocos sem finalidade aparente.
- [ ] Clock e reset não precisam poluir o desenho desta etapa, pois a especificação os trata como sinais intuitivamente implícitos.



## 12. Referências usadas neste roteiro

- [Especificação do Projeto 2026.2](../Especificacao%20Projeto%202026-2.pdf), primeira etapa, especialmente as páginas 4 a 6: requisitos de módulos, ligações, sinais da UC e sentido do circuito.
- A mesma especificação, páginas 7 em diante: conjunto de 23 instruções e necessidades arquiteturais de cada família.
- [Arquitetura no Figma](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=0-1): referência visual dos blocos e conexões atuais.
- [Arquitetura e sinais](03-arquitetura-e-sinais.md) e [catálogo das instruções](02-catalogo-23-instrucoes.md): consulta complementar durante o ensaio.

