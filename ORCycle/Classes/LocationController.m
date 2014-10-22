//
//  LocationController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/17/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import "LocationController.h"

@implementation LocationController

@synthesize currentLocation;
@synthesize locationServicesAvailable;

static LocationController *sharedInstance;

+ (LocationController *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
			[[LocationController alloc] init];              
    }
    return sharedInstance;
}

+(id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton LocationController.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

-(id) init {
    if ((self = [super init])) {
		locationServicesAvailable = NO;
        self.currentLocation = [[CLLocation alloc] init];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [self start];
    }
    return self;
}

-(void) start {
    [locationManager startUpdatingLocation];
}

-(void) stop {
    [locationManager stopUpdatingLocation];
}

-(BOOL) locationKnown {
    if (currentLocation) 
        return YES;
    else
        return NO;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //if the time interval returned from core location is more than two minutes we ignore it because it might be from an old session
    locationServicesAvailable = YES;
	if ( abs([newLocation.timestamp timeIntervalSinceDate: [NSDate date]]) < 120) {             
        self.currentLocation = newLocation;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	self.currentLocation = nil;
	locationServicesAvailable = NO;
}
@end
