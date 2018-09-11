//
//  DetailPhotoViewController.swift
//  ImagEngine
//
//  Created by Melissa Zellhuber on 9/11/18.
//  Copyright © 2018 mzellhuber. All rights reserved.
//

import UIKit
import MBProgressHUD

class DetailPhotoViewController: UIViewController {
    
    // MARK: - Properties
    var photo:Photo!
    var img:UIImage!
    var profileURL = ""
    var photos: [Photo]!
    var flickrImagesUrls : [String] = []
    var flickrPhotos : [Photo] = []
    let url = "https://api.flickr.com/services/rest/"
    var photoURL = ""

    
    // MARK: - IBOutlets
    @IBOutlet weak var userBtn: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    

    fileprivate let reuseIdentifier = "userImageCell"


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInfo()
        getUsername()
        setBarButtonItem()
        flickrImagesUrls = []
        flickrPhotos = []
        downloadInfo()
    }
    
    func setInfo() {
        
        setUpImgView()
        
        if let title = photo.title {
            self.title = title
        }
        
    }
    
    func setBarButtonItem() {
        
        let shareBar: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem:.action, target: self, action: #selector(self.share))
        
        self.navigationItem.rightBarButtonItem = shareBar
    }
    
    func setUpImgView(){
        self.imgView.image = img
        imgView.layer.cornerRadius = 8.0
        imgView.clipsToBounds = true
    }
    
    func getUsername() {
        
        let params = ["user_id":photo.owner!,  "nojsoncallback":"1", "format":"json", "method":"flickr.people.getInfo", "api_key":"2c52226553a9808f63bfa82b50719b7c"]
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Loading"
        
        Networking().getData(url: url, params: params, onSuccess: { data in
            do{                
                let user = try JSONDecoder().decode(GetUserResponse.self, from: data)
                
                if let username = user.person {
                    DispatchQueue.main.async {
                        if let name  = username.username {
                            self.photoURL = "https://www.flickr.com/photos/\(username.id!)/\(self.photo.id!)"
                            //print(self.photoURL)
                            
                            self.profileURL = "https://www.flickr.com/people/\(username.id!)/"
                            self.userBtn.setTitle(name._content, for: .normal)
                        }
                    }
                }
                
                
            }catch {
                //print("Error: \(error)")
            }
        }) { error in
            //print("Error: \(error)")
        }
        
        hud.hide(animated: true)
    }
    
    func getMorePhotos() {
        
    }
    
    func downloadInfo() {
        
        
        
        let parameters = ["nojsoncallback":"1", "format":"json", "method":"flickr.photos.getContactsPublicPhotos", "api_key":"2c52226553a9808f63bfa82b50719b7c", "sort":"relevance", "user_id": photo.owner!, "count":"120"]
        
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
                //print("Error: \(error)")
            }
        }) { error in
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)

            if (error as NSError).code == 8 {
                hud.show(animated: true)
                hud.label.text = "Please check your internet connection"
                
                hud.hide(animated: true, afterDelay: 2.0)
            }else{
                hud.show(animated: true)
                hud.label.text = "An error happened, please try again"
                hud.hide(animated: true, afterDelay: 3)
            }
        }
        
    }
    
    @objc func share() {
        let text = photo.title!
        let image = img
        let shareAll = [text , img ,URL(string: photoURL)!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profileVC = segue.destination as? UserProfileViewController {
            profileVC.urlString = self.profileURL
        }
    }
}

extension DetailPhotoViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrImagesUrls.count
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
        let size = (view.frame.width / 3)-7.0
        return CGSize(width: size, height: size)
    }

}
