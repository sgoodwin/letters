//
//  LBIMAPConnectionTests.m
//  LetterBox
//
//  Created by August Mueller on 2/21/10.
//  Copyright 2010 Flying Meat Inc. All rights reserved.
//

#import "LBIMAPConnectionTests.h"
#import "LBIMAPConnection.h"
#import "LBAccount.h"

#define debug NSLog

#define LBTestError(err, reason) { if (err) {   NSLog(@"err: %@", err);\
                                                failed = YES;\
                                                failReason = reason;\
                                                waitForFinish = NO;\
                                                return; } }

#define LBAssertTrue(b, reason) { if (!(b)) {   failed = YES;\
                                                failReason = reason;\
                                                waitForFinish = NO;\
                                                return; } }

#define LBInitTest() __block BOOL failed            = NO;\
                     __block NSString *failReason   = nil;\
                     __block BOOL waitForFinish     = YES;\
                     __block NSTask *serverTask     = nil;
                     

#define LBInitTestWithServerScript(script)  LBInitTest()\
                                            dispatch_sync(dispatch_get_main_queue(),^ {\
                                                serverTask = [[self runServerScript:script] retain];\
                                            });

#define LBEndTest() waitForFinish = NO;

#define LBWaitForFinish() { while (waitForFinish) { sleep(.1); } [serverTask terminate]; [serverTask release]; GHAssertFalse(failed, failReason); }

@implementation LBIMAPConnectionTests

- (LBAccount*)atestAccount {
    
    LBAccount *acct = [[[LBAccount alloc] init] autorelease];
    [acct setUsername:@"user"];
    [acct setPassword:@"password"];
    [acct setImapServer:@"localhost"];
    [acct setImapPort:1430];
    [acct setIsActive:YES];
    [acct setImapTLS:NO];
    
    return acct;
}

- (LBAccount*)realAccount {
    
    // oh what to do here?
    LBAccount *acct = [[[LBAccount alloc] init] autorelease];
    [acct setUsername:@"gus"];
    [acct setPassword:@"password"];
    [acct setImapServer:@"ubuntu.local"];
    [acct setImapPort:143];
    [acct setIsActive:YES];
    [acct setImapTLS:NO];
    
    return acct;
}



- (NSTask*)runServerScript:(NSString*)scriptName {
    
    system("killall python");
    
    NSString *myFilePath = [NSString stringWithUTF8String:__FILE__];
    
    NSString *parentDir = [[myFilePath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    
    NSString *testDir   = [[parentDir stringByAppendingPathComponent:@"tests"] stringByAppendingPathComponent:@"LBIMAPConnectionTests"];
    
    NSString *taskPath  = [testDir stringByAppendingPathComponent:scriptName];
    
    NSTask *task = [[NSTask alloc] init];
    
    [task setLaunchPath:taskPath];
    
    [task launch];
    
    // wait a sec for it to startup
    sleep(1);
    
    debug(@"task: %@", task);
    
    return task;
}

- (void)testLoginLogout {
    
    LBInitTestWithServerScript(@"testLoginLogout.py");
    
    // this needs to run on the main loop
    dispatch_async(dispatch_get_main_queue(),^ {
        
        LBIMAPConnection *conn = [[[LBIMAPConnection alloc] initWithAccount:[self atestAccount]] autorelease];
        
        [conn connectUsingBlock:^(NSError *err) {
            
            LBTestError(err, @"Got an error trying to connect!");
            
            [conn logoutWithBlock:^(NSError *err) {
                
                LBTestError(err, @"Got an error trying to log out!");
                
                [conn close];
                
                LBEndTest();
            }];
        }];
    });
    
    LBWaitForFinish();
}
- (void)testLoginFail {
    
    LBInitTestWithServerScript(@"testLoginFail.py");
    
    dispatch_async(dispatch_get_main_queue(),^ {
        
        LBIMAPConnection *conn = [[[LBIMAPConnection alloc] initWithAccount:[self atestAccount]] autorelease];
        
        [conn connectUsingBlock:^(NSError *err) {
            
            LBTestError(err, @"Got an error trying to connect!");
            
            [conn loginWithBlock:^(NSError *err) {
                
                LBAssertTrue(err != nil, @"We shouldn't have been able to log in.");
                
                [conn close];
                
                LBEndTest();
            }];
        }];
    });
    
    LBWaitForFinish();
}


- (void)testMobileMeSelect {
    
    LBInitTestWithServerScript(@"testMobileMeSelect.py");
    
    // this needs to run on the main loop
    dispatch_async(dispatch_get_main_queue(),^ {
        
        LBAccount *account      = [self atestAccount];
        LBIMAPConnection *conn  = [[[LBIMAPConnection alloc] initWithAccount:account] autorelease];
        
        conn.debugOutput = YES;
        
        [conn connectUsingBlock:^(NSError *err) {
            
            LBTestError(err, @"Got an error trying to connect!");
            
            [conn loginWithBlock:^(NSError *err) {
                
                LBTestError(err, @"Got an error trying to login!");
                
                [conn selectMailbox:@"Mailbox With Spaces" block:^(NSError *err) {
                    
                    LBTestError(err, @"Got an error trying to select!");
                    
                    [conn logoutWithBlock:^(NSError *err) {
                        debug(@"all done!");
                        LBTestError(err, @"Got an error trying to log out!");
                        
                        [conn close];
                        
                        LBEndTest();
                    }];
                }];
            }];
        }];
    });
    
    LBWaitForFinish();
}

- (void)testDeleteAndExpunge {
    
    LBInitTestWithServerScript(@"testDeleteAndExpunge.py");
    
    // this needs to run on the main loop
    dispatch_async(dispatch_get_main_queue(),^ {
        
        LBAccount *account      = [self atestAccount];
        LBIMAPConnection *conn  = [[[LBIMAPConnection alloc] initWithAccount:account] autorelease];
        
        conn.debugOutput = YES;
        
        [conn connectUsingBlock:^(NSError *err) {
            
            LBTestError(err, @"Got an error trying to connect!");
            
            [conn loginWithBlock:^(NSError *err) {
                
                LBTestError(err, @"Got an error trying to login!");
                
                
                [conn selectMailbox:@"INBOX" block:^(NSError *err) {
                    
                    LBTestError(err, @"Got an error trying to select!");
                    
                    // delete the first message.
                    [conn deleteMessages:@"1" withBlock:^(NSError *err) {
                        
                        LBTestError(err, @"delete the first message.");
                        
                        [conn expungeWithBlock:^(NSError *err) {
                            
                            LBTestError(err, @"expunge");
                            
                            [conn close];
                            
                            LBEndTest();
                        }];
                    }];
                }];
            }];
        }];
    });
    
    LBWaitForFinish();
}

- (void)testListSubscriptions {
    
    LBInitTestWithServerScript(@"testListSubscriptions.py");
    
    // this needs to run on the main loop
    dispatch_async(dispatch_get_main_queue(),^ {
        
        LBAccount *account      = [self atestAccount];
        LBIMAPConnection *conn  = [[[LBIMAPConnection alloc] initWithAccount:account] autorelease];
        
        [conn connectUsingBlock:^(NSError *err) {
            
            LBTestError(err, @"Got an error trying to connect!");
            
            [conn loginWithBlock:^(NSError *err) {
                LBTestError(err, @"Got an error trying to login!");
                
                [conn listSubscribedMailboxesWithBock:^(NSError *err) {
                    LBTestError(err, @"Could not list mailboxes!");
                    
                    NSArray *mailboxes = [conn fetchedMailboxes];
                    
                    LBAssertTrue([mailboxes count] > 0, @"Could not find any mailboxes");
                    
                    BOOL foundINBOX = NO;
                    BOOL foundDeletedMessages = NO;
                    
                    for (NSDictionary *box in mailboxes) {
                        foundINBOX = foundINBOX || [[box objectForKey:@"mailboxName"] isEqualToString:@"INBOX"];
                        foundDeletedMessages = foundDeletedMessages || [[box objectForKey:@"mailboxName"] isEqualToString:@"INBOX.Deleted Messages"];
                    }
                    
                    LBAssertTrue(foundINBOX, @"Could not find the inbox");
                    LBAssertTrue(foundDeletedMessages, @"Could not find the deleted messages");
                    
                    debug(@"logging out now");
                    
                    [conn logoutWithBlock:^(NSError *err) {
                        debug(@"all done!");
                        LBTestError(err, @"Got an error trying to log out!");
                        
                        [conn close];
                        
                        LBEndTest();
                    }];
                }];
            }];
        }];
    });
    
    LBWaitForFinish();
}








@end