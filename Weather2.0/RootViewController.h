//
//  RootViewController.h
//  Weather2.0
//
//  Created by Admin on 25.03.16.
//  Copyright (c) 2016 com.evgenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocation.h>

@interface RootViewController : UIViewController <CLLocationManagerDelegate>{
    BOOL flag;
    BOOL ic;
    float a;
    float b;
    NSString * adr;
}
@property (weak, nonatomic) IBOutlet UIButton *pushButton;
@property (nonatomic, retain) CLLocationManager *gps;
@property (nonatomic, retain) IBOutlet UILabel *infoOldLocation;
@property (nonatomic, retain) IBOutlet UILabel *infoNewLocation;
@property (nonatomic, retain) CLLocation * nLocation;
@property (nonatomic, retain) CLLocation * oldLocation;
@property (nonatomic, retain) NSString * adr;


@end
