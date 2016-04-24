//
//  SecondViewController.h
//  Weather
//
//  Created by Admin on 25.03.16.
//  Copyright (c) 2016 com.evgenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQL.h"
#import "RootViewController.h"
@interface SecondViewController : UIViewController{
    YQL * yql;
}
- (IBAction)RefreshWeather:(id)sender;

@end
