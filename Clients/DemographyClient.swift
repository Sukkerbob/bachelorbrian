
import Foundation
import Parse

class DemographyClient : IDemographyClient {
    
    let parseClient : IParseClientWrapper
    let uuid : String
    
    init(parseClient: IParseClientWrapper) {
        uuid = UIDevice.current.identifierForVendor!.uuidString
        self.parseClient = parseClient
    }
    
    /// Asynchronously retrieves the Demography data that is stored in the Parse database and is associated with this iPhone. If there is an error, it calls the onFailure function, and if not, the onSuccess function is called with the retrieved InBed data.
    ///
    /// - parameter onSuccess: A function that will be called if Demography data can be successfully fetched from HealthKit
    /// - parameter onFailure: A function that will be called if Demography data can not be fetched from HealthKit
    ///
    /// - returns: Void
    func get(onSuccess: @escaping (Demography) -> Void, onFailure: @escaping () -> Void) {
        let query = PFQuery(className: "Demography")
        query.whereKey("uuid", equalTo: uuid)
        parseClient.executeQuery(query: query) {(objects: [PFObject]?, error: Error?) in
            if (error != nil) {
                onFailure()
                return
            }
            
            if let demographies = objects {
                var demographyData:[Demography] = []
                for demographyObject in demographies {
                    let demography = self.PFobjectToDemographyMapper(object: demographyObject)
                    demographyData.append(demography)
                }
                if (demographyData.count != 1) {
                    onFailure()
                } else {
                    onSuccess(demographyData[0])
                }
            } else {
                onFailure()
            }
        }
    }
    
    /// Asynchronously saves the given Demography data to the Parse database. It first retrieves any demography data associated with this iPhone to see if there already is demography data associated with this iPhone. If there is, nothing is saved as we do not want duplicate demography rows.
    ///
    /// - parameter AsleepData: A list of Asleep models to be saved to the Parse database.
    ///
    /// - returns: Void
    func save(demography: Demography) {
        do {
            let query = PFQuery(className: "Demography")
            query.whereKey("uuid", equalTo: uuid)
            let demographies = try parseClient.executeQuerySynchronous(query: query)
            if (demographies.count == 1) {
                let pfObject = demographies[0]
                if (demography.BirthYear == nil) {
                    pfObject.remove(forKey: "BirthYear")
                } else {
                    pfObject["BirthYear"] = demography.BirthYear!
                }
                pfObject["Sex"] = demography.Sex == BiologicalSex.Male ? 0 :
                    demography.Sex == BiologicalSex.Female ? 1 : 2
                parseClient.saveObject(object: pfObject)
                return
            }
        } catch {
            
        }
        let demographyPfObject = DemographyToPFobjectMapper(demography: demography)
        parseClient.saveObject(object: demographyPfObject)
    }
    
    /// Deletes all of the stored Demography data associated with this iPhone from the Parse database.
    ///
    /// - returns: A boolean representing whether or not the procedure was successful.
    func delete() -> Bool {
        let query = PFQuery(className: "Demography")
        query.whereKey("uuid", equalTo: uuid)
        var succeeded = true
        do {
            let demographyObjects = try parseClient.executeQuerySynchronous(query: query)
            for demographyObject in demographyObjects {
                if (!parseClient.deleteObject(object: demographyObject)) {
                    succeeded = false
                }
            }
        } catch {
            succeeded = false
        }
        return succeeded
    }
    
    /// Maps a parse object (PFObject) to our Demography data model.
    ///
    /// - parameter object: A PFObject representing the Demography data model.
    ///
    /// - returns: A Demography object.
    private func PFobjectToDemographyMapper(object: PFObject) -> Demography {
        return Demography(uuid: uuid,
                          birthYear: object["BirthYear"] as? Int,
                          sex: (object["Sex"] as! Int) == 0 ? BiologicalSex.Male :
                            (object["Sex"] as! Int) == 1 ? BiologicalSex.Female : BiologicalSex.Unavailable)
    }
    
    /// Maps our Demography data model to a parse object.
    ///
    /// - parameter Demography: An Demongraphy object.
    ///
    /// - returns: A parse object (PFObject)
    private func DemographyToPFobjectMapper(demography: Demography) -> PFObject {
        let pfObject = PFObject(className: "Demography")
        pfObject["uuid"] = UIDevice.current.identifierForVendor?.uuidString
        if (demography.BirthYear != nil) {
            pfObject["BirthYear"] = demography.BirthYear
        }
        pfObject["Sex"] = demography.Sex == BiologicalSex.Male ? 0 :
                            demography.Sex == BiologicalSex.Female ? 1 : 2
        return pfObject
    }
}
