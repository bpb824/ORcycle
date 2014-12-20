//
//  NoteDetailDelegate.h
//  ORcycle
//
//  Created by orcycle on 8/31/14.
//
//
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol NoteDetailDelegate <NSObject>

@required
- (NSString *)getPurposeString:(unsigned int)index;
- (NSString *)setPurpose:(unsigned int)index;
- (void)setSaved:(BOOL)value;

@optional
- (void)didCancelNote;
- (void)didCancelNoteDelete;
- (void)didPickNoteType:(NSNumber *)index;
- (void)didEnterNoteDetails:(NSString *)details;
- (void)didSaveImage:(NSData *)imgData;
- (void)getNoteThumbnail:(NSData *)imgData;
- (void)saveNote;
- (void)openDetailPage;
- (void)openCustomLocation;
- (void)revertGPSLocation;
- (void)didPickReportDate:(NSDate *)date;
- (void)saveCustomLocation:(CLLocation*)customLocation;
- (void)backOut;

- (void)didPickIsCrash:(BOOL *)boolean;

- (void)didPickConflictWith:(NSString *)conflictWithString;
- (void)didPickIssueType:(NSString *)issueTypeString;
- (void)didPickCrashActions:(NSString *)crashActionsString;
- (void)didPickCrashReasons:(NSString *)crashReasonsString;
- (void)didPickUrgency:(NSNumber *)index;

- (void)didEnterOtherConflictWith:(NSString *)otherConflictWithString;
- (void)didEnterOtherIssueType:(NSString *)otherIssueTypeString;
- (void)didEnterOtherCrashActions:(NSString *)otherCrashActionsString;
- (void)didEnterOtherCrashReasons:(NSString *)otherCrashReasonsString;

@end
