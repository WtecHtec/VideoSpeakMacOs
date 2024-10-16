//
//  AudioTranscriptionView.swift
//  CaptureText
//
//  Created by shenruqi on 10/16/24.
//

import SwiftUI


struct AudioTranscriptionView: View {
    let transcription: AudioTranscription
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("[\(String(format: "%.2f - %.2f", transcription.startTime, transcription.endTime))]")
                .font(.caption)
                .foregroundColor(.blue)
            Text(transcription.text)
                .font(.body)

        }
    }
}

