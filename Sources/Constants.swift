//
//  Constants.swift
//  CleverooDAM
//
//  Application-wide constants for configuration and UI timing
//

import Foundation

/// Application-wide constants
public enum AppConstants {
    
    /// UI timing constants
    public enum Timing {
        /// Duration to display feedback after submitting an answer (in seconds)
        public static let feedbackDisplayDuration: TimeInterval = 2.0
        
        /// Duration to wait before auto-advancing to next level (in seconds)
        public static let levelTransitionDuration: TimeInterval = 2.0
        
        /// Delay for Mental Math feedback display (in seconds)
        public static let mentalMathFeedbackDuration: TimeInterval = 2.0
        
        /// Delay for AI Game feedback display (in seconds)
        public static let aiGameFeedbackDuration: TimeInterval = 2.5
    }
    
    /// Default values for game configuration
    public enum Defaults {
        /// Default answer value when timeout occurs
        public static let timeoutDefaultAnswer: Int = 0
        
        /// Default number of questions in Mental Math session
        public static let mentalMathQuestionCount: Int = 10
    }
    
    /// API configuration
    public enum API {
        /// Default base URL for API requests
        public static let defaultBaseURL = "https://api.cleveroodam.com"
    }
}
