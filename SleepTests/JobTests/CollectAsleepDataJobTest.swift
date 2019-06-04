
import XCTest
import HealthKit
@testable import Sleep

class AsleepApiMock : IAsleepClient {

    var didSaveSleepData = false
    
    func get(onSuccess: @escaping ([Asleep]) -> Void, onFailure: @escaping () -> Void){
        
    }
    
    func save(asleepData: [Asleep]) -> Bool {
        didSaveSleepData = true
        return true
    }
    
    func delete() -> Bool{
        return true
    }
    
}

class CollectAsleepDataJobTest: XCTestCase {

    var healthKitClient : HKHealthStore = HKHealthStore()
    var AsleepClient : IAsleepClient = AsleepApiMock()

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "Anchor")
    }

    func testConstructorMapsParametersCorrectly() {
        let actual = CollectAsleepDataJob(asleepClient: AsleepClient, healthKitClient: healthKitClient)
        XCTAssert(actual.HealthKitClient == healthKitClient)
    }

    func testExecutesSetsAnchor() {
        let job = CollectAsleepDataJob(asleepClient: AsleepClient, healthKitClient: healthKitClient)
        job.execute(anchor: nil)
        sleep(1)
        let storedAnchor = UserDefaults.standard.object(forKey: "Anchor")
        XCTAssert(storedAnchor != nil)
    }
    
    func testExecuteSavesSleepData() {
        let job = CollectAsleepDataJob(asleepClient: AsleepApiMock(), healthKitClient: healthKitClient)
        job.execute(anchor: nil)
        sleep(1)
        let actual = job.AsleepClient as! AsleepApiMock
        XCTAssert(actual.didSaveSleepData == true)
    }
    
    func testUicompletionhandlerCalledIfExists() {
        let job = CollectAsleepDataJob(asleepClient: AsleepApiMock(), healthKitClient: healthKitClient, uiCompletionHandler: uiCompletionHandler)
        job.execute(anchor: nil)
    }
    
    private func uiCompletionHandler(_ _: [Asleep]) -> Void {
        XCTAssert(true)
    }
}
