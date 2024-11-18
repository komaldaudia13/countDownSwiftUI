//
//  TimerViewModelTests.swift
//  TestCountdownTimerTests
//
//  Created by Komal Daudia on 17/11/24.
//

import XCTest
@testable import TestCountdownTimer

final class TimerViewModelTests: XCTestCase {
    var viewModel: TimerViewModel!
    var mockCurrentDate: () -> Date!
    var currentTime: Date!

    override func setUp() {
        super.setUp()
        // Mocked current date for predictable testing
        currentTime = Date()
        mockCurrentDate = { self.currentTime }
        viewModel = TimerViewModel(currentDate: mockCurrentDate)
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.strTimer, "01:00.00")
        XCTAssertEqual(viewModel.progress, 1.0)
        XCTAssertFalse(viewModel.isRunning)
    }

    func testStartTimer() {
        viewModel.toggleTimer()
        XCTAssertTrue(viewModel.isRunning)
    }

    func testPauseTimer() {
        viewModel.toggleTimer() // Start the timer
        XCTAssertTrue(viewModel.isRunning)

        // Advance the mocked time by 10 seconds
        currentTime = currentTime.addingTimeInterval(10)
        viewModel.toggleTimer() // Pause the timer
        XCTAssertFalse(viewModel.isRunning)

        // Ensure the remaining time reflects the 10 seconds elapsed
        XCTAssertEqual(viewModel.strTimer, "00:50.00")
    }

    func testStopTimer() {
        viewModel.toggleTimer() // Start the timer
        XCTAssertTrue(viewModel.isRunning)

        // Advance the mocked time by 10 seconds
        currentTime = currentTime.addingTimeInterval(10)
        viewModel.stopTimer() // Stop the timer
        XCTAssertFalse(viewModel.isRunning)

        // Timer should reset to initial state
        XCTAssertEqual(viewModel.strTimer, "01:00.00")
        XCTAssertEqual(viewModel.progress, 1.0)
    }

    func testTimerCompletion() {
        viewModel.toggleTimer() // Start the timer
        XCTAssertTrue(viewModel.isRunning)

        // Simulate timer reaching 0
        currentTime = currentTime.addingTimeInterval(60)
        viewModel.updateTimer()

        // Timer should stop and reset
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertEqual(viewModel.strTimer, "00:00.00")
        XCTAssertEqual(viewModel.progress, 0.0)
    }

    func testBackgroundTimerAccuracy() {
        viewModel.toggleTimer() // Start the timer
        XCTAssertTrue(viewModel.isRunning)

        // Simulate the app going to the background for 30 seconds
        currentTime = currentTime.addingTimeInterval(30)
        viewModel.updateTimer()

        // Ensure the timer reflects the correct time remaining
        XCTAssertEqual(viewModel.strTimer, "00:30.00")
        XCTAssertTrue(viewModel.isRunning)

        // Simulate another 30 seconds to complete the timer
        currentTime = currentTime.addingTimeInterval(30)
        viewModel.updateTimer()

        XCTAssertEqual(viewModel.strTimer, "00:00.00")
        XCTAssertFalse(viewModel.isRunning)
    }

    func testNotificationIsScheduled() {
        let expectation = XCTestExpectation(description: "Notification should be scheduled when timer ends")
        let center = UNUserNotificationCenter.current()

        // Mock the notification center
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                self.viewModel.toggleTimer() // Start the timer
                
                // Simulate timer reaching 0
                self.currentTime = self.currentTime.addingTimeInterval(60)
                self.viewModel.updateTimer()

                // Check notification request exists
                center.getPendingNotificationRequests { requests in
                    XCTAssertFalse(requests.isEmpty, "Notification should have been scheduled")
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 5)
    }
}
