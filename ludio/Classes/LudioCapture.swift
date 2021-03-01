//
//  LudioCapture.swift
//  ludio
//
//  Created by Cory Zachman on 12/18/20.
//

import Foundation
import Photos

public class LudioCapture: NSObject, AVCaptureFileOutputRecordingDelegate {
    var previewView: UIView
    var captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var cameraActive: Bool = false
    private var listeners: [LudioCaptureDelegate] = []

    public init(view: UIView) {
        self.previewView = view
        super.init()

        if setupSession() {
            setupPreview()
            startSession()
        }
    }

    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = previewView.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewView.layer.addSublayer(previewLayer)
    }

    // MARK: - Setup Camera
    func setupSession() -> Bool {

        captureSession.sessionPreset = AVCaptureSession.Preset.high

        // Setup Camera
        let camera = AVCaptureDevice.devices(for: AVMediaType.video)

        do {
            guard let device = camera.last else {
                return false
            }

            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }

        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }

        return true
    }

    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // Note: Because we use a unique file path for each recording, a new recording won't overwrite a recording mid-save.
        func cleanup() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
        }

        var success = true

        if error != nil {
            print("Movie file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }

        if success {
            // Check the authorization status.
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    // Save the movie file to the photo library and cleanup.
                    PHPhotoLibrary.shared().performChanges({
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    }, completionHandler: { success, error in
                        if !success {
                            print("AVCam couldn't save the movie to your photo library: \(String(describing: error))")
                        }
                        cleanup()
                    }
                    )
                } else {
                    cleanup()
                }
            }
        } else {
            cleanup()
        }
    }

    @objc private func onVideoError(notification: NSNotification) {
        print("AVCaptureSessionRuntimeError")
    }

    // MARK: - Camera Session
    func startSession() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onVideoError),
            name: NSNotification.Name.AVCaptureSessionRuntimeError,
            object: captureSession)

        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }

    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }

    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation

        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }

        return orientation
    }

    public func startRecording() {

        if movieOutput.isRecording == false {

            let connection = movieOutput.connection(with: AVMediaType.video)
            if ((connection?.isVideoOrientationSupported) != nil) {
                connection?.videoOrientation = currentVideoOrientation()
            }

            if ((connection?.isVideoStabilizationSupported) != nil) {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            if activeInput == nil {
                return
            }

            let device = activeInput.device
            if device.isSmoothAutoFocusSupported {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
            }

            // Update the orientation on the movie file output video connection before recording.
            if #available(iOS 11.0, *) {
                let availableVideoCodecTypes = movieOutput.availableVideoCodecTypes
                if availableVideoCodecTypes.contains(.h264) {
                    movieOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: connection!)
                }
            } else {
                // Fallback on earlier versions
            }

            let outputFileName = NSUUID().uuidString
            let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
            movieOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)

            for listener in listeners {
                listener.onCaptureStarted()
            }
        }
    }

    public func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
            for listener in listeners {
                listener.onCaptureCompleted()
            }
        }
    }

    public func isCameraActive() -> Bool {
        return cameraActive
    }

    public func add(listener: LudioCaptureDelegate) {
        listeners.append(listener)
    }

    public func remove(listener: LudioCaptureDelegate) {
        if let idx = listeners.firstIndex(where: { $0 === listener }) {
            listeners.remove(at: idx)
        }
    }
}
