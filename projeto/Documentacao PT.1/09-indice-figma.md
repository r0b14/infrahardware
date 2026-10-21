# 09 — Índice do circuito no Figma

[Índice](README.md) · [Catálogo](02-catalogo-23-instrucoes.md) · [PUSH/POP](04-maquina-de-estados.md) · [Mermaid](08-atlas-mermaid.md)

[Visão geral do quadro original](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=0-1). Todos os links abaixo apontam para o mesmo circuito; a documentação permanece no repositório.

## 1. Pontos da extensão

| Elemento | ID | Finalidade |
|---|---|---|
| [Read1Sel](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=26-443) | 26:443 | Escolher rs ou índice 29 |
| [Read2Sel](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=26-446) | 26:446 | Escolher rt ou rs |
| [Constante 29](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=26-449) | 26:449 | Índice de SP para leitura e escrita |
| [Constante 227](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=26-452) | 26:452 | Dado inicial de SP em INIT_SP |
| [RegDst existente](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-42) | 1:42 | Entrada 3 acrescentada para R29 |
| [MemtoReg existente](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-43) | 1:43 | Entrada 8 acrescentada para 227 |
| [DataSource existente](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-101) | 1:101 | Entrada 2 reaproveitada para B |
| [B para DataSource](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-146) | 1:146 | Fio reaproveitado como derivação do barramento B |
| [AWrite](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=30-419) | 30:419 | Conservar SP antigo em A |
| [BWrite](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=30-423) | 30:423 | Conservar o dado de PUSH em B |

## 2. Blocos anteriores preservados

| Etapa | Elementos |
|---|---|
| Controle | [UC](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-2); [ALUControl](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-38) |
| Busca | [PC](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-3); [IR](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-5); [IorD](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-13) |
| Leitura | [Banco](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-9); [A](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-21); [B](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-22) |
| Cálculo | [ALU](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-12); [ALUOut](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-31); [constante 4](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-27) |
| Memória | [Memória](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-4); [MDR](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-7); [MergeBytes](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-105) |
| Produto e divisão | [MULT](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-65); [DIV](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-128); [HI](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-66); [LO](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-67) |
| Deslocamento | [SHIFT](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-77); [seleção de N](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-75) |
| Desvios | [PCSource](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-32); [EPC](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=1-111) |

## 3. Registro da substituição

- Excluídos os temporários `1:144` e `1:145` e seus fios/controles `1:147`, `1:148`, `1:149`, `1:152` e `1:153`. Parte desses fios foi eliminada automaticamente com os temporários.
- Retirada a entrada MDR → quantidade de SHIFT: `1:143`.
- Retiradas as entradas diretas de endereço do fluxo antigo: `1:150` e `1:151`.
- Reaproveitado `1:146` como B → DataSource[2], a partir do barramento B existente.
- Mantidas as fontes de MemtoReg 0–7; suas terminações foram alinhadas aos rótulos após inserir a entrada 8.
- Verificada a preservação da posição e do tamanho dos 38 blocos principais comparados antes/depois.

Os IDs permitem navegar e auditar a edição do desenho. Não são nomes de módulos HDL nem codificações da máquina de estados.
