# 00 — Leia primeiro ao retomar

[Índice completo](README.md) · [Circuito no Figma](https://www.figma.com/board/hILCPGWNEfBjOQvYNMzxR0/ProjetoIH-2K26.2--EQ01?node-id=0-1)

## 1. O que foi entregue

A estrutura do circuito da equipe foi preservada. A alteração no FigJam ficou concentrada na substituição de **XCHG (R) e SRAM (I) por PUSH (R) e POP (R)**. O estudo e a apresentação estão nesta pasta, em arquivos Markdown.

| Entrega | Onde revisar | Situação |
|---|---|---|
| Alteração localizada do circuito | [Índice dos blocos no Figma](09-indice-figma.md) | Realizada no quadro original |
| Análise das 23 instruções | [Catálogo](02-catalogo-23-instrucoes.md) | 13 R, 8 I e 2 J documentadas |
| Ligações e seletores da pilha | [Arquitetura e sinais](03-arquitetura-e-sinais.md) | Fontes, larguras e habilitações descritas |
| Controle de PUSH/POP | [Estados](04-maquina-de-estados.md) | Captura, microoperações, escrita e espera especificadas |
| Material para apresentar | [Roteiro](05-roteiro-de-apresentacao.md) e [13 Mermaid](08-atlas-mermaid.md) | Sequência de fala, exemplos e diagramas |
| Critérios de teste | [Plano de validação](06-plano-de-validacao.md) | Entradas, resultados esperados e sinais a observar |
| Pontos ainda não demonstrados | [Análise](01-analise-do-quadro.md) e [decisões](07-decisoes-e-fontes.md) | Separados das alterações realizadas |

## 2. A mudança em três ideias

1. **SP é R29.** Os novos seletores permitem capturar SP antigo em A e o operando de PUSH em B, mantendo a leitura rs/rt para as outras instruções.
2. **PUSH:** calcular SP−4, escrever R29 e depois gravar o dado capturado no endereço calculado.
3. **POP:** ler no SP atual, aguardar a memória, escrever rd e depois escrever SP antigo+4. As duas escritas usam a mesma porta do banco em estados diferentes.

O exemplo central segue o texto da seção 2.7: **227 → 223 → 227**. Não foi usado arredondamento para 220. A descrição detalhada e a ordem dos bytes estão em [04](04-maquina-de-estados.md).

## 3. Conferências realizadas

- Os 38 blocos principais comparados conservaram posição e tamanho.
- Os 14 novos elementos de desenho esperados estão presentes: dois muxes, duas constantes e dez conexões de dados/controle.
- Os dez elementos exclusivos retirados do fluxo antigo não aparecem na conferência final.
- Não ficaram seções paralelas de apresentação no FigJam.
- Os 13 Mermaid foram renderizados sem erro; os fluxos principais foram inspecionados visualmente.
- As codificações e os valores do exemplo foram conferidos. Os links do material foram revisados.

## 4. O que ainda depende de implementação

O desenho e os estados documentados **não são uma simulação da CPU**. A busca por módulos Verilog/VHDL e projetos de hardware na pasta IF674 não encontrou os arquivos necessários para implementar ou simular a UC nesta revisão.

As primeiras verificações quando os módulos estiverem disponíveis são:

| Ordem | Verificação | Referência |
|---|---|---|
| 1 | Conciliar reset do banco com SP=227; INIT_SP está proposto para antes da primeira busca | D02 em [07](07-decisoes-e-fontes.md) |
| 2 | Confirmar acesso exato aos bytes 223–226 e a latência de leitura | D03/D08 em [07](07-decisoes-e-fontes.md) |
| 3 | Implementar as seleções e os estados de PUSH/POP na UC existente | [03](03-arquitetura-e-sinais.md) e [04](04-maquina-de-estados.md) |
| 4 | Executar PUSH/POP simples, LIFO e PUSH R29; observar as duas escritas de POP | [06](06-plano-de-validacao.md) |
| 5 | Conferir as outras instruções e as exceções conforme os achados A01–A12 | [01](01-analise-do-quadro.md) |

Esses pontos estão documentados para continuidade; não foram tratados como testes aprovados.

## 5. Revisão rápida antes de apresentar

Leia 03 e 04, abra M03/M04/M05 em 08 e ensaie o roteiro de 05. Use 09 para localizar cada bloco no circuito. Os relatórios anteriores da pasta Projeto foram preservados.
