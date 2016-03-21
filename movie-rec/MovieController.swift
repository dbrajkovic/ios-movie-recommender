//
//  MovieController.swift
//  movie-rec
//
//  Created by Eric Drew on 3/15/16.
//  Copyright © 2016 Eric Drew. All rights reserved.
//

import UIKit

class MovieController: UIViewController,UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var starControl: StarControl!
    @IBOutlet weak var recBtn: MaterialButtonView!
    @IBOutlet weak var posterView: MaterialContentView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var posterConstraint: NSLayoutConstraint!
    @IBOutlet weak var starView: MaterialContentView!
    @IBOutlet weak var posterImg: MaterialImageView!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postBlur: UIImageView!
    
    var similarAr = [Similar]()
    var movie: Movie?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.hidden = true
        tableView.alpha = 0.0
        
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.view.bounds
        postBlur.addSubview(blurView)
        
        setRec()
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:"posterTapped:")
        posterImg.userInteractionEnabled = true
        posterImg.addGestureRecognizer(tapGestureRecognizer)
        
        similarAr.append(Similar(index: 1, title: "title one"))
        similarAr.append(Similar(index: 2, title: "title two"))
        similarAr.append(Similar(index: 3, title: "title three"))
        similarAr.append(Similar(index: 4, title: "title four"))
        similarAr.append(Similar(index: 5, title: "title five"))
        similarAr.append(Similar(index: 6, title: "title six"))
        similarAr.append(Similar(index: 7, title: "title seven"))
        similarAr.append(Similar(index: 8, title: "title eight"))
        similarAr.append(Similar(index: 9, title: "title nine"))
        similarAr.append(Similar(index: 10, title: "title ten"))
    }
    
    override func viewWillAppear(animated: Bool) {
        if let mov = movie {
            let completionBlock: (img: UIImage) -> () = { img in self.nextMovie(mov, image: img) }
            MovieInfo.instance.retrieveData(mov.tmdbId, completion: completionBlock)
        }
    }
    
    
    func posterTapped(sender: AnyObject) {
        performSegueWithIdentifier(DETAIL_SEGUE, sender: nil)
    }
    
    func setRec() {
        if starControl.currentStarCount > 0 {
            recBtn.alpha = 1.0
            recBtn.setTitle("next recommendation", forState: .Normal)
        } else {
            recBtn.alpha = 0.7
            recBtn.setTitle("I haven't seen it", forState: .Normal)
        }
    }

    @IBAction func starChanged(sender: StarControl) {
        setRec()
    }

    @IBAction func nextPressed(sender: AnyObject) {
        if starControl.currentStarCount == 0 {
            //skip
        } else {
            //send review
            //store rating history
        }
        //nextMovie()
    }
    
    @IBAction func segPressed(sender: SegButtonView) {
        if sender.isLeftSelected {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.starView.hidden = false
                self.posterView.hidden = false
                self.recBtn.hidden = false
                self.tableView.alpha = 0.0
                self.starView.alpha = 1.0
                self.posterView.alpha = 1.0
                self.recBtn.alpha = 1.0
                self.postBlur.alpha = 1.0
                }, completion: { (Bool) -> Void in
                    self.tableView.hidden = true
            })
            
        } else {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.tableView.hidden = false
                self.tableView.alpha = 1.0
                self.starView.alpha = 0.0
                self.posterView.alpha = 0.0
                self.recBtn.alpha = 0.0
                self.postBlur.alpha = 0.0
                }, completion: { (Bool) -> Void in
                    self.starView.hidden = true
                    self.posterView.hidden = true
                    self.recBtn.hidden = true
            })
        }
    }
    
    @IBAction func filterPressed(sender: AnyObject) {
        performSegueWithIdentifier(FILTER_SEGUE, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if FILTER_SEGUE == segue.identifier {
            if let popoverViewController = segue.destinationViewController as? FilterController {
                popoverViewController.popoverPresentationController!.delegate = self
                let rct = popoverViewController.popoverPresentationController!.sourceRect
                popoverViewController.popoverPresentationController!.sourceRect = rct.offsetBy(dx: filterBtn.bounds.width / 2.0, dy: filterBtn.bounds.height)
                popoverViewController.popoverPresentationController!.permittedArrowDirections = .Up
                popoverViewController.popoverPresentationController?.backgroundColor = UIColor(colorLiteralRed: 0.0/255.0, green: 145.0/255.0, blue: 234.0/255.0, alpha: 1.0)
            }
        }
        if DETAIL_SEGUE == segue.identifier {
            if let destinationVC = segue.destinationViewController as? MovieDetailController {
                
                destinationVC.movie = movie
            }
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        //update filter
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func nextMovie(movie: Movie, image: UIImage) {
        let totalDuration = 0.75
        self.posterConstraint.constant = -self.view.frame.width
        starControl.animateReset(totalDuration)
        UIView.animateWithDuration(totalDuration, animations: {
                self.recBtn.alpha = 0.7
        })
        UIView.animateWithDuration(totalDuration/2, animations: {
            self.movieTitle.alpha = 0.0
            self.postBlur.alpha = 0.0
            self.view.layoutIfNeeded()
            }, completion: { finished in
                self.posterConstraint.constant = self.view.frame.width
                self.view.layoutIfNeeded()
                self.posterConstraint.constant = 0
                self.updateMovie(movie, image: image)
                UIView.animateWithDuration(totalDuration/2) {
                    self.movieTitle.alpha = 1.0
                    self.postBlur.alpha = 1.0
                    self.view.layoutIfNeeded()
                }
            })
    }
    
    func updateMovie(movie: Movie, image: UIImage) {
        self.movieTitle.text = movie.formattedTitle
        self.posterImg.image = image
        self.postBlur.image = image
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return similarAr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let similar = similarAr[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier(SIMILAR_CELL_ID) as? SimilarCell {
            cell.configureCell(similar)
            return cell
        } else {
            return SimilarCell()
        }
    }
}
