//
//  ClassifierVC.swift
//  AnimalClassifierML
//
//  Created by gdm on 1/17/19.
//  Copyright © 2019 gdm. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ClassifierVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            //pull in my CoreML model I created
            let model = try VNCoreMLModel(for: AnimalClassifier().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                //process classifications
                self.processClassifications(for: request, error: error)
            })
            // model requires square image
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load VisionML model \(error)")
        }
    }()
    
    func processClassifications(for request: VNRequest, error: Error?) {
        guard let classifications = request.results as? [VNClassificationObservation] else {
            self.classificationLabel.text = "Unable to classify image. \n\(error?.localizedDescription ?? "Error")"
            return
        }
        if classifications.isEmpty {
            self.classificationLabel.text = "Nothing recognized."
        } else {
            let topClassifications = classifications.prefix(2)
            let descriptions = topClassifications.map { classification in
                return String(format: "%.2f", classification.confidence * 100) + "% - " + classification.identifier
            }
            
            self.classificationLabel.text = "Classifications: \n" + descriptions.joined(separator: "\n")
        }
    }

    @IBAction func cameraButtonPressed(_ sender: Any) {
        //verify device has camera
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            //present photo picker
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            //present photo picker with camera option
            self.presentPhotoPicker(sourceType: .camera)
        }
        
        let choosePhotoAction = UIAlertAction(title: "Choose Photo", style: .default) { _ in
            //present photo picker with photo picker
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhotoAction)
        photoSourcePicker.addAction(choosePhotoAction)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true, completion: nil)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
        
    }
}

extension ClassifierVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { fatalError("No image returned") }
        imageView.image = image
        //Use image to make predictions with CoreML model
    }
}
