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
    
    // 尽可能获取每一帧
    static func extractAllFrames(from videoURL: URL, fps: Float, completion: @escaping (CMTime, CGImage) -> Void) {
        var frames: [CGImage] = []
        let asset = AVAsset(url: videoURL)
        
        guard let track = asset.tracks(withMediaType: .video).first else {
            print("错误：无法获取视频轨道")
            return
        }
        
        do {
            let assetReader = try AVAssetReader(asset: asset)
            let outputSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
            
            assetReader.add(readerOutput)
            
            guard assetReader.startReading() else {
                print("错误：无法开始读取视频")
                return
            }
            
            let nominalFrameRate = track.nominalFrameRate
           
            let timeScale = Float(track.timeRange.duration.timescale)
            print("nominalFrameRate---", timeScale, nominalFrameRate)
            let frameDuration = CMTime(value: 1, timescale: CMTimeScale(timeScale * fps / nominalFrameRate))
                  while let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                      if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                          let ciImage = CIImage(cvImageBuffer: imageBuffer)
                          let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                          if let cgImage = convertCIImageToCGImage(ciImage: ciImage) {
                              completion(presentationTime, cgImage)
                          } else {
                              print("警告：无法转换 CIImage 到 CGImage")
                          }
                      } else {
                          print("警告：无法从 sampleBuffer 获取 imageBuffer")
                      }
                      
                      if CMSampleBufferGetPresentationTimeStamp(sampleBuffer) >= CMTimeAdd(CMSampleBufferGetPresentationTimeStamp(sampleBuffer), frameDuration) {
                          continue
                      }
                  }
                  
                  if assetReader.status == .completed {
                      print("视频读取完成，共提取 \(frames.count) 帧")
                  } else {
                      print("错误：视频读取未完成，状态：\(assetReader.status.rawValue)")
                  }
                  
                  assetReader.cancelReading()
              } catch {
                  print("错误：设置 AVAssetReader 失败：\(error)")
              }
              
             
          }
    
    
    static  func convertCIImageToCGImage(ciImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("警告：无法创建 CGImage")
            return nil
        }
        return cgImage
    }

    
    // 按秒
    static func extractAllFramesByTime(from videoURL: URL, interval: Double = 0.1, completion: @escaping (CMTime, CGImage) -> Void) {
        var frames: [(CMTime, CGImage)] = []
        let asset = AVAsset(url: videoURL)
        
        guard let track = asset.tracks(withMediaType: .video).first else {
            print("错误：无法获取视频轨道")
            return
        }
        
        let duration = asset.duration
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        
        var currentTime = CMTime.zero
        let intervalTime = CMTime(seconds: interval, preferredTimescale: 600)
        
        while currentTime < duration {
            do {
                let imageRef = try generator.copyCGImage(at: currentTime, actualTime: nil)
                completion(currentTime, imageRef)
                
//                if frames.count % 100 == 0 {
//                    print("已处理 \(frames.count) 帧")
//                }
            } catch {
                print("在时间 \(CMTimeGetSeconds(currentTime)) 提取帧失败：\(error)")
            }
            
            currentTime = CMTimeAdd(currentTime, intervalTime)
        }
        
        print("视频读取完成，共提取 \(frames.count) 帧")
       
    }
    
}
