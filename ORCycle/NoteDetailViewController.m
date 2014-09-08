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

@interface NoteDetailViewController ()

@end

@implementation NoteDetailViewController
@synthesize noteDelegate, appDelegate, managedObjectContext, infoTableView, noteResponse;
@synthesize severity;
@synthesize severitySelectedRow, conflictWithSelectedRows, issueTypeSelectedRows, selectedItem, selectedItems;

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
    
    severityArray = [[NSArray alloc] initWithObjects: @"",@"I have had a major crash/accident", @"I have had a minor crash/accident", @"I have had a near-crash/accident", @"I do not feel safe", @"I feel uncomfortable",  nil];
    
    conflictWithArray = [[NSArray alloc] initWithObjects: @" ", @"Auto Traffic", @"Large commercial vehicles (trucks)", @"Public transport (buses, light rail, streetcar)", @"Parked vehicles (being doored)", @"Other cyclists", @"Pedestrians", @"Poles/barriers/infrastructure", @"Other", nil];
    
    issueTypeArray = [[NSArray alloc] initWithObjects: @"",@"Narrow Bicycle Lane", @"No bike lane or seperation", @"High vehicle speeds", @"High traffic volumes", @"Right/left turning vehicles", @"Traffic signal timing", @"No traffic signal detection", @"Truck traffic", @"Bus traffic/stop", @"Parked vehicles", @"Pavement condition", @"Other",nil];
    
    conflictWithSelectedRows = [[NSMutableArray alloc] init];
    issueTypeSelectedRows = [[NSMutableArray alloc] init];


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

-(IBAction)skip:(id)sender{
    NSLog(@"Skip");
    
    [infoTableView resignFirstResponder];
    [noteDelegate didPickNoteType:[NSNumber numberWithInt:severitySelectedRow]];
    [self done];
    [noteDelegate openDetailPage];
}

-(IBAction)saveDetail:(id)sender{
    NSLog(@"Save Detail");
    
    [infoTableView resignFirstResponder];
    
    [noteDelegate didPickNoteType:[NSNumber numberWithInt:severitySelectedRow]];
    
    [self done];
    
    [noteDelegate  openDetailPage];

}

#pragma mark UITextFieldDelegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(currentTextField == severity ){
        NSLog(@"currentTextField: text2");
        [currentTextField resignFirstResponder];
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)myTextField{
    
    currentTextField = myTextField;
    
    if(myTextField == severity){
        
        [myTextField resignFirstResponder];
        
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
        NSLog(@"saved conflict with array: %@", noteResponse.issueType);

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
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
        case 0:
			return @"Severity of the problem (choose one)";
			break;
        case 1:
            return @"I had a conflict or accident with... (can select more than one)";
            break;
        case 2:
            return @"Location specific infrastructure/safety issues... (can select more than one)";
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000]];
    
    CALayer *topLine = [CALayer layer];
    topLine.frame = CGRectMake(0, 0, 320, 1);
    topLine.backgroundColor = [UIColor blackColor].CGColor;
    [header.layer addSublayer:topLine];
    
    
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    if (section ==2){
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
			return 65;
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
            return 8;
            break;
        case 2:
            return 12;
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
			static NSString *CellIdentifier = @"CellIssueType";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
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
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [cell.textLabel setNumberOfLines:0];
		}
			break;
    }
    cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            
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
                [issueTypeSelectedRows addObject:indexPath];
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [issueTypeSelectedRows removeObject:indexPath];
            }
            break;
        }
    }
    [tableView reloadData];
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
    self.issueType = nil;
    self.issueTypeSelectedRows = nil;
    
    [noteDelegate release];
    [noteResponse release];
    [managedObjectContext release];
    [severity release];
    [doneToolbar release];
    [actionSheet release];
    [pickerView release];
    [currentTextField release];
    [severityArray release];
    [conflictWithArray release];
    [issueTypeArray release];
    
    [super dealloc];
}

@end
