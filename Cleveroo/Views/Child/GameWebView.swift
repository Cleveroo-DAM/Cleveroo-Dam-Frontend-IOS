//
//  GameWebView.swift
//  Cleveroo
//
//  WebView for playing external games
//

import SwiftUI
import WebKit

struct GameWebView: View {
    let assignment: ActivityAssignment
    @ObservedObject var activityVM: ActivityViewModel
    var onComplete: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var showCompleteSheet = false
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // WebView
                if let urlString = assignment.activityId.externalUrl,
                   let url = URL(string: urlString) {
                    WebViewRepresentable(url: url, isLoading: $isLoading)
                        .ignoresSafeArea()
                } else {
                    // Fallback if no URL
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("No game URL available")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
                
                // Floating "Mark as Completed" button
                if assignment.status.lowercased() != "completed" {
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            showCompleteSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                Text("Mark as Completed")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    colors: [Color.green, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: Color.green.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle(assignment.activityId.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showCompleteSheet) {
                CompleteActivityView(assignmentId: assignment.id, activityVM: activityVM) {
                    showCompleteSheet = false
                    onComplete()
                    dismiss()
                }
            }
        }
    }
}

// MARK: - WebView Representable
struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewRepresentable
        
        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}

#Preview {
    GameWebView(
        assignment: ActivityAssignment(
            id: "1",
            childId: "child1",
            activityId: ActivityDetails(
                id: "act1",
                title: "Tetris Game",
                description: "Play Tetris",
                type: "external_game",
                domain: "logic",
                externalUrl: "https://tetris.com/play-tetris",
                minAge: 6,
                maxAge: 12
            ),
            status: "in_progress",
            dueDate: nil,
            score: nil,
            notes: nil,
            createdAt: nil,
            updatedAt: nil
        ),
        activityVM: ActivityViewModel(),
        onComplete: {}
    )
}
