//
//  TableViewController.swift
//  TableViewTest
//
//  Created by Matt Ackerman on 4/8/18.
//  Copyright © 2018 Matthew Ackerman. All rights reserved.
//
import UIKit

class TableViewController: UITableViewController {
    
    // articles gathered from api
    var articles = [News]()
    
    // list of strings for the table with temp values until articles are gathered
    var tableRows:[String] = ["", "", "", "", "", "", "", "", "", ""]

    override func viewDidLoad() {
        super.viewDidLoad()
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRows.count
    }

    // set cells to our tableRows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // set cell's text and make the text wrap
        cell.textLabel?.text = String(tableRows[indexPath.row])
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        return cell
    }
    
    // on-click event for each row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            self.tableView.reloadData()
        }
    }
}
