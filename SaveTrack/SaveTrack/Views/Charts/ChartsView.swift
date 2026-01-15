import SwiftUI
import Charts

struct ChartsView: View {
    @StateObject private var viewModel = ChartsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Chart Type Selector
                    Picker("Chart Type", selection: $viewModel.selectedChartType) {
                        ForEach(ChartsViewModel.ChartType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Period Selector
                    Picker("Period", selection: $viewModel.selectedPeriod) {
                        ForEach(ChartsViewModel.TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: viewModel.selectedPeriod) { _ in
                        viewModel.updateData()
                    }
                    .onChange(of: viewModel.selectedChartType) { _ in
                        updateChartTypeData()
                    }
                    
                    // Chart Display based on selected type
                    Group {
                        switch viewModel.selectedChartType {
                        case .line:
                            lineChartView
                        case .bar:
                            barChartView
                        case .trend:
                            trendAnalysisView
                        }
                    }
                    
                    // Category Breakdown (show for line and bar charts)
                    if viewModel.selectedChartType != .trend {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Savings by Category")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if #available(iOS 16.0, *) {
                                Chart(viewModel.categoryData) { item in
                                    SectorMark(
                                        angle: .value("Amount", Double(truncating: item.amount as NSDecimalNumber)),
                                        innerRadius: .ratio(0.5),
                                        angularInset: 2
                                    )
                                    .foregroundStyle(by: .value("Category", item.categoryName))
                                    .annotation(position: .overlay) {
                                        if item.percentage > 5 {
                                            Text("\(Int(item.percentage))%")
                                                .font(.caption2)
                                        }
                                    }
                                }
                                .frame(height: 250)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(16)
                                .padding(.horizontal)
                            } else {
                                // Fallback for iOS 15
                                CategoryBreakdownListView(data: viewModel.categoryData)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Summary Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Summary Stats")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "Total Saved", value: formatCurrency(viewModel.totalSaved))
                            StatCard(title: "Avg Per Day", value: formatCurrency(viewModel.averagePerDay))
                            StatCard(title: "Total Entries", value: "\(viewModel.totalEntries)")
                            StatCard(title: "Top Category", value: viewModel.topCategory)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
            .onAppear {
                viewModel.updateData()
                updateChartTypeData()
            }
        }
    }
    
    private func updateChartTypeData() {
        switch viewModel.selectedChartType {
        case .line:
            viewModel.updateData()
        case .bar:
            viewModel.updateMonthlyComparison()
            viewModel.updateWeekOverWeek()
        case .trend:
            viewModel.updateTrendAnalysis()
        }
    }
    
    // MARK: - Line Chart View
    private var lineChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Savings Over Time")
                .font(.headline)
                .padding(.horizontal)
            
            if #available(iOS 16.0, *) {
                Chart(viewModel.chartData) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Amount", Double(truncating: dataPoint.amount as NSDecimalNumber))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Amount", Double(truncating: dataPoint.amount as NSDecimalNumber))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667eea").opacity(0.3), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: 250)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            } else {
                ChartPlaceholderView(title: "Savings Over Time")
                    .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Bar Chart View
    private var barChartView: some View {
        VStack(spacing: 24) {
            // Monthly Comparison
            VStack(alignment: .leading, spacing: 12) {
                Text("Monthly Comparison")
                    .font(.headline)
                    .padding(.horizontal)
                
                if #available(iOS 16.0, *) {
                    Chart(viewModel.monthlyComparisonData) { data in
                        BarMark(
                            x: .value("Month", data.month),
                            y: .value("Amount", Double(truncating: data.amount as NSDecimalNumber))
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                    }
                    .frame(height: 250)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                } else {
                    MonthlyComparisonListView(data: viewModel.monthlyComparisonData)
                        .padding(.horizontal)
                }
            }
            
            // Week-over-Week
            VStack(alignment: .leading, spacing: 12) {
                Text("Week-over-Week")
                    .font(.headline)
                    .padding(.horizontal)
                
                if #available(iOS 16.0, *) {
                    Chart(viewModel.weekOverWeekData) { data in
                        BarMark(
                            x: .value("Week", data.weekLabel),
                            y: .value("Amount", Double(truncating: data.amount as NSDecimalNumber))
                        )
                        .foregroundStyle(Color(hex: "667eea"))
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                } else {
                    WeekComparisonListView(data: viewModel.weekOverWeekData)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Trend Analysis View
    private var trendAnalysisView: some View {
        VStack(spacing: 24) {
            if let trend = viewModel.trendData {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Trend Analysis")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        TrendCard(
                            title: "Weekly Growth",
                            value: String(format: "%.1f%%", trend.weeklyGrowth),
                            emoji: trend.weeklyGrowth >= 0 ? "📈" : "📉",
                            color: trend.weeklyGrowth >= 0 ? .green : .red
                        )
                        
                        TrendCard(
                            title: "Monthly Growth",
                            value: String(format: "%.1f%%", trend.monthlyGrowth),
                            emoji: trend.monthlyGrowth >= 0 ? "📈" : "📉",
                            color: trend.monthlyGrowth >= 0 ? .green : .red
                        )
                        
                        TrendCard(
                            title: "Average Daily",
                            value: formatCurrency(trend.averageDailySavings),
                            emoji: "💰",
                            color: Color(hex: "667eea")
                        )
                        
                        TrendCard(
                            title: "Best Day",
                            value: trend.bestDayOfWeek,
                            emoji: "📅",
                            color: Color(hex: "667eea")
                        )
                        
                        TrendCard(
                            title: "Top Category",
                            value: trend.bestCategory,
                            emoji: "🏆",
                            color: Color(hex: "667eea")
                        )
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("Not enough data for trend analysis")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(Color(hex: "667eea"))
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ChartPlaceholderView: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Charts require iOS 16+")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct CategoryBreakdownListView: View {
    let data: [CategoryChartData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(data) { item in
                HStack {
                    Text(item.categoryEmoji)
                        .font(.title2)
                    Text(item.categoryName)
                        .font(.subheadline)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatCurrency(item.amount))
                            .font(.headline)
                        Text("\(Int(item.percentage))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            }
        }
        .frame(height: 250)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

struct TrendCard: View {
    let title: String
    let value: String
    let emoji: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(emoji)
                .font(.title2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .foregroundColor(color)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct MonthlyComparisonListView: View {
    let data: [ChartsViewModel.MonthlyComparisonData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(data) { item in
                HStack {
                    Text(item.month)
                        .font(.subheadline)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatCurrency(item.amount))
                            .font(.headline)
                        Text("\(item.entryCount) entries")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            }
        }
        .frame(height: 250)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

struct WeekComparisonListView: View {
    let data: [ChartsViewModel.WeekComparisonData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(data) { item in
                HStack {
                    Text(item.weekLabel)
                        .font(.subheadline)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatCurrency(item.amount))
                            .font(.headline)
                        Text("\(item.entryCount) entries")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            }
        }
        .frame(height: 200)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}
