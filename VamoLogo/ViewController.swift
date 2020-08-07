//
//  ViewController.swift
//  VamoLogo
//
//  Created by Leonardo Mello on 06/08/20.
//  Copyright © 2020 Leonardo Mello. All rights reserved.
//

import AVFoundation
import UIKit
import MobileCoreServices
import TesseractOCR
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

       @IBAction func takephoto(_ sender: Any){
        
        let imagePickerActionSheet =
          UIAlertController(title: "Snap/Upload Image",
                            message: nil,
                            preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
          let cameraButton = UIAlertAction(
            title: "Take Photo",
            style: .default) { (alert) -> Void in
      
              let imagePicker = UIImagePickerController()
              imagePicker.delegate = self
              imagePicker.sourceType = .camera
              imagePicker.mediaTypes = [kUTTypeImage as String]
              self.present(imagePicker, animated: true, completion: {
                
              })
          }
          imagePickerActionSheet.addAction(cameraButton)
        }

        let libraryButton = UIAlertAction(
          title: "Choose Existing",
          style: .default) { (alert) -> Void in

            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(imagePicker, animated: true, completion: {

            })
        }
        imagePickerActionSheet.addAction(libraryButton)

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)


        present(imagePickerActionSheet, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedPhoto =
          info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        dismiss(animated: true) {
          self.performImageRecognition(selectedPhoto)
        }
    }

    //MARK: -- Tesseract
    // Tesseract Image Recognition
    func performImageRecognition(_ image: UIImage){
        let scaledImage = image.scaledImage(1000) ?? image
        
        if let tesseract = G8Tesseract(language: "eng") {
          tesseract.engineMode = .tesseractCubeCombined
          tesseract.pageSegmentationMode = .auto
          tesseract.image = scaledImage
          tesseract.recognize()
             textView.text = tesseract.recognizedText
        }
        
    }

}

// MARK: - UIImage extension

extension UIImage {
  
  func scaledImage(_ maxDimension: CGFloat) -> UIImage? {
  
    var scaledSize = CGSize(width: maxDimension, height: maxDimension)

    if size.width > size.height {
      scaledSize.height = size.height / size.width * scaledSize.width
    } else {
      scaledSize.width = size.width / size.height * scaledSize.height
    }
    UIGraphicsBeginImageContext(scaledSize)
    draw(in: CGRect(origin: .zero, size: scaledSize))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  
    return scaledImage
  }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
}


