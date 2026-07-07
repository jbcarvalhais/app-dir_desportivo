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
| Entra (reforço manual por V) | − V |
| Fora da análise (removido, recuperável) | 0 |

Valores em milhões de euros (€M), sempre introduzidos manualmente pelo utilizador. Saldo sempre visível, atualizado em tempo real.

> Nota sobre visibilidade: tal como "Fora da análise", os jogadores marcados "Sai" também deixam de aparecer na Lista e no Campo principais (decisão do utilizador a 2026-07-07) — ficam numa secção "Vendidos" à parte, recuperável (basta voltar a marcar "Fica"). O valor de venda continua sempre a contar no saldo, mesmo escondido da vista principal.

> Nota sobre a percentagem na venda: o campo pede diretamente "percentagem que fica no clube" (default 100%), não uma percentagem de corte/retenção a subtrair. Ex.: vendido por 10M€, clube fica com 80% → soma 8M€. Decisão do utilizador a 2026-07-05, mais intuitiva do que a formulação original com "retenção".

## Vistas
- **Lista**: agrupada por linha (GK/Defesas/Médios/Avançados) segundo a posição principal, com idade inline, estado e valor. Jogadores "Sai" e "Fora da análise" ficam em secções à parte, recuperáveis.
- **Campo**: jogadores num relvado por posição principal (só "Fica" e "Entra" aparecem); arrastar entre zonas reposiciona e muda a principal. MVP usa quadro posicional por 6 linhas (não formação tática rígida de 11 slots): Guarda-redes, Defesas (7 zonas), Médios defensivos (3), Médios (5), Médios ofensivos (3), Avançados (5) — zonas ordenadas da esquerda para a direita, para que os trios L/C/R (ex.: LCB/CCB/RCB) se definam pela zona onde o jogador é largado. Orientação: guarda-redes no fundo, avançados no topo (decisão do utilizador a 2026-07-07).

## Partilha
- Imagem: PNG com cabeçalho (nome do clube + saldo), o campo (só Fica/Entra) e, por baixo, duas listas compactas "Saem" e "Entram" com valores associados. Fotos convertidas para data URL antes da exportação (contorna CORS do CDN); se uma foto falhar, usa iniciais em vez de bloquear a exportação toda.
- Link: **adiado para o backlog** (decisão do utilizador a 2026-07-07 — não faz sentido para já). Retomar só se pedido explicitamente.

## Ordem de construção (um entregável de cada vez)
1. Importar (chave + procurar clube + buscar plantel) → vista de lista editável, agrupada por linha, com placeholder de iniciais e idade inline. ✅
2. Estados (fica/sai/entra/fora) + saldo com retenção. ✅
3. Mini-editor de posições no cartão do jogador. ✅
4. Vista de campo + arrastar para reposicionar/mudar a principal. ✅
5. ~~Partilha por link~~ — adiado para o backlog.
6. Exportar imagem. ✅ (MVP core está completo)

## Riscos conhecidos
- Plantel importado reflete a época terminada, não as transferências do mês corrente — o utilizador corrige à mão.
- Podem aparecer jogadores da equipa B → resolvido com "fora da análise".
- Exportação de imagem com fotos cross-origin pode bloquear o canvas do html2canvas — provável ponto de iteração.
