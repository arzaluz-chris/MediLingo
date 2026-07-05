package app.medilingo

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import app.medilingo.ui.MediLingoApp
import app.medilingo.ui.theme.MediLingoTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        val dependencies = (application as MediLingoApplication).dependencies
        setContent {
            MediLingoTheme {
                MediLingoApp(dependencies = dependencies)
            }
        }
    }
}
