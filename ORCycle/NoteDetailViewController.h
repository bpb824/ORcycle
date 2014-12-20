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

@interface NoteDetailViewController : UIViewController<UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    id <NoteDetailDelegate> noteDelegate;
    RenoTracksAppDelegate *appDelegate;
    NoteResponse *noteResponse;
    UITableView *infoTableView;
    NSManagedObjectContext *managedObjectContext;
    NSInteger pickerCategory;
    
    UITextField *urgency;
    UIToolbar *doneToolbar;
    UIActionSheet *actionSheet;
    UIPickerView *pickerView;
    UITextField *currentTextField;
    
    NSArray *urgencyArray;
    //NSArray *conflictWithArray;
    NSArray *issueTypeArray;
    
    NSInteger urgencySelectedRow;
    //NSMutableArray *conflictWithSelectedRows;
    NSMutableArray *issueTypeSelectedRows;
    NSInteger selectedItem;
    NSMutableArray *selectedItems;
    
    NSString *otherIssueType;
    //NSString *otherConflictWith;
    
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

@property (nonatomic,retain) UITextField *urgency;
@property (nonatomic,retain) UITextField *issueType;

@property (nonatomic) NSInteger urgencySelectedRow;
//@property (nonatomic,retain) NSMutableArray *conflictWithSelectedRows;
@property (nonatomic,retain) NSMutableArray* issueTypeSelectedRows;
@property (nonatomic) NSInteger selectedItem;
@property (nonatomic,retain) NSMutableArray *selectedItems;

@property (nonatomic, retain) NSString *otherIssueType;
//@property (nonatomic, retain) NSString *otherConflictWith;

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
