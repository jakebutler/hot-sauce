import XCTest
@testable import HotSauce

final class DashboardViewModelTests: XCTestCase {
    var viewModel: DashboardViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = DashboardViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.todaySteps, 0)
        XCTAssertTrue(viewModel.last30DaysData.isEmpty)
        XCTAssertEqual(viewModel.lastUpdated, "Never")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    func testLoadCachedData() {
        // Create test data
        let testData = [
            StepData(date: Date(), steps: 10000, distance: 5000, calories: 300, activeMinutes: 45),
            StepData(date: Date().addingTimeInterval(-86400), steps: 8000, distance: 4000, calories: 250, activeMinutes: 30)
        ]
        
        // Save test data
        CoreDataManager.shared.saveStepData(testData)
        
        // Create new view model to load cached data
        let newViewModel = DashboardViewModel()
        
        // Verify data was loaded
        XCTAssertEqual(newViewModel.todaySteps, 10000)
        XCTAssertEqual(newViewModel.last30DaysData.count, 2)
        XCTAssertEqual(newViewModel.last30DaysData[0].steps, 10000)
        XCTAssertEqual(newViewModel.last30DaysData[1].steps, 8000)
    }
} 