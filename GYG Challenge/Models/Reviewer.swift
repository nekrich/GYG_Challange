import Foundation

struct Reviewer {
  
  let travelerType: TravelerType?
  let name: String?
  let country: String?
  let profilePhotoURL: URL?
  let isAnonymous: Bool
}

extension Reviewer: Decodable {
  
  private enum CodingKey: String, Swift.CodingKey {
    
    case travelerType = "traveler_type"
    case name = "reviewerName"
    case country = "reviewerCountry"
    case profilePhoto = "reviewerProfilePhoto"
    case isAnonymous = "isAnonymous"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKey.self)
    
    isAnonymous = try container.decode(Bool.self, forKey: .isAnonymous)
    
    if !isAnonymous {
      travelerType = try container.decodeIfPresent(TravelerType.self, forKey: .travelerType)
      name = try container.decode(String.self, forKey: .name)
      country = try container.decode(String.self, forKey: .country)
      profilePhotoURL = (try container.decodeIfPresent(String.self, forKey: .profilePhoto))
        .flatMap(URL.init(string:))
    } else {
      travelerType = .none
      name = .none
      country = .none
      profilePhotoURL = .none
    }
  }
}
