
import Foundation
import Parse

class ParseClientWrapper : IParseClientWrapper {
    
    static let GetClient = ParseClientWrapper()
    
    /// Read object from Parse (asynchronous)
    ///
    /// - parameter query: The Parse query to execute
    /// - parameter completionHandler: The functino to call upon query completion.
    ///
    /// - returns: Void
    func executeQuery(query: PFQuery<PFObject>, completionHandler: @escaping ([PFObject]?, Error?) -> Void) {
        query.findObjectsInBackground(block: completionHandler)
    }
    
    /// Executes query synchronously on the current thread.
    ///
    /// - parameter query: The Parse query to execute
    ///
    /// - returns: An array of parse objects
    func executeQuerySynchronous(query: PFQuery<PFObject>) throws -> [PFObject] {
        return try query.findObjects()
    }
    
    /// Write object to Parse (asynchronous)
    ///
    /// - parameter object: The parse object to save.
    ///
    /// - returns: A boolean representing if the deletion was successful or not.
    @discardableResult func saveObject(object: PFObject) -> Bool {
        do {
            try object.save()
            return true
        } catch {
            return false
        }
    }
    
    /// Deletes an object in Parse server
    ///
    /// - parameter object: The parse object to delete.
    ///
    /// - returns: A boolean representing if the deletion was successful or not.
    @discardableResult func deleteObject(object: PFObject) -> Bool {
        do {
            try object.delete()
            return true
        } catch {
            return false
        }
    }
}
