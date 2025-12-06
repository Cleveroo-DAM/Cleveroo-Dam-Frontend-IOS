import SwiftUI
import Charts

struct ChildAIReportView: View {
    let childId: String
    let childName: String
    @ObservedObject var authVM: AuthViewModel
    
    @StateObject private var viewModel = AIReportViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                BubbleBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ChildReportHeaderView(childName: childName, viewModel: viewModel, dismiss: dismiss)
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            ChildReportScoreView(viewModel: viewModel)
                            ChildReportScoresDetailView(viewModel: viewModel)
                            ChildReportStrengthsView(viewModel: viewModel)
                            ChildReportImprovementView(viewModel: viewModel)
                            ChildReportAdviceView(viewModel: viewModel)
                            ChildReportTipsView(viewModel: viewModel, childName: childName)
                            ChildReportRecommendationsView(viewModel: viewModel)
                            ChildReportChartView(viewModel: viewModel)
                            //ChildReportEvolutionButtonView()
                            
                            Spacer(minLength: 20)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {                
                ToolbarItem(placement: .principal) {
                    Text("AI Report")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AIEvolutionView()) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Evolution")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                viewModel.loadChildReport(childId: childId)
            }
        }
    }
}

// MARK: - Header View
struct ChildReportHeaderView: View {
    let childName: String
    @ObservedObject var viewModel: AIReportViewModel
    var dismiss: DismissAction
    
    var body: some View {
        VStack(spacing: 10) {
            Text("How is \(childName) doing today?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Here’s how your little explorer is doing today!")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 10)
    }
}

// MARK: - Score View
struct ChildReportScoreView: View {
    @ObservedObject var viewModel: AIReportViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else {
                CircularProgressViewChild(value: viewModel.overallScore / 100)
                    .frame(width: 160, height: 160)
                    .padding(.top, 10)
                
                Text("Overall Score: \(Int(viewModel.overallScore)) / 100")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Scores Detail View
struct ChildReportScoresDetailView: View {
    @ObservedObject var viewModel: AIReportViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressRow(title: "Emotional Intelligence 💖", value: viewModel.emotionalScore)
            ProgressRow(title: "Memory 🧩", value: viewModel.memoryScore)
            ProgressRow(title: "Focus 🎯", value: viewModel.focusScore)
            ProgressRow(title: "Creativity 🎨", value: viewModel.creativityScore)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

// MARK: - Strengths View
struct ChildReportStrengthsView: View {
    @ObservedObject var viewModel: AIReportViewModel
    
    var body: some View {
        if !viewModel.strengths.isEmpty {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Your Strengths ⭐")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                
                VStack(spacing: 8) {
                    ForEach(viewModel.strengths, id: \.self) { strength in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(strength)
                                .foregroundColor(.white.opacity(0.9))
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding()
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
}

// MARK: - Improvement Areas View
struct ChildReportImprovementView: View {
    @ObservedObject var viewModel: AIReportViewModel
    
    var body: some View {
        if !viewModel.areasNeedingImprovement.isEmpty {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.orange)
                    Text("Areas to Improve 🎯")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                
                VStack(spacing: 8) {
                    ForEach(viewModel.areasNeedingImprovement, id: \.self) { area in
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.orange)
                            Text(area)
                                .foregroundColor(.white.opacity(0.9))
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
}

// MARK: - Advice View
struct ChildReportAdviceView: View {
    @ObservedObject var viewModel: AIReportViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Cleveroo's Advice")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            Text(viewModel.cleverooAdvice)
                .font(.body)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.yellow.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

// MARK: - Tips View
struct ChildReportTipsView: View {
    @ObservedObject var viewModel: AIReportViewModel
    let childName: String
    
    var body: some View {
        if !viewModel.dailyTips.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Daily Tips for \(childName)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                VStack(spacing: 10) {
                    ForEach(viewModel.dailyTips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            Text(tip)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
}

// MARK: - Recommendations View
struct ChildReportRecommendationsView: View {
    @ObservedObject var viewModel: AIReportViewModel
    
    var body: some View {
        if !viewModel.personalisedRecommendations.isEmpty {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.blue)
                    Text("Personalised Recommendations 🚀")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                
                VStack(spacing: 8) {
                    ForEach(viewModel.personalisedRecommendations, id: \.self) { recommendation in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(.blue)
                                .padding(.top, 2)
                            Text(recommendation)
                                .foregroundColor(.white.opacity(0.9))
                                .font(.caption)
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
}

// MARK: - Chart View
struct ChildReportChartView: View {
    @ObservedObject var viewModel: AIReportViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Skill Overview 📊")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            Chart {
                ForEach(viewModel.skillProgress) { skill in
                    BarMark(
                        x: .value("Skill", skill.name),
                        y: .value("Score", skill.value)
                    )
                    .foregroundStyle(
                        skill.value >= 80 ? Color.green :
                        skill.value >= 60 ? Color.orange :
                        Color(UIColor.systemRed)
                    )
                }
            }
            .frame(height: 200)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }
}

// MARK: - Evolution Button View
//struct ChildReportEvolutionButtonView: View {
//    var body: some View {
//        NavigationLink(destination: AIEvolutionView()) {
//            HStack {
//                Image(systemName: "chart.line.uptrend.xyaxis")
//                Text("View 7-Day Evolution")
//            }
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(
//                LinearGradient(
//                    colors: [Color.blue, Color.cyan],
//                    startPoint: .leading,
//                    endPoint: .trailing
//                )
//            )
//            .foregroundColor(.white)
//            .fontWeight(.semibold)
//            .cornerRadius(15)
//            .padding()
//        }
//    }
//}

#Preview {
    ChildAIReportView(
        childId: "123",
        childName: "John",
        authVM: AuthViewModel()
    )
}
