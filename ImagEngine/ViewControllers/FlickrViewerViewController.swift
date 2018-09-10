//
//  FlickrViewerViewController.swift
//  ImagEngine
//
//  Created by Melissa Zellhuber on 9/10/18.
//  Copyright © 2018 mzellhuber. All rights reserved.
//

import UIKit

class FlickrViewerViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    var page: Int = 1
    var foodTags = "pretty food, amazing food, food photography"
    let url = "https://api.flickr.com/services/rest/"
    var flickrPhotos : [Photo] = []
    var flickrImagesUrls : [String] = []
    
    var scope = "relevance"
    
    var parameters = ["per_page":"50", "page":String(1), "nojsoncallback":"1", "format":"json", "tags": "pretty food, amazing food, food photography", "method":"flickr.photos.search", "api_key":"2c52226553a9808f63bfa82b50719b7c", "sort":"relevance"]
    
    fileprivate let reuseIdentifier = "ImageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadInfo(parameters: parameters)
    }
    
    func downloadInfo(parameters: [String:String]) {
        
        Networking().getData(url: url, params: parameters, onSuccess: { data in
            do{
                let photos = try JSONDecoder().decode(FlickrResponse.self, from: data)
                
                self.flickrPhotos = self.flickrPhotos + (photos.photos?.photos)!
                
                for photo in (photos.photos?.photos)!{
                    let photoURL = "https://farm\(photo.farm!).staticflickr.com/\(photo.server!)/\(photo.id!)_\(photo.secret!).jpg"
                    self.flickrImagesUrls.append(photoURL)
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            }catch {
                print("Error: \(error)")
            }
        }) { error in
            print("error")
        }
    }

}

// MARK: - UICollectionViewDataSource
extension FlickrViewerViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! ImageCollectionViewCell
        
        if flickrImagesUrls.count != 0 {
            cell.imgView.downloadImageWith(string: flickrImagesUrls[indexPath.row])
        }
        
        cell.imgView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        cell.imgView.contentMode = .scaleAspectFill
        cell.imgView.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (view.frame.width / 1.96)-10.0
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Go to detail
    }
    
}