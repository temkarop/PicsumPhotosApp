//
//  MainViewController.swift
//  PicsumPhotosApp
//
//  Created by Артем Ропавка on 14.11.2021.
//

import UIKit
import Nuke

class MainViewController: UIViewController {
    
    var collectionView: UICollectionView!
    
    var networkFetchData = NetworkFetchData()
    private var timer: Timer?
    
    private var photos = [UnsplashPhoto]()
    private var selectedImages = [UIImage]()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    var resizedImageProcessors: [ImageProcessing] {
      let imageSize = CGSize(width: (view.frame.width/2)-2, height: (view.frame.height/2)-2)
      return [ImageProcessors.Resize(size: imageSize, contentMode: .aspectFill)]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupNavigationBar()
        setupSearchBar()
        setupSpinner()
        
        let contentModes = ImageLoadingOptions.ContentModes(
          success: .scaleAspectFill,
          failure: .scaleAspectFit,
          placeholder: .scaleAspectFit)

        ImageLoadingOptions.shared.placeholder = UIImage(named: "image")
        ImageLoadingOptions.shared.failureImage = UIImage(named: "no-image")
        ImageLoadingOptions.shared.transition = .fadeIn(duration: 0.5)
        ImageLoadingOptions.shared.contentModes = contentModes

        DataLoader.sharedUrlCache.diskCapacity = 0

    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.addSubview(collectionView)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.cellId)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Picsum Photos"
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func setupSpinner() {
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        let transition = CATransition()
        
        detailVC.detailImage = photos[indexPath.row]
        detailVC.resizedImageProcessors = resizedImageProcessors
        
        transition.duration = 0.3
        transition.type = .fade
        self.view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellId, for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        let photo = photos[indexPath.item]
        cell.photo = photo
    
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width/2)-2, height: (view.frame.height/2)-2)
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        self.spinner.startAnimating()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.networkFetchData.searchImages(searchTerm: searchText) { [weak self] (searchResults) in
                guard let fetchedPhotos = searchResults else { return }
                self?.spinner.stopAnimating()
                self?.photos = fetchedPhotos.results
                self?.collectionView.reloadData()
            }
        })
    }
}

