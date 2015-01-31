//
//  NoteDetailViewController.m
//  ORcycle
//
//  Created by orcycle on 8/29/14.
//
//

#import "NoteDetailViewController.h"
#import "NoteResponse.h"
#import "constants.h"
#import "ActionSheetStringPicker.h"
#import "SetReportLocationViewController.h"
#import "ActionSheetDatePicker.h"
#import "NSDate+TCUtils.h"

@interface NoteDetailViewController ()

@end

@implementation NoteDetailViewController
@synthesize noteDelegate, appDelegate, managedObjectContext, infoTableView, noteResponse;
@synthesize urgency, issueType;
@synthesize urgencySelectedRow, issueTypeSelectedRows, selectedItem, selectedItems, otherIssueType,gpsLoc, customLoc, customDate, nowDate, reportDate;

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
    
    /*
    severityArray = [[NSArray alloc] initWithObjects: @"", @"I have had a major crash/accident", @"I have had a minor crash/accident", @"I have had a near-crash/accident", @"I do not feel safe", @"I feel uncomfortable",  nil];
    
    conflictWithArray = [[NSArray alloc] initWithObjects: @" ", @"Auto Traffic", @"Large commercial vehicles (trucks)", @"Public transport (buses, light rail, streetcar)", @"Parked vehicles (being doored)", @"Other cyclists", @"Pedestrians", @"Poles/barriers/infrastructure", @"Other", nil];
     */
    
    urgencyArray = [[NSArray alloc] initWithObjects: @"", @"1 (not urgent)", @"2", @"3 (somewhat urgent)", @"4", @"5 (urgent)",  nil];
    
    issueTypeArray = [[NSArray alloc] initWithObjects: @"",@"Narrow bike lane", @"No bike lane or shoulder", @"High traffic speed", @"High traffic volume", @"Right-turning vehicles", @"Left-turning vehicles", @"Short green time (traffic signal)", @"Long wait time (traffic signal)", @"No push button or detection (traffic signal)", @"Truck traffic", @"Bus traffic/stop", @"Parked vehicles", @"Pavement condition", @"Other (specify)",nil];
    
    //conflictWithSelectedRows = [[NSMutableArray alloc] init];
    issueTypeSelectedRows = [[NSMutableArray alloc] init];
    
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
    
    self.urgency = [self initTextFieldAlpha];

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
    
    if (urgencySelectedRow <10 && urgencySelectedRow != 0){
        numFields = numFields +1;
    }
    if ([issueTypeSelectedRows count]!=0){
        numFields = numFields + 1;
    }
    
    if (gpsLoc || customLoc ){
        didPickLoc = true;
    }
    
    if (nowDate || customDate ){
        didPickDate = true;
    }
    
    if (numFields < 2 && didPickLoc == false && didPickDate == false){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must answer both questions about the safety issue and choose the location and date of the safety issue."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (numFields >= 2 && didPickLoc == false && didPickDate == false){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must choose the location and date of the safety issue."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (numFields < 2 && didPickLoc == true && didPickDate == true){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must answer both questions about the safety issue."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (numFields >= 2 && didPickLoc == true && didPickDate == false){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must choose the date of the safety issue."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    
    else if (numFields < 2 && didPickLoc == true && didPickDate == false){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must answer both questions about the safety issue and choose the date of the safety issue."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (numFields < 2 && didPickLoc == false && didPickDate == true){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must answer both questions about the safety issue and choose the location of the safety issue."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (numFields >= 2 && didPickLoc == false && didPickDate == true){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Insufficient Data"
                              message:@"You must choose the location of the safety issue."
                              delegate:nil
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:nil];
        [alert show];
    }
    
    
    else{
        [infoTableView resignFirstResponder];
        
        [noteDelegate didPickUrgency:[NSNumber numberWithInt:urgencySelectedRow]];
        
        [self done];
        
        [noteDelegate didPickIssueType:noteResponse.issueType];
        
        [noteDelegate didEnterOtherIssueType: self.otherIssueType];
        
        [noteDelegate didPickReportDate:self.reportDate];
        
        [noteDelegate didPickIsCrash: false];
        
        [noteDelegate openDetailPage];
    }

}

#pragma mark UITextFieldDelegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(currentTextField == urgency ){
        NSLog(@"currentTextField: text2");
        //[currentTextField resignFirstResponder];
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)myTextField{
    
    currentTextField = myTextField;
    
    if(myTextField == urgency){
        
        [myTextField resignFirstResponder];
        
        if (myTextField == urgency){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([urgency respondsToSelector:@selector(setText:)]) {
                    [urgency performSelector:@selector(setText:) withObject:selectedValue];
                    NSLog(@"Picker: %@", picker);
                    NSLog(@"Selected Index: %ld", (long)selectedIndex);
                    NSLog(@"Selected Value: %@", selectedValue);
                    
                    if (selectedIndex != [noteResponse.urgency integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    urgencySelectedRow = selectedIndex;
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Urgency" rows: urgencyArray initialSelection:urgencyArray[0] doneBlock:done cancelBlock:cancel origin:urgency];
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
        //[noteResponse setIsCrash:false];
        
        [noteResponse setUrgency:[NSNumber numberWithInt:urgencySelectedRow]];
        NSLog(@"saved urgency index: %@ and text: %@", noteResponse.urgency,urgency.text);
        
        /*
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
         */
        
        NSMutableArray *checksIssueType = [[NSMutableArray alloc]init];
        for (int i = 0;i<[issueTypeSelectedRows count];i++){
            NSIndexPath *indexpath = issueTypeSelectedRows[i];
            [checksIssueType addObject:[NSNumber numberWithInt:indexpath.row]];
        }
        NSMutableString *issueTypeString = [[NSMutableString alloc] init];
        for (int i = 0;i<[issueTypeArray count];i++){
            if ([checksIssueType containsObject:[NSNumber numberWithInt:i]]){
                [issueTypeString appendString:[NSString stringWithFormat:@"%i", 1]];
            }
            else {
                [issueTypeString appendString:[NSString stringWithFormat:@"%i", 0]];
            }
            [issueTypeString appendString:@","];
        }
        [issueTypeString deleteCharactersInRange:NSMakeRange([issueTypeString length]-1, 1)];
        [noteResponse setIssueType:issueTypeString];
        NSLog(@"saved issue type array: %@", noteResponse.issueType);

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
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
        case 0:
            return @"Location specific infrastructure/safety issues... (can select more than one)";
			break;
        case 1:
            return @"Urgency of the problem? (scale 1 to 5, choose one)";
            break;
        case 2:
            return @"Location of infrastructure/safety issue";
            break;
        case 3:
            return @"Date of infrastructure/safety issue";
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
    if (section ==4){
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
            return 65;
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
            return 14;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 2;
            break;
        case 3:
            return 2;
            break;
        case 4:
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
			static NSString *CellIdentifier = @"CellIssueType";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
             cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            
            if([issueTypeSelectedRows containsObject:indexPath]) { cell.accessoryType = UITableViewCellAccessoryCheckmark; } else { cell.accessoryType = UITableViewCellAccessoryNone; }
            
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = issueTypeArray[1];
                    break;
				case 1:
					cell.textLabel.text = issueTypeArray[2];
					break;
				case 2:
					cell.textLabel.text = issueTypeArray[3];
					break;
                case 3:
					cell.textLabel.text = issueTypeArray[4];
					break;
                case 4:
					cell.textLabel.text = issueTypeArray[5];
                    break;
                case 5:
					cell.textLabel.text = issueTypeArray[6];
                    break;
                case 6:
					cell.textLabel.text = issueTypeArray[7];
                    break;
                case 7:
					cell.textLabel.text = issueTypeArray[8];
                    break;
                case 8:
					cell.textLabel.text = issueTypeArray[9];
                    break;
                case 9:
					cell.textLabel.text = issueTypeArray[10];
                    break;
                case 10:
					cell.textLabel.text = issueTypeArray[11];
                    break;
                case 11:
                    cell.textLabel.text = issueTypeArray[12];
                    break;
                case 12:
                    cell.textLabel.text = issueTypeArray[13];
                    break;
                case 13:
                    if (self.otherIssueType != NULL){
                        NSMutableString *otherIssueTypeString = [NSMutableString stringWithFormat: @"Other ("];
                        [otherIssueTypeString appendString:self.otherIssueType];
                        [otherIssueTypeString appendString:@")"];
                        cell.textLabel.text = otherIssueTypeString;
                    }
                    else{
                        cell.textLabel.text = issueTypeArray[14];
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
        case 1:
        {
            static NSString *CellIdentifier = @"CellUrgency";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
             cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            // inner switch statement identifies row
            switch ([indexPath indexAtPosition:1])
            {
                case 0:
                    cell.textLabel.text = @"urgency";
                    [cell.contentView addSubview:urgency];
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
                    cell.textLabel.text = @"Pick a custom location...";
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
            
        case 3:
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
            

        case 4:
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
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType == UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [issueTypeSelectedRows addObject:indexPath];
                if ([indexPath indexAtPosition:1]==13){
                    //NSLog(@"Trying to bring up other text view");
                    UIAlertView* otherIssueTypeView = [[UIAlertView alloc] initWithTitle:@"Other Issue Type" message:@"Please describe the location specific infrastructure/safety issue" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                    otherIssueTypeView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [otherIssueTypeView show];
                }
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [issueTypeSelectedRows removeObject:indexPath];
            }
            break;
        }
        case 1:
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
        case 2:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            switch ([indexPath indexAtPosition:1])
            {
                case 0:{
                    NSIndexPath *customIndex = [NSIndexPath indexPathForRow:1 inSection:2];
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
                    NSIndexPath *gpsIndex = [NSIndexPath indexPathForRow:0 inSection:2];
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
        case 3:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            switch ([indexPath indexAtPosition:1])
            {
                case 0:{
                    NSIndexPath *customIndex = [NSIndexPath indexPathForRow:1 inSection:3];
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
                    NSIndexPath *nowIndex = [NSIndexPath indexPathForRow:0 inSection:3];
                    UITableViewCell *nowCell = [infoTableView cellForRowAtIndexPath:nowIndex];
                    
                    if(cell.accessoryType == UITableViewCellAccessoryNone && nowCell.accessoryType == UITableViewCellAccessoryNone) {
                        ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:self.reportDate target:self action:@selector(dateWasSelected:element:) origin:self.infoTableView];
    
                        [datePicker addCustomButtonWithTitle:@"Today" value:[NSDate date]];
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

                        [datePicker addCustomButtonWithTitle:@"Today" value:[NSDate date]];
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

        case 4:
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
    if ([alertView.title isEqualToString:@"Other Issue Type"]){
        NSLog(@"Button Index =%ld",(long)buttonIndex);
        if (buttonIndex == 1) {  //Okay
            UITextField *otherIssueTypeField= [alertView textFieldAtIndex:0];
            self.otherIssueType = otherIssueTypeField.text;
            if (self.otherIssueType != NULL){
                NSMutableString *otherIssueTypeString = [NSMutableString stringWithFormat: @"Other ("];
                [otherIssueTypeString appendString:self.otherIssueType];
                [otherIssueTypeString appendString:@")"];
                NSIndexPath *index =  [NSIndexPath indexPathForRow:13 inSection:0];
                UITableViewCell *cell = [self.infoTableView cellForRowAtIndexPath: index];
                cell.textLabel.text = otherIssueTypeString;
            }
        }
        NSLog(@"Saved other route prefs as = %@",self.otherIssueType);
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if(currentTextField == urgency){
        return [urgencyArray count];
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
    if(currentTextField == urgency){
        tView.text =  [urgencyArray objectAtIndex:row];
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
    if(currentTextField == urgency){
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
    
    urgency.delegate = nil;
    self.noteDelegate = nil;
    infoTableView.delegate = nil;
    self.managedObjectContext = nil;
    self.urgency = nil;
    self.urgencySelectedRow = nil;
    //self.conflictWithSelectedRows = nil;
    self.issueType = nil;
    self.issueTypeSelectedRows = nil;
    self.reportDate = nil;
    
    [noteDelegate release];
    [noteResponse release];
    [managedObjectContext release];
    [urgency release];
    [infoTableView release];
    [doneToolbar release];
    [actionSheet release];
    [pickerView release];
    [currentTextField release];
    [urgencyArray release];
    //[conflictWithArray release];
    [issueTypeArray release];
    
    [super dealloc];
}

@end
