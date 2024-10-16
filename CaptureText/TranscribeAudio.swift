//
//  TranscribeAudio.swift
//  CaptureText
//
//  Created by shenruqi on 10/16/24.
//
import SwiftUI
import AVKit
import Vision

import AVFoundation
import Speech



import Security


class TranscribeAudio {
    
    static func transcribeAudio(from videoURL: URL, completion: @escaping ([AudioTranscription]) -> Void) {
        let asset = AVAsset(url: videoURL)
        
        // 检查是否有音频轨道
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            print("No audio track found in the video")
            completion([])
            return
        }
        
        // 创建音频提取会话
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
        let audioOutputURL = FileManager.default.temporaryDirectory.appendingPathComponent("audio.m4a")
        // 如果文件已存在，删除旧文件
        if FileManager.default.fileExists(atPath: audioOutputURL.path) {
            try? FileManager.default.removeItem(at: audioOutputURL)
        }
        
        exportSession?.outputURL = audioOutputURL
        exportSession?.outputFileType = .m4a
        exportSession?.exportAsynchronously {
            switch exportSession?.status {
            case .completed:
                self.recognizeSpeech(audioURL: audioOutputURL, completion: completion)
            case .failed, .cancelled:
                print("Audio extraction failed: \(exportSession?.error?.localizedDescription ?? "Unknown error")")
                completion([])
            default:
                break
            }
        }
    }
    
    static  func recognizeSpeech(audioURL: URL, completion: @escaping ([AudioTranscription]) -> Void) {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))  // 使用中文识别,可以根据需要更改
        
        guard let recognizer = recognizer, recognizer.isAvailable else {
            print("Speech recognition is not available")
            completion([])
            return
        }
        
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false
        
        recognizer.recognitionTask(with: request) { result, error in
            guard let result = result else {
                print("Recognition failed: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            if result.isFinal {
                let transcriptions = result.bestTranscription.segments.map { segment in
                    AudioTranscription(
                        text: segment.substring,
                        startTime: segment.timestamp,
                        endTime: segment.timestamp + segment.duration
                    )
                }
                completion(transcriptions)
            }
        }
    }
    
    
    
     // 字幕合并
    static func mergeTranscriptions(_ transcriptions: [AudioTranscription], intervalDuration: Double = 10.0) -> [AudioTranscription] {
       
        guard !transcriptions.isEmpty else { return [] }
        
        var mergedTranscriptions: [AudioTranscription] = []
        var currentText = ""
        var currentStartTime = transcriptions[0].startTime
        var currentEndTime = transcriptions[0].endTime
        
        for transcription in transcriptions {
            if transcription.startTime - currentStartTime >= intervalDuration {
                // 如果当前转录的开始时间与之前的开始时间相差大于等于10秒,就创建一个新的合并转录
                if !currentText.isEmpty {
                    mergedTranscriptions.append(AudioTranscription(text: currentText.trimmingCharacters(in: .whitespacesAndNewlines),
                                                                   startTime: currentStartTime,
                                                                   endTime: currentEndTime))
                }
                currentText = transcription.text
                currentStartTime = transcription.startTime
                currentEndTime = transcription.endTime
            } else {
                // 否则,继续合并文本
                currentText += " " + transcription.text
                currentEndTime = transcription.endTime
            }
        }
        
        // 添加最后一个合并的转录
        if !currentText.isEmpty {
            mergedTranscriptions.append(AudioTranscription(text: currentText.trimmingCharacters(in: .whitespacesAndNewlines),
                                                           startTime: currentStartTime,
                                                           endTime: currentEndTime))
        }
        
        return mergedTranscriptions
    }
    
 
}
