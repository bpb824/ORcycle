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
//  CycleTracksAppDelegate.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/21/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>


@interface RenoTracksAppDelegate : NSObject <UIApplicationDelegate>
{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
    
    UITabBarController *tabBarController;
	NSString *uniqueIDHash;
    //UIAlertView *consentFor18;
    // added to handle location manager background service switching
    BOOL isRecording;
    CLLocationManager *locationManager;
    CMMotionManager *motionManager;

}


@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) NSString *uniqueIDHash;
//@property (nonatomic, retain) UIAlertView *consentFor18;
// added to handle location manager background service switching
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic,retain) CMMotionManager *motionManager;

- (NSString *)applicationDocumentsDirectory;
- (void)initUniqueIDHash;

@end

