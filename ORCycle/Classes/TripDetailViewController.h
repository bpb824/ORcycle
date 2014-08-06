/** Reno Tracks, Copyright 2012, 2013 Hack4Reno
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
#import "TripPurposeDelegate.h"
#import "RenoTracksAppDelegate.h"
#import "Checkbox.h"
#import "TripResponse.h"

@interface TripDetailViewController : UIViewController<UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    id <TripPurposeDelegate> delegate;
    RenoTracksAppDelegate *appDelegate;
    TripResponse *tripResponse;
    UITextView *detailTextView;
    UITableView *infoTableView;
    NSManagedObjectContext *managedObjectContext;
    NSInteger pickerCategory;
    NSString *details;
    
    UITextField *routeFreq;
    UITextField *routePrefs;
    UITextField *routeComfort;
    UITextField *routeSafety;
    UITextField *ridePassengers;
    UITextField *rideSpecial;
    UITextField *rideConflict;
    UITextField *routeStressors;
    UIToolbar *doneToolbar;
    UIActionSheet *actionSheet;
    UIPickerView *pickerView;
    UITextField *currentTextField;
    
    NSArray *routeFreqArray;
    NSArray *routePrefsArray;
    NSArray *routeComfortArray;
    NSArray *routeSafetyArray;
    NSArray *ridePassengersArray;
    NSArray *rideSpecialArray;
    NSArray *rideConflictArray;
    NSArray *routeStressorsArray;
    
    NSInteger routeFreqSelectedRow;
    NSMutableArray *routePrefsSelectedRows;
    NSInteger routeComfortSelectedRow;
    NSInteger routeSafetySelectedRow;
    NSMutableArray *ridePassengersSelectedRows;
    NSMutableArray *rideSpecialSelectedRows;
    NSInteger rideConflictSelectedRow;
    NSMutableArray *routeStressorsSelectedRows;
    NSInteger selectedItem;
    NSMutableArray *selectedItems;
}

@property (nonatomic, retain) id <TripPurposeDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITextView *detailTextView;

@property (nonatomic, retain) RenoTracksAppDelegate *appDelegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) TripResponse *tripResponse;

@property (nonatomic,retain) UITextField *routeFreq;
@property (nonatomic,retain) UITextField *routePrefs;
@property (nonatomic,retain) UITextField *routeComfort;
@property (nonatomic,retain) UITextField *routeSafety;
@property (nonatomic,retain) UITextField *ridePassengers;
@property (nonatomic,retain) UITextField *rideSpecial;
@property (nonatomic,retain) UITextField *rideConflict;
@property (nonatomic,retain) UITextField *routeStressors;

@property (nonatomic) NSInteger routeFreqSelectedRow;
@property (nonatomic,retain) NSMutableArray *routePrefsSelectedRows;
@property (nonatomic) NSInteger routeComfortSelectedRow;
@property (nonatomic) NSInteger routeSafetySelectedRow;
@property (nonatomic,retain) NSMutableArray *ridePassengersSelectedRows;
@property (nonatomic,retain) NSMutableArray *rideSpecialSelectedRows;
@property (nonatomic) NSInteger rideConflictSelectedRow;
@property (nonatomic,retain) NSMutableArray *routeStressorsSelectedRows;
@property (nonatomic) NSInteger selectedItem;
@property (nonatomic,retain) NSMutableArray *selectedItems;

@property (nonatomic, retain) IBOutlet UITableView *infoTableView;


-(IBAction)skip:(id)sender;
-(IBAction)saveDetail:(id)sender;

// DEPRECATED
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;

- (void)done;

@end
