//
//  TutorialPageViewController.m
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "TutorialChildViewController.h"
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface TutorialChildViewController ()

@end

@implementation TutorialChildViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //self.screenNumber.text = [NSString stringWithFormat:@"Screen #%d", self.index];
    
    if(IS_IPHONE_5){
        switch (self.index){
            case 0:{
                UIImage		*image		= [UIImage imageNamed:@"iOS-Report.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 13.52, 10, 292.96, 520 );
                [self.view addSubview:imageView];
            }
                break;
            case 1:{
                UIImage		*image		= [UIImage imageNamed:@"iOS-ReportsButton.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 13.52, 10, 292.96, 520 );
                [self.view addSubview:imageView];
            }
                break;
            case 2:{
                UIImage		*image		= [UIImage imageNamed:@"iOS-HomeStart.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 13.52, 10, 292.96, 520 );
                [self.view addSubview:imageView];
            }
                break;
            case 3:{
                UIImage		*image		= [UIImage imageNamed:@"iOSHomeTrip.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 13.52, 10, 292.96, 520 );
                [self.view addSubview:imageView];
                
                
            }
                break;
            case 4:{
                UIImage		*image		= [UIImage imageNamed:@"iOSHomeFeedback.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 13.52, 10, 292.96, 520 );
                [self.view addSubview:imageView];
                
                
            }
                break;
            case 5:{
                UIImage		*image		= [UIImage imageNamed:@"iOSRemindTrip.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 13.52, 10, 292.96, 520 );
                [self.view addSubview:imageView];
                
                
            }
                break;
            case 6:{
                UIImage		*image		= [UIImage imageNamed:@"iOS-LinkOut.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 13.52, 10, 292.96, 520 );
                [self.view addSubview:imageView];
                
                
            }
                break;
        }

    }
    else{
        switch (self.index){
            case 0:{
                UIImage		*image		= [UIImage imageNamed:@"iOS-Report.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 41.13, 10, 237.75, 422 );
                [self.view addSubview:imageView];
            }
                break;
            case 1:{
                UIImage		*image		= [UIImage imageNamed:@"iOS-ReportsButton.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 41.13, 10, 237.75, 422 );
                [self.view addSubview:imageView];
            }
                break;
            case 2:{
                UIImage		*image		= [UIImage imageNamed:@"iOS-HomeStart.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 41.13, 10, 237.75, 422 );
                [self.view addSubview:imageView];
            }
                break;
            case 3:{
                UIImage		*image		= [UIImage imageNamed:@"iOSHomeTrip.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 41.13, 10, 237.75, 422 );
                [self.view addSubview:imageView];
            }
                break;
            case 4:{
                UIImage		*image		= [UIImage imageNamed:@"iOSHomeFeedback.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 41.13, 10, 237.75, 422 );
                [self.view addSubview:imageView];
            }
                break;
            case 5:{
                UIImage		*image		= [UIImage imageNamed:@"iOSRemindTrip.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 41.13, 10, 237.75, 422 );
                [self.view addSubview:imageView];
                
                
            }
                break;
            case 6:{
                UIImage		*image		= [UIImage imageNamed:@"iOS-LinkOut.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 41.13, 10, 237.75, 422 );
                [self.view addSubview:imageView];
                
                
            }
                break;

        }

    }
    
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
