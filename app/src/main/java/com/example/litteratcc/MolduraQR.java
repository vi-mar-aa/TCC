// Arquivo: app/src/main/java/com/example/tccteste/MolduraQR.java
package com.example.litteratcc;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.annotation.NonNull;

public class MolduraQR extends View {

    private final Paint paint;
    private final RectF arcRect = new RectF();

    public MolduraQR(@NonNull Context context) {
        super(context);
        paint = createPaint();
    }

    public MolduraQR(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        paint = createPaint();
    }

    public MolduraQR(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        paint = createPaint();
    }
    private Paint createPaint() {
        Paint p = new Paint();
        p.setColor(Color.RED); // Troque para a cor desejada
        p.setStyle(Paint.Style.STROKE);
        p.setStrokeWidth(8f);
        p.setAntiAlias(true);
        return p;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        int width = getWidth();
        int height = getHeight();

        int minSide = Math.min(width, height);
        int frameSize = (int) (minSide * 0.7f);

        int left = (width - frameSize) / 2;
        int top = (height - frameSize) / 2;
        int right = left + frameSize;
        int bottom = top + frameSize;

        int cornerLength = (int) (frameSize * 0.18f);
        float cornerRadius = frameSize * 0.10f;

        // Canto superior esquerdo
        canvas.drawLine(left + cornerRadius, top, left + cornerLength, top, paint);
        canvas.drawLine(left, top + cornerRadius, left, top + cornerLength, paint);
        arcRect.set(left, top, left + 2 * cornerRadius, top + 2 * cornerRadius);
        canvas.drawArc(arcRect, 180, 90, false, paint);

        // Canto superior direito
        canvas.drawLine(right - cornerRadius, top, right - cornerLength, top, paint);
        canvas.drawLine(right, top + cornerRadius, right, top + cornerLength, paint);
        arcRect.set(right - 2 * cornerRadius, top, right, top + 2 * cornerRadius);
        canvas.drawArc(arcRect, 270, 90, false, paint);

        // Canto inferior esquerdo
        canvas.drawLine(left + cornerRadius, bottom, left + cornerLength, bottom, paint);
        canvas.drawLine(left, bottom - cornerRadius, left, bottom - cornerLength, paint);
        arcRect.set(left, bottom - 2 * cornerRadius, left + 2 * cornerRadius, bottom);
        canvas.drawArc(arcRect, 90, 90, false, paint);

        // Canto inferior direito
        canvas.drawLine(right - cornerRadius, bottom, right - cornerLength, bottom, paint);
        canvas.drawLine(right, bottom - cornerRadius, right, bottom - cornerLength, paint);
        arcRect.set(right - 2 * cornerRadius, bottom - 2 * cornerRadius, right, bottom);
        canvas.drawArc(arcRect, 0, 90, false, paint);
    }
}