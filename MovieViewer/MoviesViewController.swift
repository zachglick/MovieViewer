//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Zach Glick on 1/26/16.
//  Copyright © 2016 Zach Glick. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, /*UITableViewDataSource, UITableViewDelegate,*/ UISearchBarDelegate, UICollectionViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var endpoint : String!
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        print("ViewDidLoad")
        super.viewDidLoad()
        //tableView.dataSource = self
        //tableView.delegate = self
        //tableView.hidden = true
        collectionView.dataSource = self
        collectionView.delegate = self
        movieSearchBar!.delegate = self
        collectionView.allowsSelection = true
        
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        //tableView.insertSubview(refreshControl, atIndex: 0)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.color = UIColor.grayColor()
        

        refreshMovies()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        refreshMovies()
    
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("true")
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = filteredMovies![indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }
    

    @IBAction func onMoviesTap(sender: AnyObject) {
        self.view.endEditing(true)
        if(self.errorView.hidden == false){
            refreshMovies()
        }
    }
    
    
    
    func refreshMovies(){
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            //print("response: \(responseDictionary)")
                            
                            self.movies = (responseDictionary["results"] as! [NSDictionary])
                            self.filteredMovies = self.movies
                            
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                            self.refreshControl.endRefreshing()
                            self.errorView.hidden = true
                            
                            self.collectionView.reloadData()
                    }

                }
                if error != nil{
                    if error!.code == NSURLErrorNotConnectedToInternet {
                        self.errorView.hidden = false
                    }
                    
                }
        })
        task.resume()
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredMovies = movies?.filter({(dataItem: NSDictionary) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if (dataItem["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    //print("\(dataItem["title"] as! String)     \(searchText)")
                    return true
                } else {
                    return false
                }
            })
        }
        collectionView.reloadData()
    }
    
    
    

    func collectionView(collection: UICollectionView, selectedItemIndex: NSIndexPath)
    {
        print("true")
        self.performSegueWithIdentifier("showDetail", sender: self)
    }
    
    
    
}

extension MoviesViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies{
            return filteredMovies.count
        }
        else{
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MovieCollectionCell
        cell.backgroundColor = UIColor.blackColor()
        
        //let title = movie["title"] as! String
        //let overview = movie["overview"] as! String
        //cell.titleLabel.text = title
        //cell.overviewLabel.text = overview
        
        
        
        let movie = filteredMovies![indexPath.item]
        let posterPath = movie["poster_path"] as? String

        
        
        if let posterPath = posterPath{
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageUrl = NSURL(string: baseUrl + posterPath)
            
            
            let request = NSURLRequest(URL: imageUrl!)
            let placeholderImage = UIImage(named: "MovieHolder")
            if(cell.posterCollectionView?.image == nil){
                cell.posterCollectionView.setImageWithURLRequest(request, placeholderImage: placeholderImage, success: { (request, response, imageData) -> Void in
                    UIView.transitionWithView(cell.posterCollectionView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { cell.posterCollectionView.image = imageData }, completion: nil   )
                    }, failure: nil)
            }
            else{
                cell.posterCollectionView.setImageWithURL(imageUrl!)
            }
            
        }
        else{
            cell.posterCollectionView.image = nil
        }
    
        return cell
    }
    
}



