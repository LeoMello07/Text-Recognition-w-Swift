//
//  ViewController.swift
//  VamoLogo
//
//  Created by Leonardo Mello on 06/08/20.
//  Copyright © 2020 Leonardo Mello. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func takephoto(){
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

        // 3
        let libraryButton = UIAlertAction(
          title: "Choose Existing",
          style: .default) { (alert) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
        }
        imagePickerActionSheet.addAction(libraryButton)

        // 4
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)

        // 5
        present(imagePickerActionSheet, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 1
        guard let selectedPhoto =
          info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        // 3
        dismiss(animated: true) {
           // self.performImageRecognition(selectedPhoto)
        }


    }

}
