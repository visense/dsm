package com.example.dsmhelper

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.dsmhelper.ui.DashboardScreen
import com.example.dsmhelper.ui.DashboardViewModel
import com.example.dsmhelper.ui.LoginScreen
import com.example.dsmhelper.ui.LoginUiState
import com.example.dsmhelper.ui.LoginViewModel
import com.example.dsmhelper.ui.theme.DSMHelperTheme
import kotlin.system.exitProcess

private const val TAG = "MainActivity"

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            Log.e(TAG, "Uncaught exception on thread ${thread.name}", throwable)
            // 在实际应用中，你可能想要将崩溃信息上报到服务器
            finishAffinity()
        }

        setContent {
            DSMHelperTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    var errorMessage by remember { mutableStateOf<String?>(null) }

                    if (errorMessage != null) {
                        AlertDialog(
                            onDismissRequest = { errorMessage = null },
                            title = { Text("Error") },
                            text = { Text(errorMessage!!) },
                            confirmButton = {
                                TextButton(onClick = { errorMessage = null }) {
                                    Text("OK")
                                }
                            }
                        )
                    }

                    val loginViewModel: LoginViewModel = viewModel()
                    val loginUiState by loginViewModel.uiState.collectAsState()

                    LaunchedEffect(loginUiState) {
                        when (loginUiState) {
                            is LoginUiState.Error -> {
                                errorMessage = (loginUiState as LoginUiState.Error).message
                            }
                            else -> {}
                        }
                    }

                    when (loginUiState) {
                        is LoginUiState.Success -> {
                            val dashboardViewModel = remember {
                                DashboardViewModel(loginViewModel).also { viewModel ->
                                    viewModel.setApi(loginViewModel.api)
                                }
                            }
                            DashboardScreen(dashboardViewModel)
                        }
                        else -> LoginScreen(loginViewModel)
                    }
                }
            }
        }
    }
}
