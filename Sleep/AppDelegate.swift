
import UIKit
import HealthKit
import Parse
import SystemConfiguration

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let HealthKitClient : HKHealthStore = HKHealthStore()
    let secondsInADay : Int = 86400
    
    /// This function is called when mQoL-Sleep has finished launching. First the background fetch interval is set to 24 hours. Then we set the startup controller. If the user has not given consent to participate in the exploration, the ConsentView will be presented to the user, otherwise the MainView will be presented. Lastly, the Parse server client is configured and initialized, so there is a connection to the mQoL parse server.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(secondsInADay))
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ageConfirmed = UserDefaults.standard.bool(forKey: "AgeIs18OrOlder")
        let willingToParticipate = UserDefaults.standard.bool(forKey: "IsWillingToParticipate")
        
        let rootViewController = storyboard.instantiateViewController(withIdentifier: ageConfirmed && willingToParticipate ? "mainView" : "consentView")
        
        window?.rootViewController = rootViewController
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "mQoL-app-dk"
            $0.clientKey = "6MR5Y5xNUVO6B4"
            $0.server = "https://qol1.unige.ch/mqol-parse-dk"
        }

        if (Parse.currentConfiguration() == nil) {
            Parse.initialize(with: configuration)
        }
        
        return true
    }
    
    /// This function is called everytime mQoL-Sleep is allowed background execution time. If the user has not given consent to participate in the sleep exploration, nothing is done. If the user has given consent, it fetches all sleep data from HealthKit and saves it to the Parse server.
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionhandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let ageConfirmed = UserDefaults.standard.bool(forKey: "AgeIs18OrOlder")
        let willingToParticipate = UserDefaults.standard.bool(forKey: "IsWillingToParticipate")
        
        if (!ageConfirmed || !willingToParticipate || !deviceIsConnectedToWiFi() || UIDevice.current.batteryState != .charging) {
            completionhandler(UIBackgroundFetchResult.noData)
            return
        }

        let jobs = collectJobs()
        let jobQueue = JobQueue(jobs: jobs)
        jobQueue.ExecuteAllJobs()
        
        completionhandler(UIBackgroundFetchResult.newData)
        
        return
    }
    
    /// Setup for determining when a device is connected via WiFi and requires no user interaction, based on its flags. Uses parse server to check reachability.
    ///
    /// - returns: True if flags indicate automatic WiFi connection, otherwise false
    func deviceIsConnectedToWiFi() -> Bool {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "https://qol1.unige.ch/mqol-parse-dk") else {
            return false
        }
        
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        
        if (!networkIsWifi(with: flags)) {
            return false
        }
        
        return true
    }
    
    /// Determines if a reachability object is connected via WiFi and requires no user interaction, based on its flags
    ///
    /// - parameter flags: Network reachability flags
    ///
    /// - returns: True if flags indicate automatic WiFi connection, otherwise false
    func networkIsWifi(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let connectionIsWifi = !flags.contains(.isWWAN)
        let canConnectAutomatically = !flags.contains(.interventionRequired)
        return isReachable && connectionIsWifi && canConnectAutomatically
    }

    /// Collects all of the data collection jobs that should be executed during background execution.
    ///
    /// - returns: Jobs
    func collectJobs() -> [IJob] {
        var jobs : [IJob] = []
        
        let parseClient = ParseClientWrapper.GetClient

        jobs.append(buildCollectAsleepDataJob(parseClient: parseClient))
        jobs.append(buildCollectInBedDataJob(parseClient: parseClient))
        
        return jobs
    }

    /// Builds the CollectAsleepDataJob.
    ///
    /// - parameter parseClient: The parse server client.
    ///
    /// - returns: A CollectAsleepDataJob object
    func buildCollectAsleepDataJob(parseClient: IParseClientWrapper) -> CollectAsleepDataJob {
        let asleepClient : AsleepClient = AsleepClient(parseClient: parseClient)
        return CollectAsleepDataJob(asleepClient: asleepClient, healthKitClient: HealthKitClient)
    }
    
    /// Builds the CollectInBedDataJob.
    ///
    /// - parameter parseClient: The parse server client.
    ///
    /// - returns: A CollectInBedDataJob object
    func buildCollectInBedDataJob(parseClient: IParseClientWrapper) -> CollectInBedDataJob {
        let inBedClient : InBedClient = InBedClient(parseClient: parseClient)
        return CollectInBedDataJob(inBedClient: inBedClient, healthKitClient: HealthKitClient)
    }
}
