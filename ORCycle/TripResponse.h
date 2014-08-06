//
//  TripResponse.h
//  ORCycle
//
//  Created by orcycle on 7/21/14.
//
//


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
