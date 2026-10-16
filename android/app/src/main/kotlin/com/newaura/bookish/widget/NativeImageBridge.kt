package com.newaura.bookish.widget

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges native gallery/camera picks to Flutter over a [MethodChannel].
 * [com.newaura.bookish.MainActivity] starts [com.newaura.bookish.media.NativeImagePickerActivity]
 * and forwards the returned file path here.
 *
 * Dart may call `openGallery` / `openCamera`; native emits `onImagePicked`.
 */
object NativeImageBridge {

    const val CHANNEL: String = "com.newaura.bookish/native_image"

    private val mainHandler: Handler = Handler(Looper.getMainLooper())
    private var channel: MethodChannel? = null
    private var openGalleryAction: (() -> Unit)? = null
    private var openCameraAction: (() -> Unit)? = null

    fun attachChannel(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "openGallery" -> {
                        openGallery()
                        result.success(null)
                    }
                    "openCamera" -> {
                        openCamera()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun detachChannel() {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    fun attachLaunchers(
        openGallery: () -> Unit,
        openCamera: () -> Unit,
    ) {
        openGalleryAction = openGallery
        openCameraAction = openCamera
    }

    fun detachLaunchers() {
        openGalleryAction = null
        openCameraAction = null
    }

    fun openGallery() {
        openGalleryAction?.invoke()
    }

    fun openCamera() {
        openCameraAction?.invoke()
    }

    fun emitImagePath(path: String) {
        mainHandler.post {
            channel?.invokeMethod(
                "onImagePicked",
                mapOf("path" to path),
            )
        }
    }
}
