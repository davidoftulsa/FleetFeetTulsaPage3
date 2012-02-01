//
//  ClassListViewController.m
//  FleetFeetTulsaPage3
//
//  Created by David Wright on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Parse/Parse.h>
#import "ClassListViewController.h"
#import "ClassListCustomCell.h"
#import "AppDelegate.h"


@implementation ClassListViewController

@synthesize myTableView,customerClasses,locationManager,myLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self; // send loc updates to myself
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager startUpdatingLocation];
        self.myLocation = [[CLLocation alloc] init];
        [self.tableView setRowHeight:76];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchCustomerClasses];
    self.title = @"My Classes";
    
    UIBarButtonItem *checkInButton = [[UIBarButtonItem alloc] initWithTitle:@"Check In" style:UIBarButtonItemStylePlain target:self action:@selector(checkInToClass:)];
    self.navigationItem.rightBarButtonItem = checkInButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [checkInButton release];

    
    
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}



// Customize the number of rows in the table view.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return customerClasses.count;
    
}



// Customize the appearance of table view cells.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ClassListCustomCell";
	
    ClassListCustomCell *cell = (ClassListCustomCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ClassListCustomCell" owner:self options:nil];
		
		for (id currentObject in topLevelObjects){
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell =  (ClassListCustomCell *) currentObject;
				break;
			}
		}
	}
    
    PFObject *customerClass = [customerClasses objectAtIndex:indexPath.row];
    NSString *classTitle = [customerClass objectForKey:@"ClassTitle"];
    NSString *classLocationName = [customerClass objectForKey:@"ClassLocationName"];
    NSString *classDateString = [customerClass objectForKey:@"ClassDate"]; 
    NSString *classTimeString = [customerClass objectForKey:@"ClassTime"]; 
    
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setLocale:enUSPOSIXLocale];
    
    [df1 setDateFormat:@"MM/dd/yyyy HHmm"];
    NSDate *classDateTime = [df1 dateFromString:[NSString stringWithFormat:@"%@ %@",classDateString,classTimeString]];
    
    [df1 setDateFormat:@"MM/dd/yyyy  hh:mm a"];
    NSString *classDateTimeString = [df1 stringFromDate:classDateTime];

    cell.classTitleLabel.text = classTitle;
    cell.classLocationLabel.text = classLocationName;
    cell.classDateTimeLabel.text = classDateTimeString;
    
    [enUSPOSIXLocale release];
    [df1 release];
    
    return cell;

}



- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
}



- (void)fetchCustomerClasses
{
 
    
    PFQuery *query = [PFQuery queryWithClassName:@"ClassCalendar"];
    [query whereKey:@"ClassId" equalTo:@"aaaa"];
    [query whereKey:@"ClassTermId" equalTo:@"aaaa"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            [self setCustomerClasses:objects];
            
            [myTableView reloadData];
            
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
 
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    self.myLocation = newLocation;
    NSLog(@"Location: %@", [newLocation description]);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
}

-(void) checkInToClass:(id) sender{
    
    //check for existing checkin -- if a check in exists for this user for this class then notify the user  -- do not insert checkin
    //check to make sure that the user is at one of the fleet feet locations
    //insert checkin record
    //notify user of success or failure
    
    BOOL existingCheckIn =  NO;
    BOOL userAtValidLocation =  NO;
    
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self showLoadingIndicator];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PFObject *customerClass = [customerClasses objectAtIndex:[[myTableView indexPathForSelectedRow] row]];
    
    PFQuery *checkInQuery = [PFQuery queryWithClassName:@"CheckIn"];
    [checkInQuery whereKey:@"ClassOfferingId" equalTo:[customerClass objectForKey:@"ClassOfferingId"]];
    [checkInQuery whereKey:@"CustomerId" equalTo:appDelegate.customerId];
    NSArray *existingCheckIns= [checkInQuery findObjects:nil];
    
    for (PFObject *pfo in existingCheckIns)
    {
        //check to see if any of the objects were created today.  if so then alert the user that this is a duplicate checkin
        
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
        [df1 setLocale:enUSPOSIXLocale];
        
        [df1 setDateFormat:@"MM/dd/yyyy"];
        
        NSLog(@"today:%@",[df1 stringFromDate:[NSDate date]]);
        NSLog(@"check in record:%@",[df1 stringFromDate:pfo.createdAt]);
        
        NSString *todayDateString = [df1 stringFromDate:[NSDate date]];
        
        if ([todayDateString isEqualToString:[df1 stringFromDate:pfo.createdAt]] == YES ){
            existingCheckIn = YES;
        }
    }
    
    
    if([CLLocationManager locationServicesEnabled])
        {
        
    
    // User's location
    PFGeoPoint *userPoint = [PFGeoPoint geoPointWithLatitude:myLocation.coordinate.latitude longitude:myLocation.coordinate.longitude];
    // Create a query for places
    PFQuery *query = [PFQuery queryWithClassName:@"Locations"];
    // Interested in locations near user.
    [query whereKey:@"Coordinates" nearGeoPoint:userPoint withinKilometers:1];
    // Limit what could be a lot of points.
    //query.limit = [NSNumber numberWithInt:10];
    // Final list of objects
    NSArray *placesObjects = [query findObjects];
    
    if(placesObjects.count>0)
        userAtValidLocation=YES;


    if (existingCheckIn==NO && userAtValidLocation==YES){
    PFObject *gameScore = [PFObject objectWithClassName:@"CheckIn"];
    [gameScore setObject:[customerClass objectForKey:@"ClassOfferingId"] forKey:@"ClassOfferingId"];
    [gameScore setObject:appDelegate.customerId forKey:@"CustomerId"];
    [gameScore setObject:@"MgEUZbw6tB" forKey:@"LocationId"];
    [gameScore save];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Success"
                              message: @"You are checked in to the class."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        
        if(existingCheckIn==YES){
       
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: @"You have already checked in to this class."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        }else{
            
            if(userAtValidLocation==NO){
                
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"Error"
                                      message: @"You must be at one of the Fleet Feet locations to check in to a class."
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
                
            }
        
        
        }
    }
    }    //if([CLLocationManager locationServicesEnabled])     
    else
    {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: @"You must allow location services to use this app."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    
    }
    
    [self hideLoadingIndicator];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    }

    -(void)showLoadingIndicator{
        rView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 110, 164, 164)];
        [rView setImage:[UIImage imageNamed:@"spinnerBackground.png"]];
        spinnerView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(62, 50, 40, 40)];
        [spinnerView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [spinnerView startAnimating];
        [rView addSubview:spinnerView];
        [self.view addSubview:rView];
        [rView release];
    }


-(void)hideLoadingIndicator{
	[spinnerView removeFromSuperview];
	[rView removeFromSuperview];
}


- (void)dealloc {
    [self.locationManager release];
    [self.myLocation release];
    [super dealloc];
}

    




@end
