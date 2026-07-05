package app.medilingo.feature.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.medilingo.data.AuthRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
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

    private val _state = MutableStateFlow(UiState())
    val state: StateFlow<UiState> = _state.asStateFlow()

    fun onEmailChange(value: String) { _state.update { it.copy(email = value) } }
    fun onPasswordChange(value: String) { _state.update { it.copy(password = value) } }
    fun toggleMode() { _state.update { it.copy(isSignUp = !it.isSignUp, error = null) } }

    fun submit(onSuccess: () -> Unit) {
        val s = _state.value
        _state.update { it.copy(isLoading = true, error = null) }
        viewModelScope.launch {
            try {
                if (s.isSignUp) auth.signUp(s.email, s.password)
                else auth.signIn(s.email, s.password)
                _state.update { it.copy(isLoading = false) }
                onSuccess()
            } catch (e: Exception) {
                _state.update { it.copy(isLoading = false, error = "Credenciales incorrectas.") }
            }
        }
    }
}
