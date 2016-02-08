//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by Zach Glick on 2/2/16.
//  Copyright © 2016 Zach Glick. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var movie: NSDictionary!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y+infoView.frame.size.height )
        
        
        print(movie)
        let title = movie["title"] as! String
        titleLabel.text = title
        let overview = movie["overview"] as! String
        
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        
        
        
        let posterPath = movie["poster_path"] as? String
        if let posterPath = posterPath{
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageUrl = NSURL(string: baseUrl + posterPath)
            
            
            let request = NSURLRequest(URL: imageUrl!)
            let placeholderImage = UIImage(named: "MovieHolder")
            if(posterImageView?.image == nil){
                posterImageView.setImageWithURLRequest(request, placeholderImage: placeholderImage, success: { (request, response, imageData) -> Void in
                    UIView.transitionWithView(self.posterImageView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { self.posterImageView.image = imageData }, completion: nil   )
                    }, failure: nil)
            }
            else{
                posterImageView.setImageWithURL(imageUrl!)
            }
            
        }
        else{
            posterImageView.image = nil
        }
        // Do any additional setup after loading the view.
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
