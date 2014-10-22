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

@class Trip;

@interface Coord : NSManagedObject

@property (nonatomic, retain) NSNumber * hAccuracy;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * vAccuracy;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * recorded;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) Trip *trip;

@end
