//
//  TutorialDelegate.h
//  ORcycle
//
//  Created by orcycle on 12/14/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol TutorialDelegate <NSObject>

@optional
- (void)didFinishTutorial;

@end
