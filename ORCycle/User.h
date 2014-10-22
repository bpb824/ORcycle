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
