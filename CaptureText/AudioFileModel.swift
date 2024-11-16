//
//  AudioFileModel.swift
//  CaptureText
//
//  Created by shenruqi on 11/16/24.
//

import SwiftUI
import AVFoundation

class AudioFileModel: ObservableObject {
    @Published var exportInProgress : Bool = false
    @Published  var exportCompleted : Bool = false
    @Published  var exportError: String?
    
    init(){}
    
    
    func exportAudioFile(inVideoUrl: URL) {
           // 打开文件保存面板
           let savePanel = NSSavePanel()
           savePanel.allowedFileTypes = ["wav"] // 只允许保存为 .m4a 文件
           savePanel.nameFieldStringValue = "exported_audio.wav"

           savePanel.begin { response in
               if response == .OK, let exportUrl = savePanel.url {
                   // 如果用户选择了路径，开始导出
                   self.exportInProgress = true
                   self.extractAudioTo(url: exportUrl, inVideoUrl: inVideoUrl) { result in
                       DispatchQueue.main.async {
                           self.exportInProgress = false
                           switch result {
                           case .success:
                               self.exportCompleted = true
                               self.exportError = nil
                           case .failure(let error):
                               self.exportCompleted = false
                               self.exportError = error.localizedDescription
                           }
                       }
                   }
               }
           }
       }
    
    private func extractAudioTo(url: URL, inVideoUrl: URL, completion: @escaping (Result<Void, Error>) -> Void) {
            // 视频文件路径（测试用）
            let videoUrl = inVideoUrl
        

            let asset = AVAsset(url: videoUrl)
            guard asset.tracks(withMediaType: .audio).count > 0 else {
                completion(.failure(NSError(domain: "ExtractAudio", code: -1, userInfo: [NSLocalizedDescriptionKey: "视频中不包含音频轨道"])))
                return
            }

            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
                completion(.failure(NSError(domain: "ExtractAudio", code: -2, userInfo: [NSLocalizedDescriptionKey: "无法创建 AVAssetExportSession"])))
                return
            }

        exportSession.outputFileType = .m4a
            exportSession.outputURL = url
        exportSession.exportAsynchronously {
                   switch exportSession.status {
                   case .completed:
                       completion(.success(()))
                   case .failed:
                       if let error = exportSession.error {
                           completion(.failure(error))
                       } else {
                           completion(.failure(NSError(domain: "ExtractAudio", code: -3, userInfo: [NSLocalizedDescriptionKey: "导出失败"])))
                       }
                   case .cancelled:
                       completion(.failure(NSError(domain: "ExtractAudio", code: -4, userInfo: [NSLocalizedDescriptionKey: "导出被取消"])))
                   default:
                       completion(.failure(NSError(domain: "ExtractAudio", code: -5, userInfo: [NSLocalizedDescriptionKey: "未知导出状态"])))
                   }
               }
           }
}
