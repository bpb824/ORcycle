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
 *   along with Cycle Atlanta.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NoteDetailDelegate.h"
#import "RenoTracksAppDelegate.h"
#import "Checkbox.h"
#import "NoteResponse.h"
#import "DetailViewController.h"



@interface CrashDetailViewController : UIViewController<UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    id <NoteDetailDelegate> noteDelegate;
    RenoTracksAppDelegate *appDelegate;
    NoteResponse *noteResponse;
    UITableView *infoTableView;
    NSManagedObjectContext *managedObjectContext;
    NSInteger pickerCategory;
    
    UITextField *severity;
    UIToolbar *doneToolbar;
    UIActionSheet *actionSheet;
    UIPickerView *pickerView;
    UITextField *currentTextField;
    
    NSArray *severityArray;
    NSArray *conflictWithArray;
    NSArray *crashActionsArray;
    NSArray *crashReasonsArray;
    //NSArray *issueTypeArray;
    
    NSInteger severitySelectedRow;
    NSMutableArray *conflictWithSelectedRows;
    //NSMutableArray *issueTypeSelectedRows;
    NSInteger selectedItem;
    NSMutableArray *selectedItems;
    
    //NSString *otherIssueType;
    NSString *otherConflictWith;
    
    NSDate *reportDate;
    
    BOOL customLoc;
    BOOL gpsLoc;
    
    BOOL customDate;
    BOOL nowDate;
    
}

@property (nonatomic, retain) id <NoteDetailDelegate> noteDelegate;

@property (nonatomic, retain) RenoTracksAppDelegate *appDelegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NoteResponse *noteResponse;

@property (nonatomic,retain) UITextField *severity;
@property (nonatomic,retain) UITextField *issueType;

@property (nonatomic) NSInteger severitySelectedRow;
@property (nonatomic,retain) NSMutableArray *conflictWithSelectedRows;
@property (nonatomic,retain) NSMutableArray *crashActionsSelectedRows;
@property (nonatomic,retain) NSMutableArray *crashReasonsSelectedRows;

@property (nonatomic) NSInteger selectedItem;
@property (nonatomic,retain) NSMutableArray *selectedItems;

@property (nonatomic, retain) NSString *otherConflictWith;
@property (nonatomic, retain) NSString *otherCrashActions;
@property (nonatomic, retain) NSString *otherCrashReasons;



@property (nonatomic, retain) IBOutlet UITableView *infoTableView;

@property (nonatomic, strong) NSDate *reportDate;

@property (nonatomic) BOOL customLoc;
@property (nonatomic) BOOL gpsLoc;

@property (nonatomic) BOOL customDate;
@property (nonatomic) BOOL nowDate;


-(IBAction)back:(id)sender;
-(IBAction)saveDetail:(id)sender;

// DEPRECATED
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;

- (void)done;

@end
