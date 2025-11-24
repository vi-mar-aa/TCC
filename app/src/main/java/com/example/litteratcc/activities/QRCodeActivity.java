package com.example.litteratcc.activities;

import static android.view.View.GONE;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.litteratcc.R;
import com.example.litteratcc.modelo.Midia;
import com.example.litteratcc.service.ApiService;
import com.example.litteratcc.request.MidiaRequest;
import com.example.litteratcc.service.RetrofitManager;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.mlkit.vision.barcode.BarcodeScanner;
import com.google.mlkit.vision.barcode.BarcodeScanning;
import com.google.mlkit.vision.barcode.common.Barcode;
import com.google.mlkit.vision.common.InputImage;

import java.util.List;
import java.util.Objects;
import java.util.concurrent.ExecutionException;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class QRCodeActivity extends AppCompatActivity {
    private PreviewView previewView;
    LinearLayout btnAcessar;
    ApiService apiService;
    TextView tvNomeMidia, tvAutorMidia;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qrcode);

        findViewById();

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)//verifica se o app tem permissão de acesso a câmera
                == PackageManager.PERMISSION_GRANTED) {
            startCamera();
        } else {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.CAMERA},
                    1001);//1001 é uma etiqueta que fica na resposta do user
        }

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    private void findViewById() {
        previewView = findViewById(R.id.previewView);
        btnAcessar = findViewById(R.id.btnAcessar);
        tvNomeMidia = findViewById(R.id.tvTit_Midia);
        tvAutorMidia = findViewById(R.id.tvTit_Autor);
        btnAcessar.setVisibility(GONE);
        apiService = RetrofitManager.getApiService();

    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        if (requestCode == 1001) {//se for da camera faz isso
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {//se tiver resposta e for sim
                startCamera();
            } else {
                Toast.makeText(this, "ATENÇÃO: Permissão da câmera é necessária para escanear QR Codes!", Toast.LENGTH_LONG).show();
            }
        }
    }
    private void startCamera() {
        ListenableFuture<ProcessCameraProvider> cameraProviderFuture =
                ProcessCameraProvider.getInstance(this);//pega a camera do cel

        cameraProviderFuture.addListener(() -> {//quando a camera estiver pronta
            try {
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();//tem acesso
                //camera aparece na tela
                Preview preview = new Preview.Builder().build();
                preview.setSurfaceProvider(previewView.getSurfaceProvider());
                //olha a imagem
                ImageAnalysis imageAnalysis =
                        new ImageAnalysis.Builder()
                                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)//resultado mais atual só
                                .build();
                //analisa a foto tirada em cada milisegundo
                imageAnalysis.setAnalyzer(ContextCompat.getMainExecutor(this), imageProxy -> {
                    @SuppressLint("UnsafeOptInUsageError")
                    InputImage inputImage = InputImage.fromMediaImage(//ml kit só entende inputtype
                            Objects.requireNonNull(imageProxy.getImage()),
                            imageProxy.getImageInfo().getRotationDegrees()//foto tirada em cada milisegundo
                    );

                    BarcodeScanner scanner = BarcodeScanning.getClient();//entende o qr

                    scanner.process(inputImage)//tenta ler o qr
                            .addOnSuccessListener(barcodes -> {
                                for (Barcode barcode : barcodes) {//p/ cada qr achado
                                    String qrValue = Objects.requireNonNull(barcode.getRawValue());

                                    if (qrValue.matches("\\d+")) { // só números
                                        int idMidia = Integer.parseInt(qrValue);
                                        if(idMidia != 0){
                                            getMidiaInfo(idMidia);
                                        }
                                    } else if (qrValue.startsWith("http://") || qrValue.startsWith("https://")) {
                                        // se for uma URL, abre no navegador
                                        Intent intent = new Intent(Intent.ACTION_VIEW);
                                        intent.setData(android.net.Uri.parse(qrValue));
                                        startActivity(intent);
                                    } else {
                                        Toast.makeText(this, "QR Code não reconhecido!", Toast.LENGTH_SHORT).show();
                                    }
                                }

                            })
                            .addOnCompleteListener(task -> imageProxy.close());//fecha imagem
                });
                //fica no fim pq tem que receber tudo pronto
                CameraSelector cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA;//usa a camera traseira
                cameraProvider.unbindAll();//gerencia, desconecta tudo q usa a câmera
                cameraProvider.bindToLifecycle(this, cameraSelector, preview, imageAnalysis);//camera ativa quando a activity ativa

            } catch (ExecutionException | InterruptedException e) {
                e.printStackTrace();
            }
        }, ContextCompat.getMainExecutor(this));//tem que rodar na thread principal, thread é processo/ação
    }

    private void getMidiaInfo(int idMidia) {
        MidiaRequest request = new MidiaRequest(idMidia);
        apiService.getMidiaById(request).enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<List<Midia>> call, @NonNull Response<List<Midia>> response) {
                if (response.isSuccessful() && response.body() != null && !response.body().isEmpty()) {
                    Midia midiaCarregada = response.body().get(0);
                    btnAcessar.setVisibility(View.VISIBLE);
                    tvNomeMidia.setText(midiaCarregada.getTitulo());
                    tvAutorMidia.setText(midiaCarregada.getAutor());
                    btnAcessar.setOnClickListener(v -> abrirPagMidia(idMidia));
                } else {
                    Toast.makeText(QRCodeActivity.this, "ERROR: Falha ao acessar mídia!", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(@NonNull Call<List<Midia>> call, @NonNull Throwable t) {
                Toast.makeText(QRCodeActivity.this, "ERROR: Falha ao acessar mídia!", Toast.LENGTH_SHORT).show();
            }
        });

    }
    private void abrirPagMidia(int idMidia) {
        Intent intent = new Intent(QRCodeActivity.this, MidiaActivity.class);
        intent.putExtra("idMidia", idMidia);
        startActivity(intent);
    }
}
