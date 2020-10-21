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
import SQLite


class ViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func updateSearchResults(for searchController: UISearchController) {
       
    }
    
        private var db : Connection? = nil
        let sugestion = Table("sugestion")
        let id = Expression<Int>("id")
        let sugestao = Expression<String>("sugestao")
        private var collectionView: UICollectionView?
        private var textObservations = [VNTextObservation]()
        private var textDetectionRequest: VNDetectTextRectanglesRequest?
        
        private let session = AVCaptureSession()
        private var scanImageView = ScanImageView(frame: .zero)
        private var ocrTextView = OcrTextView(frame: .zero, textContainer: nil)
        private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    
        private var foundWord = " "
    
        private var models = [String]()
    
        var searchController : UISearchController!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            connection()
            database()
            printTable()
            collection()
            searchCont()
            
            guard let myCollection = collectionView else {
                return
            }

            cameraView.addSubview(myCollection)
            
            ocrTextView.isEditable = false
            ocrTextView.textColor = .black
        
            showSearch()
            configure()
            configureOCR()
            configureCamera()
            configureTextDetection()
        }
    
    func searchCont(){
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
    }
    
    func database(){
        let connection = try? Connection()
        let table = Table("sugestao")
        do {
            try connection?.scalar(table.exists)
            print("talbe already exist!")
        } catch {
            print("criando tabela.")
                    try? db?.run(sugestion.create {  t in
                        t.column(id, primaryKey: .autoincrement)
                        t.column(sugestao, unique: false)
                    })
        }

    }
    



    func collection(){
        
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
    }
    
    func printTable(){
        do {
                let stmt = try db!.prepare("SELECT * FROM sugestion")
                for row in stmt {
                    models.append(row[1] as! String)
                }
        } catch {
            print(error)
        }
    }
    
    private func connection(){
        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! + "/" + Bundle.main.bundleIdentifier!
         try? FileManager.default.createDirectory( atPath: path, withIntermediateDirectories: true, attributes: nil )
         db =  try? Connection("\(path)/db.sqlite3")
        
    }
    
    private func addTable(sug : String){
        do {
            let rowid = try db?.run(sugestion.insert(sugestao <- sug))
            print("inserted id: \(String(describing: rowid))")
        } catch {
            print("insertion failed: \(error)")
        }

    }

    //MARK: -- COLLECTION VIEW - SUGGEST TEXT
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = CGRect(x: 0, y: 0, width: cameraView.frame.size.width, height: 60).integral
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.reloadData()
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CircleCollectionViewCell.identifier, for: indexPath) as! CircleCollectionViewCell

            let button = UIButton(frame: CGRect(x: 75, y: 15, width: 20, height: 20))
            button.setImage(UIImage(named: "trash.png"), for: UIControl.State.normal)
        
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            cell.addSubview(button)
    
            cell.configure(with: models[indexPath.row])
        
        return cell
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let indexPath = IndexPath(item: sender.tag, section: 0)

        models.remove(at: indexPath.row)

        self.collectionView?.performBatchUpdates({
            self.collectionView?.deleteItems(at: [indexPath])
            }) { (finished) in
            self.collectionView?.reloadItems(at: self.collectionView!.indexPathsForVisibleItems)
            }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchController.isActive = true
        self.searchController.searchBar.text =  models[indexPath.row]
        searchBar(self.searchController.searchBar, textDidChange: models[indexPath.row] )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
      return 1
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return 1
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
            
            NSLayoutConstraint.activate([

                ocrTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                ocrTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                ocrTextView.bottomAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                ocrTextView.heightAnchor.constraint(equalToConstant: 100),
                
                scanImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                scanImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                scanImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -0),
                scanImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor , constant: -0),
                
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
            models.append(foundWord)
            addTable(sug: foundWord)
            collectionView?.reloadData()
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
                    
                    if(ocrText.lowercased().contains(self.foundWord.lowercased())){
                        self.ocrTextView.text = "Contém: " + self.foundWord
                    } else {
                        self.ocrTextView.text =  "Não contém: " + self.foundWord
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
    }
}
