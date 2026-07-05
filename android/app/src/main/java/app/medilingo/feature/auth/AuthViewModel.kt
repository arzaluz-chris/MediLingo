package app.medilingo.feature.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.medilingo.data.AuthRepository
import kotlinx.coroutines.launch

// Auth screen state (mirrors iOS AuthViewModel).
class AuthViewModel(private val auth: AuthRepository) : ViewModel() {

    data class UiState(
        val email: String = "",
        val password: String = "",
        val isSignUp: Boolean = false,
        val isLoading: Boolean = false,
        val error: String? = null,
    )

    var state = UiState()
        private set

    fun onEmailChange(value: String) { state = state.copy(email = value) }
    fun onPasswordChange(value: String) { state = state.copy(password = value) }
    fun toggleMode() { state = state.copy(isSignUp = !state.isSignUp, error = null) }

    val canSubmit: Boolean
        get() = state.email.contains("@") && state.password.length >= 6 && !state.isLoading

    fun submit(onSuccess: () -> Unit) {
        state = state.copy(isLoading = true, error = null)
        viewModelScope.launch {
            try {
                if (state.isSignUp) auth.signUp(state.email, state.password)
                else auth.signIn(state.email, state.password)
                state = state.copy(isLoading = false)
                onSuccess()
            } catch (e: Exception) {
                state = state.copy(isLoading = false, error = "Credenciales incorrectas.")
            }
        }
    }
}
