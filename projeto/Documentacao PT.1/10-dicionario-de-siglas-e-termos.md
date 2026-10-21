# 10 — Dicionário de siglas, sinais e termos

[Índice](README.md) · [Catálogo das 23 instruções](02-catalogo-23-instrucoes.md) · [Arquitetura e sinais](03-arquitetura-e-sinais.md) · [Roteiro de apresentação](05-roteiro-de-apresentacao.md)

> **Convenção da documentação:** na primeira ocorrência de uma sigla, o texto apresenta o formato **SIGLA (nome por extenso)**. Depois disso, usa apenas a forma curta para manter a leitura fluida. Este documento reúne todas as definições para consulta durante o estudo ou a apresentação.

## 1. Blocos e conceitos da arquitetura

| Sigla ou termo | Nome por extenso | Papel no processador |
|---|---|---|
| **UC** | Unidade de Controle | Decide os sinais que configuram muxes, registradores, memória e ALU em cada etapa lógica. |
| **PC** | *Program Counter* — contador de programa | Guarda o endereço da próxima instrução. |
| **ALU** | *Arithmetic Logic Unit* — unidade lógica e aritmética | Faz somas, subtrações, comparações, cálculos de endereço e atualização do PC/SP. |
| **IR** | *Instruction Register* — registrador de instrução | Preserva a instrução buscada na memória. |
| **MDR** | *Memory Data Register* — registrador de dados da memória | Preserva uma palavra lida da memória antes de ela seguir para outro bloco. |
| **SP** | *Stack Pointer* — ponteiro da pilha | Guarda o endereço do topo da pilha. No projeto, é o registrador R29. |
| **EPC** | *Exception Program Counter* — contador de programa de exceção | Guarda o endereço necessário para tratar ou retomar uma exceção. |
| **HI** | *High* — registrador da parte alta | Retém a parte alta de um produto ou o resto de uma divisão. |
| **LO** | *Low* — registrador da parte baixa | Retém a parte baixa de um produto ou o quociente de uma divisão. |
| **FSM** | *Finite State Machine* — máquina de estados finitos | Definirá, na segunda etapa, a ordem temporal dos sinais de controle. |
| **HDL** | *Hardware Description Language* — linguagem de descrição de hardware | Categoria de linguagens usadas para descrever circuitos, como Verilog e VHDL. |
| **Verilog / VHDL** | Linguagens de descrição de hardware | Linguagens candidatas para implementar e testar o circuito depois da etapa de arquitetura. |

## 2. Registradores intermediários, notação e campos da instrução

| Sigla ou termo | Nome ou significado | Uso |
|---|---|---|
| **A** | Registrador intermediário A | Normalmente preserva o valor lido de rs. Também preserva o SP em PUSH e POP. |
| **B** | Registrador intermediário B | Normalmente preserva o valor lido de rt. Em PUSH, preserva o valor original de rs. |
| **ALUOut** | Registrador de saída da ALU | Mantém um resultado da ALU, como endereço efetivo, resultado aritmético ou valor de SP, entre etapas. |
| **EA** | *Effective Address* — endereço efetivo | Endereço de memória calculado, geralmente R[rs] + imediato estendido. |
| **M32[a]** | Palavra de 32 bits iniciando em a | Notação para uma leitura ou escrita de palavra na memória. |
| **M8[a]** | Byte armazenado no endereço a | Notação para acesso individual de byte. |
| **SE16 / SE8** | Extensão com sinal de 16/8 bits | Expande um imediato ou byte para 32 bits preservando o sinal. |
| **P** | PC antes da busca | Ajuda a escrever fórmulas de PC; depois da busca, o caminho sequencial produz P+4. |
| **rs** | *Register source* | Campo que indica o primeiro registrador-fonte. |
| **rt** | *Register target* | Campo que pode indicar segundo operando, destino de instrução I ou fonte de store. |
| **rd** | *Register destination* | Campo que indica o destino das instruções R, incluindo POP. |
| **shamt** | *Shift amount* — quantidade de deslocamento | Campo de 5 bits usado por SLL e SRA. |
| **imm** | Imediato | Campo de 16 bits presente nas instruções I. |
| **target** | Alvo de salto | Campo de 26 bits presente nas instruções J. |
| **opcode** | Código de operação | Campo que identifica a família principal da instrução. |
| **funct** | Código de função | Campo que diferencia instruções R quando opcode é zero. |

## 3. Sinais e seletores de controle

| Sinal | Nome por extenso | Efeito no diagrama |
|---|---|---|
| **IorD** | *Instruction or Data* — instrução ou dado | Seleciona PC para busca de instrução ou ALUOut para acesso a dados na memória. |
| **PCSource** | Fonte do PC | Seleciona de onde vem o próximo endereço: PC+4, alvo de desvio, salto ou registrador em JR. |
| **PCWrite** | Habilitação de escrita do PC | Permite atualizar o PC sem depender de condição. |
| **PCWriteCond** | Habilitação condicional de escrita do PC | Atualiza PC apenas quando a condição de BEQ/BNE é satisfeita. |
| **IRWrite** | Habilitação de escrita do IR | Permite carregar uma nova instrução no registrador de instrução. |
| **MemRead** | Leitura de memória | Indica que o datapath deve usar o dado vindo da memória. |
| **MemWrite / wr** | Escrita de memória | Habilita a gravação de um dado na memória. |
| **ALUSrcA** | *ALU Source A* — fonte A da ALU | Escolhe, por exemplo, PC ou A como primeiro operando da ALU. |
| **ALUSrcB** | *ALU Source B* — fonte B da ALU | Escolhe B, a constante 4, um imediato estendido ou um deslocamento como segundo operando. |
| **ALUOp** | *ALU Operation* — operação da ALU | Código geral que orienta a função a ser executada pela ALU. |
| **F** | Função da ALU | Código específico da ALU fornecida; por exemplo, pode selecionar “passar A”, soma ou subtração. |
| **RegWrite** | Habilitação de escrita no banco | Permite gravar um resultado em um registrador geral. |
| **RegDst** | *Register Destination* — destino do registrador | Escolhe qual índice recebe a escrita: rt, rd, R31 ou R29. |
| **MemtoReg** | *Memory to Register* — fonte para registrador | Escolhe o dado que será escrito no banco: ALUOut, MDR, HI, LO, SHIFT ou outra fonte disponível. |
| **DataSource** | Fonte de dados para a memória | Escolhe o dado a gravar na memória, como B ou a palavra produzida por MergeBytes. |
| **Read1Sel** | Seleção da porta de leitura 1 | Escolhe rs ou R29 para a primeira leitura do banco. |
| **Read2Sel** | Seleção da porta de leitura 2 | Escolhe rt ou rs para a segunda leitura do banco. |
| **AWrite / BWrite** | Habilitação de escrita de A/B | Permitem capturar ou conservar os operandos intermediários. |
| **ALUOutWrite** | Habilitação de escrita de ALUOut | Permite preservar a saída da ALU. |
| **MDRWrite** | Habilitação de escrita de MDR | Permite capturar o dado de memória quando ele está válido. |

## 4. Blocos auxiliares e rótulos do circuito

| Rótulo | Nome ou explicação | Uso |
|---|---|---|
| **SHIFT** | Unidade de deslocamento | Executa SLL e SRA; também pode formar o resultado de LUI. |
| **MergeBytes** | Combinação de bytes | Troca somente o byte necessário em SB sem apagar os outros bytes da palavra. |
| **PC+4** | Próximo endereço sequencial | Resultado de somar 4 ao PC durante a busca. |
| **IorD = PC** | Busca de instrução | A memória recebe o PC como endereço. |
| **IorD = ALUOut** | Acesso a dados | A memória recebe o endereço calculado pela ALU. |
| **ALUOut ← A** | Passar A pela ALU | Em POP, preserva o endereço do SP em ALUOut sem modificar o SP. |

## 5. Mnemônicos das 23 instruções

| Mnemônico | Nome ou ação | Grupo de explicação |
|---|---|---|
| **ADD** | Soma com sinal | Resultado de ALU no banco |
| **AND** | E lógico bit a bit | Resultado de ALU no banco |
| **SUB** | Subtração com sinal | Resultado de ALU no banco |
| **SLT** | *Set Less Than* — definir 1 se menor que | Resultado de ALU no banco |
| **ADDI** | *Add Immediate* — soma com imediato | Resultado de ALU no banco |
| **SLL** | *Shift Left Logical* — deslocamento lógico à esquerda | Deslocamento e constante |
| **SRA** | *Shift Right Arithmetic* — deslocamento aritmético à direita | Deslocamento e constante |
| **LUI** | *Load Upper Immediate* — carregar imediato superior | Deslocamento e constante |
| **LW** | *Load Word* — carregar palavra | Carga da memória |
| **LB** | *Load Byte* — carregar byte | Carga da memória |
| **SW** | *Store Word* — armazenar palavra | Armazenamento na memória |
| **SB** | *Store Byte* — armazenar byte | Armazenamento na memória |
| **BEQ** | *Branch if Equal* — desviar se igual | Desvio condicional |
| **BNE** | *Branch if Not Equal* — desviar se diferente | Desvio condicional |
| **J** | *Jump* — salto | Alteração incondicional do PC |
| **JAL** | *Jump and Link* — salto e ligação | Alteração incondicional do PC |
| **JR** | *Jump Register* — salto para registrador | Alteração incondicional do PC |
| **MULT** | Multiplicação | Família HI/LO |
| **DIV** | Divisão | Família HI/LO |
| **MFHI** | *Move From HI* — mover de HI | Família HI/LO |
| **MFLO** | *Move From LO* — mover de LO | Família HI/LO |
| **PUSH** | Empilhar | Pilha |
| **POP** | Desempilhar | Pilha |

## 6. Como usar o dicionário na apresentação

Quando uma sigla aparecer em uma pergunta, responda primeiro com o nome e depois com o papel. Por exemplo:

> “MDR significa *Memory Data Register*, ou registrador de dados da memória. Ele guarda a palavra lida até que o banco de registradores possa recebê-la.”

Essa estrutura evita respostas decoradas: nomear a sigla mostra o que ela representa; explicar o papel mostra por que ela existe na arquitetura.

## 7. Documentos relacionados

- [Catálogo das 23 instruções](02-catalogo-23-instrucoes.md): caminhos detalhados por instrução e por grupo.
- [Arquitetura e sinais](03-arquitetura-e-sinais.md): seletores e valores concretos da extensão PUSH/POP.
- [Roteiro de apresentação](05-roteiro-de-apresentacao.md): ordem de fala e perguntas prováveis.
