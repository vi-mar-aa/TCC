package com.example.litteratcc.service;

import android.content.Context;
import android.content.SharedPreferences;

import androidx.security.crypto.EncryptedSharedPreferences;
import androidx.security.crypto.MasterKeys;

import com.example.litteratcc.modelo.Cliente;

import java.io.IOException;
import java.security.GeneralSecurityException;

public class ClienteSessionManager {

    private static final String PREFS_NAME = "secure_prefs";
    private SharedPreferences sharedPreferences;

    public ClienteSessionManager(Context context) {
        try {
            String masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC);

            sharedPreferences = EncryptedSharedPreferences.create(
                    PREFS_NAME,
                    masterKeyAlias,
                    context,
                    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
            );
        } catch (GeneralSecurityException | IOException e) {
            // Se falhar, cai pro modo normal (evita crash)
            e.printStackTrace();
            sharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        }
    }

    // Salva dados do cliente logado
    public void salvaCliente(Integer idCliente,String email, String nome, String username, String cpf, String fotoPerfil, String telefone) {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt("idCliente", idCliente);
        editor.putString("email", email);
        editor.putString("nome", nome);
        editor.putString("username", username);
        editor.putString("cpf", cpf);
        editor.putString("imagemPerfil",fotoPerfil);
        editor.putString("telefone",telefone);
        editor.apply();
    }

    // Retorna o objeto Cliente
    public Cliente getDadosCliente() {
        Integer idCliente = sharedPreferences.getInt("idCliente", -1);
        String email = sharedPreferences.getString("email", "");
        String nome = sharedPreferences.getString("nome", "");
        String username = sharedPreferences.getString("username", "");
        String cpf = sharedPreferences.getString("cpf", "");
        String fotoPerfil = sharedPreferences.getString("imagemPerfil", "");
        String telefone = sharedPreferences.getString("telefone", "");

        Cliente cliente = new Cliente();
        cliente.setIdCliente(idCliente);
        cliente.setEmail(email);
        cliente.setNome(nome);
        cliente.setUsername(username);
        cliente.setFotoPerfil(fotoPerfil);
        cliente.setTelefone(telefone);
        return cliente;
    }

    // Remove todos os dados (logout)
    public void limpaCliente() {
        sharedPreferences.edit()
            .remove("idCliente")
            .remove("email")
            .remove("nome")
            .remove("username")
            .remove("cpf")
            .remove("imagemPerfil")
            .remove("telefone")
            .apply();
    }

    // Getters individuais


    public String getEmail() {
        return sharedPreferences.getString("email", null);
    }
    public String getFotoPerfil() {
        return sharedPreferences.getString("imagemPerfil", null);
    }

    public String getNome() {
        return sharedPreferences.getString("nome", null);
    }
    public String getUser() {
        return sharedPreferences.getString("username", null);
    }

    public boolean isClienteLogado() {
        return sharedPreferences.contains("email");
    }
    public Integer getIdCliente() {
        return sharedPreferences.getInt("idCliente", -1);
    }
    public String getTelefone() {
        return sharedPreferences.getString("telefone", null);
    }



}
