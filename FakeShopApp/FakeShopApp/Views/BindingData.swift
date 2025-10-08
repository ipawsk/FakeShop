//
//  BindingData.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

import UIKit

extension HomeStoreView {
    
    func bindingData() {
        viewModel.refreshData = { [weak self] in
            guard let self else { return }
            
            let vmProducts = self.viewModel.products
            DispatchQueue.main.async {
                self.products = vmProducts
                self.productsCollectionView.reloadData()
                
                if self.categories != self.viewModel.categories {
                    self.categories = self.viewModel.categories
                    self.categoriesCollectionView.reloadData()
                    
                    if self.selectedCategory == nil, self.categoriesCollectionView.numberOfItems(inSection: 0) > 0 {
                        let first = IndexPath(item: 0, section: 0)
                        self.categoriesCollectionView.selectItem(at: first, animated: false, scrollPosition: [])
                    }
                }
            }
        }
    }
}

extension FavoritesView {
    func favsBindingData() {
        viewModel.refreshData = { [weak self] in
            guard let self else { return }
            self.products = self.viewModel.allProducts
            self.productsCollectionView.reloadData()
        }
    }
}
