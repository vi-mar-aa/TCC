package com.example.litteratcc;
import androidx.annotation.NonNull;
import android.graphics.Rect;
import android.view.View;
import androidx.recyclerview.widget.RecyclerView;


public class EspacoItem extends RecyclerView.ItemDecoration {

    private final int horizontalSpaceWidth;

    public EspacoItem(int horizontalSpaceWidth) {
        this.horizontalSpaceWidth = horizontalSpaceWidth;
    }

    @Override
    public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                               @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {//state é tipo oq o rv faz
        int position = parent.getChildAdapterPosition(view);


        outRect.right = horizontalSpaceWidth;//espaço a direita de todos


        if (position == 0) {
            outRect.left = horizontalSpaceWidth;//adiciona espaço a esquerda no primeiro item
        }
    }
}

