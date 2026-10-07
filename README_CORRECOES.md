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
- Fluxo `Tela Inicial → Criar Conta → Cadastro → Login → Home`.
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

