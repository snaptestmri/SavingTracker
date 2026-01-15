import Foundation
import Combine

class GoalsViewModel: ObservableObject {
    @Published var activeGoals: [Goal] = []
    @Published var completedGoals: [Goal] = []
    @Published var newlyCompletedGoal: Goal?
    
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var previousCompletedGoalIds: Set<UUID> = []
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        dataManager.$goals
            .receive(on: DispatchQueue.main)
            .sink { [weak self] goals in
                self?.updateGoals(goals: goals)
            }
            .store(in: &cancellables)
    }
    
    private func updateGoals(goals: [Goal]) {
        let currentCompletedGoalIds = Set(goals.filter { $0.isCompleted }.map { $0.id })
        
        // Check for newly completed goals
        let newlyCompleted = goals.filter { goal in
            goal.isCompleted && !previousCompletedGoalIds.contains(goal.id)
        }
        
        if let newGoal = newlyCompleted.first {
            newlyCompletedGoal = newGoal
            NotificationManager.shared.scheduleGoalAchievementNotification(goalName: newGoal.name)
        }
        
        previousCompletedGoalIds = currentCompletedGoalIds
        
        activeGoals = goals.filter { $0.isActive }
            .sorted { goal1, goal2 in
                if let days1 = goal1.daysRemaining, let days2 = goal2.daysRemaining {
                    if days1 != days2 {
                        return days1 < days2
                    }
                }
                return goal1.progressPercentage > goal2.progressPercentage
            }
        
        completedGoals = goals.filter { $0.isCompleted }
            .sorted { ($0.completedAt ?? $0.createdAt) > ($1.completedAt ?? $1.createdAt) }
    }
    
    func saveGoal(_ goal: Goal) {
        dataManager.saveGoal(goal)
    }
    
    func deleteGoal(_ goal: Goal) {
        dataManager.deleteGoal(goal)
    }
    
    func archiveGoal(_ goal: Goal) {
        var archivedGoal = goal
        archivedGoal.isCompleted = true
        archivedGoal.completedAt = Date()
        dataManager.saveGoal(archivedGoal)
    }
}
