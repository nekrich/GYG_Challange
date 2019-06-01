import Foundation

protocol ReviewsCommentsDataSourceDelegate: AnyObject {
  
  func reviewsCommentsDataSourceDidUpdateReviewsList(
    _ dataSource: ReviewsCommentsDataSource,
    count: Int,
    isEndReached: Bool
  )
}

class ReviewsCommentsDataSource {
  
  weak var delegate: ReviewsCommentsDataSourceDelegate?
  
  private let operationQueue: OperationQueue = {
    let operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 1
    operationQueue.qualityOfService = .utility
    operationQueue.underlyingQueue = DispatchQueue.global(qos: .utility)
    return operationQueue
  }()
  
  private var requestBuilder: ReviewsCommentsRequestBuilder {
    didSet {
      reset()
    }
  }
  
  var options: ReviewsCommentsRequestBuilder.Options {
    didSet {
      requestBuilder = ReviewsCommentsRequestBuilder(
        countPerPage: requestBuilder.countPerPage,
        options: requestBuilder.options,
        cityURLPath: requestBuilder.cityURLPath,
        guideURLPath: requestBuilder.guideURLPath
      )
    }
  }
  
  private var reviewComments: [Int: [ReviewComment]] = [:] {
    didSet {
      updateCount()
    }
  }
  
  internal private(set) var count: Int = 0
  
  private var totalReviewsCount: Int?
  
  private var isInitialized: Bool = false
  
  init(requestBuilder: ReviewsCommentsRequestBuilder) {
    self.requestBuilder = requestBuilder
    self.options = requestBuilder.options
    
    loadNextPageIfNeeded()
  }
  
  private var isRequestInProgress: Bool = false
  
  internal private(set) var isEndReached: Bool = false {
    didSet {
      delegateUpdates()
    }
  }
  
  func loadNextPageIfNeeded() {
    operationQueue.addOperation { [weak self] in
      self?._loadNextPageIfNeeded()
    }
  }
  
  private func _loadNextPageIfNeeded() {
    
    guard !(isRequestInProgress || isEndReached) else {
      return
    }
    
    let pageIndex = reviewComments.count
    
    let result = requestBuilder
      .request(for: pageIndex)
      .map {
        DataTaskOperation(
          request: $0,
          session: .shared,
          transform: ReviewsCommentsResponse.decodeResponse,
          completion: { [weak self] (result) in
            self?.update(with: result.value, pageIndex: pageIndex)
        })
      }
      .map(operationQueue.addOperation)
    
    isRequestInProgress = result.isSuccess
  }
  
  private func reset() {
    operationQueue.addOperation { [weak self] in
      self?._reset()
    }
  }
  
  private func _reset() {
    operationQueue.cancelAllOperations()
    isRequestInProgress = false
    
    totalReviewsCount = 0
    reviewComments = [:]
    isEndReached = false
  }
  
  private func update(
    with response: ReviewsCommentsResponse?,
    pageIndex: Int
    )
  {
    operationQueue.addOperation { [weak self] in
      self?._update(with: response, pageIndex: pageIndex)
    }
  }
  
  private func _update(
    with response: ReviewsCommentsResponse?,
    pageIndex: Int
    )
  {
    defer { isRequestInProgress = false }
    
    guard let response = response else {
      return
    }
    
    if totalReviewsCount == .none {
      totalReviewsCount = response.totalReviewsCount
    }
    
    reviewComments[pageIndex] = response.reviews
    
    // Looks like we'll never get promised in `totalReviewsCount` comments count.
    // An error `Could not find data for thre request tour` occurs after #723. 🤷‍♂️
    isEndReached = response.reviews.count < requestBuilder.countPerPage
      || count >= (totalReviewsCount ?? 0)
    
    if isEndReached {
      totalReviewsCount = count
    }
  }
  
  private func updateCount() {
    count = reviewComments.reduce(into: 0) { $0 += $1.value.count }
    delegateUpdates()
  }
  
  private func delegateUpdates() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        return
      }
      self.delegate?.reviewsCommentsDataSourceDidUpdateReviewsList(
        self,
        count: self.count,
        isEndReached: self.isEndReached
      )
    }
  }
}

extension ReviewsCommentsDataSource {
  
  subscript(position: Int) -> ReviewComment {
    get {
      let countPerPage = requestBuilder.countPerPage
      return reviewComments[position / countPerPage, default: []][position % countPerPage]
    }
  }
}
