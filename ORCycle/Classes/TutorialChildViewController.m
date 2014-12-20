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
                UIImage		*image		= [UIImage imageNamed:@"iOS_TutorialScreen1.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 33, 16, 246, 436 );
                [self.view addSubview:imageView];
            }
                break;
            case 1:{
                UIImage		*image		= [UIImage imageNamed:@"iOS_TutorialScreen2.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 40, 16, 248, 436 );
                [self.view addSubview:imageView];
            }
                break;
            case 2:{
                UIImage		*image		= [UIImage imageNamed:@"iOS_TutorialScreen3.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 33.75, 16, 252.5, 436 );
                [self.view addSubview:imageView];
            }
                break;
            case 3:{
                UIImage		*image		= [UIImage imageNamed:@"iOS_TutorialScreen4.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 37.25, 16, 245.5, 436 );
                [self.view addSubview:imageView];
                
                
            }
                break;
        }

    }
    else{
        switch (self.index){
            case 0:{
                UIImage		*image		= [UIImage imageNamed:@"iOS_TutorialScreen1.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 52.8, 16, 214.5, 380 );
                [self.view addSubview:imageView];
            }
                break;
            case 1:{
                UIImage		*image		= [UIImage imageNamed:@"iOS_TutorialScreen2.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 51.9, 16, 216.2, 380 );
                [self.view addSubview:imageView];
            }
                break;
            case 2:{
                UIImage		*image		= [UIImage imageNamed:@"iOS_TutorialScreen3.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 50, 16, 220.1, 380 );
                [self.view addSubview:imageView];
            }
                break;
            case 3:{
                UIImage		*image		= [UIImage imageNamed:@"iOS_TutorialScreen4.png"];
                UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
                imageView.frame = CGRectMake( 53, 16, 214.0, 380 );
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
