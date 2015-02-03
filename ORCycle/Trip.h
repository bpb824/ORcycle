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

@class Coord, User;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * uploaded;
@property (nonatomic, retain) NSString * purpose;
@property (nonatomic, retain) NSString * purposeOther;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSDate * saved;
@property (nonatomic, retain) NSSet *coords;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) User *user;

@property (nonatomic, retain) NSNumber *routeFreq;
@property (nonatomic, retain) NSString *routePrefs;
@property (nonatomic, retain) NSNumber *routeComfort;
@property (nonatomic, retain) NSString *routeStressors;

@property (nonatomic,retain) NSString *otherRouteStressors;
@property (nonatomic,retain) NSString *otherRoutePrefs;

@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addCoordsObject:(Coord *)value;
- (void)removeCoordsObject:(Coord *)value;
- (void)addCoords:(NSSet *)values;
- (void)removeCoords:(NSSet *)values;

@end
