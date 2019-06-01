import Foundation

class DataTaskOperation<Model>: AsynchronousOperation {
  
  enum Error: Swift.Error {
    
    case uninitalized
    case task(Swift.Error)
    case emptyDataReposnse
    case decoding(Swift.Error)
  }
  
  private var task: URLSessionTask!
  
  internal private(set) var result: Result<Model, Error> = .failure(.uninitalized)
  
  init(
    request: URLRequest,
    session: URLSession,
    transform: @escaping (Data) -> Result<Model, Swift.Error>,
    completion: @escaping (Result<Model, DataTaskOperation.Error>) -> Void
    )
  {
    super.init()
    
    let completionHandler: (Result<Model, Error>) -> Void = { [weak self] in
      self?.result = $0
      completion($0)
      self?.finish()
    }
    
    self.task = session.dataTask(with: request) { (data, response, error) in
      
      guard error == nil else {
        return completionHandler(.failure(.task(error!)))
      }
      
      guard
        let data = data,
        !data.isEmpty
        else {
          return completionHandler(.failure(.emptyDataReposnse))
      }
      
      completionHandler(transform(data).mapError(Error.decoding))
    }
  }
  
  override func startAsyncronousOperation() {
    task.resume()
  }
  
  override func cancel() {
    if task.state != .completed && task.state != .canceling {
      task.cancel()
    }
    super.cancel()
  }
}
