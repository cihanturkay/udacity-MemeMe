//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Cihan Turkay on 26/05/2017.
//  Copyright © 2017 Cihan Turkay. All rights reserved.
//

import UIKit


class MemeTableViewController: UITableViewController {
    
    var memes: [Meme]!
    let tableFooterView:UIView = UIView(frame: .zero);
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        self.tableView?.reloadData()
        tableView.tableFooterView = tableFooterView
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return self.memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MemeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MemeTableViewCell", for: indexPath) as! MemeTableViewCell
        let meme = self.memes[(indexPath as NSIndexPath).row]
        cell.memedImage?.image = meme.memedImage
        cell.memeText?.text = meme.topText + " " + meme.bottomText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            memes.remove(at: (indexPath as NSIndexPath).row)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.memes = memes
            self.tableView?.reloadData()
        }
    }
    
}
