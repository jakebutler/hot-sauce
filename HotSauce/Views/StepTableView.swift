import SwiftUI

struct StepTableView: View {
    let data: [StepData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Detailed History")
                .font(.headline)
                .foregroundColor(ColorTheme.darkBrown)
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Date")
                            .frame(width: 100, alignment: .leading)
                        Text("Steps")
                            .frame(width: 80, alignment: .trailing)
                        Text("Distance")
                            .frame(width: 80, alignment: .trailing)
                        Text("Calories")
                            .frame(width: 80, alignment: .trailing)
                        Text("Active")
                            .frame(width: 60, alignment: .trailing)
                    }
                    .font(.caption)
                    .foregroundColor(ColorTheme.darkBrown)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(ColorTheme.lightBeige.opacity(0.5))
                    
                    // Data rows
                    ForEach(data) { day in
                        HStack {
                            Text(day.formattedDate)
                                .frame(width: 100, alignment: .leading)
                            Text("\(day.steps)")
                                .frame(width: 80, alignment: .trailing)
                            Text(day.formattedDistance)
                                .frame(width: 80, alignment: .trailing)
                            Text(day.formattedCalories)
                                .frame(width: 80, alignment: .trailing)
                            Text("\(day.activeMinutes)m")
                                .frame(width: 60, alignment: .trailing)
                        }
                        .font(.caption)
                        .foregroundColor(ColorTheme.darkBrown)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        Divider()
                            .background(ColorTheme.darkBrown.opacity(0.2))
                    }
                }
            }
        }
    }
}

struct StepTableView_Previews: PreviewProvider {
    static var previews: some View {
        StepTableView(data: [
            StepData(date: Date(), steps: 8000, distance: 5000, calories: 300, activeMinutes: 45),
            StepData(date: Date().addingTimeInterval(86400), steps: 10000, distance: 6000, calories: 400, activeMinutes: 60)
        ])
    }
} 