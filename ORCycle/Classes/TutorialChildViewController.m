/*
 **	ORcycle, Copyright 2014, 2015, PSU Transportation, Technology, and People Lab.
 *
 *	ORcycle 2.2.0 has introduced new app features: safety focus with new buttons
 *	to report safety issues and crashes (new questionnaires), expanded trip
 *	questionnaire (adding questions besides trip purpose), app utilization
 *	reminders, app tutorial, and updated font and color schemes.
 *
 *	@author Bryan.Blanc <bryanpblanc@gmail.com>    (code)
 *	@author Miguel Figliozzi <figliozzi@pdx.edu> and ORcycle team (general app
 *	design and features, report questionnaires and new ORcycle features)
 *
 *	For more information on the project, go to
 * 	http://www.pdx.edu/transportation-lab/orcycle  and http://www.pdx.edu/transportation-lab/app-development
 *
 *	Updated/modified for Oregon pilot study and app deployment.
 *
 *	ORcycle is free software: you can redistribute it and/or modify it under the
 *	terms of the GNU General Public License as published by the Free Software
 *	Foundation, either version 3 of the License, or any later version.
 *	ORcycle is distributed in the hope that it will be useful, but WITHOUT ANY
 *	WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 *	A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *	You should have received a copy of the GNU General Public License along with
 *	ORcycle. If not, see <http://www.gnu.org/licenses/>.
 *
 */

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
