/**ORcycle, Copyright 2014, PSU Transportation, Technology, and People Lab
 *
 * @author Bryan.Blanc <bryanpblanc@gmail.com>
 * For more info on the project, go to http://www.pdx.edu/transportation-lab/orcycle
 *
 * Updated/modified for Oregon Department of Transportation app deployment. Based on the CycleTracks codebase for SFCTA
 * Cycle Atlanta, and RenoTracks.
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
