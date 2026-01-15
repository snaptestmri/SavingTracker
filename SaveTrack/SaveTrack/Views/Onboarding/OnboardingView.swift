import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        hasCompletedOnboarding = true
                    }
                    .padding()
                }
                
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        icon: "💰",
                        title: "Welcome to SaveTrack",
                        description: "Track your daily money-saving efforts and watch your savings grow over time."
                    )
                    .tag(0)
                    
                    OnboardingPageView(
                        icon: "🔒",
                        title: "Your Data Stays Local",
                        description: "All your savings data is stored securely on your device. No cloud, no accounts needed."
                    )
                    .tag(1)
                    
                    OnboardingPageView(
                        icon: "✏️",
                        title: "Quick & Easy Logging",
                        description: "Add entries in seconds with amount, category, and optional notes."
                    )
                    .tag(2)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Action buttons
                VStack(spacing: 12) {
                    if currentPage < 2 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            hasCompletedOnboarding = true
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        hasCompletedOnboarding = true
                    }) {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPageView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(icon)
                .font(.system(size: 100))
            
            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
