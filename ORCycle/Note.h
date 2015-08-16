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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * vAccuracy;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSNumber * note_type;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * hAccuracy;
@property (nonatomic, retain) NSDate * recorded;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSData * image_data;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSDate * uploaded;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSNumber *imageLatitude;
@property (nonatomic, retain) NSNumber * imageLongitude;
@property (nonatomic) BOOL sentEmail;

@property (nonatomic) BOOL isCrash;
@property (nonatomic, retain) NSNumber *urgency;
@property (nonatomic, retain) NSNumber *severity;
@property (nonatomic, retain) NSString *conflictWith;
@property (nonatomic, retain) NSString *issueType;
@property (nonatomic, retain) NSString *crashActions;
@property (nonatomic, retain) NSString *crashReasons;

@property (nonatomic, retain) NSString *otherIssueType;
@property (nonatomic, retain) NSString *otherConflictWith;
@property (nonatomic, retain) NSString *otherCrashActions;
@property (nonatomic, retain) NSString *otherCrashReasons;

@property (nonatomic, retain) NSDate *reportDate;

@end
