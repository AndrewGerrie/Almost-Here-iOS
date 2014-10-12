//
//  locationShare.m
//  locationshare
//
//  Created by Andrew Gerrie on 26/07/2014.
//  Copyright (c) 2014 Andrew. All rights reserved.
//

#import "locationShare.h"
@import CoreTelephony.CTTelephonyNetworkInfo;

NSString *databaseId;
BOOL *urlSet;

@interface locationShare ()

@end

@implementation locationShare

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gray_jean_@2X.jpg"]];
    _sharebutton.layer.cornerRadius = 8; // this value vary as per your desire
    _sharebutton.clipsToBounds = YES;
    
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _urlArea.inputView = dummyView; // Hide keyboard, but show blinking cursor
    
    urlSet = false;
    
        locationManager = [[CLLocationManager alloc] init];
        [locationManager requestWhenInUseAuthorization];

   
        if([CLLocationManager locationServicesEnabled]){

            [self.urlArea resignFirstResponder];
    
            [self setUpUrl];
        
            _mapView.showsUserLocation = YES;
        
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            [locationManager startUpdatingLocation];
        }
}

-(void)zoomToPolyLine:(MKMapView*)map polyLine:(MKPolyline*)polyLine
             animated:(BOOL)animated
{
    MKPolygon* polygon = [MKPolygon polygonWithPoints:polyLine.points count:polyLine.pointCount];
    
    [map setRegion:MKCoordinateRegionForMapRect([polygon boundingMapRect]) animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
    MKCoordinateRegion adjustRegion = [_mapView regionThatFits:region];
    [_mapView setRegion:adjustRegion animated:YES];
    
    if ([self connected]) {
        
        if(!urlSet){
            [self setUpUrl];
        }
        
        NSString *foramtedUrl = [NSString stringWithFormat:@"%s%@%s%lf%s%lf", "https://almost-here.herokuapp.com/updateCollections/loc/",databaseId,"?latitude=", newLocation.coordinate.latitude, "&longitude=",newLocation.coordinate.longitude];
       
    
        NSURL *url = [NSURL URLWithString:foramtedUrl];
    
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req setHTTPMethod:@"get"];
        [req setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req setValue:@"" forHTTPHeaderField:@"secureHash"];
    
        NSError *err = nil;
        NSHTTPURLResponse *res = nil;
        [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
    }
    
}

-(void) setUpUrl {
    if ([self connected]) {
        
    NSString *foramtedUrl = [NSString stringWithFormat:@"%s%lf%s%lf", "https://almost-here.herokuapp.com/setCollections/loc?latitude=", 51.5008, "&longitude=",0.1247];
    
    NSURL *url = [NSURL URLWithString:foramtedUrl];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"get"];
    [req setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"" forHTTPHeaderField:@"secureHash"];
    
    NSError *err = nil;
    NSHTTPURLResponse *res = nil;
    NSData *ret = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
    
    NSString *returnString = [[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding];
    
    returnString = [returnString substringFromIndex:1];
    returnString = [returnString substringToIndex:[returnString length] - 1];
    
    databaseId = returnString;
    
    NSString *trackingUrl = [NSString stringWithFormat:@"%s%@", "http://track.almosthe.re/live?id=",databaseId];
    
    [self.urlArea setText:trackingUrl];
        
    urlSet = true;
    }
}

- (IBAction)trackingLinkCopy:(id)sender {
    NSString *shareString = [NSString stringWithFormat:@"%s%@", "Follow me with Almost Here: http://track.almosthe.re/live?id=",databaseId];
    NSArray *shareable = @[shareString];
    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems: shareable applicationActivities :nil];
    
    shareController.excludedActivityTypes = @[];
    
    [self presentViewController: shareController animated: YES completion: nil];

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *) textField{

    return NO;
}


- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}
@end
