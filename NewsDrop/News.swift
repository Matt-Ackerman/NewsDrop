//
//  News.swift
//  TableViewTest
//
//  Created by Matt Ackerman on 4/8/18.
//  Copyright © 2018 Matthew Ackerman. All rights reserved.
//
import Foundation

struct News {
    
    let site:String
    let title:String
    let siteUrl:String
    let imageUrl:String
    
    static let url = "http://192.168.1.3:8999/api"
    
    // Initializes a News object using an array
    init(json:[String:Any]) throws {
        guard let site = json["site"] as? String else {throw SerializationError.missing("site is missing")}
        guard let title = json["title"] as? String else {throw SerializationError.missing("title is missing")}
        guard let siteUrl = json["url"] as? String else {throw SerializationError.missing("site url is missing")}
        guard let imageUrl = json["main_image"] as? String else {throw SerializationError.missing("image url is missing")}
        
        self.site = site
        self.title = title
        self.siteUrl = siteUrl
        self.imageUrl = imageUrl
    }
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    // REST API call
    static func getNews (completion: @escaping ([News]) -> ()) {
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var newsArray:[News] = []
            
            // Getting json response and stepping down its heirarchy
            if let data = data {
                do {
                    // top level
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        // get all news postings in the API response
                        if let posts = json["posts"] as? [[String:Any]] {
                            
                            // looping through all news postings
                            for post in posts {
                                if let thread = post["thread"] as? [String:Any] {
                                    // creating a News object out of the "thread" object's JSON
                                    if let newsObject = try? News(json: thread) {
                                        newsArray.append(newsObject)
                                    }
                                }
                            }
                            
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                // Return the array of News objects
                completion(newsArray)
            }
        }
        task.resume()
    }
    
}
