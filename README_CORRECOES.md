# Correções e alterações aplicadas — Fhive

Este documento registra as alterações aplicadas ao projeto durante a
organização e evolução da interface.

## Organização

- Estrutura `lib` reorganizada em padrão feature-first.
- Criação de `core`, `shared` e `features`.
- Compatibilidade mantida em `lib/widget/` para imports antigos.
- Tema centralizado em `lib/core/theme/theme.dart`.

## Autenticação

- Nova tela inicial em `/inicio`.
- Fluxo `Tela Inicial → Entrar → Home`.
- Fluxo `Tela Inicial → Criar Conta → Cadastro → autenticação automática → Home`.
- Tela de cadastro padronizada visualmente com base na tela de login.
- Botões de login/cadastro e login social mantidos dentro da identidade visual
  do Fhive.

## Senha

- Criado indicador de força com quatro barras.
- 1 barra representa **Fraca**.
- 2 e 3 barras representam **Média**.
- 4 barras representam **Forte**.
- A quarta barra só é exibida quando todos os requisitos estão corretos.
- Requisitos: 6 caracteres, minúscula, maiúscula, número e caractere especial.
- O caractere especial é obrigatório.
- A interface informa dinamicamente o que ainda precisa ser atendido com o
  texto `A senha precisa de: ...`.
- Quando tudo está correto, aparece `Forte` e `Todos os requisitos foram
  atendidos.`.

## Interface

- Login e cadastro padronizados quanto a fundo, painel, tipografia, ícones,
  espaçamentos e botões.
- Tela inicial ampliada: logo maior, texto da marca maior e botões maiores,
  mantendo o layout original.
- Botões sociais do cadastro ajustados para evitar overflow.
- Transições entre telas suavizadas com fade e pequeno deslocamento lateral.
- Barra de navegação mantida integrada ao layout das telas principais.

## Aparelhos e favoritos

- Criada a função de cadastro de novos aparelhos.
- O aparelho cadastrado é incluído automaticamente na lista de dispositivos.
- Cada aparelho possui uma **estrela** para favoritar ou remover dos favoritos.
- A seção **Favoritos** da Home acompanha o estado das estrelas em tempo real.
- O estado de aparelhos e favoritos fica centralizado em
  `lib/shared/state/aparelhos_store.dart`.
- O botão superior de `+` das telas que possuem cabeçalho agora abre
  diretamente o cadastro de aparelho.

## Pop-up de adicionar aparelhos

- O cadastro de aparelhos deixou de abrir como uma tela inteira e passou a ser
  exibido como **pop-up sobre a tela atual**.
- O pop-up segue o mesmo conceito visual utilizado pelo tutorial: painel
  central marrom, cantos arredondados, sombra, botão de fechar no canto
  superior e fundo escurecido ao redor.
- O conteúdo do cadastro foi mantido em formato rolável para funcionar melhor
  em telas menores e quando o teclado estiver aberto.
- O botão `Adicionar aparelho` fecha o pop-up após o cadastro e mantém a lista
  atualizada sem exigir uma nova navegação.
- A abertura do pop-up foi centralizada na função
  `mostrarCriarAparelho(context)`, em
  `lib/features/devices/presentation/criar_aparelho.dart`.
- As telas Home, Aparelhos, Detalhes do Aparelho, Gráficos, Configurações e
  Rotinas foram ajustadas para usar o mesmo pop-up no botão superior de `+`.
- A rota independente `/criar-aparelho` foi removida do `main.dart`, pois o
  cadastro agora funciona como modal.

## Testes

- O teste de senha passou a verificar o `errorText` do campo através de
  `InputDecorator`, evitando conflito entre placeholder e mensagem de erro.
- Os testes passaram a considerar a nova tela inicial.
- O fluxo `Entrar → Home` é testado.
- O fluxo `Criar Conta → Cadastro` é testado.
- `ensureVisible` é usado antes de toques em botões que podem ficar fora da
  área visível em ambientes de teste menores.

## Flutter Analyze

Foram corrigidos:

- interpolação desnecessária em `graficos.dart`;
- elemento nulo em `configuracoes.dart` usando a forma null-aware apropriada.

## Validação

Antes de executar o aplicativo, recomenda-se rodar:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

> Observação: o ambiente usado para esta atualização não possui o Flutter/Dart
> instalado, portanto a validação de compilação e os testes automatizados
> precisam ser executados no ambiente local do projeto.

## Refinamento visual dos pop-ups

- O pop-up de **Adicionar aparelho** foi redesenhado para ficar mais leve e confortável.
- O **marrom principal (`AppColors.primary`)** agora aparece como destaque no cabeçalho e no botão principal, reforçando a identidade do Fhive sem deixar todo o formulário escuro.
- O conteúdo do formulário usa **creme, amarelo claro e superfícies suaves** já presentes no tema do aplicativo.
- Campos de nome, tipo e local ganharam áreas maiores, cantos mais arredondados, ícones e foco visual mais claro.
- A área de Wi-Fi foi transformada em um cartão compacto e mais legível.
- O botão de fechar ficou integrado ao cabeçalho do pop-up.
- O fundo externo ficou menos pesado, usando uma sombra mais suave e um escurecimento menor da tela ao redor.
- Os demais `AlertDialog` do aplicativo passaram a usar bordas arredondadas, espaçamento mais confortável, fundo creme e destaque consistente da cor principal por meio do tema global.
- O estilo do tutorial foi mantido como referência visual, preservando o uso do marrom principal com amarelo de destaque.

## Cadastro IoT de novos aparelhos — atualização atual

O fluxo de **Adicionar aparelho** foi ampliado para funcionar como um cadastro de dispositivo IoT mais completo, mantendo o cadastro em pop-up para não quebrar a navegação atual.

### Nova tela de identificação

- A primeira etapa do cadastro agora é exclusiva para a identificação do dispositivo.
- Campo **Nome do dispositivo**, usado para o usuário reconhecer o aparelho dentro da casa.
- Campo **ID do dispositivo**, preparado para receber identificadores como número de série, MAC ou ID fornecido pelo fabricante.
- Validação do nome com mínimo de 2 caracteres.
- Validação do ID entre 4 e 32 caracteres, aceitando letras, números, `_` e `-`.
- Bloqueio de cadastro quando o nome ou o ID já estiverem sendo usados por outro aparelho.

### Fluxo em etapas

O pop-up de cadastro passou a ter quatro etapas com indicador de progresso:

1. **Identificação** — nome e ID do dispositivo.
2. **Características** — tipo, fabricante, modelo e local.
3. **Conexão** — escolha entre Wi-Fi, Bluetooth ou Ethernet; no Wi-Fi também são solicitados nome da rede e senha.
4. **Revisão** — resumo de tudo que foi preenchido antes da confirmação.

### Conexão e configuração IoT

- Adicionada seleção do método de conexão: **Wi-Fi**, **Bluetooth** ou **Ethernet**.
- Para Wi-Fi, foram adicionados campos de **nome da rede** e **senha**.
- Adicionado botão **Testar** para validar os dados de conexão antes do cadastro.
- O cadastro registra o status inicial como **Online** quando a configuração foi marcada como testada; caso contrário, usa **Aguardando conexão**.
- A interface deixa explícito que o teste atual é apenas da configuração da tela: a conexão física, descoberta, pareamento, MQTT/HTTP ou outro protocolo depende de uma futura integração com o hardware e backend do projeto.

### Dados salvos do dispositivo

`AparelhoItem` foi ampliado para armazenar:

- nome;
- ID;
- tipo;
- fabricante;
- modelo;
- status;
- local;
- método de conexão;
- indicação de conexão Wi-Fi;
- ícone do tipo de dispositivo.

Também foram adicionadas verificações centralizadas no `AparelhosStore` para impedir IDs e nomes duplicados.

### Detalhes do aparelho

- A abertura de um aparelho pela lista agora envia para a tela de detalhes também o ID, tipo, fabricante, modelo, local, conexão e status.
- O menu **Informações** dos detalhes passou a exibir esses dados para facilitar a identificação e o suporte do dispositivo.

### Compatibilidade visual

- O novo fluxo continua usando o mesmo pop-up sobreposto já adotado pelo Fhive.
- O cabeçalho, progressão, campos, botões e cartões utilizam as cores, tipografia, bordas e superfícies já existentes no tema.
- O conteúdo permanece rolável para funcionar em telas menores e com o teclado aberto.

### Teste do novo fluxo

- Adicionado teste widget para abrir o cadastro IoT, preencher nome e ID, percorrer as quatro etapas e chegar à tela de revisão.

### Arquivos modificados nesta atualização

- `lib/features/devices/presentation/criar_aparelho.dart`
- `lib/shared/state/aparelhos_store.dart`
- `lib/features/devices/presentation/aparelhos.dart`
- `lib/features/devices/presentation/aparelho_detalhes.dart`
- `README_CORRECOES.md`

### Limite técnico desta implementação

O projeto continua sendo um protótipo de interface e fluxo de cadastro. Não foi adicionada uma biblioteca de Bluetooth, leitor de QR Code, descoberta automática de dispositivos, comunicação MQTT/HTTP ou integração com uma API/servidor IoT nesta atualização. A tela já organiza os dados necessários para essas integrações futuras sem simular que o hardware foi realmente pareado.


## Correção 2026-10-07 — Overflow no rodapé do cadastro IoT

- Corrigido o `RenderFlex overflowed by 24 pixels on the right` na tela `criar_aparelho.dart`.
- O rodapé do diálogo deixava os botões **Voltar** e **Continuar/Adicionar aparelho** obrigatoriamente na mesma `Row`.
- Em telas mais estreitas, essa combinação podia ultrapassar a largura disponível.
- O rodapé agora usa `LayoutBuilder` + `Wrap`, permitindo que os botões se reorganizem automaticamente quando a largura não comportar os dois na mesma linha.
- O espaçamento entre os botões e entre linhas foi preservado para manter o padrão visual.


## Correções de lint — 07/10/2026

Após a execução de `flutter analyze`, foram corrigidos os 6 apontamentos encontrados:

1. `aparelhos.dart`: o `if` que adiciona locais agora usa chaves, atendendo à regra `curly_braces_in_flow_control_structures`.
2. `criar_aparelho.dart`: a lista `_conexoes` passou a ser realmente utilizada para montar os cartões de Wi-Fi, Bluetooth e Ethernet, removendo o aviso `unused_field`.
3. `criar_aparelho.dart`: os `DropdownButtonFormField` de tipo e local trocaram `value` por `initialValue`, removendo o uso depreciado desde Flutter 3.33.0-1.0.pre.
4. `home.dart`: removida a função `_opcaoAdicionar`, que não estava sendo referenciada, eliminando o aviso `unused_element`.
5. `aparelhos_store.dart`: removido o import desnecessário de `package:flutter/foundation.dart`.
6. O fluxo de cadastro IoT e a correção anterior de overflow foram preservados; nenhuma funcionalidade do cadastro foi removida.

> Observação: o ambiente usado para gerar esta versão não possui o SDK do Flutter/Dart instalado, portanto a validação final por `flutter analyze` deve ser executada localmente.


## Interface dos aparelhos e tela de detalhes por tipo — 07/10/2026

- A tela `TelaAparelhos` passou de uma tela estática para uma interface com **seções expansíveis por local**.
- Cada seção de local agora possui uma seta clicável. Ao tocar nela, os aparelhos daquele local são ocultados ou exibidos sem afetar as demais seções.
- A quantidade de aparelhos de cada local é mostrada no cabeçalho da seção.
- Os cartões de aparelhos foram redesenhados com:
  - área de ícone maior;
  - identificação do tipo do aparelho;
  - indicador de status `Online`/`Offline`;
  - indicador visual do tipo de conexão;
  - espaçamento e contraste mais suaves para reduzir a sensação de poluição visual.
- A abertura de um aparelho continua enviando nome, ID, tipo, fabricante, modelo, local, conexão, status e ícone para a tela de detalhes.

### Tela de detalhes adaptativa por aparelho

A `TelaDetalhesAparelho` agora usa o campo `tipo` cadastrado para escolher automaticamente os controles exibidos:

- **TV:** ligar/desligar, volume, brilho, modo silencioso e atalhos de entretenimento.
- **Ar condicionado:** temperatura, modo de operação, velocidade de ventilação, modo sono e modo econômico.
- **Lâmpada:** ligar/desligar, brilho, temperatura da cor e cenas rápidas.
- **Câmera:** área de visualização, privacidade, detecção de movimento e gravação.
- **Tomada inteligente:** acionamento, potência, consumo diário e temporizador.
- **Sensor:** leituras de temperatura/umidade, monitoramento e alertas.
- **Outro:** controles genéricos de energia, notificações e atalhos.

A tela também foi reorganizada visualmente em cartões mais leves, com mais respiro, hierarquia de informação, áreas de toque maiores e uso consistente de `AppColors`/`AppSpacing`.

> Os controles permanecem como interface de protótipo. A execução física de comandos, leitura de sensores, streaming da câmera e demais ações dependem da integração do dispositivo e do backend IoT.

### Arquivos alterados nesta atualização

- `lib/features/devices/presentation/aparelhos.dart`
- `lib/features/devices/presentation/aparelho_detalhes.dart`
- `test/widget_test.dart`
- `README_CORRECOES.md`

### Testes desta atualização

- Adicionado teste para recolher e reabrir uma seção de local pela seta.
- Adicionado teste para garantir que a tela de detalhes de uma TV apresente controles próprios de TV e não os controles do ar condicionado.

## Favoritos, visual anterior da tela de aparelhos e nova tela de opções — 07/10/2026

### Acesso direto pelos favoritos

- O cartão de cada aparelho em **Favoritos** na Home agora abre diretamente `TelaDetalhesAparelho`.
- O usuário não passa mais pela tela `Minha casa > Todos aparelhos` para chegar aos controles.
- A navegação envia junto nome, ID, tipo, fabricante, modelo, local, conexão, status e ícone do aparelho, mantendo a tela de opções específica para cada dispositivo.

### Tela de aparelhos voltou ao visual anterior

- Restaurado o visual mais simples utilizado anteriormente na tela `Minha casa`.
- Removidos os cartões grandes de seção introduzidos na atualização anterior.
- Mantidos os cartões menores de aparelho, o cabeçalho de **Todos aparelhos** e a organização em grade.
- A funcionalidade de recolher/abrir os aparelhos de cada local foi preservada: tocar no nome/seta do local alterna entre aberto e fechado.
- A seta e a quantidade de aparelhos permanecem visíveis sem alterar o estilo mais leve da tela anterior.

### Tela de opções do aparelho redesenhada com referência às telas fornecidas

- A tela de opções passou a usar um painel creme grande sobre o gradiente amarelo, aproximando o formato das referências de **Ar condicionado** e **TV - Cristal**.
- O título do dispositivo e o ícone ficam no topo, com navegação de retorno discreta.
- Controles de ligar/desligar, sliders e atalhos agora usam a mesma linguagem visual das referências: textos marrons, áreas amarelo-claro, cantos arredondados e bastante espaço entre controles.
- Para **Ar condicionado**, foram mantidos e reorganizados: temperatura, desligamento automático, velocidade do ventilador, modo econômico, modo sono, gráficos e pré-configurações.
- Para **TV**, foram mantidos e reorganizados: ligar/desligar, volume, desligamento automático, controle remoto, gráficos e atalhos de streaming.
- Lâmpada, câmera, tomada, sensor e outros continuam tendo controles próprios conforme o tipo cadastrado, porém usando o novo padrão visual.
- Os dados de identificação continuam disponíveis no final da tela, recolhíveis para não deixar o painel visualmente carregado.

### Teste adicionado

- Criado teste widget para garantir que um aparelho favoritado na Home abre diretamente a tela de opções e apresenta controles específicos do tipo do aparelho.

### Arquivos modificados nesta atualização

- `lib/features/home/presentation/home.dart`
- `lib/features/devices/presentation/aparelhos.dart`
- `lib/features/devices/presentation/aparelho_detalhes.dart`
- `test/widget_test.dart`
- `README_CORRECOES.md`

## Correções após `flutter analyze` e `flutter test` — 07/10/2026

Foram corrigidos os problemas reportados na validação local do projeto:

- `aparelho_detalhes.dart`: removido o import não utilizado de `criar_aparelho.dart`.
- `aparelho_detalhes.dart`: removido o getter `_online`, que não era utilizado.
- `aparelho_detalhes.dart`: substituído `Switch.adaptive.activeColor` por `activeThumbColor`, eliminando o aviso de API depreciada.
- `test/widget_test.dart`: corrigido o teste da seta das seções para procurar os ícones que a tela realmente renderiza (`keyboard_arrow_up`/`keyboard_arrow_down`).
- `test/widget_test.dart`: atualizado o teste de detalhes da TV para validar os textos presentes no novo design (`TV da sala`, `Ligar/Desligar`, `Volume` e `Streamings`) em vez de títulos que não existem mais na interface.
- `home.dart`: os `ListTile` do menu foram envolvidos individualmente em `Material` transparente para evitar o alerta do Flutter sobre tinta/efeitos do `ListTile` escondidos por um `DecoratedBox` ancestral.

Essas alterações não mudam o fluxo funcional pedido anteriormente: favoritos continuam abrindo diretamente a tela de opções do aparelho e a tela `Minha casa` mantém o visual anterior com as seções recolhíveis.



## Correções de testes e avisos de renderização — 07/10/2026

Após a execução local de `flutter analyze` e `flutter test`, foram identificados
problemas nos testes por estado compartilhado e avisos de pintura do `ListTile`.

### Testes independentes

- Adicionado `AparelhosStore.reset()` em `lib/shared/state/aparelhos_store.dart`.
- O `setUp()` de `test/widget_test.dart` agora restaura a lista inicial de aparelhos
e os favoritos antes de cada teste.
- Isso evita que o teste de cadastro deixe um terceiro aparelho no `ValueNotifier`
e faça a tela de aparelhos mostrar mais de uma seta de seção.

### Teste da seta dos locais

- O teste agora procura a seta dentro do cabeçalho `Sala de Estar`, em vez de
usar `find.byIcon(...)` globalmente.
- A verificação passou a funcionar mesmo que outra seção/local seja adicionada
futuramente à tela.

### Aviso de `ListTile`/`DecoratedBox`

- Os `ListTile` dos menus de gráficos e de seleção de local das rotinas foram
envolvidos em `Material(color: Colors.transparent)`.
- A mesma proteção já existente no menu da Home foi preservada.
- Isso impede que o `DecoratedBox` externo esconda o fundo ou os efeitos de toque
do `ListTile` durante os testes.

### Sobre o teste da tela de TV

- O teste widget deve validar os textos que fazem parte do design atual da tela:
`Ligar/Desligar`, `Volume` e `Streamings`.
- Um teste local que ainda procure `Controles da TV` está desatualizado em relação
à implementação atual e deve ser substituído pelo teste presente nesta versão.

## Correção de compilação da tela de gráficos — 07/10/2026

A validação local apontou que `lib/features/analytics/presentation/graficos.dart` estava com a implementação de detalhes inserida dentro de `_TelaGraficosState`, causando uma segunda declaração de `build` e várias referências fora do escopo (`isTv`, `nomeAparelho`, `gastoEnergia`, `periodoSelecionado`, cores e dados do gráfico).

### O que foi corrigido

- Criada a classe `TelaGraficosDetalhes` com seu próprio `State`, separando corretamente a tela principal de gráficos da tela de detalhes.
- Movidos para o novo estado os dados específicos do aparelho: nome, ícone, pontuação, avaliação, gasto, horas de uso e informação específica.
- Criados os valores dos períodos `7 dias`, `4 semanas` e `6 meses`, mantendo o gráfico funcional ao trocar o período.
- Definidas as cores específicas usadas pela tela de detalhes (`laranja`, `textoSecundario`, `amareloClaro` e `amareloCard`).
- Mantida a diferenciação entre TV e ar-condicionado na tela de detalhes.
- A correção elimina a segunda declaração de `build` e os erros de identificadores indefinidos reportados pelo compilador.

### Arquivo modificado

- `lib/features/analytics/presentation/graficos.dart`



## Revisão dos ZIPs e ajustes de navegação e locais — 09/10/2026

Foram analisados os dois arquivos enviados nesta etapa:

- `lib(1).zip`: contém o código da pasta `lib`, organizado por funcionalidades (`features`), tema (`core/theme`), estado compartilhado (`shared/state`) e componentes compartilhados (`shared/widgets`), além dos exports legados em `lib/widget/`.
- `README_CORRECOES.zip`: contém o histórico de alterações anterior. O conteúdo existente foi preservado e esta seção foi acrescentada ao final para documentar as novas modificações.

### Destaque da barra de navegação

Arquivo modificado: `lib/shared/widgets/barra_navegacao.dart`.

- O item selecionado agora usa fundo marrom sólido, ícone branco e cantos arredondados.
- Foi adicionado um sombreado suave no item selecionado para separá-lo melhor do fundo creme.
- A animação de mudança de seleção foi suavizada e levemente ampliada.
- Os demais itens mantêm ícones marrons sobre fundo transparente.
- A altura, a ordem das rotas e o comportamento de navegação foram preservados; a mudança é localizada no indicador visual da aba ativa.

### Tela inicial: logotipo e botões

Arquivo modificado: `lib/features/auth/presentation/tela_inicial.dart`.

- O grupo composto pelo ícone e pela palavra **Fhive** foi centralizado explicitamente.
- O espaço horizontal entre o ícone e o texto foi reduzido de 10 para 4 pixels, aproximando a marca.
- A largura dos botões **Entrar** e **Criar Conta** foi aumentada de 190 para 225 pixels.
- Cores, formato dos botões, textos, navegação e gradiente foram mantidos.

### Lista centralizada de locais

Arquivo modificado: `lib/shared/state/aparelhos_store.dart`.

- Foi criado o `ValueNotifier` compartilhado `AparelhosStore.locais`.
- As sugestões iniciais foram centralizadas em `AparelhosStore.locaisSugeridos` para evitar listas fixas diferentes em cada tela.
- `locaisDisponiveis` fornece uma lista sem duplicatas, incluindo sugestões, locais personalizados e os locais usados pelos aparelhos cadastrados.
- `adicionarLocal` registra um local personalizado e impede nomes vazios ou duplicados, ignorando diferenças entre maiúsculas e minúsculas.
- `localExiste` permite validar nomes já registrados.
- Ao adicionar um aparelho, seu local também é registrado na lista compartilhada quando necessário.
- O método `reset()` restaura a lista inicial de sugestões, mantendo os testes independentes.

### Seletor de locais na tela de aparelhos

Arquivo modificado: `lib/features/devices/presentation/aparelhos.dart`.

- O rótulo **Locais** passou a ser clicável e abre/fecha um painel de locais disponíveis.
- O painel lista as sugestões e os locais personalizados já registrados.
- A opção **Todos** limpa o filtro; tocar em outro local filtra a lista para mostrar apenas aquele local.
- Um local selecionado sem aparelhos continua visível com contagem zero e a mensagem **Nenhum aparelho neste local ainda**.
- Foi adicionado o botão **Criar local**, que abre um diálogo para cadastrar um local personalizado.
- O diálogo valida nomes vazios e duplicados e informa o resultado ao usuário.
- Após criar um local pela tela de aparelhos, ele fica disponível no painel e no cadastro de aparelhos.
- A organização existente da tela, os cartões pequenos, o gradiente, as cores e a barra inferior foram mantidos.

### Locais personalizados no cadastro de aparelhos

Arquivo modificado: `lib/features/devices/presentation/criar_aparelho.dart`.

- O campo **Local do aparelho** passou a usar `AparelhosStore.locaisDisponiveis`, em vez de manter uma segunda lista independente dentro do formulário.
- As sugestões padrão continuam disponíveis.
- Foi adicionada a opção **Criar local personalizado** diretamente no seletor de locais.
- O diálogo de criação reutiliza a mesma validação compartilhada e impede locais vazios ou duplicados.
- Depois de criado, o novo local é selecionado no cadastro atual e também aparece no painel de locais da tela de aparelhos.
- Foi adicionada uma chave de atualização para restaurar o valor correto do seletor caso o usuário cancele ou não consiga criar um local.

### Arquivos alterados nesta atualização

- `lib/shared/widgets/barra_navegacao.dart`
- `lib/features/auth/presentation/tela_inicial.dart`
- `lib/shared/state/aparelhos_store.dart`
- `lib/features/devices/presentation/aparelhos.dart`
- `lib/features/devices/presentation/criar_aparelho.dart`
- `README_CORRECOES.md`

### Limite de persistência dos locais

Os locais personalizados usam o mesmo estado em memória do restante do protótipo, centralizado no `AparelhosStore`. Assim, ficam sincronizados entre a tela de aparelhos e o cadastro enquanto o aplicativo está em execução. Esta atualização não adiciona banco de dados nem armazenamento local permanente; manter locais após encerrar completamente o aplicativo depende de integrar persistência local ou backend.

### Validação

O ambiente desta edição não disponibiliza o SDK Flutter/Dart e os ZIPs de entrada não incluem `pubspec.yaml` nem a pasta `test`. Por isso, não foi possível executar `flutter analyze` ou `flutter test` nesta sessão. Recomenda-se validar no projeto completo com:

```bash
 dart format lib test
 flutter analyze
 flutter test
```


## Navegação por gestos e ícone do aplicativo — 09/10/2026

Os arquivos desta rodada foram `lib(2).zip` e `README_CORRECOES(1).zip`. Como eles não incluem `pubspec.yaml` nem diretórios nativos de Android/iOS/desktop, para aplicar o ícone de lançamento no projeto completo foi aproveitada a estrutura de plataforma do ZIP completo do Fhive já disponível nesta conversa; a pasta `lib` e o README foram substituídos pelos arquivos enviados nesta rodada.

### Navegação horizontal entre abas

Arquivo novo: `lib/shared/widgets/navegacao_por_deslize.dart`.

- Adicionado gesto horizontal às cinco telas principais, seguindo exatamente a ordem da barra inferior: **Início → Aparelhos → Gráficos → Rotinas → Configurações**.
- Arrastar para a esquerda avança para a próxima tela da barra; arrastar para a direita volta para a tela anterior.
- A navegação usa as mesmas rotas nomeadas já usadas pelos botões da barra, evitando fluxos divergentes.
- Nas extremidades da lista, o gesto não faz ciclo automático: Início não volta de Configurações e Configurações não avança para Início.
- O reconhecedor trata apenas gestos horizontais; os gestos verticais continuam disponíveis para rolagem dos conteúdos.
- A tela de detalhes de aparelhos e a tela de detalhes de gráficos ficaram fora do gesto de troca de abas para evitar que um arrasto sobre controles de aparelho/gráficos troque de seção inesperadamente.
- `BarraNavegacao.rotasPrincipais` é agora a lista compartilhada de rotas e serve como fonte única para a barra e para os gestos.

### Ícone do app

- Criado `assets/images/fhive_app_icon.png` em 1024×1024, usando a mesma marca SVG da tela inicial (`assets/images/logo.svg`).
- A marca é marrom (`#964800`) e está sobre um fundo em gradiente amarelo com as cores já usadas no tema (`#FFE832`, `#FFCD1B`, `#F4A91A`).
- A imagem foi adicionada à lista de assets do `pubspec.yaml`.
- Atualizados os ícones de lançamento Android em `android/app/src/main/res/mipmap-*`, além do ícone adaptativo em `mipmap-anydpi-v26/ic_launcher.xml` e da camada foreground.
- Atualizados os PNGs de ícone do catálogo iOS em `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.
- Atualizados os tamanhos de ícone do macOS em `macos/Runner/Assets.xcassets/AppIcon.appiconset/`.
- Atualizado o ícone multi-resolução do Windows em `windows/runner/resources/app_icon.ico`.
- O desenho das telas e o SVG usado dentro da tela inicial não foram modificados; a mudança de aparência é somente o ícone de lançamento e o novo gesto de navegação.

### Teste acrescentado

- Criado `test/navegacao_por_deslize_test.dart`, verificando que arrastar para a esquerda sai de Início para Aparelhos e arrastar para a direita retorna para Início.

### Arquivos modificados nesta atualização

- `lib/shared/widgets/barra_navegacao.dart`
- `lib/shared/widgets/navegacao_por_deslize.dart` (novo)
- `lib/features/home/presentation/home.dart`
- `lib/features/devices/presentation/aparelhos.dart`
- `lib/features/analytics/presentation/graficos.dart` (apenas a tela principal)
- `lib/features/routines/presentation/rotinas.dart`
- `lib/features/settings/presentation/configuracoes.dart`
- `assets/images/fhive_app_icon.png` (novo)
- `pubspec.yaml`
- `android/app/src/main/AndroidManifest.xml` (inclui a referência ao ícone redondo)
- `android/app/src/main/res/mipmap-*/*ic_launcher*`
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher*.xml` (novos)
- `android/app/src/main/res/drawable-nodpi/ic_launcher_foreground.png` (novo)
- `android/app/src/main/res/values/ic_launcher_colors.xml` (novo)
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/*`
- `windows/runner/resources/app_icon.ico`
- `test/navegacao_por_deslize_test.dart` (novo)
- `README_CORRECOES.md`

### Validação

Os arquivos PNG foram gerados a partir do SVG de marca existente e instalados nos catálogos e diretórios das plataformas incluídas no projeto base. A consistência do ZIP e dos catálogos JSON/XML foi verificada. Esta sessão não possui o SDK Flutter para executar `flutter analyze` ou `flutter test`; execute esses comandos localmente após extrair o pacote.


---

## Atualização de funções locais — 13/10/2026

Esta seção consolida neste README o histórico das alterações funcionais realizadas em 13/10/2026. O conteúdo antes mantido separadamente em `UPDATE_CORRECOES.md` foi incorporado aqui para que este arquivo seja a referência principal das mudanças do projeto.

### 1. Autenticação local

- Criado `lib/shared/state/auth_store.dart` para centralizar as contas e a sessão de demonstração.
- O login valida e-mail e senha contra uma conta cadastrada, em vez de aceitar somente o preenchimento do formulário.
- Conta local de demonstração: `teste@fhive.com` / `123456`.
- O cadastro valida nome, e-mail já existente e requisitos de senha; quando termina com sucesso, autentica a conta recém-criada e abre a Home automaticamente.
- A recuperação permite redefinir a senha de uma conta local existente e informa claramente quando a conta não é encontrada.
- Os botões Google/Facebook informam que são necessárias credenciais e integração com um serviço de autenticação; não afirmam que ocorreu uma autenticação externa.
- **Limite:** a autenticação é um protótipo em memória. Não há envio de e-mail, sessão segura ou backend, e a conta de demonstração não deve ser usada em produção.

### 2. Estado dos aparelhos, locais e favoritos

- `lib/shared/state/aparelhos_store.dart` centraliza o estado de locais, aparelhos e favoritos.
- Foram reunidas operações de cadastro, consulta por ID/nome, atualização, alteração de status, remoção, verificação de duplicidade e reinicialização.
- O modelo `AparelhoItem` inclui `copyWith` para permitir atualizações controladas.
- Os favoritos são associados ao ID do aparelho; a atualização de dados preserva essa referência quando o ID é mantido.
- Remover um aparelho também remove seu favorito, evitando referências órfãs.
- O cadastro verifica nomes e IDs duplicados. Os locais personalizados são compartilhados entre as telas enquanto o aplicativo está em execução.
- O menu superior da tela Aparelhos inclui ações para atualizar a lista, criar local e acessar a ajuda.
- A seção Favoritos da Home reflete o estado centralizado e permite remover um favorito diretamente.
- Os cartões e o contador da Home utilizam o estado centralizado dos aparelhos.

### 3. Cadastro e detalhes de aparelho

- Mantido o cadastro em quatro etapas dentro de um pop-up, com validação dos campos e seleção de local e método de conexão.
- O teste de conexão verifica os dados preenchidos na interface; não comprova pareamento ou conectividade física.
- O status inicial do aparelho é `Aguardando conexão` para não indicar falsamente que o hardware está online.
- A estrela dos detalhes utiliza o estado central de favoritos.
- O menu de detalhes permite consultar as informações cadastradas e remover um aparelho após confirmação.
- A ação Gráficos encaminha TVs e aparelhos de ar-condicionado para a visualização correspondente; outros tipos utilizam a rota geral.
- Pré-configurações de ar-condicionado, cenas de iluminação e serviços de streaming personalizados podem ser mantidos localmente, com validações para nomes vazios ou repetidos.
- Selecionar um streaming informa que a abertura requer o aplicativo ou link externo correspondente.
- **Limite:** interruptores e controles de aparelhos são demonstrativos locais. Comandos físicos dependem de hardware compatível e de um serviço/backend IoT.

### 4. Gráficos

- A lista de gráficos disponíveis é carregada do `AparelhosStore`; TVs e aparelhos de ar-condicionado cadastrados são exibidos para o local selecionado.
- O seletor de local permite escolher entre os locais disponíveis no aplicativo.
- Aparelhos sem visualização de gráficos disponível aparecem em uma seção separada e informam o motivo quando selecionados.
- A ação “Atualizar gráficos” esclarece que os dados atuais são demonstrativos e dependem de integração IoT para atualização em tempo real.
- Séries, pontuações e indicadores de energia/uso não são telemetria real.

### 5. Rotinas

- Criado `lib/shared/state/rotinas_store.dart` para centralizar o estado das rotinas.
- O estado reúne consulta, criação, atualização, ativação/desativação, registro de execução, remoção e reinicialização.
- A tela Rotinas consome esse estado e atualiza a interface após as mudanças.
- A criação valida o nome; o menu permite ativar/desativar ou remover com confirmação; tentar executar uma rotina inativa apresenta uma orientação.
- A execução local registra data/hora da última execução, mas não envia comandos a aparelhos físicos sem backend IoT.

### 6. Conta, ajuda e configurações

- Criadas `lib/features/settings/presentation/conta.dart` e `lib/features/settings/presentation/ajuda.dart`.
- Adicionadas as rotas `/conta` e `/ajuda` em `lib/main.dart`, ligadas à Home e a Configurações.
- Preferências de notificações, sincronização de favoritos e sugestões usam `lib/shared/state/preferencias_store.dart`.
- As mensagens das preferências explicam que o efeito é local e informam quando uma integração ainda não existe.
- Recursos avançados exibem um resumo de aparelhos, favoritos e rotinas, sem alegar que testam a conexão física.
- Os avisos de serviços vinculados, privacidade, consentimento e permissões não prometem integrações com terceiros ou permissões nativas não implementadas.
- “Sair” encerra a sessão local; “Sair do Fhive” solicita confirmação, limpa os dados demonstrativos e restaura o estado inicial, incluindo a conta de demonstração.

### 7. Testes e documentação

- `test/widget_test.dart` foi atualizado para cobrir a abertura inicial, login de demonstração, navegação, cadastro de aparelhos, favoritos, detalhes, Perfil/Ajuda, autenticação e redefinição de senha local, preferências e operações de aparelhos/rotinas.
- Mantido `test/navegacao_por_deslize_test.dart` para os gestos horizontais entre abas.
- Este README passa a reunir o histórico funcional e as limitações técnicas; o resultado da validação local mais recente está registrado na seção ao final do documento.

### 8. Arquivos criados nesta atualização

- `lib/shared/state/auth_store.dart`
- `lib/shared/state/preferencias_store.dart`
- `lib/shared/state/rotinas_store.dart`
- `lib/features/settings/presentation/conta.dart`
- `lib/features/settings/presentation/ajuda.dart`

### 9. Arquivos modificados nesta atualização

- `lib/main.dart`
- `lib/shared/state/aparelhos_store.dart`
- `lib/features/auth/presentation/entrar.dart`
- `lib/features/auth/presentation/cadastrar.dart`
- `lib/features/home/presentation/home.dart`
- `lib/features/devices/presentation/aparelhos.dart`
- `lib/features/devices/presentation/aparelho_detalhes.dart`
- `lib/features/devices/presentation/criar_aparelho.dart`
- `lib/features/analytics/presentation/graficos.dart`
- `lib/features/routines/presentation/rotinas.dart`
- `lib/features/settings/presentation/configuracoes.dart`
- `test/widget_test.dart`
- `test/navegacao_por_deslize_test.dart`
- `README.md` e `README_CORRECOES.md`

### 10. Integrações ainda necessárias para produção

Para transformar o protótipo local em uma aplicação pronta para produção, ainda será necessário implementar e configurar:

- backend e banco persistente para contas, sessões, aparelhos, rotinas, favoritos e preferências;
- autenticação segura e recuperação de senha por e-mail;
- OAuth/SDKs de Google e Facebook;
- hardware e protocolo IoT para pareamento, comandos, estados e execução real de rotinas;
- telemetria real para gráficos e consumo de energia;
- integrações com aplicativos/streaming, notificações e permissões nativas do sistema.

### 11. Comandos de validação

Use estes comandos a partir da pasta que contém `pubspec.yaml`:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

O resultado da execução local enviada em 13/10/2026 não foi totalmente aprovado; as falhas específicas e os próximos passos estão descritos na seção **Resultado da validação local — 13/10/2026** ao final deste documento.

## Detalhamento dos indicadores, ícone e edição de perfil — 13/10/2026

### Navegação para as telas detalhadas de gráficos

Os cartões da visão geral de cada aparelho agora abrem uma tela detalhada própria, mantendo a paleta amarela/marrom, as superfícies arredondadas e a tipografia já usadas no Fhive:

- **Energia:** o cartão `Energia` abre a página `Gasto diário`, com medidor semicircular, consumo em kWh, limite de referência, barra de utilização, legenda, dicas para economizar e histórico com períodos **Semanal / Mensal / Geral**.
- **Horas usadas:** o cartão `Uso` abre a distribuição de tempo por **Manhã / Tarde / Noite**, com barras coloridas, duração de cada período, total de horas e comparação demonstrativa com o dia anterior.
- **Pontuação:** o cartão `Pontos de gestão` abre a pontuação de 0 a 100, o status geral e a composição por consumo, tempo de uso e eficiência.
- **Histórico:** o cartão de gráfico abre uma página ampliada com linha histórica e seletor de períodos.
- **Informações específicas:** o cartão `Recomendações` (TV) ou `Temperatura` (ar-condicionado) abre uma tela com informação atual e sugestões contextualizadas.
- **Eficiência:** o cartão `Eficiência` abre uma tela com indicador circular, avaliação do aproveitamento e orientações para melhorar o resultado.

As telas detalhadas usam o nome personalizado do aparelho no cabeçalho e possuem retorno explícito por seta. Os cartões mantêm a aparência anterior, mas agora indicam uma ação ao toque.

### Ajuste de consistência das horas

- O exemplo da TV passa a usar **12 horas** no resumo, compatível com a distribuição demonstrativa `5h + 3h + 4h` da página detalhada.
- O ar-condicionado usa a distribuição demonstrativa `7h + 5h + 6h`, totalizando 18 horas.
- Os valores de energia, tempo e eficiência continuam sendo dados demonstrativos, não telemetria real. Para receber medidas de verdade, ainda é necessária a integração com o backend/dispositivo IoT.

### Ícone do aplicativo com traços reforçados

- O desenho de células hexagonais foi preservado; somente a espessura dos traços da marca foi aumentada.
- `assets/images/logo.svg` agora reforça o contorno com preenchimento e traço da mesma cor, mantendo a marca e as proporções que já apareciam na tela inicial.
- `assets/images/fhive_app_icon.png` foi atualizado e os ícones nativos do Android, iOS, macOS, Windows e Web (favicon/ícones PWA) foram regenerados a partir da mesma arte, para evitar aparências diferentes entre plataformas.
- A cor marrom da marca (`#964800`) e o fundo amarelo em gradiente foram mantidos.

### Tela de perfil revisada

- A tela de perfil foi organizada em cartões para **Dados pessoais** e **Segurança**, com mais hierarquia visual, espaçamento e áreas de toque confortáveis, seguindo padrões comuns em aplicativos de conta.
- O avatar apresenta as iniciais do nome atual e atualiza visualmente após alterar o perfil.
- O usuário pode editar **nome e e-mail**. A validação exige nome com pelo menos dois caracteres, e-mail válido e impede o uso de e-mail que já pertença a outra conta local.
- A seção expansível **Segurança** permite informar a senha atual, a nova senha e a confirmação; valida a senha atual, bloqueia senhas iguais e exige pelo menos seis caracteres, maiúscula, minúscula, número e caractere especial.
- Os formulários mostram/ocultam a senha, exibem mensagens claras e confirmam o resultado das operações.
- A tela mantém o aviso de que os dados ficam na memória na versão atual. Ainda não há sincronização com backend nem armazenamento permanente.

### Testes e arquivos alterados

- Acrescentados testes widget para a navegação entre os seis detalhes de indicadores e testes do `AuthStore` para atualização de nome, e-mail e senha.
- Atualizado o teste de perfil para continuar verificando o título `Perfil`.
- Arquivos alterados/adicionados:
  - `lib/features/analytics/presentation/graficos.dart`
  - `lib/features/analytics/presentation/indicador_grafico_detalhe.dart` (novo)
  - `lib/features/settings/presentation/conta.dart`
  - `lib/shared/state/auth_store.dart`
  - `assets/images/logo.svg`
  - `assets/images/fhive_app_icon.png`
  - Ícones de lançamento nativos das plataformas Android, iOS, macOS, Windows e Web (favicon/PWA)
  - `test/widget_test.dart`
  - `README_CORRECOES.md`, `UPDATE_CORRECOES.md` e `update_correções.md`

### Validação

- Foram verificados os caminhos dos assets e a integridade estrutural dos arquivos alterados.
- O SDK Flutter/Dart não está disponível neste ambiente; por isso, os testes novos ainda precisam ser executados localmente com `dart format lib test`, `flutter analyze` e `flutter test`.
- As telas têm conteúdo responsivo e rolável, mas a validação visual em emulador/dispositivo continua recomendada antes da publicação.

---

## Resultado da validação local — 13/10/2026

Esta seção registra o log local enviado junto com o projeto. Ela complementa as validações anteriores: descreve o resultado observado naquela execução e **não significa que as falhas já foram corrigidas**.

### `dart format lib test`

- O comando terminou e formatou 36 arquivos; 17 foram alterados pelo formatador.
- Entre os arquivos formatados estão telas de gráficos, autenticação, aparelhos, Home, rotinas, configurações, os stores compartilhados e os testes.
- A formatação bem-sucedida não garante que o aplicativo compile ou que os testes passem.

### `flutter analyze`

- A análise não terminou normalmente. O servidor de análise Dart encerrou com código `255`.
- O log registra `FormatException: Unexpected end of input` ao interpretar uma mensagem JSON/LSP em `LspByteStreamServerChannel._readMessage`.
- Como o servidor caiu antes de concluir a análise, o log **não comprova ausência de problemas de lint ou compilação**.
- Próxima tentativa recomendada: fechar e reabrir o terminal/IDE e executar `flutter pub get` e `flutter analyze` separadamente. Se o erro persistir, reiniciar o Dart Analysis Server no editor e repetir a análise.

### `flutter test`

O resumo do log foi `+9 -5`: nove testes passaram e cinco falharam. As falhas observadas foram:

1. **`Cadastro IoT percorre as quatro etapas e adiciona o aparelho`**
   - Foi reportado overflow horizontal de 37 pixels durante o layout.
   - O teste procurou o texto exato `Testar conexão`, mas não encontrou nenhum widget com esse texto.
   - Ajuste necessário: tornar o layout responsivo na largura usada pelo teste e alinhar o texto procurado pelo teste ao rótulo acessível/visível realmente usado pelo botão de teste de conexão.

2. **`Favorito aparece na Home e pode ser removido por lá`**
   - O toque no controle associado à dica `Remover dos favoritos` foi realizado em uma posição que não atingia o widget na área interativa.
   - Ao final, o favorito `FH-TV-CRISTAL-001` continuava na coleção.
   - Ajuste necessário: garantir que o controle esteja visível antes do toque, localizar a estrela/ação interativa correta no teste e confirmar que o callback de remoção atualiza o estado central.

3. **`Detalhes exibem controles e menu de informações`**
   - O teste procurou `FH-TV-TESTE-002`, mas o texto não foi encontrado na árvore visível.
   - Também apareceu o aviso do Flutter sobre `ListTile` dentro de `DecoratedBox` com cor de fundo; isso pode ocultar o feedback visual de toque.
   - Ajuste necessário: confirmar que o teste abre/expande a seção que mostra os dados de identificação e envolver `ListTile` decorados em `Material` próprio, quando aplicável.

4. **`Cartões de indicadores abrem telas detalhadas próprias`**
   - Foram registrados vários `RenderFlex overflow` na tela `lib/features/analytics/presentation/graficos.dart`, incluindo linhas próximas de 898, 961, 1003, 1083, 1413 e 1416. Os excessos atingiram áreas verticais e horizontais.
   - O teste esperava encontrar apenas um texto `Limite de energia`, mas a busca encontrou dois widgets com o mesmo texto.
   - Ajuste necessário: rever a composição responsiva dos cartões/detalhes em larguras menores e restringir a busca do teste à área ou widget correto, em vez de usar uma busca global ambígua.

5. **`Configurações abre Perfil e Ajuda`**
   - O teste terminou com falha e o log também registrou o aviso de `ListTile` colocado dentro de `DecoratedBox` com fundo.
   - O trecho de log fornecido não expõe a asserção exata que provocou essa falha; é necessário executar este teste isoladamente para identificar o ponto preciso.

Os avisos de renderização devem ser tratados mesmo quando não são a única causa de uma falha. Uma verificação útil depois dos ajustes é executar cada cenário com `flutter test --plain-name "nome do teste"` e, em seguida, repetir toda a suíte.

### `flutter run` para Windows — log inicial

A inicialização do aplicativo Windows falhou durante a geração dos arquivos de build do CMake. O log apontou a ausência da declaração `project()`, o comando `apply_standard_settings` desconhecido e a falha `Unable to generate build files`.

A inspeção dos arquivos identificou a causa direta: `windows/CMakeLists.txt` continha o conteúdo de configuração que pertence a `windows/flutter/CMakeLists.txt`. Esse erro fazia a configuração raiz procurar `windows/ephemeral/generated_config.cmake`, embora os arquivos gerados pelo Flutter pertençam a `windows/flutter/ephemeral/`.

**Correção aplicada no pacote atualizado:** o `windows/CMakeLists.txt` raiz foi restaurado com a configuração principal do projeto, a declaração `project(tcc_mobile LANGUAGES CXX)`, a função `APPLY_STANDARD_SETTINGS`, a inclusão de `flutter`, `runner` e dos plugins, e as regras de instalação. A configuração própria de `windows/flutter/CMakeLists.txt` foi mantida separada.

Para regenerar os arquivos de build no ambiente Windows, execute os comandos descritos na seção de correção adicionada ao final deste README. Não altere manualmente arquivos em `windows/flutter/ephemeral/`, pois são gerados pelas ferramentas Flutter.

### Dependências

O `flutter pub get` foi concluído, mas informou que oito dependências possuem versões mais recentes incompatíveis com as restrições atuais. Esse aviso, por si só, não foi apresentado como causa das falhas acima. Para revisar versões antes de qualquer atualização:

```bash
flutter pub outdated
```

Não se recomenda atualizar todas as dependências indiscriminadamente sem revisar a compatibilidade com o SDK, os plugins e os testes.

### Situação registrada no log

- **Formatação:** concluída.
- **Análise estática:** não concluída; servidor de análise encerrou com erro.
- **Testes automatizados:** parcialmente aprovados; nove passaram e cinco falharam.
- **Build Windows:** falhou durante a configuração CMake.
- **Correção do código após este log:** ainda pendente; esta seção documenta os achados e os próximos passos, sem alegar que eles foram resolvidos.



## Correção da configuração CMake do Windows — 13/10/2026

### Diagnóstico confirmado

O arquivo `windows/CMakeLists.txt` estava duplicando a configuração interna de `windows/flutter/CMakeLists.txt`. Por isso, a raiz do projeto não declarava corretamente o projeto CMake, não definia `APPLY_STANDARD_SETTINGS` e construía o caminho de arquivos gerados a partir da pasta errada. Isso corresponde ao erro mais recente:

```text
CMake Error at CMakeLists.txt:21 (apply_standard_settings):
  Unknown CMake command "apply_standard_settings".
```

### Alterações feitas

- Restaurado `windows/CMakeLists.txt` como arquivo raiz de configuração CMake para o aplicativo `tcc_mobile`.
- Incluídas a declaração do projeto CMake, a configuração dos modos `Debug`, `Profile` e `Release`, a função `APPLY_STANDARD_SETTINGS`, as regras de `runner`/plugins e as regras de instalação de assets.
- Mantido `windows/flutter/CMakeLists.txt` como a configuração específica da integração Flutter para Windows.
- Removidos do ZIP os diretórios de saída/cache `build/`, `.dart_tool/` e `windows/flutter/ephemeral/`, além de outros arquivos gerados de build que podem reter caminhos da máquina onde o projeto foi compilado. O diretório `.git/` não faz parte do ZIP de entrega. Esses arquivos e diretórios temporários são regenerados pelas ferramentas de desenvolvimento.

### Como testar no Windows

Na pasta do projeto, execute em um PowerShell:

```powershell
flutter clean
flutter pub get
flutter run -d windows
```

**Atenção:** `flutter clean` remove arquivos gerados, mas não corrige o conteúdo de `windows/CMakeLists.txt`. Se o erro `Unknown CMake command "apply_standard_settings"` continuar, confira primeiro se o arquivo raiz `windows/CMakeLists.txt` foi realmente substituído pela versão corrigida do pacote. Remover apenas `build/`, `.dart_tool/` ou `windows/flutter/ephemeral/` não resolve um `CMakeLists.txt` raiz incorreto. Não substitua `windows/flutter/CMakeLists.txt` nem `windows/runner/CMakeLists.txt`.

### Estado da validação

A correção estrutural do arquivo CMake foi aplicada ao pacote e o ZIP não contém os caches anteriores. A compilação real para Windows ainda precisa ser confirmada no computador com Flutter e ferramentas C++ para Windows instaladas; portanto, não se afirma aqui que `flutter run -d windows` já foi executado com sucesso. As falhas anteriores de `flutter test` e do servidor `flutter analyze` continuam registradas nas seções acima e não são corrigidas por esta alteração de CMake.


### Retorno após a nova tentativa — 13/10/2026

O usuário executou `flutter clean`, `flutter pub get` e `flutter run -d windows` na pasta local existente. As dependências foram resolvidas, mas o build parou novamente com:

```text
CMake Error at CMakeLists.txt:21 (apply_standard_settings):
  Unknown CMake command "apply_standard_settings".
```

Este resultado confirma que limpar o cache não foi suficiente. O comando `apply_standard_settings` está sendo chamado durante a configuração de um subdiretório (o ponto indicado na linha 21 normalmente corresponde a `windows/runner/CMakeLists.txt`), mas a configuração raiz carregada não disponibilizou essa função. A causa mais provável é que o arquivo corrigido `windows/CMakeLists.txt` ainda não foi copiado para a pasta do projeto que está sendo executada.

**Aplicação correta da correção:** extraia o arquivo `CMakeLists_windows_corrigido.txt` do pacote de correção e copie-o para a pasta do projeto com o nome exato `windows/CMakeLists.txt`, substituindo o arquivo existente. Alternativamente, extraia `Correcao_CMake_Fhive.zip` diretamente dentro da pasta `Fhive_flutter` existente e confirme que o destino final é `Fhive_flutter\windows\CMakeLists.txt` — não `Fhive_flutter\Fhive_flutter\windows\CMakeLists.txt`.

Depois, confira no início do arquivo `windows/CMakeLists.txt` se há uma declaração `project(tcc_mobile LANGUAGES CXX)` e procure a definição `function(APPLY_STANDARD_SETTINGS TARGET)` antes de `add_subdirectory(...)`. Só então execute:

```powershell
flutter clean
flutter pub get
flutter run -d windows
```

Se o erro mudar, registre a nova mensagem completa: ela poderá apontar um próximo problema diferente. A compilação não é considerada confirmada até que o comando termine sem erro.

## Correção do build Android (Gradle/Kotlin) — 14/10/2026

### Diagnóstico

A tentativa de `flutter run` falhou durante a configuração do Gradle, antes de compilar o aplicativo. O arquivo `android/build.gradle.kts` continha o bloco `plugins` e as configurações `android { ... }`, `kotlin { ... }` e `flutter { ... }` que pertencem ao módulo `android/app`, em vez das tarefas e repositórios do projeto Android. Isso fazia o Gradle tentar configurar um módulo de aplicativo na raiz e gerava erros como `Unresolved reference 'compilerOptions'` e `Unresolved reference 'jvmTarget'`.

Também faltava aplicar `org.jetbrains.kotlin.android` em `android/app/build.gradle.kts`, apesar de `settings.gradle.kts` declarar a versão do plugin e o módulo configurar `kotlin.compilerOptions`. Como `android/gradle.properties` mantém `android.builtInKotlin=false`, o projeto precisa aplicar explicitamente o plugin Kotlin Gradle (KGP).

### Correções aplicadas

- Restaurada a configuração raiz de `android/build.gradle.kts`, com repositórios, diretórios de build dos subprojetos, dependência de avaliação do módulo `:app` e tarefa `clean`.
- Adicionado `id("org.jetbrains.kotlin.android")` ao bloco `plugins` de `android/app/build.gradle.kts`, antes do plugin Gradle do Flutter.
- Mantidas as versões de AGP, Kotlin e Gradle já declaradas no projeto, assim como `android.newDsl=false` e `android.builtInKotlin=false`; a correção não atualiza dependências do aplicativo sem necessidade.
- Os avisos de pacotes Dart com versões mais novas não foram tratados como causa desta falha, pois o erro aconteceu durante a compilação dos scripts Gradle.

### Como validar no Windows

Na raiz do projeto `Fhive_flutter`, execute no PowerShell:

```powershell
flutter clean
flutter pub get
flutter run
```

Se o erro mudar, compartilhe a nova mensagem completa. A alteração corrige a inconsistência identificada nos scripts; a compilação real no celular ainda deve ser confirmada no ambiente local com o SDK Flutter, Java e Android SDK instalados.



## Ajuste da barra de navegação do sistema Android — 14/10/2026

- A área inferior do sistema Android agora usa o mesmo tom creme da barra de navegação do Fhive (`AppColors.surfaceLight`).
- Definida a cor da barra de navegação e dos ícones do sistema por `SystemChrome.setSystemUIOverlayStyle` para versões Android em que essa configuração é respeitada.
- Em Android 15+ no modo edge-to-edge, a faixa de gestos é transparente; o widget `NavegacaoPorDeslize` desenha o fundo creme sob essa faixa, mantendo o posicionamento dos ícones do app.
- Alterações realizadas em `lib/main.dart` e `lib/shared/widgets/navegacao_por_deslize.dart`.
- Para validar no dispositivo: executar `flutter clean`, `flutter pub get` e `flutter run`. O build Android não foi executado neste ambiente.

### Correção complementar: consistência da barra do sistema em todas as telas — 14/10/2026

**Problema observado:** a faixa inferior do Android ainda apresentava uma cor diferente em telas secundárias, principalmente nos detalhes dos gráficos dos aparelhos e na tela de controle de aparelhos. Essas telas não passam todas pelo widget `NavegacaoPorDeslize`, que anteriormente era responsável por pintar a área inferior transparente do modo edge-to-edge.

**Correção aplicada:**

- Criado `lib/shared/widgets/fundo_navegacao_sistema.dart`, um wrapper comum que define o estilo da barra de navegação do sistema e pinta de creme (`AppColors.surfaceLight`) a área inferior reservada à barra de gestos quando o Android usa edge-to-edge.
- Registrado o wrapper no `MaterialApp.builder`, em `lib/main.dart`, para abranger todas as rotas — telas principais, gráficos detalhados e controle de aparelhos — sem precisar alterar o layout interno de cada tela.
- Mantida a cor escura dos ícones/gestos do sistema para contraste sobre o fundo creme. A altura dos conteúdos e a posição da barra de navegação interna do Fhive não foram alteradas.

**Validação recomendada:** no projeto local, executar `dart format lib/main.dart lib/shared/widgets/fundo_navegacao_sistema.dart`, `flutter analyze`, `flutter test` e `flutter run`. Ainda é necessário conferir no dispositivo Android, sobretudo na tela de detalhes dos gráficos e na tela de controle do aparelho; a compilação real não foi executada neste ambiente.


## Polimento visual, perfil, gráficos e controle IoT — 14/10/2026

### Consistência visual
- Preservada a identidade visual já usada pelo Fhive: amarelos e laranjas em degradê, superfícies creme, marrom principal, cantos arredondados e tipografia existente. As alterações focam hierarquia, alinhamento, espaçamento, legibilidade, áreas de toque e adaptação a telas menores, sem reformular o aplicativo do zero.
- O ícone do aplicativo usa uma marca simplificada de casa com sinal Wi-Fi, sem texto pequeno, centrada em uma composição quadrada de alto contraste. Os arquivos de launcher das plataformas mantêm a mesma arte.
- O cabeçalho de Perfil recebeu fundo sólido na cor superior do degradê e o conteúdo continua com o fundo amarelo do tema, reduzindo a emenda visual na transição entre AppBar e conteúdo.

### Cadastro e perfil
- Ao concluir um cadastro válido, a sessão inicia automaticamente com a conta recém-criada e navega direto para a Home. Se o login local falhar por algum motivo, a tela informa o erro e permite entrar manualmente.
- Os campos de nome e e-mail do Perfil agora validam os dados antes de salvar e mostram mensagens junto dos respectivos campos; o teclado é recolhido antes de mostrar o resultado.
- A seção Segurança valida senha atual, força da nova senha, exigência de símbolo e confirmação. Mensagens de sucesso/erro não afirmam persistência no servidor: a autenticação continua sendo um protótipo local em memória.
- O texto dos termos do cadastro foi ajustado para “termos de uso do aplicativo”.

### Aparelhos, locais e gráficos
- Os cartões de gráficos são filtrados pelo local selecionado e mostram os aparelhos daquele cômodo que têm métricas disponíveis. Nomes de locais são comparados sem diferença entre maiúsculas/minúsculas e espaços nas pontas.
- O cabeçalho do local apresenta a quantidade de dispositivos e quantos têm gráficos suportados; quando não há aparelho elegível, é exibido um estado vazio em vez de um dispositivo fictício. Aparelhos sem telemetria compatível continuam identificados como aguardando dados, com explicação clara.
- As telas de detalhes recebem o status do aparelho para distinguir visualmente dispositivos online/offline. As métricas exibidas seguem sendo demonstrativas enquanto o backend de telemetria IoT não for integrado.
- Os cartões de dados e indicadores empilham as informações em larguras menores para reduzir risco de overflow e manter a leitura confortável.
- O favorito na Home tem um alvo de toque de pelo menos 44 × 44 px, e o teste de cadastro de aparelho procura o texto real do botão de teste de conexão, que é um `TextButton`.

### Controle da TV e atalhos
- A tela de controle da TV reúne energia, volume, canal, modo de imagem, aplicativos e acesso aos gráficos em grupos visuais consistentes com o tema atual.
- O fluxo “Adicionar atalho” permite nomear um atalho e escolher um comando. Atalhos cadastrados podem ser executados com um toque e removidos com toque longo; os comandos afetam o estado demonstrativo local da tela.
- A integração física com TVs e outros aparelhos permanece como etapa futura: para comandar hardware real será necessária integração a uma API/serviço IoT e ao protocolo suportado por cada fabricante.

### Validação
- Foi feita revisão estática dos arquivos modificados e conferência estrutural do conteúdo do pacote. Não foi possível executar `dart format`, `flutter analyze`, `flutter test` nem compilar o aplicativo nesta sessão, pois o SDK Flutter/Dart não está disponível no ambiente. Execute esses comandos localmente para confirmar a compilação e os testes antes de publicar.
