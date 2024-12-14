package pl.edu.pg.GoGetter.go_getter

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.PlayersClient
import com.google.android.gms.games.SnapshotsClient
import com.google.android.gms.games.LeaderboardsClient
import com.google.android.gms.games.snapshot.Snapshot
import com.google.android.gms.games.snapshot.SnapshotMetadataChange
import android.util.Log
import io.flutter.plugin.common.MethodCall

class MainActivity : FlutterActivity() {
    private val CHANNEL = "play_games_service"
    private val RC_LEADERBOARD_UI = 9004

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAuthenticated" -> checkAuthentication(result)
                "signIn" -> signIn(result)
                "getPlayerId" -> getPlayerId(result)
                "saveGame" -> saveGame(call, result)
                "loadGame" -> loadGame(result)
                "submitScore" -> submitScore(call, result)
                "showLeaderboard" -> showLeaderboard(call, result)
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
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
                result.success(true)
            } else {
                val exception = task.exception
                result.error("ERROR", "Sign-in failed: ${exception?.message}", null)
            }
        }
    }

    private fun getPlayerId(result: MethodChannel.Result) {
        val playersClient: PlayersClient = PlayGames.getPlayersClient(this)
        playersClient.currentPlayer.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val playerId = task.result?.playerId
                result.success(playerId)
            } else {
                result.error("ERROR", "Failed to get Player ID", null)
            }
        }
    }

    private fun saveGame(call: MethodCall, result: MethodChannel.Result) {
        val data = call.argument<ByteArray>("data")
        if (data == null) {
            result.error("ERROR", "No data provided for saveGame", null)
            return
        }

        val snapshotClient: SnapshotsClient = PlayGames.getSnapshotsClient(this)
        val snapshotName = "game_save"

        snapshotClient.open(snapshotName, true).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val snapshot = task.result?.data
                if (snapshot != null) {
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
                    result.error("ERROR", "No snapshot data returned", null)
                }
            } else {
                result.error("ERROR", "Failed to open snapshot", null)
            }
        }
    }

    private fun loadGame(result: MethodChannel.Result) {
        val snapshotClient: SnapshotsClient = PlayGames.getSnapshotsClient(this)
        val snapshotName = "game_save"

        snapshotClient.open(snapshotName, false).addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val snapshot = task.result?.data
                if (snapshot != null) {
                    val data = snapshot.snapshotContents.readFully()
                    snapshotClient.discardAndClose(snapshot)
                    result.success(data)
                } else {
                    result.error("ERROR", "No snapshot data returned", null)
                }
            } else {
                result.error("ERROR", "Failed to open snapshot", null)
            }
        }
    }

    private fun submitScore(call: MethodCall, result: MethodChannel.Result) {
        val leaderboardId = call.argument<String>("leaderboardId")
        val score = call.argument<Int>("score") ?: 0

        if (leaderboardId == null) {
            result.error("ERROR", "No leaderboardId provided", null)
            return
        }

        val leaderboardsClient: LeaderboardsClient = PlayGames.getLeaderboardsClient(this)
        leaderboardsClient.submitScore(leaderboardId, score.toLong())
        result.success(null)
    }

    private fun showLeaderboard(call: MethodCall, result: MethodChannel.Result) {
        val leaderboardId = call.argument<String>("leaderboardId")
        if (leaderboardId == null) {
            result.error("ERROR", "No leaderboardId provided", null)
            return
        }

        val leaderboardsClient: LeaderboardsClient = PlayGames.getLeaderboardsClient(this)
        leaderboardsClient.getLeaderboardIntent(leaderboardId)
            .addOnSuccessListener { intent ->
                startActivityForResult(intent, RC_LEADERBOARD_UI)
                result.success(null)
            }
            .addOnFailureListener { e ->
                result.error("ERROR", "Failed to show leaderboard: ${e.message}", null)
            }
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
    }
}