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
 *   along with Reno Cycle.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "TripDetailViewController.h"
#import "TripResponse.h"
#import "constants.h"
#import "ActionSheetStringPicker.h"

@interface TripDetailViewController ()

@end

@implementation TripDetailViewController
@synthesize delegate, appDelegate, managedObjectContext, infoTableView, tripResponse;
@synthesize routeFreq, routePrefs, routeComfort, routeSafety, ridePassengers, rideSpecial, rideConflict, routeStressors;
@synthesize routeFreqSelectedRow, routePrefsSelectedRows, routeComfortSelectedRow, routeSafetySelectedRow, ridePassengersSelectedRows, rideSpecialSelectedRows, rideConflictSelectedRow, routeStressorsSelectedRows, selectedItem, selectedItems, isAlone, isNone, isNotConcerned, otherRoutePrefs, otherRouteStressors;

@synthesize detailTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    self.managedObjectContext = context;
    return self;
}

- (UITextField*)initTextFieldAlpha
{
	CGRect frame = CGRectMake( 10, 7, 300, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"Choose one";
	textField.delegate = self;
	return textField;
}

- (UITextField*)initTextFieldBeta
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"Choose one";
	textField.delegate = self;
	return textField;
}

- (UITextView*)initTextViewDetails
{
    CGRect frame = CGRectMake( 10, 7, 300, 100 );
    UITextView *textView = [[UITextView alloc] initWithFrame:frame];
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone,
    [textView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [textView.layer setBorderWidth:0.5];
    textView.layer.cornerRadius = 5;
    textView.clipsToBounds = YES;
    textView.textAlignment = NSTextAlignmentLeft;
    textView.keyboardType = UIKeyboardTypeDefault;
    textView.returnKeyType = UIReturnKeyDone;
    textView.font = [UIFont systemFontOfSize:17];
    textView.delegate = self;
    return textView;
}

- (TripResponse *)createTripResponse
{
	// Create and configure a new instance of the User entity
	TripResponse *newForm = (TripResponse *)[[NSEntityDescription insertNewObjectForEntityForName:@"TripResponse" inManagedObjectContext:managedObjectContext] retain];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"createTripResponse error %@, %@", error, [error localizedDescription]);
	}
	
	return [newForm autorelease];
}

- (void)viewDidLoad
{
    id objectDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [objectDelegate managedObjectContext];

    //[self.detailTextView becomeFirstResponder];
    [self.infoTableView becomeFirstResponder];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //detailTextView.layer.borderWidth = 1.0;
    //detailTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    routeFreqArray = [[NSArray alloc] initWithObjects:@" ", @"Several times per week", @"Several times per month", @"Several times per year", @"Once per year or less", @"First time ever", nil];
    routePrefsArray = [[NSArray alloc] initWithObjects:@" ", @"It is direct/fast", @"It has good bicycle facilities", @"It is enjoyable/has nice scenery", @"It is good for a workout", @"It has low traffic/low speeds", @"It has few busy intersections", @"It has few/easy hills", @"It has other riders/people",  @"It is good for families/kids", @"I do not know/have another route", @"I found it on my phone/online", @"Other", nil];
    routeComfortArray = [[NSArray alloc] initWithObjects: @" ", @"Very Good (even for families/children)" , @"Good (for most riders)", @"Average", @"Bad (only for confident riders)", @"Very Bad (unacceptable for most riders)", nil];
    routeSafetyArray = [[NSArray alloc] initWithObjects:@" ", @"Safe/comfortable for families, children, or new riders", @"Safe/comfortable for most riders", @"Safe/comfortable for the average confident rider", @"Only for the highly experienced and/or confident riders (not neccesarily comfortable)", @"Unacceptable", nil];
    ridePassengersArray = [[NSArray alloc] initWithObjects:@" ", @"Alone", @"With a child under 2", @"With a child between 2 and 10", @"With a child/teen over 10", @"With 1 adult", @"With 2+ adults", nil];
    rideSpecialArray = [[NSArray alloc] initWithObjects: @"None",@"Child seat(s)", @"Electric-assist", @"The cargo area", @"Other",nil];
    rideConflictArray = [[NSArray alloc] initWithObjects:@" ", @"I have had a crash/accident", @"I have had a near crash/accident", @"I did not have a near crash/accident, but did not feel safe", @"I did feel safe", nil];
    routeStressorsArray = [[NSArray alloc] initWithObjects: @" ", @"Not concerned",@"Auto traffic", @"Large commercial vehicles (trucks)", @"Public transportation (e.g. buses, light rail)", @"Parked vehicles (being doored)", @"Other cyclists", @"Pedestrians", @"Other", nil];
    
    routePrefsSelectedRows = [[NSMutableArray alloc] init];
    ridePassengersSelectedRows = [[NSMutableArray alloc] init];
    rideSpecialSelectedRows = [[NSMutableArray alloc] init];
    routeStressorsSelectedRows = [[NSMutableArray alloc] init];
    
    isAlone = false;
    isNone = false;
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    self.routeFreq = [self initTextFieldAlpha];
    self.routeComfort =[self initTextFieldAlpha];
    self.routeSafety =[self initTextFieldAlpha];
    self.rideConflict =[self initTextFieldAlpha];
    self.detailTextView = [self initTextViewDetails];
    
    [self setTripResponse:[self createTripResponse]];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    //Navigation bar color
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:psuGreen];
    
    
	// Set up the buttons.
    // this is actually the Save button.
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done)];
    
    //Initial Save button state is disabled. will be enabled if a change has been made to any of the fields.
	done.enabled = NO;
	self.navigationItem.rightBarButtonItem = done;
}

-(IBAction)skip:(id)sender{
    NSLog(@"Skip");
    
    [infoTableView resignFirstResponder];
    [delegate didCancelNote];
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    details = @"";
    
    [delegate didEnterTripDetails:details];
    [delegate saveTrip];
}

-(IBAction)saveDetail:(id)sender{
    NSLog(@"Save Detail");
    
    if ((routeFreqSelectedRow > 10 || routeFreqSelectedRow ==0)){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must answer the question 'How often do you ride this route?'"
                              delegate:nil
                              cancelButtonTitle:@"Okay"
                              otherButtonTitles:nil];
        [alert show];
    }
   
    else{
        /*
        if (routeFreqSelectedRow == 1){
            
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"High Route Frequency"
                                  message:@"Thank you for sharing this ride with us. If you ride this route often, there is no need to log/upload it more than a couple of times."
                                  delegate:nil
                                  cancelButtonTitle:@"Okay"
                                  otherButtonTitles:nil];
            [alert show];
        }
         */
        
        [infoTableView resignFirstResponder];
        [delegate didCancelNote];
        
        pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        details = detailTextView.text;
        
        [delegate didEnterTripDetails:details];
        
        [self done];
        
        [delegate didPickRouteFreq:tripResponse.routeFreq];
        [delegate didPickRoutePrefs:tripResponse.routePrefs];
        [delegate didPickRouteComfort:tripResponse.routeComfort];
        [delegate didPickRouteStressors:tripResponse.routeStressors];
        
        if (self.otherRoutePrefs.length>0){
            NSLog(@"Trying to save other route prefs as %@",self.otherRoutePrefs);
            [delegate didEnterOtherRoutePrefs:self.otherRoutePrefs];
        }
        
        if (self.otherRouteStressors.length>0){
            NSLog(@"Trying to save other route prefs as %@",self.otherRouteStressors);
            [delegate didEnterOtherRouteStressors:self.otherRouteStressors];
        }
        
        [delegate saveTrip];
    }
    
}

#pragma mark UITextFieldDelegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(currentTextField == routeFreq ||  currentTextField == routeComfort /*|| currentTextField == routeSafety || currentTextField == rideConflict */){
        NSLog(@"currentTextField: text2");
        [currentTextField resignFirstResponder];
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)myTextField{
    
    currentTextField = myTextField;
    
    if(myTextField == routeFreq || myTextField == routeComfort /*|| myTextField == routeSafety ||  myTextField == rideConflict */){
        
        [myTextField resignFirstResponder];
        
        if (myTextField == routeFreq){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([routeFreq respondsToSelector:@selector(setText:)]) {
                    [routeFreq performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [tripResponse.routeFreq integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    routeFreqSelectedRow = selectedIndex;
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Route Frequency" rows: routeFreqArray initialSelection:routeFreqArray[0] doneBlock:done cancelBlock:cancel origin:routeFreq];
        }
        else if (myTextField == routeComfort){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([routeComfort respondsToSelector:@selector(setText:)]) {
                    [routeComfort performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [tripResponse.routeComfort integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    routeComfortSelectedRow = selectedIndex;
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Route Comfort" rows: routeComfortArray initialSelection:routeComfortArray[0] doneBlock:done cancelBlock:cancel origin:routeComfort];
        }

        
        /*
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]; //as we want to display a subview we won't be using the default buttons but rather we're need to create a toolbar to display the buttons on
        
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        [actionSheet addSubview:pickerView];
        
        doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        doneToolbar.barStyle = UIBarStyleDefault;
        [doneToolbar sizeToFit];
        
        NSMutableArray *barItems = [[[NSMutableArray alloc] init] autorelease];
        
        UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
        [barItems addObject:flexSpace];
        
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        [barItems addObject:cancelBtn];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        [barItems addObject:doneBtn];
        
        [doneToolbar setItems:barItems animated:YES];
        
        [actionSheet addSubview:doneToolbar];
        
        selectedItem = 0;

        [pickerView selectRow:selectedItem inComponent:0 animated:NO];
        
        [pickerView reloadAllComponents];
        
        [actionSheet addSubview:pickerView];
        
        [actionSheet showInView:self.view];
        
        [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
         
         */
        
    }
}

// the user pressed the "Done" button, so dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSLog(@"textFieldShouldReturn");
	[textField resignFirstResponder];
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == detailTextView){
        [currentTextField resignFirstResponder];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        CGPoint offset = self.infoTableView.contentOffset;
        offset.y += 170; // You can change this, but 200 doesn't create any problems
        [self.infoTableView setContentOffset:offset];
        [UIView commitAnimations];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


- (void)done
{
    [detailTextView resignFirstResponder];
    
    NSLog(@"Saving Trip Response Data");
	if ( tripResponse != nil )
	{
        [tripResponse setRouteFreq:[NSNumber numberWithInt:routeFreqSelectedRow]];
        NSLog(@"saved route frew index: %@ and text: %@", tripResponse.routeFreq,routeFreq.text);
       
        NSMutableArray *checksRoutePrefs = [[NSMutableArray alloc]init];
        for (int i = 0;i<[routePrefsSelectedRows count];i++){
            NSIndexPath *indexpath = routePrefsSelectedRows[i];
            [checksRoutePrefs addObject:[NSNumber numberWithInt:indexpath.row]];
        }
        NSMutableString *routePrefsString = [[NSMutableString alloc] init];
        for (int i = 0;i<[routePrefsArray count];i++){
            if ([checksRoutePrefs containsObject:[NSNumber numberWithInt:i]]){
                [routePrefsString appendString:[NSString stringWithFormat:@"%i", 1]];
            }
            else {
                [routePrefsString appendString:[NSString stringWithFormat:@"%i", 0]];
            }
            [routePrefsString appendString:@","];
        }
        [routePrefsString deleteCharactersInRange:NSMakeRange([routePrefsString length]-1, 1)];
        [tripResponse setRoutePrefs:routePrefsString];
        NSLog(@"saved route Prefs array: %@", tripResponse.routePrefs);
///-------
        [tripResponse setRouteComfort:[NSNumber numberWithInt:routeComfortSelectedRow]];
        NSLog(@"saved route comfort index: %@ and text: %@", tripResponse.routeComfort,routeComfort.text);
        
        /*
        
        [tripResponse setRouteSafety:[NSNumber numberWithInt:routeSafetySelectedRow]];
        NSLog(@"saved route safety index: %@ and text: %@", tripResponse.routeSafety,routeSafety.text);
//----------
        NSMutableArray *checksRidePassengers = [[NSMutableArray alloc]init];
        for (int i = 0;i<[ridePassengersSelectedRows count];i++){
            NSIndexPath *indexpath = ridePassengersSelectedRows[i];
            [checksRidePassengers addObject:[NSNumber numberWithInt:indexpath.row]];
        }
        NSMutableString *ridePassengersString = [[NSMutableString alloc] init];
        for (int i = 0;i<[ridePassengersArray count];i++){
            if ([checksRidePassengers containsObject:[NSNumber numberWithInt:i]]){
                [ridePassengersString appendString:[NSString stringWithFormat:@"%i", 1]];
            }
            else {
                [ridePassengersString appendString:[NSString stringWithFormat:@"%i", 0]];
            }
            [ridePassengersString appendString:@","];
        }
        [ridePassengersString deleteCharactersInRange:NSMakeRange([ridePassengersString length]-1, 1)];
        [tripResponse setRidePassengers:ridePassengersString];
        NSLog(@"saved route Passengers array: %@", tripResponse.ridePassengers);
//----------
        NSMutableArray *checksRideSpecial = [[NSMutableArray alloc]init];
        for (int i = 0;i<[rideSpecialSelectedRows count];i++){
            NSIndexPath *indexpath = rideSpecialSelectedRows[i];
            [checksRideSpecial addObject:[NSNumber numberWithInt:indexpath.row]];
        }
        NSMutableString *rideSpecialString = [[NSMutableString alloc] init];
        for (int i = 0;i<[rideSpecialArray count];i++){
            if ([checksRideSpecial containsObject:[NSNumber numberWithInt:i]]){
                [rideSpecialString appendString:[NSString stringWithFormat:@"%i", 1]];
            }
            else {
                [rideSpecialString appendString:[NSString stringWithFormat:@"%i", 0]];
            }
            [rideSpecialString appendString:@","];
        }
        [rideSpecialString deleteCharactersInRange:NSMakeRange([rideSpecialString length]-1, 1)];
        [tripResponse setRideSpecial:rideSpecialString];
        NSLog(@"saved ride special array: %@", tripResponse.rideSpecial);
//----------
        [tripResponse setRideConflict:[NSNumber numberWithInt:rideConflictSelectedRow]];
        NSLog(@"saved ride conflict index: %@ and text: %@", tripResponse.rideConflict,rideConflict.text);
         */
//----------
        NSMutableArray *checksRouteStressors = [[NSMutableArray alloc]init];
        for (int i = 0;i<[routeStressorsSelectedRows count];i++){
            NSIndexPath *indexpath = routeStressorsSelectedRows[i];
            [checksRouteStressors addObject:[NSNumber numberWithInt:indexpath.row]];
        }
        NSMutableString *routeStressorsString = [[NSMutableString alloc] init];
        for (int i = 0;i<[routeStressorsArray count];i++){
            if ([checksRouteStressors containsObject:[NSNumber numberWithInt:i]]){
                [routeStressorsString appendString:[NSString stringWithFormat:@"%i", 1]];
            }
            else {
                [routeStressorsString appendString:[NSString stringWithFormat:@"%i", 0]];
            }
            [routeStressorsString appendString:@","];
        }
        [routeStressorsString deleteCharactersInRange:NSMakeRange([routeStressorsString length]-1, 1)];
        [tripResponse setRouteStressors:routeStressorsString];
        NSLog(@"saved route Stressors array: %@", tripResponse.routeStressors);
        
        NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Trip response save cerror %@, %@", error, [error localizedDescription]);
		}
	}
	else
		NSLog(@"ERROR can't save trip responses for nil trip response");
	
	// update UI
	
	[delegate setSaved:YES];
    //disable the save button after saving
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[self.navigationController popViewControllerAnimated:YES];
    
    NSLog(@"Saving trip response data");
    
	
}

#pragma mark Table view methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
        case 0:
			return @"How often do you ride this route?";
			break;
        case 1:
            return @"I chose this route because... (can select more than one)";
            break;
        case 2:
            return @"In terms of comfort, this route is...";
            break;
            /*
        case 3:
            return @"This route is...";
            break;
        case 4:
            return @"Who accompanied you on this ride? (can select more than one)";
            break;
        case 5:
            return @"On this ride, did you use any acessories? (can select more than one)";
            break;
        case 6:
            return @"On this route, indicate which best fits your experience";
            break;
             */
        case 3:
            return @"Along this route, you are concerned about conflicts/crashes with... (can select more than one)";
            break;
        case 4:
            return @"Additional details about your trip:";
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000]];
    
    CALayer *topLine = [CALayer layer];
    topLine.frame = CGRectMake(0, 0, 320, 0.5);
    topLine.backgroundColor = [UIColor blackColor].CGColor;
    [header.layer addSublayer:topLine];

    
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    if (section ==5){
        return 100;
    } else{
       return 0.01;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch ( section )
	{
        case 0:
            return 35;
            break;
        case 1:
            return 50;
            break;
		case 2:
			return 35;
			break;
            /*
		case 3:
			return 35;
			break;
        case 4:
			return 50;
			break;
        case 5:
			return 65;
			break;
        case 6:
            return 50;
            break;
             */
        case 3:
            return 80;
            break;
        case 4:
            return 50;
            break;
        case 5:
            return 0;
            break;
		default:
			return 0;
	}
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch ( section )
	{
        case 0:
            return 1;
            break;
        case 1:
            return 12;
            break;
        case 2:
            return 1;
            break;
            /*
        case 3:
            return 1;
            break;
        case 4:
            if (isAlone){
                return 1;
            }
            else{
                return 6;
            }
            break;
        case 5:
            if (isNone){
                return 1;
            }
            else{
                return 5;
            }
            break;
        case 6:
            return 1;
            break;
             */
        case 3:
            if (isNotConcerned){
                return 1;
            }
            else{
                return 8;
            }
            break;
        case 4:
            return 1;
            break;
        case 5:
            return 1;
            break;
        default:
            return 0;
            break;
    }
    return 0;
    [tableView reloadData];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set up the cell...
	UITableViewCell *cell = nil;
	
	// outer switch statement identifies section
	switch ([indexPath indexAtPosition:0])
	{
        case 0:
		{
			static NSString *CellIdentifier = @"CellRouteFreq";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Route Frequency";
					[cell.contentView addSubview:routeFreq];
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [cell.textLabel setNumberOfLines:0];
		}
			break;
        case 1:
		{
			static NSString *CellIdentifier = @"CellRoutePrefs";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
            if([routePrefsSelectedRows containsObject:indexPath]) { cell.accessoryType = UITableViewCellAccessoryCheckmark; } else { cell.accessoryType = UITableViewCellAccessoryNone; }
            
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];

			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = routePrefsArray[1];
                    break;
				case 1:
					cell.textLabel.text = routePrefsArray[2];
					break;
				case 2:
					cell.textLabel.text = routePrefsArray[3];
					break;
                case 3:
					cell.textLabel.text = routePrefsArray[4];
					break;
                case 4:
					cell.textLabel.text = routePrefsArray[5];
                    break;
                case 5:
					cell.textLabel.text = routePrefsArray[6];
                    break;
                case 6:
					cell.textLabel.text = routePrefsArray[7];
                    break;
                case 7:
					cell.textLabel.text = routePrefsArray[8];
                    break;
                case 8:
					cell.textLabel.text = routePrefsArray[9];
                    break;
                case 9:
					cell.textLabel.text = routePrefsArray[10];
                    break;
                case 10:
					cell.textLabel.text = routePrefsArray[11];
                    break;
                case 11:
                    if (self.otherRoutePrefs != NULL){
                        NSMutableString *otherRoutePrefsString = [NSMutableString stringWithFormat: @"Other ("];
                        [otherRoutePrefsString appendString:self.otherRoutePrefs];
                        [otherRoutePrefsString appendString:@")"];
                        cell.textLabel.text = otherRoutePrefsString;
                    } else{
                        cell.textLabel.text = routePrefsArray[12];
                    }
                    break;
			}
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [cell.textLabel setNumberOfLines:0];
		}
			break;
        case 2:
		{
			static NSString *CellIdentifier = @"CellRouteComfort";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];

			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Route Comfort";
					[cell.contentView addSubview:routeComfort];
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [cell.textLabel setNumberOfLines:0];
		}
			break;
            /*
        case 3:
		{
			static NSString *CellIdentifier = @"CellRouteSafety";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Route Safety";
					[cell.contentView addSubview:routeSafety];
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [cell.textLabel setNumberOfLines:0];
		}
			break;
            */
            /*
        case 4:
		{
			static NSString *CellIdentifier = @"CellRidePassengers";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            if([ridePassengersSelectedRows containsObject:indexPath]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            if (!ridePassengersSelectedRows || ![ridePassengersSelectedRows count]){
                // inner switch statement identifies row
                switch ([indexPath indexAtPosition:1])
                {
                    case 0:
                        cell.textLabel.text = ridePassengersArray[1];
                        break;
                    case 1:
                        cell.textLabel.text = ridePassengersArray[2];
                        break;
                    case 2:
                        cell.textLabel.text = ridePassengersArray[3];
                        break;
                    case 3:
                        cell.textLabel.text = ridePassengersArray[4];
                        break;
                    case 4:
                        cell.textLabel.text = ridePassengersArray[5];
                        break;
                    case 5:
                        cell.textLabel.text = ridePassengersArray[6];
                        break;
                }

            }
            
            else if (isAlone){
                switch ([indexPath indexAtPosition:1])
                {
                    case 0:
                        cell.textLabel.text = ridePassengersArray[1];
                        break;
                }
            }
            else{
                // inner switch statement identifies row
                switch ([indexPath indexAtPosition:1])
                {
                    case 0:
                        cell.hidden = true;
                        break;
                    case 1:
                        cell.textLabel.text = ridePassengersArray[2];
                        break;
                    case 2:
                        cell.textLabel.text = ridePassengersArray[3];
                        break;
                    case 3:
                        cell.textLabel.text = ridePassengersArray[4];
                        break;
                    case 4:
                        cell.textLabel.text = ridePassengersArray[5];
                        break;
                    case 5:
                        cell.textLabel.text = ridePassengersArray[6];
                        break;
                }
            }
            
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [cell.textLabel setNumberOfLines:0];
		}
			break;
            */
            
        /*
        case 5:
		{
			static NSString *CellIdentifier = @"CellRideSpecial";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
            if([rideSpecialSelectedRows containsObject:indexPath]) { cell.accessoryType = UITableViewCellAccessoryCheckmark; } else { cell.accessoryType = UITableViewCellAccessoryNone; }
            
            if (!rideSpecialSelectedRows || ![rideSpecialSelectedRows count]){
                // inner switch statement identifies row
                switch ([indexPath indexAtPosition:1])
                {
                    case 0:
                        cell.textLabel.text = rideSpecialArray[0];
                        break;
                    case 1:
                        cell.textLabel.text = rideSpecialArray[1];
                        break;
                    case 2:
                        cell.textLabel.text = rideSpecialArray[2];
                        break;
                    case 3:
                        cell.textLabel.text = rideSpecialArray[3];
                        break;
                    case 4:
                        cell.textLabel.text = rideSpecialArray[4];
                        break;
                        
                }
            }
            else if (isNone){
                // inner switch statement identifies row
                switch ([indexPath indexAtPosition:1])
                {
                    case 0:
                        cell.textLabel.text = rideSpecialArray[0];
                        break;
                }
            }
            else{
                // inner switch statement identifies row
                switch ([indexPath indexAtPosition:1])
                {
                    case 0:
                        cell.hidden = true;
                        break;
                    case 1:
                        cell.textLabel.text = rideSpecialArray[1];
                        break;
                    case 2:
                        cell.textLabel.text = rideSpecialArray[2];
                        break;
                    case 3:
                        cell.textLabel.text = rideSpecialArray[3];
                        break;
                    case 4:
                        cell.textLabel.text = rideSpecialArray[4];
                        break;
                        
                }
            }
			
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [cell.textLabel setNumberOfLines:0];
		}
			break;
        
        case 6:
		{
			static NSString *CellIdentifier = @"CellRideConflict";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Ride Conlict";
					[cell.contentView addSubview:rideConflict];
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [cell.textLabel setNumberOfLines:0];
		}
			break;
          */
        case 3:
		{
			static NSString *CellIdentifier = @"CellRouteStressors";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];

            if([routeStressorsSelectedRows containsObject:indexPath]) { cell.accessoryType = UITableViewCellAccessoryCheckmark; } else { cell.accessoryType = UITableViewCellAccessoryNone; }
            
            if (!routeStressorsSelectedRows || ![routeStressorsSelectedRows count]){
                // inner switch statement identifies row
                switch ([indexPath indexAtPosition:1])
                {
                    case 0:
                        cell.textLabel.text = routeStressorsArray[1];
                        break;
                    case 1:
                        cell.textLabel.text = routeStressorsArray[2];
                        break;
                    case 2:
                        cell.textLabel.text = routeStressorsArray[3];
                        break;
                    case 3:
                        cell.textLabel.text = routeStressorsArray[4];
                        break;
                    case 4:
                        cell.textLabel.text = routeStressorsArray[5];
                        break;
                    case 5:
                        cell.textLabel.text = routeStressorsArray[6];
                        break;
                    case 6:
                        cell.textLabel.text = routeStressorsArray[7];
                        break;
                    case 7:
                        if (self.otherRouteStressors != NULL){
                            NSMutableString *otherRouteStressorsString = [NSMutableString stringWithFormat: @"Other ("];
                            [otherRouteStressorsString appendString:self.otherRouteStressors];
                            [otherRouteStressorsString appendString:@")"];
                            cell.textLabel.text = otherRouteStressorsString;
                        } else{
                            cell.textLabel.text = routeStressorsArray[8];
                        }
                        break;
                }
            }
            else if (isNotConcerned){
                // inner switch statement identifies row
                switch ([indexPath indexAtPosition:1])
                {
                    case 0:
                        cell.textLabel.text = routeStressorsArray[1];
                        break;
                }
            }
            else{
                // inner switch statement identifies row
                switch ([indexPath indexAtPosition:1])
                {
                    case 0:
                        cell.hidden = true;
                        break;
                    case 1:
                        cell.textLabel.text = routeStressorsArray[2];
                        break;
                    case 2:
                        cell.textLabel.text = routeStressorsArray[3];
                        break;
                    case 3:
                        cell.textLabel.text = routeStressorsArray[4];
                        break;
                    case 4:
                        cell.textLabel.text = routeStressorsArray[5];
                        break;
                    case 5:
                        cell.textLabel.text = routeStressorsArray[6];
                        break;
                    case 6:
                        cell.textLabel.text = routeStressorsArray[7];
                        break;
                    case 7:
                        cell.textLabel.text = routeStressorsArray[8];
                        break;
                }
            }

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [cell.textLabel setNumberOfLines:0];
		}
			break;
        case 4:
        {
            static NSString *CellIdentifier = @"CellDetails";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            // inner switch statement identifies row
            switch ([indexPath indexAtPosition:1])
            {
                case 0:
                    cell.textLabel.text = @"Details";
                    [cell.contentView addSubview:detailTextView];
                    break;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 5:
        {
            static NSString *CellIdentifier = @"CellSaveUser";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.backgroundColor = [UIColor colorWithRed:106.0f/255.0f green:127.0f/255.0f  blue:16.0f/255.0f  alpha:1.000];
            cell.textLabel.textColor = [UIColor whiteColor];
            // inner switch statement identifies row
            switch ([indexPath indexAtPosition:1])
            {
                case 0:
                    cell.textLabel.text = @"Save";
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    break;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] == 4){
        return 115;
    }
    else{
        return 43;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog (@"Selected index path = %@", indexPath);
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch ([indexPath indexAtPosition:0])
	{
		case 0:
		{
            switch ([indexPath indexAtPosition:1])
			{
				case 0:
					break;
				case 1:
					break;
			}
			break;
        }
        case 1:
		{
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType == UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [routePrefsSelectedRows addObject:indexPath];
                if ([indexPath indexAtPosition:1]==11){
                    NSLog(@"Trying to bring up other text view");
                    UIAlertView* otherRoutePrefsView = [[UIAlertView alloc] initWithTitle:@"Other Preferences" message:@"Please describe why you chose this route" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                    otherRoutePrefsView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [otherRoutePrefsView show];
                }
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [routePrefsSelectedRows removeObject:indexPath];
            }
            break;
        }
        case 2:
		{
            switch ([indexPath indexAtPosition:1])
			{
				case 0:
					break;
				case 1:
					break;
			}
			break;
        }
            /*
        case 3:
		{
            switch ([indexPath indexAtPosition:1])
			{
				case 0:
					break;
				case 1:
					break;
			}
			break;
        }
        case 4:
		{
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType == UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [ridePassengersSelectedRows addObject:indexPath];
                if ([indexPath indexAtPosition:1] ==0){
                    isAlone = true;
                    
                }
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [ridePassengersSelectedRows removeObject:indexPath];
                if ([indexPath indexAtPosition:1] ==0){
                    isAlone = false;
                }
            }
            break;
        }
        case 5:
		{
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType == UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [rideSpecialSelectedRows addObject:indexPath];
                if ([indexPath indexAtPosition:1] ==0){
                    isNone = true;
                }
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [rideSpecialSelectedRows removeObject:indexPath];
                if ([indexPath indexAtPosition:1] ==0){
                    isNone = false;
                }
            }
            break;
        }
        case 6:
		{
            switch ([indexPath indexAtPosition:1])
			{
				case 0:
					break;
				case 1:
					break;
			}
			break;
        }
             */
        case 3:
		{
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType == UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [routeStressorsSelectedRows addObject:indexPath];
                if ([indexPath indexAtPosition:1] ==0){
                    isNotConcerned = true;
                }
                if ([indexPath indexAtPosition:1]==7){
                    NSLog(@"Trying to bring up other text view");
                    UIAlertView* otherRouteStressorsView = [[UIAlertView alloc] initWithTitle:@"Other Stressors" message:@"Please describe any other transportation modes you are concerned about conflicts/crashes with" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                    otherRouteStressorsView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [otherRouteStressorsView show];
                }
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [routeStressorsSelectedRows removeObject:indexPath];
                if ([indexPath indexAtPosition:1] ==0){
                    isNotConcerned = false;
                }
            }
            
            break;
        }
        case 4:
        {
            switch ([indexPath indexAtPosition:1])
            {
                case 0:
                    break;
                case 1:
                    break;
            }
            break;
        }
        case 5:
        {
            switch ([indexPath indexAtPosition:1])
            {
                case 0:{
                    [self saveDetail:nil];
                }
            }
            break;
        }
    }
    [tableView reloadData];
    //NSLog(@"isAlone = %i",isAlone);
    //NSLog(@"isNone = %i",isNone);

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Other Preferences"]){
        NSLog(@"Button Index =%ld",(long)buttonIndex);
        if (buttonIndex == 1) {  //Okay
            UITextField *otherRoutePrefsField= [alertView textFieldAtIndex:0];
            self.otherRoutePrefs = otherRoutePrefsField.text;
            if (self.otherRoutePrefs != NULL){
                NSMutableString *otherRoutePrefsString = [NSMutableString stringWithFormat: @"Other ("];
                [otherRoutePrefsString appendString:self.otherRoutePrefs];
                [otherRoutePrefsString appendString:@")"];
                NSIndexPath *index =  [NSIndexPath indexPathForRow:11 inSection:1];
                UITableViewCell *cell = [self.infoTableView cellForRowAtIndexPath: index];
                cell.textLabel.text = otherRoutePrefsString;
            }
        }
        
    }
    else if ([alertView.title isEqualToString:@"Other Stressors"]){
        NSLog(@"Button Index =%ld",(long)buttonIndex);
        if (buttonIndex == 1) {  //Okay
            UITextField *otherRouteStressorsField= [alertView textFieldAtIndex:0];
            self.otherRouteStressors = otherRouteStressorsField.text;
            if (self.otherRouteStressors != NULL){
                NSMutableString *otherRouteStressorsString = [NSMutableString stringWithFormat: @"Other ("];
                [otherRouteStressorsString appendString:self.otherRouteStressors];
                [otherRouteStressorsString appendString:@")"];
                NSIndexPath *index =  [NSIndexPath indexPathForRow:7 inSection:3];
                UITableViewCell *cell = [self.infoTableView cellForRowAtIndexPath: index];
                cell.textLabel.text = otherRouteStressorsString;
            }
        }
        NSLog(@"Saved other route prefs as = %@",self.otherRouteStressors);
    }
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if(currentTextField == routeFreq){
        return [routeFreqArray count];
    }
    else if(currentTextField == routeComfort){
        return [routeComfortArray count];
    }
    /*
    else if(currentTextField == routeSafety){
        return [routeSafetyArray count];
    }
    else if(currentTextField == rideConflict){
        return [rideConflictArray count];
    }
     */
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        
        CGRect frame = CGRectMake(0.0, 0.0, 320, 200);
        tView = [[UILabel alloc] initWithFrame:frame];
        [tView setFont:[UIFont fontWithName:@"Helvetica" size:15]];
        [tView setTextAlignment:NSTextAlignmentCenter];
        tView.lineBreakMode = NSLineBreakByWordWrapping;
        //tView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [tView setNumberOfLines:0];
    }
    if(currentTextField == routeFreq){
        tView.text =  [routeFreqArray objectAtIndex:row];
    }
    else if(currentTextField == routeComfort){
        tView.text =  [routeComfortArray objectAtIndex:row];
    }
    /*
    else if(currentTextField == routeSafety){
        tView.text =  [routeSafetyArray objectAtIndex:row];
    }
    else if(currentTextField == rideConflict){
        tView.text =  [rideConflictArray objectAtIndex:row];
    }
     */
    return tView;
}

- (void)cancelButtonPressed:(id)sender{
    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
}
/*

- (void)doneButtonPressed:(id)sender{
    
    NSInteger selectedRow;
    selectedRow = [pickerView selectedRowInComponent:0];
    if(currentTextField == routeFreq){
        //enable save button
        self.navigationItem.rightBarButtonItem.enabled = YES;
        routeFreqSelectedRow = selectedRow;
        NSString *routeFreqSelect = [routeFreqArray objectAtIndex:selectedRow];
        routeFreq.text = routeFreqSelect;
    }
    if(currentTextField == routePrefs){
        //enable save button if value has been changed.
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    if(currentTextField == routeComfort){
        self.navigationItem.rightBarButtonItem.enabled = YES;
        routeComfortSelectedRow = selectedRow;
        NSString *routeComfortSelect = [routeComfortArray objectAtIndex:selectedRow];
        routeComfort.text = routeComfortSelect;
    }

    if(currentTextField == routeSafety){
        //enable save button if value has been changed.
        self.navigationItem.rightBarButtonItem.enabled = YES;
        routeSafetySelectedRow = selectedRow;
        NSString *routeSafetySelect = [routeSafetyArray objectAtIndex:selectedRow];
        routeSafety.text = routeSafetySelect;
    }
    if(currentTextField == ridePassengers){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    if(currentTextField == rideSpecial){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    if(currentTextField == rideConflict){
        //enable save button if value has been changed.
        self.navigationItem.rightBarButtonItem.enabled = YES;
        rideConflictSelectedRow = selectedRow;
        NSString *rideConflictSelect = [rideConflictArray objectAtIndex:selectedRow];
        rideConflict.text = rideConflictSelect;
    }
 
    if(currentTextField == routeStressors){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.delegate = nil;
    self.detailTextView = nil;
    self.managedObjectContext = nil;
    self.routeFreq = nil;
    self.routeFreqSelectedRow = nil;
    self.routePrefs = nil;
    self.routePrefsSelectedRows = nil;
    self.routeSafety = nil;
    self.routeSafetySelectedRow = nil;
    self.routeComfort = nil;
    self.routeComfortSelectedRow = nil;
    self.ridePassengers = nil;
    self.ridePassengersSelectedRows = nil;
    self.rideSpecial = nil;
    self.rideSpecialSelectedRows = nil;
    self.routeStressors = nil;
    self.routeStressorsSelectedRows = nil;
    self.rideConflict = nil;
    self.rideConflictSelectedRow = nil;
    
    [delegate release];
    [detailTextView release];
    [tripResponse release];
    [managedObjectContext release];
    [routeFreq release];
    [routePrefs release];
    [routeComfort release];
    [routeSafety release];
    [ridePassengers release];
    [rideSpecial release];
    [rideConflict release];
    [routeStressors release];
    [doneToolbar release];
    [actionSheet release];
    [pickerView release];
    [currentTextField release];
    [routeFreqArray release];
    [routePrefsArray release];
    [routeComfortArray release];
    [routeSafetyArray release];
    [ridePassengersArray release];
    [rideSpecialArray release];
    [rideConflictArray release];
    [routeStressorsArray release];
    
    [super dealloc];
}

@end
