import AGSAuth
import AGSSync
import UIKit

public class LoginViewController: UIViewController {

    @IBOutlet var loginButton: UIButton!

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.layer.cornerRadius = 10.0
        loginButton.alpha = 0.6
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction public func onLoginPressed(_ sender: Any) {
        try! AgsAuth.instance.login(presentingViewController: self, onCompleted: onLoginComplete)
    }
    
    public func onLoginComplete(user: User?, err: Error?) {
        if let error = err {
            print(error)
            return
        }
        
        createOrRetrieveProfile(user: user!)
    }
    
    public func createOrRetrieveProfile(user: User) {
        AgsSync.instance.client?.fetch(query: ProfileQuery(email: user.email!), cachePolicy: .fetchIgnoringCacheData) { result, error in
            if let error = error {
                NSLog("Error while fetching query: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: "Failed to fetch profile", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.navigationController?.present(alert, animated: true)
                return
            }
            
            let profiles = result?.data?.profile
            if(profiles != nil && (profiles?.count)! > 0) {
                let profile = profiles![0]?.fragments.profileDetails
                self.navigateToMemeList(profile: profile!)
            } else {
                self.createProfile(user: user)
            }
        }
    }
    
    public func createProfile(user: User) {
        AgsSync.instance.client?.perform(mutation: CreateProfileMutation(email: user.email!, displayname: user.fullName!, pictureurl: "https://randomuser.me/api/portraits/lego/1.jpg")) { result, error in
            if let profile = result?.data?.createProfile.fragments.profileDetails {
                self.navigateToMemeList(profile: profile)
            } else {
                let alert = UIAlertController(title: "Error", message: "Failed to create profile", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            return
        }
    }
    
    public func navigateToMemeList(profile: ProfileDetails) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.profile = profile
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "memeListViewController")
        self.navigationController!.present(UINavigationController(rootViewController: vc), animated: true)
    }

}
