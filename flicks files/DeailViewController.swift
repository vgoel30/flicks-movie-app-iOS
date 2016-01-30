  //
  //  DetailViewController.swift
  //  MovieViewer
  //
  //  Created by Varun Goel on 1/16/16.
  //  Copyright © 2016 Varun Goel. All rights reserved.
  //
  
  import UIKit
  
  class DeailViewController: UIViewController {
    
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var containerView: UIView!
    var movie:NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: containerView.frame.origin.y + containerView.frame.size.height-58)
        
        titleLabel.text = movie["title"] as? String
        
        overviewLabel.text = movie["overview"] as? String
        overviewLabel.sizeToFit()
        
        //base url of the lower resolution imahe
        let smallURL = "https://image.tmdb.org/t/p/w45"
        
        //default url
        let defaultURL = "https://image.tmdb.org/t/p/w500"
        
        //base url of an image extracted from the API for the high res image
        let largeURL = "http://image.tmdb.org/t/p/original"
        
        //the total url for the lower resolution image
        //let smallImageURL = NSURL(string:smallURL + posterPath)
        
        //the total url for the higher resolution image
        //let smallImageURL = NSURL(string:largeURL + posterPath)
        
        
        
        
        //safety check in case the particular movie doesn't have a poster
        if let posterPath = movie["poster_path"] as? String {
            
            //the total url for the lower resolution image
            let smallImageURL = NSURL(string:smallURL + posterPath)
            
            //the total url for the default resolution image
            let defaultImageURL = NSURL(string:defaultURL + posterPath)
            
            //the total url for the higher resolution image
            let largeImageURL = NSURL(string:largeURL + posterPath)
            
            let smallImageRequest = NSURLRequest(URL: smallImageURL!)

            let largeImageRequest = NSURLRequest(URL: largeImageURL!)
            
            posterImageView.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = smallImage;
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        self.posterImageView.alpha = 1.0
                        
                        }, completion: { (sucess) -> Void in
                            
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            self.posterImageView.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    
                                    self.posterImageView.image = largeImage;
                                    
                                },
                                failure: { (request, response, error) -> Void in
                                    self.posterImageView.setImageWithURL(defaultImageURL!)
                            })
                    })
                },
                failure: { (request, response, error) -> Void in
                    self.posterImageView.setImageWithURL(defaultImageURL!)
            })
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
  }
