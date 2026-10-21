# 07 — Decisões, limites e fontes

[Índice](README.md) · [Catálogo](02-catalogo-23-instrucoes.md) · [PUSH/POP](04-maquina-de-estados.md) · [Mermaid](08-atlas-mermaid.md)

## 1. Referência normativa

A especificação da disciplina governa esta CPU. MIPS convencional é complemento quando o texto abrevia uma operação. A orientação do usuário define o escopo: preservar o circuito, trocar XCHG/SRAM por PUSH/POP e manter estudo/apresentação em Markdown no repositório.

## 2. Decisões e pendências

| ID | Tema | Requisito ou lacuna | Tratamento |
|---|---|---|---|
| D01 | JAL/delay slot | O PDF descreve o alvo, mas não fecha claramente o link e a execução de delay slot. | Exemplos assumem ausência de delay slot e link=P+4. Confirmar antes de codificar a UC; não tratar como texto expresso do PDF. |
| D02 | Reset/SP | Seção 2.2 exige SP=227 quando reset é ativado; seção 2.8.3 diz que o reset assíncrono limpa o banco. | INIT_SP escreve 227 antes da primeira busca, após reset. Isso não comprova SP=227 enquanto reset=1. Confirmar a integração aceita ou ajustar banco/wrapper conforme a disciplina. |
| D03 | Palavra em 223 | O exemplo exige 223 em memória endereçada por byte. | Manter o endereço exato e conferir acesso a 223..226 no módulo; não arredondar para 220. |
| D04 | POP R29 | A colisão entre destino e atualização de SP não é explicitada. | A sequência faz SP antigo+4 prevalecer na última escrita. Confirmar; não usar esse caso como demonstração principal. |
| D05 | Divisão mínimo/−1 | 0x80000000/−1 não cabe em 32 bits com sinal. | Não inventar resultado/exceção normativa; confirmar comportamento esperado. |
| D06 | RTE | A seção de exceções menciona PC←EPC, mas não fornece codificação nas 23 instruções. | Não criar opcode/funct nem acrescentar uma 24ª instrução sem definição. |
| D07 | LB/SLT | LB é resumida como leitura de byte; SLT não detalha o hardware. | Adotar extensão de sinal de LB e comparação com sinal de SLT; testar extremos e resultado 0/1. |
| D08 | Leitura | Saída válida no pulso seguinte à requisição; MDR também amostra em borda. | REQ/WAIT/CAP conservador, a confrontar com o HDL antes de otimizar estados. |

## 3. Mapa de fontes

| Fonte | Trecho | Uso |
|---|---|---|
| [Especificação 2026.2](../Especificacao%20Projeto%202026-2.pdf) | Páginas 7–8, tabelas 1–3 | Lista/codificação das 23 instruções |
| Mesma especificação | Página 8, seção 2.2 | R29 como SP e início em 227 |
| Mesma especificação | Páginas 8–10, seções 2.3/2.4 | DIV/MULT separados, sinais e resultados |
| Mesma especificação | Página 10, seções 2.5/2.6 | Desvios e preservação de bytes em SB |
| Mesma especificação | Seção 2.7: título na página 10; exemplos na 11 | Ordem de PUSH/POP, também enviada pelo usuário |
| Mesma especificação | Páginas 11–12, seções 2.8.1/2.8.3 | Memória, latência, little-endian e porta única de escrita |
| Mesma especificação | Páginas 13–14, Figuras 7/8 e seção 2.9 | SHIFT, códigos da ALU e exceções |
| [Quadro EQ01](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=0-1) | Circuito original e revisão localizada | Evidência dos blocos e ligações; navegação em 09 |
| [MIPS32 Architecture for Programmers, Volume II-A, revisão 3.00](https://pages.hmc.edu/harris/class/e155/11/MIPS32InstructionSet.pdf) | Entradas LB e SLT, páginas internas 142 e 232 | Referência primária complementar para operação com sinal |

## 4. Limite da avaliação

Um fio no FigJam não comprova largura no HDL, temporização ou habilitações. O desenho não apresenta o interior da UC, de MergeBytes e dos componentes fornecidos. Os achados A01–A12 devem orientar a conferência desses módulos; não são afirmações de aprovação das 23 instruções em simulação.

Os relatórios anteriores da pasta Projeto foram preservados. A avaliação anterior das 23 instruções refere-se a outro identificador de quadro e não substitui a inspeção deste circuito.
