import Foundation

struct ReviewComment {
  
  let id: UInt64
  let rating: String
  let date: Date
  
  let reviwer: Reviewer
  
  let title: String?
  let message: String
  let languageCode: String
}

extension ReviewComment: Decodable {
  
  private enum CodingKey: String, Swift.CodingKey {
    
    case id = "review_id"
    case rating = "rating"
    case date = "date"
    
    case title = "title"
    case message = "message"
    case languageCode = "languageCode"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKey.self)
    
    id = try container.decode(UInt64.self, forKey: .id)
    rating = try container.decode(String.self, forKey: .rating)
    date = try container.decode(Date.self, forKey: .date)
    
    reviwer = try Reviewer(from: decoder)
    
    title = try container.decodeIfPresent(String.self, forKey: .title)
    message = try container.decode(String.self, forKey: .message)
    languageCode = try container.decode(String.self, forKey: .languageCode)
  }
}
