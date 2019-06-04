
import Foundation
import Parse

class InBedClient : IInBedClient {
    
    let parseClient : IParseClientWrapper
    let uuid : String
    
    init(parseClient: IParseClientWrapper) {
        uuid = UIDevice.current.identifierForVendor!.uuidString
        self.parseClient = parseClient
    }

    /// Asynchronously retrieves all of the InBed data that is stored in the Parse database. If there is an error, it calls the onFailure function, and if not, the onSuccess function is called with the retrieved InBed data.
    ///
    /// - parameter onSuccess: A function that will be called if InBed data can be successfully fetched from HealthKit
    /// - parameter onFailure: A function that will be called if InBed data can not be fetched from HealthKit
    ///
    /// - returns: Void
    func get(onSuccess: @escaping ([InBed]) -> Void, onFailure: @escaping () -> Void) {
        let query = PFQuery(className: "InBed")
        query.whereKey("uuid", equalTo: uuid)
        parseClient.executeQuery(query: query) { (objects: [PFObject]?, error: Error?) in
            if (error != nil) {
                onFailure()
                return
            }
            
            if let inBedObjects = objects {
                var inBedData:[InBed] = []
                for inBedObject in inBedObjects {
                    let inBed = self.PFobjectToInBedMapper(object: inBedObject)
                    inBedData.append(inBed)
                }
                onSuccess(inBedData)
            } else {
                onFailure()
            }
        }
    }
    

    /// Asynchronously saves the given InBed data to the Parse database.
    ///
    /// - parameter inBedData: A list of InBed models to be saved to the Parse database.
    ///
    /// - returns: A boolean representing whether or not the procedure was successful.
    func save(inBedData: [InBed]) -> Bool {
        var succeeded = true
        do {
            for inBed in inBedData {
                let inBedPfObject = InBedToPFobjectMapper(inBed: inBed)
                if (!parseClient.saveObject(object: inBedPfObject)) {
                    succeeded = false
                }
            }
        }
        return succeeded
    }
    
    /// Deletes all of the stored InBed data associated with this iPhone from the Parse database.
    ///
    /// - returns: A boolean representing whether or not the procedure was successful.
    func delete() -> Bool {
        let query = PFQuery(className: "InBed")
        query.whereKey("uuid", equalTo: uuid)
        var succeeded = true
        do {
            let inBedObjects = try parseClient.executeQuerySynchronous(query: query)
            for inBedObject in inBedObjects {
                if (!parseClient.deleteObject(object: inBedObject)) {
                    succeeded = false
                }
            }
        } catch {
            succeeded = false
        }
        return succeeded
    }

    /// Maps a parse object (PFObject) to our InBed data model.
    ///
    /// - parameter object: A PFObject representing the InBed data model.
    ///
    /// - returns: An InBed object.
    private func PFobjectToInBedMapper(object: PFObject) -> InBed {
        return InBed(uuid: uuid,
                     startTime: object["StartTime"] as! Date,
                     endTime: object["EndTime"] as! Date)
    }
    
    /// Maps our InBed data model to a parse object.
    ///
    /// - parameter inBed: An InBed object.
    ///
    /// - returns: A PFObject representing the InBed data model.
    private func InBedToPFobjectMapper(inBed: InBed) -> PFObject {
        let pfObject = PFObject(className: "InBed")
        pfObject["uuid"] = UIDevice.current.identifierForVendor?.uuidString
        pfObject["StartTime"] = inBed.StartTime
        pfObject["EndTime"] = inBed.EndTime
        return pfObject
    }
}
