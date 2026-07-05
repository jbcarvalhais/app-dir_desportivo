# Diretor Desportivo — convenções do projeto

## Quem é o utilizador
Estudante de mestrado em Ciência de Dados, não programador. Todo o código é escrito e mantido pelo Claude. As explicações de passos técnicos (instalar, testar, publicar) devem ser em **português europeu**, sem jargão técnico desnecessário. O utilizador dedica ~2h/semana ao projeto: entregáveis pequenos, um de cada vez, testados no browser antes de avançar.

## Regra de processo
Antes de escrever código para um novo entregável, apresentar o plano e esperar aprovação explícita. Nunca publicar no GitHub Pages sem guiar o utilizador passo a passo (é a primeira vez que o faz).

## Arquitetura (fechada — não reabrir sem pedido explícito)
- **Um único ficheiro HTML** auto-suficiente: HTML + CSS + JavaScript vanilla. Sem passo de build, sem framework, sem Streamlit.
- Bibliotecas só por **CDN**: SortableJS (arrastar-e-largar) e html2canvas (exportar imagem).
- Alojamento: **GitHub Pages** (site estático, sem servidor).
- Fonte de dados: **API-Football** (`https://v3.football.api-sports.io`), autenticação por header `x-apisports-key`, chamada direta do browser (sem proxy).
- A chave da API **nunca** vai no código. É pedida uma vez ao utilizador e guardada só no `localStorage` do seu browser. Um cenário partilhado (link/imagem) é um snapshot de dados — quem o abre não precisa de chave.

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
| Sai (vendido por V, retenção r%) | + V × (1 − r/100) |
| Entra (reforço manual por V) | − V |
| Fora da análise (removido, recuperável) | 0 |

Valores em milhões de euros (€M), sempre introduzidos manualmente pelo utilizador. Saldo sempre visível, atualizado em tempo real.

## Vistas
- **Lista**: agrupada por linha (GK/Defesas/Médios/Avançados) segundo a posição principal, com idade inline, estado e valor.
- **Campo**: jogadores num relvado por posição principal; arrastar entre zonas reposiciona e muda a principal. MVP usa quadro posicional por linhas (não formação tática rígida de 11 slots).

## Partilha
- Imagem: PNG da vista de campo, descarregado para disco.
- Link: estado do cenário codificado no próprio URL, auto-contido.

## Ordem de construção (um entregável de cada vez)
1. Importar (chave + procurar clube + buscar plantel) → vista de lista editável, agrupada por linha, com placeholder de iniciais e idade inline.
2. Estados (fica/sai/entra/fora) + saldo com retenção.
3. Mini-editor de posições no cartão do jogador.
4. Vista de campo + arrastar para reposicionar/mudar a principal.
5. Partilha por link (estado no URL).
6. Exportar imagem (deixado para o fim — risco conhecido de CORS/canvas com fotos de CDN externo; tratar com `crossorigin` ou fetch como blob).

## Riscos conhecidos
- Plantel importado reflete a época terminada, não as transferências do mês corrente — o utilizador corrige à mão.
- Podem aparecer jogadores da equipa B → resolvido com "fora da análise".
- Exportação de imagem com fotos cross-origin pode bloquear o canvas do html2canvas — provável ponto de iteração.
