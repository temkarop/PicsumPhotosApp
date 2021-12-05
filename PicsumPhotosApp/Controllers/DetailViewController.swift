//
//  DetailViewController.swift
//  PicsumPhotosApp
//
//  Created by Артем Ропавка on 22.11.2021.
//

import UIKit
import Nuke
import Combine

class DetailViewController: UIViewController, UIScrollViewDelegate {
    
    var cancellable: AnyCancellable?
    var resizedImageProcessors: [ImageProcessing] = []
    var detailImage: UnsplashPhoto?
    
    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .gray
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 6
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let clouseButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "close")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()

        guard let imageString = detailImage?.urls["regular"] else { return }
        guard let imageURL = URL(string: imageString) else { return }
        
        loadImage(url: imageURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setupView() {
        view.backgroundColor = .gray
        imageScrollView.delegate = self
        view.addSubview(imageScrollView)
        imageScrollView.addSubview(imageView)
        view.addSubview(clouseButton)
    }
    
    private func setupConstraint() {
        imageScrollView.frame = view.bounds
        imageView.frame = imageScrollView.bounds
        
        clouseButton.frame = CGRect(x: 20, y: (self.navigationController?.navigationBar.frame.size.height)!, width: 25, height: 25)
    }
    
    private func setupGesture() {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector( handleSingleTapOnScrollView(recoginazer:)))
        singleTapGesture.numberOfTapsRequired = 1
        imageScrollView.addGestureRecognizer(singleTapGesture)
        
        let DoubleTapGesture = UITapGestureRecognizer(target: self, action: #selector( handleDoubleTapOnScrollView(recoginazer:)))
        DoubleTapGesture.numberOfTapsRequired = 2
        imageScrollView.addGestureRecognizer(DoubleTapGesture)
        
        singleTapGesture.require(toFail: DoubleTapGesture)
    }
    
    @objc func handleSingleTapOnScrollView(recoginazer: UITapGestureRecognizer){
        if clouseButton.isHidden {
            clouseButton.isHidden = false
        }else {
            clouseButton.isHidden = true
        }
    }
    @objc func handleDoubleTapOnScrollView(recoginazer: UITapGestureRecognizer){
        if imageScrollView.zoomScale == 1 {
            imageScrollView.zoom(to: zoomRectForScale(scele: imageScrollView.maximumZoomScale, center: recoginazer.location(in: recoginazer.view)), animated: true)
            clouseButton.isHidden = true
        }else {
            imageScrollView.setZoomScale(1, animated: true)
        }
    }
    
    private func zoomRectForScale(scele: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.width = imageView.frame.size.width / scele
        zoomRect.size.height = imageView.frame.size.height / scele
        
        let newCenter = imageView.convert(center,from: imageScrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if imageScrollView.zoomScale > 1 {
            if let image = imageView.image {
                let ratioWidth = imageView.frame.width / image.size.width
                let ratioHeight = imageView.frame.height / image.size.height
                
                let ratio = ratioWidth < ratioHeight ? ratioWidth : ratioHeight
                let newWidth = image.size.width * ratio
                let newHeigth = image.size.height * ratio
                
                let left = 0.5 * (newWidth * imageScrollView.zoomScale > imageView.frame.width ? (newWidth - imageView.frame.width) : (imageScrollView.frame.width - imageScrollView.contentSize.width))
                let top = 0.5 * (newHeigth * imageScrollView.zoomScale > imageView.frame.height ? (newHeigth - imageView.frame.height) : (imageScrollView.frame.height - imageScrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
                
            }
        }else {
            scrollView.contentInset = UIEdgeInsets.zero
        }
    }
    
    @objc func closeButtonTapped() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .reveal
        transition.type = .fade
        self.view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.popViewController(animated: true)
        navigationController?.navigationBar.isHidden = false
    }
    
    func loadImage(url: URL) {
        let resizedImageRequest = ImageRequest(
            url: url,
            processors: resizedImageProcessors)
        
          let resizedImagePublisher = ImagePipeline.shared
            .imagePublisher(with: resizedImageRequest)
          cancellable = resizedImagePublisher
        
            .sink(
              receiveCompletion: { [weak self] response in
                guard let self = self else { return }
                switch response {
                case .failure:
                  self.imageView.image = ImageLoadingOptions.shared.failureImage
                case .finished:
                  break
                }
              },
              receiveValue: {
                self.imageView.image = $0.image
              }
          )
    }
}
