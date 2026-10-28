# UPDATE_CORRECOES — Implementação de funções do Fhive

**Data:** 13/10/2026  
**Projeto:** Fhive Flutter  
**Objetivo:** concluir os comportamentos locais que estavam incompletos, sem redesenhar as telas existentes nem alterar a paleta visual principal.

## 1. Autenticação local

- Criado `lib/shared/state/auth_store.dart` para centralizar as contas e a sessão de demonstração.
- O login agora valida e-mail e senha contra uma conta cadastrada em vez de aceitar somente o preenchimento do formulário.
- Adicionado usuário de demonstração: `teste@fhive.com` / `123456`.
- O cadastro valida nome, e-mail já existente e requisitos da senha; após sucesso, volta à tela de login.
- A recuperação permite redefinir a senha de uma conta local existente e apresenta uma mensagem clara quando não encontra a conta.
- Os botões Google/Facebook informam a necessidade de credenciais e de um serviço de autenticação; não simulam que houve login ou cadastro externo.
- A autenticação é apenas um protótipo em memória. Não existe envio de e-mail, sessão segura ou backend; as senhas não devem ser usadas como mecanismo de produção.

## 2. Estado dos aparelhos, locais e favoritos

- Refeito `lib/shared/state/aparelhos_store.dart` como ponto central de estado para locais, aparelhos e favoritos.
- Incluídos métodos de cadastro, consulta por ID/nome, atualização, alteração de status, remoção, checagem de duplicados e reinicialização de estado.
- Adicionado `copyWith` ao modelo `AparelhoItem` para editar dados de forma controlada.
- Favoritos são relacionados pelo ID estável do aparelho; renomear/alterar o ID por meio do método de atualização preserva a referência de favorito.
- Remover um aparelho também remove seu favorito, evitando favoritos órfãos.
- O cadastro de novos aparelhos valida nome e ID duplicados, e os novos locais passam a ser compartilhados pelas telas enquanto o app estiver aberto.
- O menu superior da tela Aparelhos agora responde a atualizar lista, criar local e ajuda.
- A seção Favoritos da Home mostra o estado atualizado e permite remover um favorito diretamente.
- Os cartões e o contador da Home usam o estado centralizado dos aparelhos.

## 3. Cadastro e detalhes de aparelho

- Mantido o fluxo de quatro etapas do pop-up de cadastro, com validação dos campos e seleção de local/conexão.
- O teste de conexão agora descreve corretamente que valida os dados informados: não marca o dispositivo físico como conectado.
- O status inicial de um novo aparelho é `Aguardando conexão`, evitando indicar falsamente que o hardware está online.
- Nos detalhes, a estrela usa o mesmo estado central de favoritos.
- Adicionado menu para consultar as informações cadastradas e remover um aparelho com confirmação.
- A ação Gráficos encaminha TVs e aparelhos de ar-condicionado para a tela de gráficos correspondente e mantém rota geral para outros tipos.
- As pré-configurações de ar-condicionado e cenas de iluminação podem ser criadas localmente; duplicados e nomes vazios são tratados.
- Serviços de streaming personalizados podem ser adicionados à lista local. Selecionar um serviço existente informa que a abertura exige o app/link externo correspondente; não é alegada uma integração inexistente.
- Os interruptores e controles de dispositivo continuam sendo controles demonstrativos locais. Enviar comandos físicos exige serviço/backend e compatibilidade do hardware.

## 4. Gráficos

- A lista de gráficos disponíveis agora é carregada do `AparelhosStore`: TVs e aparelhos de ar-condicionado cadastrados aparecem no local selecionado.
- O seletor de local da tela de gráficos permite escolher entre os locais disponíveis no aplicativo.
- Os cartões adicionais de outros tipos de aparelho são mostrados na seção de gráficos indisponíveis e informam o motivo quando tocados.
- O menu “Atualizar gráficos” não afirma que atualizou telemetria real; informa que os valores atuais são demonstrativos e precisam de integração IoT para atualização em tempo real.
- As séries, pontuações e valores apresentados em detalhes de gráficos continuam sendo dados de demonstração, não medições reais.

## 5. Rotinas

- Criado `lib/shared/state/rotinas_store.dart`, que estava ausente apesar de a tela/teste precisar dele.
- Centralizadas as operações de consulta, criação, atualização, ativação/desativação, registro de execução, remoção e reset das rotinas.
- A tela de Rotinas passou a consumir esse estado e exibe mudanças sem precisar reconstruir a tela manualmente.
- A criação valida o nome; o menu da rotina ativa/desativa ou remove com confirmação; tentar executar uma rotina inativa apresenta orientação.
- A execução local registra data/hora da última execução. Ela não envia comandos aos dispositivos físicos enquanto o backend IoT não estiver integrado.

## 6. Conta, ajuda e configurações

- Criada `lib/features/settings/presentation/conta.dart` para ver nome/e-mail e editar o nome da conta local.
- Criada `lib/features/settings/presentation/ajuda.dart` com orientações para aparelhos, favoritos, rotinas e limites de integração.
- Adicionadas as rotas `/conta` e `/ajuda` em `lib/main.dart`, ligadas à Home e Configurações.
- Preferências de notificação, sincronização de favoritos e sugestões passaram a compartilhar um estado local centralizado em `lib/shared/state/preferencias_store.dart`.
- As mudanças nessas preferências apresentam mensagens que esclarecem o alcance local e as integrações ainda ausentes.
- O item Recursos avançados mostra um resumo de aparelhos, favoritos e rotinas e deixa claro que não testa a conexão física.
- Os avisos de serviços vinculados, privacidade, consentimento e permissões foram ajustados para não prometer vínculo com terceiros, coleta remota ou permissões nativas que não estão implementadas.
- “Sair” encerra apenas a sessão; “Sair do Fhive” pede confirmação, limpa os dados da demonstração e restaura o estado inicial (incluindo a conta de demonstração) para que o app continue utilizável.

## 7. Testes e documentação

- Reescrito `test/widget_test.dart` para refletir as telas/rotas do projeto atual e cobrir abertura inicial, login demonstrativo, navegação, cadastro de aparelho, favoritos, detalhes, Perfil/Ajuda, cadastro/autenticação/redefinição de senha local, preferências e CRUD de aparelhos/rotinas.
- Mantido o teste de navegação por gestos em `test/navegacao_por_deslize_test.dart`.
- Atualizado `README.md` com a conta de demonstração, rotas de Perfil/Ajuda e limitações da versão.
- O histórico anterior permanece em `README_CORRECOES.md`; este arquivo concentra as alterações desta atualização.

## 8. Arquivos criados

- `lib/shared/state/auth_store.dart`
- `lib/shared/state/preferencias_store.dart`
- `lib/shared/state/rotinas_store.dart`
- `lib/features/settings/presentation/conta.dart`
- `lib/features/settings/presentation/ajuda.dart`

## 9. Arquivos modificados

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
- `README.md`
- `README_CORRECOES.md`

## 10. Limitações técnicas que dependem de integração externa

Esta atualização conclui o comportamento que pode ser implementado com os arquivos disponíveis, mas não inventa credenciais nem serviços externos. Para uma versão de produção ainda será necessário configurar:

- backend e banco persistente para contas, sessões, aparelhos, rotinas, favoritos e preferências;
- autenticação segura e fluxo real de recuperação de senha por e-mail;
- OAuth/SDKs de Google e Facebook;
- protocolo e hardware IoT para pareamento, comandos, estados e execução real das rotinas;
- telemetria para gráficos e dados de energia reais;
- integrações de apps/streaming, notificações e permissões nativas do sistema.

## 11. Validação

O ambiente desta edição não tem os comandos `flutter` e `dart` disponíveis. Por isso, não foi possível executar `flutter pub get`, `dart format`, `flutter analyze` nem `flutter test` nesta sessão. A validação estática dos arquivos e a consistência do pacote devem ser complementadas no ambiente que contém o SDK Flutter com:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

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

## Correção de configuração Gradle Android — 14/10/2026

- `android/build.gradle.kts`: restaurado como script raiz do projeto, removendo o bloco de aplicativo que estava no local errado.
- `android/app/build.gradle.kts`: aplicado explicitamente `org.jetbrains.kotlin.android`, necessário enquanto `android.builtInKotlin=false` estiver definido.
- Não foi possível executar o build Android nesta sessão por depender do ambiente local Flutter/Android. Teste com `flutter clean`, `flutter pub get` e `flutter run` no computador de desenvolvimento.



## Ajuste da barra de navegação do sistema Android — 14/10/2026

- A área inferior do sistema Android agora usa o mesmo tom creme da barra de navegação do Fhive (`AppColors.surfaceLight`).
- Definida a cor da barra de navegação e dos ícones do sistema por `SystemChrome.setSystemUIOverlayStyle` para versões Android em que essa configuração é respeitada.
- Em Android 15+ no modo edge-to-edge, a faixa de gestos é transparente; o widget `NavegacaoPorDeslize` desenha o fundo creme sob essa faixa, mantendo o posicionamento dos ícones do app.
- Alterações realizadas em `lib/main.dart` e `lib/shared/widgets/navegacao_por_deslize.dart`.
- Para validar no dispositivo: executar `flutter clean`, `flutter pub get` e `flutter run`. O build Android não foi executado neste ambiente.

### Correção complementar da barra de navegação do Android — 14/10/2026

A faixa inferior do Android não acompanhava a barra interna em algumas telas secundárias, pois o fundo era desenhado anteriormente apenas por `NavegacaoPorDeslize`. Para tornar o comportamento global, foi criado `lib/shared/widgets/fundo_navegacao_sistema.dart` e conectado ao `MaterialApp.builder` em `lib/main.dart`. Assim, a mesma cor creme e o estilo de ícones escuros são aplicados também aos detalhes dos gráficos dos aparelhos e à tela de controle dos aparelhos. O teste visual no celular ainda é necessário; esta sessão não dispõe do SDK Flutter para confirmar compilação e execução.


## Integração com backend Fhive — 28/10/2026

- Substituída a autenticação demonstrativa pela autenticação da API: cadastro com confirmação por e-mail, login JWT, perfil, alteração de senha e recuperação por código.
- Adicionado cliente HTTP central em `lib/core/network/api_client.dart`, com URL configurável por `FHIVE_API_BASE_URL`, cabeçalho Bearer, timeout e mensagens de falha.
- Dispositivos e rotinas agora são carregados do backend; criação/exclusão de aparelhos e operações de rotina usam os endpoints REST existentes. As listas começam vazias e não inserem aparelhos ou rotinas fictícios.
- O app consulta telemetria pelo ID interno MongoDB e diferencia leituras reais de valores demonstrativos.
- Acrescentada a camada de serviço de equipes, pronta para uso quando houver interface correspondente.
- O token e os caches de conta são limpos ao sair. Favoritos, atalhos e preferências continuam locais.
- Padronizada a senha forte nos fluxos de cadastro, alteração e recuperação: mínimo de 8 caracteres, maiúscula, minúscula, número e símbolo, validado tanto no mobile como nos controllers do backend.
- Limitações assumidas: ainda não há API para enviar comandos físicos aos aparelhos ou executar rotinas sob demanda; a integração MQTT de comando deverá ser definida no backend. Cadastro/recuperação exigem SMTP válido.
- O backend recebeu os campos de local/fabricante/modelo/conexão nos dispositivos, o endpoint autenticado para exclusão e documentação de configuração em `.env.example` e `README.md`.
- A camada Flutter ainda precisa ser validada no ambiente de desenvolvimento com `dart format lib test`, `flutter analyze` e `flutter test`; essas ferramentas não estavam disponíveis durante a edição.

## Correção da configuração Windows/CMake e análise Dart
- Adicionada uma definição alternativa protegida de `apply_standard_settings` nos CMakeLists do runner e da camada Flutter, para evitar o erro `Unknown CMake command` quando a configuração de plataforma está inconsistente.
- Removidos qualificadores `this.` desnecessários e adicionado `@override` no método `build` da tela de detalhes dos gráficos.
- Removida constante de cor não utilizada, atualizados parâmetros de campos suspensos para `initialValue` e adicionadas verificações `mounted` após operações assíncronas na tela de conta.
- Aplicada a sintaxe de elementos de mapa null-aware do Dart 3.8+ nos serviços de autenticação e equipes.
- A compilação Windows ainda deve ser confirmada localmente com `flutter run -d windows`, pois o ambiente de edição não possui a toolchain Flutter/Visual Studio para validar esse alvo.
