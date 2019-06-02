import Foundation
import UIKit
import Cosmos
import SDWebImage

class ReviewCommentTableViewCell: UITableViewCell {
  
  private static let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    return dateFormatter
  }()
  
  @IBOutlet private weak var avatarImageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var raitingStarsView: CosmosView!
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var authorLabel: UILabel!
  @IBOutlet private weak var dateLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    configureImageView()
  }
  
  private func configureImageView() {
    avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2.0
    avatarImageView.layer.borderWidth = 1.0
    avatarImageView.layer.borderColor = UIColor.darkGray.cgColor
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    clean()
  }
  
  private func clean() {
    avatarImageView.image = .none
    
    titleLabel.attributedText = .none
    titleLabel.isHidden = false
    
    raitingStarsView.rating = 0.0
    
    messageLabel.attributedText = .none
    messageLabel.isHidden = false
    
    authorLabel.text = .none
    dateLabel.text = .none
  }
  
  func configure(with reviewComment: ReviewComment) {
    
    if let title = reviewComment.title {
      titleLabel.attributedText = attributedString(
        fromHTMLEncoded: title,
        font: titleLabel.font
      )
      titleLabel.isHidden = false
    } else {
      titleLabel.isHidden = true
    }
    
    raitingStarsView.rating = Double(reviewComment.rating)
    
    if let message = reviewComment.message {
      messageLabel.attributedText = attributedString(
        fromHTMLEncoded: message,
        font: messageLabel.font
      )
      messageLabel.isHidden = false
    } else {
      messageLabel.isHidden = true
    }
    
    dateLabel.text = ReviewCommentTableViewCell.dateFormatter.string(from: reviewComment.date)
    
    configureReviewer(reviewComment.reviwer)
  }
  
  private func attributedString(
    fromHTMLEncoded string: String,
    font: UIFont
    )
    -> NSAttributedString
  {
    guard let data = string.data(using: .utf8) else {
      return NSAttributedString(string: string)
    }
    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
      .documentType: NSAttributedString.DocumentType.html.rawValue,
      .characterEncoding: String.Encoding.utf8.rawValue
    ]
    
    do {
      let attributedString = try NSMutableAttributedString(
        data: data,
        options: options,
        documentAttributes: nil
      )
      attributedString.addAttributes(
        [.font: font],
        range: NSRange(location: 0, length: attributedString.length)
      )
      return attributedString
    } catch {
      return NSAttributedString(string: string)
    }
  }
  
  private func configureReviewer(_ reviwer: Reviewer) {
    if reviwer.isAnonymous {
      authorLabel.text = "Anonymous"
      avatarImageView.image = UIImage(named: "anonymous_user_avatar")
    } else {
      authorLabel.text = reviwer.name
      avatarImageView.sd_setImage(
        with: reviwer.profilePhotoURL,
        placeholderImage: UIImage(named: "anonymous_user_avatar")
      )
    }
  }
}
