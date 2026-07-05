package app.medilingo.data

import io.github.jan.supabase.auth.auth
import io.github.jan.supabase.auth.providers.builtin.Email

// Email/password auth against Supabase (mirrors iOS SupabaseAuthService).
class AuthRepository {
    private val auth get() = Supabase.client.auth

    val isAuthenticated: Boolean
        get() = auth.currentSessionOrNull() != null

    suspend fun signIn(email: String, password: String) {
        auth.signInWith(Email) {
            this.email = email
            this.password = password
        }
    }

    suspend fun signUp(email: String, password: String) {
        auth.signUpWith(Email) {
            this.email = email
            this.password = password
        }
    }

    suspend fun signOut() {
        auth.signOut()
    }
}
