
import Foundation
import Parse

protocol IParseClientWrapper {
    func executeQuery(query: PFQuery<PFObject>, completionHandler: @escaping ([PFObject]?, Error?) -> Void)
    func executeQuerySynchronous(query: PFQuery<PFObject>) throws -> [PFObject]
    @discardableResult func saveObject(object: PFObject) -> Bool
    @discardableResult func deleteObject(object: PFObject) -> Bool
}
