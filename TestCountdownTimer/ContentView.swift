//
//  ContentView.swift
//  TestCountdownTimer
//
//  Created by Komal Daudia on 17/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()

    var body: some View {
        ZStack {
            // Circular Ring
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.2)
                .foregroundColor(.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(viewModel.progress))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(viewModel.isRunning ? .green : .red)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: viewModel.progress)
            
            // Timer Text
            Text(viewModel.strTimer)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .padding()
            
            // Controls
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        viewModel.toggleTimer()
                    }) {
                        Text(viewModel.isRunning ? "Pause" : "Start")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        viewModel.stopTimer()
                    }) {
                        Text("Stop")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .padding()
        .onAppear {
            viewModel.requestNotificationPermission()
        }
    }
}
// MARK: - ContentView_Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
