//
//  ViewController.swift
//  Erin_20170424
//
//  Created by Erin on 24/4/2017.
//  Copyright © 2017 Erin. All rights reserved.
//

import UIKit

class TableViewCell1 : UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var lateCountLabel: UILabel!
}

class ViewController: UIViewController, UITableViewDataSource {
    
    var fetechedColleague = [Colleague]()
    @IBOutlet weak var colleagueTableView: UITableView!
    @IBOutlet weak var Controller: UISegmentedControl!
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    var default_mode = "teamA"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colleagueTableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(ViewController.refreshData), for: UIControlEvents.valueChanged)
        
        var title = "Pull to refresh Content\n"
        refreshControl.attributedTitle = NSAttributedString(string: title)
        
        if #available(iOS 10.0, *){
            colleagueTableView.refreshControl = refreshControl
        }else{
            colleagueTableView.addSubview(refreshControl)
        }
        getDataFromURL()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func refreshData() {
        viewDidLoad()
        refreshControl.endRefreshing()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch default_mode {
            case "teamA":
                let filter_count = fetechedColleague.filter{$0.late_count <= 5}.count
                return filter_count
            case "teamB":
                let filter_count = fetechedColleague.filter{$0.late_count > 5}.count
                return filter_count
            default:
                let filter_count = fetechedColleague.filter{$0.late_count <= 5}.count
                return filter_count
        }
        //return fetechedColleague.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = colleagueTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell1

        switch default_mode {
        case "teamA":
            print ("debug: teamA")
            let tmp_obj = fetechedColleague.filter{$0.late_count <= 5}
        
            // avatar img
            let tmp_url = tmp_obj[indexPath.row].avatar
            let url = URL(string:tmp_url)
            let data = try! Data(contentsOf: url!)
            
            // team
            let team_string = tmp_obj[indexPath.row].teams.joined(separator: " / ")
            
            cell.avatarImageView?.image = UIImage(data:data)
            cell.nameLabel?.text = tmp_obj[indexPath.row].name
            cell.teamLabel?.text = team_string
            cell.lateCountLabel?.text = String(tmp_obj[indexPath.row].late_count)
            
        case "teamB":
            print ("debug: teamB")
            let tmp_obj = fetechedColleague.filter{$0.late_count > 5}
            
            // avatar img
            let tmp_url = tmp_obj[indexPath.row].avatar
            let url = URL(string:tmp_url)
            let data = try! Data(contentsOf: url!)
            
            // team
            let team_string = tmp_obj[indexPath.row].teams.joined(separator: " / ")
            
            cell.avatarImageView?.image = UIImage(data:data)
            cell.nameLabel?.text = tmp_obj[indexPath.row].name
            cell.teamLabel?.text = team_string
            cell.lateCountLabel?.text = String(tmp_obj[indexPath.row].late_count)
            
        default:
            print ("debug: default")
            let tmp_obj = fetechedColleague.filter{$0.late_count <= 5}

            // avatar img
            let tmp_url = tmp_obj[indexPath.row].avatar
            let url = URL(string:tmp_url)
            let data = try! Data(contentsOf: url!)
            
            // team
            let team_string = tmp_obj[indexPath.row].teams.joined(separator: " / ")
            
            cell.avatarImageView?.image = UIImage(data:data)
            cell.nameLabel?.text = tmp_obj[indexPath.row].name
            cell.teamLabel?.text = team_string
            cell.lateCountLabel?.text = String(tmp_obj[indexPath.row].late_count)

        }
        return cell
    }
    
    @IBAction func ChangeContent(_ sender: Any) {
        if Controller.selectedSegmentIndex == 0{
            default_mode = "teamA"
        }
        if Controller.selectedSegmentIndex == 1{
            default_mode = "teamB"
        }
        reload()
    }
    
    func reload() {
        DispatchQueue.main.async() {
            //self.fetechedColleague.removeAll()
            
            self.colleagueTableView.reloadData()
        }
    }
    
    func getDataFromURL(){
        
        fetechedColleague = []
        
        let url = "http://hiring.hkdev.motherapp.com/api/mausers/?format=json"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if (error != nil){
                print("Error")
            }else{
                do {
                    let fetchedData = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSArray
                    //print(fetchedData)
                    for eachFetchedColleague in fetchedData {
                        let eachColleague = eachFetchedColleague as! [String : Any]
                        let name = eachColleague["name"] as! String
                        let avatar = eachColleague["avatar"] as! String
                        let late_count = eachColleague["late_count"] as! Int
                        let lates = eachColleague["lates"] as! [String]
                        let teams = eachColleague["teams"] as! [String]
                        
                        self.fetechedColleague.append(Colleague(name:name,avatar:avatar,late_count:late_count,lates:lates,teams:teams))
                    }
                    //print(self.fetechedColleague)
                    //self.colleagueTableView.reloadData()
                    //self.default_mode = "teamA"
                    self.reload()
                    
                }
                catch{
                    print("Error2")
                }
            }
            
        }
        task.resume()
        
    }
}

class Colleague {
    var name: String
    var avatar: String
    var late_count: Int
    var lates: [String]
    var teams: [String]
    
    init(name:String,avatar:String,late_count:Int,lates:[String],teams:[String]){
        self.name = name
        self.avatar = avatar
        self.late_count = late_count
        self.lates = lates
        self.teams = teams
    }
}


