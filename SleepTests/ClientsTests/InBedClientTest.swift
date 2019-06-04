
import XCTest
import Parse
@testable import Sleep

class InBedParseClientMock : IParseClientWrapper {

    static let GetInstance = InBedParseClientMock()
    
    var InBedData : [PFObject]?
    var Error : Error?
    var QueryShouldSucceed : Bool
    var MethodShouldSucceed : Bool
    
    private init() {
        QueryShouldSucceed = true
        MethodShouldSucceed = true
    }
    
    func executeQuery(query: PFQuery<PFObject>, completionHandler: @escaping ([PFObject]?, Error?) -> Void) {
        completionHandler(InBedData, Error)
    }
    
    func executeQuerySynchronous(query: PFQuery<PFObject>) throws -> [PFObject] {
        if (!QueryShouldSucceed || InBedData == nil) {
            throw ParseErrorMock.FailedToFindObjectsError("Failed To Find Objects.")
        }
        
        return InBedData!
    }
    
    func saveObject(object: PFObject) -> Bool {
        if (!MethodShouldSucceed) {
            return false
        }
        
        InBedData = [object]
        return true
    }
    
    func deleteObject(object: PFObject) -> Bool {
        if (!MethodShouldSucceed) {
            return false
        }
        
        InBedData = nil
        return true
    }
    
}

class InBedClientTest: XCTestCase {
    
    var inBedClient : IInBedClient = InBedClient(parseClient: InBedParseClientMock.GetInstance)
    var uuid: String = "E328ABA6-56E2-4C7C-B9FF-BF37B292FB08"
    
    override func setUp() {
        let parseClient = InBedParseClientMock.GetInstance
        
        let startDate = Date(timeIntervalSinceReferenceDate: 0)
        let endDate = startDate + 1
        let inBedObject = PFObject(className: "InBed")
        inBedObject["uuid"] = uuid
        inBedObject["StartTime"] = startDate
        inBedObject["EndTime"] = endDate
        
        parseClient.InBedData = [inBedObject]
        parseClient.Error = nil
        parseClient.QueryShouldSucceed = true
        parseClient.MethodShouldSucceed = true
    }
    
    func testGetCallsOnFailureWhenErrorIsNotNil() {
        InBedParseClientMock.GetInstance.Error = NSError(domain: "", code: 1, userInfo: nil)
        inBedClient.get(onSuccess: { (data: [InBed]) in
            XCTAssert(false)
        }) {
            XCTAssert(true)
        }
    }
    
    func testGetOnSuccess(){
        let startDate = Date(timeIntervalSinceReferenceDate: 0)
        let endDate = startDate + 1
        let testObject = PFObject(className: "InBedtest")
        testObject["uuid"] = uuid
        testObject["StartTime"] = startDate
        testObject["EndTime"] = endDate
        let expected = InBed(uuid: uuid, startTime: startDate, endTime: endDate)
        InBedParseClientMock.GetInstance.InBedData = [testObject]
        inBedClient.get(onSuccess: { (inBedData: [InBed]) in
            for actual in inBedData {
                XCTAssert(actual.Uuid == self.uuid)
                XCTAssert(actual.StartTime==expected.StartTime)
                XCTAssert(actual.EndTime==expected.EndTime)
            }
        }) {
            XCTAssert(false)
        }
    }
    
    func testSave() {
        let startDate = Date(timeIntervalSinceReferenceDate: 0)
        let endDate = startDate + 1
        let inBedData = [InBed(uuid: uuid, startTime: startDate, endTime: endDate)]
        inBedClient.save(inBedData: inBedData)
        let actual = InBedParseClientMock.GetInstance.InBedData![0]
        XCTAssert(actual["uuid"] as! String == uuid)
        XCTAssert(actual["StartTime"] as! Date == startDate)
        XCTAssert(actual["EndTime"] as! Date == endDate)
    }
    
    func testDelete(){
        XCTAssert(inBedClient.delete())
    }
    
    func testGetCallsOnFailureWhenObjectsIsNull() {
        InBedParseClientMock.GetInstance.InBedData = nil
        inBedClient.get(onSuccess: { (inBedData: [InBed]) in
            XCTAssert(false)
        }) {
            XCTAssert(true)
        }
    }
    
    func testSaveFailsIfAnObjectCannotBeSaved() {
       InBedParseClientMock.GetInstance.MethodShouldSucceed = false
        let inBedData = [InBed(uuid: uuid, startTime: Date()-1, endTime: Date())]
        XCTAssert(!inBedClient.save(inBedData: inBedData))
    }
    
    func testDeleteFailsWhenParseCannotDeleteObjects() {
        InBedParseClientMock.GetInstance.MethodShouldSucceed = false
        XCTAssert(!inBedClient.delete())
    }
    
    func testDeleteFailsWhenQueryThrows() {
        InBedParseClientMock.GetInstance.QueryShouldSucceed = false
        XCTAssert(!inBedClient.delete())
    }
}
