// Arquivo: app/src/main/java/com/example/tccteste/MolduraQR.java
package com.example.litteratcc;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

public class MolduraQR extends View {

    private final Paint paint;//pra desenhar a moldura
    private final RectF arcRect = new RectF();//pra desenhar as bordas arredondadas

    public MolduraQR(@NonNull Context context) {
        super(context);
        paint = createPaint(context);
    }

    public MolduraQR(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        paint = createPaint(context);
    }

    public MolduraQR(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        paint = createPaint(context);
    }
    private Paint createPaint(Context context) {//config da pain
        TypedValue tv = new TypedValue();
        context.getTheme().resolveAttribute(com.google.android.material.R.attr.colorOnPrimary, tv, true);
        int color = tv.data;
        Paint p = new Paint();
        p.setColor(color);
        p.setStyle(Paint.Style.STROKE);
        p.setStrokeWidth(8f);
        p.setAntiAlias(true);
        return p;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        int width = getWidth();
        int height = getHeight();//pega o tamanho da view

        int minSide = Math.min(width, height);//moldur cabe certinho no quadrado da view
        int frameSize = (int) (minSide * 0.7f);//espaço q a moldura ocupa

        //coordenadas no centro da tela
        int left = (width - frameSize) / 2;
        int top = (height - frameSize) / 2;
        int right = left + frameSize;
        int bottom = top + frameSize;

        //estilo arredondado
        int cornerLength = (int) (frameSize * 0.18f);//comprimento das linhas retas dos cantos
        float cornerRadius = frameSize * 0.10f;//raio das curvas dos cantos

        //canto superior esquerdo
        canvas.drawLine(left + cornerRadius, top, left + cornerLength, top, paint);
        canvas.drawLine(left, top + cornerRadius, left, top + cornerLength, paint);
        arcRect.set(left, top, left + 2 * cornerRadius, top + 2 * cornerRadius);
        canvas.drawArc(arcRect, 180, 90, false, paint);

        //canto superior direito
        canvas.drawLine(right - cornerRadius, top, right - cornerLength, top, paint);
        canvas.drawLine(right, top + cornerRadius, right, top + cornerLength, paint);
        arcRect.set(right - 2 * cornerRadius, top, right, top + 2 * cornerRadius);
        canvas.drawArc(arcRect, 270, 90, false, paint);

        //canto inferior esquerdo
        canvas.drawLine(left + cornerRadius, bottom, left + cornerLength, bottom, paint);
        canvas.drawLine(left, bottom - cornerRadius, left, bottom - cornerLength, paint);
        arcRect.set(left, bottom - 2 * cornerRadius, left + 2 * cornerRadius, bottom);
        canvas.drawArc(arcRect, 90, 90, false, paint);

        //canto inferior direito
        canvas.drawLine(right - cornerRadius, bottom, right - cornerLength, bottom, paint);
        canvas.drawLine(right, bottom - cornerRadius, right, bottom - cornerLength, paint);
        arcRect.set(right - 2 * cornerRadius, bottom - 2 * cornerRadius, right, bottom);
        canvas.drawArc(arcRect, 0, 90, false, paint);
    }
}