//
//  locationShare.h
//  locationshare
//
//  Created by Andrew Gerrie on 26/07/2014.
//  Copyright (c) 2014 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>


@interface locationShare : UIViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}
- (IBAction)trackingLinkCopy:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *urlArea;
@property (weak, nonatomic)CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *sharebutton;
@end
