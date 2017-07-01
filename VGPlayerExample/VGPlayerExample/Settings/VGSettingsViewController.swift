//
//  VGSettingsViewController.swift
//  VGPlayerExample
//
//  Created by Vein on 2017/7/1.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit
import VGPlayer

class VGSettingsViewController: UIViewController {
    @IBOutlet weak var settingsInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VGPlayerCacheManager.shared.cacheConfig.maxCacheSize = 160000000
        getPlayerCacheInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPlayerCacheInfo()
    }
    
    func getPlayerCacheInfo() {
        let maxCacheSize = VGPlayerCacheManager.shared.cacheConfig.maxCacheSize
        VGPlayerCacheManager.shared.calculateCacheSize { (size) in
            self.settingsInfoLabel.text = String(format: "Maximum cache: %lld   Current cache size: %lld", maxCacheSize, size)
        }
        
    }

    @IBAction func onCleanAllcache(_ sender: Any) {
        VGPlayerCacheManager.shared.cleanAllCache()
        getPlayerCacheInfo()
    }

    @IBAction func onCleanOldFiles(_ sender: Any) {
        VGPlayerCacheManager.shared.cleanOldFiles {
            self.getPlayerCacheInfo()
        }
    }
}
