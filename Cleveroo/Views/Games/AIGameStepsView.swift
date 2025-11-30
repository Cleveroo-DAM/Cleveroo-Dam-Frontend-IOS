//
//  AIGameStepsView.swift
//  Cleveroo
//
//  Created by GitHub Copilot on 30/11/2025.
//

import SwiftUI

// MARK: - Enhanced Timed Reaction (Ballon)
struct EnhancedTimedReactionStep: View {
    let step: GameStep
    let themeColors: [Color]
    let stepStartTime: Date
    let onAnswer: ([String: Any]) -> Void
    
    @State private var balloonY: CGFloat = 500
    @State private var hasClicked = false
    @State private var swayOffset: CGFloat = -15
    @State private var isAnimating = false
    
    var prompt: String {
        step.prompt
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Prompt card
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 1.0, green: 0.42, blue: 0.62), Color(red: 1.0, green: 0.55, blue: 0.58)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        
                        Text("⚡")
                        .font(.system(size: 28))
                    }
                    
                    Text(prompt)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.18, green: 0.21, blue: 0.28))
                        .lineLimit(3)
                    
                    Spacer()
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.95))
            .cornerRadius(24)
            .shadow(radius: 20)
            
            Spacer()
            
            // Balloon zone
            ZStack(alignment: .center) {
                ZStack(alignment: .center) {
                    Text("🎈")
                        .font(.system(size: 120))
                        .offset(y: -10)
                        .offset(x: swayOffset, y: balloonY)
                        .onTapGesture {
                            if !hasClicked {
                                hasClicked = true
                                let rt = Date().timeIntervalSince(stepStartTime) * 1000
                                
                                let event: [String: Any] = [
                                    "type": "reaction",
                                    "stepId": step.id,
                                    "timestamp": Date().timeIntervalSince1970 * 1000,
                                    "payload": ["rt": Int(rt)]
                                ]
                                
                                onAnswer(event)
                            }
                        }
                        .animation(hasClicked ? Animation.easeOut(duration: 0.5) : Animation.easeOut(duration: 2.5), value: balloonY)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            
            Spacer()
            
            // Tap instruction
            HStack(spacing: 12) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                
                Text("TAP LE BALLON !")
                    .font(.system(size: 24, weight: .black))
                    .tracking(1.5)
                    .foregroundColor(Color(red: 0.18, green: 0.21, blue: 0.28))
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.white.opacity(0.95))
            .cornerRadius(20)
            .shadow(radius: 15)
            .opacity(hasClicked ? 0.3 : 1.0)
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
                
                withAnimation(.easeOut(duration: 2.5)) {
                    balloonY = 50
                }
                
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    swayOffset = 15
                }
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - Creative Task (Dessin)
struct CreativeTaskStep: View {
    let step: GameStep
    let themeColors: [Color]
    let stepStartTime: Date
    let onAnswer: ([String: Any]) -> Void
    
    @State private var drawingPaths: [DrawingPath] = []
    @State private var currentPath: UIBezierPath?
    @State private var selectedColor = Color.black
    
    let colors: [Color] = [
        .black, .red, .blue,
        Color(red: 0.3, green: 0.8, blue: 0.3),
        Color(red: 1.0, green: 0.92, blue: 0.23),
        Color(red: 1.0, green: 0.6, blue: 0.0),
        Color(red: 0.6, green: 0.15, blue: 0.69)
    ]
    
    var prompt: String {
        step.prompt
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Prompt
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 1.0, green: 0.42, blue: 0.62), Color(red: 1.0, green: 0.63, blue: 0.48)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    
                    Text("🎨")
                        .font(.system(size: 26))
                }
                
                Text(prompt)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(Color(red: 0.18, green: 0.21, blue: 0.28))
                    .lineLimit(3)
                
                Spacer()
            }
            .padding(20)
            .background(Color.white.opacity(0.95))
            .cornerRadius(20)
            .shadow(radius: 15)
            
            // Color palette
            HStack(spacing: 0) {
                ForEach(colors, id: \.self) { color in
                    ZStack {
                        Circle()
                            .fill(color)
                            .frame(width: selectedColor == color ? 44 : 36, height: selectedColor == color ? 44 : 36)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                            )
                            .shadow(radius: selectedColor == color ? 8 : 4)
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        selectedColor = color
                    }
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            
            // Canvas
            VStack {
                ZStack {
                    Color(red: 0.97, green: 0.98, blue: 0.99)
                    
                    CanvasView(paths: $drawingPaths, currentPath: $currentPath, selectedColor: selectedColor)
                    
                    if drawingPaths.isEmpty && currentPath == nil {
                        VStack(spacing: 8) {
                            Image(systemName: "hand.draw.fill")
                                .font(.system(size: 48))
                                .foregroundColor(Color(red: 0.8, green: 0.84, blue: 0.88))
                            
                            Text("Dessine avec ton doigt !")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.44, green: 0.5, blue: 0.57))
                        }
                    }
                }
                .cornerRadius(24)
                .shadow(radius: 20)
            }
            .frame(maxHeight: .infinity)
            
            // Buttons
            HStack(spacing: 12) {
                Button(action: {
                    drawingPaths.removeAll()
                    currentPath = nil
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20))
                        Text("Effacer")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.32, blue: 0.32))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 1.0, green: 0.32, blue: 0.32), lineWidth: 2)
                    )
                }
                
                Button(action: {
                    let event: [String: Any] = [
                        "type": "answer",
                        "stepId": step.id,
                        "timestamp": Date().timeIntervalSince1970 * 1000,
                        "payload": [
                            "answer": "drawing_completed",
                            "pathCount": drawingPaths.count,
                            "rt": Int(Date().timeIntervalSince(stepStartTime) * 1000),
                            "correct": true
                        ]
                    ]
                    onAnswer(event)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                        Text("Continuer")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: themeColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                }
            }
        }
    }
}

// MARK: - Canvas View for Drawing
struct CanvasView: UIViewRepresentable {
    @Binding var paths: [DrawingPath]
    @Binding var currentPath: UIBezierPath?
    let selectedColor: Color
    
    func makeUIView(context: Context) -> UIView {
        let view = DrawingCanvasUIView()
        view.onPathsUpdated = { paths, currentPath in
            self.paths = paths
            self.currentPath = currentPath
        }
        view.selectedColor = UIColor(selectedColor)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let canvasView = uiView as? DrawingCanvasUIView {
            canvasView.selectedColor = UIColor(selectedColor)
        }
    }
}

class DrawingCanvasUIView: UIView {
    var paths: [DrawingPath] = []
    var currentPath: UIBezierPath?
    var selectedColor = UIColor.black
    var onPathsUpdated: (([DrawingPath], UIBezierPath?) -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 0.99, alpha: 1.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
        currentPath = UIBezierPath()
        currentPath?.move(to: point)
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        
        currentPath?.addLine(to: point)
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let path = currentPath {
            paths.append(DrawingPath(path: path, color: selectedColor, strokeWidth: 8))
            currentPath = nil
        }
        onPathsUpdated?(paths, currentPath)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        for drawingPath in paths {
            drawingPath.color.setStroke()
            drawingPath.path.lineWidth = drawingPath.strokeWidth
            drawingPath.path.lineCapStyle = .round
            drawingPath.path.lineJoinStyle = .round
            drawingPath.path.stroke()
        }
        
        if let currentPath = currentPath {
            selectedColor.setStroke()
            currentPath.lineWidth = 8
            currentPath.lineCapStyle = .round
            currentPath.lineJoinStyle = .round
            currentPath.stroke()
        }
    }
}

struct DrawingPath {
    let path: UIBezierPath
    let color: UIColor
    let strokeWidth: CGFloat
}

// MARK: - Interactive Star Counting (Tap each star)
struct InteractiveStarCountingStep: View {
    let step: GameStep
    let themeColors: [Color]
    let stepStartTime: Date
    let onAnswer: ([String: Any]) -> Void
    
    @State private var tappedCount = 0
    @State private var starStates: [TappableStarState] = []
    let maxStars = 7
    
    var prompt: String {
        step.prompt
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Prompt
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 1.0, green: 0.85, blue: 0.24), Color(red: 1.0, green: 0.55, blue: 0.0)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    
                    Text("👆")
                        .font(.system(size: 26))
                }
                
                Text(prompt)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.18, green: 0.21, blue: 0.28))
                    .lineLimit(3)
                
                Spacer()
            }
            .padding(20)
            .background(Color.white.opacity(0.95))
            .cornerRadius(20)
            .shadow(radius: 15)
            
            // Count display
            HStack(spacing: 12) {
                Text("Comptées:")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.44, green: 0.5, blue: 0.57))
                
                Text("\(tappedCount)")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(Color(red: 0.28, green: 0.73, blue: 0.47))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            
            // Stars zone
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color(red: 0.18, green: 0.21, blue: 0.28), Color(red: 0.1, green: 0.13, blue: 0.18)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 800
                        )
                    )
                
                // Background stars
                Canvas { context, size in
                    for i in 0..<20 {
                        let x = CGFloat(i * 43) * 0.5
                        let y = CGFloat(i * 79) * 0.5
                        let point = CGPoint(x: x.truncatingRemainder(dividingBy: 400) + 50, y: y.truncatingRemainder(dividingBy: 400) + 50)
                        
                        var path = Path(ellipseIn: CGRect(x: point.x, y: point.y, width: 4, height: 4))
                        context.fill(path, with: .color(Color.white.opacity(0.3)))
                    }
                }
                
                // Interactive stars
                VStack {
                    ForEach(starStates, id: \.id) { starState in
                        StarTapView(
                            star: starState,
                            onTap: {
                                if !starState.isTapped {
                                    tappedCount += 1
                                    starStates[starStates.firstIndex(where: { $0.id == starState.id }) ?? 0].isTapped = true
                                }
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
            .cornerRadius(24)
            .shadow(radius: 20)
            
            // Finish button
            Button(action: {
                let event: [String: Any] = [
                    "type": "answer",
                    "stepId": step.id,
                    "timestamp": Date().timeIntervalSince1970 * 1000,
                    "payload": [
                        "answer": tappedCount.description,
                        "rt": Int(Date().timeIntervalSince(stepStartTime) * 1000),
                        "correct": tappedCount == maxStars
                    ]
                ]
                onAnswer(event)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                    Text("J'ai fini !")
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: themeColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
            }
        }
        .onAppear {
            starStates = (0..<maxStars).map { index in
                let angle = (2 * CGFloat.pi * CGFloat(index) / CGFloat(maxStars))
                let radius: CGFloat = 100
                return TappableStarState(
                    id: index,
                    x: 150 + cos(angle) * radius,
                    y: 180 + sin(angle) * radius,
                    isTapped: false
                )
            }
        }
    }
}

struct TappableStarState: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    var isTapped: Bool
}

struct StarTapView: View {
    let star: TappableStarState
    let onTap: () -> Void
    @State private var scale: CGFloat = 0.9
    
    var body: some View {
        VStack {
            Text(star.isTapped ? "✅" : "⭐")
                .font(.system(size: 50))
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        scale = star.isTapped ? 1.4 : 1.1
                    }
                }
                .onTapGesture {
                    onTap()
                }
                .opacity(star.isTapped ? 0.5 : 1.0)
        }
        .offset(x: star.x - 30, y: star.y - 30)
    }
}

// MARK: - Enhanced Task (Star Counting with Buttons)
struct EnhancedTaskStep: View {
    let step: GameStep
    let themeColors: [Color]
    let stepStartTime: Date
    let onAnswer: ([String: Any]) -> Void
    
    @State private var starCount = 5
    @State private var selectedAnswer: Int?
    @State private var stars: [StarData] = []
    
    var prompt: String {
        step.prompt
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Prompt
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 1.0, green: 0.85, blue: 0.24), Color(red: 1.0, green: 0.55, blue: 0.0)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    
                    Text("👀")
                        .font(.system(size: 26))
                }
                
                Text(prompt)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(Color(red: 0.18, green: 0.21, blue: 0.28))
                    .lineLimit(3)
                
                Spacer()
            }
            .padding(20)
            .background(Color.white.opacity(0.95))
            .cornerRadius(20)
            .shadow(radius: 15)
            
            // Stars display zone
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color(red: 0.18, green: 0.21, blue: 0.28), Color(red: 0.1, green: 0.13, blue: 0.18)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 800
                        )
                    )
                
                // Background stars
                Canvas { context, size in
                    for i in 0..<25 {
                        let x = CGFloat(i * 41) * 0.7
                        let y = CGFloat(i * 67) * 0.7
                        let point = CGPoint(x: x.truncatingRemainder(dividingBy: 350) + 50, y: y.truncatingRemainder(dividingBy: 350) + 50)
                        
                        var path = Path(ellipseIn: CGRect(x: point.x, y: point.y, width: 4, height: 4))
                        context.fill(path, with: .color(Color.white.opacity(0.3)))
                    }
                }
                
                // Main stars display
                GeometryReader { geometry in
                    ZStack {
                        ForEach(stars, id: \.delay) { star in
                            StarDisplayView(star: star)
                                .position(x: geometry.size.width / 2 + star.initialX, y: geometry.size.height / 2 + star.initialY)
                        }
                    }
                }
            }
            .frame(height: 400)
            .cornerRadius(24)
            .shadow(radius: 20)
            
            // Answer buttons
            HStack(spacing: 12) {
                ForEach([3, 5, 7], id: \.self) { num in
                    Button(action: {
                        selectedAnswer = num
                        let event: [String: Any] = [
                            "type": "answer",
                            "stepId": step.id,
                            "timestamp": Date().timeIntervalSince1970 * 1000,
                            "payload": [
                                "answer": num.description,
                                "rt": Int(Date().timeIntervalSince(stepStartTime) * 1000),
                                "correct": num == starCount
                            ]
                        ]
                        onAnswer(event)
                    }) {
                        VStack(spacing: 0) {
                            Text(num.description)
                                .font(.system(size: 42, weight: .black))
                            Text("étoiles")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(selectedAnswer == num ? .white : Color(red: 0.18, green: 0.21, blue: 0.28))
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .background(selectedAnswer == num ? Color(red: 0.28, green: 0.73, blue: 0.47) : Color.white)
                        .cornerRadius(20)
                    }
                }
            }
        }
        .onAppear {
            stars = (0..<starCount).map { index in
                let angle = (2 * CGFloat.pi * CGFloat(index) / CGFloat(starCount)) - (CGFloat.pi / 2)
                let radius: CGFloat = 60
                return StarData(
                    initialX: cos(angle) * radius,
                    initialY: sin(angle) * radius,
                    delay: CGFloat(index) * 150
                )
            }
        }
    }
}

struct StarData: Identifiable {
    let id = UUID()
    let initialX: CGFloat
    let initialY: CGFloat
    let delay: CGFloat
}

struct StarDisplayView: View {
    let star: StarData
    @State private var scale: CGFloat = 0.9
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color(red: 1.0, green: 0.85, blue: 0.0).opacity(0.6), Color.clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 35
                    )
                )
                .frame(width: 70, height: 70)
            
            Text("⭐")
                .font(.system(size: 55))
        }
        .scaleEffect(scale)
        .onAppear {
            let duration = (1000.0 + Double(star.delay)) / 1000.0
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                scale = 1.15
            }
        }
    }
}

// MARK: - Enhanced Question (Multiple Choice)
struct EnhancedQuestionStep: View {
    let step: GameStep
    let themeColors: [Color]
    let stepStartTime: Date
    let onAnswer: ([String: Any]) -> Void
    
    @State private var selectedIndex: Int?
    @State private var visibleIndices: Set<Int> = []
    
    let optionColors: [[Color]] = [
        [Color(red: 1.0, green: 0.42, blue: 0.62), Color(red: 1.0, green: 0.55, blue: 0.58)],
        [Color(red: 0.31, green: 0.98, blue: 0.99), Color(red: 0.0, green: 0.95, blue: 0.99)],
        [Color(red: 0.27, green: 0.91, blue: 0.48), Color(red: 0.22, green: 0.98, blue: 0.85)],
        [Color(red: 0.98, green: 0.44, blue: 0.60), Color(red: 1.0, green: 0.88, blue: 0.25)],
        [Color(red: 0.19, green: 0.81, blue: 0.82), Color(red: 0.2, green: 0.05, blue: 0.4)]
    ]
    
    var prompt: String {
        step.prompt
    }
    
    var options: [String] {
        step.options ?? []
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Question card
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: themeColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 4))
                            .shadow(radius: 8)
                        
                        Text("?")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(.white)
                    }
                    
                    Text(prompt)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.18, green: 0.21, blue: 0.28))
                        .lineLimit(4)
                    
                    Spacer()
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(28)
            .shadow(radius: 20)
            
            // Options
            ScrollView([.vertical], showsIndicators: true) {
                VStack(spacing: 14) {
                    ForEach(Array(options.indices), id: \.self) { index in
                        let option = options[index]
                        OptionButton(
                            index: index + 1,
                            text: option,
                            isSelected: selectedIndex == index,
                            colors: optionColors[index % Array(optionColors).count],
                            isVisible: visibleIndices.contains(index),
                            onTap: {
                                selectedIndex = index
                                let event: [String: Any] = [
                                    "type": "answer",
                                    "stepId": step.id,
                                    "timestamp": Date().timeIntervalSince1970 * 1000,
                                    "payload": [
                                        "selectedIndex": index,
                                        "selectedValue": option,
                                        "rt": Int(Date().timeIntervalSince(stepStartTime) * 1000),
                                        "correct": true
                                    ]
                                ]
                                onAnswer(event)
                            }
                        )
                        .transition(.opacity.combined(with: .offset(x: -50)))
                        .onAppear {
                            let delay: Double = Double(index) * 0.08
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                visibleIndices.insert(index)
                                withAnimation {
                                    // Trigger animation
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 80)
            }
        }
    }
}

struct OptionButton: View {
    let index: Int
    let text: String
    let isSelected: Bool
    let colors: [Color]
    let isVisible: Bool
    let onTap: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 46, height: 46)
                    } else {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 46, height: 46)
                    }
                    
                    Text(String(index))
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white)
                }
                
                Text(text)
                    .font(.system(size: 17, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : Color(red: 0.18, green: 0.21, blue: 0.28))
                    .lineLimit(3)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
            }
            .padding(20)
            .background(isSelected ? LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [Color.white, Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color(red: 0.88, green: 0.91, blue: 0.94), lineWidth: 2)
            )
            .shadow(radius: isSelected ? 20 : 8)
            .scaleEffect(scale)
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 1.0)) {
                scale = 0.96
            }
        }
    }
}
