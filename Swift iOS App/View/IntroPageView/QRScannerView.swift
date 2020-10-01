//
//  QRScannerView.swift
//  sporthealth
//
//  Created by Chuying He on 09.01.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI
import AVFoundation
import UIKit

final class QRScannerView: UIViewController, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var qrValue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        captureSession = AVCaptureSession()

        guard let captureSession = captureSession else {
           print("error: captureSession doesnt exits")
           return
        }

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
           return
        }

        let videoInput: AVCaptureDeviceInput
        do {
           videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
           return
        }

        if captureSession.canAddInput(videoInput) {
           captureSession.addInput(videoInput)
        } else {
           failed()
           return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
           captureSession.addOutput(metadataOutput)
           // Sets the receiver's delegate that will accept metadata objects and dispatch queue on which the delegate will be called.
           metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
           metadataOutput.metadataObjectTypes = [.qr]
        } else {
           failed()
           return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let previewLayer = previewLayer else {
           print("error: previewLayer doesn't exits")
           return
        }

        let screenWidth = self.view.bounds.width
        let cgRect = CGRect(x: screenWidth * 0.1, y: screenWidth * 0.1, width: screenWidth * 0.8, height: screenWidth * 0.8)
        previewLayer.frame = cgRect
        previewLayer.cornerRadius = 10
        previewLayer.borderColor = CGColor(srgbRed: CGFloat(0.988), green: CGFloat(0.337), blue: CGFloat(0.447), alpha: CGFloat(1))
        previewLayer.borderWidth = 3

        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        #if targetEnvironment(simulator)
            print("Simulator doesn't support camera test, please use a ios-device!")
        #else
            print("ios device detected.")
            if captureSession?.isRunning == false {
               captureSession?.startRunning()
            }
        #endif
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("Tell Delegate: we captured a new Metadata from the Output!")

        captureSession?.stopRunning()

        if let metadata = metadataObjects.first {
            guard let metadata = metadata as? AVMetadataMachineReadableCodeObject else {
                print("no readable data")
                return
            }
            guard let stringValue = metadata.stringValue else {
                print("no string value from readable data")
                return
            }
            qrValue = stringValue
            print("qr value:\(String(describing: qrValue))")
        }
        
        print("qrValue: \(String(describing: qrValue))")
        dismiss(animated: true)
    }

    func failed() {
        let alert = UIAlertController(title: "Scanning failed", message: "Please use a device with a camera", preferredStyle: .alert)
        present(alert, animated: true)
        captureSession = nil    // default value
    }
}


extension QRScannerView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = QRScannerView

    func makeUIViewController(context: UIViewControllerRepresentableContext<QRScannerView>) -> QRScannerView {
        // return ScannerViewController(result: resultOfScanner)
        return QRScannerView()
    }
    
    func updateUIViewController(_ uiViewController: QRScannerView, context: UIViewControllerRepresentableContext<QRScannerView>) {}
}
