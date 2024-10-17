//
//  Model.swift
//  CaptureText
//
//  Created by shenruqi on 10/16/24.
//

import SwiftUI
import AVKit

struct FrameWithText: Identifiable, Hashable {
    let id = UUID()
    let image: NSImage
    let timestamp: CMTime
    let text: String
    let isWithText: Bool
    let textBounds: [CGRect]  // 新增: 存储每个识别出的文字的边界框
}

struct RecognizedText: Identifiable {
    let id = UUID()
    let text: String
    let boundingBox: CGRect
}

struct AudioTranscription: Identifiable {
    let id = UUID()
    let text: String
    let startTime: Double
    let endTime: Double
}

struct ContentItem: Codable {
    let index: Int
    let text: String
}

