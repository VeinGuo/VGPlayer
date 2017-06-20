//
//  VGMainViewController.swift
//  VGPlayer-Example
//
//  Created by Vein on 2017/6/8.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit

class VGMainViewController: UITableViewController {
    
    let dataSource = ["Normal Player", "Vertical Player", "Custom Player", "Custom Player 2"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        cell.textLabel?.text = dataSource[indexPath.row]
        cell.accessoryType = .disclosureIndicator
    
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            performSegue(withIdentifier: "VGMediaViewController", sender: dataSource[indexPath.row])
        } else if indexPath.row == 1{
            performSegue(withIdentifier: "VGVerticalViewController", sender: dataSource[indexPath.row])
        } else if indexPath.row == 2 {
            performSegue(withIdentifier: "VGCustomViewController", sender: dataSource[indexPath.row])
        } else {
            performSegue(withIdentifier: "VGCustomViewController2", sender: dataSource[indexPath.row])
        }
    }
}
