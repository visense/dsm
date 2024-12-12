package com.example.dsmhelper.ui

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.dsmhelper.data.DsmApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.security.cert.X509Certificate
import java.util.concurrent.TimeUnit
import javax.net.ssl.*

private const val TAG = "LoginViewModel"

class LoginViewModel : ViewModel() {
    private val _uiState = MutableStateFlow<LoginUiState>(LoginUiState.Initial)
    val uiState: StateFlow<LoginUiState> = _uiState

    private var baseUrl: String = ""
    private var _api: DsmApi? = null
    val api: DsmApi? get() = _api
    
    private var _sid: String? = null
    val sid: String? get() = _sid

    fun updateBaseUrl(domain: String, port: String, isHttps: Boolean) {
        try {
            if (domain.isBlank() || port.isBlank()) {
                Log.e(TAG, "Domain or port is empty")
                _uiState.value = LoginUiState.Error("Please enter domain and port")
                return
            }

            baseUrl = "${if (isHttps) "https" else "http"}://$domain:$port/"
            Log.d(TAG, "Updating base URL to: $baseUrl")

            val loggingInterceptor = HttpLoggingInterceptor { message ->
                Log.d(TAG, "OkHttp: $message")
            }.apply {
                level = HttpLoggingInterceptor.Level.BODY
            }

            val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
                override fun checkClientTrusted(chain: Array<X509Certificate>, authType: String) {}
                override fun checkServerTrusted(chain: Array<X509Certificate>, authType: String) {}
                override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
            })

            val sslContext = SSLContext.getInstance("SSL")
            sslContext.init(null, trustAllCerts, java.security.SecureRandom())
            val sslSocketFactory = sslContext.socketFactory

            val client = OkHttpClient.Builder()
                .addInterceptor(loggingInterceptor)
                .connectTimeout(30, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .sslSocketFactory(sslSocketFactory, trustAllCerts[0] as X509TrustManager)
                .hostnameVerifier { _, _ -> true }
                .build()

            val retrofit = Retrofit.Builder()
                .baseUrl(baseUrl)
                .client(client)
                .addConverterFactory(GsonConverterFactory.create())
                .build()

            _api = retrofit.create(DsmApi::class.java)
            Log.d(TAG, "API instance created successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error updating base URL", e)
            _uiState.value = LoginUiState.Error("Failed to initialize connection: ${e.message}")
        }
    }

    fun login(username: String, password: String) {
        viewModelScope.launch {
            try {
                if (username.isBlank() || password.isBlank()) {
                    Log.e(TAG, "Username or password is empty")
                    _uiState.value = LoginUiState.Error("Please enter username and password")
                    return@launch
                }

                Log.d(TAG, "Attempting login for user: $username")
                _uiState.value = LoginUiState.Loading
                
                val api = _api
                if (api == null) {
                    Log.e(TAG, "API instance is null")
                    _uiState.value = LoginUiState.Error("Connection not initialized. Please check your server settings.")
                    return@launch
                }

                val response = try {
                    api.login(account = username, passwd = password)
                } catch (e: Exception) {
                    Log.e(TAG, "Network error during login", e)
                    _uiState.value = LoginUiState.Error("Network error: ${e.message}")
                    return@launch
                }

                Log.d(TAG, "Login response code: ${response.code()}")
                Log.d(TAG, "Login response body: ${response.body()}")
                
                val errorBody = response.errorBody()?.string()
                if (errorBody != null) {
                    Log.e(TAG, "Login error body: $errorBody")
                    _uiState.value = LoginUiState.Error("Server error: $errorBody")
                    return@launch
                }

                if (!response.isSuccessful) {
                    Log.e(TAG, "Login failed with code: ${response.code()}")
                    _uiState.value = LoginUiState.Error("Login failed with code: ${response.code()}")
                    return@launch
                }

                val body = response.body()
                if (body == null) {
                    Log.e(TAG, "Login response body is null")
                    _uiState.value = LoginUiState.Error("Empty response from server")
                    return@launch
                }

                if (!body.success) {
                    Log.e(TAG, "Login not successful: ${body.error}")
                    _uiState.value = LoginUiState.Error("Login failed: ${body.error?.code}")
                    return@launch
                }

                if (body.data?.sid == null) {
                    Log.e(TAG, "Session ID is null")
                    _uiState.value = LoginUiState.Error("Invalid session ID")
                    return@launch
                }

                Log.d(TAG, "Login successful")
                _sid = body.data.sid
                Log.d(TAG, "Session ID: $_sid")
                _uiState.value = LoginUiState.Success
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error during login", e)
                _uiState.value = LoginUiState.Error("Unexpected error: ${e.message}")
            }
        }
    }
}

sealed class LoginUiState {
    data object Initial : LoginUiState()
    data object Loading : LoginUiState()
    data object Success : LoginUiState()
    data class Error(val message: String) : LoginUiState()
}
