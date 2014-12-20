//
//  APPViewController.h
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialDelegate.h"

@interface TutorialViewController : UIViewController <UINavigationControllerDelegate,UIPageViewControllerDataSource>{
    id <TutorialDelegate> tutorialDelegate;
}
@property (nonatomic, retain) id <TutorialDelegate> tutorialDelegate;


@property (strong, nonatomic) UIPageViewController *pageController;


- (void)didFinishTutorial:(id)sender;
@end
