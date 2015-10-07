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
//  TripManager.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "ActivityIndicatorDelegate.h"
#import "TripPurposeDelegate.h"
#import "LoadingView.h"

@class Trip;


@interface TripManager : NSObject
<ActivityIndicatorDelegate, 
TripPurposeDelegate, 
UIAlertViewDelegate, 
UITextViewDelegate>
{
	UIAlertView *saving;
	UIAlertView *tripNotes;
	UITextView	*tripNotesText;
//    id <ActivityIndicatorDelegate> activityDelegate;
//    id <UIAlertViewDelegate> alertDelegate;
//    UIActivityIndicatorView *activityIndicator;

	BOOL dirty;
	Trip *trip;
	CLLocationDistance distance;
	NSInteger purposeIndex;
	
	NSMutableArray *coords;
    NSMutableArray *tripResponses;
    NSManagedObjectContext *managedObjectContext;
    
   // NSMutableArray *tripResponses;

	NSMutableData *receivedData;
	
	NSMutableArray *unSavedTrips;
	NSMutableArray *unSyncedTrips;
	NSMutableArray *zeroDistanceTrips;
}

@property (nonatomic, retain) id <ActivityIndicatorDelegate> activityDelegate;
@property (nonatomic, retain) id <UIAlertViewDelegate> alertDelegate;

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) LoadingView *uploadingView;

@property (nonatomic, retain) UIViewController *parent; 

@property (nonatomic, retain) UIAlertView *saving;
@property (nonatomic, retain) UIAlertView *tripNotes;
@property (nonatomic, retain) UITextView *tripNotesText;

@property (assign) BOOL dirty;
@property (nonatomic, retain) Trip *trip;

@property (nonatomic, retain) NSMutableArray *coords;
@property (nonatomic, retain) NSMutableArray *tripResponses;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//@property (nonatomic, retain) NSMutableArray *tripResponses;

@property (nonatomic, retain) NSMutableData *receivedData;


- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
- (id)initWithTrip:(Trip*)trip;
- (BOOL)loadTrip:(Trip*)trip;

- (void)createTrip;
- (void)createTrip:(unsigned int)index;

- (CLLocationDistance)addOnlyCoord:(CLLocation*)location;
- (CLLocationDistance)addCoord:(CLLocation*)location withAccel:(NSMutableDictionary*)accelDict;
- (void)saveNotes:(NSString*)notes;
- (void)saveTrip;
- (void)discardTrip;

- (CLLocationDistance)getDistanceEstimate;

- (NSInteger)getPurposeIndex;

//- (void)promptForTripNotes;

- (int)countUnSavedTrips;
- (int)countUnSyncedTrips;
- (int)countZeroDistanceTrips;

- (BOOL)loadMostRecetUnSavedTrip;
- (int)recalculateTripDistances;
- (CLLocationDistance)calculateTripDistance:(Trip*)_trip;

@end


@interface TripPurpose : NSObject { }

+ (unsigned int)getPurposeIndex:(NSString*)string;
+ (NSString *)getPurposeString:(unsigned int)index;

@end


