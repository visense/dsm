package com.example.dsmhelper.data

import com.google.gson.annotations.SerializedName
import retrofit2.Response
import retrofit2.http.*

interface DsmApi {
    @FormUrlEncoded
    @POST("webapi/auth.cgi")
    suspend fun login(
        @Field("api") api: String = "SYNO.API.Auth",
        @Field("version") version: Int = 3,
        @Field("method") method: String = "login",
        @Field("account") account: String,
        @Field("passwd") passwd: String,
        @Field("session") session: String = "FileStation",
        @Field("format") format: String = "cookie"
    ): Response<LoginResponse>

    @GET("webapi/entry.cgi")
    suspend fun getSystemInfo(
        @Query("api") api: String = "SYNO.Core.System.Utilization",
        @Query("version") version: Int = 1,
        @Query("method") method: String = "get",
        @Query("_sid") sid: String
    ): Response<SystemInfoResponse>
}

data class LoginResponse(
    @SerializedName("success")
    val success: Boolean,
    @SerializedName("data")
    val data: LoginData? = null,
    @SerializedName("error")
    val error: Error? = null
)

data class LoginData(
    @SerializedName("sid")
    val sid: String,
    @SerializedName("did")
    val did: String? = null,
    @SerializedName("synotoken")
    val synotoken: String? = null
)

data class Error(
    @SerializedName("code")
    val code: Int,
    @SerializedName("errors")
    val errors: List<ErrorDetail>? = null
)

data class ErrorDetail(
    @SerializedName("code")
    val code: Int,
    @SerializedName("message")
    val message: String? = null
)

data class SystemInfoResponse(
    @SerializedName("success")
    val success: Boolean,
    @SerializedName("data")
    val data: SystemData? = null,
    @SerializedName("error")
    val error: Error? = null
)

data class SystemData(
    @SerializedName("cpu")
    val cpu: CpuData,
    @SerializedName("memory")
    val memory: MemoryData,
    @SerializedName("disk")
    val disk: Map<String, DiskData>
)

data class CpuData(
    @SerializedName("system_load")
    val system_load: Double,
    @SerializedName("user_load")
    val user_load: Double,
    @SerializedName("other_load")
    val other_load: Double = 0.0
) {
    val total_load: Double get() = system_load + user_load + other_load
}

data class MemoryData(
    @SerializedName("memory_size")
    val total: Long,
    @SerializedName("real_usage")
    val used: Long,
    @SerializedName("available_swap")
    val available_swap: Long,
    @SerializedName("cached")
    val cached: Long,
    @SerializedName("available_real")
    val available: Long,
    @SerializedName("buffer")
    val buffer: Long
)

data class DiskData(
    @SerializedName("device")
    val device: String,
    @SerializedName("display_name")
    val displayName: String,
    @SerializedName("status")
    val status: String,
    @SerializedName("total")
    val total: Long,
    @SerializedName("used")
    val used: Long
)
