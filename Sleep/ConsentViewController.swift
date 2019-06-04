
import UIKit

class ConsentViewController: UIViewController {

    @IBOutlet weak var age: UISwitch!
    @IBOutlet weak var willingToParticipate: UISwitch!
    @IBOutlet weak var consent: UIButton!
    
    /// This function is called before the ConsentView appears to the user. It is used to set up the switches in the view in accordance with what the user has previously consented to.
    ///
    /// - returns: Void
    override func viewWillAppear(_ animated: Bool) {
        let ageIsOver18 = UserDefaults.standard.bool(forKey: "AgeIs18OrOlder")
        let IsWillingToParticipate = UserDefaults.standard.bool(forKey: "IsWillingToParticipate")
        
        age.isOn = ageIsOver18
        willingToParticipate.isOn = IsWillingToParticipate
        toggleConsentButton()
    }
    
    /// This function is called when the user clicks the "I Consent" button. It sets the locally stored "AgeIs18OrOlder" and "IsWillingToParticipate" variables to true, indicating that the user has given consent to participate in the exploration.
    ///
    /// - parameter sender: The Accept Agreement button in the consent view.
    ///
    /// - returns: Void
    @IBAction func acceptConsent(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "AgeIs18OrOlder")
        UserDefaults.standard.set(true, forKey: "IsWillingToParticipate")
    }
    
    /// This function is called when the user changes the state of the age switch. If the user is not 18 years old, it sets the locally stored "AgeIs18OrOlder" variable to false.
    ///
    /// - parameter sender: The switch associated with the age acceptence text.
    ///
    /// - returns: Void
    @IBAction func ageChanged(_ sender: Any) {
        if (!age.isOn) {
            UserDefaults.standard.set(false, forKey: "AgeIs18OrOlder")
        }
        toggleConsentButton()
    }
    
    /// This function is called when the user changes the state of the switch that indicates if the user is willing to participate in the exploration. If the user is not willing to participate, it sets the locally stored "IsWillingToParticipate" variable to false.
    ///
    /// - parameter sender: The switch associated with the user's willingness to participate in the study.
    ///
    /// - returns: Void
    @IBAction func willingToParticipateChanged(_ sender: Any) {
        if (!willingToParticipate.isOn) {
            UserDefaults.standard.set(false, forKey: "IsWillingToParticipate")
        }
        toggleConsentButton()
    }
    
    /// Enables the consent button if the user is 18 years or older and is willing to participate, otherwise disables it.
    ///
    /// - returns: Void
    private func toggleConsentButton() {
        if (age.isOn && willingToParticipate.isOn) {
            consent.isEnabled = true
        } else {
            consent.isEnabled = false
        }
    }
}
