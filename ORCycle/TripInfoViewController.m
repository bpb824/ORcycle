//
//  TripInfoViewController.m
//  ORCycle
//
//  Created by orcycle on 7/21/14.
//
//

#import "TripInfoViewController.h"
#import "TripResponse.h"
#import "constants.h"

@implementation TripInfoViewController

@synthesize delegate, managedObjectContext;
@synthesize routeFreq, routePrefs, routeComfort, routeSafety, ridePassengers, rideSpecial, rideConflict, routeStressors;
@synthesize routeFreqSelectedRow, routePrefsSelectedRows, routeComfortSelectedRow, routeSafetySelectedRow, ridePassengersSelectedRows, rideSpecialSelectedRows, rideConflictSelectedRow, routeStressorsSelectedRows, selectedItem, selectedItems;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}


- (id)init
{
	NSLog(@"INIT");
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}


- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		NSLog(@"PersonalInfoViewController::initWithManagedObjectContext");
		self.managedObjectContext = context;
    }
    return self;
}

- (UITextField*)initTextFieldAlpha
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
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
    [super viewDidLoad];
    
    routeFreqArray = [[NSArray alloc]initWithObjects:@" ", @"Several times per week", @"Several times per month", @"Several times per year", @"Once per year or less", @"First time ever", nil];
    routePrefsArray = [[NSArray alloc] initWithObjects: @" ", @"It is direct/fast", @"It has good bicycle facilities", @"It is enjoyable", @"It is good for a workout", @"It has low traffic/low speeds", @"It has few intersections", @"It has few/easy hills", @"I has other riders/people (I am not alone)", @"It has beautiful scenery", @"I have no other reasonable alternative", @"I do not know anohter route", @"I found it online or using my phone", "Other", nil];
    routeComfortArray = [[NSArray alloc] initWithObjects: @" ", @"Very Bad", @"Bad", @"Average", @"Good", @"Very Good" , nil];
    routeSafetyArray = [[NSArray alloc] initWithObjects:@" ", @"Safe/comfortable for families, children, or new riders", @"Safe/comfortable for most riders", @"Safe/comfortable for the average confident rider", @"Only for the highly experienced and/or confident riders (not neccesarily comfortable)", @"Unacceptable", nil];
    ridePassengersArray = [[NSArray alloc] initWithObjects:@" ", @"Alone", @"With a child under 2", @" With a child between 2 and 10", @"With a child/teen over 10", @"With 1 adult", @"With 2+ adults", nil];
    rideSpecialArray = [[NSArray alloc] initWithObjects:@" ", @"child seat(s)", @"electric-assist", @"the cargo area", nil];
    rideConflictArray = [[NSArray alloc] initWithObjects:@" ", @"I have had a crash/accident", @"I have had a near crash/accident", @"I did not have a near crash/accident, but do not feel safe", @"I feel safe", nil];
    routeStressorsArray = [[NSArray alloc] initWithObjects: @" ", @"Auto Traffic", @"Large Commercial Vehicles (trucks)", @"Public Transport (buses, light rail, streetcar)", @"Parked vehicles (being doored)", @"Other cyclists", @"Pedestrians", @"Other", nil];
    
    for (int i = 0; i < [routePrefsArray count]; i++){routePrefsSelectedRows[i]=false;};
    for (int i = 0; i < [ridePassengersArray count]; i++){ridePassengersSelectedRows[i]=false;};
    for (int i = 0; i < [rideSpecialArray count]; i++){rideSpecialSelectedRows[i]=false;};
    for (int i = 0; i < [routeStressorsArray count]; i++){routeStressorsSelectedRows[i]=false;};
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    self.routeFreq = [self initTextFieldAlpha];
    self.routePrefs =[self initTextFieldAlpha];
    self.routeComfort =[self initTextFieldAlpha];
    self.routeSafety =[self initTextFieldAlpha];
    self.ridePassengers =[self initTextFieldAlpha];
    self.rideSpecial =[self initTextFieldAlpha];
    self.rideConflict =[self initTextFieldAlpha];
    self.routeStressors =[self initTextFieldAlpha];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    //Navigation bar color
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:bikeRouteGreen];
    
    
	// Set up the buttons.
    // this is actually the Save button.
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done)];
    
    //Initial Save button state is disabled. will be enabled if a change has been made to any of the fields.
	done.enabled = NO;
	self.navigationItem.rightBarButtonItem = done;
	
	NSFetchRequest		*request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
    
    NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"saved trip response count  = %d", count);
	if ( count == 0 )
	{
		// create an empty User entity
		//[self setTripResponse:[self createTripResponse]];
	}
	
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"no saved trip response");
		if ( error != nil )
			NSLog(@"TripInfo viewDidLoad fetch error %@, %@", error, [error localizedDescription]);
	}
    
    [mutableFetchResults release];
	[request release];
}

#pragma mark UITextFieldDelegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(currentTextField == routeFreq){
        NSLog(@"currentTextField: text2");
        [currentTextField resignFirstResponder];
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)myTextField{
    
    currentTextField = myTextField;
    
    if(myTextField == routeFreq || myTextField == routePrefs || myTextField == routeComfort || myTextField == routeSafety || myTextField == ridePassengers || myTextField == rideSpecial || myTextField == rideConflict || myTextField == routeStressors){
        
        [myTextField resignFirstResponder];
        
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]; //as we want to display a subview we won't be using the default buttons but rather we're need to create a toolbar to display the buttons on
        
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        [actionSheet addSubview:pickerView];
        
        doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        doneToolbar.barStyle = UIBarStyleBlackOpaque;
        [doneToolbar sizeToFit];
        
        NSMutableArray *barItems = [[[NSMutableArray alloc] init] autorelease];
        
        UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
        [barItems addObject:flexSpace];
        
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        [barItems addObject:cancelBtn];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        [barItems addObject:doneBtn];
        
        //TODO add a next and previous button to left side to take us to the next/previous thing. and switch to the right kind of input mode.
        
        [doneToolbar setItems:barItems animated:YES];
        
        [actionSheet addSubview:doneToolbar];
        
        selectedItem = 0;
        
        /*
        if(myTextField == gender){
            selectedItem = [user.gender integerValue];
        }else if (myTextField == age){
            selectedItem = [user.age integerValue];
        }else if (myTextField == ethnicity){
            selectedItem = [user.ethnicity integerValue];
        }else if (myTextField == occupation){
            selectedItem = [user.occupation integerValue];
        }else if (myTextField == income){
            selectedItem = [user.income integerValue];
        }else if (myTextField == hhWorkers){
            selectedItem = [user.hhWorkers integerValue];
        }else if (myTextField == hhVehicles){
            selectedItem = [user.hhVehicles integerValue];
        }else if (myTextField == numBikes){
            selectedItem = [user.numBikes integerValue];
        }else if (myTextField == cyclingFreq){
            selectedItem = [user.cyclingFreq integerValue];
        }else if (myTextField == cyclingWeather){
            selectedItem = [user.cyclingWeather integerValue];
        }else if (myTextField == riderAbility){
            selectedItem = [user.riderAbility integerValue];
        }else if (myTextField == riderType){
            selectedItem = [user.riderType integerValue];
        }else if (myTextField == riderHistory){
            selectedItem = [user.riderHistory integerValue];
        }
         */
        
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
    NSArray *questions = @[@19, @21, @22, @23, @24, @25, @26, @27];
    for (int i = 0; i < [questions count]; i++){
        NSInteger question = questions[i];
    TripResponse *tripResponse = (TripResponse *)[NSEntityDescription insertNewObjectForEntityForName:@"TripResponse" inManagedObjectContext:managedObjectContext];
        if(question == 19){
            [tripResponse setQuestion_id: question];
            [tripResponse setAnswer_id:87 + routeFreqSelectedRow];
        }
        if(question == 21){
            [tripResponse setQuestion_id: question];
            for(int j = 0; j < [routePrefsSelectedRows count]; j++){
                bool answer = routePrefsSelectedRows[j];
                if (answer){
               [tripResponse setAnswer_id:102 + j];
                }
            }
        }
        if(question == 22){
            [tripResponse setQuestion_id: question];
            [tripResponse setAnswer_id:116 + routeComfortSelectedRow];
        }
        if(question == 23){
            [tripResponse setQuestion_id: question];
            [tripResponse setAnswer_id: 122 + routeSafetySelectedRow];
        }
        if(question == 24){
            [tripResponse setQuestion_id: question];
            for(int j = 0; j < [ridePassengersSelectedRows count]; j++){
                bool answer = ridePassengersSelectedRows[j];
                if (answer){
                    [tripResponse setAnswer_id:128 + j];
                }
            }
        }
        if(question == 25){
            [tripResponse setQuestion_id: question];
            for(int j = 0; j < [rideSpecialSelectedRows count]; j++){
                bool answer = rideSpecialSelectedRows[j];
                if (answer){
                    [tripResponse setAnswer_id:135 + j];
                }
            }
        }
        if(question == 26){
            [tripResponse setQuestion_id: question];
            [tripResponse setAnswer_id: 139 + rideConflictSelectedRow];
        }
        if(question == 27){
            [tripResponse setQuestion_id: question];
            for(int j = 0; j < [routeStressorsSelectedRows count]; j++){
                bool answer = routeStressorsSelectedRows[j];
                if (answer){
                    [tripResponse setAnswer_id:143 + j];
                }
            }
        }
        
    }

    /*
    NSLog(@"Saving Trip Data");
	if ( tripResponse != nil )
	{
        if (
		[tripResponse setRouteFreq:[NSNumber numberWithInt:routeFreqSelectedRow]];
        NSLog(@"saved routeFreq index: %@ and text: %@", trip.routeFreq, routeFreq.text);
		
		//NSLog(@"saving cycling freq: %d", [cyclingFreq intValue]);
		//[user setCyclingFreq:cyclingFreq];
        
		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"PersonalInfo save cycling freq error %@, %@", error, [error localizedDescription]);
		}
	}
	else
		NSLog(@"ERROR can't save personal info for nil trip");
	
	// update UI
	 */
    
	[delegate setSaved:YES];
    //disable the save button after saving
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark Table view methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
            return @"In terms of my comfort, this route is...";
            break;
        case 3:
            return @"This route is...";
            break;
        case 4:
            return @"I rode this route... (can select more than one)";
            break;
        case 5:
            return @"On this ride, I used ... (can select more than one)";
            break;
        case 6:
            return @"On this route, indicate which best fits your experience";
            break;
        case 7:
            return @"Along this route, you are mostly concerned about conflicts/crashes with... (more than one option available)";
            break;
    }
    return nil;
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
        case 3:
            return 1;
            break;
        case 4:
            return 6;
            break;
        case 5:
            return 3;
            break;
        case 6:
            return 1;
            break;
        case 7:
            return 8;
            break;
        default:
            return 0;
    }
    return 0;
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
		}
			break;
        case 1:
		{
			static NSString *CellIdentifier = @"CellRoutePrefs";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    //TODO
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
        case 2:
		{
			static NSString *CellIdentifier = @"CellRouteComfort";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Route Comfort";
					[cell.contentView addSubview:routeComfort];
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
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
		}
			break;
        case 4:
		{
			static NSString *CellIdentifier = @"CellRidePassengers";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    //TODO
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
        case 5:
		{
			static NSString *CellIdentifier = @"CellRideSpecial";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    //TODO
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
		}
			break;
        case 7:
		{
			static NSString *CellIdentifier = @"CellRouteStressors";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    //TODO
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
            switch ([indexPath indexAtPosition:1])
			{
				case 0:
					break;
				case 1:
					break;
			}
			break;
        }
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
				case 0:
					break;
				case 1:
					break;
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
        case 7:
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
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if(currentTextField == routeFreq){
        return [routeFreqArray count];
    }
    else if(currentTextField == routePrefs){
        return [routePrefsArray count];
    }
    else if(currentTextField == routeComfort){
        return [routeComfortArray count];
    }
    else if(currentTextField == routeSafety){
        return [routeSafetyArray count];
    }
    else if(currentTextField == ridePassengers){
        return [ridePassengersArray count];
    }
    else if(currentTextField == rideSpecial){
        return [rideSpecialArray count];
    }
    else if(currentTextField == rideConflict){
        return [rideConflictArray count];
    }
    else if(currentTextField == routeStressors){
        return [routeStressorsArray count];
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(currentTextField == routeFreq){
        return [routeFreqArray objectAtIndex:row];
    }
    else if(currentTextField == routePrefs){
        return [routePrefsArray objectAtIndex:row];
    }
    else if(currentTextField == routeComfort){
        return [routeComfortArray objectAtIndex:row];
    }
    else if(currentTextField == routeSafety){
        return [routeSafetyArray objectAtIndex:row];
    }
    else if(currentTextField == ridePassengers){
        return [ridePassengersArray objectAtIndex:row];
    }
    else if(currentTextField == rideSpecial){
        return [rideSpecialArray objectAtIndex:row];
    }
    else if(currentTextField == rideConflict){
        return [rideConflictArray objectAtIndex:row];
    }
    else if(currentTextField == routeStressors){
        return [routeStressorsArray objectAtIndex:row];
    }
    return nil;
}

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
        //routePrefsSelectedRows = selectedRow;
        //NSString *ageSelect = [ageArray objectAtIndex:selectedRow];
        //age.text = ageSelect;
    }
    if(currentTextField == routeComfort){
        //enable save button if value has been changed.
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
        //enable save button if value has been changed.
        self.navigationItem.rightBarButtonItem.enabled = YES;
        //ridePassengersSelectedRows = selectedRow;
        //NSString *incomeSelect = [incomeArray objectAtIndex:selectedRow];
        //income.text = incomeSelect;
    }
    if(currentTextField == rideSpecial){
        //enable save button if value has been changed.
        self.navigationItem.rightBarButtonItem.enabled = YES;
        //hhWorkersSelectedRow = selectedRow;
        //NSString *hhWorkersSelect = [hhWorkersArray objectAtIndex:selectedRow];
        //hhWorkers.text = hhWorkersSelect;
    }
    if(currentTextField == rideConflict){
        //enable save button if value has been changed.
        self.navigationItem.rightBarButtonItem.enabled = YES;
        rideConflictSelectedRow = selectedRow;
        NSString *rideConflictSelect = [rideConflictArray objectAtIndex:selectedRow];
        rideConflict.text = rideConflictSelect;
    }
    if(currentTextField == routeStressors){
        //enable save button if value has been changed.
        self.navigationItem.rightBarButtonItem.enabled = YES;
        //numBikesSelectedRow = selectedRow;
        //NSString *numBikesSelect = [numBikesArray objectAtIndex:selectedRow];
        //numBikes.text = numBikesSelect;
    }
    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
}

- (void)cancelButtonPressed:(id)sender{
    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
}

- (void)dealloc {
    self.delegate = nil;
    self.managedObjectContext = nil;
    self.routeFreq = nil;
    self.routeFreqSelectedRow = nil;
    
    [delegate release];
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