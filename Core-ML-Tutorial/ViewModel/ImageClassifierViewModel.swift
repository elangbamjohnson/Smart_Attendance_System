//
//  ImageClassifierViewModel.swift
//  Core ML tutorial
//
//  Created by Johnson Elangbam on 3/21/26.
//

import Foundation
import UIKit
import Vision
import CoreML

//ObservableObject: This declares a class that can be observed for changes, meaning that other parts of your app can react when its properties are updated.
class ImageClassifierViewModel: ObservableObject {
    //@Published means that any changes to results will automatically notify observers (e.g., your UI), triggering updates. It's initialized as an empty array.
    @Published var results: [String] = []
    @Published var isLoading: Bool = false
    
    func classifyImage(_ image: UIImage) {
        isLoading = true
        results = []
        
        guard let ciImage = CIImage(image: image) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                
                let config = MLModelConfiguration()
                let coreMLModel = try MobileNetV2(configuration: config)
                let visionModel = try VNCoreMLModel(for: coreMLModel.model)
                let request = VNCoreMLRequest(model: visionModel) { request, error in
                    guard let observations = request.results as? [VNClassificationObservation] else { return }
                    let top3 = observations.prefix(2)
                    
                    let formattedResults = top3.map {
                        "\($0.identifier) (\(String(format: "%.2f", $0.confidence * 100))%)"
                    }
                    
                    DispatchQueue.main.async {
                        self.results = formattedResults
                        self.isLoading = false
                    }
                }
                let handler = VNImageRequestHandler(ciImage: ciImage)
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.results = ["Error: \(error.localizedDescription)"]
                    self.isLoading = false
                }
            }
        }
    }
}
