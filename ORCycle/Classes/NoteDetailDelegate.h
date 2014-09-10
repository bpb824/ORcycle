//
//  NoteDetailDelegate.h
//  ORcycle
//
//  Created by orcycle on 8/31/14.
//
//

@protocol NoteDetailDelegate <NSObject>

@required
- (NSString *)getPurposeString:(unsigned int)index;
- (NSString *)setPurpose:(unsigned int)index;
- (void)setSaved:(BOOL)value;

@optional
- (void)didCancelNote;
- (void)didPickNoteType:(NSNumber *)index;
- (void)didEnterNoteDetails:(NSString *)details;
- (void)didSaveImage:(NSData *)imgData;
- (void)getNoteThumbnail:(NSData *)imgData;
- (void)saveNote;
- (void)openDetailPage;
- (void)backOut;

- (void)didPickConflictWith:(NSString *)conflictWithString;
- (void)didPickIssueType:(NSString *)issueTypeString;


@end
