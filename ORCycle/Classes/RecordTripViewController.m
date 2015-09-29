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
*
** 	Reno Tracks, Copyright 2012, 2013 Hack4Reno
*
*   @author Brad.Hellyar <bradhellyar@gmail.com>
*
*   Updated/Modified for Reno, Nevada app deployment. Based on the
*   CycleTracks codebase for SFCTA, and the Atlanta Cycle app repo.
*
** 	CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
*                                    San Francisco, CA, USA
*
*   @author Matt Paul <mattpaul@mopimp.com>
*
*   This file is part of CycleTracks.
*
*   CycleTracks is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   CycleTracks is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
*/

//
//  RecordTripViewController.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/10/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>

#include <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import "constants.h"
#import "MapViewController.h"
#import "NoteViewController.h"
#import "NoteDetailViewController.h"
#import "CrashDetailViewController.h"
#import "DetailViewController.h"
#import "PersonalInfoViewController.h"
#import "PickerViewController.h"
#import "RecordTripViewController.h"
#import "ReminderManager.h"
#import "TripManager.h"
#import "NoteManager.h"
#import "Trip.h"
#import "User.h"
#import "TutorialViewController.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

//TODO: Fix incomplete implementation
@implementation RecordTripViewController

@synthesize tripManager,reminderManager;
@synthesize noteManager;
@synthesize infoButton, saveButton, startButton, noteButton, centerButton, parentView, welcomeCheckboxButton, tripCheckboxButton;
@synthesize timer, timeCounter, distCounter, slowSpeedsArray;
@synthesize recording, shouldUpdateCounter, userInfoSaved, iSpeedCheck, timeSpeedCheck, distSpeedCheck, speedCheck, speedNoteUp;
@synthesize appDelegate;
@synthesize saveActionSheet;
@synthesize accelDataHolder;

#pragma mark CMMotionManagerDelegate methods

- (CMMotionManager *)getMotionManager
{
    CMMotionManager *motionManager = nil;
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    
    return motionManager;
}

- (void)newAccelData
{
    NSMutableArray *emptyArray = [[NSMutableArray alloc]init];
    self.accelDataHolder = emptyArray;
}

- (void) addAccelObs: (CMAccelerometerData *)accelObs
{
    [self.accelDataHolder addObject:accelObs];
    
}

- (NSNumber *)meanOf:(NSMutableArray *)array
{
    double runningTotal = 0.0;
    
    for(NSNumber *number in array)
    {
        runningTotal += [number doubleValue];
    }
    
    return [NSNumber numberWithDouble:(runningTotal / [array count])];
}

- (NSNumber *)ssDiffOf:(NSMutableArray *)array
{
    if(![array count]) return nil;
    
    double mean = [[self meanOf:array] doubleValue];
    double sumOfSquaredDifferences = 0.0;
    
    for(NSNumber *number in array)
    {
        double valueOfNumber = [number doubleValue];
        double difference = valueOfNumber - mean;
        sumOfSquaredDifferences += difference * difference;
    }
    
    return [NSNumber numberWithDouble:sumOfSquaredDifferences];
}
 


- (NSMutableDictionary *)aggAccelData:(NSMutableArray *)accelArray
{
    NSMutableDictionary *aggData = [NSMutableDictionary dictionaryWithCapacity:7];
    
    NSMutableArray *xData = [[NSMutableArray alloc]init];
    NSMutableArray *yData = [[NSMutableArray alloc]init];
    NSMutableArray *zData = [[NSMutableArray alloc]init];
    
    for (int i=0; i < [accelArray count];i++){
        CMAccelerometerData *accelObs = [accelArray objectAtIndex:i];
        [xData addObject:[NSNumber numberWithDouble: accelObs.acceleration.x]];
        [yData addObject:[NSNumber numberWithDouble: accelObs.acceleration.y]];
        [zData addObject:[NSNumber numberWithDouble: accelObs.acceleration.z]];
    }
    
    [aggData setValue: [self meanOf:xData] forKey: @"x_avg"];
    [aggData setValue:[self meanOf:yData] forKey: @"y_avg"];
    [aggData setValue:[self meanOf:zData] forKey: @"z_avg"];
    
    [aggData setValue: [self ssDiffOf:xData] forKey: @"x_ss"];
    [aggData setValue:[self ssDiffOf:yData] forKey: @"y_ss"];
    [aggData setValue:[self ssDiffOf:zData] forKey: @"z_ss"];
    
    [aggData setValue:[NSNumber numberWithInteger:[accelArray count]] forKey: @"numObs"];

    return aggData;
}


#pragma mark CLLocationManagerDelegate methods


- (CLLocationManager *)getLocationManager {
	appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.locationManager != nil) {
        return appDelegate.locationManager;
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorizedAlways:
            {NSLog(@"GPS Services functioning properly");}
                break;
            case kCLAuthorizationStatusDenied:
            {
                UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Error" message:@"App level settings have been denied. Please allow ORcycle to access location services in Settings>Privacy>Location Services." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
                alert= nil;
            }
                break;
            case kCLAuthorizationStatusNotDetermined:
            {
                /*
                UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Error" message:@"The user is yet to provide the permission" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
                alert= nil;
                 */
            }
                break;
            case kCLAuthorizationStatusRestricted:
            {
                UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Error" message:@"The app is recstricted from using location services." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
                alert= nil;
            }
                break;
                
            default:
                break;
        }
    }
    else{
        UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"Error" message:@"The location services seems to be disabled from the settings." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        alert= nil;
    }
    appDelegate.locationManager = [[[CLLocationManager alloc] init] autorelease];
    
    //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    appDelegate.locationManager.delegate = self;
    
    appDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    return appDelegate.locationManager;
}



- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	CLLocationDistance deltaDistance = [newLocation distanceFromLocation:oldLocation];
    
    if (!myLocation) {
        myLocation = [newLocation retain];
    }
    else if ([myLocation distanceFromLocation:newLocation]) {
        [myLocation release];
        myLocation = [newLocation retain];
    }
    
	if ( !didUpdateUserLocation )
	{
		NSLog(@"zooming to current user location");
		MKCoordinateRegion region = { newLocation.coordinate, { 0.0078, 0.0068 } };
		[mapView setRegion:region animated:YES];

		didUpdateUserLocation = YES;
	}
	
	// only update map if deltaDistance is at least some epsilon 
	else if ( deltaDistance > 1.0 )
	{
		//NSLog(@"center map to current user location");
		[mapView setCenterCoordinate:newLocation.coordinate animated:YES];
	}
    
	if ( recording )
	{
		// add to CoreData store
        NSMutableDictionary *aggedAccelData = [self aggAccelData:self.accelDataHolder];
        [self newAccelData];
        CLLocationDistance distance = [tripManager addCoord:newLocation withAccel:aggedAccelData];
		self.distCounter.text = [NSString stringWithFormat:@"%.1f", distance / 1609.344];
        
        
        
        /*
        //Calory text
        double calory = 49 * distance / 1609.344 - 1.69;
        if (calory <= 0) {
            calorieCount.text = [NSString stringWithFormat:@"0.0"];
        }
        else
            calorieCount.text = [NSString stringWithFormat:@"%.1f", calory];
        
        //CO2 text
        C02Count.text = [NSString stringWithFormat:@"%.1f", 0.93 * distance / 1609.344];
        */
        
        NSArray *timeArray = [timeCounter.text componentsSeparatedByString:@":"];
        //NSLog(timeCounter.text);
        double duration = [timeArray[0] integerValue]*3600 + [timeArray[1] integerValue]* 60 + [timeArray[2] integerValue];
        //NSLog(@"Duration = %f",duration);
        //NSLog(@"Distance = %f", distance);
        double avgSpeed = ( distance / 1609.344 ) / ( duration / 3600. );
        // speedCounter.text = [NSString stringWithFormat:@"%.1f", newLocation.speed * 3600 / 1609.344];
        if ( avgSpeed >= 0. ){
            speedCounter.text = [NSString stringWithFormat:@"%.1f", avgSpeed];
        }
        else{
            speedCounter.text = @"0.0";
        }
        
        if (!iSpeedCheck){
            timeSpeedCheck = 0.0;
            distSpeedCheck = 0.0;
            speedCheck = 0.0;
            iSpeedCheck = true;
            self.speedNoteUp = false;
        }
        
        else{
            timeSpeedCheck = [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp]+ timeSpeedCheck;
            //NSLog(@"timeSpeedCheck = %f",timeSpeedCheck);
            distSpeedCheck = deltaDistance + distSpeedCheck;
            //NSLog(@"distSpeedCheck = %f",distSpeedCheck);
        }
        
        if (timeSpeedCheck >= 180){
            speedCheck = ( distSpeedCheck / 1609.344 ) / ( timeSpeedCheck / 3600.0 );
            //NSLog(@"Speed check = %f", speedCheck);
            
            CFURLRef		soundFileURLRef;
            SystemSoundID	soundFileObject;
            
            // Get the main bundle for the app
            CFBundleRef mainBundle = CFBundleGetMainBundle();
            
            // Get the URL to the sound file to play
            soundFileURLRef = CFBundleCopyResourceURL( mainBundle, CFSTR ("bicycle-bell-normalized"), CFSTR ("aiff"), NULL );
            
            if (speedCheck < 3.0){
                
                
                UIApplication *ORcycle = [UIApplication sharedApplication];
                if ([ORcycle applicationState] == UIApplicationStateBackground){
                    UILocalNotification *slow = [[UILocalNotification alloc] init];
                    slow.alertBody = @"Are you still bicycling? If not, please stop recording the trip. Thanks!";
                    slow.soundName = @"bicycle-bell-normalized.aiff";
                    [ORcycle presentLocalNotificationNow:slow];
                    [slow release];
                }
                else{
                    // Create a system sound object representing the sound file
                    AudioServicesCreateSystemSoundID( soundFileURLRef, &soundFileObject );
                    
                    // play audio + vibrate
                    AudioServicesPlayAlertSound( soundFileObject );
                    
                    if (self.speedNoteUp== false){
                        UIAlertView *slow = [[UIAlertView alloc]
                                             initWithTitle:@"Slow Speed"
                                             message:@"You are going slower than 3 mph, if you are not biking anymore please stop recording the trip. Thanks!"
                                             delegate:self
                                             cancelButtonTitle:@"Okay"
                                             otherButtonTitles:nil];
                        [slow show];
                        self.speedNoteUp = true;
                    }
                }
                
            }
            else if (speedCheck > 20.0){
                UIApplication *ORcycle = [UIApplication sharedApplication];
                if ([ORcycle applicationState] == UIApplicationStateBackground){
                    UILocalNotification *slow = [[UILocalNotification alloc] init];
                    slow.alertBody = @"Are you still bicycling? If not, please stop recording the trip. Thanks!";
                    slow.soundName = @"bicycle-bell-normalized.aiff";
                    [ORcycle presentLocalNotificationNow:slow];
                    [slow release];
                }
                else{
                    // Create a system sound object representing the sound file
                    AudioServicesCreateSystemSoundID( soundFileURLRef, &soundFileObject );
                    
                    // play audio + vibrate
                    AudioServicesPlayAlertSound( soundFileObject );
                    
                    if (self.speedNoteUp== false){
                        UIAlertView *slow = [[UIAlertView alloc]
                                             initWithTitle:@"Fast Speed"
                                             message:@"You are going faster than 20 mph, if you are not biking anymore please stop recording the trip. Thanks!"
                                             delegate:self
                                             cancelButtonTitle:@"Okay"
                                             otherButtonTitles:nil];
                        [slow show];
                        self.speedNoteUp = true;
                    }
                }
            }
            timeSpeedCheck = 0.0;
            distSpeedCheck = 0.0;
        }
    }
    else{
        speedCounter.text = @"0.0";
    }
}



- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"locationManager didFailWithError: %@", error );
}


#pragma mark MKMapViewDelegate methods

- (void)initTripManager:(TripManager*)manager
{
	manager.dirty			= YES;
	self.tripManager		= manager;
    manager.parent          = self;
}


- (void)initNoteManager:(NoteManager*)manager
{
	self.noteManager = manager;
    manager.parent = self;
}


- (BOOL)hasUserInfoBeenSaved
{
	BOOL					response = NO;
	NSManagedObjectContext	*context = tripManager.managedObjectContext;
	NSFetchRequest			*request = [[NSFetchRequest alloc] init];
	NSEntityDescription		*entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
	[request setEntity:entity];
	
	NSError *error;
	NSInteger count = [context countForFetchRequest:request error:&error];
	//NSLog(@"saved user count  = %d", count);
	if ( count )
	{	
		NSArray *fetchResults = [context executeFetchRequest:request error:&error];
		if ( fetchResults != nil )
		{
			User *user = (User*)[fetchResults objectAtIndex:0];
            NSInteger numFields = 0;
            NSLog(@"user.age = %@", user.age);
            if ([user.cyclingFreq integerValue]!= 0){
                numFields = numFields + 1;
            }
            if ([user.cyclingWeather integerValue] != 0){
                numFields = numFields + 1;
            }
            if ([user.riderAbility integerValue]!= 0) {
                numFields = numFields + 1;
            }
            if ([user.riderType integerValue]!= 0){
                numFields = numFields + 1;
            }
            if ([user.numBikes integerValue]!= 0){
                numFields = numFields + 1;
            }
            NSMutableArray *bikeTypesTemp = [[user.bikeTypes componentsSeparatedByString:@","] mutableCopy];
            NSMutableArray *bikeTypes = [[NSMutableArray alloc] init];
            for (NSString *s in bikeTypesTemp)
            {
                NSNumber *num = [NSNumber numberWithInt:[s intValue]];
                [bikeTypes addObject:num];
            }
            if([bikeTypes containsObject:[NSNumber numberWithInt:1]]){
                numFields = numFields +1;
            }
			if (numFields >= 6)
            {
				NSLog(@"found saved user info");
				self.userInfoSaved = YES;
				response = YES;
			}
            else{
				NSLog(@"no saved user info");
            }
		}
		else
		{
			// Handle the error.
			NSLog(@"no saved user");
			if ( error != nil )
				NSLog(@"PersonalInfo viewDidLoad fetch error %@, %@", error, [error localizedDescription]);
		}
	}
    else{
		NSLog(@"no saved user");
        response  = YES;
    }
	
	[request release];
	return response;
}


- (void)hasRecordingBeenInterrupted
{
	if ( [tripManager countUnSavedTrips] )
	{        
        [self resetRecordingInProgress];
	}
	else
		NSLog(@"no unsaved trips found");
}

/*
- (void)infoAction:(id)sender
{
	if ( !recording )
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: kInfoURL]];
}
 */


- (void)viewDidLoad
{
    //Keep app from sleeping
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
	NSLog(@"RecordTripViewController viewDidLoad");
    NSLog(@"Bundle ID: %@", [[NSBundle mainBundle] bundleIdentifier]);
    [super viewDidLoad];
	//[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"doneWithTutorial"] != true){
        //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        // Override point for customization after application launch.
        TutorialViewController *tutorialView = [[TutorialViewController alloc] initWithNibName:@"TutorialViewController" bundle:nil];
        //self.window.rootViewController = self.tutorialViewController;
        //[self.window makeKeyAndVisible];
        [tutorialView setTutorialDelegate:self];
        [self.navigationController presentViewController:tutorialView animated:NO completion: ^{
            //[self.tutorialViewController release];
        }];
    }
	
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    //Navigation bar color
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:psuGreen];
    
    self.navigationController.navigationBarHidden = YES;
	
	// init map region to Portland, OR
	MKCoordinateRegion region = { { 44.1419049, -120.5380992}, { 0.0078, 0.0068 } };
	[mapView setRegion:region animated:NO];
	
	// setup info button used when showing recorded trips
	infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	infoButton.showsTouchWhenHighlighted = YES;
	
	// Set up the buttons.
	[self.view addSubview:[self createStartButton]];
    [self.view addSubview:[self createNoteButton]];
    [self.view addSubview:[self createCenterButton]];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, 0.5)];
    topLineView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:topLineView];
    [topLineView release];
    
    if (IS_IPHONE_5){
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 518.5, self.view.bounds.size.width, 0.5)];
        bottomLineView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:bottomLineView];
        [bottomLineView release];

    }
    else{
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 430, self.view.bounds.size.width, 0.5)];
        bottomLineView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:bottomLineView];
        [bottomLineView release];

    }
    
    
    // Start the location manager.
    CLLocationManager *locationManger = [self getLocationManager];
    if ([locationManger respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManger performSelector:@selector(requestAlwaysAuthorization)];
    }
    
    [locationManger startUpdatingLocation];
    
    self.motionManager = [self getMotionManager];
    self.motionManager.accelerometerUpdateInterval = .2;
    
    [self newAccelData];
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self addAccelObs:accelerometerData];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = NO;
	self.recording = NO;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	self.shouldUpdateCounter = NO;
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // setup the noteManager
    [self initNoteManager:[[[NoteManager alloc] initWithManagedObjectContext:context]autorelease]];
    
    /*
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Welcome"]){
        if (self.systemVersion >= 8.0){
            
            UILabel *welcomeLabel		= [[[UILabel alloc] initWithFrame:CGRectMake(10,0,250,90)] autorelease];
            welcomeLabel.font = [UIFont systemFontOfSize:10.7];
            
            welcomeLabel.text = @"This app lets you record bicycle trips, display trip maps, and provide bicycle safety feedback. You can report crashes, near-misses or safety issues from anywhere: home, office, along your trip, etc. by pressing the “Report” button. To record a trip you need to press start/finish buttons before/after your trip.";
            welcomeLabel.textAlignment = NSTextAlignmentJustified;
            welcomeLabel.lineBreakMode = NSLineBreakByWordWrapping;
            welcomeLabel.numberOfLines = 0;
            
            UIView *welcomeView = [[UIView alloc] initWithFrame:CGRectMake(0,0,250,200)];
            
            [welcomeView addSubview:welcomeLabel];
            
            UILabel *checkboxLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 77, 180, 50)];
            checkboxLabel.backgroundColor = [UIColor clearColor];
            checkboxLabel.textColor = [UIColor blackColor];
            checkboxLabel.text = @"Do not show again";
            checkboxLabel.font = [UIFont systemFontOfSize:12.0];
            [welcomeView addSubview:checkboxLabel];
            [checkboxLabel release];
            
            //declared welcomeCheckboxButton in the header due to errors I was getting when referring to the button in the button's method below
            welcomeCheckboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
            welcomeCheckboxButton.frame = CGRectMake(170, 94, 18, 18);
            welcomeCheckboxButton.backgroundColor = [UIColor clearColor];
            UIImage *alertButtonImageNormal = [UIImage imageNamed:@"unchecked_checkbox.png"];
            UIImage *alertButtonImageChecked = [UIImage imageNamed:@"checked_checkbox.png"];
            [welcomeCheckboxButton setImage:alertButtonImageNormal forState:UIControlStateNormal];
            [welcomeCheckboxButton setImage:alertButtonImageChecked forState:UIControlStateSelected];
            [welcomeCheckboxButton addTarget:self action:@selector(welcomeCheckboxButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            
            [welcomeView addSubview: welcomeCheckboxButton];
            
            UIAlertView *welcome = [[UIAlertView alloc]
                                    initWithTitle:@"Welcome to ORcycle!"
                                    message:nil
                                    delegate:self
                                    cancelButtonTitle:@"Continue"
                                    otherButtonTitles:@"Instructions", nil];
            
            [welcome setValue:welcomeView forKey:@"accessoryView"];
            
            [welcome show];
            
        }
        else{
            UILabel *welcomeLabel		= [[[UILabel alloc] initWithFrame:CGRectMake(3,0,250,90)] autorelease];
            welcomeLabel.font = [UIFont systemFontOfSize:10.7];
            welcomeLabel.text = @"This app lets you record bicycle trips, display trip maps, and provide bicycle safety feedback. You can report crashes, near-misses or safety issues from anywhere: home, office, along your trip, etc. by pressing the “Report” button. To record a trip you need to press start/finish buttons before/after your trip.";
            welcomeLabel.lineBreakMode = NSLineBreakByWordWrapping;
            welcomeLabel.numberOfLines = 0;
            
            UIView *welcomeView = [[UIView alloc] initWithFrame:CGRectMake(0,0,250,115)];
            
            [welcomeView addSubview:welcomeLabel];
            
            UILabel *checkboxLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 80, 260, 50)];
            checkboxLabel.backgroundColor = [UIColor clearColor];
            checkboxLabel.textColor = [UIColor blackColor];
            checkboxLabel.text = @"Do not show again";
            checkboxLabel.font = [UIFont systemFontOfSize:12.0];
            [welcomeView addSubview:checkboxLabel];
            [checkboxLabel release];
            
            //declared welcomeCheckboxButton in the header due to errors I was getting when referring to the button in the button's method below
            welcomeCheckboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
            welcomeCheckboxButton.frame = CGRectMake(170, 97, 18, 18);
            welcomeCheckboxButton.backgroundColor = [UIColor clearColor];
            UIImage *alertButtonImageNormal = [UIImage imageNamed:@"unchecked_checkbox.png"];
            UIImage *alertButtonImageChecked = [UIImage imageNamed:@"checked_checkbox.png"];
            [welcomeCheckboxButton setImage:alertButtonImageNormal forState:UIControlStateNormal];
            [welcomeCheckboxButton setImage:alertButtonImageChecked forState:UIControlStateSelected];
            [welcomeCheckboxButton addTarget:self action:@selector(welcomeCheckboxButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            
            [welcomeView addSubview: welcomeCheckboxButton];
            
            UIAlertView *welcome = [[UIAlertView alloc]
                                    initWithTitle:@"Welcome to ORcycle!"
                                    message:nil
                                    delegate:self
                                    cancelButtonTitle:@"Continue"
                                    otherButtonTitles:@"Instructions", nil];
            
            [welcome setValue:welcomeView forKey:@"accessoryView"];
            
            [welcome show];
        }


    }
    
    */
    
    

	// check if any user data has already been saved and pre-select personal info cell accordingly
	if ( [self hasUserInfoBeenSaved] )
		[self setSaved:YES];
    else{
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Tell us more about yourself"
                              message:@"Please answer at least the first six questions about your biking habits on the 'User' screen."
                              delegate:self
                              cancelButtonTitle:@"Later"
                              otherButtonTitles:@"Okay", nil];
        [alert show];
    
    }
    
    //self.slowSpeedsArray = [[NSMutableArray alloc] init];
	
	// check for any unsaved trips / interrupted recordings
	[self hasRecordingBeenInterrupted];
    
	NSLog(@"save");
}

-(void)welcomeCheckboxButtonClicked{
    
    NSLog(@"welcomeCheckbocButtonClicked Method called");
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Welcome"]){
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"Welcome"];
        welcomeCheckboxButton.selected = YES;
    }else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Welcome"];
        welcomeCheckboxButton.selected = NO;
    }
    
}

-(void)tripCheckboxButtonClicked{
    
    NSLog(@"tripCheckboxButtonClicked Method called");
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"TripLogging"]){
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"TripLogging"];
        tripCheckboxButton.selected = YES;
    }else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TripLogging"];
        tripCheckboxButton.selected = NO;
    }
    
}

-(float)systemVersion
{
    NSArray * versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    float total = 0;
    int pot = 0;
    for (NSNumber * number in versionCompatibility)
    {
        total += number.intValue * powf(10, pot);
        pot--;
    }
    return total;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button at index %li clicked",(long)buttonIndex);
    
    if ([alertView.title isEqualToString:@"Tell us more about yourself"]){
        if(buttonIndex == 0){
            alertView.delegate = nil;
            [alertView.delegate release];
        }
        if( buttonIndex == 1 ) /* NO = 0, YES = 1 */
        {
            PersonalInfoViewController *PersonalInfoView = [[PersonalInfoViewController alloc] initWithManagedObjectContext:managedObjectContext] ;
            [PersonalInfoView initWithManagedObjectContext:managedObjectContext];
            [self.navigationController pushViewController:PersonalInfoView animated:YES];
            alertView.delegate = nil;
            [alertView.delegate release];
        }
    }
    else if ([alertView.title isEqualToString:@"Tutorial"]){
        if(buttonIndex == 0){
            alertView.delegate = nil;
            [alertView.delegate release];
        }
        if( buttonIndex == 1 ) /* Yes = 0, No = 1 */
        {
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"doneWithTutorial"];
            alertView.delegate = nil;
            [alertView.delegate release];
        }
    }
    else if([alertView.title isEqualToString:@"Welcome to ORcycle!"]){
        if(buttonIndex == 0){
            alertView.delegate = nil;
            [alertView.delegate release];
        }
        if( buttonIndex == 1 ) /* NO = 0, YES = 1 */
        {
            NSURL *url = [NSURL URLWithString:kInstructionsURL];
            NSURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [[UIApplication sharedApplication] openURL:[request URL]];
            alertView.delegate = nil;
            [alertView.delegate release];
        }

    }
    else if([alertView.title isEqualToString:@"Report Map"]){
        if(buttonIndex == 0){
            alertView.delegate = nil;
            [alertView.delegate release];
        }
        if( buttonIndex == 1 ) /* NO = 0, YES = 1 */
        {
            NSURL *url = [NSURL URLWithString:kReportMapURL];
            NSURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [[UIApplication sharedApplication] openURL:[request URL]];
            alertView.delegate = nil;
            [alertView.delegate release];
        }
        
    }
    else if([alertView.title isEqualToString:@"Slow Speed"]){
        if(buttonIndex == [alertView cancelButtonIndex]){
            self.speedNoteUp = false;
            alertView.delegate = nil;
            [alertView.delegate release];
        }
    }
    else if([alertView.title isEqualToString:@"Fast Speed"]){
        if(buttonIndex == [alertView cancelButtonIndex]){
            self.speedNoteUp = false;
            alertView.delegate = nil;
            [alertView.delegate release];
        }
    }
}



- (UIButton *)createNoteButton
{
    /*
    noteButton.enabled = YES;
    
    [noteButton setTitle:@"Mark Safety" forState:UIControlStateNormal];
    
    noteButton.layer.borderWidth = 1.0f;
    noteButton.layer.borderColor = [[UIColor blackColor]CGColor];
    
     */
    
    if (IS_IPHONE_5) {
        
        noteButton.frame=CGRectMake(118, 130, 84, 40);
        
    }else{
        noteButton.frame=CGRectMake(118, 130, 84, 40);
        
    }
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [noteButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    noteButton.layer.borderWidth = 0.5f;
    [noteButton.layer setCornerRadius:5.0f];
    noteButton.clipsToBounds = YES;
    noteButton.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [noteButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    noteButton.backgroundColor = [UIColor clearColor];
    noteButton.enabled = YES;
    
    [noteButton setTitle:@"Report" forState:UIControlStateNormal];
    [noteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    noteButton.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
    //noteButton.titleLabel.shadowOffset = CGSizeMake (0, 0);
    noteButton.titleLabel.textColor = [UIColor whiteColor];

//    noteButton.titleLabel.font = [UIFont boldSystemFontOfSize: 24];
    [noteButton addTarget:self action:@selector(notethis:) forControlEvents:UIControlEventTouchUpInside];
    
	return noteButton;
    
}


// instantiate start button
- (UIButton *)createStartButton
{
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [startButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    startButton.layer.borderWidth = 0.5f;
    startButton.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [startButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    startButton.backgroundColor = [UIColor clearColor];
    startButton.enabled = YES;
    
    [startButton setTitle:@"Start Trip" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    startButton.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
    [startButton.layer setCornerRadius:5.0f];
    startButton.clipsToBounds = YES;
    startButton.titleLabel.textColor = [UIColor whiteColor];
    [startButton addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    
	return startButton;
}

- (UIButton *)createCenterButton
{
    UIImage *buttonImage = [UIImage imageNamed:@"greyButton.png"];
    UIImage *buttonImageHighlight = [UIImage imageNamed:@"greyButtonHighlight.png"];
    
    
    if (IS_IPHONE_5) {
        
        [centerButton setFrame: CGRectMake(10,82,33,33)];
        
    }else{
        [centerButton setFrame: CGRectMake(10,82,33,33)];
        
    }
    
    
    [centerButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    centerButton.layer.borderWidth = 0.5f;
    centerButton.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [centerButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    centerButton.backgroundColor = [UIColor clearColor];
    centerButton.enabled = YES;
    
    [centerButton.layer setCornerRadius:5.0f];
    centerButton.clipsToBounds = YES;
    [centerButton addTarget:self action:@selector(zoomToGps:) forControlEvents:UIControlEventTouchUpInside];
    
    return centerButton;
}

- (void)zoomToGps:(id)sender{
    MKCoordinateRegion region;
    region.center.latitude = mapView.userLocation.coordinate.latitude;
    region.center.longitude = mapView.userLocation.coordinate.longitude;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.0078; // arbitrary value seems to look OK
    span.longitudeDelta =  0.0068; // arbitrary value seems to look OK
    region.span = span;
    [mapView setRegion:region animated:true];
    
}

- (void)displayUploadedTripMap
{
    Trip *trip = tripManager.trip;
    [self resetRecordingInProgress];
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    
    if ([eventArray count]>0){
        for (int i=0; i<[eventArray count]; i++)
        {
            UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
            NSDictionary *userInfoCurrent = oneEvent.userInfo;
            if ([[userInfoCurrent valueForKey:@"reminderNum"] isEqualToString:@"Three"])
            {
                //Cancelling local notification
                NSLog(@"Found notification %@",oneEvent);
                [app cancelLocalNotification:oneEvent];
            }
        }
    }
    
    NSDate *today = [NSDate date];
    
    //First Reminder
    
    NSDate *dateToFire = [today dateByAddingTimeInterval:3600*24*7*12];
    
    UILocalNotification *remind = [[UILocalNotification alloc] init];
    remind.alertBody = @"You haven't logged a trip in three months. Please return to log another trip!";
    remind.soundName = @"bicycle-bell-normalized.aiff";
    remind.fireDate = dateToFire;
    NSLog(@"Trip reminder firedate =%@", remind.fireDate);
    remind.timeZone = [NSTimeZone defaultTimeZone];
    remind.userInfo = [NSMutableDictionary dictionaryWithObject:@"Three"
                                                         forKey:@"reminderNum"];
    [app scheduleLocalNotification:remind];
    [remind release];
    
    //Second Reminder
    
    NSDate *dateToFireAgain = [today dateByAddingTimeInterval:3600*24*7*13];
    
    UILocalNotification *remindAgain = [[UILocalNotification alloc] init];
    remindAgain.alertBody = @"You haven't logged a trip in three months. Please return to log another trip!";
    remindAgain.soundName = @"bicycle-bell-normalized.aiff";
    remindAgain.fireDate = dateToFireAgain;
    NSLog(@"Trip reminder firedate =%@", remindAgain.fireDate);
    remindAgain.timeZone = [NSTimeZone defaultTimeZone];
    remindAgain.userInfo = [NSMutableDictionary dictionaryWithObject:@"Three"
                                                         forKey:@"reminderNum"];
    [app scheduleLocalNotification:remindAgain];
    [remindAgain release];
    
    // load map view of saved trip
    MapViewController *mvc = [[MapViewController alloc] initWithTrip:trip];
    [[self navigationController] pushViewController:mvc animated:YES];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"TripLogging"]){
        
        
        NSString *tripPurposeString = @"Trip Logged";
        //NSString *tripPurposeShortString1 = @"";
        //NSString *tripPurposeShortString2 = @"";
        
        
        if (![trip.purpose isEqualToString:@"Other"]){
            tripPurposeString = [NSString stringWithFormat:@"%@ Trip Logged", trip.purpose];
            //tripPurposeShortString1 = trip.purpose;
            //tripPurposeShortString2 = trip.purpose;
        }
        
        //Route Frequency Text
        NSString *routeFreqText = [[NSString alloc]init];
        switch ([trip.routeFreq intValue]) {
            case 0:
                routeFreqText = @"no route frequency indicated";
                break;
            case 1:
                routeFreqText = @"several times per week";
                break;
            case 2:
                routeFreqText = @"several times per month";
                break;
            case 3:
                routeFreqText = @"several times per year";
                break;
            case 4:
                routeFreqText = @"once per year or less";
                break;
            case 5:
                routeFreqText = @"first time ever";
                break;
            default:
                routeFreqText = @"no route frequency indicated";
                break;
        }
        
        NSString *string1 = trip.purpose;
        NSString *string2 = @"optional";
        NSString *string3 = trip.purpose;
        
        NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@ trip logged. To reduce user burden, it is %@ to log frequent (repeated) %@ trips. We will remind you to log a new trip after 3 months without loggings.", string1,string2, string3]];
        
        
        [messageString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(0,messageString.length)];
        
        [messageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:12.0] range:NSMakeRange(0, string1.length)];
        
        [messageString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0] range: NSMakeRange(string1.length+ 43, string2.length)];
        
        [messageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:12.0] range: NSMakeRange(string1.length+ 43 +string2.length + 28, string3.length)];
        
        
        NSLog(@"System verison is equal to %f",self.systemVersion);
        
        if (self.systemVersion >= 8.0){
            
            UILabel *alertLabel		= [[[UILabel alloc] initWithFrame:CGRectMake(10,0,250,100)] autorelease];
            
            alertLabel.attributedText = messageString;
            alertLabel.lineBreakMode = NSLineBreakByWordWrapping;
            alertLabel.numberOfLines = 0;
            
            UIView *tripLogAlertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,250)];
            
            [tripLogAlertView addSubview:alertLabel];
            
            UILabel *checkboxLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 80, 260, 50)];
            checkboxLabel.backgroundColor = [UIColor clearColor];
            checkboxLabel.textColor = [UIColor blackColor];
            checkboxLabel.text = @"Do not show again";
            checkboxLabel.font = [UIFont systemFontOfSize:12.0];
            [tripLogAlertView addSubview:checkboxLabel];
            [checkboxLabel release];
            
            //declared tripCheckboxButton in the header due to errors I was getting when referring to the button in the button's method below
            tripCheckboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
            tripCheckboxButton.frame = CGRectMake(180, 97, 18, 18);
            tripCheckboxButton.backgroundColor = [UIColor clearColor];
            UIImage *alertButtonImageNormal = [UIImage imageNamed:@"unchecked_checkbox.png"];
            UIImage *alertButtonImageChecked = [UIImage imageNamed:@"checked_checkbox.png"];
            [tripCheckboxButton setImage:alertButtonImageNormal forState:UIControlStateNormal];
            [tripCheckboxButton setImage:alertButtonImageChecked forState:UIControlStateSelected];
            [tripCheckboxButton addTarget:self action:@selector(tripCheckboxButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            
            [tripLogAlertView addSubview: tripCheckboxButton];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:tripPurposeString
                                  message:nil
                                  delegate:nil
                                  cancelButtonTitle:@"Okay"
                                  otherButtonTitles:nil];
            
            [alert setValue:tripLogAlertView forKey:@"accessoryView"];
            
            [alert show];
            
        }
        else{
            UILabel *alertLabel		= [[[UILabel alloc] initWithFrame:CGRectMake(0,0,200,130)] autorelease];
            
            alertLabel.attributedText = messageString;
            alertLabel.lineBreakMode = NSLineBreakByWordWrapping;
            alertLabel.numberOfLines = 0;
            
            UIView *tripLogAlertView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,150)];
            
            [tripLogAlertView addSubview:alertLabel];
            
            UILabel *checkboxLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 110, 260, 50)];
            checkboxLabel.backgroundColor = [UIColor clearColor];
            checkboxLabel.textColor = [UIColor blackColor];
            checkboxLabel.text = @"Do not show again";
            checkboxLabel.font = [UIFont systemFontOfSize:12.0];
            [tripLogAlertView addSubview:checkboxLabel];
            [checkboxLabel release];
            
            //declared tripCheckboxButton in the header due to errors I was getting when referring to the button in the button's method below
            tripCheckboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
            tripCheckboxButton.frame = CGRectMake(150, 127, 18, 18);
            tripCheckboxButton.backgroundColor = [UIColor clearColor];
            UIImage *alertButtonImageNormal = [UIImage imageNamed:@"unchecked_checkbox.png"];
            UIImage *alertButtonImageChecked = [UIImage imageNamed:@"checked_checkbox.png"];
            [tripCheckboxButton setImage:alertButtonImageNormal forState:UIControlStateNormal];
            [tripCheckboxButton setImage:alertButtonImageChecked forState:UIControlStateSelected];
            [tripCheckboxButton addTarget:self action:@selector(tripCheckboxButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            
            [tripLogAlertView addSubview: tripCheckboxButton];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:tripPurposeString
                                  message:nil
                                  delegate:nil
                                  cancelButtonTitle:@"Okay"
                                  otherButtonTitles:nil];
            
            [alert setValue:tripLogAlertView forKey:@"accessoryView"];
            
            [alert show];
        }
        
    }

    
    
    NSLog(@"displayUploadedTripMap");
    [mvc release];
}

- (void)displayUploadedNote
{
    Note *note = noteManager.note;
    
    /*
    
    UIAlertView *reportMap = [[UIAlertView alloc]
                              initWithTitle:@"Report Map"
                              message:@"To see maps with reported safety issues visit the ORcycle webpage."
                              delegate:self
                              cancelButtonTitle:@"Later"
                              otherButtonTitles:@"Now", nil];

    */
    // load map view of note
    NoteViewController *mvc = [[NoteViewController alloc] initWithNote:note];
    [[self navigationController] pushViewController:mvc animated:YES];
    NSLog(@"displayUploadedNote");
    [mvc release];
    //[reportMap show];
}


- (void)resetTimer
{
	// invalidate timer
	if ( timer )
	{
		[timer invalidate];
		//[timer release];
		timer = nil;
	}
}


- (void)resetRecordingInProgress
{
	// reset button states
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = NO;
	recording = NO;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	startButton.enabled = YES;
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [startButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [startButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [startButton.layer setCornerRadius:5.0f];
    startButton.clipsToBounds = YES;
    [startButton setTitle:@"Start Trip" forState:UIControlStateNormal];
     startButton.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
	[startButton setTitleColor:[[UIColor whiteColor ] autorelease] forState:UIControlStateNormal];
    self.iSpeedCheck = false;
    
	// reset trip, reminder managers
	NSManagedObjectContext *context = tripManager.managedObjectContext;
	[self initTripManager:[[[TripManager alloc] initWithManagedObjectContext:context] autorelease]];
	tripManager.dirty = YES;

	[self resetCounter];
	[self resetTimer];
}

- (void)resetRecordingInProgressDelete
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:tripManager.managedObjectContext];
    [request setEntity:entity];
    
    // configure sort order
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
    NSSortDescriptor *sortDescriptorSaved = [[NSSortDescriptor alloc] initWithKey:@"saved" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptorSaved, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    [sortDescriptor release];
    
    NSError *error;
    NSInteger count = [tripManager.managedObjectContext countForFetchRequest:request error:&error];
    NSLog(@"count = %ld", (long)count);
    
    NSMutableArray *mutableFetchResults = [[tripManager.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    NSManagedObject *tripToDelete = [mutableFetchResults objectAtIndex:0];
    
    
    if (tripManager.trip!= nil && tripManager.trip.saved == nil) {
        [noteManager.managedObjectContext deleteObject:tripToDelete];
    }
    
    
    if (![tripManager.managedObjectContext save:&error]) {
        // Handle the error.
        NSLog(@"Unresolved error %@", [error localizedDescription]);
    }
    
    
    // reset button states
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = NO;
    recording = NO;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    startButton.enabled = YES;
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [startButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [startButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [startButton setTitle:@"Start Trip" forState:UIControlStateNormal];
    
    // reset trip, reminder managers
    NSManagedObjectContext *context = tripManager.managedObjectContext;
    [self initTripManager:[[[TripManager alloc] initWithManagedObjectContext:context] autorelease]];
    tripManager.dirty = YES;
    
    [self resetCounter];
    [self resetTimer];
    
}



#pragma mark UIActionSheet delegate methods


// NOTE: implement didDismissWithButtonIndex to process after sheet has been dismissed
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.title isEqualToString:@""]){
        NSLog(@"actionSheet clickedButtonAtIndex %ld", (long)buttonIndex);
        switch ( buttonIndex )
        {
            case 0:
            {
                NSLog(@"Discard!!!!");
                [self.tripManager discardTrip];
                [self resetRecordingInProgress];
                //discard that trip
                break;
            }
            case 1:{
                [self save];
                break;
            }
            default:{
                NSLog(@"Cancel");
                // re-enable counter updates
                shouldUpdateCounter = YES;
                break;
            }
        }

    }
    else if ([actionSheet.title isEqualToString:@"Report Type"]){
        switch ( buttonIndex )
        {
            case 0:
            {
                NSLog(@"Crash or near-miss");
                //[self resetRecordingInProgress];
                //discard that trip
                //[noteManager createNote];
                
                if (myLocation){
                    [noteManager addLocation:myLocation];
                }
                
                // go directly to TripPurpose, user can cancel from there
                if ( YES )
                {
                    // Trip Purpose
                    NSLog(@"INIT + PUSH");
                    
                    
                    CrashDetailViewController *crashDetailView = [[CrashDetailViewController alloc]
                                                                //initWithPurpose:[tripManager getPurposeIndex]];
                                                                initWithNibName:@"CrashDetailViewController" bundle:nil];
                    [crashDetailView setNoteDelegate:self];
                    //[[self navigationController] pushViewController:pickerViewController animated:YES];
                    [self.navigationController presentViewController:crashDetailView animated:YES completion:nil];
                    
                    //add location information
                    
                    [crashDetailView release];
                }
                break;
            }
            case 1:{
                NSLog(@"Safety Issue");
                //[noteManager createNote];
                
                if (myLocation){
                    [noteManager addLocation:myLocation];
                }
                
                // go directly to TripPurpose, user can cancel from there
                if ( YES )
                {
                    // Trip Purpose
                    NSLog(@"INIT + PUSH");
                    
                    
                    NoteDetailViewController *noteDetailView = [[NoteDetailViewController alloc]
                                                                //initWithPurpose:[tripManager getPurposeIndex]];
                                                                initWithNibName:@"NoteDetailViewController" bundle:nil];
                    [noteDetailView setNoteDelegate:self];
                    //[[self navigationController] pushViewController:pickerViewController animated:YES];
                    [self.navigationController presentViewController:noteDetailView animated:YES completion:nil];
                    
                    //add location information
                    
                    [noteDetailView release];
                }

                break;
            }
            default:{
                NSLog(@"Cancel");
                break;
            }
        }
    }
}



// called if the system cancels the action sheet (e.g. homescreen button has been pressed)
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	NSLog(@"actionSheetCancel");
}


#pragma mark UIAlertViewDelegate methods


// NOTE: method called upon closing save error / success alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  
        switch (alertView.tag) {
            case 101:
            {
                NSLog(@"recording interrupted didDismissWithButtonIndex: %ld", (long)buttonIndex);
                switch (buttonIndex) {
                    case 0:
                        // new trip => do nothing
                        break;
                    case 1:
                    default:
                        // continue => load most recent unsaved trip
                        [tripManager loadMostRecetUnSavedTrip];
                        
                        // update UI to reflect trip once loading has completed
                        [self setCounterTimeSince:tripManager.trip.start
                                         distance:[tripManager getDistanceEstimate]];
                        
                        startButton.enabled = YES;
                        
                        [startButton setTitle:@"Continue" forState:UIControlStateNormal];
                        break;
                }
            }
                break;
                /*
            default:
            {
                NSLog(@"saving didDismissWithButtonIndex: %ld", (long)buttonIndex);
                
                // keep a pointer to our trip to pass to map view below
                Trip *trip = tripManager.trip;
                [self resetRecordingInProgress];
                
                // load map view of saved trip
                MapViewController *mvc = [[MapViewController alloc] initWithTrip:trip];
                [[self navigationController] pushViewController:mvc animated:YES];
                [mvc release];
            }
                break;
                 */
        }
	
}


- (NSDictionary *)newTripTimerUserInfo
{
    return [[NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"StartDate",
			tripManager, @"TripManager", nil ] retain ];
}


//- (NSDictionary *)continueTripTimerUserInfo
//{
//	if ( tripManager.trip && tripManager.trip.start )
//		return [NSDictionary dictionaryWithObjectsAndKeys:tripManager.trip.start, @"StartDate",
//				tripManager, @"TripManager", nil ];
//	else {
//		NSLog(@"WARNING: tried to continue trip timer but failed to get trip.start date");
//		return [self newTripTimerUserInfo];
//	}
//	
//}


// handle start button action
- (IBAction)start:(UIButton *)sender
{
    
    if(recording == NO)
    {
        NSLog(@"start");
        
        // start the timer if needed
        if ( timer == nil )
        {
			[self resetCounter];
			timer = [NSTimer scheduledTimerWithTimeInterval:kCounterTimeInterval
													 target:self selector:@selector(updateCounter:)
												   userInfo:[self newTripTimerUserInfo] repeats:YES];
        }
        
        UIImage *buttonImage = [[UIImage imageNamed:@"redButton.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        UIImage *buttonImageHighlight = [[UIImage imageNamed:@"redButtonHighlight.png"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];

        [startButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [startButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [startButton setTitleColor:plainWhite forState:UIControlStateNormal];
        [startButton setTitle:@"Finish" forState:UIControlStateNormal];
        [startButton.layer setCornerRadius:5.0f];
        startButton.clipsToBounds = YES;
        startButton.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
        
        // set recording flag so future location updates will be added as coords
        appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.isRecording = YES;
        recording = YES;
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey: @"recording"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // set flag to update counter
        shouldUpdateCounter = YES;
    }
    // do the saving
    else
    {
        NSLog(@"User Press Save Button");
        saveActionSheet = [[UIActionSheet alloc]
                           initWithTitle:@""
                           delegate:self
                           cancelButtonTitle:@"Continue"
                           destructiveButtonTitle:@"Discard"
                           otherButtonTitles:@"Save",nil];
        //[saveActionSheet showInView:self.view];
        [saveActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
	
}
- (void)save
{
    if ([tripManager.coords count] >=1){
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // go directly to TripPurpose, user can cancel from there
        if ( YES )
        {
            /*
             //Trip Information
             NSLog(@"INIT + PUSH");
             TripInfoViewController *tripInfoVC = [[TripInfoViewController alloc]
             initWithNibName: @"TripInfoViewController" bundle: nil];
             [tripInfoVC setDelegate: self];
             [self.navigationController presentViewController: tripInfoVC animated: YES completion: nil];
             [tripInfoVC release];
             */
            
            
            // Trip Purpose
            NSLog(@"INIT + PUSH");
            PickerViewController *tripPurposePickerView = [[PickerViewController alloc]
                                                           //initWithPurpose:[tripManager getPurposeIndex]];
                                                           initWithNibName:@"TripPurposePicker" bundle:nil];
            [tripPurposePickerView setDelegate:self];
            //[[self navigationController] pushViewController:pickerViewController animated:YES];
            [self.navigationController presentViewController:tripPurposePickerView animated:YES completion:nil];
            [tripPurposePickerView release];
            
        }
        
        // prompt to confirm first
        else
        {
            // pause updating the counter
            shouldUpdateCounter = NO;
            
            // construct purpose confirmation string
            NSString *purpose = nil;
            if ( tripManager != nil )
                purpose = [self getPurposeString:[tripManager getPurposeIndex]];
            
            NSString *confirm = [NSString stringWithFormat:@"Stop recording & save this trip?"];
            
            // present action sheet
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:confirm
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Save", nil];
            
            actionSheet.actionSheetStyle		= UIActionSheetStyleBlackTranslucent;
            UIViewController *pvc = self.parentViewController;
            UITabBarController *tbc = (UITabBarController *)pvc.parentViewController;
            
            [actionSheet showFromTabBar:tbc.tabBar];
            [actionSheet release];
        }
 
    }
    else{
        UIAlertView *noGPS = [[UIAlertView alloc]
                              initWithTitle:@"Not enough GPS points"
                              message:@"This trip is very short or you do not have a sufficient GPS signal. Please try recording a trip again."
                              delegate:self
                              cancelButtonTitle:@"Okay"
                              otherButtonTitles:nil];
        [noGPS show];
        [noGPS release];
        [self resetRecordingInProgress];

    }
    
}


-(IBAction)notethis:(id)sender{
    /*
    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
     */
    
    
    UIActionSheet *reportType = [[UIActionSheet alloc] initWithTitle:@"Report Type"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Report crash or near-miss", @"Report safety issue", nil];
    
    reportType.actionSheetStyle		= UIActionSheetStyleBlackTranslucent;
    UIViewController *pvc = self.parentViewController;
    UITabBarController *tbc = (UITabBarController *)pvc.parentViewController;
    
    [reportType showFromTabBar:tbc.tabBar];
    [reportType release];
    
    
    NSLog(@"Note This");
    
}
/*
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet;
{
    UILabel *sheetTitleLabel;
    NSMutableAttributedString *reportTitle = [[NSMutableAttributedString alloc] initWithString:@"Report Type"];
    [reportTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0,reportTitle.length)];

    if([actionSheet respondsToSelector:@selector(_titleLabel)] && [actionSheet.title isEqualToString: @"Report Type"]) {
        sheetTitleLabel = objc_msgSend(actionSheet, @selector(_titleLabel));
        sheetTitleLabel.attributedText = reportTitle;
        
    }
}
 */


- (void)resetCounter
{
	if ( timeCounter != nil )
		timeCounter.text = @"00:00:00";
	
	if ( distCounter != nil )
		distCounter.text = @"0.0";
    
    if ( calorieCount != nil)
        calorieCount.text = @"0.0";
    
    if ( C02Count != nil)
        C02Count.text = @"0.0";
}


- (void)setCounterTimeSince:(NSDate *)startDate distance:(CLLocationDistance)distance
{
	if ( timeCounter != nil )
	{
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
		
		static NSDateFormatter *inputFormatter = nil;
		if ( inputFormatter == nil )
			inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
		
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *outputDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:fauxDate] autorelease];
		
		timeCounter.text = [inputFormatter stringFromDate:outputDate];
	}
	
	if ( distCounter != nil )
		distCounter.text = [NSString stringWithFormat:@"%.1f", distance / 1609.344];
;
}


// handle start button action
- (void)updateCounter:(NSTimer *)theTimer
{
	//NSLog(@"updateCounter");
	if ( shouldUpdateCounter )
	{
		NSDate *startDate = [[theTimer userInfo] objectForKey:@"StartDate"];
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];

		static NSDateFormatter *inputFormatter = nil;
		if ( inputFormatter == nil )
			inputFormatter = [[NSDateFormatter alloc] init];
		
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *outputDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:fauxDate] autorelease];
		
		//NSLog(@"Timer started on %@", startDate);
		//NSLog(@"Timer started %f seconds ago", interval);
		//NSLog(@"elapsed time: %@", [inputFormatter stringFromDate:outputDate] );
		
		//self.timeCounter.text = [NSString stringWithFormat:@"%.1f sec", interval];
		self.timeCounter.text = [inputFormatter stringFromDate:outputDate];
	}

}


- (void)viewWillAppear:(BOOL)animated 
{
    // listen for keyboard hide/show notifications so we can properly adjust the table's height
	[super viewWillAppear:animated];
    self.navigationController.delegate = self;
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}



- (void)keyboardWillShow:(NSNotification *)aNotification
{
	NSLog(@"keyboardWillShow");
}


- (void)keyboardWillHide:(NSNotification *)aNotification
{
	NSLog(@"keyboardWillHide");
}


- (NSString *)updatePurposeWithString:(NSString *)purpose
{	
	// only enable start button if we don't already have a pending trip
	if ( timer == nil )
		startButton.enabled = YES;
	
	startButton.hidden = NO;
	
	return purpose;
}


- (NSString *)updatePurposeWithIndex:(unsigned int)index
{
	return [self updatePurposeWithString:[tripManager getPurposeString:index]];
}


#pragma mark UINavigationController


- (void)navigationController:(UINavigationController *)navigationController 
	   willShowViewController:(UIViewController *)viewController 
					animated:(BOOL)animated
{
	if ( viewController == self )
	{
		//NSLog(@"willShowViewController:self");
		self.title = @"Record";
	}
	else
	{
		//NSLog(@"willShowViewController:else");
		self.title = @"Record";
		self.tabBarItem.title = @"Record"; // important to maintain the same tab item title
	}
}


#pragma mark UITabBarControllerDelegate


- (BOOL)tabBarController:(UITabBarController *)tabBarController 
shouldSelectViewController:(UIViewController *)viewController
{
		return YES;		
}


#pragma mark PersonalInfoDelegate methods


- (void)setSaved:(BOOL)value
{
	NSLog(@"setSaved");
	// no-op

}

#pragma mark TripInfoDelegate methods
- (void)popController
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark TripPurposeDelegate methods


- (NSString *)setPurpose:(unsigned int)index
{
	NSString *purpose = [tripManager setPurpose:index];
	NSLog(@"setPurpose: %@", purpose);

	//[self.navigationController popViewControllerAnimated:YES];
	
	return [self updatePurposeWithString:purpose];
}


- (NSString *)getPurposeString:(unsigned int)index
{
	return [tripManager getPurposeString:index];
}


- (void)didCancelPurpose
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = YES;
	recording = YES;
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	shouldUpdateCounter = YES;
}

-(void)didFinishTutorial
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    UIAlertView *tutorial = [[UIAlertView alloc]
                         initWithTitle:@"Tutorial"
                         message:@"You can turn the tutorial on/off in the user screen. Do you want to see the tutorial next time you open ORcycle?"
                         delegate:self
                         cancelButtonTitle:@"Yes"
                         otherButtonTitles:@"No",nil];
    [tutorial show];
    [tutorial release];

}

- (void)didCancelNote
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    appDelegate = [[UIApplication sharedApplication] delegate];
}

- (void)didCancelNoteDelete
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:noteManager.managedObjectContext];
    [request setEntity:entity];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"note_type",@"recorded",nil]];
    
    // configure sort order
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recorded" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    [sortDescriptor release];
    
    NSError *error;
    NSInteger count = [noteManager.managedObjectContext countForFetchRequest:request error:&error];
    NSLog(@"count = %ld", (long)count);
    
    NSMutableArray *mutableFetchResults = [[noteManager.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    
    NSManagedObject *noteToDelete = [mutableFetchResults objectAtIndex:0];
    [noteManager.managedObjectContext deleteObject:noteToDelete];
    
    if (![noteManager.managedObjectContext save:&error]) {
        // Handle the error.
        NSLog(@"Unresolved error %@", [error localizedDescription]);
    }
    
}


- (void)didPickPurpose:(unsigned int)index
{
	//[self.navigationController dismissModalViewControllerAnimated:YES];
	// update UI
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = NO;
	recording = NO;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	startButton.enabled = YES;
	[self resetTimer];
	
	[tripManager setPurpose:index];
	//[tripManager promptForTripNotes];
    //do something here: may change to be the save as a separate view. Not prompt.
}

- (void)didEnterTripDetails:(NSString *)details{
    [tripManager saveNotes:details];
    NSLog(@"Trip Added details: %@",details);
}

- (void)didEnterTripPurposeOther:(NSString *)purposeOther{
    [tripManager.trip setPurposeOther:purposeOther];
    NSLog(@"Saved other trip purpose: %@",purposeOther);
}

- (void) didEnterOtherRoutePrefs:(NSString *)otherRoutePrefsString{
    [tripManager.trip setOtherRoutePrefs:otherRoutePrefsString];
    NSLog(@"Saved other route prefs: %@",otherRoutePrefsString);
}

- (void) didEnterOtherRouteStressors:(NSString *)otherRouteStressorsString{
    [tripManager.trip setOtherRouteStressors:otherRouteStressorsString];
    NSLog(@"Saved other route prefs: %@",otherRouteStressorsString);
}

- (void)didPickRouteFreq:(NSNumber *)index
{
    [tripManager.trip setRouteFreq:index];
    NSLog(@"Added Route Freq: %d", [tripManager.trip.routeFreq intValue]);
}

- (void)didPickRoutePrefs:(NSString *) routePrefsString
{
    [tripManager.trip setRoutePrefs: routePrefsString];
    NSLog(@"Added Route Prefs: %@", tripManager.trip.routePrefs);
}
- (void)didPickRouteComfort:(NSNumber *)index
{
    [tripManager.trip setRouteComfort:index];
    NSLog(@"Added Route Comfort: %d", [tripManager.trip.routeComfort intValue]);
}

- (void)didPickRouteStressors:(NSString *) routeStressorsString
{
    [tripManager.trip setRouteStressors: routeStressorsString];
    NSLog(@"Added Route Stressors: %@", tripManager.trip.routeStressors);
}


- (void)saveTrip{
    [tripManager saveTrip];
    NSLog(@"Save trip");
}

- (void)didPickIsCrash:(BOOL *)boolean
{
    [noteManager.note setIsCrash:boolean];
    NSLog(@"Set is crash to: %d", noteManager.note.isCrash);
    //do something here: may change to be the save as a separate view. Not prompt.
}

- (void)didPickNoteType:(NSNumber *)index
{	
	[noteManager.note setNote_type:index];
    NSLog(@"Added note type: %d", [noteManager.note.note_type intValue]);
    //do something here: may change to be the save as a separate view. Not prompt.
}

- (void)didPickUrgency:(NSNumber *)index
{
    [noteManager.note setUrgency:index];
    NSLog(@"Added urgency: %d", [noteManager.note.urgency intValue]);
    //do something here: may change to be the save as a separate view. Not prompt.
}

- (void)didPickConflictWith:(NSString *) conflictWithString
{
    [noteManager.note setConflictWith: conflictWithString];
    NSLog(@"Added Conflict With: %@", noteManager.note.conflictWith);
}

- (void)didPickCrashActions:(NSString *) crashActionsString
{
    [noteManager.note setCrashActions: crashActionsString];
    NSLog(@"Added Crash Actions: %@", noteManager.note.crashActions);
}

- (void)didPickCrashReasons:(NSString *) crashReasonsString
{
    [noteManager.note setCrashReasons: crashReasonsString];
    NSLog(@"Added Crash Reasons: %@", noteManager.note.crashReasons);
}

- (void)didPickIssueType:(NSString *) issueTypeString
{
    [noteManager.note setIssueType: issueTypeString];
    NSLog(@"Added Issue Type: %@", noteManager.note.issueType);
}

- (void) didEnterOtherConflictWith:(NSString *)otherConflictWithString{
    [noteManager.note setOtherConflictWith:otherConflictWithString];
    NSLog(@"Saved other conflict with: %@",otherConflictWithString);
}

- (void) didEnterOtherIssueType:(NSString *)otherIssueTypeString{
    [noteManager.note setOtherIssueType:otherIssueTypeString];
    NSLog(@"Saved other issue type: %@",otherIssueTypeString);
}

- (void) didEnterOtherCrashActions:(NSString *)otherCrashActionsString{
    [noteManager.note setOtherCrashActions:otherCrashActionsString];
    NSLog(@"Saved other crash actions: %@",otherCrashActionsString);
}

- (void) didEnterOtherCrashReasons:(NSString *)otherCrashReasonsString{
    [noteManager.note setOtherCrashReasons:otherCrashReasonsString];
    NSLog(@"Saved other crash reasons: %@",otherCrashReasonsString);
}

-(BOOL) noteLocExists{
    if (noteManager.note.latitude != NULL && noteManager.note.longitude !=NULL){
        return TRUE;
    }else{
        return false;
    }
}

- (void) saveCustomLocation:(CLLocation *)customLocation{
    [noteManager.note setAltitude:[NSNumber numberWithDouble:0]];
    NSLog(@"Altitude: %f", [noteManager.note.altitude doubleValue]);
    
    [noteManager.note setLatitude:[NSNumber numberWithDouble:customLocation.coordinate.latitude]];
    NSLog(@"Latitude: %f", [noteManager.note.latitude doubleValue]);
    
    [noteManager.note setLongitude:[NSNumber numberWithDouble:customLocation.coordinate.longitude]];
    NSLog(@"Longitude: %f", [noteManager.note.longitude doubleValue]);
    
    [noteManager.note setSpeed:[NSNumber numberWithDouble:0]];
    NSLog(@"Speed: %f", [noteManager.note.speed doubleValue]);
    
    [noteManager.note setHAccuracy:[NSNumber numberWithDouble:-1]];
    NSLog(@"HAccuracy: %f", [noteManager.note.hAccuracy doubleValue]);
    
    [noteManager.note setVAccuracy:[NSNumber numberWithDouble:-1]];
    NSLog(@"VAccuracy: %f", [noteManager.note.vAccuracy doubleValue]);
}

- (void) revertGPSLocation{
    [noteManager.note setAltitude:[NSNumber numberWithDouble:myLocation.altitude]];
    NSLog(@"Altitude: %f", [noteManager.note.altitude doubleValue]);
    
    [noteManager.note setLatitude:[NSNumber numberWithDouble:myLocation.coordinate.latitude]];
    NSLog(@"Latitude: %f", [noteManager.note.latitude doubleValue]);
    
    [noteManager.note setLongitude:[NSNumber numberWithDouble:myLocation.coordinate.longitude]];
    NSLog(@"Longitude: %f", [noteManager.note.longitude doubleValue]);
    
    [noteManager.note setSpeed:[NSNumber numberWithDouble:myLocation.speed]];
    NSLog(@"Speed: %f", [noteManager.note.speed doubleValue]);
    
    [noteManager.note setHAccuracy:[NSNumber numberWithDouble:myLocation.horizontalAccuracy]];
    NSLog(@"HAccuracy: %f", [noteManager.note.hAccuracy doubleValue]);
    
    [noteManager.note setVAccuracy:[NSNumber numberWithDouble:myLocation.verticalAccuracy]];
    NSLog(@"VAccuracy: %f", [noteManager.note.vAccuracy doubleValue]);
}

-(void) didPickReportDate:(NSDate *)date{
    [noteManager.note setReportDate: date];
    NSLog(@"Did pick report date: %@", date);
}


- (void)didEnterNoteDetails:(NSString *)details{
    [noteManager.note setDetails:details];
    NSLog(@"Note Added details: %@", noteManager.note.details);
}

- (void)didSaveImage:(NSData *)imgData{
    [noteManager.note setImage_data:imgData];
    NSLog(@"Added image, Size of Image(bytes):%lu", (unsigned long)[imgData length]);
    //[imgData release];
}

- (void)didSaveImgLat:(NSNumber *)imgLat{
    [noteManager.note setImageLatitude:imgLat];
    NSLog(@"Added image with latitude =%@", imgLat);
    //[imgData release];
}

- (void)didSaveImgLong:(NSNumber *)imgLong{
    [noteManager.note setImageLongitude:imgLong];
    NSLog(@"Added image with longitude =%@", imgLong);
    //[imgData release];
}

- (void)getTripThumbnail:(NSData *)imgData{
    [tripManager.trip setThumbnail:imgData];
    NSLog(@"Trip Thumbnail, Size of Image(bytes):%lu", (unsigned long)[imgData length]);
}

- (void)getNoteThumbnail:(NSData *)imgData{
    [noteManager.note setThumbnail:imgData];
    NSLog(@"Note Thumbnail, Size of Image(bytes):%lu", (unsigned long)[imgData length]);
}

- (void)openDetailPage{
    
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        appDelegate = [[UIApplication sharedApplication] delegate];
        
        DetailViewController *DetailView = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        
        [self.navigationController presentViewController:DetailView animated:true completion:nil ];
        
        [DetailView setNoteDelegate:self];
        
        [DetailView release];
        
    }];
}

- (void)backOut{
    NSLog(@"Back out from Note Detail");
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveNote{
    [noteManager promptEmail];
    NSLog(@"Save note");
}

#pragma mark RecordingInProgressDelegate method


- (Trip *)getRecordingInProgress
{
	if ( recording )
		return tripManager.trip;
	else
		return nil;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    
    appDelegate = nil;
    self.startButton = nil;
    self.infoButton = nil;
    self.saveButton = nil;
    self.noteButton = nil;
    self.centerButton = nil;
    self.timeCounter = nil;
    self.distCounter = nil;
    self.saveActionSheet = nil;
    self.timer = nil;
    self.parentView = nil;
    self.recording = nil;
    self.shouldUpdateCounter = nil;
    self.userInfoSaved = nil;
    self.tripManager = nil;
    self.noteManager = nil;
    self.appDelegate = nil;
    
    [appDelegate release];
    [infoButton release];
    [saveButton release];
    [startButton release];
    [noteButton release];
    [centerButton release];
    [timeCounter release];
    [distCounter release];
    [speedCounter release];
    [saveActionSheet release];
    [timer release];
    [opacityMask release];
    [parentView release];
    [tripManager release];
    [noteManager release];
    [myLocation release];
    
    [managedObjectContext release];
    [mapView release];
    
    [calorieCount release];
    [C02Count release];
    
    [super dealloc];
}

@end