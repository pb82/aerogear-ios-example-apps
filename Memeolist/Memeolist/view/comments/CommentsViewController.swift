import AGSSync
import UIKit

class CommentsViewController: UIViewController {
    
    var meme: MemeDetails?
    var tableViewController: CommentsTableViewController?
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var commentTextView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Comments"
        
        avatar.kf.setImage(with: URL(string: appDelegate.profile.pictureurl!), placeholder: UIImage(named: "loading"))
        avatar.layer.cornerRadius = avatar.frame.size.width / 2;
        avatar.clipsToBounds = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        let id = meme?.id
        let owner = appDelegate.profile.id
        
        AgsSync.instance.client?.perform(mutation: PostCommentMutation(memeid: id!, comment: commentTextView.text!, owner: owner)) { result, error in
            if let comment = result?.data?.postComment.fragments.commentDetails {
                self.commentTextView.text = ""
                self.tableViewController?.comments.insert(comment, at: 0)
                self.tableViewController?.tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Error", message: "Failed to post comment", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentsEmbedSegue" {
            tableViewController = segue.destination as? CommentsTableViewController
            tableViewController?.meme = meme
        }
    }

}
