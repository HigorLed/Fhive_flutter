# Organização do lib — Fhive

A aplicação segue organização por funcionalidade (feature-first).

```text
lib/
├── main.dart
├── core/
│   └── theme/
│       └── theme.dart
├── shared/
│   └── widgets/
│       ├── barra_navegacao.dart
│       ├── cabecalho_pagina.dart   (cabeçalho, título de seção, cartão e botão voltar)
│       └── logo_fhive.dart
└── features/
    ├── auth/
    │   └── presentation/
    │       ├── tela_inicial.dart
    │       ├── entrar.dart
    │       └── cadastrar.dart
    ├── home/
    ├── devices/
    ├── analytics/
    ├── routines/
    ├── settings/
    └── onboarding/
```

## Fluxo de autenticação

```text
Tela Inicial
   ├── Entrar → Login → Home
   └── Criar Conta → Cadastro → Login → Home
```

A tela inicial é a rota `/inicio`. A Home permanece em `/home`.

## Design system

Todo o visual vem de `core/theme/theme.dart`: `AppColors`, `AppTextStyles`,
`AppRadius`, `AppSpacing`, `AppShadows` e o `AppTheme` (botões, campos, chips,
diálogos, AppBar, etc.). As telas **não** devem declarar cores (`Color(0x...)`),
tamanhos de fonte ou raios fixos; usem os tokens e os widgets de
`shared/widgets/cabecalho_pagina.dart`.

As novas telas devem ser criadas dentro de `lib/features/`.
