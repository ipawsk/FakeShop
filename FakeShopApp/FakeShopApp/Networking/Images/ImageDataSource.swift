//
//  ImageDataSource.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

import UIKit

class ImageDownloader {
    static func setImage(into imageView: UIImageView, from url: URL, useCache: Bool = true) {
        var req = URLRequest(url: url)
        req.cachePolicy = useCache ? .returnCacheDataElseLoad : .reloadIgnoringLocalCacheData

        if useCache, let cached = URLCache.shared.cachedResponse(for: req),
            let img = UIImage(data: cached.data) {
            DispatchQueue.main.async {
                imageView.image = img
            }
        }

        URLSession.shared.dataTask(with: req) { [weak imageView] data, response, _ in
            guard let data = data, let img = UIImage(data: data) else { return }

            if useCache, let response = response {
                let cached = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cached, for: req)
            }

            DispatchQueue.main.async {
                imageView?.image = img
            }
        }.resume()
    }
}
