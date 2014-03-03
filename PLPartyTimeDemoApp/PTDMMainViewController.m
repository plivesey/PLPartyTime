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
  
  self.partyTime = [[PLPartyTime alloc] initWithServiceType:@"test"];
  self.partyTime.delegate = self;
}

- (IBAction)joinParty:(id)sender
{
  [self.partyTime joinParty];
  
  [self.tableView reloadData];
}

- (IBAction)leaveParty:(id)sender
{
  [self.partyTime leaveParty];
  
  [self.tableView reloadData];
}

#pragma mark - Table View Delegate/DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
  if (indexPath.section == 0)
  {
    cell.textLabel.text = [UIDevice currentDevice].name;
  }
  else
  {
    cell.textLabel.text = ((MCPeerID *)[self.connectedPeers objectAtIndex:indexPath.row]).displayName;
  }
  return cell;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0)
  {
    // This is the section for our name
    if (self.partyTime.connected)
    {
      return 1;
    }
    else
    {
      return 0;
    }
  }
  return [self.connectedPeers count];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

#pragma mark - Party Time Delegate

- (void)partyTime:(PLPartyTime *)partyTime
   didReceiveData:(NSData *)data
         fromPeer:(MCPeerID *)peerID
{
  NSLog(@"Received some data!");
}

- (void)partyTime:(PLPartyTime *)partyTime
             peer:(MCPeerID *)peer
     changedState:(MCSessionState)state
     currentPeers:(NSArray *)currentPeers
{
  if (state == MCSessionStateConnected)
  {
    NSLog(@"Connected to %@", peer.displayName);
  }
  else
  {
    NSLog(@"Peer disconnected: %@", peer.displayName);
  }
  NSLog(@"%@", currentPeers);
  
  self.connectedPeers = currentPeers;
  [self.tableView reloadData];
}

@end
