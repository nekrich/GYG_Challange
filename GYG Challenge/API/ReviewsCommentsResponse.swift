import Foundation

struct ReviewsCommentsResponse {
  
  let status: Bool
  let totalReviewsCount: Int
  let reviews: [ReviewComment]
}

extension ReviewsCommentsResponse: Decodable {
  
  private enum CodingKey: String, Swift.CodingKey {
    
    case status = "status"
    case totalReviewsCount = "total_reviews_comments"
    case reviews = "data"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKey.self)
    
    status = try container.decode(Bool.self, forKey: .status)
    if status {
      totalReviewsCount = try container.decode(Int.self, forKey: .totalReviewsCount)
      reviews = try container.decode([ReviewComment].self, forKey: .reviews)
    } else {
      totalReviewsCount = 0
      reviews = []
    }
  }
}
