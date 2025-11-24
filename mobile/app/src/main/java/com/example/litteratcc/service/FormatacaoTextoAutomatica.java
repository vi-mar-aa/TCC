package com.example.litteratcc.service;

import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;

public class FormatacaoTextoAutomatica implements TextWatcher {
    private final EditText editText;
    private final String mask; // ex: "###.###.###-##" ou "(##) #####-####"
    private boolean isUpdating;
    private String old = "";

    public FormatacaoTextoAutomatica(EditText editText, String mask) {
        this.editText = editText;
        this.mask = mask;
    }

    private String onlyDigits(String s) {
        return s.replaceAll("[^0-9]", "");
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) { }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) { }

    @Override
    public void afterTextChanged(Editable s) {
        if (isUpdating) return;

        String digits = onlyDigits(s.toString());
        String formatted = applyMask(digits);
        isUpdating = true;
        editText.setText(formatted);
        // posiciona o cursor no final (ou tente calcular posição melhor se quiser)
        editText.setSelection(formatted.length());
        isUpdating = false;
    }

    private String applyMask(String digits) {
        StringBuilder out = new StringBuilder();
        int digitIndex = 0;

        for (int i = 0; i < mask.length(); i++) {
            char m = mask.charAt(i);
            if (m == '#') {
                if (digitIndex < digits.length()) {
                    out.append(digits.charAt(digitIndex));
                    digitIndex++;
                } else {
                    break;
                }
            } else {
                if (digitIndex < digits.length()) {
                    out.append(m);
                } else {
                    break;
                }
            }
        }
        return out.toString();
    }
}

