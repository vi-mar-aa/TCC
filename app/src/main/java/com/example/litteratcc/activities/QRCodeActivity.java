package com.example.litteratcc.activities;

import android.os.Bundle;
import android.widget.FrameLayout;

import androidx.appcompat.app.AppCompatActivity;

import com.example.litteratcc.R;
import com.journeyapps.barcodescanner.DecoratedBarcodeView;


public class QRCodeActivity extends AppCompatActivity {

        private static final int PERMISSION_REQUEST_CAMERA = 1;
        DecoratedBarcodeView barcodeView;
        FrameLayout btnAcessar;

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_qrcode);

        /*    barcodeView = findViewById(R.id.barcodeView);
            btnAcessar = findViewById(R.id.btnAcessar);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, PERMISSION_REQUEST_CAMERA);
                } else {
                    iniciarLeitor();
                }
            } else {
                iniciarLeitor();
            }*/
        }}

     /*   private void iniciarLeitor() {
            barcodeView.setDecoderFactory(
                    new DefaultDecoderFactory(Collections.singletonList(BarcodeFormat.QR_CODE))
            );

            barcodeView.decodeContinuous(new BarcodeCallback() {
                @Override
                public void barcodeResult(BarcodeResult result) {
                    if (result.getText() != null) {
                        Toast.makeText(QRCodeActivity.this, "QR Code: " + result.getText(), Toast.LENGTH_LONG).show();
                        barcodeView.pause();
                    }
                }

                @Override
                public void possibleResultPoints(List<ResultPoint> resultPoints) {
                }
            });
        }

        @Override
        public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
            if (requestCode == PERMISSION_REQUEST_CAMERA && grantResults.length > 0
                    && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                iniciarLeitor();
            } else {
                Toast.makeText(this, "Permissão da câmera negada.", Toast.LENGTH_SHORT).show();
                finish();
            }
        }

        @Override
        protected void onResume() {
            super.onResume();
            if (barcodeView != null) barcodeView.resume();
        }

        @Override
        protected void onPause() {
            super.onPause();
            if (barcodeView != null) barcodeView.pause();
        }
    }*/
