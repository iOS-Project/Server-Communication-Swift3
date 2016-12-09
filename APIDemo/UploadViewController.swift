//
//  UploadViewController.swift
//  APIDemo
//
//  Created by Lun Sovathana on 12/7/16.
//  Copyright © 2016 Lun Sovathana. All rights reserved.
//

import UIKit
import SwiftSpinner

class UploadViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var progressLabel: UILabel!
    
    
    var session : URLSession!
    var uploadTask : URLSessionUploadTask!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.progress = 0.0
        progressLabel.text = ""
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(browseImage(_:)))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tapGesture)
        
        // Session
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    @IBAction func uploadClick(_ sender: Any) {
        
        //SwiftSpinner.show("Uploading...")
        
        let url = URL(string: "http://120.136.24.174:1301/v1/api/uploadfile/single")
        var request = URLRequest(url: url!)
        // Set method
        request.httpMethod = "POST"
        // Set boundary
        request.addValue("Basic QU1TQVBJQURNSU46QU1TQVBJUEBTU1dPUkQ=", forHTTPHeaderField: "Authorization")
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create requestBody
        var formData = Data()
        
        let imageData = UIImagePNGRepresentation(image.image!)
        let mimeType = "image/png" // Multipurpose Internet Mail Extension
        formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        formData.append("Content-Disposition: form-data; name=\"FILE\"; filename=\"Image.png\"\r\n".data(using: .utf8)!)
        formData.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        formData.append(imageData!)
        formData.append("\r\n".data(using: .utf8)!)
        formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = formData
        
        print(formData)
        
        uploadTask = session.uploadTask(with: request, from: formData, completionHandler: {
            
            data, response, error in
            
            print("Finished")
            
            if error == nil{
                
                print("Success : \(response)")
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    print(json)
                }catch let error{
                    print("Error : \(error.localizedDescription)")
                }
                
                
                
            }else{
                print(error?.localizedDescription)
            }
            
        })
        
        uploadTask.resume()
        
        //        let task = session.dataTask(with: request, completionHandler: {
        //
        //            data, response, error in
        //
        //            print("Finished")
        //
        //            if error == nil{
        //
        //                print("Success : \(data)")
        //
        //                do{
        //                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        //                    print(json)
        //                }catch let error{
        //                    print("Error : \(error.localizedDescription)")
        //                }
        //
        //
        //
        //            }else{
        //                print(error?.localizedDescription)
        //            }
        //
        //            DispatchQueue.main.async {
        //                SwiftSpinner.hide()
        //            }
        //
        //        })
        //
        //        task.resume()
        
    }
}

extension UploadViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // Browse Image
    func browseImage(_ tapGesture: UITapGestureRecognizer){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Upload when finish
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //Get as UIImage
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.image.image = image
        }
        
        // Get from URL
        /*
         if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL{
         
         // document path
         let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
         let localPath = documentDir.appendingPathComponent(imageURL.absoluteURL.lastPathComponent)
         
         // write to local folder
         let img = info[UIImagePickerControllerOriginalImage] as! UIImage
         let data = UIImagePNGRepresentation(img)
         do{
         try data?.write(to: URL(fileURLWithPath: localPath), options: .atomic)
         }catch let error{
         print("Error: \(error.localizedDescription)")
         }
         
         // display image
         let imageData = NSData(contentsOfFile: localPath)
         image.image = UIImage(data: imageData as! Data)
         
         
         }*/
        
        
        
        // Dismiss ImagePicker
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension UploadViewController:URLSessionTaskDelegate{
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        let byte = ByteCountFormatter.string(fromByteCount: totalBytesSent, countStyle: .binary)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToSend, countStyle: .binary)
        let progress = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
        let display = String.init(format: "Upload %@ of %@", byte, totalSize)
        print(display)
        
        DispatchQueue.main.async {
            self.progressView.progress = progress
            self.progressLabel.text = display
        }
    }
}
