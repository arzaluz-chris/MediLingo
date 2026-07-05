package app.medilingo.ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import app.medilingo.AppDependencies
import app.medilingo.feature.auth.AuthScreen
import app.medilingo.feature.home.HomeScreen

// Root composable: routes between auth and the authenticated home shell.
@Composable
fun MediLingoApp(dependencies: AppDependencies) {
    var authenticated by remember { mutableStateOf(dependencies.authRepository.isAuthenticated) }

    if (authenticated) {
        HomeScreen(onSignOut = { authenticated = false }, dependencies = dependencies)
    } else {
        AuthScreen(dependencies = dependencies, onAuthenticated = { authenticated = true })
    }
}
