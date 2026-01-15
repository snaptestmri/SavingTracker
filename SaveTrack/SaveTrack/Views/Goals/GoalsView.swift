import SwiftUI

struct GoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    @State private var showCreateGoal = false
    @State private var showCelebration = false
    
    var body: some View {
        NavigationView {
            List {
                if !viewModel.activeGoals.isEmpty {
                    Section("ACTIVE GOALS") {
                        ForEach(viewModel.activeGoals) { goal in
                            GoalDetailCard(goal: goal)
                                .swipeActions {
                                    Button("Archive") {
                                        viewModel.archiveGoal(goal)
                                    }
                                }
                        }
                    }
                }
                
                if !viewModel.completedGoals.isEmpty {
                    Section("COMPLETED") {
                        ForEach(viewModel.completedGoals) { goal in
                            CompletedGoalCard(goal: goal)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateGoal = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateGoal) {
                CreateGoalView()
            }
            .sheet(isPresented: $showCelebration) {
                if let goal = viewModel.newlyCompletedGoal {
                    GoalCelebrationView(
                        goal: goal,
                        onDismiss: {
                            showCelebration = false
                            viewModel.newlyCompletedGoal = nil
                        },
                        onCreateNewGoal: {
                            showCelebration = false
                            viewModel.newlyCompletedGoal = nil
                            showCreateGoal = true
                        }
                    )
                }
            }
            .onChange(of: viewModel.newlyCompletedGoal) { newGoal in
                if newGoal != nil {
                    showCelebration = true
                }
            }
            .overlay {
                if viewModel.activeGoals.isEmpty && viewModel.completedGoals.isEmpty {
                    EmptyGoalsView {
                        showCreateGoal = true
                    }
                }
            }
        }
    }
}

struct GoalDetailCard: View {
    let goal: Goal
    @State private var showShare = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(.title3.bold())
                Text("\(goal.period.displayName) Goal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(goal.progressPercentage / 100))
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
            
            VStack(spacing: 8) {
                Text(goal.formattedCurrentAmount)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                Text("of \(goal.formattedTargetAmount) saved (\(Int(goal.progressPercentage))%)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            if let daysRemaining = goal.daysRemaining {
                Text("\(daysRemaining) days remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
            
            if goal.isCompleted {
                Button(action: { showShare = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Achievement")
                    }
                    .font(.subheadline)
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
                .padding(.top, 8)
            }
        }
        .padding(25)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .sheet(isPresented: $showShare) {
            if let image = ShareableImageGenerator.shared.generateGoalAchievementImage(goal: goal) {
                ShareSheet(activityItems: [image])
            }
        }
    }
}

struct CompletedGoalCard: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goal.name)
                    .font(.headline)
                Spacer()
                Text("✅ Goal Achieved!")
                    .font(.caption.bold())
                    .foregroundColor(.green)
            }
            
            if let completedAt = goal.completedAt {
                Text("Completed \(formatDate(completedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .opacity(0.7)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

struct EmptyGoalsView: View {
    let onCreateGoal: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No goals yet")
                .font(.title2.bold())
            Text("Create a savings goal to track your progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(action: onCreateGoal) {
                Text("Create Your First Goal")
                    .font(.headline)
                    .foregroundColor(.white)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CreateGoalView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = GoalsViewModel()
    @State private var name: String = ""
    @State private var targetAmountText: String = ""
    @State private var period: Goal.GoalPeriod = .monthly
    @State private var startDate: Date = Date()
    @State private var endDate: Date?
    @State private var hasEndDate: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Goal Name", text: $name)
                    
                    TextField("Target Amount", text: $targetAmountText)
                        .keyboardType(.decimalPad)
                    
                    Picker("Period", selection: $period) {
                        ForEach(Goal.GoalPeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("Set End Date", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("End Date", selection: Binding(
                            get: { endDate ?? Date() },
                            set: { endDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                
                Section {
                    Button(action: saveGoal) {
                        Text("Create Goal")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Create Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !targetAmountText.isEmpty &&
        Decimal(string: targetAmountText) != nil &&
        Decimal(string: targetAmountText)! > 0 &&
        (!hasEndDate || (endDate != nil && endDate! > startDate))
    }
    
    private func saveGoal() {
        guard let targetAmount = Decimal(string: targetAmountText) else { return }
        
        let goal = Goal(
            name: name,
            targetAmount: targetAmount,
            period: period,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil
        )
        
        viewModel.saveGoal(goal)
        dismiss()
    }
}
