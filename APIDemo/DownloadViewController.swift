//
//  DownloadViewController.swift
//  APIDemo
//
//  Created by Lun Sovathana on 12/5/16.
//  Copyright © 2016 Lun Sovathana. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController {
    
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var downloadProgressLabel: UILabel!
    
    let cache = URLCache.init(memoryCapacity: 10000, diskCapacity: 10000, diskPath: "ImageCache")
    var downloadTask:URLSessionDownloadTask!
    var session:URLSession!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadProgressLabel.text = ""
        
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
    }
    
    @IBAction func downloadFile(_ sender: Any) {
        
        let urlString = "http://cdn.wallpapersafari.com/6/36/XxOeFh.jpg"
        
        checkCache(urlString: urlString)
        
        if let url = URL(string: urlString){
            downloadTask = session.downloadTask(with: url)
            downloadTask.resume()
        }
    }
    
    @IBAction func clearCache(_ sender: Any) {
        
        URLCache.shared.removeAllCachedResponses()
    }
    
    
    func getCatch(url: String) -> Any?{
        
        guard let urlCache = cache.value(forKey: url)else{
            return nil
        }
        
        return urlCache
    }
    
    func checkCache(urlString: String){
        
        print("Download Started...")
        
        let url = URL(string: urlString)
        //Create request with caching policy
        let request = URLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad
            , timeoutInterval: 60)
        
        //Get cache response using request object
        let cacheResponse = URLCache.shared.cachedResponse(for: request)
        
        //check if cached response is available if nil then hit url for data
        if cacheResponse == nil {
            
            //default configuration
            let config = URLSessionConfiguration.default
            
            //Enable url cache in session configuration and assign capacity
            config.urlCache = URLCache.shared
            config.urlCache = URLCache(memoryCapacity: 51200, diskCapacity: 10000, diskPath: "urlCache")
            
            //create session with configration
            let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
            
            //create data task to download data and having completion handler
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                //below two lines will cache the data, request object as key
                let cacheResponse = CachedURLResponse(response: response!, data: data!)
                URLCache.shared.storeCachedResponse(cacheResponse, for: request)
            })
            task.resume()
        } else {
            //if cache response is not nil then print
            let string = NSString(data: cacheResponse!.data, encoding: String.Encoding.utf8.rawValue)
            print(string)
            
        }
    }
}

extension DownloadViewController:URLSessionDownloadDelegate{
    
    func urlForLocalFile(url: URL) -> URL{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            let fullPath = path.appendingPathComponent(url.lastPathComponent)
            return URL(fileURLWithPath: fullPath)
        
        }
        
        // When Download is Finished
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            print("Finished: \(location.absoluteString)")
            
            // Create originalPath
            let originalPath = downloadTask.originalRequest?.url?.absoluteURL
            
            // Create destination to move
            let destinationPath = urlForLocalFile(url: originalPath!)
            
            let fileManager = FileManager.default
            
            // Delete old file if exist
            do{
                try fileManager.removeItem(at: destinationPath)
            }catch{
                print("File doesn't exist")
            }
            
            // Move file
            do{
                try fileManager.copyItem(at: location, to: destinationPath)
            }catch{
                print("Error")
            }
            
            DispatchQueue.main.async {
                let data = try? Data(contentsOf: destinationPath)
                self.image.image = UIImage(data: data!)
                
                //self.cache.setValue(self.image.image, forKey: (originalPath?.absoluteString)!)
                self.downloadProgressLabel.text = "Downloaded"
                
                
            }
        }
        
        // Download is progressing
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            
            // Display the progress
            let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            let displayProgress = ByteCountFormatter.string(fromByteCount: totalBytesWritten, countStyle: .binary)
            // Total size
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .binary)
            print("Downloading \(progress)")
            
            DispatchQueue.main.async {
                self.progressView.progress = progress
                self.downloadProgressLabel.text = String(format: "%@ of %@", displayProgress, totalSize)
            }
            
        }
}

