//
//  Model.swift
//  APIDemo
//
//  Created by Lun Sovathana on 11/30/16.
//  Copyright © 2016 Lun Sovathana. All rights reserved.
//

import Foundation

struct Author{
    var id:Int!
    var name:String!
    var email:String!
    var telephone:String!
}

struct Category{
    var id:Int!
    var name:String!
}

class Article{
    var id:Int!
    var title:String!
    var imageUrl:String!
    var description:String!
    var createdDate:Date!
    var author:Author!
    var category:Category!
    
    init(id:Int, title:String?, imageUrl:String?, description:String?, createdDate:Date?, author:Author?, category:Category?) {
        self.title = title ?? ""
        self.imageUrl = imageUrl ?? ""
        self.description = description ?? ""
        self.createdDate = createdDate
        self.author = author
        self.category = category
    }
}
