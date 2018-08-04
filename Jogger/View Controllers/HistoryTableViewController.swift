//
//  HistoryTableViewController.swift
//  Jogger
//
//  Created by Ashley Paradis on 2018-05-23.
//  Copyright © 2018 Ashley Paradis. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Kingfisher

class HistoryTableViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var run:Run?
    var progressView:UIActivityIndicatorView!
    var cell:UITableViewCell!
    
    var refUsers:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("History", comment: "History")
        
        self.refUsers = Database.database().reference().child("user")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tableView.reloadData()
        
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
        return self.appDelegate.runHistoryList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if self.appDelegate.runHistoryList.count > 0 {
            let run = self.appDelegate.runHistoryList[indexPath.row]
            cell.textLabel?.text = run.runDate
            if self.appDelegate.unitKm == true {
                let runInts:Int = Int(run.runDuration)!
                let runString = String(format: "%02d:%02d:%02d", runInts / 3600, (runInts % 3600) / 60, (runInts % 3600) % 60)
                cell.detailTextLabel?.text = "\(run.runDistance)km - \(runString)"
            } else {
                var runDistance = Double(run.runDistance)!
                runDistance = runDistance/0.621371
                cell.detailTextLabel?.text = String(format: "%.3f miles - \(run.runDuration)", runDistance)
            }
            cell.imageView?.clipsToBounds = true
            cell.imageView?.contentMode = .scaleAspectFit
            
            if run.runImage != nil {
                cell.imageView?.image = self.run?.runImage
            } else {
                let imageRef = Storage.storage().reference().child("runImages").child((Auth.auth().currentUser?.uid)!).child(run.runId)
                imageRef.downloadURL { url, error in
                    if error != nil {
                        print("error downloading image")
                    } else {
                        do {
                            let image = self.cell.imageView?.kf.setImage(with: url)
                            self.run?.runImage? = image as! UIImage
                            }
                        }
                    }
                }
            }
        
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.appDelegate.segueFromTableView = true
        run = self.appDelegate.runHistoryList[indexPath.row]
        performSegue(withIdentifier: "showHistoryDetailVC", sender: self)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showHistoryDetailVC" {
            let detailVC = segue.destination as! HistoryDetailViewController
            detailVC.run = self.run
        }
    }

}
