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
│       └── barra_navegacao.dart
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

## Compatibilidade

A pasta `lib/widget/` permanece como compatibilidade com imports antigos do projeto. As novas telas devem ser criadas dentro de `lib/features/`.
