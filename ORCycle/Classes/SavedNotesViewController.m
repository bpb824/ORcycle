/**ORcycle, Copyright 2014, PSU Transportation, Technology, and People Lab
 *
 * @author Bryan.Blanc <bryanpblanc@gmail.com>
 * For more info on the project, e-mail figliozzi@pdx.edu
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


#import "constants.h"
#import "SavedNotesViewController.h"
#import "TripPurposeDelegate.h"
#import "LoadingView.h"
#import "NoteViewController.h"
#import "PickerViewController.h"
#import "Note.h"
#import "NoteManager.h"

#define kAccessoryViewX	282.0
#define kAccessoryViewY 24.0

#define kCellReuseIdentifierCheck		@"CheckMark"
#define kCellReuseIdentifierExclamation @"Exclamataion"

#define kRowHeight	75
#define kTagTitle	1
#define kTagDetail	2
#define kTagImage	3

@interface NoteCell : UITableViewCell
{
    
}
- (void)setTitle:(NSString *)title;
- (void)setDetail:(NSString *)detail;
- (void)setDirty;

@end

@implementation NoteCell

- (void)setTitle:(NSString *)title
{
    self.textLabel.text = title;
    [self setNeedsDisplay];
}

- (void)setDetail:(NSString *)detail
{
    self.detailTextLabel.text = detail;
    [self setNeedsDisplay];
}

- (void)setDirty
{
	[self setNeedsDisplay];
}

@end

@implementation SavedNotesViewController

@synthesize managedObjectContext;
@synthesize noteManager;
@synthesize notes;
@synthesize selectedNote;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if (self = [super init]) {
		self.managedObjectContext = context;
        
		// Set the title NOTE: important for tab bar tab item to set title here before view loads
		self.title = @"View Saved Safety Marks";
    }
    return self;
}

- (void)initNoteManager:(NoteManager*)manager
{
	self.noteManager = manager;
}

- (id)initWithNoteManager:(NoteManager*)manager
{
    if (self = [super init]) {
		//NSLog(@"SavedTripsViewController::initWithTripManager");
		self.noteManager = manager;
		
		// Set the title NOTE: important for tab bar tab item to set title here before view loads
		self.title = @"View Saved Safety Marks";
    }
    return self;
}

- (void)refreshTableView
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:noteManager.managedObjectContext];
	[request setEntity:entity];

    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"note_type",@"recorded",nil]];

	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recorded" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	NSError *error;
	NSInteger count = [noteManager.managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"count = %ld", (long)count);
	
	NSMutableArray *mutableFetchResults = [[noteManager.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"no saved notes");
		if ( error != nil )
			NSLog(@"Unresolved error2 %@, %@", error, [error userInfo]);
	}
	
	[self setNotes:mutableFetchResults];
	[self.tableView reloadData];
    
	[mutableFetchResults release];
	[request release];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.rowHeight = kRowHeight;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    //Navigation bar color
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:psuGreen];
    
    //[self refreshTableView];
    
    /*
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
     */
}

- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"SavedNotesViewController viewWillAppear");
	
	[self refreshTableView];
    
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [notes count];
}

- (NoteCell *)getCellWithReuseIdentifier:(NSString *)reuseIdentifier
{
	NoteCell *cell = (NoteCell*)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil)
	{
		cell = [[[NoteCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier] autorelease];
		cell.detailTextLabel.numberOfLines = 2;
        if ( [reuseIdentifier isEqual: kCellReuseIdentifierExclamation] )
		{
			// add exclamation point
			UIImage		*image		= [UIImage imageNamed:@"failedUpload.png"];
			UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
			imageView.frame = CGRectMake( kAccessoryViewX, kAccessoryViewY, image.size.width, image.size.height );
			imageView.tag	= kTagImage;
			cell.accessoryView = imageView;
		}
	}
	else{
        [[cell.contentView viewWithTag:kTagImage] setNeedsDisplay];
    }
    
	// slide accessory view out of the way during editing
	cell.editingAccessoryView = cell.accessoryView;
    
	return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    static NSDateFormatter *timeFormatter = nil;
    if (timeFormatter == nil) {
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    Note *note = (Note *)[notes objectAtIndex:indexPath.row];
	NoteCell *cell = nil;
    
    UIImage	*image;
    
    if(note.uploaded){
        cell = [self getCellWithReuseIdentifier:kCellReuseIdentifierCheck];
        
        int index = [note.note_type intValue];
        
        NSLog(@"note.purpose: %d",index);
        
        // add purpose icon
        
        switch (index) {
            case 0:
                image = [UIImage imageNamed:kNoteThisIssueBlack];
                break;
            case 1:
                image = [UIImage imageNamed:kNoteThisIssueRed];
                break;
            case 2:
                image = [UIImage imageNamed:kNoteThisIssueOrange];
                break;
            case 3:
                image = [UIImage imageNamed:kNoteThisIssueYellow];
                break;
            case 4:
                image = [UIImage imageNamed:kNoteThisIssueGreen];
                break;
            case 5:
                image = [UIImage imageNamed:kNoteThisIssueWhite];
                break;
            default:
            
                image = [UIImage imageNamed:kNoteThisIssueBlack];
                break;
        }
        
        UIImageView *imageView	= [[[UIImageView alloc] initWithImage:image] autorelease];
        imageView.frame			= CGRectMake( kAccessoryViewX, kAccessoryViewY, image.size.width, image.size.height );
        
        //[cell.contentView addSubview:imageView];
        cell.accessoryView = imageView;
    }
    else
	{
		cell = [self getCellWithReuseIdentifier:kCellReuseIdentifierExclamation];
		//tripStatus = @"(recording interrupted)";
	}
    
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n(note saved & uploaded)", 
//                                 [dateFormatter stringFromDate:[note recorded]]];
//    noteStatus = @"(note saved & uploaded)";
    
    cell.detailTextLabel.tag = kTagDetail;
    cell.textLabel.tag = kTagTitle;
    
    NSString *title = [[[NSString alloc] init] autorelease] ;
    switch ([note.note_type intValue]) {
        case 0:
            title = @"No severity level indicated";
            break;
        case 1:
            title = @"Major crash/accident";
            break;
        case 2:
            title = @"Minor crash/accident";
            break;
        case 3:
            title = @"Near crash/accident";
            break;
        case 4:
            title = @"Did not feel safe";
            break;
        case 5:
            title = @"Uncomfortable";
            break;
        default:
            break;
    }
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    [cell.textLabel setTextColor:[UIColor grayColor]];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ at %@", [dateFormatter stringFromDate:[note recorded]], [timeFormatter stringFromDate:[note recorded]]];
    
    [cell.detailTextLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [cell.detailTextLabel setTextColor:[UIColor blackColor]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",title];
    
    cell.editingAccessoryView = cell.accessoryView;

    //cell.textLabel.text			= [dateFormatter stringFromDate:[note recorded]];
    //cell.detailTextLabel.text = title;
    
    //timeText.text = [NSString stringWithFormat:@"%@ at %@", [dateFormatter stringFromDate:[note recorded]], [timeFormatter stringFromDate:[note recorded]]];
    
    
    
    //purposeText.text = [NSString stringWithFormat:@"%@",title];
    
    //[cell addSubview:purposeText];
    //[cell addSubview:timeText];

    
    return cell;
}

- (void)promptToConfirmPurpose
{
	NSLog(@"promptToConfirmPurpose");
	
	NSString *confirm = [NSString stringWithFormat:@"This note has not yet been uploaded. Try now?"];
	
	// present action sheet
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:confirm
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Upload", nil];
	
	actionSheet.actionSheetStyle	= UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.tabBarController.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"actionSheet clickedButtonAtIndex %ld", (long)buttonIndex);
	switch ( buttonIndex )
	{
		case 0:
            [noteManager saveNote:noteManager.note];
			break;
		case 1:
		default:
			NSLog(@"Cancel");
			[self displaySelectedNoteMap];
			break;
	}
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	NSLog(@"actionSheetCancel");
}

- (void)displaySelectedNoteMap
{
	loading		= [[LoadingView loadingViewInView:self.parentViewController.view messageString:@"Loading..."] retain];
	loading.tag = 999;
	if ( selectedNote )
	{
		NoteViewController *mvc = [[NoteViewController alloc] initWithNote:selectedNote];
		[[self navigationController] pushViewController:mvc animated:YES];
		[mvc release];
		selectedNote = nil;
	}
}

- (void)displayUploadedNote
{
    Note *note = noteManager.note;
    
    // load map view of note
    NoteViewController *mvc = [[NoteViewController alloc] initWithNote:note];
    [[self navigationController] pushViewController:mvc animated:YES];
    NSLog(@"displayUploadedNote");
    [mvc release];
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSLog(@"Delete");
		
        // Delete the managed object at the given index path.
        NSManagedObject *noteToDelete = [notes objectAtIndex:indexPath.row];
        [noteManager.managedObjectContext deleteObject:noteToDelete];
		
        // Update the array and table view.
        [notes removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
        // Commit the change.
        NSError *error;
        if (![noteManager.managedObjectContext save:&error]) {
            // Handle the error.
			NSLog(@"Unresolved error %@", [error localizedDescription]);
        }
    }
	else if ( editingStyle == UITableViewCellEditingStyleInsert )
		NSLog(@"INSERT");
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    selectedNote = (Note *)[notes objectAtIndex:indexPath.row];
    
    loading		= [[LoadingView loadingViewInView:self.parentViewController.view messageString:@"Loading..."] retain];
	loading.tag = 999;
    [loading performSelector:@selector(removeView) withObject:nil afterDelay:0.5];
    
    if (!selectedNote.uploaded) {
        if ( noteManager )
            [noteManager release];
        
        noteManager = [[NoteManager alloc] initWithNote:selectedNote];
        noteManager.alertDelegate = self;
        noteManager.parent = self;
        // prompt to upload
        [self promptToConfirmPurpose];
    }
    else if ( selectedNote )
	{
		NoteViewController *mvc = [[NoteViewController alloc] initWithNote:selectedNote];
		[[self navigationController] pushViewController:mvc animated:YES];
		[mvc release];
		selectedNote = nil;
	}
}


#pragma mark UINavigationController


- (void)navigationController:(UINavigationController *)navigationController
	  willShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated
{
	if ( viewController == self )
	{
		//NSLog(@"willShowViewController:self");
		self.title = @"View Saved Safety Marks";
	}
	else
	{
		//NSLog(@"willShowViewController:else");
		self.title = @"Back";
		self.tabBarItem.title = @"View Saved Safety Marks"; // important to maintain the same tab item title
	}
}

- (void)dealloc {
    self.notes = nil;
    self.managedObjectContext = nil;
    self.noteManager = nil;
    self.selectedNote = nil;
    
    [notes release];
    [selectedNote release];
    [noteManager release];
    [loading release];
    
    [super dealloc];
}

@end
