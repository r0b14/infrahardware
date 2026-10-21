<div align="center">

# Infraestrutura de Hardware — IF674

Material de estudo, exercícios e projetos da disciplina de Infraestrutura de Hardware do Centro de Informática da UFPE.

[![UFPE](https://img.shields.io/badge/UFPE-CIn-8B0000?style=flat-square)](https://portal.cin.ufpe.br/)
[![MIPS](https://img.shields.io/badge/Assembly-MIPS-2F80ED?style=flat-square)](#assembly-mips)
[![HDL](https://img.shields.io/badge/HDL-VHDL%20%7C%20Verilog-6C63FF?style=flat-square)](#conteúdos)
[![License: MIT](https://img.shields.io/badge/licença-MIT-22A699?style=flat-square)](LICENSE)

</div>

> [!NOTE]
> Este é um repositório acadêmico e independente. Os materiais devem ser usados como apoio aos estudos e conferidos com a bibliografia e as orientações da disciplina.

## Sumário

- [Sobre](#sobre)
- [Conteúdos](#conteúdos)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Como usar](#como-usar)
- [Assembly MIPS](#assembly-mips)
- [Ementa](#ementa)
- [Materiais de referência](#materiais-de-referência)
- [Licença](#licença)

## Sobre

O repositório reúne anotações, códigos e documentação produzidos durante o estudo de arquitetura e organização de computadores. O foco está na relação entre software e hardware: da programação em Assembly MIPS ao projeto e à validação de uma CPU.

### Objetivos

- consolidar conceitos de arquitetura de computadores;
- praticar programação de baixo nível com MIPS;
- documentar exercícios, projetos e decisões de implementação;
- relacionar os conteúdos teóricos com circuitos e descrições em HDL;
- manter um acervo fácil de consultar durante a disciplina.

## Conteúdos

| Tema | O que você encontrará |
| --- | --- |
| Assembly MIPS | Instruções, registradores, memória, desvios, subrotinas e exemplos |
| Organização de computadores | ISA, ciclo de instrução, datapath e unidade de controle |
| Projeto de CPU | Arquitetura, sinais de controle, máquina de estados e validação |
| HDL | Componentes de hardware em VHDL e materiais relacionados a Verilog |
| Desempenho | Implementações monociclo, multiciclo e pipeline |

## Estrutura do repositório

```text
infrahardware/
├── book/                 # Bibliografia de apoio
├── codigos/              # Códigos e exemplos práticos
├── listas/               # Resoluções e arquivos das listas de exercícios
├── mips-assembly-main/   # Coleção de algoritmos em MIPS e versões em Python
├── projeto/              # Projeto de CPU, relatórios, diagramas e componentes HDL
├── slides/               # Materiais de aula e exemplos associados
├── documentacao_c_para_mips.md
└── README.md
```

### Acesso rápido

| Área | Descrição | Atalho |
| --- | --- | --- |
| Códigos | Exemplos de instruções em Assembly | [`codigos/`](codigos/) |
| Listas | Exercícios e resoluções | [`listas/`](listas/) |
| Exemplos MIPS | Arrays, strings, laços e recursão | [`mips-assembly-main/`](mips-assembly-main/) |
| Projeto | Documentação completa da CPU | [`projeto/`](projeto/) |
| Documentação — parte 1 | Arquitetura, instruções e máquina de estados | [`projeto/Documentacao PT.1/`](projeto/Documentacao%20PT.1/) |
| Documentação — parte 2 | Roteiro e explicação do mapa de estados | [`projeto/Documentacao PT.2/`](projeto/Documentacao%20PT.2/) |
| Componentes — parte 3 | Memória, registradores, ULA e programas de teste | [`projeto/Documentação PT.3/`](projeto/Documenta%C3%A7%C3%A3o%20PT.3/) |
| Relatório | Fonte LaTeX e figuras do relatório técnico | [`projeto/Relatório/`](projeto/Relat%C3%B3rio/) |
| Slides | Conteúdo e exemplos das aulas | [`slides/`](slides/) |
| C para MIPS | Material sobre tradução de C para Assembly | [`documentacao_c_para_mips.md`](documentacao_c_para_mips.md) |

## Como usar

Clone o repositório e acesse a pasta do projeto:

```bash
git clone https://github.com/r0b14/infrahardware.git
cd infrahardware
```

Para executar os arquivos `.asm`, abra-os em um simulador compatível com MIPS, como [MARS](https://dpetersanderson.github.io/) ou [QtSpim](https://sourceforge.net/projects/spimsimulator/). Os arquivos HDL podem exigir ferramentas específicas, como Intel Quartus ou ModelSim, de acordo com o componente estudado.

> [!TIP]
> Se você está começando, consulte primeiro os exemplos em [`mips-assembly-main/`](mips-assembly-main/) e depois avance para a documentação em [`projeto/Documentacao PT.1/`](projeto/Documentacao%20PT.1/).

## Assembly MIPS

### Extensões utilizadas

- `.asm`: comum em simuladores e materiais didáticos, como MARS e QtSpim;
- `.s`: formato tradicional em montadores e toolchains de sistemas Unix.

### Exemplo básico

```asm
.text
.globl main

main:
    li   $t0, 10          # primeiro operando
    li   $t1, 20          # segundo operando
    add  $t2, $t0, $t1    # $t2 = 30

    li   $v0, 10          # encerra o programa
    syscall
```

### Formatos de instrução

| Formato | Estrutura | Uso comum | Exemplos |
| --- | --- | --- | --- |
| R | `opcode · rs · rt · rd · shamt · funct` | Operações entre registradores | `add`, `sub`, `and` |
| I | `opcode · rs · rt · immediate` | Imediatos, memória e desvios | `addi`, `lw`, `sw`, `beq` |
| J | `opcode · address` | Saltos incondicionais | `j`, `jal` |

Todas as instruções MIPS clássicas têm 32 bits. Os campos do formato R ocupam `6 + 5 + 5 + 5 + 5 + 6` bits; os do formato I, `6 + 5 + 5 + 16`; e os do formato J, `6 + 26`.

## Ementa

1. **Funcionamento básico de um computador:** níveis de abstração, compilação, interpretação, ISA e componentes de um computador.
2. **Operações e linguagem de montagem:** aritmética, registradores, Assembly MIPS, operações lógicas, desvios e representação de instruções.
3. **Repertório avançado do MIPS:** subrotinas, tipos de dados e modos de endereçamento.
4. **Ciclo de processamento:** execução de instruções e processadores MIPS monociclo e multiciclo.
5. **Diagrama de blocos:** organização dos componentes do processador.
6. **Desempenho e prática:** fatores de desempenho, Verilog e ambiente de projeto.
7. **Pipeline:** paralelismo, conflitos estruturais, de controle e de dados, soluções e tratamento de exceções.

## Materiais de referência

### Internos

- [Livro *Computer Organization and Design*](book/)
- [Referências e especificações do projeto](projeto/)
- [Índice da documentação da primeira entrega](projeto/Documentacao%20PT.1/README.md)
- [Relatório técnico em LaTeX](projeto/Relat%C3%B3rio/Relat%C3%B3rio%20LaTeX/LEIA-ME.md)

### Externos

- [Material de aula da disciplina](https://sites.google.com/a/cin.ufpe.br/if674cc/material-de-aula?authuser=0)
- [Patterson & Hennessy — material compartilhado](https://drive.google.com/file/d/1Ih132XcT3e076MO0fj3txaEkNOlFWCAW/view)
- [Provas antigas](https://drive.google.com/drive/folders/1dZeca30XHp0qKC2CTOskhHRghDw-z_kI)
- [Questão recorrente da primeira prova](https://drive.google.com/file/d/16-7lfjoTGw4i559qx81ESS-sLzir71uV/view)
- [Questões respondidas](https://drive.google.com/drive/u/0/folders/1KbuN1yF-YD1pwNBrS8FwI2tRSljPrTl3)
- [Relatórios, projetos e provas extras](https://drive.google.com/drive/folders/1k_fskKo_1S6oaks1RWaLlgcihVm1ohRj)
- [Relatórios e projetos no Dropbox](https://www.dropbox.com/scl/fo/rv17i32p23g8cpldydmz0/ACyJgNRTaTkCfRDAomGRnS0/3%C2%BA%20Per%C3%ADodo/Infraestrutura%20de%20Hardware?rlkey=mfji3vld4c4mh30qs0nwnd3gl&e=1&dl=0)
- [Compilado de links](https://docs.google.com/document/d/1iIdWJAyOIquXBDMsABHLJu7opGv5jPcYgsMq8SUIGjY/edit?tab=t.0)

## Licença

Distribuído sob a licença MIT. Consulte o arquivo [`LICENSE`](LICENSE) para conhecer os termos.

---

<div align="center">
  Feito para apoiar os estudos de arquitetura de computadores e programação de baixo nível.
</div>
