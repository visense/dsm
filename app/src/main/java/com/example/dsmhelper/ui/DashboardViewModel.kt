package com.example.dsmhelper.ui

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.dsmhelper.data.DsmApi
import com.example.dsmhelper.data.SystemData
import com.example.dsmhelper.data.SystemInfoResponse
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

private const val TAG = "DashboardViewModel"

class DashboardViewModel(private val loginViewModel: LoginViewModel) : ViewModel() {
    private val _uiState = MutableStateFlow<DashboardUiState>(DashboardUiState.Loading)
    val uiState: StateFlow<DashboardUiState> = _uiState

    private var pollingJob: Job? = null
    private var api: DsmApi? = null

    init {
        setApi(loginViewModel.api)
    }

    fun setApi(dsmApi: DsmApi?) {
        api = dsmApi
        if (api != null) {
            startPolling()
        } else {
            Log.e(TAG, "API instance is null in setApi")
            _uiState.value = DashboardUiState.Error("API not initialized")
        }
    }

    fun fetchSystemInfo() {
        viewModelScope.launch {
            try {
                withContext(Dispatchers.IO) {
                    val currentApi = api ?: loginViewModel.api
                    if (currentApi == null) {
                        Log.e(TAG, "API instance is null")
                        _uiState.value = DashboardUiState.Error("API not initialized")
                        return@withContext
                    }

                    Log.d(TAG, "Starting to fetch system info")
                    val sid = loginViewModel.sid
                    if (sid == null) {
                        Log.e(TAG, "Session ID is null")
                        _uiState.value = DashboardUiState.Error("Not logged in")
                        return@withContext
                    }
                    Log.d(TAG, "Making system info request with sid: $sid")
                    
                    val response = try {
                        currentApi.getSystemInfo(sid = sid)
                    } catch (e: Exception) {
                        Log.e(TAG, "Network error during system info fetch", e)
                        _uiState.value = DashboardUiState.Error("Network error: ${e.message}")
                        return@withContext
                    }

                    Log.d(TAG, "System info response code: ${response.code()}")
                    Log.d(TAG, "System info response raw: $response")
                    
                    val body = response.body()
                    Log.d(TAG, "System info response body: $body")

                    val errorBody = response.errorBody()?.string()
                    if (errorBody != null) {
                        Log.e(TAG, "System info error body: $errorBody")
                        _uiState.value = DashboardUiState.Error("Server error: $errorBody")
                        return@withContext
                    }

                    if (!response.isSuccessful) {
                        Log.e(TAG, "System info request failed with code: ${response.code()}")
                        _uiState.value = DashboardUiState.Error("Request failed with code: ${response.code()}")
                        return@withContext
                    }

                    if (body == null) {
                        Log.e(TAG, "System info response body is null")
                        _uiState.value = DashboardUiState.Error("Empty response from server")
                        return@withContext
                    }

                    if (!body.success) {
                        Log.e(TAG, "System info request not successful: ${body.error}")
                        _uiState.value = DashboardUiState.Error("API error: ${body.error?.code}")
                        return@withContext
                    }

                    if (body.data == null) {
                        Log.e(TAG, "System info data is null")
                        _uiState.value = DashboardUiState.Error("No data in response")
                        return@withContext
                    }

                    Log.d(TAG, "Successfully fetched system info: ${body.data}")
                    _uiState.value = DashboardUiState.Success(body)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error fetching system info", e)
                _uiState.value = DashboardUiState.Error("Error: ${e.message}")
            }
        }
    }

    private fun startPolling() {
        pollingJob?.cancel()
        pollingJob = viewModelScope.launch {
            while (isActive) {
                fetchSystemInfo()
                delay(5000)
            }
        }
    }

    override fun onCleared() {
        super.onCleared()
        pollingJob?.cancel()
    }
}

sealed class DashboardUiState {
    data object Loading : DashboardUiState()
    data class Success(val data: SystemInfoResponse) : DashboardUiState()
    data class Error(val message: String) : DashboardUiState()
}
