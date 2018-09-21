import UIKit

class CommentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var owner: UILabel!
    
    func configure(with commentDetails: CommentDetails) {
        
        avatar.kf.setImage(with: URL(string: commentDetails.owner.pictureurl!), placeholder: UIImage(named: "loading"))
        avatar.layer.cornerRadius = avatar.frame.size.width / 2;
        avatar.clipsToBounds = true;
        comment.text = commentDetails.comment
        owner.text = commentDetails.owner.displayname
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
}
