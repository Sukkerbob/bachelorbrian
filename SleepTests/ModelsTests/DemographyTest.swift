
import XCTest
import Foundation
@testable import Sleep

class DemographyTest: XCTestCase {
    
    var uuid: String = UUID().uuidString
    var birthYear: Int? = 1995;
    var Sex : BiologicalSex = BiologicalSex.Male
    
    func testDoesNotThrowWhenEveythingIsInOrder() {
        XCTAssertNoThrow(Demography(uuid: uuid, birthYear: birthYear, sex: Sex))
    }
    
    func testConstructorMapsParametersCorrectly() {
        let actual = Demography(uuid: uuid, birthYear: birthYear, sex: Sex)
        XCTAssert(actual.Uuid == uuid)
        XCTAssert(actual.BirthYear == birthYear)
        XCTAssert(actual.Sex == Sex)
    }
}
