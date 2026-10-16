package com.newaura.bookish.media

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.view.SurfaceHolder
import android.view.SurfaceView
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.viewinterop.AndroidView

@Composable
fun GameSurfaceScreen(modifier: Modifier = Modifier) {
    val context = LocalContext.current

    // Remember the controller state or worker thread logic
    // to ensure it survives standard Composable recompositions
    val gameRenderer = remember { ComposeGameRenderer() }

    AndroidView(
        factory = { ctx ->
            // Instantiate the classic SurfaceView directly inside the factory
            SurfaceView(ctx).apply {
                holder.addCallback(gameRenderer)
            }
        },
        modifier = modifier.fillMaxSize(),
        update = { /* No-op: Drawing state is handled inside the render thread */ }
    )

    // Clean up the thread context if this Composable leaves the screen entirely
    DisposableEffect(Unit) {
        onDispose {
            gameRenderer.stopEngine()
        }
    }
}

/**
 * Encapsulates the thread logic completely separated from the Compose layout engine.
 */
class ComposeGameRenderer : SurfaceHolder.Callback, Runnable {

    private var isRunning = false
    private var gameThread: Thread? = null
    private var activeHolder: SurfaceHolder? = null

    override fun surfaceCreated(holder: SurfaceHolder) {
        activeHolder = holder
        isRunning = true
        gameThread = Thread(this).apply { start() }
    }

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        // Adjust graphics matrices or scaling resolutions here if needed
    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        stopEngine()
    }

    fun stopEngine() {
        if (!isRunning) return
        isRunning = false
        try {
            gameThread?.join(500) // Safely await thread termination with a timeout
        } catch (e: InterruptedException) {
            e.printStackTrace()
        } finally {
            gameThread = null
            activeHolder = null
        }
    }

    override fun run() {
        val holder = activeHolder ?: return

        while (isRunning) {
            if (!holder.surface.isValid) continue

            var canvas: Canvas? = null
            try {
                canvas = holder.lockCanvas()
                if (canvas != null) {
                    synchronized(holder) {
                        drawGameFrame(canvas)
                    }
                }
            } finally {
                if (canvas != null) {
                    holder.unlockCanvasAndPost(canvas)
                }
            }
        }
    }

    private fun drawGameFrame(canvas: Canvas) {
        // Draw background
        canvas.drawColor(Color.DKGRAY)

        // Draw animated/game elements
        val paint = Paint().apply {
            color = Color.GREEN // Changed color to verify it's the Compose version
            style = Paint.Style.FILL
            isAntiAlias = true
        }

        // Target center screen based on canvas size
        canvas.drawCircle(canvas.width / 2f, canvas.height / 2f, 150f, paint)
    }
}
