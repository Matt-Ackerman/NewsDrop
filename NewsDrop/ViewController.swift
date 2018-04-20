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
    @IBOutlet weak var timeOfNextAvailableNewsDrop: UILabel!
    var refresher: UIRefreshControl!
    let userDefaults = UserDefaults.standard

    // articles gathered from api
    var articles = [News]()
    
    // list of strings for the table with temp values until articles are gathered
    var tableRows:[String] = [
        "", "", "", "", "",
        "", "", "", "", "",
        "", "", "", "", "",
        "", "", "", "", ""
    ]
    
    let formatter = DateFormatter()
    let userCalender = Calendar.current;
    let requestedComponent : Set<Calendar.Component> = [
        Calendar.Component.month,
        Calendar.Component.day,
        Calendar.Component.hour,
        Calendar.Component.minute,
        Calendar.Component.second
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // table for list of news articles
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // refresh button
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull for news")
        refresher.frame.origin = CGPoint(x: 20, y: 10)
        refresher.addTarget(self, action: #selector(ViewController.reloadTableWithNews), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        if (shouldAllowRefresh() == true) {
            DispatchQueue.main.async {
                self.getNews()
                self.tableView.reloadData()
            }
        } else {
            let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timePrinter), userInfo: nil, repeats: true)
            timer.fire()
        }
        self.refresher.endRefreshing()
    }
    
    // Is it time to allow a refresh of the news?
    func shouldAllowRefresh() -> Bool {
        
        // gather DateTime of last refresh
        let nextRefreshTime = userDefaults.value(forKey: "nextRefreshTime") as! Date
        
        // if it is already past nextRefreshTime
        if (nextRefreshTime < Date()) {
            //displayTimeOfNextRefresh(currentHour: currentHour)
            return true
        } else {
            return false
        }
    }
    
    // receive news
    func getNews() {
        // asynchronously loading News articles
        News.getNews { (results:[News]) in
            for result in results {
                self.articles.append(result)
            }
            self.setText()
        }
        markThatUserGotNewsAndSetNextDate()
    }
    
    func markThatUserGotNewsAndSetNextDate() {
        
        let current = Date()
        let calendar = Calendar.current
        
        // save datetime of this table gather
        userDefaults.setValue(current, forKey: "dateOfLastNews")
        userDefaults.synchronize()
        
        // get hour of table gather
        let hourOfNewsCapture = calendar.component(.hour, from: current)
        
        // discover datetime of next available table gather
        if (hourOfNewsCapture >= 19) {
            //Next available drop: 7 am
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: current)
            let nextTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: tomorrow!)
            userDefaults.setValue(nextTime, forKey: "nextRefreshTime")
            userDefaults.synchronize()
            
        } else {
            // Next available drop: 7 pm
            let nextTime = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: current)
            userDefaults.setValue(nextTime, forKey: "nextRefreshTime")
            userDefaults.synchronize()
        }
        
    }
    
    // This is called if it is not time to refresh the news. Displays next time to refresh.
    func displayTimeOfNextRefresh() {
    
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timePrinter), userInfo: nil, repeats: true)
        
        timer.fire()
        
    }
    
    @objc func timePrinter() -> Void {
        
        let nextTime = userDefaults.value(forKey: "nextRefreshTime") as! Date
            
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
            
        // convert the date to string using the date formatter
        let nextTimeAsString = formatter.string(from: nextTime)
        let time = timeCalculator(dateFormat: "MM/dd/yyyy hh:mm:ss a", endTime: nextTimeAsString)

        timeOfNextAvailableNewsDrop.text = "\(time.month!) Months \(time.day!) Days \(time.minute!) Minutes \(time.second!) Seconds"
        
    }
    
    func timeCalculator(dateFormat: String, endTime: String, startTime: Date = Date()) -> DateComponents {
        /*
        formatter.dateFormat = dateFormat
        let _startTime = startTime
        let _endTime = formatter.date(from: endTime)
        */
        
        let timeDifference = userCalender.dateComponents(requestedComponent, from: _startTime, to: _endTime!)
        return timeDifference
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
    
}
