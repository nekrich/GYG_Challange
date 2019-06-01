import Foundation

extension Result {
  
  var isSuccess: Bool {
    switch self {
    case .success:
      return true
    case .failure:
      return false
    }
  }
  
  var value: Success? {
    switch self {
    case let .success(value):
      return value
    case .failure:
      return .none
    }
  }
}
