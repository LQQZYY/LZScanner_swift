//
//  UIImageView+LongPress.swift
//  LZCodeReader
//
//  Created by Artron_LQQ on 2016/10/14.
//  Copyright © 2016年 Artup. All rights reserved.
//

import UIKit

typealias pressResult = (_ string: String) -> Void
private var resultBack: pressResult?
private var isAlreadyAlert = false

extension UIImageView {

    
    func longPressScan(_ result: @escaping pressResult) {
        
        self.isUserInteractionEnabled = true
        let press = UILongPressGestureRecognizer.init(target: self, action: #selector(lognPress))
        self.addGestureRecognizer(press)
        
        resultBack = result
    }
    
    @objc private func lognPress() {
        
        if isAlreadyAlert == true {
            
            return
        }
        
        isAlreadyAlert = true
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let scan = UIAlertAction.init(title: "识别图中二维码", style: .default) { (action) in
            
            LZScanner.scanImage(self.image!, result: { (string) in
                
                if let result = resultBack {
                    result(string)
                }
            })
            
            isAlreadyAlert = false
        }
        
        let cancel = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
            
            isAlreadyAlert = false
        }
        
        alert.addAction(scan)
        alert.addAction(cancel)
        
        let vc = UIApplication.shared.keyWindow?.rootViewController
        
        vc?.present(alert, animated: true, completion: nil)
    }
}
