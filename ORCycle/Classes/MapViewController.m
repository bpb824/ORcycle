/**ORcycle, Copyright 2014, PSU Transportation, Technology, and People Lab
 *
 * @author Bryan.Blanc <bryanpblanc@gmail.com>
 * For more info on the project, go to http://www.pdx.edu/transportation-lab/orcycle
 *
 * Updated/modified for Oregon Department of Transportation app deployment. Based on the CycleTracks codebase for SFCTA
 * Cycle Atlanta, and RenoTracks.
 *
** Reno Tracks, Copyright 2012, 2013 Hack4Reno
 *
 *   @author Brad.Hellyar <bradhellyar@gmail.com>
 *
 *   Updated/Modified for Reno, Nevada app deployment. Based on the
 *   CycleTracks codebase for SFCTA, and the Atlanta Cycle app repo.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
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
//  MapViewController.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/28/09.
//	For more information on the project,
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "Coord.h"
#import "LoadingView.h"
#import "MapCoord.h"
#import "MapViewController.h"
#import "Trip.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "constants.h"

#define kFudgeFactor	1.5
#define kInfoViewAlpha	0.8
#define kMinLatDelta	0.0039
#define kMinLonDelta	0.0034


@implementation MapViewController

@synthesize doneButton, flipButton, infoView, trip, routeLine, alertCheckboxButton;
@synthesize delegate;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

- (id)initWithTrip:(Trip *)_trip
{
    //if (self = [super init]) {
	if (self = [super initWithNibName:@"MapViewController" bundle:nil]) {
		NSLog(@"MapViewController initWithTrip");
		self.trip = _trip;
		mapView.delegate = self;
    }
    return self;
}


/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)infoAction:(UIButton*)sender
{
	NSLog(@"infoAction");
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	
	[UIView setAnimationTransition:([infoView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.view cache:YES];
	
	if ([infoView superview])
		[infoView removeFromSuperview];
	else
		[self.view addSubview:infoView];
	
	[UIView commitAnimations];
	
	// adjust our done/info buttons accordingly
	if ([infoView superview] == self.view)
		self.navigationItem.rightBarButtonItem = doneButton;
    
	else
		self.navigationItem.rightBarButtonItem = flipButton;
}


- (void)initInfoView
{
    
    // format date as a string
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    
    // display trip duration
    static NSDateFormatter *inputFormatter = nil;
    if ( inputFormatter == nil )
        inputFormatter = [[NSDateFormatter alloc] init];
    
    [inputFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
    [inputFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *outputDate = [[[NSDate alloc] initWithTimeInterval:(NSTimeInterval)[trip.duration doubleValue] sinceDate:fauxDate] autorelease];
    
    //Average Speed
    double mph = ( [trip.distance doubleValue] / 1609.344 ) / ( [trip.duration doubleValue] / 3600. );
    
    /*
    //Calory text
    double calory = 49 * [trip.distance doubleValue] / 1609.344 - 1.69;
    NSString *Calorytext = [NSString stringWithFormat:@"kcal"];
    if (calory <= 0) {
        Calorytext = [NSString stringWithFormat:@"0 kcal"];
    }
    else{
        Calorytext = [NSString stringWithFormat:@"%.1f kcal", calory];
    }
    
    //CO2 text
    NSString *CO2Text = [NSString stringWithFormat:@"%.1f lbs", 0.93 * [trip.distance doubleValue] / 1609.344];
     */
    
    //Route Frequency Text
    NSString *routeFreqString = [[NSString alloc]init];
    switch ([trip.routeFreq intValue]) {
        case 0:
            routeFreqString = @"No route frequency indicated";
            break;
        case 1:
            routeFreqString = @"Several times per week";
            break;
        case 2:
            routeFreqString = @"Several times per month";
            break;
        case 3:
            routeFreqString = @"Several times per year";
            break;
        case 4:
            routeFreqString = @"Once per year or less";
            break;
        case 5:
            routeFreqString = @"First time ever";
            break;
        default:
            routeFreqString = @"No route frequency indicated";
            break;
    }
    
    //Route Prefs text
    NSMutableArray *routePrefsTemp = [[trip.routePrefs componentsSeparatedByString:@","] mutableCopy];
    
    NSMutableString *routePrefsString = [[NSMutableString alloc]init];
    
    if([routePrefsTemp count] != 0){
        NSMutableArray *routePrefsArray = [[NSMutableArray alloc] init];
        for (NSString *s in routePrefsTemp)
        {
            NSNumber *num = [NSNumber numberWithInt:[s intValue]];
            [routePrefsArray addObject:num];
        }
        
        if ([routePrefsArray[0] integerValue]==1){
            [routePrefsString appendString:@", It is direct/fast"];
        }
        if ([routePrefsArray[1] integerValue]==1){
            [routePrefsString appendString:@", It has good bicycle facilities"];
        }
        if ([routePrefsArray[2] integerValue]==1){
            [routePrefsString appendString:@", It is enjoyable/has nice scenery"];
        }
        if ([routePrefsArray[3] integerValue]==1){
            [routePrefsString appendString:@", It is good for a workout"];
        }
        if ([routePrefsArray[4] integerValue]==1){
            [routePrefsString appendString:@", It has low traffic/low speeds"];
        }
        if ([routePrefsArray[5] integerValue]==1){
            [routePrefsString appendString:@", It has few busy intersections"];
        }
        if ([routePrefsArray[6] integerValue]==1){
            [routePrefsString appendString:@", It has few/easy hills"];
        }
        if ([routePrefsArray[7] integerValue]==1){
            [routePrefsString appendString:@", It has other riders/people"];
        }
        if ([routePrefsArray[8] integerValue]==1){
            [routePrefsString appendString:@", It is good for families/kids"];
        }
        if ([routePrefsArray[9] integerValue]==1){
            [routePrefsString appendString:@", I do not know/have another route"];
        }
        if ([routePrefsArray[10] integerValue]==1){
            [routePrefsString appendString:@", I found it on my phone/online"];
        }
        if ([routePrefsArray[11] integerValue]==1){
            if (trip.otherRoutePrefs.length > 0){
                [routePrefsString appendString:@", Other ("];
                [routePrefsString appendString:trip.otherRoutePrefs];
                [routePrefsString appendString:@")"];
            }
            else{
                [routePrefsString appendString:@", Other"];
            }
        }
        if (routePrefsString.length != 0){
            NSRange range = {0,2};
            [routePrefsString deleteCharactersInRange:range];
        }
    }
    if(routePrefsString.length == 0){
        routePrefsString = [NSMutableString stringWithFormat:@"No route preferences indicated"];
    }
    
    //Route Comfort Text
    NSString *routeComfortString = [[NSString alloc]init];
    switch ([trip.routeComfort intValue]) {
        case 0:
            routeComfortString = @"No route comfort level indicated";
            break;
        case 1:
            routeComfortString = @"Very Good (even for families/children)";
            break;
        case 2:
            routeComfortString = @"Good (for most riders)";
            break;
        case 3:
            routeComfortString = @"Average";
            break;
        case 4:
            routeComfortString = @"Bad (only for confident riders)";
            break;
        case 5:
            routeComfortString = @"Very Bad (unacceptable for most riders)";
            break;
        default:
            routeComfortString = @"No route comfort level indicated";
            break;
    }
    
    //Route Stressors text
    NSMutableArray *routeStressorsTemp = [[trip.routeStressors componentsSeparatedByString:@","] mutableCopy];
    
    NSMutableString *routeStressorsString = [[NSMutableString alloc]init];
    
    if([routeStressorsTemp count] != 0){
        NSMutableArray *routeStressorsArray = [[NSMutableArray alloc] init];
        for (NSString *s in routeStressorsTemp)
        {
            NSNumber *num = [NSNumber numberWithInt:[s intValue]];
            [routeStressorsArray addObject:num];
        }
        
        if ([routeStressorsArray[0] integerValue]==1){
            [routeStressorsString appendString:@", Not concerned"];
        }
        if ([routeStressorsArray[1] integerValue]==1){
            [routeStressorsString appendString:@", Auto traffic"];
        }
        if ([routeStressorsArray[2] integerValue]==1){
            [routeStressorsString appendString:@", Large commercial vehicles (trucks)"];
        }
        if ([routeStressorsArray[3] integerValue]==1){
            [routeStressorsString appendString:@", Public transportation (e.g. buses, light rail)"];
        }
        if ([routeStressorsArray[4] integerValue]==1){
            [routeStressorsString appendString:@", Parked vehicles (being doored)"];
        }
        if ([routeStressorsArray[5] integerValue]==1){
            [routeStressorsString appendString:@", Other cyclists"];
        }
        if ([routeStressorsArray[6] integerValue]==1){
            [routeStressorsString appendString:@", Pedestrians"];
        }
        if ([routeStressorsArray[7] integerValue]==1){
            if (trip.otherRouteStressors.length > 0){
                [routeStressorsString appendString:@", Other ("];
                [routeStressorsString appendString:trip.otherRouteStressors];
                [routeStressorsString appendString:@")"];
            }
            else{
                [routeStressorsString appendString:@", Other"];
            }
        }
        if (routeStressorsString.length != 0){
            NSRange range = {0,2};
            [routeStressorsString deleteCharactersInRange:range];
        }
    }
    if(routeStressorsString.length == 0){
        routeStressorsString = [NSMutableString stringWithFormat:@"No route stressors indicated"];
    }



	infoView					= [[UIView alloc] initWithFrame:CGRectMake(0,0,320,560)];
	infoView.alpha				= kInfoViewAlpha;
	infoView.backgroundColor	= [UIColor grayColor];
	
	UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(115,10,160,25)] autorelease];
	notesHeader.backgroundColor = [UIColor clearColor];
	notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
	notesHeader.opaque			= NO;
	notesHeader.text			= @"Trip Details";
	notesHeader.textColor		= [UIColor whiteColor];
	[infoView addSubview:notesHeader];
    
    UITextView *tripStats		= [[[UITextView alloc] initWithFrame:CGRectMake(0,35,320,400)] autorelease];
	tripStats.backgroundColor	= [UIColor clearColor];
	tripStats.editable			= NO;
	tripStats.font				= [UIFont systemFontOfSize:16.0];
	tripStats.text				= [NSString stringWithFormat:@"Start Time: %@ \nTime Elapsed: %@ \nDistance: %.1f mi \nAvg. Speed: %.1f mph \n\nRoute Frequency: %@ \n\nRoute Preferences: %@  \n\nRoute Comfort: %@ \n\nRoute Stressors: %@ \n\nNotes: %@",
                                   [dateFormatter stringFromDate:[trip start]],
                                   [inputFormatter stringFromDate:outputDate],
                                   [trip.distance doubleValue] / 1609.344,
                                   mph, routeFreqString, routePrefsString, routeComfortString, routeStressorsString,
                                   trip.notes];
	tripStats.textColor			= [UIColor whiteColor];
	[infoView addSubview:tripStats];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    //Navigation bar color
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:psuGreen];
    
    
    self.navigationController.navigationBarHidden = NO;
    
	if ( trip )
	{
		// format date as a string
		static NSDateFormatter *dateFormatter = nil;
		if (dateFormatter == nil) {
			dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			[dateFormatter setDateStyle:NSDateFormatterLongStyle];
		}
		
		// display duration, distance as navbar prompt
		static NSDateFormatter *inputFormatter = nil;
		if ( inputFormatter == nil )
			inputFormatter = [[NSDateFormatter alloc] init];
		
		[inputFormatter setDateFormat:@"HH:mm:ss"];
//		NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
		[inputFormatter setDateFormat:@"HH:mm:ss"];
        
        if ([trip.purpose  isEqual: kTripPurposeOtherString]) {
            NSMutableString *purposeTitle = [trip.purpose mutableCopy];
            [purposeTitle appendString:@" ("];
            [purposeTitle appendString:trip.purposeOther];
            [purposeTitle appendString:@")"];
            self.title = purposeTitle;
        }
        else{
            self.title = trip.purpose;
        }
		

        doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(infoAction:)];
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"TripLogging"]){
            
            NSString *tripPurposeString = @"Trip Logged";
            NSString *tripPurposeShortString1 = @"";
            NSString *tripPurposeShortString2 = @"";
            
            if (![trip.purpose isEqualToString:@"Other"]){
                tripPurposeString = [NSString stringWithFormat:@"%@ Trip Logged", trip.purpose];
                tripPurposeShortString1 = trip.purpose;
                tripPurposeShortString2 = trip.purpose;
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
            
            NSString *sameString = @"same";
            NSString *routeString = @"route";
            
            
            NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"Data for this %@ trip will be logged and uploaded. If you repeat the %@ %@ %@ there is no need to log it again. Please use ORcycle to log new trip purposes, routes, crash events, or safety issues.", tripPurposeShortString1, sameString, tripPurposeShortString2, routeString]];
            
            [messageString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(0,messageString.length)];
            
            [messageString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0] range:NSMakeRange(14, tripPurposeShortString1.length)];
            
            [messageString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0] range: NSMakeRange(14 + tripPurposeShortString1.length + 34, sameString.length + 19)];
            
            [messageString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-BoldOblique" size: 12.0] range: NSMakeRange(14 + tripPurposeShortString1.length + 53 + sameString.length + 1, tripPurposeShortString2.length)];
            
            [messageString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0] range: NSMakeRange(14 + tripPurposeShortString1.length + 53 + sameString.length + 1 + tripPurposeShortString2.length + 1, routeString.length + 33)];
            
            [messageString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0] range: NSMakeRange(14 + tripPurposeShortString1.length + 53 + sameString.length + 1 + tripPurposeShortString2.length + 1 + routeString.length + 1 + 60,3 )];
            
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
                
                //declared alertCheckboxButton in the header due to errors I was getting when referring to the button in the button's method below
                alertCheckboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
                alertCheckboxButton.frame = CGRectMake(180, 97, 18, 18);
                alertCheckboxButton.backgroundColor = [UIColor clearColor];
                UIImage *alertButtonImageNormal = [UIImage imageNamed:@"unchecked_checkbox.png"];
                UIImage *alertButtonImageChecked = [UIImage imageNamed:@"checked_checkbox.png"];
                [alertCheckboxButton setImage:alertButtonImageNormal forState:UIControlStateNormal];
                [alertCheckboxButton setImage:alertButtonImageChecked forState:UIControlStateSelected];
                [alertCheckboxButton addTarget:self action:@selector(alertCheckboxButtonClicked) forControlEvents:UIControlEventTouchUpInside];
                
                [tripLogAlertView addSubview: alertCheckboxButton];
                
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
                
                //declared alertCheckboxButton in the header due to errors I was getting when referring to the button in the button's method below
                alertCheckboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
                alertCheckboxButton.frame = CGRectMake(150, 127, 18, 18);
                alertCheckboxButton.backgroundColor = [UIColor clearColor];
                UIImage *alertButtonImageNormal = [UIImage imageNamed:@"unchecked_checkbox.png"];
                UIImage *alertButtonImageChecked = [UIImage imageNamed:@"checked_checkbox.png"];
                [alertCheckboxButton setImage:alertButtonImageNormal forState:UIControlStateNormal];
                [alertCheckboxButton setImage:alertButtonImageChecked forState:UIControlStateSelected];
                [alertCheckboxButton addTarget:self action:@selector(alertCheckboxButtonClicked) forControlEvents:UIControlEventTouchUpInside];
                
                [tripLogAlertView addSubview: alertCheckboxButton];
                
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
        
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        infoButton.showsTouchWhenHighlighted = YES;
        [infoButton addTarget:self action:@selector(infoAction:) forControlEvents:UIControlEventTouchUpInside];
        flipButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
        self.navigationItem.rightBarButtonItem = flipButton;
			
        [self initInfoView];
		
		// filter coords by hAccuracy
		NSPredicate *filterByAccuracy	= [NSPredicate predicateWithFormat:@"hAccuracy < 100.0"];
		NSArray		*filteredCoords		= [[trip.coords allObjects] filteredArrayUsingPredicate:filterByAccuracy];
		NSLog(@"count of filtered coords = %lu", (unsigned long)[filteredCoords count]);
		
		// sort filtered coords by recorded date
		NSSortDescriptor *sortByDate	= [[[NSSortDescriptor alloc] initWithKey:@"recorded" ascending:YES] autorelease];
		NSArray		*sortDescriptors	= [NSArray arrayWithObjects:sortByDate, nil];
		NSArray		*sortedCoords		= [filteredCoords sortedArrayUsingDescriptors:sortDescriptors];
		
		// add coords as annotations to map
		BOOL first = YES;
		Coord *last = nil;
		MapCoord *pin = nil;
		int count = 0;
		
		// calculate min/max values for lat, lon
		NSNumber *minLat = [NSNumber numberWithDouble:0.0];
		NSNumber *maxLat = [NSNumber numberWithDouble:0.0];
		NSNumber *minLon = [NSNumber numberWithDouble:0.0];
		NSNumber *maxLon = [NSNumber numberWithDouble:0.0];
        
        NSMutableArray *routeCoords = [[[NSMutableArray alloc]init] autorelease];
        
		for ( Coord *coord in sortedCoords )
		{
			// only plot unique coordinates to our map for performance reasons
			if ( !last ||
				(![coord.latitude  isEqualToNumber:last.latitude] &&
				 ![coord.longitude isEqualToNumber:last.longitude] ) )
			{
                CLLocationCoordinate2D coordinate;
				coordinate.latitude  = [coord.latitude doubleValue];
				coordinate.longitude = [coord.longitude doubleValue];
                
                CLLocation *routePoint = [[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] autorelease];
				[routeCoords addObject:routePoint];
                
				//pin = [[MapCoord alloc] init];
				//pin.coordinate = coordinate;
				
				if ( first )
				{
					// add start point as a pin annotation
					first = NO;
					//pin.first = YES;
					//pin.title = @"Start";
					//pin.subtitle = [dateFormatter stringFromDate:coord.recorded];
					
					// initialize min/max values to the first coord
					minLat = coord.latitude;
					maxLat = coord.latitude;
					minLon = coord.longitude;
					maxLon = coord.longitude;
				}
				else
				{
					// update min/max values
					if ( [minLat compare:coord.latitude] == NSOrderedDescending )
						minLat = coord.latitude;
					
					if ( [maxLat compare:coord.latitude] == NSOrderedAscending )
						maxLat = coord.latitude;
					
					if ( [minLon compare:coord.longitude] == NSOrderedDescending )
						minLon = coord.longitude;
					
					if ( [maxLon compare:coord.longitude] == NSOrderedAscending )
						maxLon = coord.longitude;
				}
				
				//[mapView addAnnotation:pin];
				count++;
			}
			
			// update last coord pointer so we can cull redundant coords above
			last = coord;
		}
        NSLog(@"routeCoords array is this long: %lu@", (unsigned long)[routeCoords count]);
        
        NSUInteger numPoints = [routeCoords count];
        CLLocationCoordinate2D *routePath = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (NSUInteger index=0; index < numPoints; index ++){
            routePath[index] = [[routeCoords objectAtIndex:index] coordinate];
        }
        
        self.routeLine = [MKPolyline polylineWithCoordinates:routePath count:count];
        [mapView addOverlay:self.routeLine];
        [mapView setNeedsDisplay];
        
        //add start/end pins
        MKPointAnnotation *startPoint = [[[MKPointAnnotation alloc] init] autorelease];
        startPoint.coordinate = routePath[0];
        startPoint.title = @"Start";
        [mapView addAnnotation:startPoint];
        MKPointAnnotation *endPoint = [[[MKPointAnnotation alloc] init] autorelease];
        endPoint.coordinate = routePath[numPoints-1];
        endPoint.title = @"End";
        [mapView addAnnotation:endPoint];
        
        
        //free(routePath);
		
		NSLog(@"added %d unique GPS coordinates of %lu to map", count, (unsigned long)[sortedCoords count]);
		
		// add end point as a pin annotation
		if ( last == [sortedCoords lastObject] )
		{
			pin.last = YES;
			pin.title = @"End";
			pin.subtitle = [dateFormatter stringFromDate:last.recorded];
		}
		
		// if we had at least 1 coord
		if ( count )
		{
			// calculate region from coords min/max lat/lon
			/*
             NSLog(@"minLat = %f", [minLat doubleValue]);
             NSLog(@"maxLat = %f", [maxLat doubleValue]);
             NSLog(@"minLon = %f", [minLon doubleValue]);
             NSLog(@"maxLon = %f", [maxLon doubleValue]);
             */
			
			// add a small fudge factor to ensure
			// North-most pins are visible
			double latDelta = kFudgeFactor * ( [maxLat doubleValue] - [minLat doubleValue] );
			if ( latDelta < kMinLatDelta )
				latDelta = kMinLatDelta;
			
			double lonDelta = [maxLon doubleValue] - [minLon doubleValue];
			if ( lonDelta < kMinLonDelta )
				lonDelta = kMinLonDelta;
			
            //			MKCoordinateRegion region = { { [minLat doubleValue] + latDelta / 2,
            //											[minLon doubleValue] + lonDelta / 2 },
            //										  { latDelta,
            //											lonDelta } };
            MKCoordinateRegion region = { { (routePath[0].latitude + routePath[numPoints-1].latitude) / 2,
                (routePath[0].longitude + routePath[numPoints-1].longitude) / 2 },
                { latDelta,
                    lonDelta } };
			[mapView setRegion:region animated:NO];
		}
		else
		{
			// init map region to Oregon
			MKCoordinateRegion region = { { 44.1419049, -120.5380992}, { 0.10825, 0.10825 } };
			[mapView setRegion:region animated:NO];
		}
        free(routePath);
	}
	else
	{
		// error: init map region to Oregon
		MKCoordinateRegion region = { { 44.1419049, -120.5380992 }, { 0.10825, 0.10825 } };
		[mapView setRegion:region animated:NO];
	}
    
    LoadingView *loading = (LoadingView*)[self.parentViewController.view viewWithTag:909];
	//NSLog(@"loading: %@", loading);
	[loading performSelector:@selector(removeView) withObject:nil afterDelay:0.5];
}

-(void)alertCheckboxButtonClicked{
    
    NSLog(@"AlertCheckbocButtonClicked Method called");
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"TripLogging"]){
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"TripLogging"];
        alertCheckboxButton.selected = YES;
    }else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TripLogging"];
        alertCheckboxButton.selected = NO;
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


- (void)viewWillDisappear:(BOOL)animated{
    UIImage *thumbnailOriginal;
    thumbnailOriginal = [self screenshot];
    
    CGRect clippedRect  = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+160, self.view.frame.size.width, self.view.frame.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([thumbnailOriginal CGImage], clippedRect);
    UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    CGSize size;
    size.height = 72;
    size.width = 72;
    
    UIImage *thumbnail;
    thumbnail = shrinkImage(newImage, size);
    
    NSData *thumbnailData = [[[NSData alloc] initWithData:UIImageJPEGRepresentation(thumbnail, 0)] autorelease];
    NSLog(@"Size of Thumbnail Image(bytes):%lu",(unsigned long)[thumbnailData length]);
    NSLog(@"Size: %f, %f", thumbnail.size.height, thumbnail.size.width);
    
    [delegate getTripThumbnail:thumbnailData];
}


UIImage *shrinkImage(UIImage *original, CGSize size) {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width * scale,
                                                 size.height * scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context,
                       CGRectMake(0, 0, size.width * scale, size.height * scale),
                       original.CGImage);
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    UIImage *final = [UIImage imageWithCGImage:shrunken];
    
    CGContextRelease(context);
    CGImageRelease(shrunken);
    CGColorSpaceRelease(colorSpace);
    return final;
}


- (UIImage*)screenshot
{
    NSLog(@"Screen Shoot");
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y+50);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return screenImage;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


#pragma mark MKMapViewDelegate methods


- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	//NSLog(@"mapViewWillStartLoadingMap");
}


- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	NSLog(@"mapViewDidFailLoadingMap:withError: %@", [error localizedDescription]);
}


- (void)mapViewDidFinishLoadingMap:(MKMapView *)_mapView
{
	//NSLog(@"mapViewDidFinishLoadingMap");
	LoadingView *loading = (LoadingView*)[self.parentViewController.view viewWithTag:909];
	//NSLog(@"loading: %@", loading);
	[loading removeView];
}


- (MKAnnotationView *)mapView:(MKMapView *)_mapView
			viewForAnnotation:(id <MKAnnotation>)annotation
{
	//NSLog(@"viewForAnnotation");
	
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MapCoord class]])
    {
		MKAnnotationView* annotationView = nil;
		
		if ( [(MapCoord*)annotation first] )
		{
			// Try to dequeue an existing pin view first.
			MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView
																  dequeueReusableAnnotationViewWithIdentifier:@"FirstCoord"];
			
			if ( !pinView )
			{
				// If an existing pin view was not available, create one
				pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"FirstCoord"]
						   autorelease];
                pinView.image = [UIImage imageNamed:@"tripStart.png"];
                pinView.centerOffset = CGPointMake(0,-20);
                NSLog(@"START GLYPH");
			}
			
			annotationView = pinView;
		}
		else if ( [(MapCoord*)annotation last] )
		{
			// Try to dequeue an existing pin view first.
			MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView
																  dequeueReusableAnnotationViewWithIdentifier:@"LastCoord"];
			
			if ( !pinView )
			{
				// If an existing pin view was not available, create one
				pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"LastCoord"]
						   autorelease];
                pinView.image = [UIImage imageNamed:@"tripEnd.png"];
                NSLog(@"STOP GLYPH");
			}
			
			annotationView = pinView;
		}
		else
		{
			// Try to dequeue an existing pin view first.
			annotationView = (MKAnnotationView*)[mapView
												 dequeueReusableAnnotationViewWithIdentifier:@"MapCoord"];
			
			if (!annotationView)
			{
				// If an existing pin view was not available, create one
				annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapCoord"]
								  autorelease];
				
				annotationView.image = [UIImage imageNamed:@"MapCoord.png"];
				
				/*
				 pinView.pinColor = MKPinAnnotationColorPurple;
				 pinView.animatesDrop = YES;
				 pinView.canShowCallout = YES;
				 */
				
				/*
				 // Add a detail disclosure button to the callout.
				 UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
				 [rightButton addTarget:self action:@selector(myShowDetailsMethod:) forControlEvents:UIControlEventTouchUpInside];
				 pinView.rightCalloutAccessoryView = rightButton;
				 */
			}
		}
		
        return annotationView;
    } else {
        //handle 'normal' pins
        
        if([annotation.title isEqual:@"Start"]){
            MKAnnotationView *pinView=[[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"tripPin"] autorelease];
            pinView.image = [UIImage imageNamed:@"tripStart.png"];;
            //annView.centerOffset = CGPointMake(-(annView.image.size.width/6),(annView.image.size.height/4));
            pinView.centerOffset = (CGPoint){0.0f, 0.0f};
            return pinView;
        }else if ([annotation.title isEqual:@"End"]){
            MKAnnotationView *pinView=[[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"tripPin"] autorelease];
            pinView.image = [UIImage imageNamed:@"tripEnd.png"];
            pinView.centerOffset = (CGPoint){0.0f, 0.0f};
            return pinView;
        }
    }
	
    return nil;
}

- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView* lineView = [[[MKPolylineView alloc] initWithPolyline:self.routeLine] autorelease];
    lineView.strokeColor = psuGreen;
    lineView.lineWidth = 5;
    return lineView;
}

- (void)dealloc {
    self.trip = nil;
    self.doneButton = nil;
    self.flipButton = nil;
    self.infoView = nil;
    self.routeLine = nil;
    self.delegate = nil;
    
    [delegate release];
	[doneButton release];
	[flipButton release];
	[trip release];
    [infoView release];
    [routeLine release];
    
    [mapView release];
    
    [super dealloc];
}


@end
