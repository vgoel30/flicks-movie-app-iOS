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
        
        
        
        //containerView.frame.size.height = 290
        
        //base url of an image extracted from the API
        let baseURL = "http://image.tmdb.org/t/p/w500"
        
        titleLabel.text = movie["title"] as? String
        
        overviewLabel.text = movie["overview"] as? String
        overviewLabel.sizeToFit()
        
        
        //safety check in case the particular movie doesn't have a poster
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = NSURL(string:baseURL + posterPath)
            posterImageView.setImageWithURL(imageURL!)
        }
        
        
        
        // Do any additional setup after loading the view.
        // print(movie)
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
