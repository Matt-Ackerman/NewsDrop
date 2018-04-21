//
//  ViewController.swift
//  TableViewTest
//
//  Created by Matt Ackerman on 4/8/18.
//  Copyright © 2018 Matthew Ackerman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // table to be populated with news articles.
    @IBOutlet weak var tableView: UITableView!
    
    // label that changes to countdown for next news release.
    @IBOutlet weak var timeOfNextAvailableNewsDrop: UILabel!
    
    // pull down refresher.
    var refresher: UIRefreshControl!
    
    // dictionary of stored values.
    let userDefaults = UserDefaults.standard

    // articles gathered from api.
    var articles = [News]()
    
    // list of empty placeholder strings to fill the table rows until populated with news.
    var tableRows:[String] = [
        "", "", "", "", "",
        "", "", "", "", "",
        "", "", "", "", "",
        "", "", "", "", ""
    ]
    
    // code is ran any time the application has been loaded after being closed.
    override func viewDidLoad() {
        super.viewDidLoad()
 
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull for news")
        refresher.frame.origin = CGPoint(x: 20, y: 10)
        refresher.addTarget(self, action: #selector(ViewController.reloadTableWithNews), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
    }

    // what to do if the application produces a memory warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // returns how many rows we want in our table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRows.count
    }
    
    // generates the cell specification and formatting for each table row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // set cell's text and make the text wrap
        cell.textLabel?.text = String(tableRows[indexPath.row])
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        return cell
    }
    
    // on click event for each row which sends user to article url.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!tableRows[indexPath.row].isEmpty) {
            let url = URL(string: articles[indexPath.row].siteUrl)
            UIApplication.shared.openURL(url!)
        }
    }
    
    // asynchronously loads news articles if the user is allowed to at this time. otherwise, starts countdown to said time.
    @objc func reloadTableWithNews() {
        if (shouldAllowRefresh() == true) {
            DispatchQueue.main.async {
                self.getNews()
                self.tableView.reloadData()
            }
        } else {
            displayCountdownToNextRefresh()
        }
        self.refresher.endRefreshing()
    }
    
    // determines whether it is time to allow the user to refresh their news.
    func shouldAllowRefresh() -> Bool {
        
        if (UserDefaults.standard.object(forKey: "dateOfNextNews") == nil) {
            return true
        } else {
            let dateOfNextNews = userDefaults.value(forKey: "dateOfNextNews") as! Date
            if (dateOfNextNews < Date()) {
                return true
            } else {
                return false
            }
        }
    }
    
    // loads news articles via the News class.
    func getNews() {
        News.getNews { (results:[News]) in
            for result in results {
                self.articles.append(result)
            }
            self.setText()
        }
        markThatUserGotNewsAndSetNextDate()
        displayCountdownToNextRefresh()
    }
    
    // calculates and saves userDefault values for dateOfLastNews and dateOfNextNews to userDefaults dictionary.
    func markThatUserGotNewsAndSetNextDate() {
        let current = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: current)

        userDefaults.setValue(current, forKey: "dateOfLastNews")
        userDefaults.synchronize()
        
        var nextNews: Date!
        if (currentHour >= 19) {
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: current)
            nextNews = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: tomorrow!)
            
        } else {
            nextNews = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: current)
        }
        
        userDefaults.setValue(nextNews, forKey: "dateOfNextNews")
        userDefaults.synchronize()
    }
    
    // this is called if it is not time to refresh the news. starts countdown.
    func displayCountdownToNextRefresh() {
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timePrinter), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    // retrieves time for next refresh and prints amount of time until then.
    @objc func timePrinter() -> Void {
        let nextTime = userDefaults.value(forKey: "dateOfNextNews") as! Date
        
        let timeDifference = timeCalculator(dateFormat: "yyyy-mm-dd hh:mm:ss a", endTime: nextTime)
        timeOfNextAvailableNewsDrop.font = UIFont(name: "Times New Roman", size: 25)
        timeOfNextAvailableNewsDrop.text = "\(timeDifference.hour!):\(timeDifference.minute!):\(timeDifference.second!)"
    }
    
    // calculates difference between two times.
    func timeCalculator(dateFormat: String, endTime: Date, startTime: Date = Date()) -> DateComponents {
        let requestedComponent : Set<Calendar.Component> = [
            Calendar.Component.hour,
            Calendar.Component.minute,
            Calendar.Component.second
        ]
        
        let userCalender = Calendar.current;
        let timeDifference = userCalender.dateComponents(requestedComponent, from: startTime, to: endTime)
        
        return timeDifference
    }
    
    // sets our table rows to our articles.
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
