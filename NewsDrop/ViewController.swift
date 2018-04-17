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
    
    var refresher: UIRefreshControl!

    // articles gathered from api
    var articles = [News]()
    
    // list of strings for the table with temp values until articles are gathered
    var tableRows:[String] = [
        "", "", "", "", "",
        "", "", "", "", "",
        "", "", "", "", "",
        "", "", "", "", ""
    ]
    
    // User default values
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentDate = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentDate)
        let minutes = calendar.component(.minute, from: currentDate)
        print(currentDate)
        print(hour)
        print(minutes)
        
        // Table
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Refresh button
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull for news")
        refresher.frame.origin = CGPoint(x: 20, y: 10)
        refresher.addTarget(self, action: #selector(ViewController.reloadTableWithNews), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        getNews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getNews() {
        decideToallowRefresh()
        
        // Asynchronously loading News articles
        News.getNews { (results:[News]) in
            for result in results {
                self.articles.append(result)
            }
            self.setText()
        }
        
        // Save datetime of this table gather
        userDefaults.setValue(Date(), forKey: "dateOfLastTable")
        userDefaults.synchronize()
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
            articles[9].site + ": " +  articles[9].title,
            articles[10].site + ": " +  articles[10].title,
            articles[11].site + ": " +  articles[11].title,
            articles[12].site + ": " +  articles[12].title,
            articles[13].site + ": " +  articles[13].title,
            articles[14].site + ": " +  articles[14].title,
            articles[15].site + ": " +  articles[15].title,
            articles[16].site + ": " +  articles[16].title,
            articles[17].site + ": " +  articles[17].title,
            articles[18].site + ": " +  articles[18].title,
            articles[19].site + ": " +  articles[19].title
        ]
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
            print(" --- refreshed with pull down ---")
            self.getNews()
            self.tableView.reloadData()
            self.refresher.endRefreshing()
        }
    }
    
    func decideToallowRefresh() {
        // Gather DateTime of last refresh
        if let lastDateRefreshed = userDefaults.value(forKey: "dateOfLastTable") {
            
            let currentDate = Date()
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: currentDate)
            
            let hourOfLastCheck = calendar.component(.hour, from: lastDateRefreshed as! Date)
            
            // If last check received morning news and now it's time for night news
            // or
            // If last check received night news but it wasn't today
            if ( (hourOfLastCheck < 19 && currentHour > 19) ||
                 (hourOfLastCheck > 19 && (calendar.isDateInToday(lastDateRefreshed as! Date) == false)) ) {
                
                // Allow refresh
                print(1)
            }
            
            // If last check received night news and now it's time for morning news
            // or
            // If last check received morning news but it wasn't today
            else if ( (hourOfLastCheck > 19 && currentHour < 19) ||
                      (hourOfLastCheck < 19 && (calendar.isDateInToday(lastDateRefreshed as! Date) == false)) ) {
                
                // Allow refresh
                print(2)
            }
            
            // Display countdown to either 7 am or 7 pm
            else {
                
            }
            
        }
        
        
        
    }
    
}

