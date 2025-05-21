package com.example.tccteste;

import android.annotation.SuppressLint;
import android.os.StrictMode;

import java.sql.Connection;

public class Conexao {
    Connection con;

    @SuppressLint("NewApi")
    public Connection con() {
        String ip = "192.168.0.217", port = "1433", databasename = "CRUDAndroid", username = "sa", password = "littera";
        StrictMode.ThreadPolicy a = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(a);
        String ConnectURL = null;
        try {
            Class.forName("net.sourceforge.jtds.jdbc.Driver");
            ConnectURL = "jdbc:jtds:sqlserver://" + ip + ":" + port + "/" + databasename + ";user=" + username + ";password=" + password;
            con = java.sql.DriverManager.getConnection(ConnectURL);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}


