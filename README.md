## Installation

```pod install partytime

OR

Add PLPartyTime.h and PLPartyTime.m to your project (in the PLPartyTime folder)

## How to Use

This is a light wrapper around the MultiPeer connectivity framework which quickly connects devices without having to send or receive invites. Here's the quick setup:

Each device calls:

```objective-c 
PLPartyTime *partyTime = [[PLPartyTime alloc] initWithServiceType@"MyApp"];
partyTime.delegate = self;
[partyTime joinParty];
```

Each device will get a callback when anyone connects or disconnects. Note that any device which joins the party with this service type will automatically join without sending or receiving invitations.

```objective-c
- (void)partyTime:(PLPartyTime *)partyTime peer:(MCPeerID *)peer changedState:(MCSessionState)state currentPeers:(NSArray *)currentPeers;
```
 
Then, anytime you want to send data, you can call a method to send to all connected users (peers) or an array of select peers.

```objective-c
- (BOOL)sendData:(NSData *)data withMode:(MCSessionSendDataMode)mode error:(NSError **)error;
- (BOOL)sendData:(NSData *)data toPeers:(NSArray *)peerIDs withMode:(MCSessionSendDataMode)mode error:(NSError **)error;
```

The clients receiving data get the callback:

```objective-c
- (void)partyTime:(PLPartyTime *)partyTime didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;
```

And that's it.
There are a few more features of this library, but I'll let you read through the documentation to find those specifically. 