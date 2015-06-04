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
//  RecordTripViewController.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/10/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import <CoreLocation/CoreLocation.h>
#import "ActivityIndicatorDelegate.h"
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import <ImageIO/ImageIO.h>
#import "EXF.h"
#import "PersonalInfoDelegate.h"
#import "RecordingInProgressDelegate.h"
#import "TripPurposeDelegate.h"
#import "RenoTracksAppDelegate.h"
#import "NoteDetailDelegate.h"
#import "TutorialDelegate.h"
#import "Note.h"


@class ReminderManager;
@class TripManager;
@class NoteManager;
//@class CycleTracksAppDelegate;

//@interface RecordTripViewController : UITableViewController 
@interface RecordTripViewController : UIViewController 
	<CLLocationManagerDelegate,
	MKMapViewDelegate,
	UINavigationControllerDelegate, 
	UITabBarControllerDelegate, 
	PersonalInfoDelegate,
	RecordingInProgressDelegate,
	TripPurposeDelegate,
    NoteDetailDelegate,
	UIActionSheetDelegate,
	UIAlertViewDelegate,
	UITextViewDelegate, TutorialDelegate, MFMailComposeViewControllerDelegate>
{
    NSManagedObjectContext *managedObjectContext;
	RenoTracksAppDelegate *appDelegate;
//    CLLocationManager *locationManager;
	/*
	UITableViewCell *tripPurposeCell;
	UITableViewCell *personalInfoCell;
	*/
	BOOL				didUpdateUserLocation;
	IBOutlet MKMapView	*mapView;
	
	IBOutlet UIButton *infoButton;
	IBOutlet UIButton *saveButton;
	IBOutlet UIButton *startButton;
    IBOutlet UIButton *noteButton;
    IBOutlet UIButton *centerButton;
    
    UIButton *welcomeCheckboxButton;
    UIButton *tripCheckboxButton;
    
	IBOutlet UILabel *timeCounter;
	IBOutlet UILabel *distCounter;
	IBOutlet UILabel *speedCounter;
    IBOutlet UILabel *calorieCount;
    IBOutlet UILabel *C02Count;
    UIActionSheet *saveActionSheet;
    
    BOOL iSpeedCheck;
    BOOL speedNoteUp;
    float timeSpeedCheck;
    float distSpeedCheck;
    float speedCheck;

	NSTimer *timer;
	
	// pointer to opacity mask, TabBar view
	UIView *opacityMask;
	UIView *parentView;
	
	BOOL recording;
	BOOL shouldUpdateCounter;
	BOOL userInfoSaved;
    NSInteger pickerCategory;
    NSMutableArray *slowSpeedsArray;
	
	TripManager		*tripManager;
    NoteManager *noteManager;
    
    
    CLLocation *myLocation;
	ReminderManager *reminderManager;
}

//@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//@property (nonatomic, retain) CLLocationManager *locationManager;
/*
@property (nonatomic, retain) UITableViewCell	*tripPurposeCell;
@property (nonatomic, retain) UITableViewCell	*personalInfoCell;
*/
@property (nonatomic, retain) UIButton *infoButton;
@property (nonatomic, retain) UIButton *saveButton;
@property (nonatomic, retain) UIButton *startButton;
@property (nonatomic, retain) UIButton *noteButton;
@property (nonatomic, retain) UIButton *centerButton;

@property (nonatomic, retain) UIButton *welcomeCheckboxButton;
@property (nonatomic, retain) UIButton *tripCheckboxButton;

@property (nonatomic, retain) UILabel *timeCounter;
@property (nonatomic, retain) UILabel *distCounter;
@property (nonatomic, retain) UIActionSheet *saveActionSheet;

@property (assign) BOOL iSpeedCheck;
@property (assign) BOOL speedNoteUp;
@property (assign) float timeSpeedCheck;
@property (assign) float distSpeedCheck;
@property (assign) float speedCheck;

@property (assign) NSTimer *timer;

@property (nonatomic, retain) NSMutableArray   *slowSpeedsArray;

@property (nonatomic, retain) UIView   *parentView;

@property (assign) BOOL recording;
@property (assign) BOOL shouldUpdateCounter;
@property (assign) BOOL userInfoSaved;

@property (nonatomic, retain) ReminderManager *reminderManager;
@property (nonatomic, retain) TripManager *tripManager;

@property (nonatomic, retain) NoteManager *noteManager;

@property (nonatomic, retain) RenoTracksAppDelegate *appDelegate;


- (void)initTripManager:(TripManager*)manager;

- (void)initNoteManager:(NoteManager*)manager;

// DEPRECATED
//- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
//- (id)initWithTripManager:(TripManager*)manager;

// IBAction handlers
//- (IBAction)save:(UIButton *)sender;
//- (void)save;

- (IBAction)start:(UIButton *)sender;

-(IBAction)notethis:(id)sender;

- (void)zoomToGps:(id)sender;


// timer methods
- (void)start:(UIButton *)sender;
//- (void)createCounter;
- (void)resetCounter;
- (void)setCounterTimeSince:(NSDate *)startDate distance:(CLLocationDistance)distance;
- (void)updateCounter:(NSTimer *)theTimer;

//- (UIButton *)createSaveButton;
- (UIButton *)createStartButton;
- (UIButton *)createNoteButton;

- (void)displayUploadedTripMap;
- (void)displayUploadedNote;

@end
