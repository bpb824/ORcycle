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
