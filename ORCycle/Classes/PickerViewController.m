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
** 	Reno Tracks, Copyright 2012, 2013 Hack4Reno
*
*   @author Brad.Hellyar <bradhellyar@gmail.com>
*
*   Updated/Modified for Reno, Nevada app deployment. Based on the
*   CycleTracks codebase for SFCTA, and the Atlanta Cycle app repo.
*
** 	CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
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
//	PickerViewController.m
//	CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/28/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "CustomView.h"
#import "PickerViewController.h"
#import "DetailViewController.h"
#import "TripDetailViewController.h"
#import "TripManager.h"
#import "NoteManager.h"
#import "RecordTripViewController.h"


@implementation PickerViewController

@synthesize customPickerView, customPickerDataSource, delegate, description;
@synthesize descriptionText;


// return the picker frame based on its size
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	
	// layout at bottom of page
	/*
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
									screenRect.size.height - 84.0 - size.height,
									size.width,
									size.height);
	 */
	
	// layout at top of page
	//CGRect pickerRect = CGRectMake(	0.0, 0.0, size.width, size.height );	
	
	// layout at top of page, leaving room for translucent nav bar
	//CGRect pickerRect = CGRectMake(	0.0, 43.0, size.width, size.height );
    CGRect pickerRect;
    
	if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        CGRect pickerRect = CGRectMake(	0.0, 98.0, size.width, size.height );
        return pickerRect;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGRect pickerRect = CGRectMake(	0.0, 83.0, size.width, size.height );
        return pickerRect;
    }
    return pickerRect;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)createCustomPicker
{
	customPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	customPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	// setup the data source and delegate for this picker
	customPickerDataSource = [[CustomPickerDataSource alloc] init];
	customPickerDataSource.parent = self;
	customPickerView.dataSource = customPickerDataSource;
	customPickerView.delegate = customPickerDataSource;
	
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.
	//
	// position the picker at the bottom
	CGSize pickerSize = CGSizeMake(320, 216);
	customPickerView.frame = [self pickerFrameWithSize:pickerSize];
	
	customPickerView.showsSelectionIndicator = YES;
	
	// add this picker to our view controller, initially hidden
	//customPickerView.hidden = YES;
	[self.view addSubview:customPickerView];
}


- (IBAction)cancel:(id)sender
//add value to be sent in
{
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 3) {
        [delegate didCancelNoteDelete];
        NSLog(@"Note Cancel Pressed!!!!!!!!!!!!");
    }
    
    if (pickerCategory == 0) {
        [delegate didCancelNote];
        NSLog(@"Trip Cancel Pressed!!!!!!!!!!!!");
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];}


- (IBAction)save:(id)sender
{
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 0) {
        NSLog(@"Purpose Save button pressed");
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        TripDetailViewController *tripDetailViewController = [[TripDetailViewController alloc] initWithNibName:@"TripDetailViewController" bundle:nil];
        tripDetailViewController.delegate = self.delegate;
        
        [self presentViewController:tripDetailViewController animated:YES completion:nil];
        
        [delegate didPickPurpose:row];
        
        if(self.purposeOther.length >0){
            NSLog(@"Trying to save purposeOther as %@=",self.purposeOther);
            [delegate didEnterTripPurposeOther:self.purposeOther];
        }
    }
}


- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	NSLog(@"initWithNibNamed");
	if (self = [super initWithNibName:nibName bundle:nibBundle])
	{
		//NSLog(@"PickerViewController init");		
		[self createCustomPicker];
        
		pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
        if (pickerCategory == 0) {
            // picker defaults to top-most item => update the description
            [self pickerView:customPickerView didSelectRow:0 inComponent:0];
        }
        else if (pickerCategory == 3){
            // picker defaults to top-most item => update the description
            [self pickerView:customPickerView didSelectRow:0 inComponent:0];
        }
        
		
	}
	return self;
}


- (id)initWithPurpose:(NSInteger)index
{
	if (self = [self init])
	{
		//NSLog(@"PickerViewController initWithPurpose: %d", index);
		
		// update the picker
		[customPickerView selectRow:index inComponent:0 animated:YES];
		
		pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
        if (pickerCategory == 0) {
            // picker defaults to top-most item => update the description
            [self pickerView:customPickerView didSelectRow:0 inComponent:0];
        }
        else if (pickerCategory == 3){
            // picker defaults to top-most item => update the description
            [self pickerView:customPickerView didSelectRow:6 inComponent:0];
        }
	}
	return self;
}


- (void)viewDidLoad
{
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 0) {
        navBarItself.topItem.title = @"Trip Purpose";
        self.descriptionText.text = @"Please select your trip purpose & tap Save";
    }
    else if (pickerCategory == 1){
        navBarItself.topItem.title = @"Boo this...";
        self.descriptionText.text = @"Please select the issue type & tap Save";
    }
    /*
    else if (pickerCategory == 2){
        navBarItself.topItem.title = @"This is rad!";
        self.descriptionText.text = @"Please select the asset type & tap Save";
    }
     */
    else if (pickerCategory == 3){
        navBarItself.topItem.title = @"Mark Safety";
        self.descriptionText.text = @"Please select the type & tap Save";
        [self.customPickerView selectRow:0 inComponent:0 animated:NO];
        navBarItself.topItem.rightBarButtonItem.enabled = YES;
        /*
        if ([self.customPickerView selectedRowInComponent:0] == 6) {
            navBarItself.topItem.rightBarButtonItem.enabled = NO;
        }
        else{
            navBarItself.topItem.rightBarButtonItem.enabled = YES;
        }
         */
    }

	[super viewDidLoad];
    
	

	//self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	// self.view.backgroundColor = [[UIColor alloc] initWithRed:40. green:42. blue:57. alpha:1. ];

	// Set up the buttons.
	/*
	UIBarButtonItem* done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
															  target:self action:@selector(done)];
	done.enabled = YES;
	self.navigationItem.rightBarButtonItem = done;
	 */
	//[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	//description = [[UITextView alloc] initWithFrame:CGRectMake( 18.0, 280.0, 284.0, 130.0 )];
	description = [[UITextView alloc] initWithFrame:CGRectMake( 18.0, 314.0, 284.0, 120.0 )];
	description.editable = NO;
    description.backgroundColor = [UIColor clearColor];
    description.textColor = [UIColor blackColor];
    
	description.font = [UIFont fontWithName:@"Arial" size:16];
	[self.view addSubview:description];

}


// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark UIPickerViewDelegate


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerCategory == 3){
        if ([self.customPickerView selectedRowInComponent:0] == 6) {
            navBarItself.topItem.rightBarButtonItem.enabled = NO;
        }
        else{
            navBarItself.topItem.rightBarButtonItem.enabled = YES;
        }
    }
	//NSLog(@"parent didSelectRow: %d inComponent:%d", row, component);
    
    UIAlertView* purposeOtherView = [[UIAlertView alloc] initWithTitle:@"Other" message:@"If none of the other trip purposes describe your trip, please tell us about the purpose of your trip below" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    purposeOtherView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 0) {
        switch (row) {
            case 0:
                description.text = kDescCommute;
                break;
            case 1:
                description.text = kDescSchool;
                break;
            case 2:
                description.text = kDescWork;
                break;
            case 3:
                description.text = kDescExercise;
                break;
            case 4:
                description.text = kDescSocial;
                break;
            case 5:
                description.text = kDescErrand;
                break;
            case 6:
                description.text = kDescTranspoAccess;
                break;
            case 7:
                description.text = kDescOther;
                [purposeOtherView  show];
                break;
            default:
                description.text = kDescOther;
                break;
        }
    }
    /*

    else if (pickerCategory == 1){
        switch (row) {
            case 0:
                description.text = kIssueDescNarrowBikeLane;
                break;
            case 1:
                description.text = kIssueDescNoBikeLane;
                break;
            case 2:
                description.text = kIssueDescHighVehicleSpeeds;
                break;
            case 3:
                description.text = kIssueDescHighTrafficVolume;
                break;
            case 4:
                description.text = kIssueDescTurningVehicles;
                break;
            case 5:
                description.text = kIssueDescSignalTiming;
                break;
            case 6:
                description.text = kIssueDescSignalDetection;
                break;
            case 7:
                description.text = kIssueDescTruckTraffic;
                break;
            case 8:
                description.text = kIssueDescBusTrafficStop;
                break;
            case 9:
                description.text = kIssueDescParkedVehicles;
                break;
            case 10:
                description.text = kIssueDescPavementCondition;
                break;
            case 11:
                description.text = kIssueDescOther;
                break;
        }
    }
     */
    /*
    else if (pickerCategory == 2){
        switch (row) {
            case 0:
                description.text = kAssetDescBikeParking;
                break;
            case 1:
                description.text = kAssetDescBikeShops;
                break;
            case 2:
                description.text = kAssetDescPublicRestrooms;
                break;
            case 3:
                description.text = kAssetDescSecretPassage;
                break;
            case 4:
                description.text = kAssetDescWaterFountains;
                break;
            default:
                description.text = kAssetDescNoteThisSpot;
                break;
        }
    }
     */
    /*
    else if (pickerCategory == 3){
        switch (row) {
            case 0:
                description.text = kIssueDescNarrowBikeLane;
                break;
            case 1:
                description.text = kIssueDescNoBikeLane;
                break;
            case 2:
                description.text = kIssueDescHighVehicleSpeeds;
                break;
            case 3:
                description.text = kIssueDescHighTrafficVolume;
                break;
            case 4:
                description.text = kIssueDescTurningVehicles;
                break;
            case 5:
                description.text = kIssueDescSignalTiming;
                break;
            case 6:
                description.text = kIssueDescSignalDetection;
                break;
            case 7:
                description.text = kIssueDescTruckTraffic;
                break;
            case 8:
                description.text = kIssueDescBusTrafficStop;
                break;
            case 9:
                description.text = kIssueDescParkedVehicles;
                break;
            case 10:
                description.text = kIssueDescPavementCondition;
                break;
            case 11:
                description.text = kIssueDescOther;
                break;
        }
     
    }
     */
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index =%ld",(long)buttonIndex);
    if (buttonIndex == 1) {  //Okay
        UITextField *purposeOtherField= [alertView textFieldAtIndex:0];
        self.purposeOther = purposeOtherField.text;
    }
    NSLog(@"Saved purposeOther as = %@",self.purposeOther);
}



- (void)dealloc
{
    self.delegate = nil;
    self.customPickerView = nil;
	self.customPickerDataSource = nil;
    self.description = nil;
    self.descriptionText = nil;
    self.purposeOther = nil;
    
	[customPickerDataSource release];
	[customPickerView release];
    [delegate release];
    [description release];
    [descriptionText release];
    [purposeOther release];
    
    [navBarItself release];
	
	[super dealloc];
}

@end

