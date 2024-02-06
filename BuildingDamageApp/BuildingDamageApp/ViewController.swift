//
//  ViewController.swift
//  BuildingDamageApp
//
//  Created by CEMRE YARDIM on 6.02.2024.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {

  @IBOutlet weak var labelTitle: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  let imagePicker = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imagePicker.delegate = self
    imagePicker.allowsEditing = false
    imagePicker.sourceType = .camera
    
    imageView.contentMode = .scaleAspectFill
    labelTitle.numberOfLines = 0
    labelTitle.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    labelTitle.minimumScaleFactor = 0.5
    labelTitle.adjustsFontSizeToFitWidth = true
    
    navigationItem.titleView?.backgroundColor = .systemGreen.withAlphaComponent(0.5)
    view.backgroundColor = UIColor(red: 0.73, green: 0.67, blue: 0.59, alpha: 1.00)
    labelTitle.text = ""
  }
  
  @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
    present(imagePicker, animated: true, completion: nil)
  }
  
  func detect(image: CIImage) {
    guard let model = try? VNCoreMLModel(for: BuildingDamageClassifier().model) else {
      fatalError("Cannot import model")
    }
    let request = VNCoreMLRequest(model: model) { request, error in
      guard let classification = request.results?.first as? VNClassificationObservation else {
        fatalError("could not classify image")
      }
      self.labelTitle.text = classification.identifier.capitalized
    }
    let handler = VNImageRequestHandler(ciImage: image)
    do {
      try handler.perform([request])
    } catch {
      print(error)
    }
  }
  


}

extension ViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      guard let convertedCIImage = CIImage(image: userPickedImage) else {
        fatalError("Cannot convert to CIImage")
      }
      detect(image: convertedCIImage)
      imageView.image = userPickedImage
    }
    imagePicker.dismiss(animated: true)
  }
}

