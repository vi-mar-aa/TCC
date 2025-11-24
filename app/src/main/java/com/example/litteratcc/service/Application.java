package com.example.litteratcc.service;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.PopupWindow;

import androidx.appcompat.app.AppCompatDelegate;

import com.example.litteratcc.R;
import com.example.litteratcc.activities.AcervoActivity;
import com.example.litteratcc.activities.DesejosActivity;
import com.example.litteratcc.activities.EmprestimoActivity;
import com.example.litteratcc.activities.MainActivity;
import com.example.litteratcc.activities.ConfiguracoesActivity;
import com.example.litteratcc.activities.QRCodeActivity;
import com.example.litteratcc.activities.ReservaActivity;

public class Application extends android.app.Application {

    @Override
    public void onCreate() {
        super.onCreate();

        SharedPreferences contraste = getSharedPreferences("modo_design", MODE_PRIVATE);//mode_private é que só o cel acessa isso,
        boolean modoEscuro = contraste.getBoolean("modo_escuro", false);//valor padrão é falso pra modo escuro

        if(modoEscuro) {//se o modo escuro for selecionado, se for true
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
        } else {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
        }


    }

}
