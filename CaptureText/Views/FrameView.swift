//
//  FrameView.swift
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

struct FrameView: View {
    let frame: FrameWithText
    let selectionIndex: Int?
    
    var body: some View {
        ZStack(alignment: .topLeading){
            VStack(spacing: 8) {
                Image(nsImage: frame.isWithText ? frame.image.drawingTextBounds(frame.textBounds) : frame.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Text(formatCMTimeToString(frame.timestamp)).frame(maxWidth: .infinity, alignment: .leading)
                if frame.isWithText {
                    Text("\(frame.text) ").padding(.vertical, 4).frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
            .cornerRadius(8)
            if let index = selectionIndex {
                  Text("\(index)")
                      .font(.caption)
                      .padding(10)
                      .background(.blue)
                      .clipShape(Circle())
                      .foregroundColor(Color.white)
                      .offset(x: 0, y: -5)
              }
        }
        
        .padding(4)
        .background(Color(NSColor.white)) // 背景颜色便于观察
        .listRowInsets(EdgeInsets())
        .cornerRadius(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    private func formatCMTimeToString(_ time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        
        guard !totalSeconds.isNaN else {
            return "Invalid Time"
        }
        
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = Int(totalSeconds) % 60
        let milliseconds = Int((totalSeconds - Double(Int(totalSeconds))) * 1000)
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
        } else {
            return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds)
        }
    }
}

