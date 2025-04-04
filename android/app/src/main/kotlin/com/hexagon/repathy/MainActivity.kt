package com.hexagon.repathy
import android.os.Bundle
import android.util.Log
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.firebase.FirebaseApp
import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import com.google.firebase.appcheck.FirebaseAppCheck
import com.hexagon.repathy.BuildConfig.DEBUG
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {

    private val PLAY_SERVICES_RESOLUTION_REQUEST = 9000
    private val TAG = "MainActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "Android: onCreate called")

        if (checkGooglePlayServices()) {
            Log.d(TAG, "Android: Google Play Services available")
            FirebaseApp.initializeApp(this)

            if (DEBUG) {
                // Use DebugAppCheckProviderFactory in debug mode
                Log.d(TAG, "Android: Using DebugAppCheckProviderFactory")
                FirebaseAppCheck.getInstance().installAppCheckProviderFactory(DebugAppCheckProviderFactory.getInstance())
            } else {
                // Use PlayIntegrityAppCheckProviderFactory in release mode
                Log.d(TAG, "Android: Using PlayIntegrityAppCheckProviderFactory")
                FirebaseAppCheck.getInstance().installAppCheckProviderFactory(PlayIntegrityAppCheckProviderFactory.getInstance())
            }
        }
        Log.w(TAG, "Android: Google Play Services not available")
    }

    override fun onResume() {
        Log.d(TAG, "Android: onResume called")
        super.onResume()
        checkGooglePlayServices()
    }

    private fun checkGooglePlayServices(): Boolean {
        val googleApiAvailability = GoogleApiAvailability.getInstance()
        val resultCode = googleApiAvailability.isGooglePlayServicesAvailable(this)
        if (resultCode != ConnectionResult.SUCCESS) {
            Log.w(TAG, "Android: Google Play Services not available: $resultCode")
            if (googleApiAvailability.isUserResolvableError(resultCode)) {
                googleApiAvailability.getErrorDialog(this, resultCode, PLAY_SERVICES_RESOLUTION_REQUEST)
                    ?.show()
            } else {
                // Google Play services is not available, handle the error
                Log.e(TAG, "Android: Google Play Services not available and not resolvable")
                finish()
            }
            return false
        }
        Log.d(TAG, "Android: Google Play Services available")
        return true
    }
}
