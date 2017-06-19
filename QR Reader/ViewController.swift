//
//  ViewController.swift
//  QR Reader
//
//  Created by Kanat A on 19/06/2017.
//  Copyright © 2017 ak. All rights reserved.
//

import UIKit
import AVFoundation

// Программа читает QR Code . Также можно научить программу читать Bar Code

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var infoLabel: UILabel!
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    // Распознование  QR кода основано на захватывании видео

    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Устройство захвата видео
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Получим на входе видео
        do {
            // Создаем input из устройства захвата (камеру)
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // Занимается координацией входных и выходных медиа данных
            captureSession = AVCaptureSession()
            // Подключаем вход к координатору
            captureSession?.addInput(input)
            
            // На выходе получим метадату
            let captureMetadatOutput = AVCaptureMetadataOutput()
            // Подключаем выход к координатору
            captureSession?.addOutput(captureMetadatOutput)
            
            // Посылаем метадату себе в главном потоке
            captureMetadatOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadatOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            videoPreviewLayer =  AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start session capture
            captureSession?.startRunning()
            view.bringSubview(toFront: infoLabel)

            qrCodeFrameView = UIView()
            // Создали красную рамку
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.red.cgColor
                qrCodeFrameView.layer.borderWidth = 3
                
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch  {
            print("Error")
        }
    }

    // Декодируем обнаруженный код
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Проверка
        if metadataObjects == nil || metadataObjects.count == 0 {
            // Спрячем крсаную рамку если код не обнаружен
            qrCodeFrameView?.frame = .zero
            infoLabel.text = "QR Code is not detected"
            
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        let barCodeObj = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
        
        qrCodeFrameView?.frame = (barCodeObj?.bounds)!
        
        if metadataObj.stringValue != nil /* если   метадату можно преоброзовать в строку*/ {
            infoLabel.text = metadataObj.stringValue
        }
        
        
    }
    



}












