
import XCTest
import Foundation
@testable import Sleep

class InBedTest: XCTestCase {
    
    var StartTime: Date = Date();
    var EndTime: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!;
    var uuid: String = UUID().uuidString
    
    func testDoesNotThrowWhenEveythingIsInOrder() {
        XCTAssertNoThrow(InBed(uuid: uuid, startTime: StartTime, endTime: EndTime))
    }
    
    func testConstructorMapsParametersCorrectly() {
        let actual = InBed(uuid: uuid, startTime: StartTime, endTime: EndTime)
        
        XCTAssert(actual.Uuid == uuid)
        XCTAssert(actual.StartTime == StartTime)
        XCTAssert(actual.EndTime == EndTime)
    }
}
