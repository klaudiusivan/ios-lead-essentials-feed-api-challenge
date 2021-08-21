//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .success(let (data, response)):
				if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
					completion(.success(root.items.map({ $0.item })))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct Root: Decodable {
	let items: [Item]
}

private struct Item: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let url: URL

	var item: FeedImage {
		return FeedImage(id: id, description: description, location: location, url: url)
	}
}
