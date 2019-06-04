
import Foundation
import HealthKit
import UIKit

class CollectInBedDataJob : IJob {
    
    let HealthKitClient : HKHealthStore!
    let InBedClient : IInBedClient!
    let UiCompletionHandler : (([InBed]) -> Void)?
    
    init(inBedClient : IInBedClient, healthKitClient : HKHealthStore, uiCompletionHandler : (([InBed]) -> Void)? = nil) {
        InBedClient = inBedClient
        HealthKitClient = healthKitClient
        UiCompletionHandler = uiCompletionHandler
    }
    
    /// Executes the job. This will fetch all the InBed data on the iPhone since the last fetch. It then calls the completionHandler function with the fetched data.
    ///
    /// - parameter anchor: A HKQueryAnchor?. This is used to only collect the new data (since last data collection)
    ///
    /// - returns: Void
    func execute(anchor: HKQueryAnchor?) {
        if let inBedType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            let anchorQuery = HKAnchoredObjectQuery(type: inBedType, predicate: nil, anchor: anchor, limit: HKObjectQueryNoLimit, resultsHandler: completionHandler)
            
            HealthKitClient.execute(anchorQuery)
        }
    }
    
    /// The completion handler for the execute above.
    /// If there was no error when fetching healthkit data, it tries to update the anchor, then converts the resulting data into our InBed model and saves the InBed data to the Parse database.
    ///
    /// - parameter query: A HKAnchoredObjectQuery. This is the query that HealthKit will execute.
    /// - parameter result: The result from the query, if there is any.
    /// - parameter deleted: Data that has been deleted since last query.
    /// - parameter newAnchor: A new HKQueryAnchor to be used in future queries.
    /// - parameter error: The error, if there is any.
    ///
    /// - returns: Void
    private func completionHandler(query: HKAnchoredObjectQuery, result: [HKSample]?, deleted: [HKDeletedObject]?, newAnchor: HKQueryAnchor?, error: Error?) -> Void {
        if error != nil {
            return
        }
        
        var inBedData : [InBed] = []
        
        for item in result ?? [] {
            let uuid = UIDevice.current.identifierForVendor!.uuidString
            if let sample = item as? HKCategorySample {
                if (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) {
                    let inBed = InBed(uuid: uuid, startTime: sample.startDate, endTime: sample.endDate)
                    inBedData.append(inBed)
                }
            }
        }
        InBedClient.save(inBedData: inBedData)
        
        do {
            let data : Data = try NSKeyedArchiver.archivedData(withRootObject: newAnchor as Any, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: "Anchor")
        } catch {
            // Jobs must not throw exceptions if no anchor is given.
            // If they did, one failed job would stop all data collection
        }
        
        if let UiCompletionHandler = UiCompletionHandler {
            DispatchQueue.main.async {
                self.InBedClient.get(onSuccess: UiCompletionHandler, onFailure: { () in return })
            }
        }
    }
}
