//
//  CollectSleepDataJobTest.swift
//  SleepTests
//
//  Created by Brian Peter Olesen on 03/05/2019.
//  Copyright © 2019 Brian Peter Olesen. All rights reserved.
//

import XCTest
import HealthKit
@testable import Sleep

class InBedApiMock : IInBedClient {
    
    var didSaveInBedData = false
    
    func get(onSuccess: @escaping ([InBed]) -> Void, onFailure: @escaping () -> Void){
        
    }
    func save(inBedData: [InBed]) -> Bool {
        didSaveInBedData = true
        return true
    }
    
    func delete() -> Bool{
        return true
    }
    
}

class CollectInBedDataJobTest: XCTestCase {
    
    var healthKitClient : HKHealthStore = HKHealthStore()
    var InBedClient : IInBedClient = InBedApiMock()
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "Anchor")
    }
    
    func testConstructorMapsParametersCorrectly() {
        let actual = CollectInBedDataJob(inBedClient: InBedClient, healthKitClient: healthKitClient)
        XCTAssert(actual.HealthKitClient == healthKitClient)
    }
    
    func testExecutesSetsAnchor() {
        let job = CollectInBedDataJob(inBedClient: InBedClient, healthKitClient: healthKitClient)
        job.execute(anchor: nil)
        sleep(1)
        let storedAnchor = UserDefaults.standard.object(forKey: "Anchor")
        XCTAssert(storedAnchor != nil)
    }
    
    func testExecuteSavesSleepData() {
        let job = CollectInBedDataJob(inBedClient: InBedApiMock(), healthKitClient: healthKitClient)
        job.execute(anchor: nil)
        sleep(1)
        let actual = job.InBedClient as! InBedApiMock
        XCTAssert(actual.didSaveInBedData == true)
    }
    
    func testUiCompletionHandlerExecutesIfExists() {
        let job = CollectInBedDataJob(inBedClient: InBedApiMock(), healthKitClient: healthKitClient, uiCompletionHandler: uiCompletionHandler)
        job.execute(anchor: nil)
    }
    
    private func uiCompletionHandler(_ _: [InBed]) -> Void {
        XCTAssert(true)
    }
}
