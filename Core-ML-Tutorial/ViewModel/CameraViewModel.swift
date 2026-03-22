//
//  CameraViewModel.swift
//  Core ML tutorial
//
//  Created by Johnson Elangbam on 3/22/26.
//

import Foundation
import AVFoundation
import Vision
import CoreML
import UIKit

class CameraViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var result: String = "Scanning..."
    
    private let session = AVCaptureSession()
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(for: .video),
        let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.queue"))
        
        session.addOutput(output)
        session.startRunning()
    }
}
