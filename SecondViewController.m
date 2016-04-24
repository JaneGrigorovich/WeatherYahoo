//
//  SecondViewController.m
//  Weather
//
//  Created by Admin on 25.03.16.
//  Copyright (c) 2016 com.evgenia. All rights reserved.
//

#import "SecondViewController.h"
#import "YQL.h"

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

@interface SecondViewController ()
@end
k=0;

@implementation SecondViewController{
    IBOutlet UILabel * _cityResult;
    IBOutlet UILabel * _tempResult;
    IBOutlet UILabel * _stateResult;
    IBOutlet UIButton *_refreshWeather;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) setUpCityResult:(NSString*)adr
{
    _cityResult = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2-SCREEN_HEIGHT/4, SCREEN_WIDTH, SCREEN_HEIGHT/10)];
    _cityResult.textColor = [UIColor blackColor];
    [_cityResult setTextAlignment:NSTextAlignmentCenter];
    _cityResult.text = @"";
    _cityResult.text = [NSString stringWithFormat:@"%@",adr];
    [self.view addSubview:_cityResult];
}

-(void) setUpTempResult:(NSString*)temp
{
    _tempResult = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2-SCREEN_HEIGHT/10, SCREEN_WIDTH, SCREEN_HEIGHT/10)];
    _tempResult.textColor = [UIColor blackColor];
    [_tempResult setTextAlignment:NSTextAlignmentCenter];
    _tempResult.font = [UIFont systemFontOfSize:44];
    _tempResult.text = [NSString stringWithFormat:@"%@",temp];
    [self.view addSubview:_tempResult];
}

-(void) setUpStateResult:(NSObject*) json
{
    _stateResult = [[UILabel alloc] init];
    _stateResult.frame = CGRectMake(0, SCREEN_HEIGHT/2+SCREEN_HEIGHT/10, SCREEN_WIDTH, SCREEN_HEIGHT/10);
    _stateResult.textColor = [UIColor blackColor];
    [_stateResult setTextAlignment:NSTextAlignmentCenter];
    _stateResult.text = [NSString stringWithFormat:@"%@",json];
    [self.view addSubview:_stateResult];
}

-(void) setUpRefreshButton
{
    _refreshWeather = [[UIButton alloc]init];
    _refreshWeather.frame = CGRectMake(SCREEN_WIDTH/2 - SCREEN_WIDTH/4, SCREEN_HEIGHT/2+SCREEN_HEIGHT/4, SCREEN_WIDTH/2, SCREEN_HEIGHT/10);
    [_refreshWeather setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_refreshWeather setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    [_refreshWeather setTitle:@"Refresh Weather" forState:UIControlStateNormal];
    [self.view addSubview:_refreshWeather];
    [_refreshWeather addTarget:self action:@selector(RefreshWeather:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)refreshMethod
{
    NSError * err;
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"myfile.txt"];
    NSString * adr =  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
    yql = [[YQL alloc] init];
    NSLog(@"%@", adr);
    //получение json, из которого нужно получить woeid
    NSError * error;
    NSString * q = [NSString stringWithFormat:@"select * FROM geo.places where text=\" %@ \" AND placeTypeName.code = 7", adr];
    NSDictionary *results = [yql query:q];
    if ([results description] == nil)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Cannot find this place :("
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:results options:NSJSONWritingPrettyPrinted error:&error];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSData *data = [myString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    id woeid = [json valueForKeyPath:@"query.results.place.admin1.woeid"]; // получили woeid
    //по заданному woeid парсим данные и берем температуру воздуха и "состояние"
    NSString * q1 = [NSString stringWithFormat:@"SELECT * FROM weather.forecast WHERE woeid= %@ ", woeid];
    NSDictionary *results1 = [yql query:q1];
    if ([results1 description] == nil)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Cannot find this place :("
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    NSData *jsonData1=[NSJSONSerialization dataWithJSONObject:results1 options:NSJSONWritingPrettyPrinted error:&error];
    NSString * myString1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    NSData *data1  = [myString1 dataUsingEncoding:NSUTF8StringEncoding];
    id json1 = [NSJSONSerialization JSONObjectWithData:data1 options:0 error:nil];
    //получение температуры
    int temperature = [[json1 valueForKeyPath:@"query.results.channel.item.condition.temp"] intValue];
    //перевод в градусы Цельсия
    temperature = 5*(temperature - 32)/9;
    NSString * temper = [NSString stringWithFormat:@"%i°C", temperature];
    
    [self setUpCityResult:adr];
    [self setUpTempResult:temper];
    [self setUpStateResult:[json1 valueForKeyPath:@"query.results.channel.item.condition.text"]];
    [self setUpRefreshButton];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshMethod];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a
 little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)RefreshWeather:(id)sender {
    [self refreshMethod];
}
@end
