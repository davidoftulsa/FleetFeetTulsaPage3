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
    NSArray *classCheckIns;
    CLLocationManager *locationManager;
    CLLocation *myLocation;
    IBOutlet UITableView *myTableView;
    UIActivityIndicatorView *spinnerView;
    UIImageView *rView;
    
    NSString *customerId;
    NSMutableArray *customerRegisteredClasses;
    NSArray *customerClassesToday;
    NSMutableArray *customerCalendarClasses;
}

@property (nonatomic, retain) UITableView* myTableView;

@property (nonatomic, retain) NSArray *classesCheckIns;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *myLocation;

@property (nonatomic, retain) NSString *customerId;
@property (nonatomic, retain) NSMutableArray *customerRegisteredClasses;
@property (nonatomic, retain) NSArray *customerClassesToday;
@property (nonatomic, retain) NSMutableArray *customerCalendarClasses;


-(void) checkInToClass:(id) sender;
-(void) showLoadingIndicator;
-(void) hideLoadingIndicator;
-(void) checkInToClassBackground;

//-(id) initWithCustomerId:(NSString *) cid;
-(void) fetchCustomerClasses;
//-(void) fetchCustomerClassesToday;



@end
