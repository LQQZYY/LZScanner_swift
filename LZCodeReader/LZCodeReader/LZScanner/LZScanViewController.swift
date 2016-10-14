//
//  LZScanViewController.swift
//  LZCodeReader
//
//  Created by Artron_LQQ on 2016/10/14.
//  Copyright © 2016年 Artup. All rights reserved.
//
/*
 iOS 10 需要在info.plist添加以下字段
 
 <key>NSPhotoLibraryUsageDescription</key>
 <string>App需要您的同意,才能访问相册</string>
 
 <key>NSCameraUsageDescription</key>
 <string>App需要您的同意,才能访问相机</string>
 
 */


import UIKit

var sholdShowNaviBar = false
typealias resultCallBack = (_ result: String) -> Void
class LZScanViewController: UIViewController, LZScannerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var scanner: LZScanner!
    var scanView: LZScanView!
    var callBack: resultCallBack?
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (self.navigationController?.isNavigationBarHidden)! {
            sholdShowNaviBar = false
        } else {
            sholdShowNaviBar = true
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.scanner.startScan()
        self.scanView.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.scanner.stopScan()
        self.scanView.stop()
        if sholdShowNaviBar == true {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 使用通知监听app进入后台
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterFpreground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        self.createScanView()
        self.customNaviBar()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }

    func enterBackground() {
        
        self.scanView.stop()
        self.scanner.stopScan()
    }
    
    func enterFpreground() {
        
        self.scanner.startScan()
        self.scanView.start()
    }
    
    func createScanView() {
        
        self.scanner = LZScanner.init(frame: self.view.bounds)
        self.scanner.delegate = self
        self.view.addSubview(self.scanner)
        
        self.scanView = LZScanView.init(frame: self.view.bounds)
        self.view.addSubview(self.scanView)
        
        self.scanner.scanArea = self.scanView.windowRect
    }
    
    func scanner(_ scan: LZScanner, didScanned result: String) {
        self.scanView.stop()
        
        print("扫描结果: ", result)
        if let call = self.callBack  {
            
            call(result)
        }
        
        self.backButtonClick()
    }
    func customNaviBar() {
        
        let backButton = UIButton.init(type: .custom)
        backButton.frame = CGRect.init(x: 10, y: 20, width: 60, height: 44)
        backButton.setImage(UIImage.init(named: reader_scan_btn_back_nor), for: .normal)
        backButton.setImage(UIImage.init(named: reader_scan_btn_back_pressed), for: .highlighted)
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        
        self.view.addSubview(backButton)
        
        let libButton = UIButton.init(type: .custom)
        libButton.center = CGPoint.init(x: self.view.center.x, y: 44)
        libButton.bounds = CGRect.init(x: 0, y: 0, width: 36, height: 44)
        
        libButton.setImage(UIImage.init(named: reader_scan_btn_photoDown), for: .highlighted)
        libButton.setImage(UIImage.init(named: reader_scan_btn_photoNor), for: .normal)
        libButton.addTarget(self, action: #selector(openPhotoLib), for: .touchUpInside)
        self.view.addSubview(libButton)
        
        let torchButton = UIButton.init(type: .custom)
        torchButton.frame = CGRect.init(x: self.view.frame.width - 46, y: 20, width: 36, height: 44)
        
        torchButton.setImage(UIImage.init(named: reader_scan_btn_flashOff), for: .selected)
        torchButton.setImage(UIImage.init(named: reader_scan_btn_flashNor), for: .normal)
        torchButton.setImage(UIImage.init(named: reader_scan_btn_flashDown), for: .highlighted)
        torchButton.addTarget(self, action: #selector(openTorch), for: .touchUpInside)
        
        self.view.addSubview(torchButton)
        
    }
    
    func backButtonClick() {
        
        if self.navigationController != nil {
            
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func openPhotoLib() {
        
        let controller = UIImagePickerController.init()
        controller.delegate = self
        controller.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func openTorch(button: UIButton) {
        button.isSelected = !button.isSelected
        
        LZScanner.turnTorchOn(on: button.isSelected)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        LZScanner.scanImage(image) { (result) in
            
            if let call = self.callBack  {
                
                call(result)
            }
        }
        picker.dismiss(animated: true) { 
            
            self.backButtonClick()
        }
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
