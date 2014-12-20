/**ORcycle, Copyright 2014, PSU Transportation, Technology, and People Lab
 *
 * @author Bryan.Blanc <bryanpblanc@gmail.com>
 * For more info on the project, go to http://www.pdx.edu/transportation-lab/orcycle
 *
 * Updated/modified for Oregon Department of Transportation app deployment. Based on the CycleTracks codebase for SFCTA
 * Cycle Atlanta, and RenoTracks.
 */

#import "Note.h"
#import "User.h"


@implementation Note

@dynamic details;
@dynamic speed;
@dynamic vAccuracy;
@dynamic longitude;
@dynamic image_url;
@dynamic note_type;
@dynamic latitude;
@dynamic hAccuracy;
@dynamic recorded;
@dynamic altitude;
@dynamic image_data;
@dynamic thumbnail;
@dynamic user;
@dynamic uploaded;
@dynamic reportDate;

@dynamic isCrash;
@dynamic urgency;
@dynamic severity;
@dynamic conflictWith;
@dynamic issueType;
@dynamic crashActions;
@dynamic crashReasons;

@dynamic otherConflictWith;
@dynamic otherIssueType;
@dynamic otherCrashReasons;
@dynamic otherCrashActions;

@end
