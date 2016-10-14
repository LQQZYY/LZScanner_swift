//
//  ViewController.swift
//  LZCodeReader
//
//  Created by Artron_LQQ on 2016/10/14.
//  Copyright © 2016年 Artup. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.imageView.longPressScan { (result) in
            
            print("长按识别: ",result);
            self.label.text = result
        }
    }

    @IBAction func beginScan(_ sender: AnyObject) {
        
        let scanVC = LZScanViewController()
        
        scanVC.callBack = {(result) in
            
            self.label.text = result
        }
        self.navigationController?.pushViewController(scanVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

