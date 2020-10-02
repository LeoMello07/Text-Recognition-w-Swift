//
//  ViewController.swift
//  VamoLogo
//
//  Created by Leonardo Mello on 06/08/20.
//  Copyright © 2020 Leonardo Mello. All rights reserved.
//

import UIKit
import SwiftUI
import Vision
import VisionKit
import AVFoundation
import TesseractOCR

class ViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let models = ["img1", "img2", "img3", "img1", "img2", "img3", "img1", "img2", "img3"]
    
    func updateSearchResults(for searchController: UISearchController) {
       
    }
    
    
        private var collectionView: UICollectionView?
        private var textObservations = [VNTextObservation]()
        private var textDetectionRequest: VNDetectTextRectanglesRequest?
        private var tesseract = G8Tesseract(language: "eng", engineMode: .tesseractOnly)
        private var font = CTFontCreateWithName("Helvetica" as CFString, 18, nil)
    
        private let session = AVCaptureSession()
        private var scanImageView = ScanImageView(frame: .zero)
        private var ocrTextView = OcrTextView(frame: .zero, textContainer: nil)
        private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    
        private var isRed: Bool = false
        private var foundWord = " "
    
        var searchController : UISearchController!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 100, height: 50)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            
            collectionView?.register(CircleCollectionViewCell.self, forCellWithReuseIdentifier: CircleCollectionViewCell.identifier)
            
            collectionView?.showsHorizontalScrollIndicator = false
            collectionView?.delegate = self
            collectionView?.dataSource = self
            collectionView?.backgroundColor = UIColor(white: 1, alpha: 0)
            
            guard let myCollection = collectionView else {
                return
            }
            
            cameraView.addSubview(myCollection)
            
            
            self.searchController = UISearchController(searchResultsController:  nil)
            
            self.searchController.searchResultsUpdater = self
            self.searchController.delegate = self
            self.searchController.searchBar.delegate = self
            
            ocrTextView.isEditable = false
            
            showSearch()
            configure()
            configureOCR()
            configureCamera()
            configureTextDetection()
        }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = CGRect(x: 0, y: 0, width: cameraView.frame.size.width, height: 60).integral
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CircleCollectionViewCell.identifier, for: indexPath) as! CircleCollectionViewCell
        
        let title = UILabel(frame: CGRect(x: 0, y: 5, width: cell.bounds.size.width, height: 40))
            title.textColor = UIColor.white
            title.text = "Trigo"
            title.textAlignment = .center
            cell.contentView.addSubview(title)
    
        return cell
       
    }
    
    
    
    
    
    private var cameraView: ScanImageView {
        return scanImageView
    }

    
    private func configureCamera() {
        cameraView.session = session
        
        let cameraDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        var cameraDevice: AVCaptureDevice?
        for device in cameraDevices.devices {
            if device.position == .back {
                cameraDevice = device
                break
            }
        }
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice!)
            if session.canAddInput(captureDeviceInput) {
                session.addInput(captureDeviceInput)
            }
        }
        catch {
            print("Error occured \(error)")
            return
        }
        session.sessionPreset = .high
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        cameraView.videoPreviewLayer.videoGravity = .resize
        session.startRunning()
    }
        
        private func configure() {
            view.addSubview(scanImageView)
            view.addSubview(ocrTextView)
            
            let padding: CGFloat = 16
            let allCamera: CGFloat = 0
            NSLayoutConstraint.activate([

                ocrTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
                ocrTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
                ocrTextView.bottomAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
                ocrTextView.heightAnchor.constraint(equalToConstant: 100),
                
                scanImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: allCamera),
                scanImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: allCamera),
                scanImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -allCamera),
                scanImageView.bottomAnchor.constraint(equalTo: ocrTextView.topAnchor, constant: -allCamera),
                
            ])
        }
    
    private func showSearch(){
             self.searchController.hidesNavigationBarDuringPresentation = false
             self.navigationItem.titleView = searchController.searchBar
    }
    
    private func configureTextDetection() {
        textDetectionRequest = VNDetectTextRectanglesRequest(completionHandler: handleDetection)
        textDetectionRequest?.reportCharacterBoxes = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       foundWord = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         if(ocrTextView.text.contains(foundWord)){
            
        let alert = UIAlertController(title: "Achamos sua palavra", message: "A palavra pesquisada foi: \(foundWord)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true)
                  
            if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
                          self.present(alert, animated: true, completion: nil)
             }
        }
    }
  

    private func colorText(_ text : String){
        let main_string = ocrTextView.text
        let string_to_color = text
        let range = (main_string! as NSString).range(of: string_to_color)
        let attribute = NSMutableAttributedString.init(string: main_string!)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range)
        ocrTextView.attributedText = attribute
        isRed = true
        
    }

    private func handleDetection(request: VNRequest, error: Error?) {
        
        guard let detectionResults = request.results else {
            print("No detection results")
            return
        }
        let textResults = detectionResults.map() {
            return $0 as? VNTextObservation
        }
        if textResults.isEmpty {
            return
        }
        textObservations = textResults as! [VNTextObservation]
        DispatchQueue.main.async {
            
            guard let sublayers = self.view.layer.sublayers else {
                return
            }
            for layer in sublayers[1...] {
                if (layer as? CATextLayer) == nil {
                    layer.removeFromSuperlayer()
                }
            }
            let viewWidth = self.view.frame.size.width
            let viewHeight = self.view.frame.size.height
            for result in textResults {

                if let textResult = result {
                    
                    let layer = CALayer()
                    var rect = textResult.boundingBox
                    rect.origin.x *= viewWidth
                    rect.size.height *= viewHeight
                    rect.origin.y = ((1 - rect.origin.y) * viewHeight) - rect.size.height
                    rect.size.width *= viewWidth

                    layer.frame = rect
                    layer.borderWidth = 2
                    layer.borderColor = UIColor.red.cgColor
                    self.view.layer.addSublayer(layer)
                }
            }
        }
    }
        

        
        private func processImage(_ image: UIImage) {
            guard let cgImage = image.cgImage else { return }

            ocrTextView.text = ""
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.ocrRequest])
            } catch {
                print(error)
            }
        }

        private func configureOCR() {
            ocrRequest = VNRecognizeTextRequest { (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                
                var ocrText = ""
                for observation in observations {
                    guard let topCandidate = observation.topCandidates(1).first else { return }
                    
                    ocrText += topCandidate.string + "\n"
                }
                
                guard let detectionResults = request.results else {
                           print("No detection results")
                           return
                       }
                       let textResults = detectionResults.map() {
                           return $0 as? VNTextObservation
                       }
                       if textResults.isEmpty {
                           return
                       }
 
                DispatchQueue.main.async {
                    if(ocrText.contains(self.foundWord)){
                        self.ocrTextView.text = "Contém: " + self.foundWord
                    } else {
                        self.ocrTextView.text =  "Palavra não encontrada: " + self.foundWord
                    }
                }
            }
            
            ocrRequest.recognitionLevel = .accurate
            ocrRequest.recognitionLanguages = ["pt-BR", "en-GB"]
            ocrRequest.usesLanguageCorrection = true
        }
    }


    extension ViewController: VNDocumentCameraViewControllerDelegate {
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount >= 1 else {
                controller.dismiss(animated: true)
                return
            }
            processImage(scan.imageOfPage(at: 0))
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            //Handle properly error
            controller.dismiss(animated: true)
        }
        
        //CANCELAR CAMERA
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }
    }

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
// MARK: - Camera Delegate and Setup
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
        return
    }
    
    var imageRequestOptions = [VNImageOption: Any]()
    if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
        imageRequestOptions[.cameraIntrinsics] = cameraData
    }
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: imageRequestOptions)
        do {
        try imageRequestHandler.perform([ocrRequest])
    }
    catch {
        print("Error occured \(error)")
    }
    var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
    ciImage = ciImage.transformed(by: transform)
    let size = ciImage.extent.size
    var recognizedTextPositionTuples = [(rect: CGRect, text: String)]()
    for textObservation in textObservations {
        guard let rects = textObservation.characterBoxes else {
            continue
        }
        var xMin = CGFloat.greatestFiniteMagnitude
        var xMax: CGFloat = 0
        var yMin = CGFloat.greatestFiniteMagnitude
        var yMax: CGFloat = 0
        for rect in rects {
            
            xMin = min(xMin, rect.bottomLeft.x)
            xMax = max(xMax, rect.bottomRight.x)
            yMin = min(yMin, rect.bottomRight.y)
            yMax = max(yMax, rect.topRight.y)
            
        }
        let imageRect = CGRect(x: xMin * size.width, y: yMin * size.height, width: (xMax - xMin) * size.width, height: (yMax - yMin) * size.height)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
            continue
        }
        let uiImage = UIImage(cgImage: cgImage)
        tesseract?.image = uiImage
        tesseract?.recognize()
        guard var text = tesseract?.recognizedText else {
            continue
        }
        text = text.trimmingCharacters(in: CharacterSet.newlines)
        if !text.isEmpty {
            let x = xMin
            let y = 1 - yMax
            let width = xMax - xMin
            let height = yMax - yMin
            recognizedTextPositionTuples.append((rect: CGRect(x: x, y: y, width: width, height: height), text: text))
            }
        }
    }
}
