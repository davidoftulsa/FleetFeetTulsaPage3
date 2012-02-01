//
//  ClassListViewController.h
//  FleetFeetTulsaPage3
//
//  Created by David Wright on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ClassListViewController : UITableViewController <CLLocationManagerDelegate>
{
    NSArray *customerClasses;
    CLLocationManager *locationManager;
    CLLocation *myLocation;
    IBOutlet UITableView *myTableView;
    UIActivityIndicatorView *spinnerView;
    UIImageView *rView;
}

@property (nonatomic, retain) UITableView* myTableView;
@property (nonatomic, retain) NSArray *customerClasses;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *myLocation;


-(void) fetchCustomerClasses;
-(void) checkInToClass:(id) sender;
-(void) showLoadingIndicator;
-(void) hideLoadingIndicator;
-(void) checkInToClassBackground;


@end
