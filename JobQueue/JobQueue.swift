
import Foundation
import HealthKit
import UIKit

class JobQueue: IJobQueue {
    
    let Jobs : [IJob]!
    var anchor : HKQueryAnchor?
    
    init(jobs: [IJob]) {
        Jobs = jobs
        anchor = self.getAnchor()
    }
    
    /// Executes all jobs in it's Jobs field.
    ///
    /// - returns: Void
    func ExecuteAllJobs() {
        for job in Jobs {
            job.execute(anchor: anchor)
        }
    }
    
    /// Gets the HealthKit anchor stored in UserDefaults.
    ///
    /// - returns: HKQueryAnchor? - The anchor if there is any, else nil
    private func getAnchor() -> HKQueryAnchor? {
        var anchor : HKQueryAnchor?
        let storedAnchor = UserDefaults.standard.object(forKey: "Anchor")
        
        if (storedAnchor == nil) {
            return nil
        } else {
            do {
                anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: storedAnchor as! Data)
            } catch {
                anchor = nil
            }
        }
        
        return anchor
    }
}
