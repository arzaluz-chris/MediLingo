package app.medilingo

import android.app.Application

// Application entry. Holds the process-wide dependency container.
class MediLingoApplication : Application() {
    val dependencies: AppDependencies by lazy { AppDependencies() }

    companion object {
        lateinit var instance: MediLingoApplication
            private set
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
    }
}
