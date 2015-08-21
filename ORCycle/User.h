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

@class Note, Trip;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * cyclingFreq;
@property (nonatomic, retain) NSNumber * cyclingWeather;
@property (nonatomic, retain) NSNumber * riderHistory;
@property (nonatomic, retain) NSNumber * riderAbility;
@property (nonatomic, retain) NSNumber * riderType;
@property (nonatomic, retain) NSNumber * occupation;
@property (nonatomic, retain) NSNumber * income;
@property (nonatomic, retain) NSNumber * hhWorkers;
@property (nonatomic, retain) NSNumber * hhVehicles;
@property (nonatomic, retain) NSNumber * numBikes;
@property (nonatomic, retain) NSMutableString * bikeTypes;
@property (nonatomic, retain) NSNumber * ethnicity;
@property (nonatomic, retain) NSString * homeZIP;
@property (nonatomic, retain) NSString * schoolZIP;
@property (nonatomic, retain) NSString * workZIP;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phoneNum;
@property (nonatomic, retain) NSString * feedback;

@property (nonatomic, retain) NSString * userCreated;

@property (nonatomic,retain) NSString * otherRiderType;
@property (nonatomic,retain) NSString * otherOccupation;
@property (nonatomic,retain) NSString * otherBikeTypes;
@property (nonatomic,retain) NSString * otherEthnicity;
@property (nonatomic,retain) NSString * otherGender;

@property (nonatomic, retain) NSSet *notes;
@property (nonatomic, retain) NSSet *trips;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

- (void)addTripsObject:(Trip *)value;
- (void)removeTripsObject:(Trip *)value;
- (void)addTrips:(NSSet *)values;
- (void)removeTrips:(NSSet *)values;

@end
