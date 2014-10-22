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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "NoteManager.h"
#import "TripManager.h"
#import "NoteDetailDelegate.h"

@interface NoteViewController : UIViewController <MKMapViewDelegate>
{
    id <NoteDetailDelegate> delegate;
    IBOutlet MKMapView *noteView;
    Note *note;
    UIBarButtonItem *doneButton;
	UIBarButtonItem *flipButton;
	UIView *infoView;
}

@property (nonatomic, retain) id <NoteDetailDelegate> delegate;
@property (nonatomic, retain) Note *note;
@property (nonatomic ,retain) UIBarButtonItem *doneButton;
@property (nonatomic, retain) UIBarButtonItem *flipButton;
@property (nonatomic, retain) UIView *infoView;

-(id)initWithNote:(Note *)note;

@end
