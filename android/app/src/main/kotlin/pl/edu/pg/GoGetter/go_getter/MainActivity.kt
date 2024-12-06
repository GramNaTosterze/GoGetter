package pl.edu.pg.GoGetter.go_getter

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.PlayersClient
import com.google.android.gms.games.PlayGamesSdk
import android.util.Log
import com.google.android.gms.games.SnapshotsClient
import com.google.android.gms.games.snapshot.Snapshot
import com.google.android.gms.games.snapshot.SnapshotMetadataChange
import com.google.android.gms.tasks.Task
import com.google.android.gms.drive.Drive
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignIn

class MainActivity : FlutterActivity() {
    private val CHANNEL = "play_games_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAuthenticated" -> checkAuthentication(result)
                "signIn" -> signIn(result)
                "getPlayerId" -> getPlayerId(result)
                "saveGame" -> saveGame(call, result)
                "loadGame" -> loadGame(result)
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
                val playerId = task.result.playerId
                Log.d("MainActivity", "Pobrane Player ID: $playerId")
                result.success(playerId)
            } else {
                val exception = task.exception
                Log.e("MainActivity", "Nie udało się pobrać Player ID", exception)
                result.error("ERROR", "Failed to get Player ID: ${exception?.message}", null)
            }
        }
    }

    private fun saveGame(call: MethodCall, result: MethodChannel.Result) {
        val data = call.argument<ByteArray>("data")
        if (data == null) {
            // Jeśli dane są null, zwróć błąd
            result.error("ERROR", "No data provided for saveGame", null)
            return
        }

        val snapshotClient = PlayGames.getSnapshotsClient(this)
        val snapshotName = "game_save"

        snapshotClient.open(snapshotName, true).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val openResult = task.result
                if (openResult == null) {
                    result.error("ERROR", "Open result is null", null)
                    return@addOnCompleteListener
                }

                val snapshot = openResult.data
                if (snapshot == null) {
                    result.error("ERROR", "No snapshot data returned", null)
                    return@addOnCompleteListener
                }

                snapshot.snapshotContents.writeBytes(data)

                val metadataChange = SnapshotMetadataChange.Builder()
                    .setDescription("Game progress")
                    .build()

                snapshotClient.commitAndClose(snapshot, metadataChange)
                    .addOnCompleteListener { commitTask ->
                        if (commitTask.isSuccessful) {
                            result.success(true)
                        } else {
                            result.error("ERROR", "Failed to commit snapshot", null)
                        }
                    }

            } else {
                result.error("ERROR", "Failed to open snapshot", null)
            }
        }
    }

    private fun loadGame(result: MethodChannel.Result) {
        val snapshotClient = PlayGames.getSnapshotsClient(this)
        val snapshotName = "game_save"

        snapshotClient.open(snapshotName, false).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val openResult = task.result
                if (openResult == null) {
                    result.error("ERROR", "Open result is null", null)
                    return@addOnCompleteListener
                }

                val snapshot = openResult.data
                if (snapshot == null) {
                    result.error("ERROR", "No snapshot data returned", null)
                    return@addOnCompleteListener
                }

                val data = snapshot.snapshotContents.readFully()
                // Po odczytaniu danych można zamknąć snapshot
                snapshotClient.discardAndClose(snapshot)
                result.success(data)

            } else {
                result.error("ERROR", "Failed to open snapshot", null)
            }
        }
    }
}
