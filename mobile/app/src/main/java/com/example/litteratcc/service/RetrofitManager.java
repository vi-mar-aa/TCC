package com.example.litteratcc.service;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
public class RetrofitManager {
    private static final String BASE_URL = "https://4b1ebf6f8090.ngrok-free.app/";

    private static Retrofit retrofit = null;
    private static ApiService apiService = null;

    public static String getUrl() {
        //remove a barra final
        if (BASE_URL.endsWith("/")) {
            return BASE_URL.substring(0, BASE_URL.length() - 1);
        }
        return BASE_URL;
    }

    public static ApiService getApiService() {
        if (apiService == null) {
            retrofit = new Retrofit.Builder()
                    .baseUrl(BASE_URL)
                    .addConverterFactory(GsonConverterFactory.create())
                    .build();
            apiService = retrofit.create(ApiService.class);
        }
        return apiService;
    }
}
