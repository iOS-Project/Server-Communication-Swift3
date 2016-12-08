//
//  ViewController.swift
//  APIDemo
//
//  Created by Lun Sovathana on 11/30/16.
//  Copyright © 2016 Lun Sovathana. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftSpinner

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var reusableCellID = "ArticleCell"
    var articles = [Article]()
    var refreshControl = UIRefreshControl()
    
    // Property for using when expand label
    var expandedLabel:UILabel!
    var indexOfCellToExpand:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register Cell
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: reusableCellID)
        
        refreshControl.tintColor = UIColor.orange
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        
        tableView.addSubview(refreshControl)
        
        //get()
        testRequest()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == indexOfCellToExpand{
            return 427 + expandedLabel.frame.height
        }
        return 427
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellID, for: indexPath) as! ArticleTableViewCell
        let art = articles[indexPath.row]
        
        // image here
        cell.img.kf.setImage(with: URL(string: art.imageUrl), placeholder: UIImage(named: "placeholder"), options: nil, progressBlock: nil, completionHandler: nil)
        
        cell.title.text = art.title
        //cell.date.text = art.createdDate.description
        cell.author.text = art.author.name
        cell.desc.text = art.description
        // Add Gesture to DescriptionLabel
        cell.desc.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandCell(_:))))
        cell.desc.tag = indexPath.row
        cell.desc.isUserInteractionEnabled = true
        
        return cell
    }
    
    func refreshData(){
        get()
    }
    
    func expandCell(_ sender:UITapGestureRecognizer){
        // Create label for getting tag from this label
        let label = sender.view as! UILabel
        // Get reference cell
        let indexPath = IndexPath(row: label.tag, section: 1)
        print(indexPath.row)
        if let cell:ArticleTableViewCell = tableView.cellForRow(at: indexPath) as? ArticleTableViewCell{
            let art = articles[label.tag]
            cell.desc.sizeToFit()
            let desc = art.description
            
            // Set description text to reference cell
            cell.desc.text = desc
            expandedLabel = cell.desc
            indexOfCellToExpand = label.tag
            
            tableView.reloadRows(at: [indexPath], with: .fade)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        
    }
    
    
}

// API REQUEST
extension ViewController{
    func get(){
        
        SwiftSpinner.show("Loading...")
        
        // Create URL
        let url = URL(string: "\(API_BASE_URL)/articles")
        // Create Request
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let param = "page=1&limit=20"
        request.httpBody = param.data(using: .utf8)
        request.allHTTPHeaderFields = HEADER_FIELD
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: {
            
            data, response, error in
            
            if error == nil{
                
                if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary{
                    let jsonDATA = json.value(forKey: "DATA") as? [AnyObject]
                    
                    // remove old record
                    self.articles.removeAll(keepingCapacity: false)
                    
                    for obj in jsonDATA!{
                        let auth = obj["AUTHOR"] as? [String: AnyObject]
                        let cat = obj["CATEGORY"] as? [String: AnyObject]
                        self.articles.append(Article(id: obj["ID"] as! Int, title: obj["TITLE"] as? String, imageUrl: obj["IMAGE"] as? String, description: obj["DESCRIPTION"] as? String, createdDate: Date(jsonDate: "/Date(\(obj["CREATED_DATE"] as! String))/)"), author: Author(id: auth?["ID"] as? Int, name: auth?["NAME"] as? String, email: auth?["EMAIL"] as? String, telephone: auth?["TELEPHONE"] as! String!), category: Category(id: cat?["ID"] as? Int, name: cat?["NAME"] as? String)))
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                        // stop animation
                        self.refreshControl.endRefreshing()
                        SwiftSpinner.hide()
                        print("Finished")
                    }
                }
                
            }else{
                print(error?.localizedDescription as Any)
            }
            
        })
        
        task.resume()
        
    }
    
    
    func testRequest(){
        // URL
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")
        // Requester
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: url!, completionHandler: {
            data, response, error in
            
            if error == nil{
                do{
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary{
                        print(json)
                    }
                }catch let err{
                    print("Error : \(err)")
                }
                
                
                print(response!)
            }
        
        })
        
        task.resume()
        
        
    }
}

extension Date {
    init?(jsonDate: String) {
        
        let prefix = "/Date("
        let suffix = ")/"
        
        // Check for correct format:
        guard jsonDate.hasPrefix(prefix) && jsonDate.hasSuffix(suffix) else { return nil }
        
        // Extract the number as a string:
        let from = jsonDate.index(jsonDate.startIndex, offsetBy: prefix.characters.count)
        let to = jsonDate.index(jsonDate.endIndex, offsetBy: -suffix.characters.count)
        
        // Convert milliseconds to double
        guard let milliSeconds = Double(jsonDate[from ..< to]) else { return nil }
        
        // Create NSDate with this UNIX timestamp
        self.init(timeIntervalSince1970: milliSeconds/1000.0)
    }
}

