//
//  FlickrViewerViewController.swift
//  ImagEngine
//
//  Created by Melissa Zellhuber on 9/10/18.
//  Copyright © 2018 mzellhuber. All rights reserved.
//

import UIKit
import MBProgressHUD
import TBEmptyDataSet

class FlickrViewerViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    var page: Int = 1
    var foodTags = "pretty food, amazing food, food photography"
    let url = "https://api.flickr.com/services/rest/"
    var flickrPhotos : [Photo] = []
    var flickrImagesUrls : [String] = []
    var isDownloading = false
    let searchController = UISearchController(searchResultsController: nil)
    var scope = "relevance"
    
    var detailPhoto:Photo?
    var detailImage:UIImage?
    
    var parameters = ["per_page":"50", "page":String(1), "nojsoncallback":"1", "format":"json", "tags": "pretty food, amazing food, food photography", "method":"flickr.photos.search", "api_key":"2c52226553a9808f63bfa82b50719b7c", "sort":"relevance"]
    
    fileprivate let reuseIdentifier = "ImageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.prefetchDataSource = self
        setUpNavigationBar()
        setUp3DTouch()
        setUpSearchBar()
        downloadInfo(parameters: parameters)
        
        self.collectionView?.emptyDataSetDataSource = self
        self.collectionView?.emptyDataSetDelegate = self
    }
    
    func setUpNavigationBar() {
        let logo = #imageLiteral(resourceName: "title")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFill
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        
        self.navigationItem.titleView = titleView
    }
    
    func setUpSearchBar() {
        // Setup the Search Controller
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "New Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchBar.scopeButtonTitles = ["Relevance", "Newest"]
        definesPresentationContext = true
        customizeSearchBar()
    }
    
    func customizeSearchBar() {
        //UIColor(red: 100.0, green: 76.1, blue: 69.0, alpha: 1.0)
        for textField in searchController.searchBar.subviews.first!.subviews where textField is UITextField {
            textField.subviews.first?.backgroundColor = .white
            textField.subviews.first?.layer.cornerRadius = 10.5
            textField.subviews.first?.layer.masksToBounds = true
        }
    }
    
    func setUp3DTouch() {
        //MARK: - Check and register for 3D Touch
        if( traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView: view)
        }else{
            //print("3D Touch not available")
        }
    }
    
    func downloadInfo(parameters: [String:String]) {
        
        var hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Loading"
        
        isDownloading = true
        
        Networking().getData(url: url, params: parameters, onSuccess: { data in
            do{
                let photos = try JSONDecoder().decode(FlickrResponse.self, from: data)
                
                self.flickrPhotos = self.flickrPhotos + (photos.photos?.photos)!
                
                for photo in (photos.photos?.photos)!{
                    let photoURL = "https://farm\(photo.farm!).staticflickr.com/\(photo.server!)/\(photo.id!)_\(photo.secret!).jpg"
                    self.flickrImagesUrls.append(photoURL)
                }
                
                DispatchQueue.main.async {
                    self.isDownloading = false
                    self.collectionView.reloadData()
                    hud.hide(animated: true)
                }
                
            }catch {
                //print("Error: \(error)")
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    hud = self.errorHud()
                }
            }
        }) { error in
            
            if (error as NSError).code == 8 {
                hud.show(animated: true)
                hud.label.text = "Please check your internet connection"
                
                hud.hide(animated: true, afterDelay: 2.0)
            }else{
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    hud = self.errorHud()
                }
            }
        }
        
    }
    
    func errorHud() -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "An error happened, please try again"
        hud.hide(animated: true, afterDelay: 3)
        
        return hud
    }
    
    func loadMore() {
        isDownloading = true
        page = page + 1
        parameters["page"] = String(page)
        downloadInfo(parameters: parameters)
    }
    
    func search(tag:String, scope:String) {
        parameters["tags"] = tag
        parameters["sort"] = scope
        if flickrImagesUrls.count != 0 {
            self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                              at: .top,
                                              animated: true)
        }
        
        flickrPhotos = []
        flickrImagesUrls = []
        page = 0
        
        searchController.isActive = false
        
        downloadInfo(parameters: parameters)
    }
    
    @IBAction func getFoodPhotos(_ sender: Any) {
        search(tag: foodTags, scope: scope)
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
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailPhotoVC") as! DetailPhotoViewController
        let photo = flickrPhotos[indexPath.row]
        let imagePhoto = (collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell).imgView.image
        detailVC.photo = photo
        detailVC.img = imagePhoto
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "peekSegue"{
            return false
        }
        return true
    }
    
}

extension FlickrViewerViewController : UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let arrayCount = flickrPhotos.count - 1
        
        for indexPath in indexPaths{
            //print(indexPath)
            if indexPath.contains(arrayCount) && !isDownloading{
                loadMore()
            }
        }
    }
}

extension FlickrViewerViewController : UIViewControllerPreviewingDelegate {
    //Pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        //commit
    }
    
    //Peek
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = collectionView?.indexPathForItem(at:location) else { return nil }
        
        guard let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "PeekViewController") as? PeekViewController else { return nil }
        
        let photo = flickrPhotos[indexPath.row]
        let imagePhoto = (collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell).imgView.image
        detailVC.photo = imagePhoto
        
        detailVC.flickrViewController = self
        detailVC.imgTitle = photo.title
        
        detailVC.preferredContentSize = CGSize(width: (imagePhoto?.size.width)! * (imagePhoto?.scale)!, height: (imagePhoto?.size.height)! * (imagePhoto?.scale)!)
        
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
}

extension FlickrViewerViewController: UISearchBarDelegate{
    // MARK: - UISearchBar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            search(tag: text, scope:scope)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch searchBar.scopeButtonTitles![selectedScope] {
        case "Relevant":
            scope = "relevance"
            break
        case "Newest":
            scope = "date-posted-desc"
            break
        default:
            scope = "relevance"
        }
    }
}

extension FlickrViewerViewController : TBEmptyDataSetDelegate, TBEmptyDataSetDataSource {
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "sad")
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let attributes = [.font : UIFont.systemFont(ofSize: 22),
                          .foregroundColor: UIColor.gray] as [NSAttributedStringKey: Any]?
        
        return NSAttributedString(string: "There are no results for this", attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let attributes = [.font: UIFont.systemFont(ofSize: 17),
                          .foregroundColor: UIColor.gray] as [NSAttributedStringKey: Any]?
        return NSAttributedString(string: "Please try another search", attributes: attributes)
    }
    
    func emptyDataSetShouldDisplay(in scrollView: UIScrollView) -> Bool {
        return flickrPhotos.count == 0
    }
}
