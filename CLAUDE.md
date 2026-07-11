# Janela Aberta (Diretor Desportivo) — convenções do projeto

> Nome da app decidido pelo utilizador a 2026-07-09, no âmbito de tornar o repositório público para publicar no GitHub Pages. O repositório GitHub e a pasta local mantêm-se `app-dir_desportivo`/`dir_desportivo` — só o nome apresentado na app (título da página, cabeçalho, imagem exportada) mudou.

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
- Importado da API: nome, foto (URL; sem foto → placeholder com iniciais), **número da camisola**, posição principal (categoria grosseira da API: Goalkeeper/Defender/Midfielder/Attacker → GK/DF/MF/AT, depois refinada pelo utilizador).
- Número mostrado de forma discreta, inline (`# 10`, editável) na Lista, e como pequeno indicador subtil (cor de destaque, mono) nos cartões do Campo e na imagem exportada; se não estiver preenchido, simplesmente não aparece nada (sem placeholder feio). Reforços também podem ter número.
- **Não há campo de idade** (decisão do utilizador a 2026-07-09 — reverte a decisão anterior de excluir o número e incluir a idade; o utilizador não via utilidade na idade).
- Definido pelo utilizador: estado, valor (€M), retenção % (só quando "Sai"), posições (principal + secundárias).
- **Ordem dentro do mesmo grupo/zona é editável** (decisão do utilizador a 2026-07-09): arrastar um jogador para cima/baixo dentro do mesmo grupo da Lista, ou dentro da mesma zona do Campo (incluindo ocupantes principais na vista detalhada), reordena-o sem mudar a posição. Implementado reinserindo o jogador no array `players` na posição correspondente ao subconjunto do grupo/zona — não é um campo separado. Posições secundárias (vista detalhada) não são arrastáveis, são só pré-visualização.
- **Nota livre por jogador** (decisão do utilizador a 2026-07-09): campo de texto curto opcional, editável na Lista (ex.: "Capitão, renovar contrato"). Só visível na Lista — não entra na imagem exportada, para não sobrecarregar.

## Vocabulário de posições (fechado)
- Guarda-redes: GK
- Defesas: LB, LWB, LCB, CCB, RCB, RB, RWB
- Médios: LCDM, CCDM, RCDM, LM, LCM, CCM, RCM, RM, LCAM, CCAM, RCAM
- Avançados: LW, LST, CST, RST, RW

> Nota: existe um documento de spec mais antigo (`MVP-diretor-desportivo.md`, fora deste repositório) com uma nomenclatura em português (GR, DD, DC, DLD...). A conversa mais recente com o utilizador substituiu essa decisão pela vocabulário inglês descrito acima (o número de camisola, que esse documento antigo também tinha, acabou por ser reintroduzido a 2026-07-09 — ver "Modelo de dados por jogador"). Se surgir uma inconsistência, esta versão é a válida, salvo indicação em contrário do utilizador.

## Estados do jogador e saldo
| Estado | Efeito no saldo |
|---|---|
| Fica | 0 |
| Sai (vendido por V, o clube fica com p%) | + V × (p/100) |
| Empréstimo (sai temporariamente, sem custos associados) | 0 |
| Entra (reforço manual por V) | − V |
| Fora da análise (removido, recuperável) | 0 |

Valores em milhões de euros (€M), sempre introduzidos manualmente pelo utilizador. Saldo sempre visível, atualizado em tempo real.

**Orçamento inicial e Outros custos (decisão do utilizador a 2026-07-09):** o saldo pode partir de um valor base ("Orçamento inicial", editável no topo do plantel, default 0) em vez de começar sempre em 0. Simétrico a "Outros ganhos" existe "Outros custos" — lista de entradas manuais (Descrição + Valor) que **subtraem** ao saldo (ex.: comissões de agentes). Saldo final = orçamento inicial + vendas + reforços (negativo) + outros ganhos − outros custos.

> Nota sobre visibilidade: tal como "Fora da análise", os jogadores marcados "Sai" ou "Empréstimo" também deixam de aparecer na Lista e no Campo principais (decisão do utilizador a 2026-07-07 para "Sai", estendida a "Empréstimo" a 2026-07-08) — ficam em secções à parte ("Vendidos" / "Emprestados"), recuperáveis (basta voltar a marcar "Fica"). O valor de venda continua sempre a contar no saldo, mesmo escondido da vista principal; o empréstimo nunca tem valor associado.

> Nota sobre a percentagem na venda: o campo pede diretamente "percentagem que fica no clube" (default 100%), não uma percentagem de corte/retenção a subtrair. Ex.: vendido por 10M€, clube fica com 80% → soma 8M€. Decisão do utilizador a 2026-07-05, mais intuitiva do que a formulação original com "retenção".

## Outros ganhos (dinheiro que não vem de jogadores do plantel)
Decisão do utilizador a 2026-07-08: além dos estados por jogador, existe uma lista independente de "ganhos extra" — entradas manuais de Descrição + Valor (€M) que somam sempre ao saldo. Serve para dinheiro que entra sem estar ligado a um jogador atualmente no plantel (ex.: cláusula de venda/percentagem de passe de um jogador que já tinha saído antes). Cada entrada pode ser removida. Não têm efeito negativo — só somam.

## Vistas
- **Lista**: agrupada por linha (GK/Defesas/Médios/Avançados) segundo a posição principal, com número inline, estado e valor. Jogadores "Sai", "Empréstimo" e "Fora da análise" ficam em secções à parte, recuperáveis. Cada grupo/secção é reordenável por arrasto (pega no ícone ⠿), sem alterar a posição de ninguém. **Filtro por nome** (decisão do utilizador a 2026-07-09): caixa de texto por cima da Lista que esconde os jogadores cujo nome não corresponde — só afeta a Lista, não o Campo.
- **Cartão do jogador compacto, mobile-first** (decisão do utilizador a 2026-07-09): cada jogador em duas linhas fixas — linha de cima (identidade: arrastar, foto, nome, número, posição) e linha de baixo (ações: estado, valor, "Posições"). O estado (Fica/Sai/Empréstimo/Fora) é um único menu (`<select>`) em vez de quatro botões separados, com a cor a refletir o estado (ex.: vermelho para Sai) — aplica-se a todos os tamanhos de ecrã, não só mobile, para não haver dois comportamentos a manter. Em ecrãs ≤480px a foto encolhe e os campos ficam mais estreitos. O estado "Sai" (tem valor + percentagem) pode ocupar 3 linhas em ecrãs muito estreitos — aceite como compromisso razoável, já que mostra mais informação do que os outros estados.
- **Editor de posições (mini-campo clicável, decisão do utilizador a 2026-07-09):** o painel "Posições" no cartão do jogador deixou de ser um menu + grelha de checkboxes e passa a ser um mini-campo clicável (mesma disposição da vista de Campo, em miniatura). Toque simples numa zona alterna-a como secundária; toque duplo define-a como principal (a deteção do duplo toque é feita à mão, por temporização, e não com o evento nativo do browser, porque o re-render a cada clique interferia com a deteção nativa). Visualmente: principal a cor de destaque preenchida, secundárias com contorno tracejado — mesma linguagem visual da vista de Campo detalhada.
- **Campo**: jogadores num relvado por posição principal (só "Fica" e "Entra" aparecem). Duas sub-vistas (decisão do utilizador a 2026-07-08):
  - **Vista simples** (default): só posições principais; arrastar entre zonas muda a posição principal e a posição anterior passa automaticamente a secundária (não se perde informação); arrastar dentro da mesma zona só reordena.
  - **Vista detalhada**: mostra também os jogadores nas posições secundárias, em duplicado, com sinalética mais discreta (chip mais pequeno, semitransparente, borda tracejada). Não é possível mudar de posição nesta vista, mas os ocupantes principais de cada zona podem ser reordenados entre si (as posições secundárias/duplicados não são arrastáveis).
  - Layout por linhas (revisto a 2026-07-08, e de novo a 2026-07-09 para alinhar corretamente as colunas): Guarda-redes (1 zona, mais pequena e centrada), Defesas (LB+LWB e RB+RWB empilhados no espaço de um Central, LCB, CCB, RCB — 5 "slots" de largura), Médios defensivos (LCDM/CCDM/RCDM alinhados com a largura de LCB/CCB/RCB, com zonas vazias e invisíveis dos lados em vez de esticar até à linha), Médios (5), Médios ofensivos (LW, LCAM, CCAM, RCAM, RW), Avançados (LST/CST/RST alinhados com a largura de LCAM/CCAM/RCAM, mesma lógica de zonas vazias). Zonas ordenadas da esquerda para a direita, para que os trios L/C/R se definam pela zona onde o jogador é largado. Orientação: guarda-redes no fundo, avançados no topo.
  - **Mobile (≤480px, decisão do utilizador a 2026-07-09):** cada zona passa a ter largura fixa de 70px (sem esticar), e o relvado ganha scroll horizontal próprio quando a soma das zonas não cabe no ecrã — garante que nenhuma zona fica espremida a ponto de ser ilegível ou impossível de usar com o dedo, e mantém as colunas alinhadas entre linhas mesmo com scroll. Acima de 480px mantém-se o comportamento original (zonas a esticar para preencher a largura, sem scroll).

## Partilha
- Imagem: PNG com cabeçalho (nome do clube + saldo), o campo (só Fica/Entra, **espelhando a sub-vista ativa no momento** — simples ou detalhada, decisão do utilizador a 2026-07-09) e, por baixo, quatro listas compactas "Saem", "Entram", "Outros ganhos" e "Outros custos" com valores associados e uma **linha de total por lista**, e uma assinatura discreta "Janela Aberta" no rodapé. Fotos convertidas para data URL antes da exportação (contorna CORS do CDN); se uma foto falhar, usa iniciais em vez de bloquear a exportação toda.
- **Formato vertical para stories** (decisão do utilizador a 2026-07-09): botão "Exportar para stories" gera a mesma imagem mas mais estreita (480px) e com as quatro listas empilhadas em coluna em vez de lado a lado — pensado para partilhar em Instagram/WhatsApp stories.
- **Link** (decisão do utilizador a 2026-07-09, retomado do backlog): botão "Copiar link" codifica o cenário completo (base64 do JSON, sem compressão extra para não reabrir a arquitetura de bibliotecas) num URL com âncora `#dados=...`; quem abre o link vê o cenário sem precisar de chave. Ao carregar, a âncora é removida do URL (`history.replaceState`) para que um refresh seguinte não reponha silenciosamente o cenário original por cima de edições entretanto feitas — usa antes a guardação automática normal a partir desse momento. Nota: o link fica comprido (não é encurtado), aceitável para colar num chat mas não é elegante.

## Guardar/carregar análise (decisão do utilizador a 2026-07-09)
Botão "Guardar análise" descarrega um `.json` local com todo o estado do cenário: jogadores (estado, posições, valores), outros ganhos, nome/escudo do clube e cor de destaque escolhida. Botão "Carregar análise guardada" (no ecrã de procurar clube) lê esse ficheiro e repõe o cenário exatamente como estava — sem nenhuma chamada à API-Football, poupando o limite diário de pedidos. Pensado para continuar uma análise noutro dia ou computador sem reimportar o plantel. Cada ficheiro guardado inclui um campo `versao` (constante `ANALISE_VERSAO_ATUAL` no código); ao carregar um ficheiro com versão mais recente do que a app suporta, mostra um aviso mas continua a tentar carregar (aviso suave, não bloqueia).

## Interface: arrumação e feedback (decisão do utilizador a 2026-07-09)
- "Guardar análise" e "Exportar imagem" ficam juntos numa única barra de ações, logo a seguir ao cabeçalho do clube (em vez de espalhados entre o topo e os separadores Lista/Campo).
- Ações que geram um ficheiro ou mudam o cenário (guardar análise, exportar imagem, carregar `.json`, retomar análise automática) mostram um aviso temporário no fundo do ecrã (ex.: "Imagem descarregada ✓") que desaparece sozinho ao fim de ~2,5s — implementado com animação CSS (`@keyframes`), não com `requestAnimationFrame`, para não depender do browser estar em primeiro plano.
- Contorno de foco visível (`:focus-visible`) em toda a app, com a cor de destaque do clube, para navegação por teclado.

## Guardação automática + retomar análise (decisão do utilizador a 2026-07-09)
Além do ficheiro `.json` manual, a app guarda uma cópia completa do cenário em curso no `localStorage` a cada alteração (nome, número, estado, posição, valor, cor, reforços, ganhos extra, reordenação) — silenciosa, sem qualquer ação do utilizador. Ao abrir a app, se existir uma cópia automática, aparece uma faixa no ecrã "Procurar clube" ("Tens uma análise por retomar: [Clube]") com as opções "Retomar análise" (repõe tudo, tal como o carregamento manual) ou "Descartar" (apaga a cópia). A cópia automática só é substituída quando há uma alteração real no cenário atual — não é limpa só por clicar em "Procurar outro clube", precisamente para servir de rede de segurança contra fechos acidentais do browser.

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
10. Reordenar jogadores dentro da mesma posição, alinhar zonas LCDM/RCDM/LST/RST, número de camisola em vez de idade, exportar imagem a espelhar a sub-vista ativa. ✅
11. Guardação automática no browser + faixa "retomar análise" ao abrir a app. ✅
12. Lista compacta mobile-first: cartão do jogador em duas linhas fixas, e os 4 botões de estado substituídos por um único menu. ✅
13. Campo em mobile: zonas com largura mínima garantida (70px) e scroll horizontal próprio do relvado em ecrãs estreitos. ✅
14. Editor de posições visual: mini-campo clicável substitui o menu + checkboxes (toque simples = secundária, toque duplo = principal). ✅
15. Barra única de ações (guardar/exportar), avisos temporários, abreviação "Emprést.", foco visível, aviso de versão ao carregar ficheiro. ✅
16. Orçamento inicial, "Outros custos", filtro por nome na Lista, nota livre por jogador, partilha por link, e exportação em formato vertical para stories. ✅
17. **Publicar no GitHub Pages** — por fazer, a guiar passo a passo quando o utilizador pedir (nunca automatizado, é a primeira vez).

## Riscos conhecidos
- Plantel importado reflete a época terminada, não as transferências do mês corrente — o utilizador corrige à mão.
- Podem aparecer jogadores da equipa B → resolvido com "fora da análise".
- Exportação de imagem com fotos cross-origin pode bloquear o canvas do html2canvas — provável ponto de iteração.
