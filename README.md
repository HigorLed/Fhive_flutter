# Launch Screen Assets

You can customize the launch screen with your own desired assets by replacing the image files in this directory.

You can also do it by opening your Flutter project's Xcode project with `open ios/Runner.xcworkspace`, selecting `Runner/Assets.xcassets` in the Project Navigator and dropping in the desired images.

### Barra de navegação do Android

A faixa de gestos inferior acompanha o tom creme da barra de navegação do Fhive. O tratamento usa a cor do sistema quando suportada e desenha o fundo do app por trás da área transparente nos dispositivos Android com edge-to-edge.

## Atualização de 25/10/2026

- A tela de aparelhos oculta cômodos sem dispositivos cadastrados.
- O seletor não apresenta mais a opção genérica "Outro local"; locais personalizados continuam disponíveis.
- O ícone foi simplificado para um único favo de mel marrom em fundo transparente.
- O histórico detalhado das alterações está em `README_CORRECOES.md`.



## Integração com a API do backend (28/10/2026)

O app passou a usar a API REST do projeto `BackEnd_Fhive_Web`, em vez de validar login e cadastrar dispositivos/rotinas apenas na memória.

### Configurar e executar

1. Inicie o backend seguindo o README da pasta `BackEnd_Fhive_Web`, configure seu arquivo `.env` e confirme que o MongoDB está acessível. No Windows/PowerShell, copie o modelo com `Copy-Item .env.example .env`.
2. Na pasta deste projeto mobile, rode `flutter pub get`.
3. Execute no emulador Android (a URL padrão é `http://10.0.2.2:3000`):

   ```bash
   flutter run
   ```

4. Para celular físico, informe o IP do computador na rede local; para outro servidor, informe a URL publicada:

   ```bash
   flutter run --dart-define=FHIVE_API_BASE_URL=http://192.168.0.10:3000
   ```

   Substitua `192.168.0.10` pelo IP real do computador. O celular e computador devem conseguir se comunicar pela rede, e o firewall deve liberar a porta do backend. Use HTTPS fora do desenvolvimento local.

### Chamadas conectadas

- **Conta:** iniciar cadastro, confirmar código de e-mail, login JWT, consultar/atualizar perfil, alterar senha e recuperar senha por código.
- **Aparelhos:** listar, cadastrar, consultar, excluir e buscar telemetria. A interface mantém o `deviceId` do hardware separado do `id` interno do registro no MongoDB.
- **Rotinas:** listar, criar, ativar/desativar e excluir rotinas.
- **Equipes:** camada de API criada para listar/criar/excluir equipes; uma tela de equipes ainda não foi incluída.
- **Rede:** cliente HTTP compartilhado em `lib/core/network/api_client.dart`, tratamento uniforme de erros HTTP, timeout e cabeçalho `Authorization: Bearer`.

### O que ainda não é persistido/automatizado

- O token fica em memória e é removido ao sair do app; não há persistência segura de sessão entre reinicializações.
- Favoritos, preferências e atalhos continuam locais, pois a API atual não oferece endpoints para eles.
- Os controles da TV/ar-condicionado não enviam comandos ao hardware. A API atual também não tem endpoint de execução de rotina; o app informa essa limitação em vez de confirmar uma execução inexistente.
- Os gráficos consultam telemetria real quando existe. Na ausência de leituras MQTT, parte dos indicadores continua demonstrativa e está sinalizada na tela.
- Cadastro e recuperação de senha dependem do SMTP configurado no backend. Sem serviço de e-mail funcional, o código de confirmação/recuperação não chegará ao usuário.

### Testes

Os testes de widget usam um cliente HTTP simulado, para verificar os fluxos sem depender de MongoDB, SMTP ou um backend rodando. Antes de entregar/publicar, execute localmente:

```bash
dart format lib test
flutter pub get
flutter analyze
flutter test
flutter run
```

A análise e execução Flutter não foram realizadas neste pacote porque o SDK Flutter/Dart não estava disponível no ambiente de edição.
