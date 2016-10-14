//
//  LZScanView.swift
//  LZCodeReader
//
//  Created by Artron_LQQ on 2016/10/14.
//  Copyright © 2016年 Artup. All rights reserved.
//

import UIKit

class LZScanView: UIView {

    var windowRect: CGRect? {
        
        get {
            
            return self.cameraFrameView?.frame
        }
    }
    
    private var overlayView: LZScanOverlayView!
    private var cameraFrameView: UIImageView!
    private var scanLineView: UIImageView!
    private var warnLabel: UILabel!
    private var activity: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.loadSubViews()
    }
    
    deinit {
        print("deinit")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func start() {
        
        if (activity?.isAnimating)! {
            
            activity?.stopAnimating()
        }
        
        UIView.animate(withDuration: 2, delay: 0, options: UIViewAnimationOptions.repeat, animations: { 
            
            self.scanLineView?.center = CGPoint.init(x: self.center.x, y: (self.cameraFrameView?.frame.origin.y)! + (self.cameraFrameView?.frame.height)! - 20)
            
            }) { (finished) in
                
        }
    }
    
    func stop() {
        
        self.scanLineView?.layer.removeAllAnimations()
        self.scanLineView?.center = CGPoint.init(x: self.center.x, y: (self.cameraFrameView?.frame.origin.y)! + 20)
    }
    
    
    private func loadSubViews() {
        
        if self.overlayView == nil {
            
            self.overlayView = LZScanOverlayView.init(frame: self.bounds)
            self.addSubview(self.overlayView!)
        }
        
        let size = self.overlayView?.windowFrame?.size
        
        if self.cameraFrameView == nil {
            
            self.cameraFrameView = UIImageView.init(image: UIImage.init(named: reader_scan_scanCamera))
            self.cameraFrameView?.center = (self.overlayView?.windowCenter)!
            
            self.cameraFrameView?.bounds = CGRect.init(x: 0, y: 0, width: (size?.width)! + 8, height: (size?.height)! + 8)
            
            self.addSubview(self.cameraFrameView!)
        }
        
        if self.scanLineView == nil {
            
            self.scanLineView = UIImageView.init(image: UIImage.init(named: reader_scan_scanLine))
            self.scanLineView?.center = CGPoint.init(x: self.center.x, y: (self.cameraFrameView?.frame.origin.y)! + 20)
            self.scanLineView?.bounds = CGRect.init(x: 0, y: 0, width: (self.cameraFrameView?.frame.size.width)!, height: 20)
            
            self.addSubview(self.scanLineView)
        }
        
        if self.warnLabel == nil {
            
            self.warnLabel = UILabel.init()
            self.warnLabel.center = CGPoint.init(x: self.center.x, y: (self.overlayView.windowCenter?.y)! + (self.overlayView.windowFrame?.size.height)!/2.0 + 40)
            
            // 如果要显示在中间位置,可这样设置
//            self.warnLabel.center = self.overlayView.windowCenter!
            self.warnLabel.bounds = CGRect.init(x: 0, y: 0, width: self.bounds.width - 40, height: 20)
            self.warnLabel.text = reader_scan_warnMsg
            self.warnLabel.textAlignment = .center
            self.warnLabel.font = UIFont.systemFont(ofSize: 14)
            self.warnLabel.textColor = UIColor.white
            
            self.addSubview(self.warnLabel)
        }
        
        if self.activity == nil {
            
            self.activity = UIActivityIndicatorView.init(activityIndicatorStyle: .white)
            self.activity.center = self.cameraFrameView.center
            self.activity.bounds = CGRect.init(x: 0, y: 0, width: 50, height: 50)
            
            self.addSubview(self.activity)
        }
        
        self.activity.startAnimating()
        
        self.perform(#selector(start), with: nil, afterDelay: 1.0)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

class LZScanOverlayView: UIView {
    
    var windowCenter: CGPoint? {
        get {
            
            let smallestIdmesion = min(self.bounds.width, self.bounds.height)
            
            let windowSize = smallestIdmesion * (self.isIpad() ? 0.6 : 0.7)
            
            let windowX = self.frame.midX - windowSize/2.0
            let windowY = 20 + 49 + (self.isIphone4() ? windowX/2.0 : windowX)
            
            return CGPoint.init(x: windowX + windowSize/2.0, y: windowY + windowSize/2.0)
        }
    }
    
    var windowFrame: CGRect? {
        get {
            
            let smallestIdmesion = min(self.bounds.width, self.bounds.height)
            
            let windowSize = smallestIdmesion * (self.isIpad() ? 0.6 : 0.7)
            
            let windowX = self.frame.midX - windowSize/2.0
            let windowY = 20 + 49 + (self.isIphone4() ? windowX/2.0 : windowX)
            
            return CGRect.init(x: windowX, y: windowY, width: windowSize, height: windowSize)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isOpaque = false
        
        self.autoresizingMask = [UIViewAutoresizing.flexibleWidth,UIViewAutoresizing.flexibleHeight]
        self.layer.needsDisplayOnBoundsChange = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        UIColor.init(white: 0, alpha: 0.7).setFill()
        UIColor.init(white: 0, alpha: 0.7).setStroke()
        
        let smallestIdmesion = min(self.bounds.width, self.bounds.height)
        
        let windowSize = smallestIdmesion * (self.isIpad() ? 0.6 : 0.7)
        
        let windowX = rect.midX - windowSize/2.0
        let windowY = 20 + 49 + (self.isIphone4() ? windowX/2.0 : windowX)
        
        let frame = CGRect.init(x: windowX, y: windowY, width: windowSize, height: windowSize)
        context!.fill(rect)
        context?.clear(frame)
        context?.stroke(frame)
    }
    
    func isIphone4() -> Bool {
        
        let size = UIScreen.main.currentMode?.size
        
        return size!.equalTo(CGSize.init(width: 640, height: 960))
    }
    
    func isIpad () -> Bool {
        
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
}














