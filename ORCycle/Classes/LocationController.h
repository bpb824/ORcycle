//
//  LocationController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/17/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface  LocationController : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
	bool locationServicesAvailable;
}

+ (LocationController *)sharedInstance;

-(void) start;
-(void) stop;
-(BOOL) locationKnown;

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic) bool locationServicesAvailable;

@end
