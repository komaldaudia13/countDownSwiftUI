//
//  TimerViewModel.swift
//  TestCountdownTimer
//
//  Created by Komal Daudia on 17/11/24.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

class TimerViewModel: ObservableObject {
    @Published var strTimer: String = "01:00.00"
    @Published var isRunning: Bool = false
    @Published var progress: Double = 1.0

     var timer: Timer?
     var startTime: Date?
     var remainingTime: TimeInterval = 60
     var cancellables = Set<AnyCancellable>()
    
    // Dependency Injection for testing (default dependency: system clock)
     var currentDate: () -> Date
    
    init(currentDate: @escaping () -> Date = { Date() }) {
        self.currentDate = currentDate
    }
    
    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        remainingTime = 60
        isRunning = false
        updateDisplay()
        progress = 1.0
    }
    
    private func startTimer() {
        if startTime == nil {
            startTime = currentDate()
        }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        remainingTime -= currentDate().timeIntervalSince(startTime ?? currentDate())
        isRunning = false
    }
    
    private func updateTimer() {
        guard let startTime = startTime else { return }
        
        let elapsedTime = currentDate().timeIntervalSince(startTime)
        let timeLeft = max(0, remainingTime - elapsedTime)
        
        if timeLeft <= 0 {
            stopTimer()
            sendNotification()
        }
        
        updateDisplay(timeLeft: timeLeft)
        progress = timeLeft / 60.0
    }
    
    private func updateDisplay(timeLeft: TimeInterval = 60) {
        let minutes = Int(timeLeft) / 60
        let seconds = Int(timeLeft) % 60
        let milliseconds = Int((timeLeft - Double(Int(timeLeft))) * 100)
        DispatchQueue.main.async {
            self.strTimer = String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Timer Ended"
        content.body = "Your countdown has finished."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
