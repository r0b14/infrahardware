# Projeto IH 2026.2 — EQ01

Documentação de estudo e apresentação do circuito existente. Revisão: 13/09/2026.

A alteração no FigJam substitui **XCHG e SRAM por PUSH e POP**, mantendo a organização do circuito da equipe. O estudo cobre as **23 instruções** das páginas 7–8. Os diagramas didáticos ficam incorporados aos arquivos Markdown deste diretório.

**Ao retomar, comece por [00 — Leia primeiro](00-leia-primeiro.md):** ele reúne as alterações realizadas, as evidências da conferência e a ordem de continuidade.

## Índice

| Arquivo | Conteúdo |
|---|---|
| [00 — Leia primeiro](00-leia-primeiro.md) | Registro da entrega, estado de cada parte e próximos passos |
| [01 — Análise do quadro](01-analise-do-quadro.md) | O que já existe, o que mudou e o que ainda exige conferência |
| [02 — Catálogo das 23 instruções](02-catalogo-23-instrucoes.md) | Grupos por reaproveitamento, codificação e caminho didático de cada instrução |
| [03 — Arquitetura e sinais](03-arquitetura-e-sinais.md) | Seletores novos e reaproveitamento dos blocos originais |
| [04 — Estados de PUSH e POP](04-maquina-de-estados.md) | Microoperações, controles e exemplo 227 → 223 → 227 |
| [05 — Roteiro de apresentação](05-roteiro-de-apresentacao.md) | Sequência de fala, explicações passo a passo, perguntas e siglas expandidas |
| [06 — Plano de validação](06-plano-de-validacao.md) | Testes, codificação e resultados esperados |
| [07 — Decisões e fontes](07-decisoes-e-fontes.md) | Requisitos, propostas e pontos a confirmar |
| [08 — Atlas Mermaid](08-atlas-mermaid.md) | Diagramas de pilha e das outras famílias de instruções |
| [09 — Índice do circuito no Figma](09-indice-figma.md) | Links diretos para os blocos e pontos alterados |
| [10 — Dicionário de siglas e termos](10-dicionario-de-siglas-e-termos.md) | Nomes por extenso de blocos, sinais, campos e mnemônicos |

## Percursos de leitura

- **Apresentação rápida:** 10 → 05 → 02 (seção 4); usar os diagramas M01, M03, M04 e M05.
- **Estudo completo:** 01 → 02 → 03 → 04 → 07 → 08.
- **Implementação e verificação:** 03 → 04 → 06, consultando as pendências de 01 e 07.

## Fontes e alcance

- [Especificação local](../Especificacao%20Projeto%202026-2.pdf): tabelas das páginas 7–8; seção 2.7, iniciada na página 10, com os exemplos de PUSH/POP na página seguinte.
- [Circuito da equipe, atualizado no mesmo quadro](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=0-1).

O circuito foi inspecionado e editado como desenho. A presença de um bloco no FigJam demonstra uma proposta de conexão, mas não comprova a execução da instrução. Não foram encontrados módulos HDL ou testbench na pasta do projeto; os testes descritos são **critérios de aceitação a executar**, não resultados de simulação.

Os outros relatórios que já estavam na pasta Projeto foram preservados. Este material é inteiramente Markdown e não depende de uma apresentação externa.
