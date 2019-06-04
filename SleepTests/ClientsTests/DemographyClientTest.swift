
import XCTest
import Parse
@testable import Sleep

class DemographyParseClientMock : IParseClientWrapper {
    
    static let GetInstance = DemographyParseClientMock()
    
    var DemographyData : [PFObject]?
    var Error : Error?
    var DidSaveObject : Bool
    var QueryShouldSucceed : Bool
    var MethodShouldSucceed : Bool
    
    private init() {
        QueryShouldSucceed = true
        MethodShouldSucceed = true
        DidSaveObject = false
    }
    
    func executeQuery(query: PFQuery<PFObject>, completionHandler: @escaping ([PFObject]?, Error?) -> Void) {
        completionHandler(DemographyData, Error)
    }
    
    func executeQuerySynchronous(query: PFQuery<PFObject>) throws -> [PFObject] {
        if (!QueryShouldSucceed || DemographyData == nil) {
            throw ParseErrorMock.FailedToFindObjectsError("")
        }
        
        return DemographyData!
    }
    
    func saveObject(object: PFObject) -> Bool {
        if (!MethodShouldSucceed) {
            return false
        }
        
        DemographyData = [object]
        return true
    }
    
    func deleteObject(object: PFObject) -> Bool {
        if (!MethodShouldSucceed) {
            return false
        }
        
        DemographyData = nil
        return true
    }
    
}

class DemographyClientTest: XCTestCase {
    
    var demographyClient : IDemographyClient = DemographyClient(parseClient: DemographyParseClientMock.GetInstance)
    var uuid: String = "E328ABA6-56E2-4C7C-B9FF-BF37B292FB08"
    
    override func setUp() {
        let parseClient = DemographyParseClientMock.GetInstance
        
        let birthYear = 1995
        let sexData = BiologicalSex.Female
        let demographyObject = PFObject(className: "Demographytest")
        demographyObject["uuid"] = uuid
        demographyObject["BirthYear"] = birthYear
        demographyObject["Sex"] = sexData.rawValue
        
        parseClient.DemographyData = [demographyObject]
        parseClient.Error = nil
        parseClient.DidSaveObject = false
        parseClient.MethodShouldSucceed = true
        parseClient.QueryShouldSucceed = true
    }
    
    func testGetCallsOnFailureWhenErrorIsNotNil() {
        DemographyParseClientMock.GetInstance.Error = NSError(domain: "", code: 1, userInfo: nil)
        demographyClient.get(onSuccess: { (data: Demography) in
            XCTAssert(false)
        }) {
            XCTAssert(true)
        }
    }
    
    func testGetCallsOnSuccessWhenEverythingIsInOrder(){
        let birthYear = 1995
        let sexData = BiologicalSex.Female
        let testObject = PFObject(className: "Demographytest")
        testObject["uuid"] = uuid
        testObject["BirthYear"] = birthYear
        testObject["Sex"] = sexData.rawValue
        let expected = Demography(uuid: uuid, birthYear: birthYear, sex: sexData)
        DemographyParseClientMock.GetInstance.DemographyData = [testObject]
        demographyClient.get(onSuccess: { (actual: Demography) in
            XCTAssert(actual.Uuid == self.uuid)
            XCTAssert(actual.BirthYear == expected.BirthYear)
            XCTAssert(actual.Sex == expected.Sex)
        }) {
            XCTAssert(false)
        }
    }
    
    func testGetCallsOnFailureWhenThereIsNotExactlyOneDemographyDataPoint() {
        let dateOfBirth = Date(timeIntervalSinceReferenceDate: 0)
        let sexData = BiologicalSex.Male
        let demographyObject = PFObject(className: "Demographytest")
        demographyObject["uuid"] = "Testuuid"
        demographyObject["DateOfBirth"] = dateOfBirth
        demographyObject["Sex"] = sexData.rawValue
        DemographyParseClientMock.GetInstance.DemographyData = [demographyObject, demographyObject]
        demographyClient.get(onSuccess: { (actual: Demography) in
            XCTAssert(false)
        }) {
            XCTAssert(true)
        }
    }
    
    func testGetCallsOnFailureWhenResultIsNil() {
        DemographyParseClientMock.GetInstance.DemographyData = nil
        demographyClient.get(onSuccess: { (actual: Demography) in
            XCTAssert(false)
        }) {
            XCTAssert(true)
        }
    }
    
    func testSaveActuallySavesWhenNoDemographyDataIsStored() {
        DemographyParseClientMock.GetInstance.DemographyData = nil
        let birthYear = 1995
        let sexData = BiologicalSex.Male
        let demographyData = Demography(uuid: uuid, birthYear: birthYear, sex: sexData)
        demographyClient.save(demography: demographyData)
        let actual = DemographyParseClientMock.GetInstance.DemographyData![0]
        XCTAssert(actual["uuid"] as! String == uuid)
        XCTAssert(actual["BirthYear"] as! Int == birthYear)
        XCTAssert(actual["Sex"] as! BiologicalSex.RawValue == sexData.rawValue)
    }
    
    func testSaveDoesNotSaveNewWhenDemographyAlreadyExists() {
        let birthYear = 1995
        let sexData = BiologicalSex.Female
        let demographyData = Demography(uuid: uuid, birthYear: birthYear, sex: sexData)
        demographyClient.save(demography: demographyData)
        let actual = DemographyParseClientMock.GetInstance.DemographyData![0]
        XCTAssert(actual["uuid"] as! String == uuid)
        XCTAssert(actual["BirthYear"] as! Int == birthYear)
        XCTAssert(actual["Sex"] as! BiologicalSex.RawValue == sexData.rawValue)
        XCTAssert(!DemographyParseClientMock.GetInstance.DidSaveObject)
    }
    
    func testSaveInsertsNullWhenDateOfBirthIsNull() {
        let birthYear : Int? = nil
        let sexData = BiologicalSex.Female
        let demographyData = Demography(uuid: uuid, birthYear: birthYear, sex: sexData)
        demographyClient.save(demography: demographyData)
        let actual = DemographyParseClientMock.GetInstance.DemographyData![0]
        XCTAssert(actual["uuid"] as! String == uuid)
        XCTAssert(actual["BirthYear"] as! Int? == nil)
        XCTAssert(actual["Sex"] as! BiologicalSex.RawValue == sexData.rawValue)
        XCTAssert(!DemographyParseClientMock.GetInstance.DidSaveObject)
    }
    
    func testSaveWorksForMales() {
        let birthYear = 1995
        let sexData = BiologicalSex.Male
        let demographyData = Demography(uuid: uuid, birthYear: birthYear, sex: sexData)
        demographyClient.save(demography: demographyData)
        let actual = DemographyParseClientMock.GetInstance.DemographyData![0]
        XCTAssert(actual["uuid"] as! String == uuid)
        XCTAssert(actual["BirthYear"] as! Int == birthYear)
        XCTAssert(actual["Sex"] as! BiologicalSex.RawValue == sexData.rawValue)
    }
    
    func testSaveWorksForFemales() {
        let birthYear = 1995
        let sexData = BiologicalSex.Female
        let demographyData = Demography(uuid: uuid, birthYear: birthYear, sex: sexData)
        demographyClient.save(demography: demographyData)
        let actual = DemographyParseClientMock.GetInstance.DemographyData![0]
        XCTAssert(actual["uuid"] as! String == uuid)
        XCTAssert(actual["BirthYear"] as! Int == birthYear)
        XCTAssert(actual["Sex"] as! BiologicalSex.RawValue == sexData.rawValue)
    }
    
    func testSaveWorksForUnavailableSex() {
        let birthYear = 1995
        let sexData = BiologicalSex.Unavailable
        let demographyData = Demography(uuid: uuid, birthYear: birthYear, sex: sexData)
        demographyClient.save(demography: demographyData)
        let actual = DemographyParseClientMock.GetInstance.DemographyData![0]
        XCTAssert(actual["uuid"] as! String == uuid)
        XCTAssert(actual["BirthYear"] as! Int == birthYear)
        XCTAssert(actual["Sex"] as! BiologicalSex.RawValue == sexData.rawValue)
    }
    
    func testDelete(){
        XCTAssert(demographyClient.delete() == true)
    }
    
    func testDeleteFailsWhenParseCannotDeleteObjects() {
        DemographyParseClientMock.GetInstance.MethodShouldSucceed = false
        XCTAssert(!demographyClient.delete())
    }
    
    func testDeleteFailsWhenQueryThrows() {
        DemographyParseClientMock.GetInstance.QueryShouldSucceed = false
        XCTAssert(!demographyClient.delete())
    }
}
