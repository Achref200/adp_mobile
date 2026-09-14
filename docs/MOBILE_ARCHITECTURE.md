# Flutter architecture

ADP uses a feature-first Clean Architecture structure with MVC responsibilities:

```
lib/features/<feature>/
  data/          API data sources, DTO mapping, repository implementations
  domain/        entities, repository contracts, use cases/business rules
  presentation/  views (pages/widgets), Cubits and immutable states
```

## MVC mapping

- **Model:** domain entities (`User`, `Membership`, `Project`, etc.) and repository contracts. Data implementations map HTTP JSON into those models.
- **View:** `presentation/*_page.dart` widgets. Views render a state only; they do not access HTTP, storage, or JSON.
- **Controller:** Cubits (`AuthCubit`, `ProjectsCubit`) own user intent, validation/loading/failure transitions and call domain/data abstractions.

`AppDependencies` is the single composition root. `ADP_USE_MOCK=true` wires deterministic mock repositories; setting it to `false` substitutes API repositories without changing a View or Cubit.

## State and storage

`AuthCubit` is the session notifier. It restores a session from Keychain/Android Keystore through `SecureSessionStore`, rotates a refresh token through the API, and emits immutable `AuthState` transitions. `BlocListener`/`BlocConsumer` owns navigation and other one-off side effects; `BlocBuilder` owns rendering. Tokens never enter widget state or preferences.

For each additional feature, follow `ProjectsCubit`: create a `FeatureState`, create a Cubit that depends only on a repository contract, inject it from `AppDependencies`, and render it using `BlocBuilder`/`BlocListener`.
