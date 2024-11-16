//
//  CaptureTextApp.swift
//  CaptureText
//
//  Created by shenruqi on 10/13/24.
//

import SwiftUI
import ModelScope

@main
struct CaptureTextApp: App {
    private let modelScope: ModelScope.DownloadManager = ModelScope.DownloadManager("RiverRay/whisperkit-coreml")
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear() {
//                    Task {
//                         await modelScope.downloadModel(downFolder: "/Users/shenruqi/Desktop/Code/IOSAppLearn/ModelScope",  modelId: "openai_whisper-large-v3-v20240930_626MB" , progress: { progress in
//                            print("progress:::", progress)
//                         }) { _ in}
//                    }
                }
        }
    }
}
