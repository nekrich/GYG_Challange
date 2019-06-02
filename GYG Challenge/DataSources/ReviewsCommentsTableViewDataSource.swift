import Foundation
import UIKit

class ReviewsCommentsTableViewDataSource: NSObject {
  
  private let dataSource: ReviewsCommentsDataSource
  
  var delegate: ReviewsCommentsDataSourceDelegate? {
    get {
      return dataSource.delegate
    }
    set {
      dataSource.delegate = delegate
    }
  }
  
  var options: ReviewsCommentsRequestBuilder.Options {
    get {
      return dataSource.options
    }
    set {
      dataSource.options = newValue
    }
  }
  
  init(requestBuilder: ReviewsCommentsRequestBuilder) {
    dataSource = .init(requestBuilder: requestBuilder)
  }
  
  func loadNextPageIfNeeded() {
    dataSource.loadNextPageIfNeeded()
  }
}

extension ReviewsCommentsTableViewDataSource: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
    )
    -> Int
  {
    return dataSource.count + (dataSource.isEndReached ? 0 : 1)
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
    )
    -> UITableViewCell
  {
    return UITableViewCell()
  }
}
