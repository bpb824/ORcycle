/**ORcycle, Copyright 2014, PSU Transportation, Technology, and People Lab
 *
 * @author Bryan.Blanc <bryanpblanc@gmail.com>
 * For more info on the project, e-mail figliozzi@pdx.edu
 *
 * Updated/modified for Oregon Department of Transportation app deployment. Based on the CycleTracks codebase for SFCTA
 * Cycle Atlanta, and RenoTracks.
 */


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trip;

@interface TripResponse : NSManagedObject

@property (nonatomic, retain) NSNumber *routeFreq;
@property (nonatomic, retain) NSString *routePrefs;
@property (nonatomic, retain) NSNumber *routeComfort;
@property (nonatomic, retain) NSNumber *routeSafety;
@property (nonatomic, retain) NSString *ridePassengers;
@property (nonatomic, retain) NSString *rideSpecial;
@property (nonatomic, retain) NSNumber *rideConflict;
@property (nonatomic, retain) NSString *routeStressors;
@property (nonatomic, retain) Trip *trip;

@end
