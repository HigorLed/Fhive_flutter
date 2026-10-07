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
