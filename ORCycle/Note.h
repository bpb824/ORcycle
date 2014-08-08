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

@end
