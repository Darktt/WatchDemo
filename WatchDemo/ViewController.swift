//
//  ViewController.swift
//  WatchDemo
//
//  Created by Eden on 2025/7/21.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate
{
    
    var statusLabel: UILabel!
    var colorStackView: UIStackView!
    
    override
    func viewDidLoad()
    {
        super.viewDidLoad()
        self.setupUI()
        self.setupWatchConnectivity()
    }
    
    private
    func setupUI()
    {
        self.view.backgroundColor = .systemBackground
        self.title = "顏色選擇器"
        
        // 建立狀態標籤
        let statusLabel = UILabel()
        statusLabel.text = "請選擇一個顏色傳送給 Apple Watch"
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(statusLabel)
        self.statusLabel = statusLabel
        
        // 建立顏色按鈕的 Stack View
        let colorStackView = UIStackView()
        colorStackView.axis = .vertical
        colorStackView.spacing = 20
        colorStackView.alignment = .center
        colorStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(colorStackView)
        self.colorStackView = colorStackView
        
        // 建立顏色按鈕
        let colors: [(String, UIColor)] = [
            ("紅色", .systemRed),
            ("藍色", .systemBlue),
            ("綠色", .systemGreen),
            ("橘色", .systemOrange),
            ("紫色", .systemPurple),
            ("粉紅色", .systemPink),
            ("黃色", .systemYellow),
            ("青色", .systemTeal)
        ]
        
        for (colorName, color) in colors {
            
            let button = self.createColorButton(title: colorName, color: color)
            self.colorStackView.addArrangedSubview(button)
        }
        
        // 設定約束
        NSLayoutConstraint.activate([
            self.statusLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            self.statusLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.statusLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            
            self.colorStackView.topAnchor.constraint(equalTo: self.statusLabel.bottomAnchor, constant: 40),
            self.colorStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.colorStackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 20),
            self.colorStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -20)
        ])
    }
    
    private
    func createColorButton(title: String, color: UIColor) -> UIButton
    {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 設定按鈕大小
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 添加點擊事件
        let action = UIAction {
            
            [weak self] _ in
            
            self?.sendColorToWatch(color: color, name: title)
        }
        
        button.addAction(action, for: .touchUpInside)
        
        return button
    }
    
    private
    func setupWatchConnectivity()
    {
        guard WCSession.isSupported() else {
            
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    private
    func sendColorToWatch(color: UIColor, name: String)
    {
        guard WCSession.default.isReachable else {
            
            self.statusLabel.text = "Apple Watch 未連接或不可達"
            return
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let colorData: [String: Any] = [
            "colorName": name,
            "red": Double(red),
            "green": Double(green),
            "blue": Double(blue),
            "alpha": Double(alpha)
        ]
        
        let replyHandler: ([String : Any]) -> Void = {
            
            [weak self] reply in
            
            DispatchQueue.main.async {
                
                self?.statusLabel.text = "顏色 \(name) 已成功傳送給 Apple Watch"
            }
        }
        
        let errorHandler: (any Error) -> Void = {
            
            [weak self] error in
            
            DispatchQueue.main.async {
                
                self?.statusLabel.text = "傳送失敗：\(error.localizedDescription)"
            }
        }
        
        WCSession.default.sendMessage(colorData, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?)
    {
        DispatchQueue.main.async {
            
            [weak self] in
            
            switch activationState {
                
            case .activated:
                if session.isWatchAppInstalled {
                    
                    self?.statusLabel.text = "已連接到 Apple Watch，請選擇顏色"
                } else {
                    
                    self?.statusLabel.text = "Apple Watch 未安裝應用程式"
                }
                
            case .inactive:
                self?.statusLabel.text = "Watch 連接處於非活動狀態"
                
            case .notActivated:
                self?.statusLabel.text = "Watch 連接未啟動"
                
            @unknown default:
                self?.statusLabel.text = "未知的連接狀態"
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession)
    {
        // iOS 特定的方法
    }
    
    func sessionDidDeactivate(_ session: WCSession)
    {
        // iOS 特定的方法
        session.activate()
    }
}
