import SwiftUI
import Charts

struct StepChartView: View {
    let data: [StepData]
    @State private var selectedData: StepData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("30-Day Step History")
                .font(.headline)
                .foregroundColor(ColorTheme.darkBrown)
            
            Chart {
                ForEach(data) { day in
                    LineMark(
                        x: .value("Date", day.date),
                        y: .value("Steps", day.steps)
                    )
                    .foregroundStyle(ColorTheme.warmOrange)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", day.date),
                        y: .value("Steps", day.steps)
                    )
                    .foregroundStyle(ColorTheme.warmOrange)
                }
                
                if let selected = selectedData {
                    RuleMark(
                        x: .value("Selected", selected.date)
                    )
                    .foregroundStyle(ColorTheme.darkBrown.opacity(0.3))
                    .annotation(position: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selected.formattedDate)
                                .font(.caption)
                                .foregroundColor(ColorTheme.darkBrown)
                            Text("\(selected.steps) steps")
                                .font(.caption)
                                .foregroundColor(ColorTheme.warmOrange)
                        }
                        .padding(8)
                        .background(ColorTheme.lightBeige)
                        .cornerRadius(8)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let steps = value.as(Int.self) {
                            Text("\(steps)")
                        }
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let x = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                    guard let date = proxy.value(atX: x) as Date? else { return }
                                    
                                    // Find the closest data point
                                    selectedData = data.min(by: {
                                        abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                                    })
                                }
                                .onEnded { _ in
                                    selectedData = nil
                                }
                        )
                }
            }
        }
    }
}

struct StepChartView_Previews: PreviewProvider {
    static var previews: some View {
        StepChartView(data: [
            StepData(date: Date(), steps: 8000, distance: 5000, calories: 300, activeMinutes: 45),
            StepData(date: Date().addingTimeInterval(86400), steps: 10000, distance: 6000, calories: 400, activeMinutes: 60)
        ])
        .frame(height: 200)
        .padding()
    }
} 