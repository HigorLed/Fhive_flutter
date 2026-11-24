# FHIVE — correções do pareamento Samsung IP Control

Este pacote parte do projeto `Fhive_flutter_Samsung_IP_Control` e corrige o fluxo de pareamento e vínculo da Samsung U8600F.

## O que foi ajustado

- O pedido `createAccessToken` usa o mesmo formato JSON-RPC do teste Node.js que funcionou na TV (`id: "1"`).
- A requisição HTTPS envia o corpo em bytes com `Content-Length` explícito.
- Erros HTTP da Samsung mantêm o status e o corpo de resposta, sem serem confundidos com erros do backend.
- O pareamento local e o vínculo no backend são tratados como duas etapas separadas.
- Depois que a TV autoriza e o token é salvo no armazenamento seguro, uma falha no backend não apaga o token.
- A tela oferece **Tentar vínculo novamente**, que repete somente o `PUT` do backend e não solicita outro token à TV.
- O `ApiClient` mantém o status HTTP e apresenta a mensagem retornada pelo backend.
- A lista de TVs usa `Material` como ancestral do `ListTile`, removendo a asserção de splash que apareceu no log do Galaxy.
- As versões Gradle/AGP/Kotlin foram mantidas na configuração usada para compilar no Galaxy: Gradle 9.5.0, AGP 9.3.1 e Kotlin 2.4.20.

## Executar no Galaxy

Na raiz do projeto:

```powershell
flutter pub get
flutter run -d ID_DO_CELULAR --dart-define=FHIVE_API_BASE_URL=http://IP_DO_NOTEBOOK:3000
```

O celular precisa estar na mesma rede Wi-Fi da TV para acessar a porta 1516.

## Como o pareamento agora se comporta

1. O Flutter valida/descobre a TV na rede.
2. O celular pede autorização à Samsung e salva o token no armazenamento seguro.
3. O Flutter envia ao backend somente `provedor`, `ip`, `nome` e `modelo`.
4. Se o backend recusar o vínculo, o token fica salvo. A tela apresenta **Tentar vínculo novamente** para repetir apenas a etapa 3.
5. Se a etapa 2 falhar, a tela informa que o erro veio da Samsung e mostra o HTTP/resposta, sem dizer que o vínculo do backend falhou.

Um novo token só substitui o token local anterior depois que a Samsung retorna um token válido. Se a Samsung rejeitar a criação, o token local anterior não é apagado.

## Backend necessário

O backend deve conter as alterações Samsung fornecidas separadamente para:

- `GET /dispositivos/:id/controle`
- `PUT /dispositivos/:id/controle`
- `DELETE /dispositivos/:id/controle`

E os campos opcionais em `Dispositivos`:

- `controleProvedor`
- `controleIp`
- `controleNome`
- `controleModelo`
- `controlePareadoEm`

O token Samsung **não** é enviado ao backend. O backend continua validando o JWT e a propriedade do dispositivo.

## Segurança

- O token da TV permanece em `flutter_secure_storage` no celular.
- Não copie tokens para o código, Git ou repositório.
- A conexão de teste aceita o certificado autoassinado da TV somente após validar que o IP é privado e guarda o fingerprint para as conexões seguintes. Antes de distribuir o aplicativo, reavalie a estratégia de confiança do certificado para produção.
