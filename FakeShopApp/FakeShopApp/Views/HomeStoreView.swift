//
//  HomeStoreView.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

import UIKit
import CoreData

class HomeStoreView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let viewModel = ProductsViewModel()
    var products: [Product] = []
    var allProducts: [Product] = []
    var categories: [String] = []
    var selectedCategory: Int = 0
    
    lazy var categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 35)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false

        collectionView.register(CategorieCellView.self, forCellWithReuseIdentifier: "CategoryCell")
        return collectionView
    }()
    
    lazy var productsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 30, bottom: 16, right: 30)
        layout.itemSize = CGSize(width: 150, height: 200)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProductCellView.self, forCellWithReuseIdentifier: "ProductCell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTopBar()
        bindingData()
        configureView()
        viewModel.cargarProductos()
    }
    
    func configTopBar() {
        view.backgroundColor = .systemBackground
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let heartBtn = UIBarButtonItem(image: UIImage(systemName: "heart.fill"),
                                       style: .plain, target: self,
                                       action: #selector(goFavView))
        heartBtn.tintColor = .systemRed
        navigationItem.rightBarButtonItem = heartBtn
    }
    
    @objc private func goFavView() {
        let favViewModel = FavoritesViewModel(repo: FakeStoreProductRepository())
        let vc = FavoritesView(viewModel: favViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func configureView() {
        view.backgroundColor = UIColor(
            red: 242/255.0,
            green: 235/255.0,
            blue: 228/255.0,
            alpha: 1.0
        )
        view.addSubview(categoriesCollectionView)
        view.addSubview(productsCollectionView)
        
        NSLayoutConstraint.activate([
            categoriesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 60),
            
            productsCollectionView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor),
            productsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    //MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === categoriesCollectionView {
            return 1 + categories.count
        } else {
            return products.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === categoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategorieCellView
            if indexPath.item == 0 {
                cell.configureData(with: "All Products")
            } else {
                let index = indexPath.item - 1
                guard index >= 0, index < categories.count else { return cell }
                let categoryName = categories[index]
                cell.configureData(with: categoryName.capitalized)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCellView
            let product = products[indexPath.item]
            cell.configureData(title: product.title, imageURL: product.image)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === categoriesCollectionView {
            if indexPath.item == 0 {
                viewModel.filtrarPorCategoria(nil) //si es 0 es la "primera opcion" que muestra todos
            } else {
                let index = indexPath.item - 1
                guard index >= 0, index < categories.count else { return }
                let cat = categories[index]
                viewModel.filtrarPorCategoria(cat) //filtra las categorias
            }
            productsCollectionView.setContentOffset(.zero, animated: true)
            productsCollectionView.reloadData()
            return
        }
        
    
        if collectionView == productsCollectionView {
            let product = products[indexPath.item]
            
            let detail = DetailProductView(product: product)
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ProductCellView {
                detail.prefetchImage = cell.productImageView.image
            }
            
            navigationController?.pushViewController(detail, animated: true)
        }
    }
}
