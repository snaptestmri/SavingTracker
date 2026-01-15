import SwiftUI

struct GoalCelebrationView: View {
    let goal: Goal
    let onDismiss: () -> Void
    let onCreateNewGoal: () -> Void
    
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var showShare = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Confetti effect
                if showConfetti {
                    ConfettiView()
                }
                
                // Celebration content
                VStack(spacing: 20) {
                    Text("🎉")
                        .font(.system(size: 100))
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: scale)
                    
                    Text("Goal Achieved!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text(goal.name)
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("You saved \(goal.formattedTargetAmount)!")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    VStack(spacing: 12) {
                        Button(action: onCreateNewGoal) {
                            Text("Create New Goal")
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
                        
                        Button(action: { showShare = true }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Achievement")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                        }
                        
                        Button(action: onDismiss) {
                            Text("Continue")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 20)
                )
                .padding(30)
            }
        }
        .onAppear {
            withAnimation {
                showConfetti = true
                scale = 1.0
                rotation = 360
            }
        }
        .sheet(isPresented: $showShare) {
            if let image = ShareableImageGenerator.shared.generateGoalAchievementImage(goal: goal) {
                ShareSheet(activityItems: [image])
            }
        }
    }
}

struct ConfettiView: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var color: Color
        var velocity: CGVector
    }
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: 8, height: 8)
                    .position(particle.position)
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
    }
    
    private func createParticles() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
        for _ in 0..<50 {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 2...5)
            particles.append(Particle(
                position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2),
                color: colors.randomElement() ?? .red,
                velocity: CGVector(
                    dx: cos(angle) * speed,
                    dy: sin(angle) * speed
                )
            ))
        }
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            for index in particles.indices {
                particles[index].position.x += particles[index].velocity.dx
                particles[index].position.y += particles[index].velocity.dy
                particles[index].velocity.dy += 0.2 // Gravity
            }
            
            // Remove particles that are off screen
            particles.removeAll { particle in
                particle.position.y > UIScreen.main.bounds.height + 100
            }
            
            if particles.isEmpty {
                timer.invalidate()
            }
        }
    }
}
