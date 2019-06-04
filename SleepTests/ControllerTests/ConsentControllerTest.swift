
import XCTest
import UIKit
@testable import Sleep

class ConsentControllerTest: XCTestCase {

    var controller : ConsentViewController!
    
    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        controller = (storyboard.instantiateViewController(withIdentifier: "consentView") as! ConsentViewController)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "AgeIs18OrOlder")
        UserDefaults.standard.removeObject(forKey: "IsWillingToParticipate")
    }

    func testGaveConsentSavesUserDefaults() {
        controller.acceptConsent(self)
        XCTAssert(UserDefaults.standard.bool(forKey: "AgeIs18OrOlder") == true)
        XCTAssert(UserDefaults.standard.bool(forKey: "IsWillingToParticipate") == true)
    }
}
