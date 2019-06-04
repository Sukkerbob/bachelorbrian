//
//  JobQueueTest.swift
//  SleepTests
//
//  Created by Brian Peter Olesen on 03/05/2019.
//  Copyright © 2019 Brian Peter Olesen. All rights reserved.
//

import XCTest
import HealthKit
@testable import Sleep

class JobMock : IJob {
    var didExecute : Bool = false
    
    func execute(anchor: HKQueryAnchor?) {
        didExecute = true
    }
}

class JobQueueTest: XCTestCase {
    
    var jobs : [IJob] = []
    var jobQueue : JobQueue?
    var anchor : HKQueryAnchor? = HKQueryAnchor(fromValue: 0)
    
    override func setUp() {
        jobs = [JobMock(), JobMock(), JobMock()]
        jobQueue = JobQueue(jobs: jobs)
        anchor = HKQueryAnchor(fromValue: 0)
        do {
            let data : Data = try NSKeyedArchiver.archivedData(withRootObject: anchor as Any, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: "Anchor")
        } catch {
            UserDefaults.standard.set(anchor, forKey: "Anchor")
        }
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "Anchor")
    }
    
    func testBasicConstructorDoesNotThrow() {
        XCTAssertNoThrow(JobQueue(jobs: jobs))
    }
    
    func testConstructorMapsParametersCorrectly() {
        let actual = JobQueue(jobs: jobs)
        XCTAssert(actual.Jobs.count == jobs.count)
    }
    
    func testNoAnchorIsSetWhenNoneIsStored() {
        UserDefaults.standard.removeObject(forKey: "Anchor")
        let actual = JobQueue(jobs: jobs)
        XCTAssert(actual.anchor == nil)
        XCTAssert(actual.Jobs.count == jobs.count)
    }
    
    func testExecuteAllJobsExecutesJobs() {
        jobQueue!.ExecuteAllJobs()
        for job in jobs {
            XCTAssert((job as! JobMock).didExecute == true)
        }
    }
}
