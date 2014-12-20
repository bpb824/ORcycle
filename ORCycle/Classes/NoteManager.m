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
//  TripManager.m
//	CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project,
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "constants.h"
#import "SaveRequest.h"
#import "TripManager.h"
#import "User.h"
#import "Note.h"
#import "NoteManager.h"
#import "LoadingView.h"
#import "RecordTripViewController.h"
#import "RenoTracksAppDelegate.h"
#import "ImageResize.h"
#import "NoteResponse.h"
#import <sys/utsname.h>


#define kSaveNoteProtocolVersion	4

@implementation NoteManager

@synthesize note, managedObjectContext, receivedDataNoted;
@synthesize uploadingView, parent;
@synthesize deviceUniqueIdHash1;

// change initialization values

// change this function for note detail view

// change this function for note initialization

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if ( self = [super init] )
	{
		self.managedObjectContext = context;
        self.activityDelegate = self;
        if (!note) {
            self.note = nil;
        }
        
    }
    return self;
}

//- (void)startAnimating{}
//- (void)updateSavingMessage:(NSString *)message{}
//- (void)updateBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{}
//- (void)stopAnimating {}
//- (void)dismissSaving{}

- (void)createNote
{
	NSLog(@"createNote");
	
	// Create and configure a new instance of the Note entity
    note = [(Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext] retain];
    
    [note setRecorded:[NSDate date]];
    NSLog(@"Date: %@", note.recorded);
    
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"createNote error %@, %@", error, [error localizedDescription]);
	}
}


//called from RecordTripViewController
- (void)addLocation:(CLLocation *)locationNow
{
    NSLog(@"This is very very special!");
    
    [self createNote];
    
    if(!note){
        NSLog(@"Note nil");
    }
    
    [note setAltitude:[NSNumber numberWithDouble:locationNow.altitude]];
    NSLog(@"Altitude: %f", [note.altitude doubleValue]);
    
    [note setLatitude:[NSNumber numberWithDouble:locationNow.coordinate.latitude]];
    NSLog(@"Latitude: %f", [note.latitude doubleValue]);
    
    [note setLongitude:[NSNumber numberWithDouble:locationNow.coordinate.longitude]];
    NSLog(@"Longitude: %f", [note.longitude doubleValue]);
    
    [note setSpeed:[NSNumber numberWithDouble:locationNow.speed]];
    NSLog(@"Speed: %f", [note.speed doubleValue]);
    
    [note setHAccuracy:[NSNumber numberWithDouble:locationNow.horizontalAccuracy]];
    NSLog(@"HAccuracy: %f", [note.hAccuracy doubleValue]);
    
    [note setVAccuracy:[NSNumber numberWithDouble:locationNow.verticalAccuracy]];
    NSLog(@"VAccuracy: %f", [note.vAccuracy doubleValue]);
    
//    [note setRecorded:locationNow.timestamp];
//    NSLog(@"Date: %@", note.recorded);
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
		NSLog(@"Note addLocation error %@, %@", error, [error localizedDescription]);
	}
    
}

/*
- (void)customLocation:(CLLocation *)locationPicked
{
    NSLog(@"Accessed custom location function in note manager");
    
    if(!note){
        NSLog(@"Note nil");
    }

    [note setAltitude:[NSNumber numberWithDouble:0]];
    NSLog(@"Altitude: %f", [note.altitude doubleValue]);
    
    [note setLatitude:[NSNumber numberWithDouble:locationPicked.coordinate.latitude]];
    NSLog(@"Latitude: %f", [note.latitude doubleValue]);
    
    [note setLongitude:[NSNumber numberWithDouble:locationPicked.coordinate.longitude]];
    NSLog(@"Longitude: %f", [note.longitude doubleValue]);
    
    [note setSpeed:[NSNumber numberWithDouble:0]];
    NSLog(@"Speed: %f", [note.speed doubleValue]);
    
    [note setHAccuracy:[NSNumber numberWithDouble:0]];
    NSLog(@"HAccuracy: %f", [note.hAccuracy doubleValue]);
    
    [note setVAccuracy:[NSNumber numberWithDouble:0]];
    NSLog(@"VAccuracy: %f", [note.vAccuracy doubleValue]);
    
    //    [note setRecorded:locationNow.timestamp];
    //    NSLog(@"Date: %@", note.recorded);
    
    NSError *error;
    if (![managedObjectContext save:&error]) {
        // Handle the error.
        NSLog(@"Note addLocation error %@, %@", error, [error localizedDescription]);
    }
    
}
*/


- (NSDictionary*)encodeUserData
{
    NSLog(@"encodeUserData");
    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithCapacity:5];
    
    NSFetchRequest		*request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSError *error;
    NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    //NSLog(@"saved user count  = %d", count);
    
    if ( count )
    {
        NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        if (mutableFetchResults == nil) {
            // Handle the error.
            NSLog(@"no saved user");
            if ( error != nil )
                NSLog(@"TripManager fetch saved user data error %@, %@", error, [error localizedDescription]);
        }
        
        NSString *appVersion = [NSString stringWithFormat:@"%@ (%@) on iOS %@",
                                [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                                [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                                [[UIDevice currentDevice] systemVersion]];
        
        
        
        NSString *model = [self deviceModelName];
        
        User *user = [mutableFetchResults objectAtIndex:0];
        if ( user != nil )
        {
            // initialize text fields to saved personal info
            [userDict setValue:user.email           forKey:@"email"];
            [userDict setValue:user.feedback         forKey:@"feedback"];
            [userDict setValue:user.userCreated      forKey:@"installed"];
            /*
             [userDict setValue:user.homeZIP         forKey:@"homeZIP"];
             [userDict setValue:user.workZIP         forKey:@"workZIP"];
             [userDict setValue:user.schoolZIP       forKey:@"schoolZIP"];
             */
            [userDict setValue:appVersion           forKey:@"app_version"];
            [userDict setValue:model                forKey:@"deviceModel"];
        }
        else
            NSLog(@"TripManager fetch user FAIL");
        
        [mutableFetchResults release];
    }
    else
        NSLog(@"TripManager WARNING no saved user data to encode");
    
    [request release];
    return userDict;
}

-(NSString*)deviceModelName {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //MARK: More official list is at
    //http://theiphonewiki.com/wiki/Models
    //MARK: You may just return machineName. Following is for convenience
    
    NSDictionary *commonNamesDictionary =
    @{
      @"i386":     @"iPhone Simulator",
      @"x86_64":   @"iPad Simulator",
      
      @"iPhone1,1":    @"iPhone",
      @"iPhone1,2":    @"iPhone 3G",
      @"iPhone2,1":    @"iPhone 3GS",
      @"iPhone3,1":    @"iPhone 4",
      @"iPhone3,2":    @"iPhone 4(Rev A)",
      @"iPhone3,3":    @"iPhone 4(CDMA)",
      @"iPhone4,1":    @"iPhone 4S",
      @"iPhone5,1":    @"iPhone 5(GSM)",
      @"iPhone5,2":    @"iPhone 5(GSM+CDMA)",
      @"iPhone5,3":    @"iPhone 5c(GSM)",
      @"iPhone5,4":    @"iPhone 5c(GSM+CDMA)",
      @"iPhone6,1":    @"iPhone 5s(GSM)",
      @"iPhone6,2":    @"iPhone 5s(GSM+CDMA)",
      
      @"iPhone7,1":    @"iPhone 6+ (GSM+CDMA)",
      @"iPhone7,2":    @"iPhone 6 (GSM+CDMA)",
      
      @"iPad1,1":  @"iPad",
      @"iPad2,1":  @"iPad 2(WiFi)",
      @"iPad2,2":  @"iPad 2(GSM)",
      @"iPad2,3":  @"iPad 2(CDMA)",
      @"iPad2,4":  @"iPad 2(WiFi Rev A)",
      @"iPad2,5":  @"iPad Mini 1G (WiFi)",
      @"iPad2,6":  @"iPad Mini 1G (GSM)",
      @"iPad2,7":  @"iPad Mini 1G (GSM+CDMA)",
      @"iPad3,1":  @"iPad 3(WiFi)",
      @"iPad3,2":  @"iPad 3(GSM+CDMA)",
      @"iPad3,3":  @"iPad 3(GSM)",
      @"iPad3,4":  @"iPad 4(WiFi)",
      @"iPad3,5":  @"iPad 4(GSM)",
      @"iPad3,6":  @"iPad 4(GSM+CDMA)",
      
      @"iPad4,1":  @"iPad Air(WiFi)",
      @"iPad4,2":  @"iPad Air(GSM)",
      @"iPad4,3":  @"iPad Air(GSM+CDMA)",
      
      @"iPad4,4":  @"iPad Mini 2G (WiFi)",
      @"iPad4,5":  @"iPad Mini 2G (GSM)",
      @"iPad4,6":  @"iPad Mini 2G (GSM+CDMA)",
      
      @"iPod1,1":  @"iPod 1st Gen",
      @"iPod2,1":  @"iPod 2nd Gen",
      @"iPod3,1":  @"iPod 3rd Gen",
      @"iPod4,1":  @"iPod 4th Gen",
      @"iPod5,1":  @"iPod 5th Gen",
      
      };
    
    NSString *deviceName = commonNamesDictionary[machineName];
    
    if (deviceName == nil) {
        deviceName = machineName;
    }
    
    return deviceName;
}

- (NSMutableArray*)encodeUserResponseData
{
    NSLog(@"encodeUserResponseData");
    
    NSMutableArray *userResponsesCollection = [[NSMutableArray alloc]init];
    
    NSFetchRequest		*request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSError *error;
    NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    //NSLog(@"saved user count  = %d", count);
    
    if ( count )
    {
        NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        if (mutableFetchResults == nil) {
            // Handle the error.
            NSLog(@"no saved user");
            if ( error != nil )
                NSLog(@"TripManager fetch saved user data error %@, %@", error, [error localizedDescription]);
        }
        
        User *user = [mutableFetchResults objectAtIndex:0];
        if ( user != nil )
        {
            NSArray *answers = @[[NSNumber numberWithInt:[user.age intValue]+1],
                                 [NSNumber numberWithInt:[user.gender intValue] + 9],
                                 [NSNumber numberWithInt:[user.ethnicity intValue]+13],
                                 [NSNumber numberWithInt:[user.occupation intValue] +20],
                                 [NSNumber numberWithInt:[user.income intValue]+26],
                                 [NSNumber numberWithInt:[user.hhWorkers intValue]+35],
                                 [NSNumber numberWithInt:[user.hhVehicles intValue]+40],
                                 [NSNumber numberWithInt:[user.numBikes intValue] +45 ],
                                 [NSNumber numberWithInt:[user.cyclingFreq intValue]+59 ],
                                 [NSNumber numberWithInt:[user.cyclingWeather intValue]+64],
                                 [NSNumber numberWithInt:[user.riderType intValue] + 75 ]];
            
            NSArray *questions = @[@1,@3,@4,@5,@6,@7,@8,@9,@14,@15,@17];
            
            for(int i = 0; i < [questions count];i++){
                NSMutableDictionary *userResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                [userResponseDict setObject:questions[i] forKey:@"question_id"];
                [userResponseDict setObject:answers[i] forKey:@"answer_id"];
                if (i == 1 && [answers[i] integerValue] == 12){
                    if(user.otherGender != NULL){
                        [userResponseDict setObject:user.otherGender forKey:@"other_text"];
                    }
                    else{
                        [userResponseDict setObject:@"Other not indicated" forKey:@"other_text"];
                    }
                    
                }
                else if (i == 2 && [answers[i] integerValue] == 19){
                    if (user.otherEthnicity != NULL){
                        [userResponseDict setObject:user.otherEthnicity forKey:@"other_text"];
                    }
                    else{
                        [userResponseDict setObject:@"Other not indicated" forKey:@"other_text"];
                    }
                }
                else if (i == 3 && [answers[i] integerValue] == 25){
                    if (user.otherOccupation != NULL){
                        [userResponseDict setObject:user.otherOccupation forKey:@"other_text"];
                    }
                    else{
                        [userResponseDict setObject:@"Other not indicated" forKey:@"other_text"];
                    }
                    
                }
                else if (i == 10 && [answers[i] integerValue] == 81){
                    if (user.otherRiderType != NULL){
                        [userResponseDict setObject:user.otherRiderType forKey:@"other_text"];
                    }
                    else{
                        [userResponseDict setObject:@"Other not indicated" forKey:@"other_text"];
                    }
                    
                }
                NSLog(@"%@", userResponseDict);
                userResponsesCollection[i] = userResponseDict;
            }
            //[NSNumber numberWithInt:[user.riderAbility intValue]+69],
            NSInteger riderAbilitySelectedRow = [user.riderAbility integerValue];
            
            switch (riderAbilitySelectedRow){
                case 0:{
                    NSMutableDictionary *userResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    [userResponseDict setObject:[NSNumber numberWithInt:16] forKey:@"question_id"];
                    [userResponseDict setObject:[NSNumber numberWithInt:69] forKey:@"answer_id"];
                    [userResponsesCollection addObject:userResponseDict];
                    break;
                }
                case 1:{
                    NSMutableDictionary *userResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    [userResponseDict setObject:[NSNumber numberWithInt:16] forKey:@"question_id"];
                    [userResponseDict setObject:[NSNumber numberWithInt:74] forKey:@"answer_id"];
                    [userResponsesCollection addObject:userResponseDict];
                    break;
                }
                case 2:{
                    NSMutableDictionary *userResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    [userResponseDict setObject:[NSNumber numberWithInt:16] forKey:@"question_id"];
                    [userResponseDict setObject:[NSNumber numberWithInt:73] forKey:@"answer_id"];
                    [userResponsesCollection addObject:userResponseDict];
                    break;
                }
                case 3:{
                    NSMutableDictionary *userResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    [userResponseDict setObject:[NSNumber numberWithInt:16] forKey:@"question_id"];
                    [userResponseDict setObject:[NSNumber numberWithInt:72] forKey:@"answer_id"];
                    [userResponsesCollection addObject:userResponseDict];
                    break;
                }
                case 4:{
                    NSMutableDictionary *userResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    [userResponseDict setObject:[NSNumber numberWithInt:16] forKey:@"question_id"];
                    [userResponseDict setObject:[NSNumber numberWithInt:71] forKey:@"answer_id"];
                    [userResponsesCollection addObject:userResponseDict];
                    break;
                }
                case 5:{
                    NSMutableDictionary *userResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    [userResponseDict setObject:[NSNumber numberWithInt:16] forKey:@"question_id"];
                    [userResponseDict setObject:[NSNumber numberWithInt:70] forKey:@"answer_id"];
                    [userResponsesCollection addObject:userResponseDict];
                    break;
                }
            }
            
            
            
            NSMutableArray *bikeTypesTemp = [[user.bikeTypes componentsSeparatedByString:@","] mutableCopy];
            NSMutableArray *bikeTypes = [[NSMutableArray alloc] init];
            for (NSString *s in bikeTypesTemp)
            {
                NSNumber *num = [NSNumber numberWithInt:[s intValue]];
                [bikeTypes addObject:num];
            }
            for (int i = 0; i < [bikeTypes count];i++){
                if([bikeTypes[i] integerValue] == 1){
                    NSMutableDictionary *userResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    [userResponseDict setObject: [NSNumber numberWithInt:10] forKey:@"question_id"];
                    [userResponseDict setObject: [NSNumber numberWithInt:i + 52] forKey:@"answer_id"];
                    if (i == 6){
                        if (user.otherBikeTypes != NULL){
                            [userResponseDict setObject:user.otherBikeTypes forKey:@"other_text"];
                        }
                        else{
                            [userResponseDict setObject:@"Other not indicated" forKey:@"other_text"];
                        }
                        
                    }
                    [userResponsesCollection addObject:userResponseDict];
                }
            }
        }
        else
            NSLog(@"TripManager fetch user FAIL");
        
        [mutableFetchResults release];
    }
    else
        NSLog(@"TripManager WARNING no saved user response data to encode");
    
    [request release];
    return userResponsesCollection;
}


- (NSMutableArray*)encodeNoteResponseData
{
	NSLog(@"encodeNoteResponseData");
	NSMutableArray *noteResponsesCollection = [[NSMutableArray alloc]init];
	
	NSFetchRequest		*request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteResponse" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSError *error;
	NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"saved note response count  = %ld", (long)count);
    
    if ( count )
	{
		NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
		if (mutableFetchResults == nil) {
			// Handle the error.
			NSLog(@"no saved trip");
			if ( error != nil )
				NSLog(@"TripManager fetch saved trip data error %@, %@", error, [error localizedDescription]);
		}
        NSInteger last = [mutableFetchResults count] -1 ;
		NoteResponse *noteResponse = [mutableFetchResults objectAtIndex:last];
        NSLog(@" note response received from core data as %@", noteResponse);
		if ( noteResponse != nil ){
            
            if (note.isCrash){
                if (!([noteResponse.severity integerValue] == 0)){
                    NSNumber *severity = [[NSNumber alloc] init];
                    switch ([noteResponse.severity integerValue]) {
                        case 1:
                            severity = [NSNumber numberWithInt:151];
                            break;
                        case 2:
                            severity = [NSNumber numberWithInt:152];
                            break;
                        case 3:
                            severity = [NSNumber numberWithInt:153];
                            break;
                        case 4:
                            severity = [NSNumber numberWithInt:154];
                            break;
                        case 5:
                            severity = [NSNumber numberWithInt:155];
                            break;
                        default:
                            break;
                    }
                    
                    
                    NSMutableDictionary *noteResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    [noteResponseDict setObject:[NSNumber numberWithInt:28] forKey:@"question_id"];
                    [noteResponseDict setObject:severity forKey:@"answer_id"];
                    NSLog(@"%@", noteResponseDict);
                    [noteResponsesCollection addObject:noteResponseDict];
                }
                else{
                    NSNumber *severity = [NSNumber numberWithInt:176];
                    NSMutableDictionary *noteResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    [noteResponseDict setObject:[NSNumber numberWithInt:28] forKey:@"question_id"];
                    [noteResponseDict setObject:severity forKey:@"answer_id"];
                    NSLog(@"%@", noteResponseDict);
                    [noteResponsesCollection addObject:noteResponseDict];
                }
                
                NSMutableArray *conflictWithTemp = [[noteResponse.conflictWith componentsSeparatedByString:@","] mutableCopy];
                NSMutableArray *conflictWith = [[NSMutableArray alloc] init];
                for (NSString *s in conflictWithTemp)
                {
                    NSNumber *num = [NSNumber numberWithInt:[s intValue]];
                    [conflictWith addObject:num];
                }
                
                for (int i = 0; i < [conflictWith count];i++){
                    if([conflictWith[i] integerValue] == 1){
                        NSNumber *conflictIndex = [[NSNumber alloc]init];
                        switch (i) {
                            case 0:
                                conflictIndex = [NSNumber numberWithInt:156];
                                break;
                            case 1:
                                conflictIndex = [NSNumber numberWithInt:157];
                                break;
                            case 2:
                                conflictIndex = [NSNumber numberWithInt:158];
                                break;
                            case 3:
                                conflictIndex = [NSNumber numberWithInt:159];
                                break;
                            case 4:
                                conflictIndex = [NSNumber numberWithInt:160];
                                break;
                            case 5:
                                conflictIndex = [NSNumber numberWithInt:161];
                                break;
                            case 6:
                                conflictIndex = [NSNumber numberWithInt:162];
                                break;
                            case 7:
                                conflictIndex = [NSNumber numberWithInt:163];
                                break;
                            case 8:
                                conflictIndex = [NSNumber numberWithInt:177];
                                break;
                            case 9:
                                conflictIndex = [NSNumber numberWithInt:178];
                                break;
                            default:
                                break;
                        }
                        NSMutableDictionary *noteResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                        [noteResponseDict setObject: [NSNumber numberWithInt:29] forKey:@"question_id"];
                        [noteResponseDict setObject:conflictIndex forKey:@"answer_id"];
                        if (i == 9){
                            if (note.otherConflictWith != NULL){
                                [noteResponseDict setObject:note.otherConflictWith forKey:@"other_text"];
                            }
                            else{
                                [noteResponseDict setObject:@"Other not indicated" forKey:@"other_text"];
                            }
                        }
                        [noteResponsesCollection addObject:noteResponseDict];
                    }
                }
                
                NSMutableArray *crashActionsTemp = [[noteResponse.crashActions componentsSeparatedByString:@","] mutableCopy];
                NSMutableArray *crashActions = [[NSMutableArray alloc] init];
                for (NSString *s in crashActionsTemp)
                {
                    NSNumber *num = [NSNumber numberWithInt:[s intValue]];
                    [crashActions addObject:num];
                }
                
                for (int i = 0; i < [crashActions count];i++){
                    if([crashActions[i] integerValue] == 1){
                        NSNumber *actionIndex = [[NSNumber alloc]init];
                        switch (i) {
                            case 0:
                                actionIndex = [NSNumber numberWithInt:187];
                                break;
                            case 1:
                                actionIndex = [NSNumber numberWithInt:188];
                                break;
                            case 2:
                                actionIndex = [NSNumber numberWithInt:189];
                                break;
                            case 3:
                                actionIndex = [NSNumber numberWithInt:190];
                                break;
                            case 4:
                                actionIndex = [NSNumber numberWithInt:191];
                                break;
                            case 5:
                                actionIndex = [NSNumber numberWithInt:192];
                                break;
                            case 6:
                                actionIndex = [NSNumber numberWithInt:193];
                                break;
                            case 7:
                                actionIndex = [NSNumber numberWithInt:194];
                                break;
                            case 8:
                                actionIndex = [NSNumber numberWithInt:195];
                                break;
                            case 9:
                                actionIndex = [NSNumber numberWithInt:207];
                                break;
                            default:
                                break;
                        }
                        NSMutableDictionary *noteResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                        [noteResponseDict setObject: [NSNumber numberWithInt:32] forKey:@"question_id"];
                        [noteResponseDict setObject:actionIndex forKey:@"answer_id"];
                        if (i == 9){
                            if (note.otherCrashActions != NULL){
                                [noteResponseDict setObject:note.otherCrashActions forKey:@"other_text"];
                            }
                            else{
                                [noteResponseDict setObject:@"Other not indicated" forKey:@"other_text"];
                            }
                        }
                        [noteResponsesCollection addObject:noteResponseDict];
                    }
                }
                
                NSMutableArray *crashReasonsTemp = [[noteResponse.crashReasons componentsSeparatedByString:@","] mutableCopy];
                NSMutableArray *crashReasons = [[NSMutableArray alloc] init];
                for (NSString *s in crashReasonsTemp)
                {
                    NSNumber *num = [NSNumber numberWithInt:[s intValue]];
                    [crashReasons addObject:num];
                }
                
                for (int i = 0; i < [crashReasons count];i++){
                    if([crashReasons[i] integerValue] == 1){
                        NSNumber *reasonIndex = [[NSNumber alloc]init];
                        switch (i) {
                            case 0:
                                reasonIndex = [NSNumber numberWithInt:196];
                                break;
                            case 1:
                                reasonIndex = [NSNumber numberWithInt:197];
                                break;
                            case 2:
                                reasonIndex = [NSNumber numberWithInt:198];
                                break;
                            case 3:
                                reasonIndex = [NSNumber numberWithInt:199];
                                break;
                            case 4:
                                reasonIndex = [NSNumber numberWithInt:200];
                                break;
                            case 5:
                                reasonIndex = [NSNumber numberWithInt:201];
                                break;
                            case 6:
                                reasonIndex = [NSNumber numberWithInt:202];
                                break;
                            case 7:
                                reasonIndex = [NSNumber numberWithInt:203];
                                break;
                            case 8:
                                reasonIndex = [NSNumber numberWithInt:204];
                                break;
                            case 9:
                                reasonIndex = [NSNumber numberWithInt:205];
                                break;
                            case 10:
                                reasonIndex = [NSNumber numberWithInt:206];
                                break;
                            default:
                                break;
                        }
                        NSMutableDictionary *noteResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                        [noteResponseDict setObject: [NSNumber numberWithInt:33] forKey:@"question_id"];
                        [noteResponseDict setObject:reasonIndex forKey:@"answer_id"];
                        if (i == 10){
                            if (note.otherCrashReasons != NULL){
                                [noteResponseDict setObject:note.otherCrashReasons forKey:@"other_text"];
                            }
                            else{
                                [noteResponseDict setObject:@"Other not indicated" forKey:@"other_text"];
                            }
                        }
                        [noteResponsesCollection addObject:noteResponseDict];
                    }
                }


                
            }
            else{
                if (!([noteResponse.urgency integerValue] == 0)){
                    NSNumber *urgency = [[NSNumber alloc] init];
                    switch ([noteResponse.urgency integerValue]) {
                        case 1:
                            urgency = [NSNumber numberWithInt:181];
                            break;
                        case 2:
                            urgency = [NSNumber numberWithInt:182];
                            break;
                        case 3:
                            urgency = [NSNumber numberWithInt:183];
                            break;
                        case 4:
                            urgency = [NSNumber numberWithInt:184];
                            break;
                        case 5:
                            urgency = [NSNumber numberWithInt:185];
                            break;
                        default:
                            break;
                    }
                    
                    
                    NSMutableDictionary *noteResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    [noteResponseDict setObject:[NSNumber numberWithInt:31] forKey:@"question_id"];
                    [noteResponseDict setObject:urgency forKey:@"answer_id"];
                    NSLog(@"%@", noteResponseDict);
                    [noteResponsesCollection addObject:noteResponseDict];
                }
                else{
                    NSNumber *urgency = [NSNumber numberWithInt:186];
                    NSMutableDictionary *noteResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    [noteResponseDict setObject:[NSNumber numberWithInt:31] forKey:@"question_id"];
                    [noteResponseDict setObject:urgency forKey:@"answer_id"];
                    NSLog(@"%@", noteResponseDict);
                    [noteResponsesCollection addObject:noteResponseDict];
                }
                
                NSMutableArray *issueTypeTemp = [[noteResponse.issueType componentsSeparatedByString:@","] mutableCopy];
                NSMutableArray *issueType = [[NSMutableArray alloc] init];
                for (NSString *s in issueTypeTemp)
                {
                    NSNumber *num = [NSNumber numberWithInt:[s intValue]];
                    [issueType addObject:num];
                }
                
                for (int i = 0; i < [issueType count];i++){
                    if([issueType[i] integerValue] == 1){
                        NSNumber *issueIndex = [[NSNumber alloc]init];
                        switch (i) {
                            case 0:
                                issueIndex = [NSNumber numberWithInt:164];
                                break;
                            case 1:
                                issueIndex = [NSNumber numberWithInt:165];
                                break;
                            case 2:
                                issueIndex = [NSNumber numberWithInt:166];
                                break;
                            case 3:
                                issueIndex = [NSNumber numberWithInt:167];
                                break;
                            case 4:
                                issueIndex = [NSNumber numberWithInt:168];
                                break;
                            case 5:
                                issueIndex = [NSNumber numberWithInt:169];
                                break;
                            case 6:
                                issueIndex = [NSNumber numberWithInt:170];
                                break;
                            case 7:
                                issueIndex = [NSNumber numberWithInt:171];
                                break;
                            case 8:
                                issueIndex = [NSNumber numberWithInt:172];
                                break;
                            case 9:
                                issueIndex = [NSNumber numberWithInt:173];
                                break;
                            case 10:
                                issueIndex = [NSNumber numberWithInt:174];
                                break;
                            case 11:
                                issueIndex = [NSNumber numberWithInt:175];
                                break;
                            case 12:
                                issueIndex = [NSNumber numberWithInt:179];
                                break;
                            case 13:
                                issueIndex = [NSNumber numberWithInt:180];
                                break;
                            default:
                                break;
                        }
                        
                        NSMutableDictionary *noteResponseDict = [NSMutableDictionary dictionaryWithCapacity:2];
                        [noteResponseDict setObject: [NSNumber numberWithInt:30] forKey:@"question_id"];
                        [noteResponseDict setObject:issueIndex forKey:@"answer_id"];
                        if (i == 11){
                            if (note.otherIssueType != NULL){
                                [noteResponseDict setObject:note.otherIssueType forKey:@"other_text"];
                            }
                            else{
                                [noteResponseDict setObject:@"Other not indicated" forKey:@"other_text"];
                            }
                            
                        }
                        [noteResponsesCollection addObject:noteResponseDict];
                    }
                }

            }
        }
		else
			NSLog(@"TripManager fetch user FAIL");
		
		[mutableFetchResults release];
	}
	else
		NSLog(@"TripManager WARNING no saved user response data to encode");
    [request release];
    return noteResponsesCollection;
}

//called in DetailViewController once pressing skip or save
- (void)saveNote
{
    NSMutableDictionary *noteDict;
	
	// format date as a string
	NSDateFormatter *outputFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDateFormatter *outputFormatterURL = [[[NSDateFormatter alloc] init] autorelease];
	[outputFormatterURL setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    NSLog(@"saving using protocol version 4");
	
    // create a noteDict for each note
    noteDict = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    [noteDict setValue:note.altitude  forKey:@"a"];  //altitude
    [noteDict setValue:note.latitude  forKey:@"l"];  //latitude
    [noteDict setValue:note.longitude forKey:@"n"];  //longitude
    [noteDict setValue:note.speed     forKey:@"s"];  //speed
    [noteDict setValue:note.hAccuracy forKey:@"h"];  //haccuracy
    [noteDict setValue:note.vAccuracy forKey:@"v"];  //vaccuracy
    [noteDict setValue:note.details forKey:@"d"];  //details
    
    NSString *newDateString = [outputFormatter stringFromDate:note.recorded];
    NSString *newDateStringURL = [outputFormatterURL stringFromDate:note.recorded];
    [noteDict setValue:newDateString forKey:@"r"];    //recorded timestamp
    
    RenoTracksAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.deviceUniqueIdHash1 = delegate.uniqueIDHash;
    NSLog(@"deviceUniqueIdHash is %@", deviceUniqueIdHash1);
    
    //generated from userid, recordedtime and type
    
    if (note.image_data == nil) {
        note.image_url =@"";
    }
    else {
        note.image_url = [NSString stringWithFormat:@"%@-%@-type-%@",deviceUniqueIdHash1,newDateStringURL,note.note_type];
    }
    NSLog(@"img_url: %@", note.image_url);
    
    UIImage *castedImage = [[UIImage alloc] initWithData:note.image_data];
    
    CGSize size;
    if (castedImage.size.height > castedImage.size.width) {
        size.height = 480;
        size.width = 320;
    }
    else {
        size.height = 320;
        size.width = 480;
    }
    
    NSData *uploadData = [[NSData alloc] initWithData:UIImageJPEGRepresentation([ImageResize imageWithImage:castedImage scaledToSize:size], kJpegQuality)];
    
    NSLog(@"Size of Image(bytes):%d", [uploadData length]);
    
    [noteDict setValue:note.image_url forKey:@"i"];  //image_url
    //[noteDict setValue:note.image_data forKey:@"g"];  //image_data
        
    // JSON encode user data and trip data, return to strings
    NSError *writeError = nil;
    
    // JSON encode user data
    NSDictionary *userDict = [self encodeUserData];
    NSData *userJsonData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:&writeError];
    NSString *userJson = [[[NSString alloc] initWithData:userJsonData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"user data %@", userJson);

    // encode user response data
    NSMutableArray *userResponsesCollection = [self encodeUserResponseData];
    NSData *userResponseJsonData = [NSJSONSerialization dataWithJSONObject:userResponsesCollection options:0 error:&writeError];
    NSString *userResponseJson = [[[NSString alloc] initWithData:userResponseJsonData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"user response data %@", userResponseJson);
    
    // JSON encode the Note data
    NSData *noteJsonData = [[NSData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:noteDict options:0 error:&writeError]];
    NSString *noteJson = [[NSString alloc] initWithData:noteJsonData encoding:NSUTF8StringEncoding];
    
    // JSON encode the Note Response data
    NSMutableArray *noteResponsesCollection = [self encodeNoteResponseData];
    NSData *noteResponsesJsonData = [NSJSONSerialization dataWithJSONObject: noteResponsesCollection options:0 error:&writeError];
    NSString *noteResponseJson = [[NSString alloc] initWithData:noteResponsesJsonData encoding:NSUTF8StringEncoding];
    
	// NOTE: device hash added by SaveRequest initWithPostVars
	NSDictionary *postVars = [NSDictionary dictionaryWithObjectsAndKeys: 
                              noteJson, @"note",
                              noteResponseJson, @"noteResponses",
                              userJson, @"user",
                              userResponseJson, @"userResponses",
                              
							  [NSString stringWithFormat:@"%d", kSaveNoteProtocolVersion], @"version",
//                              [NSData dataWithData:note.image_data], @"image_data",
							  nil];
	NSLog(@"%@", postVars);
    // create save request
	SaveRequest *saveRequest = [[SaveRequest alloc] initWithPostVars:postVars with:4 image:uploadData];
	
	// create the connection with the request and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:[saveRequest request] delegate:self];
	
    // create loading view to indicate trip is being uploaded
    uploadingView = [[LoadingView loadingViewInView:parent.parentViewController.view messageString:kSavingNoteTitle] retain];
    
    //switch to map w/ trip view
    
    NSInteger recording = [[NSUserDefaults standardUserDefaults] integerForKey:@"recording"];
    
    
    if (recording == 0) {
        [parent displayUploadedNote];
    }
    
    NSLog(@"note save and parent");
    
    if ( theConnection )
    {
        receivedDataNoted=[[NSMutableData data] retain];
    }
    else
    {
        // inform the user that the download could not be made
        
    }
    
    [noteJson release];
    [noteJsonData release];
    [castedImage release];
    [uploadData release];
    [saveRequest release];
}


- (void)saveNote:(Note*)_note
{NSMutableDictionary *noteDict;
    NSMutableDictionary *noteResponseDict;
	
	// format date as a string
	NSDateFormatter *outputFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDateFormatter *outputFormatterURL = [[[NSDateFormatter alloc] init] autorelease];
	[outputFormatterURL setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    NSLog(@"saving using protocol version 4");
	
    // create a noteDict for each note
    noteDict = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    [noteDict setValue:note.altitude  forKey:@"a"];  //altitude
    [noteDict setValue:note.latitude  forKey:@"l"];  //latitude
    [noteDict setValue:note.longitude forKey:@"n"];  //longitude
    [noteDict setValue:note.speed     forKey:@"s"];  //speed
    [noteDict setValue:note.hAccuracy forKey:@"h"];  //haccuracy
    [noteDict setValue:note.vAccuracy forKey:@"v"];  //vaccuracy
    [noteDict setValue:note.details forKey:@"d"];  //details
    
    NSString *newDateString = [outputFormatter stringFromDate:note.recorded];
    NSString *newDateStringURL = [outputFormatterURL stringFromDate:note.recorded];
    [noteDict setValue:newDateString forKey:@"r"];    //recorded timestamp
    
    noteResponseDict =[[[NSMutableDictionary alloc] initWithCapacity:2]autorelease];
    [noteResponseDict setValue:[NSString stringWithFormat:@"%d",30]      forKey:@"question_id"];//note_type
    [noteResponseDict setValue:note.note_type     forKey:@"answer_id"];  //note_type
    
    RenoTracksAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.deviceUniqueIdHash1 = delegate.uniqueIDHash;
    NSLog(@"deviceUniqueIdHash is %@", deviceUniqueIdHash1);
    
    //generated from userid, recordedtime and type
    
    if (_note.image_data == nil) {
        _note.image_url =@"";
    }
    else {
        _note.image_url = [NSString stringWithFormat:@"%@-%@-type-%@",deviceUniqueIdHash1,newDateStringURL,_note.note_type];
    }
    NSLog(@"note_type: %d", [_note.note_type intValue]);
    NSLog(@"img_url: %@", _note.image_url);
    NSLog(@"img_url: %@", _note.details);
    
    UIImage *castedImage = [[UIImage alloc] initWithData:_note.image_data];
    
    CGSize size;
    if (castedImage.size.height > castedImage.size.width) {
        size.height = 480;
        size.width = 320;
    }
    else {
        size.height = 320;
        size.width = 480;
    }

    NSData *uploadData = [[NSData alloc] initWithData:UIImageJPEGRepresentation([ImageResize imageWithImage:castedImage scaledToSize:size], kJpegQuality)];
    
    NSLog(@"Size of Image(bytes):%d", [uploadData length]);
    
    [noteDict setValue:_note.image_url forKey:@"i"];  //image_url
    //[noteDict setValue:note.image_data forKey:@"g"];  //image_data
    
    // JSON encode user data and trip data, return to strings
    NSError *writeError = nil;
    
    // JSON encode user data
    NSDictionary *userDict = [self encodeUserData];
    NSData *userJsonData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:&writeError];
    NSString *userJson = [[[NSString alloc] initWithData:userJsonData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"user data %@", userJson);
    
    // encode user response data
    NSMutableArray *userResponsesCollection = [self encodeUserResponseData];
    NSData *userResponseJsonData = [NSJSONSerialization dataWithJSONObject:userResponsesCollection options:0 error:&writeError];
    NSString *userResponseJson = [[[NSString alloc] initWithData:userResponseJsonData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"user response data %@", userResponseJson);
    
    // JSON encode the Note data
    NSData *noteJsonData = [[NSData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:noteDict options:0 error:&writeError]];
    
    NSString *noteJson = [[NSString alloc] initWithData:noteJsonData encoding:NSUTF8StringEncoding];
    
    // JSON encode the Note Response data
    NSData *noteResponseJsonData = [[NSData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:noteResponseDict options:0 error:&writeError]];
    
    NSString *noteResponseJson = [[NSString alloc] initWithData:noteResponseJsonData encoding:NSUTF8StringEncoding];
    
	// NOTE: device hash added by SaveRequest initWithPostVars
	NSDictionary *postVars = [NSDictionary dictionaryWithObjectsAndKeys:
                              noteJson, @"note",
                              noteResponseJson, @"noteResponses",
                              userJson, @"user",
                              userResponseJson, @"userResponses",

							  [NSString stringWithFormat:@"%d", kSaveNoteProtocolVersion], @"version",
                              //                              [NSData dataWithData:note.image_data], @"image_data",
							  nil];
	NSLog(@"%@", postVars);
	// create save request
	SaveRequest *saveRequest = [[SaveRequest alloc] initWithPostVars:postVars with:4 image:uploadData];
	
	// create the connection with the request and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:[saveRequest request] delegate:self];
	
    // create loading view to indicate trip is being uploaded
    uploadingView = [[LoadingView loadingViewInView:parent.parentViewController.view messageString:kSavingNoteTitle] retain];
    
    //switch to map w/ trip view
    
    NSInteger recording = [[NSUserDefaults standardUserDefaults] integerForKey:@"recording"];
    
    
    if (recording == 0) {
        [parent displayUploadedNote];
    }
    
    NSLog(@"note save and parent");
    
    if ( theConnection )
    {
        receivedDataNoted=[[NSMutableData data] retain];
    }
    else
    {
        // inform the user that the download could not be made
        
    }
    
    [noteJson release];
    [noteResponseJson release];
    [noteResponseJsonData release];
    [noteJsonData release];
    [castedImage release];
    [uploadData release];
    [saveRequest release];
}


#pragma mark NSURLConnection delegate methods


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	NSLog(@"%d bytesWritten, %d totalBytesWritten, %d totalBytesExpectedToWrite",
		  bytesWritten, totalBytesWritten, totalBytesExpectedToWrite );
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	NSLog(@"didReceiveResponse: %@", response);
	
	NSHTTPURLResponse *httpResponse = nil;
	if ( [response isKindOfClass:[NSHTTPURLResponse class]] &&
		( httpResponse = (NSHTTPURLResponse*)response ) )
	{
		BOOL success = NO;
		NSString *title   = nil;
		NSString *message = nil;
		switch ( [httpResponse statusCode] )
		{
			case 200:
			case 201:
				success = YES;
				title	= kSuccessTitle;
				message = kSaveSuccess;
				break;
			case 202:
				success = YES;
				title	= kSuccessTitle;
				message = kSaveAccepted;
				break;
			case 500:
			default:
				title = @"Internal Server Error";
				//message = [NSString stringWithFormat:@"%d", [httpResponse statusCode]];
				message = kServerError;
		}
		
		NSLog(@"%@: %@", title, message);
        
        //
        // DEBUG
        NSLog(@"+++++++DEBUG didReceiveResponse %@: %@", [response URL],[(NSHTTPURLResponse*)response allHeaderFields]);
        
        if ( success )
		{
            [note setUploaded:[NSDate date]];
			
			NSError *error;
			if (![managedObjectContext save:&error]) {
				// Handle the error.
				NSLog(@"TripManager setUploaded error %@, %@", error, [error localizedDescription]);
			}
            
            [uploadingView loadingComplete:kSuccessTitle delayInterval:.7];
		} else {
            
            [uploadingView loadingComplete:kServerError delayInterval:1.5];
        }
	}
	
    // it can be called multiple times, for example in the case of a
	// redirect, so each time we reset the data.
	
    // receivedData is declared as a method instance elsewhere
    [receivedDataNoted setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
	[receivedDataNoted appendData:data];
    //	[activityDelegate startAnimating];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
	
    // receivedData is declared as a method instance elsewhere
    [receivedDataNoted release];
    
    // TODO: is this really adequate...?
    [uploadingView loadingComplete:kConnectionError delayInterval:1.5];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// do something with the data
    NSLog(@"+++++++DEBUG: Received %d bytes of data", [receivedDataNoted length]);
	NSLog(@"%@", [[[NSString alloc] initWithData:receivedDataNoted encoding:NSUTF8StringEncoding] autorelease] );
    
    // release the connection, and the data object
    [connection release];
    [receivedDataNoted release];
}

- (id)initWithNote:(Note *)_note
{
    if ( self = [super init] )
	{
		self.activityDelegate = self;
		[self loadNote:_note];
    }
    return self;
}

- (BOOL)loadNote:(Note *)_note
{
    if ( _note )
	{
		self.note					= _note;
		self.managedObjectContext	= [_note managedObjectContext];
        
		// save updated duration to CoreData
		NSError *error;
		if (![self.managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"loadNote error %@, %@", error, [error localizedDescription]);
            
		}
    }
    return YES;
}

- (void)dealloc {
    self.deviceUniqueIdHash1 = nil;
    self.activityDelegate = nil;
    self.alertDelegate = nil;
    self.activityIndicator = nil;
    self.uploadingView = nil;
    self.parent = nil;
    self.dirty = nil;
    self.note = nil;
    self.managedObjectContext = nil;
    self.receivedDataNoted = nil;
    
    
    [deviceUniqueIdHash1 release];
    [_activityDelegate release];
    [_alertDelegate release];
    [_activityIndicator release];
    [uploadingView release];
    [parent release];
    [note release];
    [managedObjectContext release];
    [receivedDataNoted release];
    
    [super dealloc];
}


@end
