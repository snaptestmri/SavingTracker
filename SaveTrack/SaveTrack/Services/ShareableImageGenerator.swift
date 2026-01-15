import UIKit
import SwiftUI

class ShareableImageGenerator {
    static let shared = ShareableImageGenerator()
    
    private init() {}
    
    func generateGoalAchievementImage(goal: Goal) -> UIImage? {
        let size = CGSize(width: 1080, height: 1080)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background gradient
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(origin: .zero, size: size)
            gradient.colors = [
                UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0).cgColor, // #667eea
                UIColor(red: 0.46, green: 0.29, blue: 0.64, alpha: 1.0).cgColor  // #764ba2
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.render(in: context.cgContext)
            
            // Content
            let textColor = UIColor.white
            let titleFont = UIFont.boldSystemFont(ofSize: 72)
            let subtitleFont = UIFont.systemFont(ofSize: 48)
            let detailFont = UIFont.systemFont(ofSize: 36)
            
            // Title
            let title = "🎉 Goal Achieved!"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: textColor
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(
                x: (size.width - titleSize.width) / 2,
                y: size.height * 0.2,
                width: titleSize.width,
                height: titleSize.height
            )
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Goal name
            let goalName = goal.name
            let goalAttributes: [NSAttributedString.Key: Any] = [
                .font: subtitleFont,
                .foregroundColor: textColor
            ]
            let goalSize = goalName.size(withAttributes: goalAttributes)
            let goalRect = CGRect(
                x: (size.width - goalSize.width) / 2,
                y: size.height * 0.4,
                width: goalSize.width,
                height: goalSize.height
            )
            goalName.draw(in: goalRect, withAttributes: goalAttributes)
            
            // Amount
            let amount = goal.formattedTargetAmount
            let amountAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 96),
                .foregroundColor: textColor
            ]
            let amountSize = amount.size(withAttributes: amountAttributes)
            let amountRect = CGRect(
                x: (size.width - amountSize.width) / 2,
                y: size.height * 0.55,
                width: amountSize.width,
                height: amountSize.height
            )
            amount.draw(in: amountRect, withAttributes: amountAttributes)
            
            // App name
            let appName = "SaveTrack"
            let appAttributes: [NSAttributedString.Key: Any] = [
                .font: detailFont,
                .foregroundColor: textColor.withAlphaComponent(0.8)
            ]
            let appSize = appName.size(withAttributes: appAttributes)
            let appRect = CGRect(
                x: (size.width - appSize.width) / 2,
                y: size.height * 0.9,
                width: appSize.width,
                height: appSize.height
            )
            appName.draw(in: appRect, withAttributes: appAttributes)
        }
    }
    
    func generateBadgeImage(badge: Badge) -> UIImage? {
        let size = CGSize(width: 1080, height: 1080)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            let backgroundColor = UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0)
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Badge emoji
            let emojiFont = UIFont.systemFont(ofSize: 200)
            let emojiAttributes: [NSAttributedString.Key: Any] = [
                .font: emojiFont
            ]
            let emojiSize = badge.emoji.size(withAttributes: emojiAttributes)
            let emojiRect = CGRect(
                x: (size.width - emojiSize.width) / 2,
                y: size.height * 0.3,
                width: emojiSize.width,
                height: emojiSize.height
            )
            badge.emoji.draw(in: emojiRect, withAttributes: emojiAttributes)
            
            // Badge name
            let nameFont = UIFont.boldSystemFont(ofSize: 64)
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .font: nameFont,
                .foregroundColor: UIColor.white
            ]
            let nameSize = badge.name.size(withAttributes: nameAttributes)
            let nameRect = CGRect(
                x: (size.width - nameSize.width) / 2,
                y: size.height * 0.55,
                width: nameSize.width,
                height: nameSize.height
            )
            badge.name.draw(in: nameRect, withAttributes: nameAttributes)
            
            // Description
            let descFont = UIFont.systemFont(ofSize: 36)
            let descAttributes: [NSAttributedString.Key: Any] = [
                .font: descFont,
                .foregroundColor: UIColor.white.withAlphaComponent(0.9)
            ]
            let descSize = badge.description.size(withAttributes: descAttributes)
            let descRect = CGRect(
                x: (size.width - descSize.width) / 2,
                y: size.height * 0.65,
                width: descSize.width,
                height: descSize.height
            )
            badge.description.draw(in: descRect, withAttributes: descAttributes)
            
            // App name
            let appName = "SaveTrack"
            let appFont = UIFont.systemFont(ofSize: 32)
            let appAttributes: [NSAttributedString.Key: Any] = [
                .font: appFont,
                .foregroundColor: UIColor.white.withAlphaComponent(0.7)
            ]
            let appSize = appName.size(withAttributes: appAttributes)
            let appRect = CGRect(
                x: (size.width - appSize.width) / 2,
                y: size.height * 0.9,
                width: appSize.width,
                height: appSize.height
            )
            appName.draw(in: appRect, withAttributes: appAttributes)
        }
    }
    
    func generateStreakImage(streak: Streak) -> UIImage? {
        let size = CGSize(width: 1080, height: 1080)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background gradient
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(origin: .zero, size: size)
            gradient.colors = [
                UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1.0).cgColor, // #FF6B6B
                UIColor(red: 0.93, green: 0.35, blue: 0.44, alpha: 1.0).cgColor  // #EE5A6F
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.render(in: context.cgContext)
            
            // Fire emoji
            let emojiFont = UIFont.systemFont(ofSize: 150)
            let emojiAttributes: [NSAttributedString.Key: Any] = [
                .font: emojiFont
            ]
            let emoji = "🔥"
            let emojiSize = emoji.size(withAttributes: emojiAttributes)
            let emojiRect = CGRect(
                x: (size.width - emojiSize.width) / 2,
                y: size.height * 0.25,
                width: emojiSize.width,
                height: emojiSize.height
            )
            emoji.draw(in: emojiRect, withAttributes: emojiAttributes)
            
            // Streak number
            let streakText = "\(streak.currentStreak) Days"
            let streakFont = UIFont.boldSystemFont(ofSize: 120)
            let streakAttributes: [NSAttributedString.Key: Any] = [
                .font: streakFont,
                .foregroundColor: UIColor.white
            ]
            let streakSize = streakText.size(withAttributes: streakAttributes)
            let streakRect = CGRect(
                x: (size.width - streakSize.width) / 2,
                y: size.height * 0.45,
                width: streakSize.width,
                height: streakSize.height
            )
            streakText.draw(in: streakRect, withAttributes: streakAttributes)
            
            // Subtitle
            let subtitle = "Current Streak"
            let subtitleFont = UIFont.systemFont(ofSize: 48)
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: subtitleFont,
                .foregroundColor: UIColor.white.withAlphaComponent(0.9)
            ]
            let subtitleSize = subtitle.size(withAttributes: subtitleAttributes)
            let subtitleRect = CGRect(
                x: (size.width - subtitleSize.width) / 2,
                y: size.height * 0.6,
                width: subtitleSize.width,
                height: subtitleSize.height
            )
            subtitle.draw(in: subtitleRect, withAttributes: subtitleAttributes)
            
            // App name
            let appName = "SaveTrack"
            let appFont = UIFont.systemFont(ofSize: 32)
            let appAttributes: [NSAttributedString.Key: Any] = [
                .font: appFont,
                .foregroundColor: UIColor.white.withAlphaComponent(0.7)
            ]
            let appSize = appName.size(withAttributes: appAttributes)
            let appRect = CGRect(
                x: (size.width - appSize.width) / 2,
                y: size.height * 0.9,
                width: appSize.width,
                height: appSize.height
            )
            appName.draw(in: appRect, withAttributes: appAttributes)
        }
    }
    
    func generateMonthlySummaryImage(totalSaved: Decimal, entryCount: Int, topCategory: String) -> UIImage? {
        let size = CGSize(width: 1080, height: 1080)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            let backgroundColor = UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0)
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Title
            let title = "Monthly Summary"
            let titleFont = UIFont.boldSystemFont(ofSize: 64)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.white
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(
                x: (size.width - titleSize.width) / 2,
                y: size.height * 0.15,
                width: titleSize.width,
                height: titleSize.height
            )
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Total saved
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            let totalText = formatter.string(from: totalSaved as NSDecimalNumber) ?? "$0.00"
            let totalFont = UIFont.boldSystemFont(ofSize: 96)
            let totalAttributes: [NSAttributedString.Key: Any] = [
                .font: totalFont,
                .foregroundColor: UIColor.white
            ]
            let totalSize = totalText.size(withAttributes: totalAttributes)
            let totalRect = CGRect(
                x: (size.width - totalSize.width) / 2,
                y: size.height * 0.35,
                width: totalSize.width,
                height: totalSize.height
            )
            totalText.draw(in: totalRect, withAttributes: totalAttributes)
            
            // Entry count
            let entryText = "\(entryCount) entries"
            let entryFont = UIFont.systemFont(ofSize: 48)
            let entryAttributes: [NSAttributedString.Key: Any] = [
                .font: entryFont,
                .foregroundColor: UIColor.white.withAlphaComponent(0.9)
            ]
            let entrySize = entryText.size(withAttributes: entryAttributes)
            let entryRect = CGRect(
                x: (size.width - entrySize.width) / 2,
                y: size.height * 0.5,
                width: entrySize.width,
                height: entrySize.height
            )
            entryText.draw(in: entryRect, withAttributes: entryAttributes)
            
            // Top category
            let categoryText = "Top: \(topCategory)"
            let categoryFont = UIFont.systemFont(ofSize: 40)
            let categoryAttributes: [NSAttributedString.Key: Any] = [
                .font: categoryFont,
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let categorySize = categoryText.size(withAttributes: categoryAttributes)
            let categoryRect = CGRect(
                x: (size.width - categorySize.width) / 2,
                y: size.height * 0.65,
                width: categorySize.width,
                height: categorySize.height
            )
            categoryText.draw(in: categoryRect, withAttributes: categoryAttributes)
            
            // App name
            let appName = "SaveTrack"
            let appFont = UIFont.systemFont(ofSize: 32)
            let appAttributes: [NSAttributedString.Key: Any] = [
                .font: appFont,
                .foregroundColor: UIColor.white.withAlphaComponent(0.7)
            ]
            let appSize = appName.size(withAttributes: appAttributes)
            let appRect = CGRect(
                x: (size.width - appSize.width) / 2,
                y: size.height * 0.9,
                width: appSize.width,
                height: appSize.height
            )
            appName.draw(in: appRect, withAttributes: appAttributes)
        }
    }
}
