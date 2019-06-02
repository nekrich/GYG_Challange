import Foundation
import UIKit
import SDWebImage

class ReviewsCommentsTableViewDataSource: NSObject {
  
  private let dataSource: ReviewsCommentsDataSource
  
  var delegate: ReviewsCommentsDataSourceDelegate? {
    get {
      return dataSource.delegate
    }
    set {
      dataSource.delegate = newValue
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

extension ReviewsCommentsTableViewDataSource {
  
  subscript(position: Int) -> ReviewComment {
    get {
      return dataSource[position]
    }
  }
  
  subscript(indexPath: IndexPath) -> ReviewComment {
    get {
      return self[indexPath.row]
    }
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
    guard !(indexPath.row == dataSource.count && !dataSource.isEndReached) else {
      return tableView.dequeueReusableCell(withIdentifier: "Loader")!
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewComment")!
    if let cell = cell as? ReviewCommentTableViewCell {
      cell.configure(with: self[indexPath])
    }
    return cell
  }
}

extension ReviewsCommentsTableViewDataSource: UITableViewDataSourcePrefetching {
  
  func tableView(
    _ tableView: UITableView,
    prefetchRowsAt _indexPaths: [IndexPath]
    )
  {
    let indexPaths: [IndexPath]
    if dataSource.isEndReached {
      indexPaths = _indexPaths
    } else {
      indexPaths = _indexPaths.filter { $0.row != dataSource.count }
    }
    
    SDWebImagePrefetcher.shared.prefetchURLs(
      indexPaths.compactMap { self[$0].reviwer.profilePhotoURL }
    )
  }
}
