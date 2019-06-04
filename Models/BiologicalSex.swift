
import Foundation

/// Biological sex enum. The unavailable option is used either when the sex is not set on the iPhone or mQoL-Sleep is not allowed to read it.
enum BiologicalSex : Int {
    case Male = 0
    case Female = 1
    case Unavailable = 2
}
