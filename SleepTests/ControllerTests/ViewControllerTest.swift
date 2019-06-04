
import XCTest
import Charts
@testable import Sleep

class ViewControllerTest: XCTestCase {

    var controller : ViewController!
    
    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        controller = (storyboard.instantiateViewController(withIdentifier: "mainView") as! ViewController)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "IsWillingToParticipate")
    }

    func testEditDataCollectionTypesRemovesConsent() {
        controller.pauseDataCollection(UIButton())
        XCTAssert(UserDefaults.standard.bool(forKey: "IsWillingToParticipate") == false)
    }
    
    func testDrawRecommendedPieChart() {
        let pieChart : PieChartView = PieChartView()
        controller.drawRecommendedDayChart(view: pieChart)
        XCTAssert(pieChart.data != nil)
        let data = pieChart.data!
        XCTAssert(data.entryCount == 4)
        XCTAssert(pieChart.rotationEnabled == false)
        XCTAssert(pieChart.isUserInteractionEnabled == false)
        XCTAssert(pieChart.drawHoleEnabled == false)
    }
    
    func testSecondsToHours() {
        let seconds = 3600
        let hours = controller.secondsToHours(seconds: seconds)
        XCTAssert(hours == 1)
    }
}
