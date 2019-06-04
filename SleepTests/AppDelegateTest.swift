
import UIKit
import Foundation
import XCTest
import Parse
import SystemConfiguration
@testable import Sleep

class AppDelegateTest : XCTestCase {
    let appDelegate = AppDelegate()
    
    func testApplicationStartsAtConsentViewWhenUserHasNotGivenConsent() {
        UserDefaults.standard.removeObject(forKey: "AgeIs18OrOlder")
        UserDefaults.standard.removeObject(forKey: "IsWillingToParticipate")
        appDelegate.window = UIWindow()
        _ = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
        XCTAssert(appDelegate.window!.rootViewController is ConsentViewController)
    }
    
    func testApplicationStartsAtMainViewWhenUserHasGivenConsent() {
        UserDefaults.standard.set(true, forKey: "AgeIs18OrOlder")
        UserDefaults.standard.set(true, forKey: "IsWillingToParticipate")
        appDelegate.window = UIWindow()
        _ = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
        XCTAssert(appDelegate.window!.rootViewController is ViewController)
    }
    
    func testIsConnectedToWifi() {
        XCTAssert(appDelegate.deviceIsConnectedToWiFi())
    }
    
    func testNetworkIsWifiFailsWhenItIsCellular() {
        var flags = SCNetworkReachabilityFlags()
        flags.insert(SCNetworkReachabilityFlags.reachable)
        flags.insert(SCNetworkReachabilityFlags.isWWAN)
        flags.insert(SCNetworkReachabilityFlags.interventionRequired)
        XCTAssert(!appDelegate.networkIsWifi(with: flags))
    }
    
    func testNetworkIsWifiFailsWhenInterventionIsRequired() {
        var flags = SCNetworkReachabilityFlags()
        flags.insert(SCNetworkReachabilityFlags.reachable)
        flags.insert(SCNetworkReachabilityFlags.interventionRequired)
        XCTAssert(!appDelegate.networkIsWifi(with: flags))
    }
    
    func testNetworkIsWifiSucceedsWhenItIsWifi() {
        var flags = SCNetworkReachabilityFlags()
        flags.insert(SCNetworkReachabilityFlags.reachable)
        XCTAssert(appDelegate.networkIsWifi(with: flags))
    }
    
    func testCollectJobs() {
        let jobs = appDelegate.collectJobs()
        XCTAssert(jobs.count == 2)
        XCTAssert(jobs[0] is CollectAsleepDataJob)
        XCTAssert(jobs[1] is CollectInBedDataJob)
    }
    
    func testBackgroundFetchFailsWhenAgeIsNot18OrOlder() {
        appDelegate.application(UIApplication.shared) { (UIBackgroundFetchResult) in
            XCTAssert(UIBackgroundFetchResult.rawValue == 1)
        }
    }
    
    func testBackgroundFetchFailsWhenUserIsNotWillingToParticipate() {
        UserDefaults.standard.set(true, forKey: "AgeIs18OrOlder")
        appDelegate.application(UIApplication.shared) { (UIBackgroundFetchResult) in
            XCTAssert(UIBackgroundFetchResult.rawValue == 1)
        }
    }
    
    func testBackgroundFetchFailsWhenBatteryIsNotCharging() {
        UserDefaults.standard.set(true, forKey: "AgeIs18OrOlder")
        UserDefaults.standard.set(true, forKey: "IsWillingToParticipate")
        appDelegate.application(UIApplication.shared) { (UIBackgroundFetchResult) in
            XCTAssert(UIBackgroundFetchResult.rawValue == 1)
        }
    }
}
