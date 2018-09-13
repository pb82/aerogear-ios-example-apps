import AGSAuth
import AGSSync
import UIKit

class MemesListViewController: UITableViewController {

    var memes: [MemeDetails?] = []
    let refreshControler = UIRefreshControl()
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControler.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControler.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControler) // not required when using UITableViewController
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64
        
        loadData()
    }

    // MARK: - Data loading

    @objc func loadData() {
       refreshControler.endRefreshing()
        AgsSync.instance.client?.fetch(query: AllMemesQuery(), cachePolicy: .fetchIgnoringCacheData) { result, error in
            if let error = error {
                NSLog("Error while fetching query: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: "Failed to fetch meme updates", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.navigationController?.present(alert, animated: true)
                return
            }
            if let allMemes = result?.data?.allMemes {
                self.memes = [];
                for meme in allMemes {
                    self.memes.append(meme.fragments.memeDetails);
                }
            }
            self.tableView.reloadData()
        }
        
        AgsSync.instance.client?.subscribe(subscription: MemeAddedSubscription(), resultHandler:  { result, error in
            if let error = error {
                NSLog("Error while fetching query: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: "Failed to subscribe to meme updates", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.navigationController?.present(alert, animated: true)
                return
            }
            
            if let memeDetails = result?.data?.memeAdded.fragments.memeDetails {
                self.memes.insert(MemeDetails(id: memeDetails.id, photourl: memeDetails.photourl, likes: memeDetails.likes, owner: memeDetails.owner, comments: []), at: 0)
            }
            self.tableView.reloadData()
        })


    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? MemesTableViewCell else {
            fatalError("Could not dequeue PostTableViewCell")
        }

        guard let meme = memes[indexPath.row] else {
            fatalError("Could not find post at row \(indexPath.row)")
        }

        cell.configure(with: meme)

        return cell
    }

    @IBAction func onLogout(_ sender: Any) {
        try? AgsAuth.instance.logout(onCompleted: { _ in
            self.navigationController!.present(UINavigationController(rootViewController: LoginViewController()), animated: true)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CommentsSegue") {
            if let button = sender as? UIButton, let cell = button.superview?.superview as? MemesTableViewCell {
                let destination = segue.destination as? CommentsViewController
                destination?.meme = memes.first(where: { ($0?.id)! == cell.memeId! }) as? MemeDetails
            }
        }
    }
    
}
