//
//  LZScanner.swift
//  LZCodeReader
//
//  Created by Artron_LQQ on 2016/10/14.
//  Copyright © 2016年 Artup. All rights reserved.
//
/*
 * 二维码扫描的扫描控制类,功能:
 *
 * 开始扫描
 * 停止扫描
 * 正在扫描
 * 输出扫描结果
 */

import UIKit
import AVFoundation

// 扫描结果返回代理
protocol LZScannerDelegate {
    
    func scanner(_ scan: LZScanner, didScanned result: String)
}

class LZScanner: UIView ,AVCaptureMetadataOutputObjectsDelegate {

    // 有效扫描区域设置
    var scanArea: CGRect? {
        
        didSet {
            
            let output = self.session.outputs.first as! AVCaptureMetadataOutput
            output.rectOfInterest = self.setScanAreaWith(bound: scanArea!)
        }
    }
    // 代理设置
    var delegate: LZScannerDelegate?
    
    private var session: AVCaptureSession!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if LZScanner.isCaremaEnable() {
            
            if frame.size.width > 0 {
                
                self.frame = frame
            } else {
                
                self.frame = (UIApplication.shared.keyWindow?.bounds)!
            }
            
            self.createSession()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 开启灯光
    static func turnTorchOn(on: Bool) {
        
        let caputreDevice: AnyClass? = NSClassFromString("AVCaptureDevice")
        if caputreDevice != nil {
            
            let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            if (device?.hasTorch)! && (device?.hasFlash)! {
                
                do {
                    try device?.lockForConfiguration()
                    
                    if on == true {
                        
                        device?.torchMode = .on
                        if #available(iOS 10.0, *) {
                            let setting = AVCapturePhotoSettings.init()
                            setting.flashMode = .on
                        } else {
                            // Fallback on earlier versions
                            device?.flashMode = AVCaptureFlashMode.on
                        }
                        
                        
                    } else {
                        
                        device?.torchMode = .off
                        if #available(iOS 10.0, *) {
                            let setting = AVCapturePhotoSettings.init()
                            setting.flashMode = .off
                        } else {
                            // Fallback on earlier versions
                            device?.flashMode = AVCaptureFlashMode.off
                        }
                        
                    }
                    
                    device?.unlockForConfiguration()
                } catch  {
                    
                }
            }
        }
    }
    
    /// 识别图片中的二维码
    ///
    /// - parameter image:  含有二维码的图片
    /// - parameter result: 返回扫描结果
    static func scanImage(_ image: UIImage, result:(_ result: String)->()) {
        
        let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        
        let features = detector?.features(in: CIImage.init(cgImage: image.cgImage!))
        
        var scanResult: String!
        if (features?.count)! >= 1 {
            
            let feature = features?.first as! CIQRCodeFeature
            
            scanResult = feature.messageString
        } else {
            
            scanResult = "无结果"
        }
        
        result(scanResult)
    }
    
    // 检查相机是否被用户允许使用
    static func isCaremaEnable() -> Bool {
        
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) 
        
        if authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.denied {
            
            return false
        } else {
            
            return true
        }
    }
    
    /// 开始扫描
    func startScan() {
        
        self.session.startRunning()
    }
    
    /// 停止扫描
    func stopScan() {
        
        self.session.stopRunning()
    }
    
    /// 正在扫描
    ///
    /// - returns: 扫描状态
    func isScanning() -> Bool {
        
        return self.session.isRunning
    }
    
    //MARK: - 私有方法
    /// 创建会话,初始化扫描器
    private func createSession() {
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput.init(device: device)
            
            let output = AVCaptureMetadataOutput.init()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // 设置有效扫描区域
            output.rectOfInterest = self.setScanAreaWith(bound: self.bounds)
            
            self.session = AVCaptureSession.init()
            self.session.sessionPreset = AVCaptureSessionPresetHigh
            
            self.session.addInput(input)
            self.session.addOutput(output)
            self.session.sessionPreset = AVCaptureSessionPreset640x480
            
            // 设置扫码支持的编码格式(以下支持条形码和二维码)
            output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code]
            
            let layer = AVCaptureVideoPreviewLayer.init(session: self.session)
            
            layer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            layer?.frame = self.layer.bounds
            self.layer.insertSublayer(layer!, at: 0)
            
            self.session.startRunning()
        } catch  {
            // 创建输入流失败的操作
        }
    }
    // 获取扫描结果
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        self.stopScan()
        var result: String?
        
        if metadataObjects.count > 0 {
            
            let metadataObj = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            
            result = metadataObj.stringValue
        } else {
            
            result = "无结果"
        }
        
        if delegate != nil{
            
            delegate?.scanner(self, didScanned: result!)
        }
    }
    
    // 设置扫描的有效区域
    private func setScanAreaWith(bound: CGRect) -> CGRect {
        
        var orginX: CGFloat = 0.0, orginY: CGFloat = 0.0, width: CGFloat = 0.0, height: CGFloat = 0.0
        let rect = self.frame
        
        orginX = bound.minY/rect.height
        
        orginY = bound.minX/rect.width
        
        width = bound.height/rect.height
        
        height = bound.width/rect.width
        
        return CGRect.init(x: orginX, y: orginY, width: width, height: height)
    }
}
