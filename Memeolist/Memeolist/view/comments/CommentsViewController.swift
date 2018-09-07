import AGSSync
import UIKit

class CommentsViewController: UIViewController {
    
    var meme: MemeDetails?
    var tableViewController: CommentsTableViewController?

    @IBOutlet weak var commentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Comments"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        guard let id = meme?.id, let owner = meme?.owner[0].id else { return }
        
        AgsSync.instance.client?.perform(mutation: PostCommentMutation(memeid: id, comment: commentTextView.text, owner: owner)) { result, error in
            if let comment = result?.data?.postComment {
                self.commentTextView.text = ""
                self.meme?.comments.insert(MemeDetails.Comment(id: comment.id, comment: comment.comment, owner: comment.owner), at: 0)
                self.tableViewController?.meme = self.meme
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
