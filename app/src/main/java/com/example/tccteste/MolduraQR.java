package com.example.tccteste;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

public class MolduraQR extends View {
        private Paint paint;
        private int cornerLength = 60;
        private int strokeWidth = 2;
        private int cornerRadius = 20;


        public MolduraQR(Context context, AttributeSet attrs) {
            super(context, attrs);
            init();
        }

    public MolduraQR(Context context) {
        super(context);
    }

    private void init() {
            paint = new Paint();
            paint.setColor(Color.RED); // cor da borda
            paint.setStrokeWidth(strokeWidth);
            paint.setStyle(Paint.Style.STROKE);
            paint.setAntiAlias(true);
        }

        @Override
        protected void onDraw(Canvas canvas) {
            super.onDraw(canvas);

            int left = getWidth();
            int top = getHeight();
            int right = getWidth() ;
            int bottom = getHeight() ;

            // Top-left corner
            canvas.drawLine(left, top + cornerRadius, left, top + cornerLength, paint);
            canvas.drawLine(left + cornerRadius, top, left + cornerLength, top, paint);

            // Top-right corner
            canvas.drawLine(right, top + cornerRadius, right, top + cornerLength, paint);
            canvas.drawLine(right - cornerRadius, top, right - cornerLength, top, paint);

            // Bottom-left corner
            canvas.drawLine(left, bottom - cornerRadius, left, bottom - cornerLength, paint);
            canvas.drawLine(left + cornerRadius, bottom, left + cornerLength, bottom, paint);

            // Bottom-right corner
            canvas.drawLine(right, bottom - cornerRadius, right, bottom - cornerLength, paint);
            canvas.drawLine(right - cornerRadius, bottom, right - cornerLength, bottom, paint);
        }
    }


