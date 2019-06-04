
import Foundation
import HealthKit
import UIKit
import Parse

class AsleepClient : IAsleepClient {
    
    let parseClient : IParseClientWrapper
    let uuid : String
    
    init(parseClient: IParseClientWrapper) {
        uuid = UIDevice.current.identifierForVendor!.uuidString
        self.parseClient = parseClient
    }
    
    /// Asynchronously retrieves all of the Alseep data that is stored in the Parse database. If there is an error, it calls the onFailure function, and if not, the onSuccess function is called with the retrieved Asleep data.
    ///
    /// - parameter onSuccess: A function that will be called if Asleep data can be successfully fetched from HealthKit
    /// - parameter onFailure: A function that will be called if Asleep data can not be fetched from HealthKit
    ///
    /// - returns: Void
    func get(onSuccess: @escaping ([Asleep]) -> Void, onFailure: @escaping () -> Void) {
        let query = PFQuery(className: "Asleep")
        query.whereKey("uuid", equalTo: uuid)
        parseClient.executeQuery(query: query) { (objects: [PFObject]?, error: Error?) in
            if (error != nil) {
                onFailure()
                return
            }
            
            if let asleepObjects = objects {
                var asleepData:[Asleep] = []
                for asleepObject in asleepObjects {
                    let asleep = self.PFobjectToSleepMapper(object: asleepObject)
                    asleepData.append(asleep)
                }
                onSuccess(asleepData)
            } else {
                onFailure()
            }
        }
    }
    
    /// Asynchronously saves the given Asleep data to the Parse database.
    ///
    /// - parameter AsleepData: A list of Asleep models to be saved to the Parse database.
    ///
    /// - returns: A boolean representing whether or not the procedure was successful.
    func save(asleepData: [Asleep]) -> Bool {
        var succeeded = true
        for asleep in asleepData {
            let asleepPfObject = SleepToPFobjectMapper(sleep: asleep)
            if (!parseClient.saveObject(object: asleepPfObject)) {
                succeeded = false
            }
        }
        return succeeded
    }
    
    /// Deletes all of the stored Asleep data associated with this iPhone from the Parse database.
    ///
    /// - returns: A boolean representing whether or not the procedure was successful.
    func delete() -> Bool {
        let query = PFQuery(className: "Asleep")
        query.whereKey("uuid", equalTo: uuid)
        var succeeded = true
        do {
            let asleepObjects = try parseClient.executeQuerySynchronous(query: query)
            for asleepObject in asleepObjects {
                if (!parseClient.deleteObject(object: asleepObject)) {
                    succeeded = false
                }
            }
        } catch {
            succeeded = false
        }
        return succeeded
    }
    
    /// Maps a parse object (PFObject) to our Asleep data model.
    ///
    /// - parameter object: A PFObject representing the Asleep data model.
    ///
    /// - returns: An Asleep object.
    private func PFobjectToSleepMapper(object: PFObject) -> Asleep {
        return Asleep(uuid: uuid,
                      startTime: object["StartTime"] as! Date,
                      endTime: object["EndTime"] as! Date)
    }
    
    /// Maps our Asleep data model to a parse object.
    ///
    /// - parameter Asleep: An Asleep object.
    ///
    /// - returns: A parse object (PFObject)
    private func SleepToPFobjectMapper(sleep: Asleep) -> PFObject {
        let pfObject = PFObject(className: "Asleep")
        pfObject["uuid"] = UIDevice.current.identifierForVendor?.uuidString
        pfObject["StartTime"] = sleep.StartTime
        pfObject["EndTime"] = sleep.EndTime
        return pfObject
    }
}
