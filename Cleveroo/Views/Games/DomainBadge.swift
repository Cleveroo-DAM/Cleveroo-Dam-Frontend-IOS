import SwiftUI

struct DomainBadge: View {
    let domain: String
    
    var domainColor: Color {
        switch domain.lowercased() {
        case "creativity":
            return Color(red: 1.0, green: 0.42, blue: 0.62) // #FF6B9D
        case "attention":
            return Color(red: 0.4, green: 0.5, blue: 0.93) // #667eea
        case "personality":
            return Color(red: 0.94, green: 0.58, blue: 0.98) // #f093fb
        case "social":
            return Color(red: 0.31, green: 0.98, blue: 0.99) // #4facfe
        default:
            return Color.blue
        }
    }
    
    var domainEmoji: String {
        switch domain.lowercased() {
        case "creativity":
            return "🎨"
        case "attention":
            return "👁️"
        case "personality":
            return "🧠"
        case "social":
            return "🤝"
        default:
            return "🎮"
        }
    }
    
    var domainLabel: String {
        switch domain.lowercased() {
        case "creativity":
            return "Créativité"
        case "attention":
            return "Attention"
        case "personality":
            return "Personnalité"
        case "social":
            return "Social"
        default:
            return domain
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Text(domainEmoji)
                .font(.system(size: 14))
            
            Text(domainLabel)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(domainColor.opacity(0.2))
        .foregroundColor(domainColor)
        .cornerRadius(6)
    }
}

#Preview {
    VStack(spacing: 12) {
        DomainBadge(domain: "creativity")
        DomainBadge(domain: "attention")
        DomainBadge(domain: "personality")
        DomainBadge(domain: "social")
    }
    .padding()
}
