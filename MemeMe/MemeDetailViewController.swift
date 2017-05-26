//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Cihan Turkay on 26/05/2017.
//  Copyright © 2017 Cihan Turkay. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    var meme:Meme!
    
    @IBOutlet weak var imageview: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageview.image = meme.memedImage
    }
    
    
}
