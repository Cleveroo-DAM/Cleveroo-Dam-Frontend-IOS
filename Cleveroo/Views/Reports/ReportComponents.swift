//
//  ReportComponents.swift
//  Cleveroo
//
//  Shared components for AI Report views
//

import SwiftUI

// MARK: - PROGRESS ROW COMPONENT
struct ProgressRow: View {
    let title: String
    let value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value))%")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 8)
                
                Capsule()
                    .fill(LinearGradient(colors: [Color.purple, Color.pink.opacity(0.8)],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: CGFloat(value) * 2.5, height: 8)
                    .animation(.easeInOut(duration: 1.0), value: value)
            }
        }
    }
}

// MARK: - CIRCULAR PROGRESS COMPONENT
struct CircularProgressView: View {
    var value: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 15)
            Circle()
                .trim(from: 0, to: value)
                .stroke(AngularGradient(gradient: Gradient(colors: [Color.purple, Color.pink, Color.yellow]),
                                        center: .center),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: value)
            
            Text("\(Int(value * 100))%")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - LEGEND ITEM
struct LegendItem: View {
    let color: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

// MARK: - CIRCULAR PROGRESS VIEW FOR CHILD REPORT
struct CircularProgressViewChild: View {
    let value: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 12)
            
            Circle()
                .trim(from: 0, to: value)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .green]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 8) {
                Text("\(Int(value * 100))%")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Overall")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }
}
