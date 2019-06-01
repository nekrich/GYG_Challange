import Foundation

enum TravelerType: RawRepresentable, Decodable {
  
  private enum PrivateType: String, Decodable {
    
    case couple = "couple"
    case solo = "solo"
    case friends = "friends"
    case youngFamily = "family_young"
  }
  
  case couple
  case solo
  case friends
  case youngFamily
  case unknown(String)
  
  private init(privateType: PrivateType) {
    switch privateType {
    case .couple:
      self = .couple
    case .solo:
      self = .solo
    case .friends:
      self = .friends
    case .youngFamily:
      self = .youngFamily
    }
  }
  
  init(from decoder: Decoder) throws {
    do {
      try self.init(privateType: PrivateType(from: decoder))
    } catch {
      do {
        let container = try decoder.singleValueContainer()
        self = try .unknown(container.decode(String.self))
      } catch {
        throw error
      }
    }
  }
  
  init?(rawValue: String) {
    if let privateType = PrivateType(rawValue: rawValue) {
      self.init(privateType: privateType)
    } else {
      self = .unknown(rawValue)
    }
  }
  
  var rawValue: String {
    switch self {
    case .couple:
      return PrivateType.couple.rawValue
    case .solo:
      return PrivateType.solo.rawValue
    case .friends:
      return PrivateType.friends.rawValue
    case .youngFamily:
      return PrivateType.youngFamily.rawValue
    case let .unknown(travelerType):
      return travelerType
    }
  }
}
