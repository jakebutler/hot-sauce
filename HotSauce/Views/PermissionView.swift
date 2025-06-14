import SwiftUI

struct PermissionView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.walk")
                .font(.system(size: 60))
                .foregroundColor(ColorTheme.warmOrange)
            
            Text("Welcome to Hot Sauce")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.darkBrown)
            
            Text("To track your steps, we need access to your Health data.")
                .multilineTextAlignment(.center)
                .foregroundColor(ColorTheme.darkBrown)
                .padding(.horizontal)
            
            if let error = healthKitManager.error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button(action: {
                isRequesting = true
                Task {
                    await healthKitManager.requestAuthorization()
                    isRequesting = false
                }
            }) {
                Text("Grant Permission")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorTheme.warmOrange)
                    .cornerRadius(10)
            }
            .disabled(isRequesting)
            .padding(.horizontal)
            
            if isRequesting {
                ProgressView()
                    .padding()
            }
        }
        .padding()
        .background(ColorTheme.lightBeige)
    }
}

struct PermissionView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionView(healthKitManager: HealthKitManager())
    }
} 