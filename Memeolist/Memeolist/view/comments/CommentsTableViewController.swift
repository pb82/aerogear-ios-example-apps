import AGSSync
import UIKit

class CommentsTableViewController: UITableViewController {
    
    var meme: MemeDetails?
    var comments: [CommentDetails?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AgsSync.instance.client?.fetch(query: CommentsQuery(memeid: (meme?.id)!), cachePolicy: .fetchIgnoringCacheData) { result, error in
            if let error = error {
                NSLog("Error while fetching query: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: "Failed to fetch comments", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.navigationController?.present(alert, animated: true)
                return
            }
            
            if let allComments = result?.data?.comments {
                for comment in allComments {
                    self.comments.append((comment?.fragments.commentDetails)!);
                }
            }
            
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTableViewCell", for: indexPath) as? CommentsTableViewCell else {
            fatalError("Could not dequeue CommentsTableViewCell")
        }
        
        guard let comment = comments[indexPath.row] else {
            fatalError("Could not find comment at row \(indexPath.row)")
        }
        
        cell.configure(with: comment)
        
        return cell
    }

}
