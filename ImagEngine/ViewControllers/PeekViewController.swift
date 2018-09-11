//
//  PeekViewController.swift
//  ImagEngine
//
//  Created by Melissa Zellhuber on 9/10/18.
//  Copyright © 2018 mzellhuber. All rights reserved.
//

import UIKit

class PeekViewController: UIViewController {
    
    //Weak to prevent memory leak
    weak var photo:UIImage?
    weak var flickrViewController:FlickrViewerViewController?
    var imgTitle:String?
    
    @IBOutlet weak var imgView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if let photo = photo {
            //let photoURL = "https://farm\(photo.farm!).staticflickr.com/\(photo.server!)/\(photo.id!)_\(photo.secret!).jpg"
            //imgView.downloadImageWith(string: photoURL)
            imgView.image = photo
        }
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        
        let shareAction = UIPreviewAction(title: "Share", style: .default) { (previewAction, viewController) -> Void in
            
            if let flickrVC = self.flickrViewController, let activityVC = self.activityViewController{
                flickrVC.present(activityVC, animated: true, completion: nil)
                
            }
        }
        
        return [shareAction]
    }
    
    private var activityViewController:UIActivityViewController?{
        guard let image = imgView.image else {
            return nil
        }
        
        return UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }

}
