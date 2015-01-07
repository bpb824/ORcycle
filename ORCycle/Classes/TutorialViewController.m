//
//  APPViewController.m
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "TutorialViewController.h"
#import "TutorialChildViewController.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface TutorialViewController ()

@end

@implementation TutorialViewController
@synthesize tutorialDelegate;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    TutorialChildViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (TutorialChildViewController *)viewControllerAtIndex:(NSUInteger)index {
        
    TutorialChildViewController *childViewController = [[TutorialChildViewController alloc] initWithNibName:@"TutorialChildViewController" bundle:nil];
    childViewController.index = index;
    if (index ==5){
        
        UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        UIButton *readyButton = [[UIButton alloc]init];
        if(IS_IPHONE_5){
            readyButton = [[UIButton alloc]initWithFrame:CGRectMake(25,475,270,50)];
        }
        else{
            readyButton = [[UIButton alloc]initWithFrame:CGRectMake(25,392,270,50)];
        }
        
        
        
        [readyButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        readyButton.layer.borderWidth = 0.5f;
        readyButton.layer.borderColor = [[UIColor blackColor] CGColor];
        
        [readyButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        
        readyButton.backgroundColor = [UIColor clearColor];
        readyButton.enabled = YES;
        
        [readyButton setTitle:@"Ready to use ORcycle!" forState:UIControlStateNormal];
        [readyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        readyButton.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
        [readyButton.layer setCornerRadius:5.0f];
        readyButton.clipsToBounds = YES;
        readyButton.titleLabel.textColor = [UIColor whiteColor];
        [readyButton addTarget:self action:@selector(didFinishTutorial:) forControlEvents:UIControlEventTouchUpInside];
        [childViewController.view addSubview:readyButton];
    }

    
    return childViewController;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TutorialChildViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TutorialChildViewController *)viewController index];
    
    index++;
    
    if (index == 6) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 6;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

-(void) didFinishTutorial:(id)sender{
    [tutorialDelegate didFinishTutorial];
}

- (void)dealloc {
    
    self.tutorialDelegate = nil;
    [tutorialDelegate release];
    
    [super dealloc];
}

@end
