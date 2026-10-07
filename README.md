# Fhive — Mobile

Aplicativo Flutter do TCC para gerenciamento de dispositivos IoT, com interface
voltada para controle da casa inteligente, gráficos de consumo, rotinas e
configurações.

> Estado atual: protótipo de interface. Os dados de aparelhos, gráficos e
> rotinas são fictícios e o login/cadastro ainda não estão conectados a um
> servidor.

## Fluxo principal

```text
Tela Inicial
   ├── Entrar
   │     ↓
   │   Login
   │     ↓
   │   Home
   │
   └── Criar Conta
         ↓
      Cadastro
         ↓
       Login
         ↓
       Home
```

A aplicação inicia em `/inicio`. A Home continua disponível em `/home`.

## Telas e rotas

| Tela | Rota | Arquivo |
| --- | --- | --- |
| Tela Inicial | `/inicio` | `lib/features/auth/presentation/tela_inicial.dart` |
| Entrar | `/entrar` | `lib/features/auth/presentation/entrar.dart` |
| Cadastrar | `/cadastrar` | `lib/features/auth/presentation/cadastrar.dart` |
| Home | `/home` | `lib/features/home/presentation/home.dart` |
| Aparelhos | `/aparelhos` | `lib/features/devices/presentation/aparelhos.dart` |
| Gráficos | `/graficos` | `lib/features/analytics/presentation/graficos.dart` |
| Rotinas | `/rotinas` | `lib/features/routines/presentation/rotinas.dart` |
| Configurações | `/configuracoes` | `lib/features/settings/presentation/configuracoes.dart` |

## Organização do projeto

A pasta `lib` segue organização **feature-first**, separando as funcionalidades
do aplicativo em módulos.

```text
lib/
├── main.dart
├── core/
│   └── theme/
│       └── theme.dart
├── shared/
│   └── widgets/
│       └── barra_navegacao.dart
└── features/
    ├── auth/presentation/
    │   ├── tela_inicial.dart
    │   ├── entrar.dart
    │   └── cadastrar.dart
    ├── home/presentation/
    ├── devices/presentation/
    ├── analytics/presentation/
    ├── routines/presentation/
    ├── settings/presentation/
    └── onboarding/presentation/
```

A pasta `lib/widget/` foi mantida somente para compatibilidade com imports
antigos. Novas implementações devem ser feitas dentro de `lib/features/`,
`lib/core/` ou `lib/shared/`.

## Alterações e correções aplicadas

### 1. Nova tela inicial

A tela inicial foi adicionada como ponto de entrada do aplicativo e utiliza a
identidade visual atual do Fhive.

- Fundo em degradê da paleta do app.
- Logo Fhive centralizado.
- Botões `Entrar` e `Criar Conta`.
- Navegação para login e cadastro.
- Elementos visuais ampliados para melhorar a presença da marca e a área de
  toque dos botões.

### 2. Padronização de Entrar e Cadastrar

A tela de cadastro foi ajustada usando a tela de login como referência visual.
As duas telas compartilham o mesmo padrão de:

- fundo e elementos decorativos;
- painel principal;
- tipografia;
- espaçamentos;
- campos;
- botões;
- divisão por login social;
- navegação entre autenticação.

### 3. Indicador de força da senha

A tela de cadastro possui agora um indicador de força com quatro barras:

```text
1 barra  → Fraca
2 barras → Média
3 barras → Média
4 barras → Forte
```

A quarta barra só é preenchida quando todos os requisitos da senha estão
atendidos.

### 4. Requisitos da senha

Para uma senha ser considerada forte, ela precisa ter:

- pelo menos 6 caracteres;
- uma letra minúscula;
- uma letra maiúscula;
- um número;
- um caractere especial.

O caractere especial é obrigatório para concluir o cadastro.

Enquanto a senha está sendo digitada, a tela informa o que ainda precisa ser
atendido. O texto usado para orientar o usuário é:

```text
A senha precisa de: ...
```

Quando todos os requisitos são atendidos:

```text
Forte
Todos os requisitos foram atendidos.
```

### 5. Validação do cadastro

Foram mantidas validações para:

- nome obrigatório;
- e-mail obrigatório e em formato válido;
- senha com os requisitos mínimos;
- aceite dos termos do site.

### 6. Correção do teste de senha no login

O campo de senha usa `Digite sua senha` como placeholder e também pode usar o
mesmo texto como mensagem de validação. O teste foi ajustado para verificar
diretamente o `errorText` por meio do `InputDecorator`, evitando a ambiguidade
entre os dois textos.

### 7. Correções dos testes de navegação

Os testes foram ajustados para: 

- considerar a nova tela inicial;
- testar `Entrar` → Login → Home;
- testar `Criar Conta` → Cadastro;
- utilizar `ensureVisible` antes de tocar em botões que podem ficar abaixo da
  área visível no ambiente de teste;
- evitar o erro anterior causado por `scrollUntilVisible` apontando diretamente
  para `SingleChildScrollView`.

### 8. Flutter Analyze

Foram corrigidos os avisos informativos que existiam no projeto:

- interpolação desnecessária em `graficos.dart`;
- uso de `if` para elemento nulo em `configuracoes.dart`, utilizando a forma
  null-aware apropriada.

### 9. Correção de layout no cadastro

Os botões sociais do cadastro foram ajustados para evitar `RenderFlex overflow`
em telas ou ambientes de teste com largura menor.

### 10. Fluxo de autenticação

O cadastro, após concluir a validação, retorna para a tela de login. O login
segue para a Home. O fluxo atual é:

```text
/inicio → /entrar → /home
/inicio → /cadastrar → /entrar → /home
```

## Tecnologias

- Flutter / Dart
- Material Design
- `flutter_svg` para o logo
- Rotas nomeadas com `Navigator`
- Tema centralizado em `lib/core/theme/theme.dart`
- Fontes utilizadas pelo projeto: Arvo e Montserrat

## Como executar

```bash
flutter pub get
flutter run
```

Para verificar o projeto antes de enviar alterações:

```bash
dart format lib test
flutter analyze
flutter test
```

## Observações

O projeto continua sendo um protótipo de TCC. As ações de Google/Facebook e
a autenticação real ainda são apenas pontos de integração; a aplicação não
está conectada a um backend de autenticação neste estado.
