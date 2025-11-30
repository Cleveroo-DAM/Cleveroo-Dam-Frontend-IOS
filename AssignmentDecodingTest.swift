import Foundation

// Test the Assignment decoding with the new AnyCodable approach
let testJSON = """
[{"_id":"692c16a0d7f56ec720a43aef","title":"Dessiner un cercle ⭕️","description":"Dessine un cercle.","type":"drawing","status":"submitted","parentId":"6919ef820d85496dcfbb84ff","childId":{"_id":"6922e26fecaeef8e94c50546","age":8},"dueDate":"2025-12-01T10:03:00.000Z","rewardPoints":5,"submissionPhotos":["/uploads/assignments/fe948aba-d1aa-430a-b57c-bae6b7270d5c.png"],"createdAt":"2025-11-30T10:04:16.404Z","updatedAt":"2025-11-30T10:33:55.952Z","__v":1,"submittedAt":"2025-11-30T10:33:55.950Z"}]
"""

do {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let assignments = try decoder.decode([Assignment].self, from: testJSON.data(using: .utf8)!)
    
    print("✅ Successfully decoded \(assignments.count) assignments!")
    for (index, assignment) in assignments.enumerated() {
        print("📋 Assignment \(index + 1):")
        print("   Title: \(assignment.title)")
        print("   Type: \(assignment.type.displayName)")
        print("   Status: \(assignment.status.displayName)")
        print("   Child ID: \(assignment.childId)")
        print("   Parent ID: \(assignment.parentId)")
    }
} catch let DecodingError.dataCorruptedError(key, context) {
    print("❌ Data corrupted error at key \(key): \(context.debugDescription)")
} catch let DecodingError.keyNotFound(key, context) {
    print("❌ Key not found: \(key) - \(context.debugDescription)")
} catch let DecodingError.typeMismatch(type, context) {
    print("❌ Type mismatch for \(type): \(context.debugDescription)")
    print("   Coding path: \(context.codingPath)")
} catch {
    print("❌ Decoding error: \(error)")
}
