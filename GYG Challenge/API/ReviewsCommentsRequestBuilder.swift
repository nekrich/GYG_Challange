import Foundation

struct ReviewsCommentsRequestBuilder {
  
  let countPerPage: Int
  let options: Options
  
  let cityURLPath: String
  let guideURLPath: String
  
  init(
    countPerPage: Int,
    options: Options,
    cityURLPath: String = "berlin-l17",
    guideURLPath: String = "tempelhof-2-hour-airport-history-tour-berlin-airlift-more-t23776"
    )
  {
    self.countPerPage = countPerPage
    self.options = options
    
    self.cityURLPath = cityURLPath
    self.guideURLPath = guideURLPath
  }
  
  private var queryItems: [URLQueryItem] {
    return [
      URLQueryItem(name: "count", value: "\(countPerPage)")
      ] + options.queryItems
  }
  
  private func urlComponents(for pageIndex: Int) -> URLComponents {
    var urlComponents = URLComponents()
    
    urlComponents.scheme = "https"
    urlComponents.host = "www.getyourguide.com"
    
    urlComponents.path = "/" + [cityURLPath, guideURLPath, "reviews.json"].joined(separator: "/")
    
    urlComponents.queryItems = queryItems + [URLQueryItem(name: "page", value: "\(pageIndex)")]
    
    return urlComponents
  }
  
  private func url(for pageIndex: Int) -> Result<URL, Error> {
    return urlComponents(for: pageIndex)
      .url
      .map(Result.success) ?? .failure(.cantBuildURLFromURLComponents)
  }
  
  func request(for pageIndex: Int) -> Result<URLRequest, Error> {
    return url(for: pageIndex).map { URLRequest(url: $0) }
  }
}

extension ReviewsCommentsRequestBuilder {
  
  enum Error: Swift.Error {
    case cantBuildURLFromURLComponents
  }
}

extension ReviewsCommentsRequestBuilder {
  
  struct Options {
    
    let raiting: RaitingStars?
    let sortBy: SotrField
    let sortDirection: SortDirection
  }
}

extension ReviewsCommentsRequestBuilder.Options {
  
  fileprivate var queryItems: [URLQueryItem] {
    return [raiting?.queryItem, sortBy.queryItem, sortDirection.queryItem].compactMap { $0 }
  }
}

extension ReviewsCommentsRequestBuilder.Options {
  
  enum RaitingStars: Int8 {
    
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
  }
}

extension ReviewsCommentsRequestBuilder.Options.RaitingStars {
  
  fileprivate var queryItem: URLQueryItem {
    return URLQueryItem(name: "rating", value: "\(rawValue)")
  }
}

extension ReviewsCommentsRequestBuilder.Options {
  
  enum SotrField: String {
    
    case date = "date_of_review"
    case rating = "rating"
  }
}

extension ReviewsCommentsRequestBuilder.Options.SotrField {
  
  fileprivate var queryItem: URLQueryItem {
    return URLQueryItem(name: "sortBy", value: rawValue)
  }
}


extension ReviewsCommentsRequestBuilder.Options {
  
  enum SortDirection: String {
    
    case ascending = "ASC"
    case descending = "DESC"
  }
}

extension ReviewsCommentsRequestBuilder.Options.SortDirection {
  
  fileprivate var queryItem: URLQueryItem {
    return URLQueryItem(name: "direction", value: rawValue)
  }
}
