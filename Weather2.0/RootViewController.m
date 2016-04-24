//
//  RootViewController.m
//  Weather
//
//  Created by Admin on 25.03.16.
//  Copyright (c) 2016 com.evgenia. All rights reserved.
//

#import "RootViewController.h"
#include<unistd.h>
#include<netdb.h>
#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

@interface RootViewController ()

@end

@implementation RootViewController{
    IBOutlet UIButton * _detectLocation;
    IBOutlet UILabel *_label;
    IBOutlet UIActivityIndicatorView *_ActivityIndicator;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
@synthesize gps;
@synthesize infoOldLocation;
@synthesize infoNewLocation;
@synthesize nLocation;
@synthesize adr;

- (void)viewDidLoad
{
    [self setUpDetectLocationButton];
    _ActivityIndicator.hidden = true;
    flag = false;
    self.gps = [CLLocationManager new];
    gps.delegate = self;
    gps.desiredAccuracy = kCLLocationAccuracyBest;
    [gps startUpdatingLocation];
    [super viewDidLoad];
}


-(void) SetUpActivityIndicator{
    _ActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _ActivityIndicator.alpha = 1.0;
    _ActivityIndicator.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-SCREEN_HEIGHT/4+SCREEN_HEIGHT/20);
    [_ActivityIndicator startAnimating];
    [self.view addSubview:_ActivityIndicator];
}


-(void) setUpDetectLocationButton{
    _detectLocation = [[UIButton alloc] init];
    [_detectLocation setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    _detectLocation.frame = CGRectMake(SCREEN_WIDTH/2-SCREEN_WIDTH/4, SCREEN_HEIGHT/2, SCREEN_WIDTH/2, SCREEN_HEIGHT/10);
    [_detectLocation setTitle:@"Detect location" forState:UIControlStateNormal];
    [self.view addSubview: _detectLocation];
    _pushButton.hidden = true;
    [_detectLocation addTarget:self action:@selector(DetectLocationClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) setUpAdressLabel:(NSString*)adress {
    _label = [[UILabel alloc]init];
    _label.textColor = [UIColor blackColor];
    _label.frame = CGRectMake(0, SCREEN_HEIGHT/2-SCREEN_HEIGHT/4, SCREEN_WIDTH, SCREEN_HEIGHT/10);
    _label.numberOfLines = 2;
    [_label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_label];
    _label.alpha = 0.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [_label setText:[NSString stringWithFormat:@"%@", adress]];
    _label.alpha = 1.0;
    [UIView commitAnimations];
}

- (BOOL)connectedToInternet
{
    NSString *urlString = @"http://www.google.com/";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    
    return ([response statusCode] == 200) ? YES : NO;
}


- (void)locationManager:(CLLocationManager *)locationManager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
{
    if (flag){
        // проверка подключения к интернету
        if (![self connectedToInternet])
        {
            [[[UIAlertView alloc] initWithTitle:@"No Internet connection"
                                        message:@"Connect to the Internet and then try again"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            [_ActivityIndicator stopAnimating];
            _ActivityIndicator.hidden = true;
            flag = false;
            return;
        }
        UILabel * infoOldLocation;
        UILabel * infoNewLocation;
        infoOldLocation.text = [NSString stringWithFormat:@"latitude:%f, longitude:  %f", oldLocation.coordinate.latitude,oldLocation.coordinate.longitude];
        infoNewLocation.text = [NSString stringWithFormat:@"latitude:%f, longitude:  %f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];
        CLGeocoder *geocoder = [CLGeocoder new];
            [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error){
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                NSString *adress = [NSString stringWithFormat:@"%@, %@, %@",[placemark thoroughfare], [placemark subAdministrativeArea],  [placemark country]];
                adr = [NSString stringWithFormat:@"%@, %@", [placemark subAdministrativeArea], [placemark country]];
                
                NSError *err;
                NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"myfile.txt"];
                [adr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&err];
                
                
                _pushButton.hidden = false;
                [_ActivityIndicator stopAnimating];
                _ActivityIndicator.hidden = true;
                _label.text = @"";
                [self setAdr:adr];
                [self setUpAdressLabel:adress];
            }];
        }
    flag = false;
    ic = true;
}

- (IBAction)DetectLocationClick:(id)sender {
    [self SetUpActivityIndicator];
    _ActivityIndicator.hidden = false;
    [_ActivityIndicator startAnimating];
    flag = true;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
