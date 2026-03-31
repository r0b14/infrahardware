# 🏗️ Arquitetura e Padrões do Projeto - Infraestrutura de Hardware

Este documento estabelece as diretrizes arquiteturais, os padrões de codificação, e a organização de diretórios para todos os projetos, scripts e códigos práticos desenvolvidos na disciplina de Infraestrutura de Hardware. Todo novo código gerado deve estar aderente a este material.

## 📂 Organização do Repositório

Nós estaremos centralizando todos os arquivos práticos dentro do diretório `/codigos`. A estrutura lógica e organizacional para facilitar os nossos estudos e projetos será:

```text
📦 infrahardware
 ┣ 📂 codigos
 ┃ ┣ 📂 assembly
 ┃ ┃ ┣ 📂 exercicios         # Resoluções isoladas de listas ou práticas rápidas em MIPS
 ┃ ┃ ┣ 📂 provas             # Resoluções baseadas em questões de provas anteriores
 ┃ ┃ ┗ 📂 projetos           # Subrotinas complexas e algoritmos completos implementados
 ┃ ┣ 📂 verilog
 ┃ ┃ ┣ 📂 modulos_basicos    # Portas lógicas, ALUs, multiplexadores, extensores de sinal
 ┃ ┃ ┣ 📂 mem_registradores  # Banco de registradores, memórias de instrução e dados
 ┃ ┃ ┗ 📂 testbenches        # Arquivos de simulação e testes de todos os módulos
 ┃ ┗ 📂 projetos_cpu
 ┃   ┣ 📂 cpu_monociclo      # Implementação MIPS em arquitetura de ciclo único
 ┃   ┣ 📂 cpu_multiciclo     # Implementação MIPS em arquitetura multí-ciclos
 ┃   ┗ 📂 cpu_pipeline       # Implementação MIPS com paralelismo / pipeline
```

## 💻 Tecnologias, Extensões e Ferramentas

### 1. Assembly MIPS

- **Extensões Padrão:** Utilizar `.s` ou `.asm` nos arquivos produzidos.
- **Ambientes de Referência:** MIPS Assembler and Runtime Simulator (MARS) ou QtSpim. Os códigos Assembly escritos aqui devem ser idealizados pensando nesses ambientes de simulação e execução.
- **Padrão de Estilo e Escrita:**
  - **Identação**: Sempre utilize TAB (ou 4 espaços) para alinhar os comandos, os operandos e os comentários de linha. O código precisa estar altamente legível.
  - **Uso de Registradores**: Respeite estritamente as convenções do MIPS:
    - Retornos: `$v0`, `$v1`
    - Argumentos: `$a0` a `$a3`
    - Temporários (não preservados): `$t0` a `$t9`
    - Salvos (preservados entre subrotinas): `$s0` a `$s7`
  - **Comentários**: Obrigatório adicionar comentários ao lado de operações matemáticas ou lógicas complexas. Traduza a operação de baixo nível para a lógica humana de "pseudo-código".

### 2. Verilog / Hardware Description Language (HDL)

- **Extensões Padrão:** Utilizar `.v` para módulos de implementação. Para testbenches, usar o nome com sufixo explícito `_tb.v`.
- **Ambientes de Referência:** Utilização visada para simulação usando Icarus Verilog (`iverilog`) e análise de formas de onda via GTKWave (`.vcd`), bem como uso em protótipos em ferramentas como Intel Quartus ou ModelSim.
- **Padrão de Estilo e Escrita:**
  - **Nomenclatura**: Nomes de módulos, wires e regs devem usar `snake_case` descritivos (ex: `unidade_controle_principal`). Constantes e parâmetros (ex: OPCODEs) devem usar `UPPER_SNAKE_CASE`.
  - **Desacoplamento Lógico**: Ao escrever sequencial vs combinacional, procure sempre isolar registradores do sistema (estado lógico) da combinacional do Datapath num estilo limpo.
  - **Prefixos Úteis**: Se possível e necessário, sinalize os sentidos de IO nos Módulos maiores usando `i_` para _inputs_ e `o_` para _outputs_.

## 🛠️ Regras de Criação de Arquivos e Módulos

### Organização dos Testes Verilog (Testbenches)

1. Nós não vamos criar módulos em Verilog baseando-se apenas em intuição tática sem a respectiva prova. Cada bloco da CPU que concebermos (ALU, Mux, ULA Control) deverá vir com o seu próprio arquivo `_tb.v`.
2. O "testbench" deverá cobrir pelo menos os cenários de borda ou variações triviais da unidade para garantir que a lógica criada vai ser útil no momento da integração do processador (monociclo/pipeline).

### Etapas de Construção das CPUs MIPS

1. **Design Bottom-Up**: As CPUs deverão ser implementadas da periferia e dos operacionais para os eixos controladores. Projeta-se primeiro ALU, Memórias, Extensor, Fluxo de dados (Datapath), para por último engatar a "Unidade de Controle" de cada arquitetura.
2. **Abordagem Didática e Isolada do Controle**: Todo sinal de "jump/branch/memRead/memWrite/aluOp" vindo da Unidade de Controle deve ser bem mapeado, explicado no cabeçalho do arquivo Verilog qual tabela verdade está sendo descrita nas saídas do controle em relação à instrução (OPCODE).
3. **Riscos e Pipeline**: No caso de projetos ligados à Unidade 7 (Pipeline), estruturas como Unidade de Detecção de Hazards e Unidade de Adiantamento (Forwarding) deverão ser bem comentadas no código para que os conflitos estruturais, operacionais e de dados fiquem expostos visualmente ao ler os fios.

## 📝 Documentação Adicional de Resoluções

Por se tratar de um repositório também de estudos direcionado à aprovação na disciplina:

- Sempre que houver solução de alguma prova ou exercícios em Assembly complexo, faça uma correlação direta com C/C++ (um pseudo-código do que está sendo implementado), escrevendo-o num comentário de bloco no topo do arquivo. Assim se estuda em alto nível interpretando baixo nível.
- Justifique nos repositórios eventuais "Por que alocamos 16 bytes na Pilha de controle do MIPS na subrotina X usando a instrução _addi $sp, $sp, -16_?", aprofundando o conhecimento prático em chamadas aninhadas.
