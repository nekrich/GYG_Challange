import Foundation

extension ReviewsCommentsResponse {
  
  private static func decodingDateFormatter() -> DateFormatter {
    let dateFromatter = DateFormatter()
    dateFromatter.dateFormat = "MMMM dd, yyyy"
    return dateFromatter
  }
  
  private static func jsonDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(decodingDateFormatter())
    return decoder
  }
  
  static func decodeResponse(from data: Data) -> Result<ReviewsCommentsResponse, Error> {
    do {
      return .success(try jsonDecoder().decode(ReviewsCommentsResponse.self, from: data))
    } catch {
      return .failure(error)
    }
  }
}
