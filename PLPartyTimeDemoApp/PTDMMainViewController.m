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


@interface PTDMMainViewController () <PLPartyTimeDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PLPartyTime *partyTime;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *connectedPeers;

@end

@implementation PTDMMainViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (IBAction)joinParty:(id)sender
{
  self.partyTime = [[PLPartyTime alloc] initWithServiceType:@"test"];
  self.partyTime.delegate = self;
  [self.partyTime joinParty];
}

#pragma mark - Table View Delegate/DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
  cell.textLabel.text = ((MCPeerID *)[self.connectedPeers objectAtIndex:indexPath.row]).displayName;
  return cell;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.connectedPeers count];
}

#pragma mark - Party Time Delegate

- (void)partyTime:(PLPartyTime *)partyTime
   didReceiveData:(NSData *)data
         fromPeer:(MCPeerID *)peerID
{
  NSLog(@"Received some data!");
}

- (void)partyTime:(PLPartyTime *)partyTime
  connectedToPeer:(MCPeerID *)peer
     currentPeers:(NSArray *)currentPeers
{
  NSLog(@"Connected to %@", peer.displayName);
  NSLog(@"%@", currentPeers);
  
  self.connectedPeers = currentPeers;
  [self.tableView reloadData];
}

@end
