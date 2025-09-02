package com.example.litteratcc.service;
import android.content.Context;
import android.content.SharedPreferences;
import androidx.security.crypto.EncryptedSharedPreferences; //ajuda a criptografar os dados armazenados
import androidx.security.crypto.MasterKeys;//ajuda a criar chaves de criptografia seguras
public class ClienteSessionManager {

    private static final String PREFS_NAME = "secure_prefs";
    private SharedPreferences sharedPreferences;

    public ClienteSessionManager(Context context) {
        try {
            String chave = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC);
            sharedPreferences = EncryptedSharedPreferences.create(
                    PREFS_NAME,
                    chave,
                    context,
                    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
            );
        } catch (Exception e) {
            e.printStackTrace();
            // Trate o erro, talvez usando SharedPreferences normal como fallback
        }
    }

    public void salvaCliente(int idCliente, String email, String nome) {
        if (sharedPreferences == null) return; // prevenir crash
        sharedPreferences.edit()
                .putInt("idCliente", idCliente)
                .putString("email", email)
                .putString("nome", nome)
                .apply();
    }

    public int getIdCliente() {
        return sharedPreferences.getInt("idCliente", -1); // retorna -1 se não existir
    }


    public String getEmail() {
        if (sharedPreferences == null) return null;
        return sharedPreferences.getString("email", null);
    }

    public String getNome() {
        if (sharedPreferences == null) return null;
        return sharedPreferences.getString("nome", null);
    }

    public void clearSession() {
        if (sharedPreferences == null) return;
        sharedPreferences.edit().clear().apply();
    }
}
