
import UIKit
import HealthKit
import Charts

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var deleteData: UIButton!
    @IBOutlet weak var userDataChartView: PieChartView!
    @IBOutlet weak var recommendedChartView: PieChartView!
    @IBOutlet weak var responseMessege: UITextField!
    @IBOutlet weak var info: UIButton!
    @IBOutlet weak var popupcenterH: NSLayoutConstraint!
    @IBOutlet weak var popupcenterV: NSLayoutConstraint!
    @IBOutlet weak var popupH: NSLayoutConstraint!
    @IBOutlet weak var popupW: NSLayoutConstraint!
    
//    let UserDefaults : IUserDefaultsWrapper = UserDefaultsWrapper()
    let HealthKitClient : HKHealthStore = HKHealthStore()
    var asleepClient : IAsleepClient = AsleepClient(parseClient: ParseClientWrapper.GetClient)
    let inBedClient : IInBedClient = InBedClient(parseClient: ParseClientWrapper.GetClient)
    let demographyClient : IDemographyClient = DemographyClient(parseClient: ParseClientWrapper.GetClient)
    
    /// This function is called before the MainView appears to the user. It is used to authorize mQoL-Sleep to read data from HealthKit, and setup the MainView by fetching sleep data stored on the Parse server and drawing pie charts.
    ///
    /// - returns: Void
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authorizeHealthKit()
        userDataChartView.noDataText = ""
        drawRecommendedDayChart(view: recommendedChartView)
    }
    
    /// Draws the recommended 24 hour day pie chart on the given PieChartView.
    ///
    /// - parameter view: The view on which to draw the chart.
    ///
    /// - returns: Void
    func drawRecommendedDayChart(view: PieChartView) {
        let entries : [PieChartDataEntry] = [
            PieChartDataEntry(value: 7.5),
            PieChartDataEntry(value: 0.5),
            PieChartDataEntry(value: 8),
            PieChartDataEntry(value: 8)
        ]
        
        let dataSet = PieChartDataSet(entries : entries, label : "Recommended 24 hours")
        ChartsDrawer.DrawStaticPieChart(dataSet: dataSet, view: view)
    }
    
    /// Draws the average 24 hour day pie chart on the given PieChartView, based on the user's data.
    ///
    /// - parameter aslepData: A list of the user's Asleep objects.
    ///
    /// - returns: Void
    func drawUserAverageDayChart(asleepData: [Asleep]) {
        DispatchQueue.main.async {
            if (asleepData.count <= 0) {
                self.responseMessege.text = "No stored data"
                return
            }
            
            var totalsleep : Float = 0.0
            for sleepData in asleepData {
                totalsleep += self.secondsToHours(seconds: Int(sleepData.EndTime.timeIntervalSince(sleepData.StartTime)))
            }
            totalsleep = totalsleep/Float(asleepData.count)
            
            let resttime = Double((24-totalsleep-0.5)/2)
            var entries : [PieChartDataEntry] = Array()
            entries.append(PieChartDataEntry(value: Double(totalsleep), label : "Average sleep"))
            entries.append(PieChartDataEntry(value: 0.5, label: "Exercise"))
            entries.append(PieChartDataEntry(value: resttime, label : "Light activity"))
            entries.append(PieChartDataEntry(value: resttime, label : "Sedentary"))
            
            let dataSet = PieChartDataSet(entries: entries, label: "Your average 24 hours")
            
            ChartsDrawer.DrawPieChart(dataSet: dataSet, view: self.userDataChartView)
        }
    }
    
    /// If the user has not already authorized mQoL-Sleep to read data from HealthKit, this will ask the user to do so. This opens up the Apple Health application on the page at which the user can authorize this. When the user is done, the iPhone reopens mQoL-Sleep.
    /// If the mQoL-Sleep is authorized, the completion handler function collects all data.
    ///
    /// - returns: Void
    func authorizeHealthKit() {
        let healKitTypesToRead : Set<HKObjectType> = [
            HKCharacteristicType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
            HKCharacteristicType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
        ]
        
        if !HKHealthStore.isHealthDataAvailable() {
            return
        }
        
        HealthKitClient.requestAuthorization(toShare: [], read: healKitTypesToRead) { (success, error) in
            if (error != nil) {
                return
            }
            
            self.collectDemography()
            
            let asleepJob = CollectAsleepDataJob(asleepClient: self.asleepClient, healthKitClient: self.HealthKitClient, uiCompletionHandler: self.drawUserAverageDayChart)
            let inBedJob = CollectInBedDataJob(inBedClient: self.inBedClient, healthKitClient: self.HealthKitClient)
            let jobQueue = JobQueue(jobs: [asleepJob, inBedJob])
            
            jobQueue.ExecuteAllJobs()
        }
    }
    
    /// Collects apple health demography information and saves it to Parse database.
    ///
    /// - returns: Void
    private func collectDemography() {
        do {
            let dob = try self.HealthKitClient.dateOfBirthComponents()
            let sex : BiologicalSex;
            switch try self.HealthKitClient.biologicalSex().biologicalSex {
                case .male: sex = BiologicalSex.Male
                case .female: sex = BiologicalSex.Female
                default: sex = BiologicalSex.Unavailable
            }
            let uuid = UIDevice.current.identifierForVendor!.uuidString
            let demography = Demography(uuid: uuid, birthYear: dob.year, sex: sex)
            self.demographyClient.save(demography: demography)
        } catch {
            // Guard catch, so the app does not crash when fetching demography data
        }
    }
    
    /// This function is called when the user clicks the "Pause Exploration" button. It removes the locally stored "IsWillingToParticipate" variable and navigates to the consent view.
    ///
    /// - parameter sender: The button that is associated with this function.
    ///
    /// - returns: Void
    @IBAction func pauseDataCollection(_ sender: UIButton) {
        let confirmAlert = UIAlertController(title: "Pause Exploration",
                                             message: "Are you sure you want to pause your sleep exploration?",
                                             preferredStyle: UIAlertController.Style.alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Yes",
             style: UIAlertAction.Style.destructive, handler: {(action) in
                UserDefaults.standard.removeObject(forKey: "IsWillingToParticipate")
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "consentView") as! ConsentViewController
                self.present(newViewController, animated: true, completion: nil)
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: {(action) in
            return
        }))
        
        self.present(confirmAlert, animated: true, completion: nil)
    }
    
    /// This function is called when the user clicks the "Delete Exploration" button. The user is presented with an alert, asking if they are sure they want to delete the exploration. If they are sure, it deletes all sleep and demography data associated with the iPhone from the Parse database. Finally, it will notify the user of whether the data was successfully deleted or not.
    ///
    /// - parameter sender: The delete exploration button on the main view.
    ///
    /// - returns: Void
    @IBAction func deleteExploration(_ sender: Any) {
        
        let confirmAlert = UIAlertController(title: "Delete exploration",
                                             message: "Are you sure you want to delete your sleep exploration?",
                                             preferredStyle: UIAlertController.Style.alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Yes",
                                             style: UIAlertAction.Style.destructive,
                                             handler: {(action) in
            DispatchQueue.global().async {
                if (self.inBedClient.delete()
                    && self.asleepClient.delete()
                    && self.demographyClient.delete()) {
                    UserDefaults.standard.removeObject(forKey: "Anchor")
                    DispatchQueue.main.async {
                        self.userDataChartView.clear()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.presentErrorAlert(title: "Error",
                                               message: "An error occured when deleting your data.",
                                               tryAgainHandler: {() in
                            self.deleteExploration(self)
                        })
                    }
                }
            }
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "No",
                                             style: UIAlertAction.Style.cancel,
                                             handler: {(action) in
            return
        }))
        
        self.present(confirmAlert, animated: true, completion: nil)
    }
    
    func presentErrorAlert(title: String, message: String, tryAgainHandler:@escaping (() -> Void)) -> Void {
        let responseAlert = UIAlertController(title: title,
                                              message: message,
                                              preferredStyle: UIAlertController.Style.alert)
        
        responseAlert.addAction(UIAlertAction(title: "Try Again",
                                              style: UIAlertAction.Style.default,
                                              handler: {(action) in tryAgainHandler()}))
        
        responseAlert.addAction(UIAlertAction(title: "Cancel",
                                              style: UIAlertAction.Style.default,
                                              handler: {(action) in
                                                return
        }))
        
        self.present(responseAlert, animated: true, completion: nil)
    }
    
    /// This function is called when the user clicks the information button. The view is then overlayed with an information text box.
    ///
    /// - parameter sender: The info button in the main view.
    ///
    /// - returns: Void
    @IBAction func showPieChartInfo(_ sender: Any) {
        popupcenterH.constant = 0
        popupcenterV.constant = 0
        popupW.constant = 240
        popupH.constant = 150
        
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()
            self.backgroundButton.alpha = 0.5
        })
    }
    
    /// This function is called when the user clicks the information button. The view is then overlayed with an information text box.
    ///
    /// - parameter sender: The info button in the main view.
    ///
    /// - returns: Void
    @IBAction func hidePieChartInfo(_ sender: Any) {
        popupcenterH.constant = 100
        popupcenterV.constant = 150
        popupW.constant = 0
        popupH.constant = 0
        
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()
            self.backgroundButton.alpha = 0
        })
    }
    
    /// Converts seconds to hours.
    ///
    /// - parameter seconds: The number of seconds to convert to hours.
    ///
    /// - returns: A floating point number representing the seconds as hours.
    func secondsToHours(seconds: Int) -> Float {
        return Float(seconds) / 60.0 / 60.0
    }
}
