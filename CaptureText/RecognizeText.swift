//
//  RecognizeText.swift
//  CaptureText
//
//  Created by shenruqi on 10/16/24.
//

import SwiftUI
import AVKit
import Vision

import AVFoundation
import Speech

import ImageIO
import UniformTypeIdentifiers
import Security


class RecognizeText {
    
    
    // 识别图片 文本
    static func recognizeTextInImage(image: CIImage, completion: @escaping ([RecognizedText]) -> Void) {
        
        let request = VNRecognizeTextRequest { request, error in
                    guard let observations = request.results as? [VNRecognizedTextObservation] else {
                        print("无法处理结果")
                        return
                    }
                    // 真实的 x\y\width\height
                    let recognizedTexts = observations.compactMap { observation -> RecognizedText? in
                        guard let candidate = observation.topCandidates(1).first else { return nil }
                        let boundingBox = ImageTool.VNImageRectForNormalizedRect(observation.boundingBox, 1, 1)
                        return RecognizedText(text: candidate.string, boundingBox: boundingBox)
                    }
                    
                    DispatchQueue.main.async {
                        completion(recognizedTexts)
//                        for (index, item) in recognizedTexts.enumerated() {
//                            print("\(index + 1). 文本: \(item.text)")
//                            print("   位置: \(item.boundingBox)")
//                        }
                    }
                }
        
              // 优化中文识别设置
              request.recognitionLevel = .accurate
              request.recognitionLanguages = ["zh-Hans", "zh-Hant"]
              request.usesLanguageCorrection = true
              
              let handler = VNImageRequestHandler(ciImage: image, orientation: .up, options: [:])
              do {
                  try handler.perform([request])
              } catch {
                  print("执行识别请求失败: \(error)")
              }
        
     }
    


}
