
import XCTest
import Foundation
@testable import Sleep

class AsleepTest: XCTestCase {

    var uuid: String = UUID().uuidString
    var StartTime: Date = Date();
    var EndTime: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!;

    func testDoesNotThrowWhenEveythingIsInOrder() {
        XCTAssertNoThrow(Asleep(uuid: uuid, startTime: StartTime, endTime: EndTime))
    }
    
    func testConstructorMapsParametersCorrectly() {
        let actual = Asleep(uuid: uuid, startTime: StartTime, endTime: EndTime)
        XCTAssert(actual.Uuid == uuid)
        XCTAssert(actual.StartTime == StartTime)
        XCTAssert(actual.EndTime == EndTime)
    }
}
