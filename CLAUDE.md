# Diretor Desportivo — convenções do projeto

## Quem é o utilizador
Estudante de mestrado em Ciência de Dados, não programador. Todo o código é escrito e mantido pelo Claude. As explicações de passos técnicos (instalar, testar, publicar) devem ser em **português europeu**, sem jargão técnico desnecessário. O utilizador dedica ~2h/semana ao projeto: entregáveis pequenos, um de cada vez, testados no browser antes de avançar.

## Regra de processo
Antes de escrever código para um novo entregável, apresentar o plano e esperar aprovação explícita. Nunca publicar no GitHub Pages sem guiar o utilizador passo a passo (é a primeira vez que o faz).

Assim que o utilizador testar e aprovar um entregável (ex.: "está a funcionar e gosto"), fazer commit com mensagem descritiva e `git push` para o repositório remoto **automaticamente, sem pedir confirmação extra** — o utilizador autorizou esta prática a 2026-07-05 precisamente para não perder trabalho entre sessões/computadores. Isto aplica-se só a `git push` para o repositório de código; não se estende a GitHub Pages nem a outras ações.

## Arquitetura (fechada — não reabrir sem pedido explícito)
- **Um único ficheiro HTML** auto-suficiente: HTML + CSS + JavaScript vanilla. Sem passo de build, sem framework, sem Streamlit.
- Bibliotecas só por **CDN**: SortableJS (arrastar-e-largar) e html2canvas (exportar imagem).
- Alojamento: **GitHub Pages** (site estático, sem servidor).
- Fonte de dados: **API-Football** (`https://v3.football.api-sports.io`), autenticação por header `x-apisports-key`, chamada direta do browser (sem proxy).
- A chave da API **nunca** vai no código. É pedida uma vez ao utilizador e guardada só no `localStorage` do seu browser. Um cenário partilhado (link/imagem) é um snapshot de dados — quem o abre não precisa de chave.

## Identidade visual (fechada — não reabrir sem pedido explícito)
Direção "sala de reuniões do clube": visual escuro e sóbrio, inspirado nas gráficas de transferências dos canais desportivos e no boardroom de um clube, não numa app de startup. Decisão do utilizador a 2026-07-07.
- **Cores** (variáveis CSS no `:root`): `--bg` azul-marinho quase preto (#0E1A24), `--card`/`--surface` tons ligeiramente mais claros para cartões e campos de formulário, `--brass` dourado envelhecido (#B8955A) como **única cor de destaque** (botões, estados ativos), `--pitch` verde relvado reservado só à vista de Campo. Estados semânticos (`--signal-red`/`--signal-green`) separados da cor de destaque. Posições por linha usam uma paleta discreta própria (`--gk`/`--df`/`--mf`/`--at`), não cores web genéricas.
- **Tipografia** (Google Fonts via CDN): "Big Shoulders Display" (condensada, tipo placar de estádio) para títulos, nome do clube e cabeçalhos; "IBM Plex Sans" para todo o texto de interface; "IBM Plex Mono" para números (saldo, valores), sempre com `font-variant-numeric: tabular-nums`.
- **Layout:** cabeçalho do plantel ("masthead") junta o escudo do clube (vindo da API-Football) + nome + saldo em destaque, em vez de elementos separados.
- Esta identidade aplica-se a toda a app, incluindo a imagem exportada (mesmo cabeçalho, cores e tipografia).
- **Cor do clube (decisão do utilizador a 2026-07-09):** seletor de cor nativo no topo do plantel substitui `--brass` pela cor escolhida (ex.: verde do Sporting), em toda a app e na imagem exportada — exceto o relvado do Campo (sempre verde) e os estados semânticos Sai/Entra (sempre vermelho/verde). O contraste do texto sobre a cor de destaque é calculado automaticamente (luminância) para nunca ficar ilegível. Reposta ao dourado por defeito sempre que se procura um clube novo; fica guardada como parte do ficheiro de análise (ver "Guardar/carregar análise").

## Princípios centrais
- **"Tudo o que vem da API é semente, tudo é editável"**: os dados importados (nome, foto, idade, posição) são só ponto de partida. O utilizador edita tudo depois.
- **"Espelho, não validador"**: a app mostra fielmente o que o utilizador definir (ex.: três centrais LCB/CCB/RCB se for isso que ele escolher). Nunca valida nem redistribui posições automaticamente.

## Modelo de dados por jogador
- Importado da API: nome, foto (URL; sem foto → placeholder com iniciais), idade, posição principal (categoria grosseira da API: Goalkeeper/Defender/Midfielder/Attacker → GK/DF/MF/AT, depois refinada pelo utilizador). **Não há campo de número de camisola.**
- Idade mostrada de forma discreta, inline: `Nome (34)` — nunca como campo grande.
- Definido pelo utilizador: estado, valor (€M), retenção % (só quando "Sai"), posições (principal + secundárias).

## Vocabulário de posições (fechado)
- Guarda-redes: GK
- Defesas: LB, LWB, LCB, CCB, RCB, RB, RWB
- Médios: LCDM, CCDM, RCDM, LM, LCM, CCM, RCM, RM, LCAM, CCAM, RCAM
- Avançados: LW, LST, CST, RST, RW

> Nota: existe um documento de spec mais antigo (`MVP-diretor-desportivo.md`, fora deste repositório) com uma nomenclatura em português (GR, DD, DC, DLD...) e um campo de número de camisola. A conversa mais recente com o utilizador substituiu explicitamente essas duas decisões pelas descritas acima. Se surgir uma inconsistência, esta versão (vocabulário inglês, sem número) é a válida, salvo indicação em contrário do utilizador.

## Estados do jogador e saldo
| Estado | Efeito no saldo |
|---|---|
| Fica | 0 |
| Sai (vendido por V, o clube fica com p%) | + V × (p/100) |
| Empréstimo (sai temporariamente, sem custos associados) | 0 |
| Entra (reforço manual por V) | − V |
| Fora da análise (removido, recuperável) | 0 |

Valores em milhões de euros (€M), sempre introduzidos manualmente pelo utilizador. Saldo sempre visível, atualizado em tempo real.

> Nota sobre visibilidade: tal como "Fora da análise", os jogadores marcados "Sai" ou "Empréstimo" também deixam de aparecer na Lista e no Campo principais (decisão do utilizador a 2026-07-07 para "Sai", estendida a "Empréstimo" a 2026-07-08) — ficam em secções à parte ("Vendidos" / "Emprestados"), recuperáveis (basta voltar a marcar "Fica"). O valor de venda continua sempre a contar no saldo, mesmo escondido da vista principal; o empréstimo nunca tem valor associado.

> Nota sobre a percentagem na venda: o campo pede diretamente "percentagem que fica no clube" (default 100%), não uma percentagem de corte/retenção a subtrair. Ex.: vendido por 10M€, clube fica com 80% → soma 8M€. Decisão do utilizador a 2026-07-05, mais intuitiva do que a formulação original com "retenção".

## Outros ganhos (dinheiro que não vem de jogadores do plantel)
Decisão do utilizador a 2026-07-08: além dos estados por jogador, existe uma lista independente de "ganhos extra" — entradas manuais de Descrição + Valor (€M) que somam sempre ao saldo. Serve para dinheiro que entra sem estar ligado a um jogador atualmente no plantel (ex.: cláusula de venda/percentagem de passe de um jogador que já tinha saído antes). Cada entrada pode ser removida. Não têm efeito negativo — só somam.

## Vistas
- **Lista**: agrupada por linha (GK/Defesas/Médios/Avançados) segundo a posição principal, com idade inline, estado e valor. Jogadores "Sai", "Empréstimo" e "Fora da análise" ficam em secções à parte, recuperáveis.
- **Campo**: jogadores num relvado por posição principal (só "Fica" e "Entra" aparecem). Duas sub-vistas (decisão do utilizador a 2026-07-08):
  - **Vista simples** (default): só posições principais; arrastar entre zonas muda a posição principal e a posição anterior passa automaticamente a secundária (não se perde informação).
  - **Vista detalhada**: mostra também os jogadores nas posições secundárias, em duplicado, com sinalética mais discreta (chip mais pequeno, semitransparente, borda tracejada). Não é possível arrastar nesta vista.
  - Layout por linhas (revisto a 2026-07-08 para reduzir sobrecarga visual): Guarda-redes (1 zona, mais pequena e centrada em vez de ocupar a linha toda), Defesas (LB+LWB e RB+RWB empilhados no espaço de um Central, LCB, CCB, RCB — 5 "slots" de largura), Médios defensivos (3), Médios (5), Médios ofensivos (LW, LCAM, CCAM, RCAM, RW), Avançados (LST, CST, RST). Zonas ordenadas da esquerda para a direita, para que os trios L/C/R se definam pela zona onde o jogador é largado. Orientação: guarda-redes no fundo, avançados no topo.

## Partilha
- Imagem: PNG com cabeçalho (nome do clube + saldo), o campo (só Fica/Entra, vista simples) e, por baixo, três listas compactas "Saem", "Entram" e "Outros ganhos" com valores associados e uma **linha de total por lista** (acrescentada a 2026-07-09, para o saldo bater sempre certo com o que se vê na imagem). Fotos convertidas para data URL antes da exportação (contorna CORS do CDN); se uma foto falhar, usa iniciais em vez de bloquear a exportação toda.
- Link: **adiado para o backlog** (decisão do utilizador a 2026-07-07 — não faz sentido para já). Retomar só se pedido explicitamente.

## Guardar/carregar análise (decisão do utilizador a 2026-07-09)
Botão "Guardar análise" descarrega um `.json` local com todo o estado do cenário: jogadores (estado, posições, valores), outros ganhos, nome/escudo do clube e cor de destaque escolhida. Botão "Carregar análise guardada" (no ecrã de procurar clube) lê esse ficheiro e repõe o cenário exatamente como estava — sem nenhuma chamada à API-Football, poupando o limite diário de pedidos. Pensado para continuar uma análise noutro dia ou computador sem reimportar o plantel.

## Ordem de construção (um entregável de cada vez)
1. Importar (chave + procurar clube + buscar plantel) → vista de lista editável, agrupada por linha, com placeholder de iniciais e idade inline. ✅
2. Estados (fica/sai/entra/fora) + saldo com retenção. ✅
3. Mini-editor de posições no cartão do jogador. ✅
4. Vista de campo + arrastar para reposicionar/mudar a principal. ✅
5. ~~Partilha por link~~ — adiado para o backlog.
6. Exportar imagem. ✅ (MVP core está completo)
7. Vista de campo: vista simples vs. detalhada (posições secundárias em duplicado), drag-and-drop com posição anterior a passar a secundária, e reorganização das linhas do campo. ✅
8. Estado "Empréstimo" (sem custos) e secção "Outros ganhos" (entradas manuais de dinheiro não ligado a jogadores do plantel). ✅
9. Guardar/carregar análise em ficheiro local, cor do clube personalizável, e totais por categoria na imagem exportada. ✅

## Riscos conhecidos
- Plantel importado reflete a época terminada, não as transferências do mês corrente — o utilizador corrige à mão.
- Podem aparecer jogadores da equipa B → resolvido com "fora da análise".
- Exportação de imagem com fotos cross-origin pode bloquear o canvas do html2canvas — provável ponto de iteração.
