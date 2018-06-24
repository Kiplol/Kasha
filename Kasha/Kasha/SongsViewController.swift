//
//  SongsViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/18/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import SwiftIcons
import UIKit

class SongsViewController: KashaViewController {
    
    var songs: [MPMediaItem] = []
    
    class func fromStoryboard() -> SongsViewController {
        let vc =  UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "songs")
        if let songsVC = vc as? SongsViewController {
            return songsVC
        } else {
            preconditionFailure("That wasn't a SongsViewController")
        }
    }
    
    // MARK: - KashaViewController
    override func commonInit() {
        super.commonInit()
        self.title = "Albums"
        self.tabBarItem.image = UIImage.init(icon: .googleMaterialDesign(.audiotrack),
                                             size: CGSize(width: 50.0, height: 50.0))
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
