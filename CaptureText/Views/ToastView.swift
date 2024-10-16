//
//  ToastView.swift
//  CaptureText
//
//  Created by shenruqi on 10/16/24.
//

import SwiftUI

struct ToastView: View {
    var message: String
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            if isShowing {
                Text(message)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .transition(.move(edge: .bottom))
//                    .animation(.easeInOut, value: isShowing)
                    .onAppear {
                        // 自动隐藏 Toast
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isShowing = false
                        }
                    }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .edgesIgnoringSafeArea(.bottom) // 确保 Toast 可以显示在底部
    }
}
