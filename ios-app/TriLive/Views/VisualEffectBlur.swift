//
//  VisualEffectBlur.swift
//  TriLive
//
//  Created by Brian Maina on 6/23/25.
//

import SwiftUI
import UIKit

struct VisualEffectBlur: UIViewRepresentable {
  let blurStyle: UIBlurEffect.Style

  func makeUIView(context: Context) -> UIVisualEffectView {
    UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
  }
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
  }
}


