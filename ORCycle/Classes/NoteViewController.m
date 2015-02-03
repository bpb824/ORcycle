/*
**	ORcycle, Copyright 2014, 2015, PSU Transportation, Technology, and People Lab. 
* 
*	ORcycle 2.2.0 has introduced new app features: safety focus with new buttons 
*	to report safety issues and crashes (new questionnaires), expanded trip 
*	questionnaire (adding questions besides trip purpose), app utilization 
*	reminders, app tutorial, and updated font and color schemes. 
*
*	@author Bryan.Blanc <bryanpblanc@gmail.com>    (code)
*	@author Miguel Figliozzi <figliozzi@pdx.edu> and ORcycle team (general app 
*	design and features, report questionnaires and new ORcycle features) 
*
*	For more information on the project, go to 
* 	http://www.pdx.edu/transportation-lab/orcycle  and http://www.pdx.edu/transportation-lab/app-development
*
*	Updated/modified for Oregon pilot study and app deployment. 
*
*	ORcycle is free software: you can redistribute it and/or modify it under the 
*	terms of the GNU General Public License as published by the Free Software 
*	Foundation, either version 3 of the License, or any later version.
*	ORcycle is distributed in the hope that it will be useful, but WITHOUT ANY 
*	WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR 
*	A PARTICULAR PURPOSE. See the GNU General Public License for more details.
*	You should have received a copy of the GNU General Public License along with 
*	ORcycle. If not, see <http://www.gnu.org/licenses/>.
*
*
** Reno Tracks, Copyright 2012, 2013 Hack4Reno
 *
 *   @author Brad.Hellyar <bradhellyar@gmail.com>
 *
 *   Updated/Modified for Reno, Nevada app deployment. Based on the
 *   CycleTracks codebase for SFCTA, and the Atlanta Cycle app repo.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Reno Tracks.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <MobileCoreServices/UTCoreTypes.h>
#import "NoteViewController.h"
#import "LoadingView.h"
#import "TripPurposeDelegate.h"
#import "Note.h"
#import "UIImageViewResizable.h"
#import "constants.h"

#define kFudgeFactor	1.5
#define kInfoViewAlpha	0.8
#define kMinLatDelta	0.0039
#define kMinLonDelta	0.0034

@interface NoteViewController ()

@end

@implementation NoteViewController

@synthesize doneButton, flipButton, infoView, note;
@synthesize delegate;

- (id)initWithNote:(Note *)_note
{
	if (self = [super initWithNibName:@"NoteViewController" bundle:nil]) {
		NSLog(@"NoteViewController initWithNote");
		self.note = _note;
		noteView.delegate = self;
    }
    return self;
}



- (void)infoAction:(UIButton*)sender
{
	NSLog(@"infoAction");
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	
	[UIView setAnimationTransition:([infoView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.view cache:YES];
	
	if ([infoView superview])
		[infoView removeFromSuperview];
	else
		[self.view addSubview:infoView];
	
	[UIView commitAnimations];
	
	// adjust our done/info buttons accordingly
	if ([infoView superview] == self.view)
		self.navigationItem.rightBarButtonItem = doneButton;
	else
		self.navigationItem.rightBarButtonItem = flipButton;
}

- (void)initInfoView
{
	infoView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,560)];
    NSInteger textLength = self.note.details.length;
    //int row = 1+(textLength-1)/34;
    
    //Mark date details
    NSDateFormatter *outputDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [outputDateFormatter setDateStyle:kCFDateFormatterLongStyle];
    NSString *newDateString =[outputDateFormatter stringFromDate:note.reportDate];
    
/////CRASH NOTE
    if (self.note.isCrash){
        NSString *severityString = [[NSString alloc]init];
        switch ([self.note.note_type intValue]) {
            case 0:
                severityString = @"Crash (No severity level indicated)";
                break;
            case 1:
                severityString = @"Crash - Major injuries (required hospitalization)";
                break;
            case 2:
                severityString = @"Crash - Severe (required visit to ER)";
                break;
            case 3:
                severityString = @"Crash - Minor injury (no visit to ER)";
                break;
            case 4:
                severityString = @"Crash - Property damage only";
                break;
            case 5:
                severityString = @"Near-Crash (no damage or injury)";
                break;
            default:
                severityString = @"Crash (No severity level indicated)";
                break;
        }
        
        NSLog(@"severity string = %@", severityString);
        
        
        NSMutableArray *conflictWithTemp = [[self.note.conflictWith componentsSeparatedByString:@","] mutableCopy];
        
        NSMutableString *conflictWithString = [[NSMutableString alloc]init];
        
        if([conflictWithTemp count] != 0){
            NSMutableArray *conflictWithArray = [[NSMutableArray alloc] init];
            for (NSString *s in conflictWithTemp)
            {
                NSNumber *num = [NSNumber numberWithInt:[s intValue]];
                [conflictWithArray addObject:num];
            }
            
            if ([conflictWithArray[0] integerValue]==1){
                [conflictWithString appendString:@", Small/medium car"];
            }
            if ([conflictWithArray[1] integerValue]==1){
                [conflictWithString appendString:@", Large car/Van/SUV"];
            }
            if ([conflictWithArray[2] integerValue]==1){
                [conflictWithString appendString:@", Pickup truck"];
            }
            if ([conflictWithArray[3] integerValue]==1){
                [conflictWithString appendString:@", Large commercial vehicles (trucks)"];
            }
            if ([conflictWithArray[4] integerValue]==1){
                [conflictWithString appendString:@", Public transportation (buses, light rail, streetcar)"];
            }
            if ([conflictWithArray[5] integerValue]==1){
                [conflictWithString appendString:@", Another bicycle"];
            }
            if ([conflictWithArray[6] integerValue]==1){
                [conflictWithString appendString:@", Pedestrian"];
            }
            if ([conflictWithArray[7] integerValue]==1){
                [conflictWithString appendString:@", Pole or fixed object"];
            }
            if ([conflictWithArray[8] integerValue]==1){
                [conflictWithString appendString:@", Cyclist fell (or almost fell)"];
            }
            if ([conflictWithArray[9] integerValue]==1){
                if (note.otherConflictWith.length > 0){
                    [conflictWithString appendString:@", Other ("];
                    [conflictWithString appendString:note.otherConflictWith];
                    [conflictWithString appendString:@")"];
                }else{
                    [conflictWithString appendString:@", Other"];
                }
            }
            if (conflictWithString.length != 0){
                NSRange range = {0,2};
                [conflictWithString deleteCharactersInRange:range];
            }
        }
        if (conflictWithString.length == 0){
            conflictWithString = [NSMutableString stringWithFormat:@"No conflicts documented"];
        }
        
        NSMutableArray *crashActionsTemp = [[self.note.crashActions componentsSeparatedByString:@","] mutableCopy];
        
        NSMutableString *crashActionsString = [[NSMutableString alloc]init];
        
        if([crashActionsTemp count] != 0){
            NSMutableArray *crashActionsArray = [[NSMutableArray alloc] init];
            for (NSString *s in crashActionsTemp)
            {
                NSNumber *num = [NSNumber numberWithInt:[s intValue]];
                [crashActionsArray addObject:num];
            }
            
            if ([crashActionsArray[0] integerValue]==1){
                [crashActionsString appendString:@", Right-turning vehicle"];
            }
            if ([crashActionsArray[1] integerValue]==1){
                [crashActionsString appendString:@", Left-turning vehicle"];
            }
            if ([crashActionsArray[2] integerValue]==1){
                [crashActionsString appendString:@", Parking or backing up vehicle"];
            }
            if ([crashActionsArray[3] integerValue]==1){
                [crashActionsString appendString:@", Person exiting a vehicle"];
            }
            if ([crashActionsArray[4] integerValue]==1){
                [crashActionsString appendString:@", Cyclist changed lane or direction of travel"];
            }
            if ([crashActionsArray[5] integerValue]==1){
                [crashActionsString appendString:@", Vehicle changed lane or direction of travel"];
            }
            if ([crashActionsArray[6] integerValue]==1){
                [crashActionsString appendString:@", Cyclist did not stop"];
            }
            if ([crashActionsArray[7] integerValue]==1){
                [crashActionsString appendString:@", Driver did not stop"];
            }
            if ([crashActionsArray[8] integerValue]==1){
                [crashActionsString appendString:@", Cyclist lost control of the bike"];
            }
            if ([crashActionsArray[9] integerValue]==1){
                if (note.otherCrashActions.length > 0){
                    [crashActionsString appendString:@", Other ("];
                    [crashActionsString appendString:note.otherCrashActions];
                    [crashActionsString appendString:@")"];
                }else{
                    [crashActionsString appendString:@", Other"];
                }
            }
            if (crashActionsString.length != 0){
                NSRange range = {0,2};
                [crashActionsString deleteCharactersInRange:range];
            }
        }
        if (crashActionsString.length == 0){
            crashActionsString = [NSMutableString stringWithFormat:@"No crash actions documented"];
        }
        
        NSMutableArray *crashReasonsTemp = [[self.note.crashReasons componentsSeparatedByString:@","] mutableCopy];
        
        NSMutableString *crashReasonsString = [[NSMutableString alloc]init];
        
        if([crashReasonsTemp count] != 0){
            NSMutableArray *crashReasonsArray = [[NSMutableArray alloc] init];
            for (NSString *s in crashReasonsTemp)
            {
                NSNumber *num = [NSNumber numberWithInt:[s intValue]];
                [crashReasonsArray addObject:num];
            }
            
            if ([crashReasonsArray[0] integerValue]==1){
                [crashReasonsString appendString:@", Debris or pavement quality"];
            }
            if ([crashReasonsArray[1] integerValue]==1){
                [crashReasonsString appendString:@", Poor lighting or visibility"];
            }
            if ([crashReasonsArray[2] integerValue]==1){
                [crashReasonsString appendString:@", Cyclist was outside bike lane or area"];
            }
            if ([crashReasonsArray[3] integerValue]==1){
                [crashReasonsString appendString:@", Vehicle entered bike lane or area"];
            }
            if ([crashReasonsArray[4] integerValue]==1){
                [crashReasonsString appendString:@", Cyclist did not obey stop sign or red light"];
            }
            if ([crashReasonsArray[5] integerValue]==1){
                [crashReasonsString appendString:@", Vehicle did not obey stop sign or red light"];
            }
            if ([crashReasonsArray[6] integerValue]==1){
                [crashReasonsString appendString:@", Cyclist did not yield"];
            }
            if ([crashReasonsArray[7] integerValue]==1){
                [crashReasonsString appendString:@", Vehicle did not yield"];
            }
            if ([crashReasonsArray[8] integerValue]==1){
                [crashReasonsString appendString:@", Cyclist was distracted"];
            }
            if ([crashReasonsArray[9] integerValue]==1){
                [crashReasonsString appendString:@", Careless driving or high vehicle speed"];
            }
            if ([crashReasonsArray[10] integerValue]==1){
                if (note.otherCrashReasons.length > 0){
                    [crashReasonsString appendString:@", Other ("];
                    [crashReasonsString appendString:note.otherCrashReasons];
                    [crashReasonsString appendString:@")"];
                }else{
                    [crashReasonsString appendString:@", Other"];
                }
            }
            if (crashReasonsString.length != 0){
                NSRange range = {0,2};
                [crashReasonsString deleteCharactersInRange:range];
            }
        }
        if (crashReasonsString.length == 0){
            crashReasonsString = [NSMutableString stringWithFormat:@"No crash reasons documented"];
        }
        
        if (self.note.image_data != nil && textLength != 0) {
            infoView.alpha = 1.0;
            infoView.backgroundColor = [UIColor blackColor];
            
            UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 427)] autorelease];
            
            UIImageViewResizable *noteImageResize = [[[UIImageViewResizable alloc] initWithFrame:CGRectMake(0, 0, 320, 427)] autorelease];
            
            noteImageResize.image= [UIImage imageWithData:self.note.image_data];
            noteImageResize.contentMode = UIViewContentModeScaleAspectFill;
            
            [scrollView addSubview:noteImageResize];
            
            [infoView addSubview:scrollView];
            
            UIImageView *bgImageHeader      = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)] autorelease];
            bgImageHeader.backgroundColor = [UIColor grayColor];
            bgImageHeader.alpha = 0.8;
            [infoView addSubview:bgImageHeader];
            
            UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(10,5,250,25)] autorelease];
            notesHeader.backgroundColor = [UIColor clearColor];
            notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
            notesHeader.opaque			= NO;
            notesHeader.text			= @"Crash/Conflict Details";
            notesHeader.textColor		= [UIColor whiteColor];
            notesHeader.textAlignment = NSTextAlignmentLeft;
            [infoView addSubview:notesHeader];
            
            //        UIImageView *bgImageText      = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 320, 25*row+25)] autorelease];
            //        bgImageText.backgroundColor = [UIColor blackColor];
            //        bgImageText.alpha = 0.8;
            //        [infoView addSubview:bgImageText];
            
            UITextView *notesText		= [[[UITextView alloc] initWithFrame:CGRectMake(0,30,320,200)] autorelease];
            notesText.backgroundColor	= [UIColor clearColor];
            notesText.editable			= NO;
            notesText.font				= [UIFont systemFontOfSize:16.0];
            notesText.text				= [NSString stringWithFormat:@"Date: %@ \nSeverity Level: %@ \nCrash Conflict(s): %@ \nCrash Action(s): %@ \nCrash Reason(s): %@ \nComments: %@", newDateString,  severityString, conflictWithString, crashActionsString, crashReasonsString, self.note.details];
            NSLog(@"note text = %@",notesText.text);
            notesText.textColor			= [UIColor whiteColor];
            [infoView addSubview:notesText];
        }
        else if (self.note.image_data != nil && textLength == 0) {
            infoView.alpha = 1.0;
            infoView.backgroundColor = [UIColor blackColor];
            
            UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 427)] autorelease];
            
            UIImageViewResizable *noteImageResize = [[[UIImageViewResizable alloc] initWithFrame:CGRectMake(0, 0, 320, 427)] autorelease];
            
            noteImageResize.image= [UIImage imageWithData:note.image_data];
            noteImageResize.contentMode = UIViewContentModeScaleAspectFill;
            
            [scrollView addSubview:noteImageResize];
            
            [infoView addSubview:scrollView];
            
            UIImageView *bgImageHeader      = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)] autorelease];
            bgImageHeader.backgroundColor = [UIColor grayColor];
            bgImageHeader.alpha = 0.8;
            [infoView addSubview:bgImageHeader];
            
            UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(10,5,250,25)] autorelease];
            notesHeader.backgroundColor = [UIColor clearColor];
            notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
            notesHeader.opaque			= NO;
            notesHeader.text			= @"Crash/Conflict Details";
            notesHeader.textColor		= [UIColor whiteColor];
            notesHeader.textAlignment = NSTextAlignmentLeft;
            [infoView addSubview:notesHeader];
            
            //        UIImageView *bgImageText      = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 320, 25*row+25)] autorelease];
            //        bgImageText.backgroundColor = [UIColor blackColor];
            //        bgImageText.alpha = 0.8;
            //        [infoView addSubview:bgImageText];
            
            UITextView *notesText		= [[[UITextView alloc] initWithFrame:CGRectMake(0,30,320,200)] autorelease];
            notesText.backgroundColor	= [UIColor clearColor];
            notesText.editable			= NO;
            notesText.font				= [UIFont systemFontOfSize:16.0];
            notesText.text				= [NSString stringWithFormat:@"Date: %@ \nSeverity Level: %@ \nCrash Cause(s): %@ \nCrash Action(s): %@ \nCrash Reason(s): %@", newDateString, severityString, conflictWithString, crashActionsString, crashReasonsString];
            NSLog(@"note text = %@",notesText.text);
            notesText.textColor			= [UIColor whiteColor];
            [infoView addSubview:notesText];
        }
        else if (self.note.image_data == nil && textLength != 0) {
            infoView.alpha				= kInfoViewAlpha;
            infoView.backgroundColor	= [UIColor grayColor];
            
            UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(10,5,250,25)] autorelease];
            notesHeader.backgroundColor = [UIColor clearColor];
            notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
            notesHeader.opaque			= NO;
            notesHeader.text			= @"Crash/Conflict Details";
            notesHeader.textColor		= [UIColor whiteColor];
            notesHeader.textAlignment = NSTextAlignmentLeft;
            [infoView addSubview:notesHeader];
            
            UITextView *notesText		= [[[UITextView alloc] initWithFrame:CGRectMake(0,30,320,400)] autorelease];
            notesText.backgroundColor	= [UIColor clearColor];
            notesText.editable			= NO;
            notesText.font				= [UIFont systemFontOfSize:16.0];
            notesText.text				= [NSString stringWithFormat:@"Date: %@ \n\nSeverity Level: %@ \n\nCrash Cause(s): %@ \n\nCrash Action(s): %@ \n\nCrash Reason(s): %@\n\nComments: %@", newDateString, severityString, conflictWithString, crashActionsString, crashReasonsString, self.note.details];
            NSLog(@"note text = %@",notesText.text);
            notesText.textColor			= [UIColor whiteColor];
            [infoView addSubview:notesText];
        }
        else{
            infoView.alpha				= kInfoViewAlpha;
            infoView.backgroundColor	= [UIColor grayColor];
            
            UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(10,5,250,25)] autorelease];
            notesHeader.backgroundColor = [UIColor clearColor];
            notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
            notesHeader.opaque			= NO;
            notesHeader.text			= @"Crash/Conflict Details";
            notesHeader.textColor		= [UIColor whiteColor];
            notesHeader.textAlignment = NSTextAlignmentLeft;
            [infoView addSubview:notesHeader];
            
            UITextView *notesText		= [[[UITextView alloc] initWithFrame:CGRectMake(0,30,320,400)] autorelease];
            notesText.backgroundColor	= [UIColor clearColor];
            notesText.editable			= NO;
            notesText.font				= [UIFont systemFontOfSize:16.0];
            notesText.text				= [NSString stringWithFormat:@"Date: %@ \n\nSeverity Level: %@ \n\nCrash Cause(s): %@ \n\nCrash Action(s): %@ \n\nCrash Reason(s): %@", newDateString, severityString, conflictWithString, crashActionsString, crashReasonsString];
            NSLog(@"note text = %@",notesText.text);
            notesText.textColor			= [UIColor whiteColor];
            [infoView addSubview:notesText];
            
        }


    }
////SAFETY ISSUE NOTE
    else{
        NSMutableArray *issueTypeTemp = [[self.note.issueType componentsSeparatedByString:@","] mutableCopy];
        
        NSMutableString *issueTypeString = [[NSMutableString alloc]init];
        
        if([issueTypeTemp count] != 0){
            NSMutableArray *issueTypeArray = [[NSMutableArray alloc] init];
            for (NSString *s in issueTypeTemp)
            {
                NSNumber *num = [NSNumber numberWithInt:[s intValue]];
                [issueTypeArray addObject:num];
            }
            
            if ([issueTypeArray[0] integerValue]==1){
                [issueTypeString appendString:@", Narrow bike lane"];
            }
            if ([issueTypeArray[1] integerValue]==1){
                [issueTypeString appendString:@", No bike lane or shoulder"];
            }
            if ([issueTypeArray[2] integerValue]==1){
                [issueTypeString appendString:@", High traffic speed"];
            }
            if ([issueTypeArray[3] integerValue]==1){
                [issueTypeString appendString:@", High traffic volume"];
            }
            if ([issueTypeArray[4] integerValue]==1){
                [issueTypeString appendString:@", Right-turning vehicles"];
            }
            if ([issueTypeArray[5] integerValue]==1){
                [issueTypeString appendString:@", Left-turning vehicles"];
            }
            if ([issueTypeArray[6] integerValue]==1){
                [issueTypeString appendString:@", Short green time (traffic signal)"];
            }
            if ([issueTypeArray[7] integerValue]==1){
                [issueTypeString appendString:@", Long wait time (traffic signal)"];
            }
            if ([issueTypeArray[8] integerValue]==1){
                [issueTypeString appendString:@", No push button or detection (traffic signal)"];
            }
            if ([issueTypeArray[9] integerValue]==1){
                [issueTypeString appendString:@", Truck traffic"];
            }
            if ([issueTypeArray[10] integerValue]==1){
                [issueTypeString appendString:@", Bus traffic/stop"];
            }
            if ([issueTypeArray[11] integerValue]==1){
                [issueTypeString appendString:@", Parked vehicles"];
            }
            if ([issueTypeArray[12] integerValue]==1){
                [issueTypeString appendString:@", Pavement condition"];
            }
            if ([issueTypeArray[13] integerValue]==1){
                if (note.otherIssueType.length > 0){
                    [issueTypeString appendString:@", Other ("];
                    [issueTypeString appendString:note.otherIssueType];
                    [issueTypeString appendString:@")"];
                }
                else{
                    [issueTypeString appendString:@", Other"];
                }
            }
            if (issueTypeString.length != 0){
                NSRange range = {0,2};
                [issueTypeString deleteCharactersInRange:range];
            }
        }
        if(issueTypeString.length == 0){
            issueTypeString = [NSMutableString stringWithFormat:@"No infrastructure issues documented"];
        }
        
        NSString *urgencyString = [[NSString alloc]init];
        switch ([self.note.urgency intValue]) {
            case 0:
                urgencyString = @"No urgency level indicated";
                break;
            case 1:
                urgencyString = @"1 (not urgent)";
                break;
            case 2:
                urgencyString = @"2";
                break;
            case 3:
                urgencyString = @"3 (somewhat urgent)";
                break;
            case 4:
                urgencyString = @"4";
                break;
            case 5:
                urgencyString = @"5 (urgent)";
                break;
            default:
                urgencyString = @"No urgency level indicated";
                break;
        }
        
        NSLog(@"urgency string = %@", urgencyString);
        
        if (self.note.image_data != nil && textLength != 0) {
            infoView.alpha = 1.0;
            infoView.backgroundColor = [UIColor blackColor];
            
            UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 427)] autorelease];
            
            UIImageViewResizable *noteImageResize = [[[UIImageViewResizable alloc] initWithFrame:CGRectMake(0, 0, 320, 427)] autorelease];
            
            noteImageResize.image= [UIImage imageWithData:self.note.image_data];
            noteImageResize.contentMode = UIViewContentModeScaleAspectFill;
            
            [scrollView addSubview:noteImageResize];
            
            [infoView addSubview:scrollView];
            
            UIImageView *bgImageHeader      = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)] autorelease];
            bgImageHeader.backgroundColor = [UIColor grayColor];
            bgImageHeader.alpha = 0.8;
            [infoView addSubview:bgImageHeader];
            
            UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(10,5,250,25)] autorelease];
            notesHeader.backgroundColor = [UIColor clearColor];
            notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
            notesHeader.opaque			= NO;
            notesHeader.text			= @"Safety Issue Details";
            notesHeader.textColor		= [UIColor whiteColor];
            notesHeader.textAlignment = NSTextAlignmentLeft;
            [infoView addSubview:notesHeader];
            
            //        UIImageView *bgImageText      = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 320, 25*row+25)] autorelease];
            //        bgImageText.backgroundColor = [UIColor blackColor];
            //        bgImageText.alpha = 0.8;
            //        [infoView addSubview:bgImageText];
            
            UITextView *notesText		= [[[UITextView alloc] initWithFrame:CGRectMake(0,30,320,200)] autorelease];
            notesText.backgroundColor	= [UIColor clearColor];
            notesText.editable			= NO;
            notesText.font				= [UIFont systemFontOfSize:16.0];
            notesText.text				= [NSString stringWithFormat:@"Date: %@ \nIssue Type(s): %@ \nUrgency Level: %@  \nComments: %@", newDateString, issueTypeString, urgencyString, self.note.details];
            NSLog(@"note text = %@",notesText.text);
            notesText.textColor			= [UIColor whiteColor];
            [infoView addSubview:notesText];
        }
        else if (self.note.image_data != nil && textLength == 0) {
            infoView.alpha = 1.0;
            infoView.backgroundColor = [UIColor blackColor];
            
            UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 427)] autorelease];
            
            UIImageViewResizable *noteImageResize = [[[UIImageViewResizable alloc] initWithFrame:CGRectMake(0, 0, 320, 427)] autorelease];
            
            noteImageResize.image= [UIImage imageWithData:note.image_data];
            noteImageResize.contentMode = UIViewContentModeScaleAspectFill;
            
            [scrollView addSubview:noteImageResize];
            
            [infoView addSubview:scrollView];
            
            UIImageView *bgImageHeader      = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)] autorelease];
            bgImageHeader.backgroundColor = [UIColor grayColor];
            bgImageHeader.alpha = 0.8;
            [infoView addSubview:bgImageHeader];
            
            UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(10,5,250,25)] autorelease];
            notesHeader.backgroundColor = [UIColor clearColor];
            notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
            notesHeader.opaque			= NO;
            notesHeader.text			= @"Safety Issue Details";
            notesHeader.textColor		= [UIColor whiteColor];
            notesHeader.textAlignment = NSTextAlignmentLeft;
            [infoView addSubview:notesHeader];
            
            //        UIImageView *bgImageText      = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 320, 25*row+25)] autorelease];
            //        bgImageText.backgroundColor = [UIColor blackColor];
            //        bgImageText.alpha = 0.8;
            //        [infoView addSubview:bgImageText];
            
            UITextView *notesText		= [[[UITextView alloc] initWithFrame:CGRectMake(0,30,320,200)] autorelease];
            notesText.backgroundColor	= [UIColor clearColor];
            notesText.editable			= NO;
            notesText.font				= [UIFont systemFontOfSize:16.0];
            notesText.text				= [NSString stringWithFormat:@"Date: %@ \nIssue Type(s): %@ \nUrgency Level: %@", newDateString, issueTypeString, urgencyString];
            NSLog(@"note text = %@",notesText.text);
            notesText.textColor			= [UIColor whiteColor];
            [infoView addSubview:notesText];
        }
        else if (self.note.image_data == nil && textLength != 0) {
            infoView.alpha				= kInfoViewAlpha;
            infoView.backgroundColor	= [UIColor grayColor];
            
            UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(10,5,250,25)] autorelease];
            notesHeader.backgroundColor = [UIColor clearColor];
            notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
            notesHeader.opaque			= NO;
            notesHeader.text			= @"Safety Issue Details";
            notesHeader.textColor		= [UIColor whiteColor];
            notesHeader.textAlignment = NSTextAlignmentLeft;
            [infoView addSubview:notesHeader];
            
            UITextView *notesText		= [[[UITextView alloc] initWithFrame:CGRectMake(0,30,320,400)] autorelease];
            notesText.backgroundColor	= [UIColor clearColor];
            notesText.editable			= NO;
            notesText.font				= [UIFont systemFontOfSize:16.0];
            notesText.text				= [NSString stringWithFormat:@"Date: %@ \n\nIssue Type(s): %@ \n\nUrgency Level: %@  \n\nComments: %@", newDateString, issueTypeString, urgencyString, self.note.details];
            NSLog(@"note text = %@",notesText.text);
            notesText.textColor			= [UIColor whiteColor];
            [infoView addSubview:notesText];
        }
        else{
            infoView.alpha				= kInfoViewAlpha;
            infoView.backgroundColor	= [UIColor grayColor];
            
            UILabel *notesHeader		= [[[UILabel alloc] initWithFrame:CGRectMake(10,5,250,25)] autorelease];
            notesHeader.backgroundColor = [UIColor clearColor];
            notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
            notesHeader.opaque			= NO;
            notesHeader.text			= @"Safety Issue Details";
            notesHeader.textColor		= [UIColor whiteColor];
            notesHeader.textAlignment = NSTextAlignmentLeft;
            [infoView addSubview:notesHeader];
            
            UITextView *notesText		= [[[UITextView alloc] initWithFrame:CGRectMake(0,30,320,400)] autorelease];
            notesText.backgroundColor	= [UIColor clearColor];
            notesText.editable			= NO;
            notesText.font				= [UIFont systemFontOfSize:16.0];
            notesText.text				= [NSString stringWithFormat:@"Date: %@ \n\nIssue Type(s): %@ \n\nUrgency Level: %@", newDateString, issueTypeString, urgencyString];
            NSLog(@"note text = %@",notesText.text);
            notesText.textColor			= [UIColor whiteColor];
            [infoView addSubview:notesText];
            
        }


    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    //Navigation bar color
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundColor:psuGreen];
    
   
    self.navigationController.navigationBarHidden = NO;
    self.tabBarItem.title = @"My Reports";

    NSString *title = [[[NSString alloc] init] autorelease];
    
	if ( self.note )
	{
        if (self.note.isCrash){
            
            switch ([self.note.note_type intValue]) {
                case 0:
                    title = @"Crash/Conflict (No severity level indicated)";
                    break;
                case 1:
                    title = @"Crash (Major Injuries)";
                    break;
                case 2:
                    title = @"Crash (Severe)";
                    break;
                case 3:
                    title = @"Crash (Minor Injuries)";
                    break;
                case 4:
                    title = @"Crash (Property Damage Only)";
                    break;
                case 5:
                    title = @"Near-Crash";
                    break;
                default:
                    title = @"Crash/Conflict (No severity level indicated)";
                    break;
            }
        }
        else{
            switch ([self.note.urgency intValue]) {
                case 0:
                    title = @"Safety Issue (No urgency level indicated)";
                    break;
                case 1:
                    title = @"Safety Issue (urgency 1)";
                    break;
                case 2:
                    title = @"Safety Issue (urgency 2)";
                    break;
                case 3:
                    title = @"Safety Issue (urgency 3)";
                    break;
                case 4:
                    title = @"Safety Issue (urgency 4)";
                    break;
                case 5:
                    title = @"Safety Issue (urgency 5)";
                    break;
                default:
                    title = @"Safety Issue (No urgency level indicated)";
                    break;
            }
        }
    
		self.title = title;
		
        doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(infoAction:)];
			
            
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        infoButton.showsTouchWhenHighlighted = YES;
        [infoButton addTarget:self action:@selector(infoAction:) forControlEvents:UIControlEventTouchUpInside];
        flipButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
        self.navigationItem.rightBarButtonItem = flipButton;
			
        [self initInfoView];
        
        CLLocationCoordinate2D noteCoordinate;
        noteCoordinate.latitude = [self.note.latitude doubleValue];
        noteCoordinate.longitude = [self.note.longitude doubleValue];
        NSLog(@"noteCoordinate is: %f, %f", noteCoordinate.latitude, noteCoordinate.longitude);
        
        MKPointAnnotation *notePoint = [[[MKPointAnnotation alloc] init] autorelease];
        notePoint.coordinate = noteCoordinate;
        notePoint.title = @"Mark Safety";
        [noteView addAnnotation:notePoint];
        
        
        MKCoordinateRegion region = { { noteCoordinate.latitude, noteCoordinate.longitude }, { 0.0078, 0.0068 }};
        [noteView setRegion:region animated:NO];
        
    }
    else{
        MKCoordinateRegion region = { { 44.1419049, -120.5380992 }, { 0.10825, 0.10825 } };
		[noteView setRegion:region animated:NO];
    }
    
    LoadingView *loading = (LoadingView*)[self.parentViewController.view viewWithTag:999];
	//NSLog(@"loading: %@", loading);
	[loading performSelector:@selector(removeView) withObject:nil afterDelay:0.5];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    UIImage *thumbnailOriginal;
    thumbnailOriginal = [self screenshot];
    
    CGRect clippedRect  = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+160, self.view.frame.size.width, self.view.frame.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([thumbnailOriginal CGImage], clippedRect);
    UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    CGSize size;
    size.height = 72;
    size.width = 72;
    
    UIImage *thumbnail;
    thumbnail = shrinkImage1(newImage, size);
    
    NSData *thumbnailData = [[[NSData alloc] initWithData:UIImageJPEGRepresentation(thumbnail, 0)] autorelease];
    NSLog(@"Size of Thumbnail Image(bytes):%d",[thumbnailData length]);
    NSLog(@"Size: %f, %f", thumbnail.size.height, thumbnail.size.width);
    
    [delegate getNoteThumbnail:thumbnailData];
}


UIImage *shrinkImage1(UIImage *original, CGSize size) {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width * scale,
                                                 size.height * scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context,
                       CGRectMake(0, 0, size.width * scale, size.height * scale),
                       original.CGImage);
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    UIImage *final = [UIImage imageWithCGImage:shrunken];
    
    CGContextRelease(context);
    CGImageRelease(shrunken);
    CGColorSpaceRelease(colorSpace);
    return final;
}


- (UIImage*)screenshot
{
    NSLog(@"Screen Shoot");
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y+50);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return screenImage;
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{

    MKAnnotationView *noteAnnotation = (MKAnnotationView*)[noteView dequeueReusableAnnotationViewWithIdentifier:@"notePin"];
    
    if (!noteAnnotation)
    {
        // If an existing pin view was not available, create one
        noteAnnotation = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"notePin"]
                          autorelease];
        if (self.note.isCrash){
            switch ([self.note.note_type integerValue]){
                case 0:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisCrashWhite];
                    break;
                case 1:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisCrashRed];
                    break;
                case 2:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisCrashOrange];
                    break;
                case 3:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisCrashYellow];
                    break;
                case 4:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisCrashGreen];
                    break;
                case 5:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisCrashBlue];
                    break;
                default:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisCrashWhite];
                    break;
            }

        }
        else{
            switch ([self.note.urgency integerValue]){
                case 0:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueWhite];
                    break;
                case 1:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueBlue];
                    break;
                case 2:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueGreen];
                    break;
                case 3:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueYellow];
                    break;
                case 4:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueOrange];
                    break;
                case 5:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueRed];
                    break;
                default:
                    noteAnnotation.image = [UIImage imageNamed:kNoteThisIssueWhite];
                    break;
            }

        }
                //noteAnnotation.image = [UIImage imageNamed:@"noteIssueMapGlyph.png"];
        //noteAnnotation.centerOffset = CGPointMake(-(noteAnnotation.image.size.width/4),(noteAnnotation.image.size.height/3));
        NSLog(@"Note Pin Note This Issue");

        /*
        if ([note.note_type intValue]>=0 && [note.note_type intValue]<=5) {
            noteAnnotation.image = [UIImage imageNamed:@"noteIssueMapGlyph.png"];
            //noteAnnotation.centerOffset = CGPointMake(-(noteAnnotation.image.size.width/4),(noteAnnotation.image.size.height/3));
            NSLog(@"Note Pin Note This Issue");
        }
        else if ([note.note_type intValue]>=6 && [note.note_type intValue]<=11) {
            noteAnnotation.image = [UIImage imageNamed:@"noteAssetMapGlyph.png"];
            //noteAnnotation.centerOffset = CGPointMake(-(noteAnnotation.image.size.width/4),(noteAnnotation.image.size.height/3));
            NSLog(@"Note Pin Note This Asset");
        }
         */
    }
    
    return noteAnnotation;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MKMapViewDelegate methods


- (void)mapViewWillStartLoadingMap:(MKMapView *)noteView
{
	//NSLog(@"mapViewWillStartLoadingMap");
}


- (void)mapViewDidFailLoadingMap:(MKMapView *)noteView withError:(NSError *)error
{
	NSLog(@"mapViewDidFailLoadingMap:withError: %@", [error localizedDescription]);
}


- (void)mapViewDidFinishLoadingMap:(MKMapView *)_noteView
{
	//NSLog(@"mapViewDidFinishLoadingMap");
	LoadingView *loading = (LoadingView*)[self.parentViewController.view viewWithTag:999];
	//NSLog(@"loading: %@", loading);
	[loading removeView];
}

- (void)dealloc {

    self.note = nil;
    self.doneButton = nil;
    self.flipButton = nil;
    self.infoView = nil;
    self.delegate = nil;
    
    [delegate release];
	[doneButton release];
	[flipButton release];
    [infoView release];
    [note release];
    
    [noteView release];
    
    [super dealloc];
}

@end
