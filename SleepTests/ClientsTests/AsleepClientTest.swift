
import XCTest
import Parse
@testable import Sleep

class AsleepParseClientMock : IParseClientWrapper {
    
    static let GetInstance = AsleepParseClientMock()
    
    var AsleepData : [PFObject]?
    var Error : Error?
    var QueryShouldSucceed : Bool
    var MethodShouldSucceed : Bool
    
    private init() {
        QueryShouldSucceed = true
        MethodShouldSucceed = true
    }
    
    func executeQuery(query: PFQuery<PFObject>, completionHandler: @escaping ([PFObject]?, Error?) -> Void) {
        completionHandler(AsleepData, Error)
    }
    
    func executeQuerySynchronous(query: PFQuery<PFObject>) throws -> [PFObject] {
        if (!QueryShouldSucceed || AsleepData == nil) {
            throw ParseErrorMock.FailedToFindObjectsError("Failed To Find Objects.")
        }
        
        return AsleepData!
    }
    
    func saveObject(object: PFObject) -> Bool {
        if (!MethodShouldSucceed) {
            return false;
        }
        
        AsleepData = [object]
        return true
    }
    
    func deleteObject(object: PFObject) -> Bool {
        if (!MethodShouldSucceed) {
            return false
        }
        AsleepData = nil
        return true
    }
}

class AsleepClientTest: XCTestCase {

    var asleepClient : IAsleepClient = AsleepClient(parseClient: AsleepParseClientMock.GetInstance)
    var uuid: String = "E328ABA6-56E2-4C7C-B9FF-BF37B292FB08"
    
    override func setUp() {
        let parseClient = AsleepParseClientMock.GetInstance
        
        let startDate = Date(timeIntervalSinceReferenceDate: 0)
        let endDate = startDate + 1
        let asleepPfObject = PFObject(className: "Asleep")
        asleepPfObject["uuid"] = uuid
        asleepPfObject["StartTime"] = startDate
        asleepPfObject["EndTime"] = endDate
        
        parseClient.AsleepData = [asleepPfObject]
        parseClient.Error = nil
        parseClient.QueryShouldSucceed = true
        parseClient.MethodShouldSucceed = true
    }
    
    func testGetCallsOnFailureWhenErrorIsNotNil() {
        AsleepParseClientMock.GetInstance.Error = NSError(domain: "", code: 1, userInfo: nil)
        asleepClient.get(onSuccess: { (data: [Asleep]) in
            XCTAssert(false)
        }) {
            XCTAssert(true)
        }
    }
    
    func testGetOnSuccess(){
        let startDate = Date(timeIntervalSinceReferenceDate: 0)
        let endDate = startDate + 1
        let testObject = PFObject(className: "Asleeptest")
        testObject["uuid"] = uuid
        testObject["StartTime"] = startDate
        testObject["EndTime"] = endDate
        let expected = Asleep(uuid: uuid, startTime: startDate, endTime: endDate)
        AsleepParseClientMock.GetInstance.AsleepData = [testObject]
        asleepClient.get(onSuccess: { (asleepData: [Asleep]) in
            for actual in asleepData {
                XCTAssert(actual.Uuid == expected.Uuid)
                XCTAssert(actual.StartTime == expected.StartTime)
                XCTAssert(actual.EndTime == expected.EndTime)
            }
        }) {
            XCTAssert(false)
        }
    }
    
    func testSave() {
        AsleepParseClientMock.GetInstance.AsleepData = nil
        
        let startDate = Date(timeIntervalSinceReferenceDate: 0)
        let endDate = startDate + 1
        let asleepData = Asleep(uuid: uuid, startTime: startDate, endTime: endDate)
        
        asleepClient.save(asleepData: [asleepData])
        let actual = AsleepParseClientMock.GetInstance.AsleepData![0]
        XCTAssert(actual["uuid"] as! String == uuid)
        XCTAssert(actual["StartTime"] as! Date == startDate)
        XCTAssert(actual["EndTime"] as! Date == endDate)
    }
    
    func testDelete() {
        XCTAssert(asleepClient.delete() == true)
    }
    
    func testGetCallsOnFailureWhenObjectsIsNull() {
        AsleepParseClientMock.GetInstance.AsleepData = nil
        asleepClient.get(onSuccess: { (asleepData: [Asleep]) in
            XCTAssert(false)
        }) {
            XCTAssert(true)
        }
    }
    
    func testSaveFailsIfAnObjectCannotBeSaved() {
        AsleepParseClientMock.GetInstance.MethodShouldSucceed = false
        let asleepData = [Asleep(uuid: uuid, startTime: Date()-1, endTime: Date())]
        XCTAssert(!asleepClient.save(asleepData: asleepData))
    }
    
    func testDeleteFailsWhenParseCannotDeleteObjects() {
        AsleepParseClientMock.GetInstance.MethodShouldSucceed = false
        XCTAssert(!asleepClient.delete())
    }
    
    func testDeleteFailsWhenQueryThrows() {
        AsleepParseClientMock.GetInstance.QueryShouldSucceed = false
        XCTAssert(!asleepClient.delete())
    }
}
