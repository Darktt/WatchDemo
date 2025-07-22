//
//  ContentView.swift
//  WatchClient Watch App
//
//  Created by Eden on 2025/7/22.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View
{
    @StateObject private var connectivityManager = WatchConnectivityManager()
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text("Apple Watch")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("顏色顯示器")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            if self.connectivityManager.isConnected {
                
                VStack(spacing: 10) {
                    
                    Text("當前顏色:")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(self.connectivityManager.currentColorName)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            } else {
                
                VStack(spacing: 5) {
                    
                    Text("等待連接...")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("請在 iPhone 上選擇顏色")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(self.connectivityManager.backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
}

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate
{
    @Published var isConnected = false
    @Published var backgroundColor = Color.black
    @Published var currentColorName = "預設"
    
    override
    init()
    {
        super.init()
        self.setupWatchConnectivity()
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
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?)
    {
        DispatchQueue.main.async {
            
            self.isConnected = (activationState == .activated) && session.isCompanionAppInstalled
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void)
    {
        DispatchQueue.main.async {
            
            if let colorName = message["colorName"] as? String,
               let red = message["red"] as? Double,
               let green = message["green"] as? Double,
               let blue = message["blue"] as? Double,
               let alpha = message["alpha"] as? Double {
                
                self.currentColorName = colorName
                self.backgroundColor = Color(red: red, green: green, blue: blue, opacity: alpha)
                
                // 回覆確認訊息
                replyHandler(["status": "success", "message": "顏色已更新"])
            } else {
                
                replyHandler(["status": "error", "message": "無效的顏色資料"])
            }
        }
    }
}

#Preview
{
    ContentView()
}
