/** Reno Tracks, Copyright 2012, 2013 Hack4Reno
 *
 *   @author Brad.Hellyar <bradhellyar@gmail.com>
 *
 *   Updated/Modified for Reno, Nevada app deployment. Based on the
 *   CycleTracks codebase for SFCTA, and the Atlanta Cycle app repo.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  PersonalInfoViewController.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/23/09.
//	For more information on the project,
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "PersonalInfoViewController.h"
#import "User.h"
#import "constants.h"

#define kMaxCyclingFreq 3

@implementation PersonalInfoViewController

@synthesize delegate, managedObjectContext, user;
@synthesize age, email, gender, ethnicity, occupation, income, hhWorkers, hhVehicles, numBikes, homeZIP, workZIP, schoolZIP;
@synthesize cyclingFreq, cyclingWeather, riderAbility, riderType, riderHistory;
@synthesize ageSelectedRow, genderSelectedRow, ethnicitySelectedRow, occupationSelectedRow, incomeSelectedRow, hhWorkersSelectedRow, hhVehiclesSelectedRow, numBikesSelectedRow, cyclingFreqSelectedRow, cyclingWeatherSelectedRow, riderAbilitySelectedRow, riderTypeSelectedRow, riderHistorySelectedRow, selectedItem;
@synthesize bikeTypes;

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


- (UITextField*)initTextFieldEmail
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone,
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"name@domain";
	textField.keyboardType = UIKeyboardTypeEmailAddress;
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	return textField;
}


- (UITextField*)initTextFieldNumeric
{
	CGRect frame = CGRectMake( 152, 7, 138, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"12345";
	textField.keyboardType = UIKeyboardTypeNumberPad;
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	return textField;
}


- (User *)createUser
{
	// Create and configure a new instance of the User entity
	User *noob = (User *)[[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext] retain];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"createUser error %@, %@", error, [error localizedDescription]);
	}
	
	return [noob autorelease];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Set the title.
	// self.title = @"Personal Info";
    
    genderArray = [[NSArray alloc]initWithObjects: @" ", @"Female",@"Male", @"Other", nil];
    
    ageArray = [[NSArray alloc]initWithObjects: @" ", @"Less than 18", @"18-24", @"25-34", @"35-44", @"45-54", @"55-64", @"65+", nil];
    
    ethnicityArray = [[NSArray alloc]initWithObjects: @" ", @"White", @"African American", @"Asian", @"Hispanic", @"American Indian, Alaskan Native", @"Other", nil];
    
    occupationArray = [[NSArray alloc]initWithObjects: @" ", @"Employed", @"Student", @"Retired", @"Homemaker", @"Other",nil];
    
    incomeArray = [[NSArray alloc]initWithObjects: @" ", @"Less than $14,999", @"$15,000 to $24,999", @"$25,000 to $34,999", @"$35,000 to $49,999", @"$50,000 to $74,999", @"$75,000 to $99,999", @"$100,000 to $149,999", @"$150,000 or more", nil];
    
    hhWorkersArray = [[NSArray alloc]initWithObjects: @" ", @"0", @"1", @"2", @"3 or more", nil];
    
    hhVehiclesArray = [[NSArray alloc]initWithObjects: @" ", @"0 Vehicles", @"1 Vehicle", @"2 Vehicles", @"3 or more Vehicles", nil];
    
    numBikesArray = [[NSArray alloc]initWithObjects: @" ", @"0 Bicycles", @"1 Bicycle", @"2 Bicycles", @"3 Bicycles", @"4 or more Bicycles", nil];
    
    cyclingFreqArray = [[NSArray alloc]initWithObjects: @" ", @"A few times per year", @"A few times per month", @"A few times per week", @"Nearly every day", nil];
    
    cyclingWeatherArray = [[NSArray alloc]initWithObjects: @" ", @"In any kind of weather", @"When it does not rain", @"Usually with warm and dry weather", @"Only with warm and dry weather", nil];
    
    riderAbilityArray = [[NSArray alloc]initWithObjects: @" ", @"Very Low", @"Low", @"Average",  @"High", @"Very High",  nil];
    
    riderTypeArray = [[NSArray alloc]initWithObjects: @" ", @"For nearly all my trips", @"To & from work", @"For recreation and/or excercise in my free time", @"For shopping, errands, or visiting friends", @"Mainly to & from work, but occasionally for other purposes", @"Other", nil];
    
    riderHistoryArray = [[NSArray alloc]initWithObjects: @" ", @"Since childhood", @"Several years", @"One year or less", @"Just trying it out / just started", nil];
    
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    
	// initialize text fields
	self.age		= [self initTextFieldAlpha];
	self.email		= [self initTextFieldEmail];
	self.gender		= [self initTextFieldAlpha];
    self.ethnicity  = [self initTextFieldAlpha];
    self.occupation    = [self initTextFieldAlpha];
    self.income     = [self initTextFieldAlpha];
    self.hhWorkers   = [self initTextFieldAlpha];
    self.hhVehicles   = [self initTextFieldAlpha];
    self.numBikes   = [self initTextFieldAlpha];
	self.homeZIP	= [self initTextFieldNumeric];
	self.workZIP	= [self initTextFieldNumeric];
	self.schoolZIP	= [self initTextFieldNumeric];
    self.cyclingFreq = [self initTextFieldBeta];
    self.cyclingWeather = [self initTextFieldBeta];
    self.riderAbility  =  [self initTextFieldBeta];
    self.riderType  =  [self initTextFieldBeta];
    self.riderHistory =[self initTextFieldBeta];
    
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
	NSLog(@"saved user count  = %d", count);
	if ( count == 0 )
	{
		// create an empty User entity
		[self setUser:[self createUser]];
	}
	
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"no saved user");
		if ( error != nil )
			NSLog(@"PersonalInfo viewDidLoad fetch error %@, %@", error, [error localizedDescription]);
	}
	
	[self setUser:[mutableFetchResults objectAtIndex:0]];
	if ( user != nil )
	{
		// initialize text fields indexes to saved personal info
		age.text            = [ageArray objectAtIndex:[user.age integerValue]];
        ageSelectedRow      = [user.age integerValue];
		email.text          = user.email;
		gender.text         = [genderArray objectAtIndex:[user.gender integerValue]];
        genderSelectedRow   = [user.gender integerValue];
        ethnicity.text      = [ethnicityArray objectAtIndex:[user.ethnicity integerValue]];
        ethnicitySelectedRow= [user.ethnicity integerValue];
        
        occupation.text         = [occupationArray objectAtIndex:[user.occupation integerValue]];
        occupationSelectedRow   = [user.occupation integerValue];
        
        income.text         = [incomeArray objectAtIndex:[user.income integerValue]];
        incomeSelectedRow   = [user.income integerValue];
        
        hhWorkers.text         = [hhWorkersArray objectAtIndex:[user.hhWorkers integerValue]];
        hhWorkersSelectedRow   = [user.hhWorkers integerValue];
        
        hhVehicles.text         = [hhVehiclesArray objectAtIndex:[user.hhVehicles integerValue]];
        hhVehiclesSelectedRow   = [user.hhVehicles integerValue];
        
        numBikes.text         = [numBikesArray objectAtIndex:[user.numBikes integerValue]];
        numBikesSelectedRow   = [user.numBikes integerValue];
		
        homeZIP.text        = user.homeZIP;
		workZIP.text        = user.workZIP;
		schoolZIP.text      = user.schoolZIP;
        
        cyclingFreq.text        = [cyclingFreqArray objectAtIndex:[user.cyclingFreq integerValue]];
        cyclingFreqSelectedRow  = [user.cyclingFreq integerValue];
        cyclingWeather.text        = [cyclingWeatherArray objectAtIndex:[user.cyclingWeather integerValue]];
        cyclingWeatherSelectedRow  = [user.cyclingWeather integerValue];
        riderAbility.text          = [riderAbilityArray objectAtIndex:[user.riderAbility integerValue]];
        riderAbilitySelectedRow    = [user.riderAbility integerValue];
        riderType.text          = [riderTypeArray objectAtIndex:[user.riderType integerValue]];
        riderTypeSelectedRow    = [user.riderType integerValue];
        riderHistory.text       = [riderHistoryArray objectAtIndex:[user.riderHistory integerValue]];
        riderHistorySelectedRow = [user.riderHistory integerValue];
		
		// init cycling frequency
		//NSLog(@"init cycling freq: %d", [user.cyclingFreq intValue]);
		//cyclingFreq		= [NSNumber numberWithInt:[user.cyclingFreq intValue]];
		
		//if ( !([user.cyclingFreq intValue] > kMaxCyclingFreq) )
		//	[self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:[user.cyclingFreq integerValue]
        //    inSection:2]];
	}
	else
		NSLog(@"init FAIL");
	
	[mutableFetchResults release];
	[request release];
}


#pragma mark UITextFieldDelegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(currentTextField == email || currentTextField == workZIP || currentTextField == homeZIP || currentTextField == schoolZIP || textField != email || textField != workZIP || textField != homeZIP || textField != schoolZIP){
        NSLog(@"currentTextField: text2");
        [currentTextField resignFirstResponder];
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)myTextField{
    
    /*if(currentTextField == email || currentTextField == workZIP || currentTextField == homeZIP || currentTextField == schoolZIP){
     NSLog(@"currentTextField: text");
     [currentTextField resignFirstResponder];
     [myTextField resignFirstResponder];
     }
     NSLog(@"currentTextfield: picker");*/
    currentTextField = myTextField;
    
    if(myTextField == gender || myTextField == age || myTextField == ethnicity || myTextField == occupation || myTextField == income || myTextField == hhWorkers || myTextField == hhVehicles || myTextField == numBikes || myTextField == cyclingFreq || myTextField == cyclingWeather|| myTextField == riderAbility || myTextField == riderType || myTextField == riderHistory){
        
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


// save the new value for this textField
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"textFieldDidEndEditing");
	
	// save value
	if ( user != nil )
	{
		if ( textField == email )
		{
            //enable save button if value has been changed.
            if (email.text != user.email){
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
			NSLog(@"saving email: %@", email.text);
			[user setEmail:email.text];
		}
		if ( textField == homeZIP )
		{
            if (homeZIP.text != user.homeZIP){
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
			NSLog(@"saving homeZIP: %@", homeZIP.text);
			[user setHomeZIP:homeZIP.text];
		}
		if ( textField == schoolZIP )
		{
            if (schoolZIP.text != user.schoolZIP){
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
			NSLog(@"saving schoolZIP: %@", schoolZIP.text);
			[user setSchoolZIP:schoolZIP.text];
		}
		if ( textField == workZIP )
		{
            if (workZIP.text != user.workZIP){
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
			NSLog(@"saving workZIP: %@", workZIP.text);
			[user setWorkZIP:workZIP.text];
		}
        
		
		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"PersonalInfo save textField error %@, %@", error, [error localizedDescription]);
		}
	}
}


- (void)done
{
    [email resignFirstResponder];
    [homeZIP resignFirstResponder];
    [workZIP resignFirstResponder];
    [schoolZIP resignFirstResponder];
    
    NSLog(@"Saving User Data");
	if ( user != nil )
	{
		[user setAge:[NSNumber numberWithInt:ageSelectedRow]];
        NSLog(@"saved age index: %@ and text: %@", user.age, age.text);
        
		[user setEmail:email.text];
        NSLog(@"saved email: %@", user.email);
        
		[user setGender:[NSNumber numberWithInt:genderSelectedRow]];
		NSLog(@"saved gender index: %@ and text: %@", user.gender, gender.text);
        
        [user setEthnicity:[NSNumber numberWithInt:ethnicitySelectedRow]];
        NSLog(@"saved ethnicity index: %@ and text: %@", user.ethnicity, ethnicity.text);
        
        [user setOccupation:[NSNumber numberWithInt:occupationSelectedRow]];
        NSLog(@"saved occupation index: %@ and text: %@", user.occupation, occupation.text);
        
        [user setIncome:[NSNumber numberWithInt:incomeSelectedRow]];
        NSLog(@"saved income index: %@ and text: %@", user.income, income.text);
        
        [user setHhWorkers:[NSNumber numberWithInt:hhWorkersSelectedRow]];
        NSLog(@"saved hhWorkers index: %@ and text: %@", user.hhWorkers, hhWorkers.text);
        
        [user setHhVehicles:[NSNumber numberWithInt:hhVehiclesSelectedRow]];
        NSLog(@"saved hhVehicles index: %@ and text: %@", user.hhVehicles, hhVehicles.text);

        [user setNumBikes:[NSNumber numberWithInt:numBikesSelectedRow]];
        NSLog(@"saved numBikes index: %@ and text: %@", user.numBikes, numBikes.text);
        
		[user setHomeZIP:homeZIP.text];
        NSLog(@"saved homeZIP: %@", homeZIP.text);
        
		[user setSchoolZIP:schoolZIP.text];
        NSLog(@"saved schoolZIP: %@", schoolZIP.text);
        
		[user setWorkZIP:workZIP.text];
        NSLog(@"saved workZIP: %@", workZIP.text);
        
        [user setCyclingFreq:[NSNumber numberWithInt:cyclingFreqSelectedRow]];
        NSLog(@"saved cycle freq index: %@ and text: %@", user.cyclingFreq, cyclingFreq.text);
        
        [user setCyclingWeather:[NSNumber numberWithInt:cyclingWeatherSelectedRow]];
        NSLog(@"saved cycling weather index: %@ and text: %@", user.cyclingWeather, cyclingWeather.text);
        
        [user setRiderAbility:[NSNumber numberWithInt:riderAbilitySelectedRow]];
        NSLog(@"saved rider ability index: %@ and text: %@", user.riderAbility, riderAbility.text);
        
        [user setRiderType:[NSNumber numberWithInt:riderTypeSelectedRow]];
        NSLog(@"saved rider type index: %@ and text: %@", user.riderType, riderType.text);
        
        [user setRiderHistory:[NSNumber numberWithInt:riderHistorySelectedRow]];
        NSLog(@"saved rider history index: %@ and text: %@", user.riderHistory, riderHistory.text);
		
		//NSLog(@"saving cycling freq: %d", [cyclingFreq intValue]);
		//[user setCyclingFreq:cyclingFreq];
        
		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"PersonalInfo save cycling freq error %@, %@", error, [error localizedDescription]);
		}
	}
	else
		NSLog(@"ERROR can't save personal info for nil user");
	
	// update UI
	
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
    return 9;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
        case 0:
			return nil;
			break;
		case 1:
			return @"Tell us about yourself";
			break;
		case 2:
			return @"Your typical commute";
			break;
		case 3:
			return @"How often do you cycle?";
			break;
        case 4:
			return @"What type of weather do you ride in?";
			break;
        case 5:
			return @"How would you rate your overall skill and experience level regarding cycling?";
			break;
        case 6:
			return @"I cycle mostly...";
			break;
        case 7:
			return @"How long have you been a cyclist?";
			break;
        case 8:
            return @"What types of bicycles do you own?";
            break;
        
	}
    return nil;
}

//- (UIView *)tableView:(UITableView *)tbl viewForHeaderInSection:(NSInteger)section
//{
//    UIView* sectionHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tbl.bounds.size.width, 18)];
//    sectionHead.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
//    sectionHead.userInteractionEnabled = YES;
//    sectionHead.tag = section;
//
//    UILabel *sectionText = [[UILabel alloc] initWithFrame:CGRectMake(18, 8, tbl.bounds.size.width - 10, 18)];
//
//    switch (section) {
//		case 0:
//			sectionText.text = @"Tell us about yourself";
//			break;
//		case 1:
//			sectionText.text = @"Your typical commute";
//			break;
//		case 2:
//			sectionText.text = @"How often do you cycle?";
//			break;
//        case 3:
//			sectionText.text = @"What kind of rider are you?";
//			break;
//        case 4:
//			sectionText.text = @"How long have you been a cyclist?";
//			break;
//	}
//    sectionText.backgroundColor = [UIColor clearColor];
//    sectionText.textColor = [UIColor colorWithHue:0.6 saturation:0.33 brightness: 0.49 alpha:1];
//    //sectionText.shadowColor = [UIColor grayColor];
//    //sectionText.shadowOffset = CGSizeMake(0,0.001);
//    sectionText.font = [UIFont boldSystemFontOfSize:16];
//
//    [sectionHead addSubview:sectionText];
//    [sectionText release];
//
//    return [sectionHead autorelease];
//}
//
//-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return UITableViewAutomaticDimension;
//}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch ( section )
	{
        case 0:
            return 1;
            break;
		case 1:
			return 9;
			break;
		case 2:
			return 3;
			break;
		case 3:
			return 1;
			break;
        case 4:
			return 1;
			break;
        case 5:
			return 1;
			break;
        case 6:
			return 1;
			break;
        case 7:
			return 1;
			break;
        case 8:
            return 7;
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
			static NSString *CellIdentifier = @"CellInstruction";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Getting started with ORcycle";
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
		case 1:
		{
			static NSString *CellIdentifier = @"CellPersonalInfo";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Age";
					[cell.contentView addSubview:age];
					break;
				case 1:
					cell.textLabel.text = @"Email";
					[cell.contentView addSubview:email];
					break;
				case 2:
					cell.textLabel.text = @"Gender";
					[cell.contentView addSubview:gender];
					break;
                case 3:
					cell.textLabel.text = @"Ethnicity";
					[cell.contentView addSubview:ethnicity];
					break;
                case 4:
					cell.textLabel.text = @"Occupation";
					[cell.contentView addSubview:occupation];
					break;
                case 5:
					cell.textLabel.text = @"Home Income";
					[cell.contentView addSubview:income];
					break;
                case 6:
					cell.textLabel.text = @"# HH Workers";
					[cell.contentView addSubview:hhWorkers];
					break;
                case 7:
					cell.textLabel.text = @"# HH Vehicles";
					[cell.contentView addSubview:hhVehicles];
					break;
                case 8:
					cell.textLabel.text = @"# Bicycles";
					[cell.contentView addSubview:numBikes];
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
		case 2:
		{
			static NSString *CellIdentifier = @"CellZip";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Home ZIP";
					[cell.contentView addSubview:homeZIP];
					break;
				case 1:
					cell.textLabel.text = @"Work ZIP";
					[cell.contentView addSubview:workZIP];
					break;
				case 2:
					cell.textLabel.text = @"School ZIP";
					[cell.contentView addSubview:schoolZIP];
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
        case 3:
		{
			static NSString *CellIdentifier = @"CellFrequecy";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Cycle Frequency";
					[cell.contentView addSubview:cyclingFreq];
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
        case 4:
		{
			static NSString *CellIdentifier = @"CellWeather";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"I cycle...";
					[cell.contentView addSubview:cyclingWeather];
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
        case 5:
		{
			static NSString *CellIdentifier = @"CellAbility";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Rider Ability";
					[cell.contentView addSubview:riderAbility];
					break;
            }
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
        case 6:
		{
			static NSString *CellIdentifier = @"CellType";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Rider Type";
					[cell.contentView addSubview:riderType];
					break;
            }
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
            
        case 7:
		{
			static NSString *CellIdentifier = @"CellHistory";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Rider History";
                    [cell.contentView addSubview:riderHistory];
					break;
			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
            break;
            
        case 8:
		{
			static NSString *CellIdentifier = @"CellBikeTypes";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Commuter (with gears)";
                    break;
				case 1:
					cell.textLabel.text = @"Commuter (single speed)";
					break;
				case 2:
					cell.textLabel.text = @"Racing or Road";
					break;
                case 3:
					cell.textLabel.text = @"Cycle Cross or Mountain";
					break;
                case 4:
					cell.textLabel.text = @"Cargo Bike";
                    break;
                case 5:
					cell.textLabel.text = @"Recumbent";
                    break;
                case 6:
					cell.textLabel.text = @"Other";
                    break;
			}
            
            if (cell.accessoryView == nil) {
                // Only configure the Checkbox control once.
                cell.accessoryView = [[Checkbox alloc] initWithFrame:CGRectMake(0, 0, 25, 43)];
                cell.accessoryView.opaque = NO;
                
                //[(Checkbox*)cell.accessoryView addTarget:self action:@selector(checkBoxTapped:forEvent:) forControlEvents:UIControlEventValueChanged];
            }
            
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;

            
	}
	
	// debug
	//NSLog(@"%@", [cell subviews]);
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
	// outer switch statement identifies section
    NSURL *url = [NSURL URLWithString:kInstructionsURL];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
	switch ([indexPath indexAtPosition:0])
	{
		case 0:
		{
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    [[UIApplication sharedApplication] openURL:[request URL]];
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
	}
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if(currentTextField == gender){
        return [genderArray count];
    }
    else if(currentTextField == age){
        return [ageArray count];
    }
    else if(currentTextField == ethnicity){
        return [ethnicityArray count];
    }
    else if(currentTextField == occupation){
        return [occupationArray count];
    }
    else if(currentTextField == income){
        return [incomeArray count];
    }
    else if(currentTextField == hhWorkers){
        return [hhWorkersArray count];
    }
    else if(currentTextField == hhVehicles){
        return [hhVehiclesArray count];
    }
    else if(currentTextField == numBikes){
        return [numBikesArray count];
    }
    else if(currentTextField == cyclingFreq){
        return [cyclingFreqArray count];
    }
    else if(currentTextField == cyclingWeather){
        return [cyclingWeatherArray count];
    }
    else if(currentTextField == riderAbility){
        return [riderAbilityArray count];
    }
    else if(currentTextField == riderType){
        return [riderTypeArray count];
    }
    else if(currentTextField == riderHistory){
        return [riderHistoryArray count];
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(currentTextField == gender){
        return [genderArray objectAtIndex:row];
    }
    else if(currentTextField == age){
        return [ageArray objectAtIndex:row];
    }
    else if(currentTextField == ethnicity){
        return [ethnicityArray objectAtIndex:row];
    }
    else if(currentTextField == occupation){
        return [occupationArray objectAtIndex:row];
    }
    else if(currentTextField == income){
        return [incomeArray objectAtIndex:row];
    }
    else if(currentTextField == hhWorkers){
        return [hhWorkersArray objectAtIndex:row];
    }
    else if(currentTextField == hhVehicles){
        return [hhVehiclesArray objectAtIndex:row];
    }
    else if(currentTextField == numBikes){
        return [numBikesArray objectAtIndex:row];
    }
    else if(currentTextField == cyclingFreq){
        return [cyclingFreqArray objectAtIndex:row];
    }
    else if(currentTextField == cyclingWeather){
        return [cyclingWeatherArray objectAtIndex:row];
    }
    else if(currentTextField == riderAbility){
        return [riderAbilityArray objectAtIndex:row];
    }
    else if(currentTextField == riderType){
        return [riderTypeArray objectAtIndex:row];
    }
    else if(currentTextField == riderHistory){
        return [riderHistoryArray objectAtIndex:row];
    }
    return nil;
}


- (void)doneButtonPressed:(id)sender{
    
    NSInteger selectedRow;
    selectedRow = [pickerView selectedRowInComponent:0];
    if(currentTextField == gender){
        //enable save button if value has been changed.
        if (selectedRow != [user.gender integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        genderSelectedRow = selectedRow;
        NSString *genderSelect = [genderArray objectAtIndex:selectedRow];
        gender.text = genderSelect;
    }
    if(currentTextField == age){
        //enable save button if value has been changed.
        if (selectedRow != [user.age integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        ageSelectedRow = selectedRow;
        NSString *ageSelect = [ageArray objectAtIndex:selectedRow];
        age.text = ageSelect;
    }
    if(currentTextField == ethnicity){
        //enable save button if value has been changed.
        if (selectedRow != [user.ethnicity integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        ethnicitySelectedRow = selectedRow;
        NSString *ethnicitySelect = [ethnicityArray objectAtIndex:selectedRow];
        ethnicity.text = ethnicitySelect;
    }
    if(currentTextField == occupation){
        //enable save button if value has been changed.
        if (selectedRow != [user.occupation integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        occupationSelectedRow = selectedRow;
        NSString *occupationSelect = [occupationArray objectAtIndex:selectedRow];
        occupation.text = occupationSelect;
    }
    if(currentTextField == income){
        //enable save button if value has been changed.
        if (selectedRow != [user.income integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        incomeSelectedRow = selectedRow;
        NSString *incomeSelect = [incomeArray objectAtIndex:selectedRow];
        income.text = incomeSelect;
    }
    if(currentTextField == hhWorkers){
        //enable save button if value has been changed.
        if (selectedRow != [user.hhWorkers integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        hhWorkersSelectedRow = selectedRow;
        NSString *hhWorkersSelect = [hhWorkersArray objectAtIndex:selectedRow];
        hhWorkers.text = hhWorkersSelect;
    }
    if(currentTextField == hhVehicles){
        //enable save button if value has been changed.
        if (selectedRow != [user.hhVehicles integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        hhVehiclesSelectedRow = selectedRow;
        NSString *hhVehiclesSelect = [hhVehiclesArray objectAtIndex:selectedRow];
        hhVehicles.text = hhVehiclesSelect;
    }
    if(currentTextField == numBikes){
        //enable save button if value has been changed.
        if (selectedRow != [user.numBikes integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        numBikesSelectedRow = selectedRow;
        NSString *numBikesSelect = [numBikesArray objectAtIndex:selectedRow];
        numBikes.text = numBikesSelect;
    }
    if(currentTextField == cyclingFreq){
        //enable save button if value has been changed.
        if (selectedRow != [user.cyclingFreq integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        cyclingFreqSelectedRow = selectedRow;
        NSString *cyclingFreqSelect = [cyclingFreqArray objectAtIndex:selectedRow];
        cyclingFreq.text = cyclingFreqSelect;
    }
    if(currentTextField == cyclingWeather){
        //enable save button if value has been changed.
        if (selectedRow != [user.cyclingWeather integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        cyclingWeatherSelectedRow = selectedRow;
        NSString *cyclingWeatherSelect = [cyclingWeatherArray objectAtIndex:selectedRow];
        cyclingWeather.text = cyclingWeatherSelect;
    }
    if(currentTextField == riderAbility){
        //enable save button if value has been changed.
        if (selectedRow != [user.riderAbility integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        riderAbilitySelectedRow = selectedRow;
        NSString *riderAbilitySelect = [riderAbilityArray objectAtIndex:selectedRow];
        riderAbility.text = riderAbilitySelect;
    }
    if(currentTextField == riderType){
        //enable save button if value has been changed.
        if (selectedRow != [user.riderType integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        riderTypeSelectedRow = selectedRow;
        NSString *riderTypeSelect = [riderTypeArray objectAtIndex:selectedRow];
        riderType.text = riderTypeSelect;
    }
    if(currentTextField == riderHistory){
        //enable save button if value has been changed.
        if (selectedRow != [user.riderHistory integerValue]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
        riderHistorySelectedRow = selectedRow;
        NSString *riderHistorySelect = [riderHistoryArray objectAtIndex:selectedRow];
        riderHistory.text = riderHistorySelect;
    }
    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
}

- (void)cancelButtonPressed:(id)sender{
    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
}

- (void)dealloc {
    self.delegate = nil;
    self.managedObjectContext = nil;
    self.user = nil;
    self.age = nil;
    self.email = nil;
    self.gender = nil;
    self.ethnicity = nil;
    self.occupation = nil;
    self.income = nil;
    self.hhWorkers = nil;
    self.hhVehicles = nil;
    self.numBikes = nil;
    self.homeZIP = nil;
    self.workZIP = nil;
    self.schoolZIP = nil;
    self.cyclingFreq = nil;
    self.cyclingWeather = nil;
    self.riderType = nil;
    self.riderAbility = nil;
    self.riderHistory = nil;
    self.ageSelectedRow = nil;
    self.genderSelectedRow = nil;
    self.ethnicitySelectedRow = nil;
    self.occupationSelectedRow = nil;
    self.incomeSelectedRow = nil;
    self.hhWorkersSelectedRow = nil;
    self.hhVehiclesSelectedRow = nil;
    self.numBikesSelectedRow = nil;
    self.cyclingFreqSelectedRow = nil;
    self.cyclingWeatherSelectedRow = nil;
    self.riderAbilitySelectedRow = nil;
    self.riderTypeSelectedRow = nil;
    self.riderHistorySelectedRow = nil;
    self.selectedItem = nil;
    
    [delegate release];
    [managedObjectContext release];
    [user release];
    [age release];
    [email release];
    [gender release];
    [ethnicity release];
    [occupation release];
    [income release];
    [hhWorkers release];
    [hhVehicles release];
    [numBikes release];
    [homeZIP release];
    [workZIP release];
    [schoolZIP release];
    [cyclingFreq release];
    [cyclingWeather release];
    [riderAbility release];
    [riderType release];
    [riderHistory release];
    
    [doneToolbar release];
    [actionSheet release];
    [pickerView release];
    [currentTextField release];
    [genderArray release];
    [ageArray release];
    [ethnicityArray release];
    [occupationArray release];
    [incomeArray release];
    [hhWorkersArray release];
    [hhVehiclesArray release];
    [numBikesArray release];
    [cyclingFreqArray release];
    [cyclingWeatherArray release];
    [riderAbilityArray release];
    [riderTypeArray release];
    [riderHistoryArray release];
    
    [super dealloc];
}

@end

