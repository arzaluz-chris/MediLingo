package app.medilingo.feature.auth

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import app.medilingo.AppDependencies

// Sign-in / sign-up screen (mirrors iOS AuthView).
@Composable
fun AuthScreen(dependencies: AppDependencies, onAuthenticated: () -> Unit) {
    val viewModel = remember { AuthViewModel(dependencies.authRepository) }
    val state by viewModel.state.collectAsState()
    val canSubmit = state.email.contains("@") && state.password.length >= 6 && !state.isLoading

    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text("MediLingo", style = androidx.compose.material3.MaterialTheme.typography.headlineLarge)
        Text("Inglés médico para profesionales de la salud",
            style = androidx.compose.material3.MaterialTheme.typography.bodyMedium)

        OutlinedTextField(
            value = state.email,
            onValueChange = { viewModel.onEmailChange(it) },
            label = { Text("Correo") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
            modifier = Modifier.padding(top = 24.dp),
        )
        OutlinedTextField(
            value = state.password,
            onValueChange = { viewModel.onPasswordChange(it) },
            label = { Text("Contraseña") },
            visualTransformation = PasswordVisualTransformation(),
            modifier = Modifier.padding(top = 12.dp),
        )
        state.error?.let { Text(it, modifier = Modifier.padding(top = 8.dp)) }

        Button(
            onClick = { viewModel.submit(onAuthenticated) },
            enabled = canSubmit,
            modifier = Modifier.padding(top = 16.dp).width(280.dp),
        ) {
            if (state.isLoading) CircularProgressIndicator()
            else Text(if (state.isSignUp) "Crear cuenta" else "Entrar")
        }
        TextButton(onClick = { viewModel.toggleMode() }) {
            Text(if (state.isSignUp) "¿Ya tienes cuenta? Entra" else "¿No tienes cuenta? Regístrate")
        }
    }
}
