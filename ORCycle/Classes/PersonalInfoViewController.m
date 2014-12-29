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
#import "ActionSheetStringPicker.h"
#import "ActionSheetDatePicker.h"

#define kMaxCyclingFreq 3

@implementation PersonalInfoViewController

@synthesize delegate, managedObjectContext, user;
@synthesize age, email, feedback, gender, ethnicity, occupation, income, hhWorkers, hhVehicles, numBikes, homeZIP, workZIP, schoolZIP;
@synthesize cyclingFreq, cyclingWeather, riderAbility, riderType, riderHistory;
@synthesize ageSelectedRow, genderSelectedRow, ethnicitySelectedRow, occupationSelectedRow, incomeSelectedRow, hhWorkersSelectedRow, hhVehiclesSelectedRow, numBikesSelectedRow, cyclingFreqSelectedRow, cyclingWeatherSelectedRow, riderAbilitySelectedRow, riderTypeSelectedRow, riderHistorySelectedRow, selectedItem, choiceButton;
@synthesize bikeTypesSelectedRows, selectedItems, otherBikeTypes, otherEthnicity, otherGender, otherOccupation, otherRiderType, reminderOneTime, reminderTwoTime;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
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
	CGRect frame = CGRectMake( 195, 7, 110, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"Choose one";
	textField.delegate = self;
	return textField;
}

- (UITextField*)initTextFieldBeta
{
	CGRect frame = CGRectMake( 10, 7, 300, 29 );
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textAlignment = NSTextAlignmentRight;
	textField.placeholder = @"Choose one";
	textField.delegate = self;
	return textField;
}


- (UITextField*)initTextFieldEmail
{
	CGRect frame = CGRectMake( 130, 7, 180, 29 );
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
	CGRect frame = CGRectMake( 195, 7, 110, 29 );
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
    
    
    
    // get current date/time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *dateCreated = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release]; dateFormatter = nil;
    NSLog(@"User's current time in their preference format:%@",dateCreated);
    
    [noob setUserCreated:dateCreated];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	return [noob autorelease];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id mocDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [mocDelegate managedObjectContext];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
	// Set the title.
	// self.title = @"Personal Info";
    
    genderArray = [[NSArray alloc]initWithObjects: @" ", @"Female",@"Male", @"Other", nil];
    
    ageArray = [[NSArray alloc]initWithObjects: @" ", @"Less than 18", @"18-24", @"25-34", @"35-44", @"45-54", @"55-64", @"65+", nil];
    
    ethnicityArray = [[NSArray alloc]initWithObjects: @" ",  @"African American", @"Asian American", @"Hispanic", @"Native American", @"White American",@"Other", nil];
    
    occupationArray = [[NSArray alloc]initWithObjects: @" ", @"Employed", @"Student", @"Retired", @"Homemaker", @"Other",nil];
    
    incomeArray = [[NSArray alloc]initWithObjects: @" ", @"Less than $14,999", @"$15,000 to $24,999", @"$25,000 to $34,999", @"$35,000 to $49,999", @"$50,000 to $74,999", @"$75,000 to $99,999", @"$100,000 to $149,999", @"$150,000 or more", nil];
    
    hhWorkersArray = [[NSArray alloc]initWithObjects: @" ", @"0 Workers", @"1 Worker", @"2 Workers", @"3 or more Workers", nil];
    
    hhVehiclesArray = [[NSArray alloc]initWithObjects: @" ", @"0 Vehicles", @"1 Vehicle", @"2 Vehicles", @"3 or more Vehicles", nil];
    
    numBikesArray = [[NSArray alloc]initWithObjects: @" ", @"0 Bicycles", @"1 Bicycle", @"2 Bicycles", @"3 Bicycles", @"4 or more Bicycles", nil];
    
    cyclingFreqArray = [[NSArray alloc]initWithObjects: @" ", @"A few times per year", @"A few times per month", @"A few times per week", @"Nearly every day", nil];
    
    cyclingWeatherArray = [[NSArray alloc]initWithObjects: @" ", @"In any kind of weather", @"When it does not rain", @"Usually with warm and dry weather", @"Only with warm and dry weather", nil];
    
    riderAbilityArray = [[NSArray alloc]initWithObjects: @" ", @"Very high", @"High", @"Average", @"Low", @"Very low", nil];
    
    riderTypeArray = [[NSArray alloc]initWithObjects: @" ", @"For nearly all my trips", @"To/from work", @"For recreation/excercise in my free time", @"For shopping, errands, or visiting friends", @"Mainly to/from work, but occasionally for other purposes", @"Other", nil];
    /*
    riderHistoryArray = [[NSArray alloc]initWithObjects: @" ", @"Since childhood", @"Several years", @"One year or less", @"Just trying it out / just started", nil];
     */
    bikeTypesArray = [[NSArray alloc]initWithObjects:@" ",@"Commuter (with gears)", @"Commuter (single speed)", @"Racing or road", @"Trail, cyclecross, or mountain", @"Cargo bike", @"Recumbent", @"Other", nil];
    
    bikeTypesSelectedRows = [[NSMutableArray alloc] init];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
   
    
    if (!([[NSUserDefaults standardUserDefaults]objectForKey:@"reminderOneTime"] == NULL)){
        self.reminderOneTime = [[NSUserDefaults standardUserDefaults]objectForKey:@"reminderOneTime"];
    }
    else{
        NSString *str =@"8:00 AM";
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"HH:mm a"];
        NSDate *date = [formatter dateFromString:str];
        self.reminderOneTime = date;
    }
    
    if (!([[NSUserDefaults standardUserDefaults]objectForKey:@"reminderTwoTime"] == NULL)){
        self.reminderTwoTime = [[NSUserDefaults standardUserDefaults]objectForKey:@"reminderTwoTime"];
    }
    else{
        NSString *str =@"5:00 PM";
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"HH:mm a"];
        NSDate *date = [formatter dateFromString:str];
        self.reminderTwoTime = date;
    }

    
    
	// initialize text fields
	self.age		= [self initTextFieldAlpha];
	self.email		= [self initTextFieldEmail];
	self.gender		= [self initTextFieldAlpha];
    self.ethnicity  = [self initTextFieldAlpha];
    self.occupation    = [self initTextFieldAlpha];
    self.income     = [self initTextFieldAlpha];
    self.hhWorkers   = [self initTextFieldAlpha];
    self.hhVehicles   = [self initTextFieldAlpha];
    self.numBikes   = [self initTextFieldBeta];
    self.cyclingFreq = [self initTextFieldBeta];
    self.cyclingWeather = [self initTextFieldBeta];
    self.riderAbility  =  [self initTextFieldBeta];
    self.riderType  =  [self initTextFieldBeta];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
	
	NSFetchRequest		*request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"saved user count  = %ld", (long)count);
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
        //feedback.text          = user.feedback;
        NSLog(@"Other gender loaded as %@",user.otherGender);
        if ([user.gender integerValue] == 3 && user.otherGender != NULL){
            NSMutableString *otherGenderString = [NSMutableString stringWithFormat: @"Other ("];
            [otherGenderString appendString:user.otherGender];
            [otherGenderString appendString:@")"];
            gender.text = otherGenderString;
        }
        else{
            gender.text         = [genderArray objectAtIndex:[user.gender integerValue]];

        }
        genderSelectedRow   = [user.gender integerValue];
        
        if ([user.ethnicity integerValue] == 6 && user.otherEthnicity != NULL){
            NSMutableString *otherEthnicityString = [NSMutableString stringWithFormat: @"Other ("];
            [otherEthnicityString appendString:user.otherEthnicity];
            [otherEthnicityString appendString:@")"];
            ethnicity.text = otherEthnicityString;
        }
        else{
            ethnicity.text      = [ethnicityArray objectAtIndex:[user.ethnicity integerValue]];
        }
        ethnicitySelectedRow= [user.ethnicity integerValue];
        
        
        if ([user.occupation integerValue] == 5 && user.otherOccupation != NULL){
            NSMutableString *otherOccupationString = [NSMutableString stringWithFormat: @"Other ("];
            [otherOccupationString appendString:user.otherOccupation];
            [otherOccupationString appendString:@")"];
            occupation.text = otherOccupationString;
        }
        else{
            occupation.text         = [occupationArray objectAtIndex:[user.occupation integerValue]];
        }
        occupationSelectedRow   = [user.occupation integerValue];
        
        income.text         = [incomeArray objectAtIndex:[user.income integerValue]];
        incomeSelectedRow   = [user.income integerValue];
        
        hhWorkers.text         = [hhWorkersArray objectAtIndex:[user.hhWorkers integerValue]];
        hhWorkersSelectedRow   = [user.hhWorkers integerValue];
        
        hhVehicles.text         = [hhVehiclesArray objectAtIndex:[user.hhVehicles integerValue]];
        hhVehiclesSelectedRow   = [user.hhVehicles integerValue];
        
        numBikes.text         = [numBikesArray objectAtIndex:[user.numBikes integerValue]];
        numBikesSelectedRow   = [user.numBikes integerValue];
		
        /*
        homeZIP.text        = user.homeZIP;
		workZIP.text        = user.workZIP;
		schoolZIP.text      = user.schoolZIP;
         */
        
        cyclingFreq.text        = [cyclingFreqArray objectAtIndex:[user.cyclingFreq integerValue]];
        cyclingFreqSelectedRow  = [user.cyclingFreq integerValue];
        cyclingWeather.text        = [cyclingWeatherArray objectAtIndex:[user.cyclingWeather integerValue]];
        cyclingWeatherSelectedRow  = [user.cyclingWeather integerValue];
        riderAbility.text          = [riderAbilityArray objectAtIndex:[user.riderAbility integerValue]];
        riderAbilitySelectedRow    = [user.riderAbility integerValue];
        
        if ([user.riderType integerValue] == 6 && user.otherRiderType != NULL){
            NSMutableString *otherRiderTypeString = [NSMutableString stringWithFormat: @"Other ("];
            [otherRiderTypeString appendString:user.otherRiderType];
            [otherRiderTypeString appendString:@")"];
            riderType.text = otherRiderTypeString;
        }
        
        else{
            riderType.text          = [riderTypeArray objectAtIndex:[user.riderType integerValue]];
        }
        riderTypeSelectedRow    = [user.riderType integerValue];
        
        if (user.otherRiderType.length >0){
            self.otherRiderType = user.otherRiderType;
        }
        else if (user.otherBikeTypes.length >0){
            self.otherBikeTypes = user.otherBikeTypes;
        }
        else if (user.otherGender.length >0){
            self.otherGender = user.otherGender;
        }
        else if (user.otherEthnicity.length >0){
            self.otherEthnicity = user.otherEthnicity;
        }
        else if (user.otherOccupation.length >0){
            self.otherOccupation = user.otherOccupation;
        }
        
        NSMutableArray *bikeTypesParse = [[user.bikeTypes componentsSeparatedByString:@","] mutableCopy];
        NSMutableArray *bikeTypesLoaded = [[NSMutableArray alloc] init];
        NSIndexPath *tempIndexPath = [[NSIndexPath alloc] init];
        [tempIndexPath retain];
        for (NSString *s in bikeTypesParse)
        {
            NSNumber *num = [NSNumber numberWithInt:[s intValue]];
            [bikeTypesLoaded addObject:num];
        }
        for (int i = 0; i <[bikeTypesLoaded count];i++){
            if([bikeTypesLoaded[i] intValue] == 1){
                tempIndexPath = [[NSIndexPath indexPathForRow:i inSection:6]retain];
                [bikeTypesSelectedRows addObject:tempIndexPath];
            }
        }
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
    if(currentTextField == email){
        NSLog(@"currentTextField: text2");
        [currentTextField resignFirstResponder];
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)myTextField{
    
    if (myTextField == email){
        [currentTextField resignFirstResponder];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        CGPoint offset = self.tableView.contentOffset;
        offset.y += 170; // You can change this, but 200 doesn't create any problems
        [self.tableView setContentOffset:offset];
        [UIView commitAnimations];
    }

    
    currentTextField = myTextField;
    
    if(myTextField == gender || myTextField == age || myTextField == ethnicity || myTextField == occupation || myTextField == income || myTextField == hhWorkers || myTextField == hhVehicles || myTextField == numBikes || myTextField == cyclingFreq || myTextField == cyclingWeather|| myTextField == riderAbility || myTextField == riderType){
        
        [myTextField resignFirstResponder];
        
        if (myTextField == gender){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([gender respondsToSelector:@selector(setText:)]) {
                    [gender performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [user.gender integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    genderSelectedRow = selectedIndex;
                    if (genderSelectedRow == 3){
                        NSLog(@"Trying to bring up other text view");
                        UIAlertView* otherGenderView = [[UIAlertView alloc] initWithTitle:@"Other Gender" message:@"Please describe your gender." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                        otherGenderView.alertViewStyle = UIAlertViewStylePlainTextInput;
                        [otherGenderView show];
                    }
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };

            [ActionSheetStringPicker showPickerWithTitle:@"Gender" rows: genderArray initialSelection:genderArray[0] doneBlock:done cancelBlock:cancel origin:gender];
        }
        else if (myTextField == age){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([age respondsToSelector:@selector(setText:)]) {
                    [age performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [user.age integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    ageSelectedRow = selectedIndex;
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Age" rows: ageArray initialSelection:ageArray[0] doneBlock:done cancelBlock:cancel origin:age];
        }
        else if (myTextField == ethnicity){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([ethnicity respondsToSelector:@selector(setText:)]) {
                    [ethnicity performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [user.ethnicity integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    ethnicitySelectedRow = selectedIndex;
                    if (ethnicitySelectedRow == 6){
                        NSLog(@"Trying to bring up other text view");
                        UIAlertView* otherEthnicityView = [[UIAlertView alloc] initWithTitle:@"Other Ethnicity" message:@"Please describe your ethnicity." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                        otherEthnicityView.alertViewStyle = UIAlertViewStylePlainTextInput;
                        [otherEthnicityView show];
                    }
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Ethnicity" rows: ethnicityArray initialSelection:ethnicityArray[0] doneBlock:done cancelBlock:cancel origin:ethnicity];
        }
        else if (myTextField == occupation){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([occupation respondsToSelector:@selector(setText:)]) {
                    [occupation performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [user.occupation integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    occupationSelectedRow = selectedIndex;
                    
                    if (occupationSelectedRow == 5){
                        NSLog(@"Trying to bring up other text view");
                        UIAlertView* otherOccupationView = [[UIAlertView alloc] initWithTitle:@"Other Occupation" message:@"Please describe your occupation." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                        otherOccupationView.alertViewStyle = UIAlertViewStylePlainTextInput;
                        [otherOccupationView show];
                    }
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Occupation" rows: occupationArray initialSelection:occupationArray[0] doneBlock:done cancelBlock:cancel origin:occupation];
        }
        else if (myTextField == income){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([income respondsToSelector:@selector(setText:)]) {
                    [income performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [user.income integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    incomeSelectedRow = selectedIndex;
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Household Income" rows: incomeArray initialSelection:incomeArray[0] doneBlock:done cancelBlock:cancel origin:income];
        }
        else if (myTextField == hhWorkers){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([hhWorkers respondsToSelector:@selector(setText:)]) {
                    [hhWorkers performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [user.hhWorkers integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    hhWorkersSelectedRow = selectedIndex;
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Household Workers" rows: hhWorkersArray initialSelection:hhWorkersArray[0] doneBlock:done cancelBlock:cancel origin:hhWorkers];
        }
        else if (myTextField == hhVehicles){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([hhVehicles respondsToSelector:@selector(setText:)]) {
                    [hhVehicles performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [user.hhVehicles integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    hhVehiclesSelectedRow = selectedIndex;
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Household Vehicles" rows: hhVehiclesArray initialSelection:hhVehiclesArray[0] doneBlock:done cancelBlock:cancel origin:hhVehicles];
        }
        else if (myTextField == numBikes){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([numBikes respondsToSelector:@selector(setText:)]) {
                    [numBikes performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [user.numBikes integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    numBikesSelectedRow = selectedIndex;
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"# Bikes Owned" rows: numBikesArray initialSelection:numBikesArray[0] doneBlock:done cancelBlock:cancel origin:numBikes];
        }
        else if (myTextField == cyclingFreq){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([cyclingFreq respondsToSelector:@selector(setText:)]) {
                    [cyclingFreq performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [user.cyclingFreq integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    cyclingFreqSelectedRow = selectedIndex;
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Cycling Frequency" rows: cyclingFreqArray initialSelection:cyclingFreqArray[0] doneBlock:done cancelBlock:cancel origin:cyclingFreq];
        }
        else if (myTextField == cyclingWeather){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([cyclingWeather respondsToSelector:@selector(setText:)]) {
                    [cyclingWeather performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [user.cyclingWeather integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    cyclingWeatherSelectedRow = selectedIndex;
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Cycling Weather" rows: cyclingWeatherArray initialSelection:cyclingWeatherArray[0] doneBlock:done cancelBlock:cancel origin:cyclingWeather];
        }
        else if (myTextField == riderAbility){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                if ([riderAbility respondsToSelector:@selector(setText:)]) {
                    [riderAbility performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [user.riderAbility integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    riderAbilitySelectedRow = selectedIndex;
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Cycling Ability" rows: riderAbilityArray initialSelection:riderAbilityArray[0] doneBlock:done cancelBlock:cancel origin:riderAbility];
        }
        else if (myTextField == riderType){
            
            ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {

                if ([riderType respondsToSelector:@selector(setText:)]) {
                    [riderType performSelector:@selector(setText:) withObject:selectedValue];
                    if (selectedIndex != [user.riderType integerValue]){
                        self.navigationItem.rightBarButtonItem.enabled = YES;
                    }
                    riderTypeSelectedRow = selectedIndex;
                    
                    if (riderTypeSelectedRow == 6){
                        NSLog(@"Trying to bring up other text view");
                        UIAlertView* otherRiderTypeView = [[UIAlertView alloc] initWithTitle:@"Other Rider Type" message:@"Please describe when/why you make a trip by bicycle." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                        otherRiderTypeView.alertViewStyle = UIAlertViewStylePlainTextInput;
                        [otherRiderTypeView show];
                    }
                }
            };
            ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            };
            
            [ActionSheetStringPicker showPickerWithTitle:@"Rider Type" rows: riderTypeArray initialSelection:riderTypeArray[0] doneBlock:done cancelBlock:cancel origin:riderType];
        }
    }
}

// the user pressed the "Done" button, so dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSLog(@"textFieldShouldReturn");
	[textField resignFirstResponder];
    //[self.view endEditing:YES];
	return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


// save the new value for this textField
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"textFieldDidEndEditing");
	
	// save value
	if ( user != nil )
	{
		if ( textField == email)
		{
            //enable save button if value has been changed.
            if (email.text != user.email){
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
            NSLog(@"saving email: %@", email.text);
			[user setEmail:email.text];
            
		}
        
        //[textField resignFirstResponder];
        //[self.view endEditing:YES];
    
		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"PersonalInfo save textField error %@, %@", error, [error localizedDescription]);
		}
	}
}


// save the new value for this textField
- (void)textViewDidEndEditing:(UITextView *)textView
{
	NSLog(@"textViewDidEndEditing");
	
	// save value
	if ( user != nil )
	{
        /*
		if ( textView == feedback)
		{
            //enable save button if value has been changed.
            if (feedback.text != user.feedback){
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
            NSLog(@"saving feedback: %@", feedback.text);
			[user setFeedback:feedback.text];
		}
         */
        
		NSError *error;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"PersonalInfo save textView error %@, %@", error, [error localizedDescription]);
		}
	}
}


- (void)done
{
    [email resignFirstResponder];
    
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
        
        /*
		[user setHomeZIP:homeZIP.text];
        NSLog(@"saved homeZIP: %@", homeZIP.text);
        
		[user setSchoolZIP:schoolZIP.text];
        NSLog(@"saved schoolZIP: %@", schoolZIP.text);
        
		[user setWorkZIP:workZIP.text];
        NSLog(@"saved workZIP: %@", workZIP.text);
         */
        
        [user setCyclingFreq:[NSNumber numberWithInt:cyclingFreqSelectedRow]];
        NSLog(@"saved cycle freq index: %@ and text: %@", user.cyclingFreq, cyclingFreq.text);
        
        [user setCyclingWeather:[NSNumber numberWithInt:cyclingWeatherSelectedRow]];
        NSLog(@"saved cycling weather index: %@ and text: %@", user.cyclingWeather, cyclingWeather.text);
        
        [user setRiderAbility:[NSNumber numberWithInt:riderAbilitySelectedRow]];
        NSLog(@"saved rider ability index: %@ and text: %@", user.riderAbility, riderAbility.text);
        
        [user setRiderType:[NSNumber numberWithInt:riderTypeSelectedRow]];
        NSLog(@"saved rider type index: %@ and text: %@", user.riderType, riderType.text);
        
        
		//NSLog(@"saving cycling freq: %d", [cyclingFreq intValue]);
		//[user setCyclingFreq:cyclingFreq];
        NSMutableArray *checks = [[NSMutableArray alloc]init];
        for (int i = 0;i<[bikeTypesSelectedRows count];i++){
            NSIndexPath *indexpath = bikeTypesSelectedRows[i];
            [checks addObject:[NSNumber numberWithInt:indexpath.row]];
        }
        NSMutableString *bikeTypesString = [[NSMutableString alloc] init];
        for (int i = 0;i<[bikeTypesArray count];i++){
            if ([checks containsObject:[NSNumber numberWithInt:i]]){
                [bikeTypesString appendString:[NSString stringWithFormat:@"%i", 1]];
            }
            else {
                [bikeTypesString appendString:[NSString stringWithFormat:@"%i", 0]];
            }
            [bikeTypesString appendString:@","];
        }
        [bikeTypesString deleteCharactersInRange:NSMakeRange([bikeTypesString length]-1, 1)];
        [user setBikeTypes:bikeTypesString];
        NSLog(@"saved bike types array: %@", user.bikeTypes);

        
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
    return 14;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
        case 0:
			return @"Links";
			break;
		case 1:
			return @"How would you rate your overall skill and experience level regarding cycling?";
            break;
		case 2:
			return @"I cycle mostly...";
			break;
        case 3:
			return @"How often do you cycle?";
			break;
        case 4:
			return @"What type of weather do you ride in?";
			break;
        case 5:
            return @"How many bicycles do you own?";
            break;
        case 6:
			return @"What types of bicycles do you own? (can select more than one)";
			break;
        case 7:
            return @"Tell us about yourself";
            break;
        case 8:
            return @"To see your routes and reports in the future and receive updates/news, please provide your email  (email will not be shared, see privacy policy).";
            break;
        case 9:
            return nil;
            break;
        case 10:
            return @"Comment here if you would like to provide feedback about the app or desirable features:";
            break;
        case 11:
            return @"1.) Remind me to record a trip or report at...";
            break;
        case 12:
            return @"2.) Remind me to record a trip or report at...";
            break;
        case 13:
			return @"Application Version";
			break;
        
	}
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000]];
    
    CALayer *topLine = [CALayer layer];
    topLine.frame = CGRectMake(0, 0, 320, 0.5);
    topLine.backgroundColor = [UIColor blackColor].CGColor;
    [header.layer addSublayer:topLine];
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    if (section ==13){
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
            return 65;
            break;
		case 2:
			return 35;
			break;
		case 3:
			return 35;
			break;
        case 4:
			return 50;
			break;
        case 5:
			return 35;
			break;
        case 6:
            return 50;
            break;
        case 7:
            return 35;
            break;
        case 8:
            return 100;
            break;
        case 9:
            return 0;
            break;
        case 10:
            return 65;
            break;
        case 11:
            return 50;
            break;
        case 12:
            return 50;
            break;
        case 13:
            return 35;
            break;
		default:
			return 0;
	}
    return 0;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch ( section )
	{
        case 0:
            return 3;
            break;
        case 1:
            return 1;
            break;
		case 2:
			return 1;
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
            return 7;
            break;
        case 7:
            return 7;
            break;
        case 8:
            return 1;
            break;
        case 9:
            return 1;
            break;
        case 10:
            return 1;
            break;
        case 11:
            return 2;
            break;
        case 12:
            return 2;
            break;
        case 13:
            return 1;
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
			static NSString *CellIdentifier = @"CellLinks";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
					cell.textLabel.text = @"Getting started with ORcycle";
                    [cell.textLabel setTextColor:[UIColor blueColor]];
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:cell.textLabel.text];
                    NSInteger len = cell.textLabel.text.length;
                    // Add attribute NSUnderlineStyleAttributeName
                    [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, len)];
                    [cell.textLabel setAttributedText:attributedString];
					break;
                case 1:
                    cell.textLabel.text = @"Report to Transportation Agencies";
                    [cell.textLabel setTextColor:[UIColor blueColor]];
                    NSMutableAttributedString *attributedStringTwo = [[NSMutableAttributedString alloc] initWithString:cell.textLabel.text];
                    NSInteger lenTwo = cell.textLabel.text.length;
                    // Add attribute NSUnderlineStyleAttributeName
                    [attributedStringTwo addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, lenTwo)];
                    [cell.textLabel setAttributedText:attributedStringTwo];
                    break;
                case 2:
					cell.textLabel.text = @"Privacy Policy";
                    [cell.textLabel setTextColor:[UIColor blueColor]];
                    NSMutableAttributedString *attributedStringThree = [[NSMutableAttributedString alloc] initWithString:cell.textLabel.text];
                    NSInteger lenThree = cell.textLabel.text.length;
                    // Add attribute NSUnderlineStyleAttributeName
                    [attributedStringThree addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, lenThree)];
                    [cell.textLabel setAttributedText:attributedStringThree];
					break;

			}
			
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		}
			break;
            
		case 1:
		{
			static NSString *CellIdentifier = @"CellAbility";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
           cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
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
         
        case 2:
		{
            static NSString *CellIdentifier = @"CellType";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
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
            
        case 3:
		{
            static NSString *CellIdentifier = @"CellFrequecy";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            
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
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            
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
            static NSString *CellIdentifier = @"CellNumBikes";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"# Bicycles";
					[cell.contentView addSubview:numBikes];
					break;
            }
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
		}
			break;
            
        case 6:
		{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
			static NSString *CellIdentifier = @"CellBikeTypes";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            if([bikeTypesSelectedRows containsObject:indexPath]) { cell.accessoryType = UITableViewCellAccessoryCheckmark;}
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
					cell.textLabel.text = @"Racing or road";
					break;
                case 3:
					cell.textLabel.text = @"Trail, cyclecross, or mountain";
					break;
                case 4:
					cell.textLabel.text = @"Cargo bike";
                    break;
                case 5:
					cell.textLabel.text = @"Recumbent";
                    break;
                case 6:
                    if (user.otherBikeTypes != NULL){
                        NSMutableString *otherBikeTypesString = [NSMutableString stringWithFormat: @"Other ("];
                        [otherBikeTypesString appendString:user.otherBikeTypes];
                        [otherBikeTypesString appendString:@")"];
                        //NSIndexPath *index =  [NSIndexPath indexPathForRow:6 inSection:6];
                        //UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: indexPath];
                        cell.textLabel.text = otherBikeTypesString;
                    }
                    else{
                        cell.textLabel.text = @"Other";
                    }
                    break;
			}
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

        }
			break;
            
        case 7:
		{
            static NSString *CellIdentifier = @"CellPersonalInfo";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];

            
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
                case 0:
					cell.textLabel.text = @"Your Occupation";
					[cell.contentView addSubview:occupation];
					break;
				case 1:
					cell.textLabel.text = @"Your Age";
					[cell.contentView addSubview:age];
					break;
				case 2:
					cell.textLabel.text = @"Your Gender";
					[cell.contentView addSubview:gender];
					break;
                case 3:
					cell.textLabel.text = @"# Household Vehicles";
                    //[cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:13]];
					[cell.contentView addSubview:hhVehicles];
					break;
                case 4:
					cell.textLabel.text = @"# Household Workers";
                    //[cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:13]];
					[cell.contentView addSubview:hhWorkers];
					break;
                case 5:
					cell.textLabel.text = @"Your Ethnicity";
					[cell.contentView addSubview:ethnicity];
					break;
                case 6:
					cell.textLabel.text = @"Household Income";
					[cell.contentView addSubview:income];
					break;
			}
			
        }
			break;
        case 8:
		{
			static NSString *CellIdentifier = @"CellEmail";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
             cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"E-mail";
					[cell.contentView addSubview:email];
					break;
            }
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
        case 9:
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
                    //[cell.contentView addSubview:feedback];
                    break;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 10:
		{
			static NSString *CellIdentifier = @"CellFeedback";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
            
            cell.backgroundColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            cell.textLabel.textColor = [UIColor whiteColor];
			// inner switch statement identifies row
			switch ([indexPath indexAtPosition:1])
			{
				case 0:
                    cell.textLabel.text = @"Send Feedback";
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
					//[cell.contentView addSubview:feedback];
					break;
            }
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
        case 11:
        {
            static NSString *CellIdentifier = @"CellReminderOne";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            // inner switch statement identifies row
            switch ([indexPath indexAtPosition:1])
            {
                case 0:{
                    NSDate *time = self.reminderOneTime;
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"h:mm a"];
                    cell.textLabel.text = [dateFormatter stringFromDate:time];
                    UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
                    cell.accessoryView = switchview;
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"reminderOneSet"]){
                        [switchview setOn:true];
                    }
                    else{
                        [switchview setOn:false];
                    }
                    switchview.tag = 1;
                    [switchview addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
                    [switchview release];
                }
                     break;
                case 1:{
                    NSArray *dayOptions = [NSArray arrayWithObjects: @"Every Day", @"Weekdays", @"Weekends", nil];
                    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:dayOptions];
                    segmentedControl.frame = CGRectMake(10, 5, 300, 33);
                    [segmentedControl addTarget:self action:@selector(segmentControlOne:) forControlEvents: UIControlEventValueChanged];
                    NSInteger dayIndex = [[[NSUserDefaults standardUserDefaults]valueForKey:@"reminderOneDays"] intValue];
                    if (dayIndex){
                        segmentedControl.selectedSegmentIndex = dayIndex;
                        
                    }
                    else{
                        segmentedControl.selectedSegmentIndex = 0;
                    }
                    [cell addSubview:segmentedControl];
                }
                    break;
                
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
            
        case 12:
        {
            static NSString *CellIdentifier = @"CellReminderTwo";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            // inner switch statement identifies row
            switch ([indexPath indexAtPosition:1])
            {
                case 0:{
                    NSDate *time = self.reminderTwoTime;
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"h:mm a"];
                    cell.textLabel.text = [dateFormatter stringFromDate:time];
                    UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
                    cell.accessoryView = switchview;
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"reminderTwoSet"]){
                        [switchview setOn:true];
                    }
                    else{
                        [switchview setOn:false];
                    }
                    switchview.tag = 2;
                    [switchview addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
                    [switchview release];
                }
                    break;
                case 1:{
                    NSArray *dayOptions = [NSArray arrayWithObjects: @"Every Day", @"Weekdays", @"Weekends", nil];
                    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:dayOptions];
                    segmentedControl.frame = CGRectMake(10, 5, 300, 33);
                    [segmentedControl addTarget:self action:@selector(segmentControlTwo:) forControlEvents: UIControlEventValueChanged];
                    NSInteger dayIndex = [[[NSUserDefaults standardUserDefaults]valueForKey:@"reminderTwoDays"] intValue];
                    if (dayIndex){
                        segmentedControl.selectedSegmentIndex = dayIndex;

                    }
                    else{
                        segmentedControl.selectedSegmentIndex = 0;
                    }
                    [cell addSubview:segmentedControl];
                }
                    break;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 13:
        {
            static NSString *CellIdentifier = @"CellAppVersion";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.textColor = [UIColor colorWithRed:164.0f/255.0f green:65.0f/255.0f  blue:34.0f/255.0f  alpha:1.000];
            // inner switch statement identifies row
            switch ([indexPath indexAtPosition:1])
            {
                case 0:{
                    NSString *appVersion = [NSString stringWithFormat:@"%@ (%@) on iOS %@",
                                            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                                            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                                            [[UIDevice currentDevice] systemVersion]];
                    cell.textLabel.text = appVersion;
                    break;
                }
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
	}
	// debug
	//NSLog(@"%@", [cell subviews]);
    return cell;
}

- (void)segmentControlOne:(UISegmentedControl *)segment
{
    NSInteger reminderOne = 1;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"reminderOneSet"]){
        
        if(segment.selectedSegmentIndex == 0)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"reminderOneDays"];
            [self updateTime:reminderOne];
        }
        else if(segment.selectedSegmentIndex == 1)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:@"reminderOneDays"];
            [self updateTime:reminderOne];
        }
        else if(segment.selectedSegmentIndex == 2)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:2] forKey:@"reminderOneDays"];
            [self updateTime:reminderOne];
        }
    }
    else{
        
        if(segment.selectedSegmentIndex == 0)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"reminderOneDays"];
        }
        else if(segment.selectedSegmentIndex == 1)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:@"reminderOneDays"];
        }
        else if(segment.selectedSegmentIndex == 2)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:2] forKey:@"reminderOneDays"];
        }
    }
}

- (void)segmentControlTwo:(UISegmentedControl *)segment
{
    NSInteger reminderTwo = 2;
    NSLog(@"Detecting segment control two change");
    NSLog(@"Segment two choice is %i",segment.selectedSegmentIndex);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"reminderTwoSet"]){
        
        if(segment.selectedSegmentIndex == 0)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"reminderTwoDays"];
            [self updateTime:reminderTwo];
            NSLog(@"Detecting segment zero choice");
        }
        else if(segment.selectedSegmentIndex == 1)
        {
            
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:@"reminderTwoDays"];
            [self updateTime:reminderTwo];
        }
        else if(segment.selectedSegmentIndex == 2)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:2] forKey:@"reminderTwoDays"];
            [self updateTime:reminderTwo];
        }
    }
    else{
        
        if(segment.selectedSegmentIndex == 0)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"reminderTwoDays"];
        }
        else if(segment.selectedSegmentIndex == 1)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:@"reminderTwoDays"];
        }
        else if(segment.selectedSegmentIndex == 2)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:2] forKey:@"reminderTwoDays"];
        }
    }
}

-(void)updateTime:(NSInteger)reminderNum
{
    if (reminderNum==1){
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"reminderOneSet"]){
            
            UIApplication *app = [UIApplication sharedApplication];
            NSArray *eventArray = [app scheduledLocalNotifications];
            NSLog(@"Event  Array = %@",eventArray);
            for (int i=0; i<[eventArray count]; i++)
            {
                UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
                NSDictionary *userInfoCurrent = oneEvent.userInfo;
                if ([[userInfoCurrent valueForKey:@"reminderNum"] isEqualToString:@"One"])
                {
                    //Cancelling local notification
                    [app cancelLocalNotification:oneEvent];
                }
            }
            
            NSArray *days = [[NSArray alloc]init];
            
            switch ([[[NSUserDefaults standardUserDefaults] valueForKey:@"reminderOneDays"] integerValue]){
                case 0:{
                    days = @[@1,@2,@3,@4,@5,@6,@7];
                }
                    break;
                case 1:{
                    days = @[@2,@3,@4,@5,@6];
                }
                    break;
                case 2: {
                    days = @[@1,@7];
                }
                    break;
                default: {
                    days = @[@1,@2,@3,@4,@5,@6,@7];
                }
                    break;
            };
            
            for (int i = 0;i<[days count];i++){
                NSInteger day = [[days objectAtIndex:i] integerValue];
                NSLog(@"day = %i",day);
                NSDate *today = [NSDate date];
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSWeekdayCalendarUnit fromDate:today];
                NSInteger currentWeekday = components.weekday;
                NSLog(@"CurrentWeekday = %i",currentWeekday);
                NSInteger diff = day - currentWeekday;
                NSLog(@"Diff = %i",diff);
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"h:mm a"];
                NSString *timeString = [dateFormatter stringFromDate:self.reminderOneTime];
                NSArray *timeArray = [timeString componentsSeparatedByString: @":"];
                NSInteger hour = [timeArray[0] integerValue];
                NSArray *back = [timeArray[1] componentsSeparatedByString:@" "];
                NSInteger min = [back[0] integerValue];
                if (back.count >1){
                    NSString *ampm = back[1];
                    if ([ampm isEqualToString: @"AM"]){
                        [components setHour: hour];
                    }
                    else{
                        [components setHour: hour + 12 ];
                    }
                }
                else{
                    [components setHour: hour];
                }
                [components setMinute: min];
                [components setSecond: 0];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                [calendar setTimeZone: [NSTimeZone defaultTimeZone]];
                NSDate *dateToFire = [[calendar dateFromComponents:components] dateByAddingTimeInterval:diff*86400];
                
                NSLog(@"Date to fire =%@", dateToFire);
                
                UIApplication *ORcycle = [UIApplication sharedApplication];
                UILocalNotification *remind = [[UILocalNotification alloc] init];
                remind.alertBody = @"ORcycle is reminding you to log a trip.";
                remind.soundName = @"bicycle-bell-normalized.aiff";
                remind.fireDate = dateToFire;
                NSLog(@"remind.firedate =%@", remind.fireDate);
                remind.timeZone = [NSTimeZone defaultTimeZone];
                remind.repeatInterval = NSWeekCalendarUnit;
                remind.userInfo = [NSMutableDictionary dictionaryWithObject:@"One"
                                                                     forKey:@"reminderNum"];
                [ORcycle scheduleLocalNotification:remind];
                [remind release];
                NSLog(@"remind.userinfo =%@", remind.userInfo);
            }
            
            
        }

    }
    else if (reminderNum ==2){
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"reminderTwoSet"]){
            
            UIApplication *app = [UIApplication sharedApplication];
            NSArray *eventArray = [app scheduledLocalNotifications];
            for (int i=0; i<[eventArray count]; i++)
            {
                UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
                NSDictionary *userInfoCurrent = oneEvent.userInfo;
                if ([[userInfoCurrent valueForKey:@"reminderNum"] isEqualToString:@"Two"])
                {
                    //Cancelling local notification
                    [app cancelLocalNotification:oneEvent];
                }
            }
            
            NSArray *days = [[NSArray alloc]init];
            
            switch ([[[NSUserDefaults standardUserDefaults] valueForKey:@"reminderTwoDays"] integerValue]){
                case 0:{
                    days = @[@1,@2,@3,@4,@5,@6,@7];
                }
                    break;
                case 1:{
                    days = @[@2,@3,@4,@5,@6];
                }
                    break;
                case 2: {
                    days = @[@1,@7];
                }
                    break;
                default: {
                    days = @[@1,@2,@3,@4,@5,@6,@7];
                }
                    break;
            };
            
            for (int i = 0;i<[days count];i++){
                NSInteger day = [[days objectAtIndex:i] integerValue];
                NSLog(@"day = %i",day);
                NSDate *today = [NSDate date];
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSWeekdayCalendarUnit fromDate:today];
                NSInteger currentWeekday = components.weekday;
                NSLog(@"CurrentWeekday = %i",currentWeekday);
                NSInteger diff = day - currentWeekday;
                NSLog(@"Diff = %i",diff);
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"h:mm a"];
                NSString *timeString = [dateFormatter stringFromDate:self.reminderTwoTime];
                NSArray *timeArray = [timeString componentsSeparatedByString: @":"];
                NSInteger hour = [timeArray[0] integerValue];
                NSArray *back = [timeArray[1] componentsSeparatedByString:@" "];
                NSInteger min = [back[0] integerValue];
                if (back.count >1){
                    NSString *ampm = back[1];
                    if ([ampm isEqualToString: @"AM"]){
                        [components setHour: hour];
                    }
                    else{
                        [components setHour: hour + 12 ];
                    }
                }
                else{
                    [components setHour: hour];
                }
                [components setMinute: min];
                [components setSecond: 0];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                [calendar setTimeZone: [NSTimeZone defaultTimeZone]];
                NSDate *dateToFire = [[calendar dateFromComponents:components] dateByAddingTimeInterval:diff*86400];
                
                NSLog(@"Date to fire =%@", dateToFire);
                
                UIApplication *ORcycle = [UIApplication sharedApplication];
                UILocalNotification *remind = [[UILocalNotification alloc] init];
                remind.alertBody = @"ORcycle is reminding you to log a trip.";
                remind.soundName = @"bicycle-bell-normalized.aiff";
                remind.fireDate = dateToFire;
                NSLog(@"remind.firedate =%@", remind.fireDate);
                remind.timeZone = [NSTimeZone defaultTimeZone];
                remind.repeatInterval = NSWeekCalendarUnit;
                remind.userInfo = [NSMutableDictionary dictionaryWithObject:@"Two"
                                                                     forKey:@"reminderNum"];
                [ORcycle scheduleLocalNotification:remind];
                [remind release];
                
                
            }
            
        }

    }
}

- (void)updateSwitch:(UISwitch *)switchView {
    NSInteger reminderNum = switchView.tag;
    
    NSIndexPath *index1 =  [NSIndexPath indexPathForRow:0 inSection:11];
    UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath: index1];
    NSIndexPath *index2 =  [NSIndexPath indexPathForRow:0 inSection:12];
    UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath: index2];
    if (![cell1.accessoryView isOn] && ![cell2.accessoryView isOn]){
         [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"reminderOneSet"];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"reminderTwoSet"];

    }
    else{
        if (reminderNum == 1){
            if ([switchView isOn]){
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"reminderOneSet"];
                
                NSArray *days = [[NSArray alloc]init];
                
                switch ([[[NSUserDefaults standardUserDefaults] valueForKey:@"reminderOneDays"] integerValue]){
                    case 0:{
                        days = @[@1,@2,@3,@4,@5,@6,@7];
                    }
                        break;
                    case 1:{
                        days = @[@2,@3,@4,@5,@6];
                    }
                        break;
                    case 2: {
                        days = @[@1,@7];
                    }
                        break;
                    default: {
                        days = @[@1,@2,@3,@4,@5,@6,@7];
                    }
                        break;
                };
                
                NSLog(@"Days are equal to=%@",days);
                
                for (int i = 0;i<[days count];i++){
                    NSInteger day = [[days objectAtIndex:i] integerValue];
                    NSLog(@"day = %i",day);
                    NSDate *today = [NSDate date];
                    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSWeekdayCalendarUnit fromDate:today];
                    NSInteger currentWeekday = components.weekday;
                    NSLog(@"CurrentWeekday = %i",currentWeekday);
                    NSInteger diff = day - currentWeekday;
                    NSLog(@"Diff = %i",diff);
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"h:mm a"];
                    NSString *timeString = [dateFormatter stringFromDate:self.reminderOneTime];
                    NSArray *timeArray = [timeString componentsSeparatedByString: @":"];
                    NSInteger hour = [timeArray[0] integerValue];
                    NSArray *back = [timeArray[1] componentsSeparatedByString:@" "];
                    NSInteger min = [back[0] integerValue];
                    if (back.count >1){
                        NSString *ampm = back[1];
                        if ([ampm isEqualToString: @"AM"]){
                            [components setHour: hour];
                        }
                        else{
                            [components setHour: hour + 12 ];
                        }
                    }
                    else{
                        [components setHour: hour];
                    }
                    
                    [components setMinute: min];
                    [components setSecond: 0];
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    [calendar setTimeZone: [NSTimeZone defaultTimeZone]];
                    NSDate *dateToFire = [[calendar dateFromComponents:components] dateByAddingTimeInterval:diff*86400];
                    
                    //NSLog(@"today is %@", [NSDate date]);
                    //NSLog(@"reminder one time is %@", timeArray);
                    //NSLog(@"Date to fire components=%@", components);
                    NSLog(@"Date to fire =%@", dateToFire);
                    
                    UIApplication *ORcycle = [UIApplication sharedApplication];
                    UILocalNotification *remind = [[UILocalNotification alloc] init];
                    remind.alertBody = @"ORcycle is reminding you to log a trip.";
                    remind.soundName = @"bicycle-bell-normalized.aiff";
                    remind.fireDate = dateToFire;
                    NSLog(@"remind.firedate =%@", remind.fireDate);
                    remind.timeZone = [NSTimeZone defaultTimeZone];
                    remind.repeatInterval = NSWeekCalendarUnit;
                    remind.userInfo = [NSMutableDictionary dictionaryWithObject:@"One"
                                                                         forKey:@"reminderNum"];
                    [ORcycle scheduleLocalNotification:remind];
                    [remind release];
                }
                
                
            }
            else{
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"reminderOneSet"];
                UIApplication *app = [UIApplication sharedApplication];
                NSArray *eventArray = [app scheduledLocalNotifications];
                for (int i=0; i<[eventArray count]; i++)
                {
                    UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
                    NSDictionary *userInfoCurrent = oneEvent.userInfo;
                    if ([[userInfoCurrent valueForKey:@"reminderNum"] isEqualToString:@"One"])
                    {
                        //Cancelling local notification
                        [app cancelLocalNotification:oneEvent];
                        break;
                    }
                }
            }
        }
        else if (reminderNum == 2){
            if ([switchView isOn]){
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"reminderTwoSet"];
                NSArray *days = [[NSArray alloc]init];
                
                switch ([[[NSUserDefaults standardUserDefaults] valueForKey:@"reminderTwoDays"] integerValue]){
                    case 0:{
                        days = @[@1,@2,@3,@4,@5,@6,@7];
                    }
                        break;
                    case 1:{
                        days = @[@2,@3,@4,@5,@6];
                    }
                        break;
                    case 2: {
                        days = @[@1,@7];
                    }
                        break;
                    default: {
                        days = @[@1,@2,@3,@4,@5,@6,@7];
                    }
                        break;
                };
                
                for (int i = 0;i<[days count];i++){
                    NSInteger day = [[days objectAtIndex:i] integerValue];
                    NSLog(@"day = %i",day);
                    NSDate *today = [NSDate date];
                    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSWeekdayCalendarUnit fromDate:today];
                    NSInteger currentWeekday = components.weekday;
                    NSLog(@"CurrentWeekday = %i",currentWeekday);
                    NSInteger diff = day - currentWeekday;
                    NSLog(@"Diff = %i",diff);
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"h:mm a"];
                    NSString *timeString = [dateFormatter stringFromDate:self.reminderTwoTime];
                    NSArray *timeArray = [timeString componentsSeparatedByString: @":"];
                    NSInteger hour = [timeArray[0] integerValue];
                    NSArray *back = [timeArray[1] componentsSeparatedByString:@" "];
                    NSInteger min = [back[0] integerValue];
                    if (back.count >1){
                        NSString *ampm = back[1];
                        if ([ampm isEqualToString: @"AM"]){
                            [components setHour: hour];
                        }
                        else{
                            [components setHour: hour + 12 ];
                        }
                    }
                    else{
                        [components setHour: hour];
                    }
                    [components setMinute: min];
                    [components setSecond: 0];
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    [calendar setTimeZone: [NSTimeZone defaultTimeZone]];
                    NSDate *dateToFire = [[calendar dateFromComponents:components] dateByAddingTimeInterval:diff*86400];
                    
                    NSLog(@"today is %@", [NSDate date]);
                    NSLog(@"reminder one time is %@", timeArray);
                    NSLog(@"Date to fire components=%@", components);
                    NSLog(@"Date to fire =%@", dateToFire);
                    
                    UIApplication *ORcycle = [UIApplication sharedApplication];
                    UILocalNotification *remind = [[UILocalNotification alloc] init];
                    remind.alertBody = @"ORcycle is reminding you to log a trip.";
                    remind.soundName = @"bicycle-bell-normalized.aiff";
                    remind.fireDate = dateToFire;
                    NSLog(@"remind.firedate =%@", remind.fireDate);
                    remind.timeZone = [NSTimeZone defaultTimeZone];
                    remind.repeatInterval = NSWeekCalendarUnit;
                    remind.userInfo = [NSMutableDictionary dictionaryWithObject:@"Two"
                                                                         forKey:@"reminderNum"];
                    [ORcycle scheduleLocalNotification:remind];
                    [remind release];
                }
                
                
            }
            else{
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"reminderTwoSet"];
                
                UIApplication *app = [UIApplication sharedApplication];
                NSArray *eventArray = [app scheduledLocalNotifications];
                for (int i=0; i<[eventArray count]; i++)
                {
                    UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
                    NSDictionary *userInfoCurrent = oneEvent.userInfo;
                    if ([[userInfoCurrent valueForKey:@"reminderNum"] isEqualToString:@"Two"])
                    {
                        //Cancelling local notification
                        [app cancelLocalNotification:oneEvent];
                        break;
                    }
                }
            }
        }
        

    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    //[switchView release];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] == 9 || [indexPath indexAtPosition:0] == 10){
        return 43;
    }
    else{
        return 43;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
	// outer switch statement identifies section
    NSURL *url = [NSURL URLWithString:kInstructionsURL];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURL *privacyURL = [NSURL URLWithString:kPrivacyURL];
    NSURLRequest *privacyRequest = [NSMutableURLRequest requestWithURL:privacyURL];
    
    NSURL *urgentURL = [NSURL URLWithString:kUrgentURL];
    NSURLRequest *urgentRequest = [NSMutableURLRequest requestWithURL:urgentURL];
    
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
                    [[UIApplication sharedApplication] openURL:[urgentRequest URL]];
                    break;
                case 2:
                    [[UIApplication sharedApplication] openURL:[privacyRequest URL]];
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
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType == UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [bikeTypesSelectedRows addObject:indexPath];
                self.navigationItem.rightBarButtonItem.enabled = YES;
                if ([indexPath indexAtPosition:1]==6){
                    NSLog(@"Trying to bring up other text view");
                    UIAlertView* otherBikeTypesView = [[UIAlertView alloc] initWithTitle:@"Other Bike Type" message:@"Please describe what other type of bicycle you own." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                    otherBikeTypesView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [otherBikeTypesView show];
                }
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [bikeTypesSelectedRows removeObject:indexPath];
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
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
        case 8:
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
        case 9:
        {
            switch ([indexPath indexAtPosition:1])
            {
                case 0:{
                    [self done];
                }
                    self.navigationItem.rightBarButtonItem.enabled = NO;
            }
            break;
        }
        case 10:
		{
			switch ([indexPath indexAtPosition:1])
			{
                case 0:{
                    NSLog(@"Trying to bring up other text view");
                    UIAlertView* feedbackView = [[UIAlertView alloc] initWithTitle:@"Feedback" message:@"Please leave feedback below." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                    feedbackView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [feedbackView show];
                }
                self.navigationItem.rightBarButtonItem.enabled = YES;
			}
			break;
		}
        case 11:
        {
            switch ([indexPath indexAtPosition:1])
            {
                case 0:{
                    NSLog(@"User selected index path = %@",indexPath);
                    NSInteger minuteInterval = 5;
                    //clamp date
                    NSInteger referenceTimeInterval = (NSInteger)[self.reminderOneTime timeIntervalSinceReferenceDate];
                    NSInteger remainingSeconds = referenceTimeInterval % (minuteInterval *60);
                    NSInteger timeRoundedTo5Minutes = referenceTimeInterval - remainingSeconds;
                    if(remainingSeconds>((minuteInterval*60)/2)) {/// round up
                        timeRoundedTo5Minutes = referenceTimeInterval +((minuteInterval*60)-remainingSeconds);
                    }
                    
                    self.reminderOneTime = [NSDate dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)timeRoundedTo5Minutes];
                    
                    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:
                                                    @"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:self.reminderOneTime target:self action:@selector(time1WasSelected:element:) origin:self.tableView];
                    datePicker.minuteInterval = minuteInterval;
                    [datePicker showActionSheetPicker];
                    
                  break;
                }
                    
            }
            break;
        }
        case 12:
        {
            switch ([indexPath indexAtPosition:1])
            {
                case 0:{
                    NSLog(@"User selected index path = %@",indexPath);
                    NSInteger minuteInterval = 5;
                    //clamp date
                    NSInteger referenceTimeInterval = (NSInteger)[self.reminderTwoTime timeIntervalSinceReferenceDate];
                    NSInteger remainingSeconds = referenceTimeInterval % (minuteInterval *60);
                    NSInteger timeRoundedTo5Minutes = referenceTimeInterval - remainingSeconds;
                    if(remainingSeconds>((minuteInterval*60)/2)) {/// round up
                        timeRoundedTo5Minutes = referenceTimeInterval +((minuteInterval*60)-remainingSeconds);
                    }
                    
                    self.reminderTwoTime = [NSDate dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)timeRoundedTo5Minutes];
                    
                    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:
                                                         @"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:self.reminderTwoTime target:self action:@selector(time2WasSelected:element:) origin:self.tableView];
                    datePicker.minuteInterval = minuteInterval;
                    [datePicker showActionSheetPicker];
                    
                    break;
                }
            }
            break;
        }

	}
}

-(void)time1WasSelected:(NSDate *)selectedTime element:(id)element {
    NSDate *oldTime = self.reminderOneTime;
    NSLog(@"old time = %@",oldTime);
    NSLog(@"new time = %@",selectedTime);
    self.reminderOneTime = selectedTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    NSIndexPath *index =  [NSIndexPath indexPathForRow:0 inSection:11];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: index];
    cell.textLabel.text = [dateFormatter stringFromDate:selectedTime];
    
    [[NSUserDefaults standardUserDefaults] setObject:selectedTime forKey: @"reminderOneTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!([self.reminderOneTime compare: oldTime]==NSOrderedSame) && [[NSUserDefaults standardUserDefaults] boolForKey:@"reminderOneSet"]){
        
        NSLog(@"made it to if statement");
        
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *eventArray = [app scheduledLocalNotifications];
        NSLog(@"Event  Array = %@",eventArray);
        for (int i=0; i<[eventArray count]; i++)
        {
            UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
            NSDictionary *userInfoCurrent = oneEvent.userInfo;
            if ([[userInfoCurrent valueForKey:@"reminderNum"] isEqualToString:@"One"])
            {
                //Cancelling local notification
                [app cancelLocalNotification:oneEvent];
            }
        }
        
        NSArray *days = [[NSArray alloc]init];
        
        switch ([[[NSUserDefaults standardUserDefaults] valueForKey:@"reminderOneDays"] integerValue]){
            case 0:{
                days = @[@1,@2,@3,@4,@5,@6,@7];
            }
                break;
            case 1:{
                days = @[@2,@3,@4,@5,@6];
            }
                break;
            case 2: {
                days = @[@1,@7];
            }
                break;
            default: {
                days = @[@1,@2,@3,@4,@5,@6,@7];
            }
                break;
        };
        
        for (int i = 0;i<[days count];i++){
            NSInteger day = [[days objectAtIndex:i] integerValue];
            NSLog(@"day = %i",day);
            NSDate *today = [NSDate date];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSWeekdayCalendarUnit fromDate:today];
            NSInteger currentWeekday = components.weekday;
            NSLog(@"CurrentWeekday = %i",currentWeekday);
            NSInteger diff = day - currentWeekday;
            NSLog(@"Diff = %i",diff);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm a"];
            NSString *timeString = [dateFormatter stringFromDate:self.reminderOneTime];
            NSArray *timeArray = [timeString componentsSeparatedByString: @":"];
            NSInteger hour = [timeArray[0] integerValue];
            NSArray *back = [timeArray[1] componentsSeparatedByString:@" "];
            NSInteger min = [back[0] integerValue];
            if (back.count >1){
                NSString *ampm = back[1];
                if ([ampm isEqualToString: @"AM"]){
                    [components setHour: hour];
                }
                else{
                    [components setHour: hour + 12 ];
                }
            }
            else{
                [components setHour: hour];
            }
            [components setMinute: min];
            [components setSecond: 0];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            [calendar setTimeZone: [NSTimeZone defaultTimeZone]];
            NSDate *dateToFire = [[calendar dateFromComponents:components] dateByAddingTimeInterval:diff*86400];
            
            NSLog(@"Date to fire =%@", dateToFire);
            
            UIApplication *ORcycle = [UIApplication sharedApplication];
            UILocalNotification *remind = [[UILocalNotification alloc] init];
            remind.alertBody = @"ORcycle is reminding you to log a trip.";
            remind.soundName = @"bicycle-bell-normalized.aiff";
            remind.fireDate = dateToFire;
            NSLog(@"remind.firedate =%@", remind.fireDate);
            remind.timeZone = [NSTimeZone defaultTimeZone];
            remind.repeatInterval = NSWeekCalendarUnit;
            remind.userInfo = [NSMutableDictionary dictionaryWithObject:@"One"
                                                                 forKey:@"reminderNum"];
            [ORcycle scheduleLocalNotification:remind];
            [remind release];
            NSLog(@"remind.userinfo =%@", remind.userInfo);
        }
        
        
    }

}

-(void)time2WasSelected:(NSDate *)selectedTime element:(id)element {
    NSDate *oldTime = self.reminderTwoTime;
    self.reminderTwoTime = selectedTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    NSIndexPath *index =  [NSIndexPath indexPathForRow:0 inSection:12];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: index];
    cell.textLabel.text = [dateFormatter stringFromDate:selectedTime];
    
    [[NSUserDefaults standardUserDefaults] setObject:selectedTime forKey: @"reminderTwoTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!([self.reminderTwoTime compare: oldTime]==NSOrderedSame) && [[NSUserDefaults standardUserDefaults] boolForKey:@"reminderTwoSet"]){
        NSLog(@"made it to if statement");
        
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *eventArray = [app scheduledLocalNotifications];
        for (int i=0; i<[eventArray count]; i++)
        {
            UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
            NSDictionary *userInfoCurrent = oneEvent.userInfo;
            if ([[userInfoCurrent valueForKey:@"reminderNum"] isEqualToString:@"Two"])
            {
                //Cancelling local notification
                [app cancelLocalNotification:oneEvent];
            }
        }
        
        NSArray *days = [[NSArray alloc]init];
        
        switch ([[[NSUserDefaults standardUserDefaults] valueForKey:@"reminderTwoDays"] integerValue]){
            case 0:{
                days = @[@1,@2,@3,@4,@5,@6,@7];
            }
                break;
            case 1:{
                days = @[@2,@3,@4,@5,@6];
            }
                break;
            case 2: {
                days = @[@1,@7];
            }
                break;
            default: {
                days = @[@1,@2,@3,@4,@5,@6,@7];
            }
                break;
        };
        
        for (int i = 0;i<[days count];i++){
            NSInteger day = [[days objectAtIndex:i] integerValue];
            NSLog(@"day = %i",day);
            NSDate *today = [NSDate date];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSWeekdayCalendarUnit fromDate:today];
            NSInteger currentWeekday = components.weekday;
            NSLog(@"CurrentWeekday = %i",currentWeekday);
            NSInteger diff = day - currentWeekday;
            NSLog(@"Diff = %i",diff);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm a"];
            NSString *timeString = [dateFormatter stringFromDate:self.reminderTwoTime];
            NSArray *timeArray = [timeString componentsSeparatedByString: @":"];
            NSInteger hour = [timeArray[0] integerValue];
            NSArray *back = [timeArray[1] componentsSeparatedByString:@" "];
            NSInteger min = [back[0] integerValue];
            if (back.count >1){
                NSString *ampm = back[1];
                if ([ampm isEqualToString: @"AM"]){
                    [components setHour: hour];
                }
                else{
                    [components setHour: hour + 12 ];
                }
            }
            else{
                [components setHour: hour];
            }
            [components setMinute: min];
            [components setSecond: 0];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            [calendar setTimeZone: [NSTimeZone defaultTimeZone]];
            NSDate *dateToFire = [[calendar dateFromComponents:components] dateByAddingTimeInterval:diff*86400];
            
            NSLog(@"Date to fire =%@", dateToFire);
            
            UIApplication *ORcycle = [UIApplication sharedApplication];
            UILocalNotification *remind = [[UILocalNotification alloc] init];
            remind.alertBody = @"ORcycle is reminding you to log a trip.";
            remind.soundName = @"bicycle-bell-normalized.aiff";
            remind.fireDate = dateToFire;
            NSLog(@"remind.firedate =%@", remind.fireDate);
            remind.timeZone = [NSTimeZone defaultTimeZone];
            remind.repeatInterval = NSWeekCalendarUnit;
            remind.userInfo = [NSMutableDictionary dictionaryWithObject:@"Two"
                                                                 forKey:@"reminderNum"];
            [ORcycle scheduleLocalNotification:remind];
            [remind release];
        }
        
        
    }

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Other Bike Type"]){
        NSLog(@"Button Index =%ld",(long)buttonIndex);
        if (buttonIndex == 1) {  //Okay
            UITextField *otherBikeTypesField= [alertView textFieldAtIndex:0];
            self.otherBikeTypes = otherBikeTypesField.text;
            if (self.otherBikeTypes != NULL){
                NSMutableString *otherBikeTypesString = [NSMutableString stringWithFormat: @"Other ("];
                [otherBikeTypesString appendString:self.otherBikeTypes];
                [otherBikeTypesString appendString:@")"];
                NSIndexPath *index =  [NSIndexPath indexPathForRow:6 inSection:6];
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: index];
                cell.textLabel.text = otherBikeTypesString;
                [user setOtherBikeTypes: self.otherBikeTypes];
            }
        }
        NSLog(@"Saved other bike type as = %@",self.otherBikeTypes);
    }
    else if ([alertView.title isEqualToString:@"Other Ethnicity"]){
        NSLog(@"Button Index =%ld",(long)buttonIndex);
        if (buttonIndex == 1) {  //Okay
            UITextField *otherEthnicityField= [alertView textFieldAtIndex:0];
            self.otherEthnicity = otherEthnicityField.text;
            if (self.otherEthnicity != NULL){
                NSMutableString *otherEthnicityString = [NSMutableString stringWithFormat: @"Other ("];
                [otherEthnicityString appendString:self.otherEthnicity];
                [otherEthnicityString appendString:@")"];
                ethnicity.text = otherEthnicityString;
                [user setOtherEthnicity: self.otherEthnicity];
            }
        }
        NSLog(@"Saved other ethnicity as = %@",self.otherEthnicity);
    }
    else if ([alertView.title isEqualToString:@"Other Occupation"]){
        NSLog(@"Button Index =%ld",(long)buttonIndex);
        if (buttonIndex == 1) {  //Okay
            UITextField *otherOccupationField= [alertView textFieldAtIndex:0];
            self.otherOccupation = otherOccupationField.text;
            if (self.otherOccupation != NULL){
                NSMutableString *otherOccupationString = [NSMutableString stringWithFormat: @"Other ("];
                [otherOccupationString appendString:self.otherOccupation];
                [otherOccupationString appendString:@")"];
                occupation.text = otherOccupationString;
                [user setOtherOccupation: self.otherOccupation];
            }
        }
        NSLog(@"Saved other occupation as = %@",self.otherOccupation);
    }
    else if ([alertView.title isEqualToString:@"Other Gender"]){
        NSLog(@"Button Index =%ld",(long)buttonIndex);
        if (buttonIndex == 1) {  //Okay
            UITextField *otherGenderField= [alertView textFieldAtIndex:0];
            self.otherGender = otherGenderField.text;
            if (self.otherGender != NULL){
                NSMutableString *otherGenderString = [NSMutableString stringWithFormat: @"Other ("];
                [otherGenderString appendString:self.otherGender];
                [otherGenderString appendString:@")"];
                gender.text = otherGenderString;
                [user setOtherGender: self.otherGender];
            }
        }
        NSLog(@"Saved other gender as = %@",self.otherGender);
    }
    else if ([alertView.title isEqualToString:@"Other Rider Type"]){
        NSLog(@"Button Index =%ld",(long)buttonIndex);
        if (buttonIndex == 1) {  //Okay
            UITextField *otherRiderTypeField= [alertView textFieldAtIndex:0];
            self.otherRiderType = otherRiderTypeField.text;
            if (self.otherRiderType != NULL){
                NSMutableString *otherRiderTypeString = [NSMutableString stringWithFormat: @"Other ("];
                [otherRiderTypeString appendString:self.otherRiderType];
                [otherRiderTypeString appendString:@")"];
                riderType.text = otherRiderTypeString;
                [user setOtherRiderType: self.otherRiderType];
            }
        }
        NSLog(@"Saved other rider type as = %@",self.otherRiderType);
    }
    else if ([alertView.title isEqualToString:@"Feedback"]){
        NSLog(@"Button Index =%ld",(long)buttonIndex);
        if (buttonIndex == 1) {  //Okay
            UITextField *feedbackField= [alertView textFieldAtIndex:0];
            NSMutableString *mutableFeedback = [user.feedback mutableCopy];
            if (mutableFeedback.length >0){
                [mutableFeedback appendString: @". "];
                [mutableFeedback appendString: feedbackField.text];
                //NSRange range = {0,2};
                //[mutableFeedback deleteCharactersInRange:range];
            }
            else{
                mutableFeedback = [feedbackField.text mutableCopy];
            }
            self.feedback = mutableFeedback;
            [user setFeedback:feedback];
            NSLog(@"saved feedback: %@", user.feedback);

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
    
    
    if(currentTextField == gender){
        tView.text = [genderArray objectAtIndex:row];
    }
    else if(currentTextField == age){
        tView.text =  [ageArray objectAtIndex:row];
    }
    else if(currentTextField == ethnicity){
        tView.text =  [ethnicityArray objectAtIndex:row];
    }
    else if(currentTextField == occupation){
        tView.text =  [occupationArray objectAtIndex:row];
    }
    else if(currentTextField == income){
        tView.text = [incomeArray objectAtIndex:row];
    }
    else if(currentTextField == hhWorkers){
        tView.text =  [hhWorkersArray objectAtIndex:row];
    }
    else if(currentTextField == hhVehicles){
        tView.text = [hhVehiclesArray objectAtIndex:row];
    }
    else if(currentTextField == numBikes){
        tView.text = [numBikesArray objectAtIndex:row];
    }
    else if(currentTextField == cyclingFreq){
        tView.text = [cyclingFreqArray objectAtIndex:row];
    }
    else if(currentTextField == cyclingWeather){
        tView.text =  [cyclingWeatherArray objectAtIndex:row];
    }
    else if(currentTextField == riderAbility){
        tView.text =  [riderAbilityArray objectAtIndex:row];
    }
    else if(currentTextField == riderType){
        tView.text =  [riderTypeArray objectAtIndex:row];
    }
     

    return tView;
}


- (void) viewWillAppear:(BOOL)animated
{
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
}


- (void)dealloc {
    self.delegate = nil;
    self.managedObjectContext = nil;
    self.user = nil;
    self.age = nil;
    self.email = nil;
    self.feedback = nil;
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
    self.otherOccupation = nil;
    self.otherRiderType = nil;
    self.otherGender = nil;
    self.otherBikeTypes = nil;
    self.otherEthnicity = nil;
    
    [delegate release];
    [managedObjectContext release];
    [user release];
    [age release];
    [email release];
    [feedback release];
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
    
    [otherEthnicity release];
    [otherBikeTypes release];
    [otherGender release];
    [otherOccupation release];
    [otherRiderType release];
    
    [super dealloc];
}

@end

