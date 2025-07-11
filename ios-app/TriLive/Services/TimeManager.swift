//
//  TimeManager.swift
//  TriLive
//
//  Created by Brian Maina on 7/11/25.
//


import Foundation
import Combine

// A simple timer that ticks every second and computes
// how many minutes have elapsed since it was created.
final class TimeManager: ObservableObject {
  @Published var currentTime: Date = Date()
  private let startDate: Date
  private var timer: Timer?

  init() {
    startDate = Date()
    startTimer()
  }

  func startTimer() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.currentTime = Date()
    }
  }

  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  // Returns how many minutes (as a Double) have passed since init
  func timeDifferenceInMinutes() -> Double {
    currentTime.timeIntervalSince(startDate) / 60
  }

  deinit {
    timer?.invalidate()
  }
}
