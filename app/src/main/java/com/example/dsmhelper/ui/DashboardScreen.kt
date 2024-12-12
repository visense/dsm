package com.example.dsmhelper.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.Alignment
import androidx.compose.ui.unit.dp
import kotlin.math.roundToInt

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(dashboardViewModel: DashboardViewModel) {
    val uiState by dashboardViewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        when (uiState) {
            is DashboardUiState.Loading -> {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }
            is DashboardUiState.Error -> {
                val error = (uiState as DashboardUiState.Error).message
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Text(
                            text = "Error: $error",
                            style = MaterialTheme.typography.bodyLarge,
                            color = MaterialTheme.colorScheme.error
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Button(
                            onClick = { dashboardViewModel.fetchSystemInfo() }
                        ) {
                            Text("Retry")
                        }
                    }
                }
            }
            is DashboardUiState.Success -> {
                val response = (uiState as DashboardUiState.Success).data
                if (response.success && response.data != null) {
                    Text("System Information", style = MaterialTheme.typography.headlineMedium)
                    Spacer(modifier = Modifier.height(16.dp))
                    
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 8.dp)
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text("CPU Usage", style = MaterialTheme.typography.titleMedium)
                            Text("Total Load: ${response.data.cpu.total_load.roundToInt()}%")
                            Text("User Load: ${response.data.cpu.user_load.roundToInt()}%")
                            Text("System Load: ${response.data.cpu.system_load.roundToInt()}%")
                            if (response.data.cpu.other_load > 0) {
                                Text("Other Load: ${response.data.cpu.other_load.roundToInt()}%")
                            }
                        }
                    }

                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 8.dp)
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text("Memory Usage", style = MaterialTheme.typography.titleMedium)
                            Text("Total: ${response.data.memory.total / 1024 / 1024} MB")
                            Text("Used: ${response.data.memory.used / 1024 / 1024} MB")
                            Text("Available: ${response.data.memory.available / 1024 / 1024} MB")
                            Text("Buffer: ${response.data.memory.buffer / 1024 / 1024} MB")
                            Text("Cached: ${response.data.memory.cached / 1024 / 1024} MB")
                            Text("Available Swap: ${response.data.memory.available_swap / 1024 / 1024} MB")
                        }
                    }

                    if (response.data.disk.isNotEmpty()) {
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 8.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp)) {
                                Text("Disk Usage", style = MaterialTheme.typography.titleMedium)
                                response.data.disk.forEach { (_, disk) ->
                                    Text("Device: ${disk.displayName} (${disk.device})")
                                    Text("Status: ${disk.status}")
                                    Text("Total: ${disk.total / 1024 / 1024} MB")
                                    Text("Used: ${disk.used / 1024 / 1024} MB")
                                    Text("Free: ${(disk.total - disk.used) / 1024 / 1024} MB")
                                    Spacer(modifier = Modifier.height(8.dp))
                                }
                            }
                        }
                    }
                } else {
                    Text(
                        text = "Error: ${response.error?.code}",
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.error
                    )
                }
            }
        }
    }
}
