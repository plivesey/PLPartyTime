//
//  PTDMMainViewController.m
//  PLPartyTime
//
//  Created by Peter Livesey on 3/1/14.
//  Copyright (c) 2014 Peter Livesey. All rights reserved.
//

#import "PTDMMainViewController.h"
// Party Time
#import "PLPartyTime.h"


@interface PTDMMainViewController ()

@end

@implementation PTDMMainViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  PLPartyTime *partyTime = [[PLPartyTime alloc] initWithServiceType:@"test"];
  [partyTime joinParty];
}

@end
