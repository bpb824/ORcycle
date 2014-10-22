/**ORcycle, Copyright 2014, PSU Transportation, Technology, and People Lab
 *
 * @author Bryan.Blanc <bryanpblanc@gmail.com>
 * For more info on the project, go to http://www.pdx.edu/transportation-lab/orcycle
 *
 * Updated/modified for Oregon Department of Transportation app deployment. Based on the CycleTracks codebase for SFCTA
 * Cycle Atlanta, and RenoTracks.
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
    
    BOOL customLoc;
    BOOL gpsLoc;
    

    
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

@property (nonatomic) BOOL customLoc;
@property (nonatomic) BOOL gpsLoc;


-(IBAction)back:(id)sender;
-(IBAction)saveDetail:(id)sender;

// DEPRECATED
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;

- (void)done;

@end
