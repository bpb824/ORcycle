//
//  NoteResponse.h
//  ORcycle
//
//  Created by orcycle on 8/29/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface NoteResponse : NSManagedObject

@property (nonatomic) BOOL isCrash;
@property (nonatomic, retain) NSNumber *severity;
@property (nonatomic, retain) NSNumber *urgency;
@property (nonatomic, retain) NSString *conflictWith;
@property (nonatomic, retain) NSString *issueType;
@property (nonatomic, retain) NSString *crashActions;
@property (nonatomic, retain) NSString *crashReasons;

@property (nonatomic, retain) Note *note;

@end
