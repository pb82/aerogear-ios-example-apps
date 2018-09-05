import AGSAuth
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
    
    public func onLoginComplete(user: User?, err: Error?) {
        if let error = err {
            print(error)
            return
        }
        let currentUser = user
        print(currentUser ?? "")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "memeListViewController")
        self.navigationController!.present(UINavigationController(rootViewController: vc), animated: true)
    }

    @IBAction public func onLoginPressed(_ sender: Any) {
        try! AgsAuth.instance.login(presentingViewController: self, onCompleted: onLoginComplete)
    }
}
