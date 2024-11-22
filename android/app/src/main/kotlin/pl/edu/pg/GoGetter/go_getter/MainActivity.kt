package pl.edu.pg.GoGetter.go_getter

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.GamesSignInClient
import com.google.android.gms.games.PlayersClient
import com.google.android.gms.games.PlayGamesSdk
import android.util.Log


class MainActivity : FlutterActivity() {
    private val CHANNEL = "play_games_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAuthenticated" -> checkAuthentication(result)
                "signIn" -> signIn(result)
                "getPlayerId" -> getPlayerId(result)
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        PlayGamesSdk.initialize(this)
    }

    private fun checkAuthentication(result: MethodChannel.Result) {
        val signInClient = PlayGames.getGamesSignInClient(this)
        signInClient.isAuthenticated.addOnCompleteListener { task ->
            val isAuthenticated = task.isSuccessful && task.result.isAuthenticated
            result.success(isAuthenticated)
        }
    }

    private fun signIn(result: MethodChannel.Result) {
        val signInClient = PlayGames.getGamesSignInClient(this)
        signInClient.signIn().addOnCompleteListener { task ->
            if (task.isSuccessful) {
                Log.d("MainActivity", "Logowanie zakończone sukcesem")
                result.success(true)
            } else {
                val exception = task.exception
                Log.e("MainActivity", "Logowanie nie powiodło się", exception)
                result.error("ERROR", "Logowanie nie powiodło się: ${exception?.message}", null)
            }
        }
    }


    private fun getPlayerId(result: MethodChannel.Result) {
        val playersClient: PlayersClient = PlayGames.getPlayersClient(this)
        playersClient.currentPlayer.addOnCompleteListener { task ->
            if (task.isSuccessful && task.result != null) {
                val playerId = task.result!!.playerId
                Log.d("MainActivity", "Pobrane Player ID: $playerId")
                result.success(playerId)
            } else {
                val exception = task.exception
                Log.e("MainActivity", "Nie udało się pobrać Player ID", exception)
                result.error("ERROR", "Failed to get Player ID: ${exception?.message}", null)
            }
        }
    }

}
