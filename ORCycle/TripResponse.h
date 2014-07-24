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

@property (nonatomic, retain) NSNumber *question_id;
@property (nonatomic, retain) NSNumber *answer_id;
@property (nonatomic, retain) Trip *trip;

@end
