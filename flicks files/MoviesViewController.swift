 //
 //  MoviesViewController.swift
 //  flicks
 //
 //  Created by Varun Goel on 1/18/16.
 //  Copyright © 2016 Varun Goel. All rights reserved.
 //
 
 import UIKit
 import AFNetworking
 
 
 
 //function to check if internet connection is active or not
 
 func isConnectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
        SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }
    
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection)
    
 }
 
 //required for searching
 extension MoviesViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
 }
 
 class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //helper function to fill the array of movie titles
    func returnAllTitles() -> [String]{
        var arrayOfTitles: [String] = []
        
        //if online and API worked properly, the number of rowns is equal to the number of movies
        if let movies = movies {
            
            for(var i = 0;  i < movies.count; i++){
                arrayOfTitles.append((movies[i])["title"]! as! String)
            }
            
            // titles = arrayOfTitles
            //print(titles)
            return arrayOfTitles
        }
            
        else{
            print("Zilch")
            return arrayOfTitles
        }
    }
    
    //function to filter name
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        let data = returnAllTitles()
        
        filteredMovies = data.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        
        tableView.reloadData()
    }
    
    //outlet for navigation bar
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    //connection error label
    @IBOutlet weak var connectionErrorLabel: UILabel!
    
    //required for pull to refresh
    var refreshControl: UIRefreshControl!
    
    //adding the search controller
    let searchController = UISearchController(searchResultsController: nil)
    
    //The filtered movies held as an array of String
    var filteredMovies = [String]()
    
    //the array to hold all the movies
    var movies:[NSDictionary]? //the array to hold all the movies
    
    var moviesToShow: [NSDictionary] = [] //the movies to show after the search has taken place
    
    var endPoint:String!
    
    //required for refreshing
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    //when refresh takes place
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
        
        if isConnectedToNetwork() == true {
            print("reload OK")
            connectionErrorLabel.hidden = true
        }
        else{
            print("reload not OK")
            connectionErrorLabel.hidden = false
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.redColor()
           // NSFontAttributeName: UIFont(name: "Avenir", size: 20)!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        

        
        //required for search functionality
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        
        
        //add the refresh thing
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        //if internet connection doesn't exist, show an alert box that internet connection is required
        if isConnectedToNetwork() == true {
            print("Internet connection OK")
            connectionErrorLabel.hidden = true
            
        } else {
            print("Internet connection FAILED")
            connectionErrorLabel.hidden = false
            // connectionErrorLabel.bringSubviewToFront(searchBar)
        }
        
        
        
        //setting the data sources
        tableView.dataSource = self
        tableView.delegate = self
        
        //making the request to fetch data
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            // print("response: \(responseDictionary)")
                            
                            //movies will hold the results from the API
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.tableView.reloadData() //reloading to reflect changes
                            
                            //show the loading state
                            //EZLoadingActivity.show("Loading...", disableUI: true)
                    }
                }
        });
        //data fetching ends
        //show the loading state
        EZLoadingActivity.show("Loading...", disableUI: true)
        task.resume()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //for the number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredMovies.count
        }
        //if online and API worked properly, the number of rowns is equal to the number of movies
        if let movies = movies {
            return movies.count
        }
            //don't create the table if no data was fetched
        else{
            return 0
        }
    }
    
    //to populate the cells with the desired values
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("movieCell",forIndexPath: indexPath) as! MovieCell
        
        //base url of an image extracted from the API
        let baseURL = "http://image.tmdb.org/t/p/w500"
        
        if(searchController.active && searchController.searchBar.text != ""){
            
            moviesToShow.removeAll() //remove all the previous movies
            
            //iterate over the movies array to check the movies that we want
            for(var i = 0; i < movies!.count; i++){
                let movie = movies![i]
                
                let title = movie["title"] as! String
                
                //print(movie)
                
                //if the title is a relevant string from the search
                if(filteredMovies.contains(title)){
                    moviesToShow.append(movie)
                }
            }
            
            //get the movie in a particular row of the movies array
            let movieToAttach = moviesToShow[indexPath.row]
            
            //movie title
            let title = movieToAttach["title"] as! String
            //titles.append(title) //add the title of the movie to the titles array
            
            var overview = "Adult: No"
            
            if(movieToAttach["adult"] as! Bool){
                overview = "Adult: Yes"
            }
            
            
            //safety check in case the particular movie doesn't have a poster
            if let posterPath = movieToAttach["poster_path"] as? String {
                let imageURL = NSURL(string:baseURL + posterPath)
                cell.posterView.setImageWithURL(imageURL!)
            }
            
            cell.titleLabel.text =  title
            cell.overviewLabel.text = overview
            
            cell.posterView.alpha = 0.1
            UIView.animateWithDuration(1, animations: {
                cell.posterView.alpha = 1
            })
            
            cell.ratingLabel.text = "Average Rating: " + String(movieToAttach["vote_average"] as! Float)
            
            //the year of release
            let releaseDate = movieToAttach["release_date"] as! String
            //splitting the string to get the integer value of today's date
            let fullNameArr = releaseDate.componentsSeparatedByString("-")
            
            let year = fullNameArr[0].componentsSeparatedByString(" ")[0]
            let month = fullNameArr[1].componentsSeparatedByString(" ")[0]
            
            let date = fullNameArr[2].componentsSeparatedByString(" ")[0]
            
            
            cell.dateLabel.text = "Release Date: " + month + "/" + date + "/" + year

            
        }
            
        else{
            let movie = movies![indexPath.row] //the movie to be applied at the particular row
            let title = movie["title"] as! String //name of the movig
            var overview = "Adult: No"
            
            if(movie["adult"] as! Bool){
                overview = "Adult: Yes"
            }
            
            //the average rating
            let averageRating = String(movie["vote_average"] as! Float)
            
            //let overview = movie["overview"] as! String
            
            //the average rating
            //print(movie["vote_average"] as! Float)
            
           
            
            //print(String(movie["vote_average"] as! Float))
            
            //safety check in case the particular movie doesn't have a poster
            if let posterPath = movie["poster_path"] as? String {
                let imageURL = NSURL(string:baseURL + posterPath)!
                cell.posterView.setImageWithURL(imageURL)
                
                let imageRequest = NSURLRequest(URL: NSURL(string: baseURL + posterPath)!)
                
                cell.posterView.setImageWithURLRequest(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterView.image = image
                        
                        cell.posterView.alpha = 0.1
                        UIView.animateWithDuration(1, animations: {
                            cell.posterView.alpha = 1
                        })
                    }
                    },
                    failure: { (imageRequest, imageResponse, error) -> Void in
                        // do something for the failure condition
                })
            }
            
            
            cell.titleLabel.text = title
            cell.overviewLabel.text = overview
            cell.ratingLabel.text = "Average Rating: " + averageRating
            
            //the year of release
            let releaseDate = movie["release_date"] as! String
            //splitting the string to get the integer value of today's date
            let fullNameArr = releaseDate.componentsSeparatedByString("-")
            
            let year = fullNameArr[0].componentsSeparatedByString(" ")[0]
            let month = fullNameArr[1].componentsSeparatedByString(" ")[0]
            
            let date = fullNameArr[2].componentsSeparatedByString(" ")[0]
            
            
            cell.dateLabel.text = "Release Date: " + month + "/" + date + "/" + year
        }
        
        
        
        //show success dialog box if connected to network
        if isConnectedToNetwork(){
            EZLoadingActivity.hide(success: true, animated: true)
            
        }
        else{
            connectionErrorLabel.hidden = false
            EZLoadingActivity.hide()
        }
        
        //sets the initial alpha to less than 1 for the animation
        
        //        cell.posterView.alpha = 0.1
        //        UIView.animateWithDuration(1, animations: {
        //            cell.posterView.alpha = 1
        //        })
        
        cell.selectionStyle = .None
        
    
        
        return cell
    }
    
  
    //for when the movie is clicked and we need to go and see it's details
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        
        if(searchController.active && searchController.searchBar.text != ""){
            let indexPath = tableView.indexPathForCell(cell)
            let movieClicked = moviesToShow[indexPath!.row]
            let detailViewController = segue.destinationViewController as! DeailViewController
            detailViewController.movie = movieClicked
        }
            
        else{
            let indexPath = tableView.indexPathForCell(cell)
            let movieClicked = movies![indexPath!.row] //the movie that was clicked
            let detailViewController = segue.destinationViewController as! DeailViewController
            detailViewController.movie = movieClicked
        }
        
    }
   
    
 }
