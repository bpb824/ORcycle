//
//  NoteDetailViewController.m
//  ORcycle
//
//  Created by orcycle on 8/29/14.
//
//

#import "CrashDetailViewController.h"
#import "NoteResponse.h"
#import "constants.h"
#import "ActionSheetStringPicker.h"
#import "SetReportLocationViewController.h"
#import "ActionSheetDatePicker.h"
#import "NSDate+TCUtils.h"


@interface CrashDetailViewController ()

@end

@implementation CrashDetailViewController
@synthesize noteDelegate, appDelegate, managedObjectContext, infoTableView, noteResponse;
@synthesize severity;
@synthesize severitySelectedRow, conflictWithSelectedRows, selectedItem, selectedItems, crashActionsSelectedRows, crashReasonsSelectedRows, otherCrashActions, otherCrashReasons, otherConflictWith, gpsLoc, customLoc,customDate, nowDate, reportDate;

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

- (NoteResponse *)createNoteResponse
{
	// Create and configure a new instance of the User entity
	NoteResponse *newForm = (NoteResponse *)[[NSEntityDescription insertNewObjectForEntityForName:@"NoteResponse" inManagedObjectContext:managedObjectContext] retain];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"createNoteResponse error %@, %@", error, [error localizedDescription]);
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
    
    severityArray = [[NSArray alloc] initWithObjects: @"", @"Major injuries (requried hospitalization)", @"Severe (required a visit to ER)", @"Minor injury (no visit to ER)", @"Property damage only (bicycle damaged but no personal injuries)", @"Near-miss (no damage or injury)",  nil];
    conflictWithArray = [[NSArray alloc] initWithObjects: @" ", @"Small/medium car", @"Large car/Van/SUV", @"Pickup truck", @"Large commercial vehicles (trucks)", @"Public transportation (buses, light rail, streetcar)", @"Another bicycle", @"Pedestrian", @"Pole or fixed object", @"Cyclist fell (or almost fell)",@"Other (specify)", nil];
    crashActionsArray = [[NSArray alloc] initWithObjects: @" ", @"Right-turning vehicle", @"Left-turning vehicle", @"Parking or backing up vehicle", @"Person exiting a vehicle", @"Cyclist changed lane or direction of travel", @"Vehicle changed lane or direction of travel", @"Cyclist did not stop", @"Driver did not stop", @"Cyclist lost control of the bike",@"Other (specify)", nil];
    crashReasonsArray = [[NSArray alloc] initWithObjects: @" ", @"Debris or pavement quality", @"Poor lighting or visibility", @"Cyclist was outside bike lane or area", @"Vehicle entered bike lane or area", @"Cyclist did not obey stop sign or red light", @"Vehicle did not obey stop sign or red light", @"Cyclist did not yield", @"Vehicle did not yield", @"Cyclist was distracted", @"Careless driving or high vehicle speed", @"Other (specify)", nil];
    
    conflictWithSelectedRows = [[NSMutableArray alloc] init];
    crashActionsSelectedRows = [[NSMutableArray alloc] init];
    crashReasonsSelectedRows = [[NSMutableArray alloc] init];
    
    customLoc = false;
    gpsLoc = false;
    
    customDate = false;
    nowDate = false;
    self.reportDate = [[NSDate date] retain];

   
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    self.severity = [self initTextFieldAlpha];

    [self setNoteResponse:[self createNoteResponse]];
    
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

-(IBAction)back:(id)sender{
    NSLog(@"Back out from Note Detail");
    
    [infoTableView resignFirstResponder];
    
   [noteDelegate didCancelNoteDelete];
}

-(IBAction)saveDetail:(id)sender{
    NSLog(@"Save Detail");
    
    NSInteger numFields = 0;
    BOOL didPickLoc = false;
    BOOL didPickDate = false;
    
    if (severitySelectedRow < 10 && severitySelectedRow !=0){
        numFields = numFields +1;
    }
    if (!([conflictWithSelectedRows count]==0)){
        numFields = numFields +1;
    }
    if (!([crashActionsSelectedRows count]==0)){
        numFields = numFields +1;
    }
    if (!([crashReasonsSelectedRows count]==0)){
        numFields = numFields +1;
    }
    if (customLoc || gpsLoc){
        didPickLoc = true;
    }
    
    if (nowDate || customDate ){
        didPickDate = true;
    }
    
    if (numFields < 4 && didPickLoc == false && didPickDate == false){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must answer all questions about the crash event and choose the location and date of the crash event."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (numFields >= 4 && didPickLoc == false && didPickDate == false){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must choose the location and date of the crash event."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (numFields < 4 && didPickLoc == true && didPickDate == true){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must answer all questions about the crash event."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (numFields >= 4 && didPickLoc == true && didPickDate == false){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must choose the date of the crash event."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    
    else if (numFields < 4 && didPickLoc == true && didPickDate == false){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must answer all questions about the crash event and choose the date of the crash event."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (numFields < 4 && didPickLoc == false && didPickDate == true){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must answer all questions about the crash event and choose the location of the crash event."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (numFields >= 4 && didPickLoc == false && didPickDate == true){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must choose the location of the crash event."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    
    else{
        [infoTableView resignFirstResponder];
        
        [noteDelegate didPickNoteType:[NSNumber numberWithInt:severitySelectedRow]];
        
        [self done];
        
        [noteDelegate didPickConflictWith:noteResponse.conflictWith];
        
        [noteDelegate didPickCrashActions:noteResponse.crashActions];
        
        [noteDelegate didPickCrashReasons:noteResponse.crashReasons];
        
        [noteDelegate didEnterOtherConflictWith:self.otherConflictWith];
        
        [noteDelegate didEnterOtherCrashActions: self.otherCrashActions];
        
        [noteDelegate didEnterOtherCrashReasons: self.otherCrashReasons];
        
        [noteDelegate didPickReportDate:self.reportDate];
        
        [noteDelegate didPickIsCrash: true];
        
        [noteDelegate openDetailPage];
    }

}

#pragma mark UITextFieldDelegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(currentTextField == severity ){
        NSLog(@"currentTextField: text2");
        //[currentTextField resignFirstResponder];
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)myTextField{
    
    currentTextField = myTextField;
    
    if(myTextField == severity){
        
        [myTextField resignFirstResponder];
        
        if (myTextField == severity){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([severity respondsToSelector:@selector(setText:)]) {
                    [severity performSelector:@selector(setText:) withObject:selectedValue];
                    NSLog(@"Picker: %@", picker);
                    NSLog(@"Selected Index: %ld", (long)selectedIndex);
                    NSLog(@"Selected Value: %@", selectedValue);
                    
                    if (selectedIndex != [noteResponse.severity integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    severitySelectedRow = selectedIndex;
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Crash Severity" rows: severityArray initialSelection:severityArray[0] doneBlock:done cancelBlock:cancel origin:severity];
        }
    }
}

// the user pressed the "Done" button, so dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSLog(@"textFieldShouldReturn");
	[textField resignFirstResponder];
	return YES;
}

- (void)done
{
    NSLog(@"Saving Note Response Data");
	if ( noteResponse != nil )
	{
        //[noteResponse setIsCrash:true];
        
        [noteResponse setSeverity:[NSNumber numberWithInt:severitySelectedRow]];
        NSLog(@"saved severity index: %@ and text: %@", noteResponse.severity,severity.text);
        
        NSMutableArray *checksConflictWith = [[NSMutableArray alloc]init];
        for (int i = 0;i<[conflictWithSelectedRows count];i++){
            NSIndexPath *indexpath = conflictWithSelectedRows[i];
            [checksConflictWith addObject:[NSNumber numberWithInt:indexpath.row]];
        }
        NSMutableString *conflictWithString = [[NSMutableString alloc] init];
        for (int i = 0;i<[conflictWithArray count];i++){
            if ([checksConflictWith containsObject:[NSNumber numberWithInt:i]]){
                [conflictWithString appendString:[NSString stringWithFormat:@"%i", 1]];
            }
            else {
                [conflictWithString appendString:[NSString stringWithFormat:@"%i", 0]];
            }
            [conflictWithString appendString:@","];
        }
        [conflictWithString deleteCharactersInRange:NSMakeRange([conflictWithString length]-1, 1)];
        [noteResponse setConflictWith:conflictWithString];
        NSLog(@"saved conflict with array: %@", noteResponse.conflictWith);
        
        NSMutableArray *checkscrashReasons = [[NSMutableArray alloc]init];
        for (int i = 0;i<[crashReasonsSelectedRows count];i++){
            NSIndexPath *indexpath = crashReasonsSelectedRows[i];
            [checkscrashReasons addObject:[NSNumber numberWithInt:indexpath.row]];
        }
        NSMutableString *crashReasonsString = [[NSMutableString alloc] init];
        for (int i = 0;i<[crashReasonsArray count];i++){
            if ([checkscrashReasons containsObject:[NSNumber numberWithInt:i]]){
                [crashReasonsString appendString:[NSString stringWithFormat:@"%i", 1]];
            }
            else {
                [crashReasonsString appendString:[NSString stringWithFormat:@"%i", 0]];
            }
            [crashReasonsString appendString:@","];
        }
        [crashReasonsString deleteCharactersInRange:NSMakeRange([crashReasonsString length]-1, 1)];
        [noteResponse setCrashReasons:crashReasonsString];
        NSLog(@"saved conflict with array: %@", noteResponse.crashReasons);
        
        NSMutableArray *checkscrashActions = [[NSMutableArray alloc]init];
        for (int i = 0;i<[crashActionsSelectedRows count];i++){
            NSIndexPath *indexpath = crashActionsSelectedRows[i];
            [checkscrashActions addObject:[NSNumber numberWithInt:indexpath.row]];
        }
        NSMutableString *crashActionsString = [[NSMutableString alloc] init];
        for (int i = 0;i<[crashActionsArray count];i++){
            if ([checkscrashActions containsObject:[NSNumber numberWithInt:i]]){
                [crashActionsString appendString:[NSString stringWithFormat:@"%i", 1]];
            }
            else {
                [crashActionsString appendString:[NSString stringWithFormat:@"%i", 0]];
            }
            [crashActionsString appendString:@","];
        }
        [crashActionsString deleteCharactersInRange:NSMakeRange([crashActionsString length]-1, 1)];
        [noteResponse setCrashActions:crashActionsString];
        NSLog(@"saved conflict with array: %@", noteResponse.crashActions);
        
        
        NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Trip response save cerror %@, %@", error, [error localizedDescription]);
		}
	}
	else
		NSLog(@"ERROR can't save trip responses for nil trip response");
	
	// update UI
	
	[noteDelegate setSaved:YES];
    //disable the save button after saving
	self.navigationItem.rightBarButtonItem.enabled = NO;
	//[self.navigationController popViewControllerAnimated:YES];
    
    NSLog(@"Successfully finished done function inside notedetailviewcontroller");
}


#pragma mark Table view methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
        case 0:
			return @"Severity of the crash event (choose one)";
			break;
        case 1:
            return @"Vehicle or object related to the event (can select more than one)";
            break;
        case 2:
            return @"Actions related to the event (can select more than one)";
            break;
        case 3:
            return @"What contributed to the event (can select more than one)";
            break;
        case 4:
            return @"Location of crash event";
            break;
        case 5:
            return @"Date of crash event";
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
    if (section ==6){
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
            return 50;
            break;
		case 1:
			return 50;
			break;
        case 2:
            return 50;
            break;
        case 3:
            return 50;
            break;
        case 4:
            return 35;
            break;
        case 5:
            return 35;
            break;
        case 6:
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
            return 10;
            break;
        case 2:
            return 10;
            break;
        case 3:
            return 11;
            break;
        case 4:
            return 2;
            break;
        case 5:
            return 2;
            break;
        case 6:
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
			static NSString *CellIdentifier = @"CellSeverity";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Severity";
					[cell.contentView addSubview:severity];
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
            static NSString *CellIdentifier = @"CellConflictWith";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            if([conflictWithSelectedRows containsObject:indexPath]) { cell.accessoryType = UITableViewCellAccessoryCheckmark; } else { cell.accessoryType = UITableViewCellAccessoryNone; }
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            
            // inner switch statement identifies row
            switch ([indexPath indexAtPosition:1])
            {
                case 0:
                    cell.textLabel.text = conflictWithArray[1];
                    break;
                case 1:
                    cell.textLabel.text = conflictWithArray[2];
                    break;
                case 2:
                    cell.textLabel.text = conflictWithArray[3];
                    break;
                case 3:
                    cell.textLabel.text = conflictWithArray[4];
                    break;
                case 4:
                    cell.textLabel.text = conflictWithArray[5];
                    break;
                case 5:
                    cell.textLabel.text = conflictWithArray[6];
                    break;
                case 6:
                    cell.textLabel.text = conflictWithArray[7];
                    break;
                case 7:
                    cell.textLabel.text = conflictWithArray[8];
                    break;
                case 8:
                    cell.textLabel.text = conflictWithArray[9];
                    break;
                case 9:
                    if (self.otherConflictWith != NULL){
                        NSMutableString *otherConflictWithString = [NSMutableString stringWithFormat: @"Other ("];
                        [otherConflictWithString appendString:self.otherConflictWith];
                        [otherConflictWithString appendString:@")"];
                        cell.textLabel.text = otherConflictWithString;
                    }
                    else{
                        cell.textLabel.text = conflictWithArray[10];
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
            static NSString *CellIdentifier = @"CellCrashActions";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            if([crashActionsSelectedRows containsObject:indexPath]) { cell.accessoryType = UITableViewCellAccessoryCheckmark; } else { cell.accessoryType = UITableViewCellAccessoryNone; }
            
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            // inner switch statement identifies row
            switch ([indexPath indexAtPosition:1])
            {
                case 0:
                    cell.textLabel.text = crashActionsArray[1];
                    break;
                case 1:
                    cell.textLabel.text = crashActionsArray[2];
                    break;
                case 2:
                    cell.textLabel.text = crashActionsArray[3];
                    break;
                case 3:
                    cell.textLabel.text = crashActionsArray[4];
                    break;
                case 4:
                    cell.textLabel.text = crashActionsArray[5];
                    break;
                case 5:
                    cell.textLabel.text = crashActionsArray[6];
                    break;
                case 6:
                    cell.textLabel.text = crashActionsArray[7];
                    break;
                case 7:
                    cell.textLabel.text = crashActionsArray[8];
                    break;
                case 8:
                    cell.textLabel.text = crashActionsArray[9];
                    break;
                case 9:
                    if (self.otherCrashActions != NULL){
                        NSMutableString *othercrashActionsString = [NSMutableString stringWithFormat: @"Other ("];
                        [othercrashActionsString appendString:self.otherCrashActions];
                        [othercrashActionsString appendString:@")"];
                        cell.textLabel.text = othercrashActionsString;
                    }
                    else{
                        cell.textLabel.text = crashActionsArray[10];
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
        case 3:
        {
            static NSString *CellIdentifier = @"CellCrashReasons";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            if([crashReasonsSelectedRows containsObject:indexPath]) { cell.accessoryType = UITableViewCellAccessoryCheckmark; } else { cell.accessoryType = UITableViewCellAccessoryNone; }
            
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            // inner switch statement identifies row
            switch ([indexPath indexAtPosition:1])
            {
                case 0:
                    cell.textLabel.text = crashReasonsArray[1];
                    break;
                case 1:
                    cell.textLabel.text = crashReasonsArray[2];
                    break;
                case 2:
                    cell.textLabel.text = crashReasonsArray[3];
                    break;
                case 3:
                    cell.textLabel.text = crashReasonsArray[4];
                    break;
                case 4:
                    cell.textLabel.text = crashReasonsArray[5];
                    break;
                case 5:
                    cell.textLabel.text = crashReasonsArray[6];
                    break;
                case 6:
                    cell.textLabel.text = crashReasonsArray[7];
                    break;
                case 7:
                    cell.textLabel.text = crashReasonsArray[8];
                    break;
                case 8:
                    cell.textLabel.text = crashReasonsArray[9];
                    break;
                case 9:
                    cell.textLabel.text = crashReasonsArray[10];
                    break;
                case 10:
                    if (self.otherCrashReasons != NULL){
                        NSMutableString *othercrashReasonsString = [NSMutableString stringWithFormat: @"Other ("];
                        [othercrashReasonsString appendString:self.otherCrashReasons];
                        [othercrashReasonsString appendString:@")"];
                        cell.textLabel.text = othercrashReasonsString;
                    }
                    else{
                        cell.textLabel.text = crashReasonsArray[11];
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
        case 4:
        {
            static NSString *CellIdentifier = @"CellPickLocation";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            
            // inner switch statement identifies row
            switch ([indexPath indexAtPosition:1])
            {
                case 0:
                    cell.textLabel.text = @"Use current GPS location";
                    if(gpsLoc) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark; }
                    else { cell.accessoryType = UITableViewCellAccessoryNone; }
                    break;
                case 1:
                    cell.textLabel.text = @"Pick custom location";
                    if(customLoc) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark; }
                    else { cell.accessoryType = UITableViewCellAccessoryNone; }
                    break;
                            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [cell.textLabel setNumberOfLines:0];
            }
            break;
        case 5:
        {
            static NSString *CellIdentifier = @"CellPickTime";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            // inner switch statement identifies row
            switch ([indexPath indexAtPosition:1])
            {
                case 0:
                    cell.textLabel.text = @"Today";
                    if(nowDate) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark; }
                    else { cell.accessoryType = UITableViewCellAccessoryNone; }
                    break;
                case 1:
                    
                    if(customDate) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        NSDateFormatter *outputDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                        [outputDateFormatter setDateStyle:kCFDateFormatterLongStyle];
                        cell.textLabel.text = [outputDateFormatter stringFromDate:self.reportDate];
                    }
                    else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.textLabel.text = @"Pick another date...";
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
        case 6:
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog (@"Selected index path = %@", indexPath);
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
                [conflictWithSelectedRows addObject:indexPath];
                if ([indexPath indexAtPosition:1]==9){
                    //NSLog(@"Trying to bring up other text view");
                    UIAlertView* otherConflictWithView = [[UIAlertView alloc] initWithTitle:@"Other Conflict" message:@"Please describe the conflict you experienced" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                    otherConflictWithView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [otherConflictWithView show];
                }

            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [conflictWithSelectedRows removeObject:indexPath];
            }
            break;
        }
        case 2:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType == UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [crashActionsSelectedRows addObject:indexPath];
                if ([indexPath indexAtPosition:1]==9){
                    //NSLog(@"Trying to bring up other text view");
                    UIAlertView* othercrashActionsView = [[UIAlertView alloc] initWithTitle:@"Other Action" message:@"Please describe the action related to the event" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                    othercrashActionsView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [othercrashActionsView show];
                }
                
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [crashActionsSelectedRows removeObject:indexPath];
            }
            break;
        }

        case 3:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType == UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [crashReasonsSelectedRows addObject:indexPath];
                if ([indexPath indexAtPosition:1]==10){
                    //NSLog(@"Trying to bring up other text view");
                    UIAlertView* othercrashReasonsView = [[UIAlertView alloc] initWithTitle:@"Other Cause" message:@"Please describe the cause of the event" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                    othercrashReasonsView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [othercrashReasonsView show];
                }
                
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [crashReasonsSelectedRows removeObject:indexPath];
            }
            break;
        }
        case 4:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            switch ([indexPath indexAtPosition:1])
            {
                case 0:{
                    NSIndexPath *customIndex = [NSIndexPath indexPathForRow:1 inSection:4];
                    UITableViewCell *customCell = [infoTableView cellForRowAtIndexPath:customIndex];
                    if(cell.accessoryType == UITableViewCellAccessoryNone && customCell.accessoryType == UITableViewCellAccessoryNone) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        gpsLoc = true;
                        customLoc = false;
                    }
                    else if (cell.accessoryType ==UITableViewCellAccessoryNone && customCell.accessoryType == UITableViewCellAccessoryCheckmark){
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        customCell.accessoryType = UITableViewCellAccessoryNone;
                        gpsLoc = true;
                        customLoc = false;
                        [noteDelegate revertGPSLocation];
                    }
                    else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        gpsLoc = false;
                    }
                }

                    break;
                case 1:{
                    
                    NSIndexPath *gpsIndex = [NSIndexPath indexPathForRow:0 inSection:4];
                    UITableViewCell *gpsCell = [infoTableView cellForRowAtIndexPath:gpsIndex];
                    
                    if(cell.accessoryType == UITableViewCellAccessoryNone && gpsCell.accessoryType == UITableViewCellAccessoryNone) {
                        //NSLog(@"Nav controller = %@", self.navigationController);
                        SetReportLocationViewController *pickLocationView = [[SetReportLocationViewController alloc] initWithNibName:@"SetReportLocationView" bundle:nil];
                        
                        [pickLocationView setNoteDelegate:noteDelegate];
                        [self presentViewController:pickLocationView animated:YES completion:nil];
                        
                        [pickLocationView release];
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        customLoc = true;
                        gpsLoc = false;
                    }
                    else if (cell.accessoryType == UITableViewCellAccessoryNone && gpsCell.accessoryType == UITableViewCellAccessoryCheckmark){
                        //NSLog(@"Nav controller = %@", self.navigationController);
                        SetReportLocationViewController *pickLocationView = [[SetReportLocationViewController alloc] initWithNibName:@"SetReportLocationView" bundle:nil];
                        
                        [pickLocationView setNoteDelegate:noteDelegate];
                        [self presentViewController:pickLocationView animated:YES completion:nil];
                        
                        [pickLocationView release];
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        customLoc = true;
                        gpsLoc = false;
                        gpsCell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        customLoc = false;
                        gpsLoc = true;
                        gpsCell.accessoryType = UITableViewCellAccessoryCheckmark;
                        [noteDelegate revertGPSLocation];
                    }

                    break;
                }
                    break;
            }
            break;
        }
        case 5:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            switch ([indexPath indexAtPosition:1])
            {
                case 0:{
                    NSIndexPath *customIndex = [NSIndexPath indexPathForRow:1 inSection:5];
                    UITableViewCell *customCell = [infoTableView cellForRowAtIndexPath:customIndex];
                    if(cell.accessoryType == UITableViewCellAccessoryNone && customCell.accessoryType == UITableViewCellAccessoryNone) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        nowDate = true;
                        customDate = false;
                        self.reportDate = [[NSDate date]retain];
                    }
                    else if (cell.accessoryType ==UITableViewCellAccessoryNone && customCell.accessoryType == UITableViewCellAccessoryCheckmark){
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        customCell.accessoryType = UITableViewCellAccessoryNone;
                        nowDate = true;
                        customDate = false;
                        self.reportDate = [[NSDate date]retain];
                    }
                    else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        nowDate = false;
                    }
                }
                    break;
                case 1:{
                    NSIndexPath *nowIndex = [NSIndexPath indexPathForRow:0 inSection:5];
                    UITableViewCell *nowCell = [infoTableView cellForRowAtIndexPath:nowIndex];
                    
                    if(cell.accessoryType == UITableViewCellAccessoryNone && nowCell.accessoryType == UITableViewCellAccessoryNone) {
                        ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:self.reportDate target:self action:@selector(dateWasSelected:element:) origin:self.infoTableView];
                        
                         [datePicker addCustomButtonWithTitle:@"Today" value:[[NSDate date]retain]];
                        /*
                         [datePicker addCustomButtonWithTitle:@"Yesterday" value:[[[NSDate date] retain] TC_dateByAddingCalendarUnits:NSDayCalendarUnit amount:-1]];
                         */
                        
                        NSDate *today = [NSDate date];
                        [datePicker setMaximumDate:today];
                        [datePicker setMinimumDate: [today dateByAddingTimeInterval:-5*31558149.7676]];
                        datePicker.hideCancel = YES;
                        [datePicker showActionSheetPicker];
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        customDate = true;
                        nowDate = false;
                    }
                    else if (cell.accessoryType == UITableViewCellAccessoryNone && nowCell.accessoryType == UITableViewCellAccessoryCheckmark){
                        ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:self.reportDate target:self action:@selector(dateWasSelected:element:) origin:self.infoTableView];
                        [datePicker addCustomButtonWithTitle:@"Today" value:[[NSDate date]retain]];
                        /*
                         [datePicker addCustomButtonWithTitle:@"Yesterday" value:[[[NSDate date] retain] TC_dateByAddingCalendarUnits:NSDayCalendarUnit amount:-1]];
                         */
                        
                        NSDate *today = [NSDate date];
                        [datePicker setMaximumDate:today];
                        [datePicker setMinimumDate: [today dateByAddingTimeInterval:-5*31558149.7676]];
                        datePicker.hideCancel = YES;
                        [datePicker showActionSheetPicker];
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        customDate = true;
                        nowDate = false;
                        nowCell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        customDate = false;
                        nowDate = true;
                        nowCell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.reportDate = [[NSDate date]retain];
                    }
                    break;
                }
                    break;
            }
            break;
        }

        case 6:
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
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    self.reportDate = selectedDate;
    [self.infoTableView reloadData];
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    //self.dateTextField.text = [self.selectedDate description];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Other Conflict"]){
        NSLog(@"Button Index =%ld",(long)buttonIndex);
        if (buttonIndex == 1) {  //Okay
            UITextField *otherConflictWithField= [alertView textFieldAtIndex:0];
            self.otherConflictWith = otherConflictWithField.text;
            if (self.otherConflictWith != NULL){
                NSMutableString *otherConflictWithString = [NSMutableString stringWithFormat: @"Other ("];
                [otherConflictWithString appendString:self.otherConflictWith];
                [otherConflictWithString appendString:@")"];
                NSIndexPath *index =  [NSIndexPath indexPathForRow:9 inSection:1];
                UITableViewCell *cell = [self.infoTableView cellForRowAtIndexPath: index];
                cell.textLabel.text = otherConflictWithString;
            }
        }
        NSLog(@"Saved other conflict as = %@",self.otherConflictWith);
    }
    else if ([alertView.title isEqualToString:@"Other Action"]){
        NSLog(@"Button Index =%ld",(long)buttonIndex);
        if (buttonIndex == 1) {  //Okay
            UITextField *othercrashActionsField= [alertView textFieldAtIndex:0];
            self.otherCrashActions = othercrashActionsField.text;
            if (self.otherCrashActions != NULL){
                NSMutableString *othercrashActionsString = [NSMutableString stringWithFormat: @"Other ("];
                [othercrashActionsString appendString:self.otherCrashActions];
                [othercrashActionsString appendString:@")"];
                NSIndexPath *index =  [NSIndexPath indexPathForRow:9 inSection:2];
                UITableViewCell *cell = [self.infoTableView cellForRowAtIndexPath: index];
                cell.textLabel.text = othercrashActionsString;
            }
            
        }
        NSLog(@"Saved other action as = %@",self.otherCrashActions);
    }
    else if ([alertView.title isEqualToString:@"Other Cause"]){
        NSLog(@"Button Index =%ld",(long)buttonIndex);
        if (buttonIndex == 1) {  //Okay
            UITextField *othercrashReasonsField= [alertView textFieldAtIndex:0];
            self.otherCrashReasons = othercrashReasonsField.text;
            if (self.otherCrashReasons != NULL){
                NSMutableString *othercrashReasonsString = [NSMutableString stringWithFormat: @"Other ("];
                [othercrashReasonsString appendString:self.otherCrashReasons];
                [othercrashReasonsString appendString:@")"];
                NSIndexPath *index =  [NSIndexPath indexPathForRow:10 inSection:3];
                UITableViewCell *cell = [self.infoTableView cellForRowAtIndexPath: index];
                cell.textLabel.text = othercrashReasonsString;
            }
        }
        NSLog(@"Saved other conflict as = %@",self.otherCrashReasons);
    }
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if(currentTextField == severity){
        return [severityArray count];
    }
    else{
         return 0;
    }
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
    if(currentTextField == severity){
        tView.text =  [severityArray objectAtIndex:row];
    }
    return tView;
}
/*
- (void)cancelButtonPressed:(id)sender{
    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
}

- (void)doneButtonPressed:(id)sender{
    
    NSInteger selectedRow;
    selectedRow = [pickerView selectedRowInComponent:0];
    if(currentTextField == severity){
        //enable save button
        self.navigationItem.rightBarButtonItem.enabled = YES;
        severitySelectedRow = selectedRow;
        NSString *severitySelect = [severityArray objectAtIndex:selectedRow];
        severity.text = severitySelect;
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    severity.delegate = nil;
    self.noteDelegate = nil;
    infoTableView.delegate = nil;
    self.managedObjectContext = nil;
    self.severity = nil;
    self.severitySelectedRow = nil;
    self.conflictWithSelectedRows = nil;
    self.crashReasonsSelectedRows = nil;
    self.crashActionsSelectedRows = nil;
    self.reportDate = nil;
    //self.issueType = nil;
    //self.issueTypeSelectedRows = nil;
    
    [noteDelegate release];
    [noteResponse release];
    [managedObjectContext release];
    [severity release];
    [infoTableView release];
    [doneToolbar release];
    [actionSheet release];
    [pickerView release];
    [currentTextField release];
    [severityArray release];
    [conflictWithArray release];
    [crashActionsArray release];
    [crashReasonsArray release];
    //[issueTypeArray release];
    
    [super dealloc];
}

@end
