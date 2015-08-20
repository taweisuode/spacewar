//
//  BackgroundViewController.swift
//  spacewar
//
//  Created by pengge on 15/8/7.
//  Copyright (c) 2015年 pengge. All rights reserved.
//

import UIKit

class BackgroundViewController: UIViewController {
    
    @IBOutlet weak var playButton: UIImageView!
    override func viewDidLoad() {
        playButton.userInteractionEnabled = true
        let singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "imageViewTouch")
        playButton.addGestureRecognizer(singleTap)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    func imageViewTouch()
    {
        //var GameView = GameViewController()
        //self.presentViewController(GameView, animated: true, completion: nil)
        //给button跳转到另一个页面的方法
        self.performSegueWithIdentifier("playButton", sender: self)
        //self.navigationController pushViewController:GameViewController animated:YES
        //println("2")
    }
}