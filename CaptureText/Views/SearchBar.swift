//
//  SearchBar.swift
//  CaptureText
//
//  Created by shenruqi on 10/16/24.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("搜索...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing)
            }
        }
    }
}
