import UIKit

class ViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!
  
  private var dataSource: ReviewsCommentsTableViewDataSource!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataSource = ReviewsCommentsTableViewDataSource(
      requestBuilder: .init(
        countPerPage: 15,
        options: .init(raiting: .none, sortBy: .date, sortDirection: .descending)
      )
    )
    dataSource.delegate = self
    
    configureTableView()
  }
  
  private func configureTableView() {
    tableView.delegate = self
    
    tableView.dataSource = dataSource
    tableView.prefetchDataSource = dataSource
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 92.0
    
    tableView.tableFooterView = UIView()
    tableView.separatorInset = .zero
  }
}

extension ViewController: UITableViewDelegate {
  
  func tableView(
    _ tableView: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath
    )
  {
    let numberOfRows = dataSource.tableView(tableView, numberOfRowsInSection: 0)
    if Double(numberOfRows) * 0.75 < Double(indexPath.row + 1) {
      dataSource.loadNextPageIfNeeded()
    }
  }
}

extension ViewController: ReviewsCommentsDataSourceDelegate {
  
  func reviewsCommentsDataSource(
    _ dataSource: ReviewsCommentsDataSource,
    didLoad countOfNewLines: Int,
    isEndReached: Bool
    )
  {
    guard countOfNewLines > 0 else {
      return tableView.reloadData()
    }
    
    let totalObjectCount = dataSource.count
    let previousObjectCount = totalObjectCount - countOfNewLines
    var indexPaths: [IndexPath] = []
    for index in 0..<countOfNewLines {
      indexPaths.append(IndexPath(item: previousObjectCount + index, section: 0))
    }
    
    tableView.beginUpdates()
    let lastIndexPath: IndexPath?
    if isEndReached {
      lastIndexPath = indexPaths.removeLast()
    } else {
      lastIndexPath = .none
    }
    tableView.insertRows(at: indexPaths, with: .automatic)
    tableView.endUpdates()
    if let lastIndexPath = lastIndexPath {
      tableView.reloadRows(at: [lastIndexPath], with: .automatic)
    }
  }
  
  func reviewsCommentsDataSourceDidUpdateReviewsList(
    _ dataSource: ReviewsCommentsDataSource,
    count: Int,
    isEndReached: Bool
    )
  {
    tableView.reloadData()
  }
}
