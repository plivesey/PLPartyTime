//
//  PLPartyTime.h
//  PLPartyTime
//
//  Created by Peter Livesey on 3/1/14.
//  Copyright (c) 2014 Peter Livesey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol PLPartyTimeDelegate;


/**
 This is a light wrapper around the MultiPeer connectivity framework which quickly connects devices without having to send or receive invites. Here's the quick setup:

 Each device calls:
 
    PLPartyTime *partyTime = [[PLPartyTime alloc] initWithServiceType@"MyApp"];
    partyTime.delegate = self;
    [partyTime joinParty];

 Each device will get a callback when anyone connects or disconnects. Note that any device which joins the party with this service type will automatically join without sending or receiving invitations.

    - (void)partyTime:(PLPartyTime *)partyTime peer:(MCPeerID *)peer changedState:(MCSessionState)state currentPeers:(NSArray *)currentPeers;
 
 Then, anytime you want to send data, you can call a method to send to all connected users (peers) or an array of select peers.

    - (BOOL)sendData:(NSData *)data withMode:(MCSessionSendDataMode)mode error:(NSError **)error;
    - (BOOL)sendData:(NSData *)data toPeers:(NSArray *)peerIDs withMode:(MCSessionSendDataMode)mode error:(NSError **)error;

 The clients receiving data get the callback:

    - (void)partyTime:(PLPartyTime *)partyTime didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;

 And that's it.
 There are a few more features of this library, but I'll let you read through the documentation to find those specifically. 
*/

@interface PLPartyTime : NSObject

#pragma mark - Properties

/// Delegate for the PartyTime methods
@property (nonatomic, weak) id<PLPartyTimeDelegate> delegate;

/// Query whether the client has joined the party
@property (nonatomic, readonly) BOOL connected;
/// Returns the current client's MCPeerID
@property (nonatomic, readonly, strong) MCPeerID *peerID;
/// Returns an array of MCPeerIDs which represents the connected peers. Doesn't include the current client's peer ID.
@property (nonatomic, readonly) NSArray *connectedPeers;
/// Returns the serviceType which was passed in when the object was initialized.
@property (nonatomic, readonly, strong) NSString *serviceType;
/// Returns the display name which was passed in when the object was initialized.
/// If no display name was specified, it defaults to [UIDevice currentDevice].name]
@property (nonatomic, readonly, strong) NSString *displayName;

#pragma mark - Initialization

/**
 Init method for this class.
 
 You must initialize this method with this method or:
 
    - (instancetype)initWithServiceType:(NSString *)serviceType displayName:(NSString *)displayName;
 
 Since you are not passing in a display name, it will default to:
 
    [UIDevice currentDevice].name]
 
 Which returns a string similar to: @"Peter's iPhone".
 
 @param serviceType The type of service to advertise. This should be a short text string that describes the app's networking protocol, in the same format as a Bonjour service type:
 
 1. Must be 1–15 characters long.
 2. Can contain only ASCII lowercase letters, numbers, and hyphens.
 
 This name should be easily distinguished from unrelated services. For example, a text chat app made by ABC company could use the service type abc-txtchat. For more details, read “Domain Naming Conventions”.
 */
- (instancetype)initWithServiceType:(NSString *)serviceType;

/**
 Init method for this class.
 
 You must initialize this method with this method or:
 
    - (instancetype)initWithServiceType:(NSString *)serviceType displayName:(NSString *)displayName;
 
 @param serviceType The type of service to advertise. This should be a short text string that describes the app's networking protocol, in the same format as a Bonjour service type:
 
 1. Must be 1–15 characters long.
 2. Can contain only ASCII lowercase letters, numbers, and hyphens.
 
 This name should be easily distinguished from unrelated services. For example, a text chat app made by ABC company could use the service type abc-txtchat. For more details, read “Domain Naming Conventions”.
 
 @param displayName The display name which is sent to other clients in the party.
 */
- (instancetype)initWithServiceType:(NSString *)serviceType
                        displayName:(NSString *)displayName;

/**
 Call this method to join the party. It will automatically start searching for peers.
 
 When you sucessfully connect to another peer, you will receive a delegate callback to:
 
    - (void)partyTime:(PLPartyTime *)partyTime peer:(MCPeerID *)peer changedState:(MCSessionState)state currentPeers:(NSArray *)currentPeers;
 */
- (void)joinParty;

/**
 Call this method stop accepting invitations from peers. You will not disconnect from the party, but will not allow incoming connections.
 
 To start searching for peers again, call the joinParty method again.
 */
- (void)stopAcceptingGuests;

/**
 Call this method to disconnect from the party. You can reconnect at any time using the joinParty method.
 */
- (void)leaveParty;

/**
 Sends data to select peers.
 
 They will receive the data with the delegate callback:
 
    - (void)partyTime:(PLPartyTime *)partyTime didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;
 
 @param data Data to send.
 @param mode The transmission mode to use (reliable or unreliable delivery).
 @param error The address of an NSError pointer where an error object should be stored upon error.
 @return Returns YES if the message was successfully enqueued for delivery, or NO if an error occurred.
 
 */
- (BOOL)sendData:(NSData *)data
        withMode:(MCSessionSendDataMode)mode
           error:(NSError **)error;

/**
 Sends data to select peers.
 
 They will receive the data with the delegate callback:
 
    - (void)partyTime:(PLPartyTime *)partyTime didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;
 
 @param data Data to send.
 @param peerIDs An array of MCPeerID objects to send data to.
 @param mode The transmission mode to use (reliable or unreliable delivery).
 @param error The address of an NSError pointer where an error object should be stored upon error.
 @return Returns YES if the message was successfully enqueued for delivery, or NO if an error occurred.
 
 */
- (BOOL)sendData:(NSData *)data
         toPeers:(NSArray *)peerIDs
        withMode:(MCSessionSendDataMode)mode
           error:(NSError **)error;

/**
 Opens a byte stream to a nearby peer.
 This method is non-blocking.
 
 @param streamName A name for the stream. This name is provided to the nearby peer.
 @param peerID The ID of the nearby peer.
 @param error The address of an NSError pointer where an error object should be stored if something goes wrong.
 @return Returns an output stream object upon success or nil if a stream could not be established.
 */
- (NSOutputStream *)startStreamWithName:(NSString *)streamName
                                 toPeer:(MCPeerID *)peerID
                                  error:(NSError **)error;

/**
 Sends the contents of a URL to a peer.
 This method is asynchronous (non-blocking).
 On the local device, the completion handler block is called when delivery succeeds or when an error occurs.
 
 @param resourceURL A file or HTTP URL.
 @param resourceName A name for the resource.
 @param peerID The peer that should receive this resource.
 @param completionHandler A block that gets called when delivery succeeds or fails. Upon success, the handler is called with an error value of nil. Upon failure, the handle is called with an error object that indicates what went wrong.
 @return Returns an NSProgress object that can be used to query the status of the transfer or cancel the transfer.
 */
- (NSProgress *)sendResourceAtURL:(NSURL *)resourceURL
                         withName:(NSString *)resourceName
                           toPeer:(MCPeerID *)peerID
            withCompletionHandler:(void (^)(NSError *error))completionHandler;

@end

/**
 The delegate for the PLPartyTime class.
 
 Most of this is self documenting, so I'm going to leave documentation out right now...I'm a little tired of writing documentation for now.
 */
@protocol PLPartyTimeDelegate <NSObject>

@required
- (void)partyTime:(PLPartyTime *)partyTime
             peer:(MCPeerID *)peer
     changedState:(MCSessionState)state
     currentPeers:(NSArray *)currentPeers;

- (void)partyTime:(PLPartyTime *)partyTime
failedToJoinParty:(NSError *)error;

@optional
- (void)partyTime:(PLPartyTime *)partyTime
   didReceiveData:(NSData *)data
         fromPeer:(MCPeerID *)peerID;

- (void)partyTime:(PLPartyTime *)partyTime
 didReceiveStream:(NSInputStream *)stream
         withName:(NSString *)streamName
         fromPeer:(MCPeerID *)peerID;

- (void)partyTime:(PLPartyTime *)partyTime
didStartReceivingResourceWithName:(NSString *)resourceName
         fromPeer:(MCPeerID *)peerID
     withProgress:(NSProgress *)progress;

- (void)partyTime:(PLPartyTime *)partyTime
didFinishReceivingResourceWithName:(NSString *)resourceName
         fromPeer:(MCPeerID *)peerID
            atURL:(NSURL *)localURL
        withError:(NSError *)error;

@end
