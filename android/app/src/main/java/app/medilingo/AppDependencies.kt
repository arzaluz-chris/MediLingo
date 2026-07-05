package app.medilingo

import app.medilingo.data.AuthRepository

// Minimal DI container (mirrors iOS AppDependencies). Grows with repositories
// as features are ported from iOS.
class AppDependencies {
    val authRepository: AuthRepository = AuthRepository()
}
