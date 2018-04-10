//
//  ViewController.swift
//  TableViewTest
//
//  Created by Matt Ackerman on 4/8/18.
//  Copyright © 2018 Matthew Ackerman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // articles gathered from api
    var articles = [News]()
    
    // list of strings for the table with temp values until articles are gathered
    var tableRows:[String] = ["", "", "", "", "", "", "", "", "", ""]
    
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Pull down to refresh
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull for news")
        refresher.addTarget(self, action: #selector(TableViewController.reloadTableWithNews), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        // Asynchronously loading News articles
        News.getNews { (results:[News]) in
            for result in results {
                print(result)
                self.articles.append(result)
            }
            self.setText()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // sets our table rows to our articles
    func setText() {
        tableRows = [
            articles[0].site + ": " +  articles[0].title,
            articles[1].site + ": " +  articles[1].title,
            articles[2].site + ": " +  articles[2].title,
            articles[3].site + ": " +  articles[3].title,
            articles[4].site + ": " +  articles[4].title,
            articles[5].site + ": " +  articles[5].title,
            articles[6].site + ": " +  articles[6].title,
            articles[7].site + ": " +  articles[7].title,
            articles[8].site + ": " +  articles[8].title,
            articles[9].site + ": " +  articles[9].title
        ]
        reloadTableWithNews()
    }
    
    // return how many rows we want in our table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRows.count
    }
    
    // set cells to our tableRows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // set cell's text and make the text wrap
        cell.textLabel?.text = String(tableRows[indexPath.row])
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        return cell
    }
    
    // on-click event for each row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected: \(indexPath.row)")
        
        // if the row clicked has been filled with an article, go to url of article
        if !tableRows[indexPath.row].isEmpty {
            let url = URL(string: articles[indexPath.row].siteUrl)
            UIApplication.shared.openURL(url!)
        }
    }
    
    // reloads table once we have the news
    @objc func reloadTableWithNews() {
        DispatchQueue.main.async {
            self.refresher.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
}

