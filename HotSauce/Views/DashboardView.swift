import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Today's Steps Card
                VStack(spacing: 10) {
                    Text("Today's Steps")
                        .font(.headline)
                        .foregroundColor(ColorTheme.darkBrown)
                    
                    Text("\(viewModel.todaySteps)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(ColorTheme.warmOrange)
                    
                    Text("Last updated: \(viewModel.lastUpdated)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(ColorTheme.lightBeige)
                .cornerRadius(15)
                .shadow(radius: 2)
                
                // 30-Day Chart
                StepChartView(data: viewModel.last30DaysData)
                    .frame(height: 200)
                    .padding()
                    .background(ColorTheme.lightBeige)
                    .cornerRadius(15)
                    .shadow(radius: 2)
                
                // Detailed Table
                StepTableView(data: viewModel.last30DaysData)
                    .frame(maxWidth: .infinity)
                    .background(ColorTheme.lightBeige)
                    .cornerRadius(15)
                    .shadow(radius: 2)
            }
            .padding()
        }
        .background(ColorTheme.lightBeige.opacity(0.3))
        .refreshable {
            await viewModel.refreshData()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
        .task {
            await viewModel.refreshData()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
} 