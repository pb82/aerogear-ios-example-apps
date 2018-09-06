import Apollo
import Kingfisher
import UIKit
import AGSSync

class MemesTableViewCell: UITableViewCell {

    var memeId: String?
    var memeNumberOfLikes: Int = 0

    @IBOutlet var likesLabel: UILabel!
    @IBOutlet var memeImageView: UIImageView!
    @IBOutlet var userLabel:UILabel!
    @IBOutlet var avatarImageView:UIImageView!

    func configure(with meme: MemeDetails) {
        memeId = meme.id
        
        avatarImageView.kf.setImage(with: URL(string: meme.owner[0].pictureurl!), placeholder: UIImage(named: "loading"))
        avatarImageView.layer.cornerRadius = 25;
        avatarImageView.layer.masksToBounds = true;
        userLabel?.text = meme.owner[0].displayname
        
        memeNumberOfLikes = meme.likes
        
        memeImageView.kf.setImage(with: URL(string: meme.photourl), placeholder: UIImage(named: "loading"))
        
        likesLabel?.text = "\(memeNumberOfLikes) likes"
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }

    @IBAction func upvote(_ sender: UIButton) {
        guard let memeId = memeId else { return }
        AgsSync.instance.client?.perform(mutation: LikeMemeMutation(memeId: memeId)) { result, error in
            if let err = result?.errors {
                print("Error:", err)
            } else {
                self.memeNumberOfLikes += 1
                self.likesLabel?.text = "\(self.memeNumberOfLikes) likes"
                sender.setBackgroundImage(UIImage(named: "favorite"), for: UIControlState.normal)
            }
            return
        }
    }
}
