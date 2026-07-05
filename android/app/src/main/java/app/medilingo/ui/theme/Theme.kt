package app.medilingo.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

// MediLingo brand palette (mirrors iOS DesignSystem/Color+ML.swift).
val MlPrimary = Color(0xFF4F46E5)
val MlSecondary = Color(0xFF06B6D4)
val MlAccent = Color(0xFFF59E0B)
val MlBackground = Color(0xFF0F172A)
val MlSurface = Color(0xFF1E293B)
val MlTextPrimary = Color(0xFFF8FAFC)

private val DarkColors = darkColorScheme(
    primary = MlPrimary,
    secondary = MlSecondary,
    tertiary = MlAccent,
    background = MlBackground,
    surface = MlSurface,
    onBackground = MlTextPrimary,
    onSurface = MlTextPrimary,
)

private val LightColors = lightColorScheme(
    primary = MlPrimary,
    secondary = MlSecondary,
    tertiary = MlAccent,
)

@Composable
fun MediLingoTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    MaterialTheme(
        colorScheme = if (darkTheme) DarkColors else LightColors,
        content = content,
    )
}
