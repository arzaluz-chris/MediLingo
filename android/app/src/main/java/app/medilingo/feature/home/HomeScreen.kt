package app.medilingo.feature.home

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import app.medilingo.AppDependencies
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

// Post-auth shell placeholder (feature parity with iOS lands incrementally).
@Composable
fun HomeScreen(onSignOut: () -> Unit, dependencies: AppDependencies) {
    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text("¡Bienvenido a MediLingo!", style = MaterialTheme.typography.headlineMedium)
        Text("Las lecciones aparecerán aquí.", style = MaterialTheme.typography.bodyMedium)
        OutlinedButton(
            onClick = {
                CoroutineScope(Dispatchers.Main).launch {
                    dependencies.authRepository.signOut()
                    onSignOut()
                }
            },
            modifier = Modifier.padding(top = 24.dp),
        ) { Text("Cerrar sesión") }
    }
}
