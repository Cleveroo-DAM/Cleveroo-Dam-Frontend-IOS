//
//  MentalMathService.swift
//  CleverooDAM
//
//  Service layer for Mental Math game API communication
//

import Foundation
import Combine

/// Service for Mental Math game operations
public class MentalMathService {
    
    // MARK: - Properties
    
    private let apiClient: APIClient
    
    // MARK: - Initialization
    
    public init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - Session Management
    
    /// Start a new Mental Math session
    /// - Parameter request: Session start request with child ID and difficulty
    /// - Returns: Publisher with the created session
    public func startSession(request: StartSessionRequest) -> AnyPublisher<MentalMathSession, APIError> {
        return apiClient.request(
            endpoint: APIClient.MentalMathEndpoint.startSession.path,
            method: .post,
            body: request
        )
    }
    
    /// Get the current question for a session
    /// - Parameter sessionId: Session identifier
    /// - Returns: Publisher with the next question
    public func getQuestion(sessionId: String) -> AnyPublisher<MathQuestion, APIError> {
        return apiClient.request(
            endpoint: APIClient.MentalMathEndpoint.getQuestion(sessionId: sessionId).path,
            method: .get
        )
    }
    
    /// Submit an answer to a question
    /// - Parameter request: Answer submission with question ID and answer
    /// - Returns: Publisher with the answer validation result
    public func submitAnswer(request: SubmitAnswerRequest) -> AnyPublisher<SubmitAnswerResponse, APIError> {
        return apiClient.request(
            endpoint: APIClient.MentalMathEndpoint.submitAnswer.path,
            method: .post,
            body: request
        )
    }
    
    /// End the current session
    /// - Parameter request: Session end request
    /// - Returns: Publisher with the completed session
    public func endSession(request: EndSessionRequest) -> AnyPublisher<MentalMathSession, APIError> {
        return apiClient.request(
            endpoint: APIClient.MentalMathEndpoint.endSession.path,
            method: .post,
            body: request
        )
    }
    
    /// Get a specific session by ID
    /// - Parameter sessionId: Session identifier
    /// - Returns: Publisher with the session details
    public func getSession(sessionId: String) -> AnyPublisher<MentalMathSession, APIError> {
        return apiClient.request(
            endpoint: APIClient.MentalMathEndpoint.getSession(sessionId: sessionId).path,
            method: .get
        )
    }
    
    /// Get all sessions for a child
    /// - Parameter childId: Child identifier
    /// - Returns: Publisher with array of sessions
    public func getSessions(childId: String) -> AnyPublisher<[MentalMathSession], APIError> {
        return apiClient.request(
            endpoint: APIClient.MentalMathEndpoint.getSessions(childId: childId).path,
            method: .get
        )
    }
    
    // MARK: - Progress and Reports
    
    /// Get progress for a child
    /// - Parameter childId: Child identifier
    /// - Returns: Publisher with progress data
    public func getProgress(childId: String) -> AnyPublisher<MentalMathProgress, APIError> {
        return apiClient.request(
            endpoint: APIClient.MentalMathEndpoint.getProgress(childId: childId).path,
            method: .get
        )
    }
    
    /// Get a report for a child
    /// - Parameters:
    ///   - childId: Child identifier
    ///   - period: Report period (daily, weekly, monthly)
    /// - Returns: Publisher with the report
    public func getReport(childId: String, period: MentalMathReport.ReportPeriod) -> AnyPublisher<MentalMathReport, APIError> {
        return apiClient.request(
            endpoint: APIClient.MentalMathEndpoint.getReport(childId: childId, period: period.rawValue).path,
            method: .get
        )
    }
}
