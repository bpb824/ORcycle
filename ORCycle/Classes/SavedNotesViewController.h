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
 *   along with Reno Tracks.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <MapKit/MapKit.h>


@class LoadingView;
@class NoteViewController;
@class Note;
@class NoteManager;

@interface SavedNotesViewController : UITableViewController
    <UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    NSMutableArray *notes;
    NoteManager *noteManager;
    NSManagedObjectContext *managedObjectContext;
    LoadingView *loading;
    NSInteger pickerCategory;
    Note * selectedNote;
}

@property (nonatomic, retain) NSMutableArray *notes;
@property (nonatomic, retain) NoteManager *noteManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Note *selectedNote;

- (void)initNoteManager:(NoteManager*)manager;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context;
- (id)initWithNoteManager:(NoteManager*)manager;

- (void)displayUploadedNote;

@end
