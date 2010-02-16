#import "LBSMTPConnection.h"
#import "TCP_Internal.h"
#import "LBAccount.h"
#import "IPAddress.h"
#import "LetterBoxUtilities.h"

static NSString *LBSMTPHello = @"helo";

@implementation LBSMTPConnection


- (id)initWithAccount:(LBAccount*)account {
    
    // FIXME: add a "smtp port" option
    IPAddress *addr = [IPAddress addressWithHostname:[account smtpServer] port:25];
    self = [self initToAddress:addr];
    
	if (self != nil) {
        
        if ([account imapTLS]) {
            
            NSMutableDictionary *sslProps = [NSMutableDictionary dictionary];
            
            [sslProps setObject:[NSNumber numberWithBool:YES] forKey:(id)kTCPPropertySSLAllowsAnyRoot];
            [sslProps setObject:[NSNull null] forKey:(id)kCFStreamSSLPeerName];
            [sslProps setObject:NSStreamSocketSecurityLevelTLSv1 forKey:(id)kCFStreamSSLLevel];
            
            [self setSSLProperties:sslProps];
        }
    }
    
    return self;
}

- (void)xconnectUsingBlock:(LBResponseBlock)block {
    
    /*
    [[self treader] setCanReadBlock:^(LBTCPReader *arg1) {
        
        debug(@"woot got data!");
        
    }];
    */
    debug(@"calling super.");
    
    [super connectUsingBlock:block];
    
    
    //get the reader class, and assign a "can read" block on it, then just dot hat here whatever.
    
}

- (void)helloWithBlock:(LBResponseBlock)block {
    
    responseBlock = [block copy];
    
    NSString *serverName = [[self address] hostname];
    
    [self sendCommand:LBSMTPHello withArgument:serverName];
}

- (void)canRead:(LBTCPReader*)reader {
    debug(@"%s:%d", __FUNCTION__, __LINE__);
    
    // what's a good number here?
#define MAX_BYTES_READ 2048
    
    NSMutableData *data         = [NSMutableData dataWithLength:MAX_BYTES_READ];
    NSInteger localBytesRead    = [reader read:[data mutableBytes] maxLength:MAX_BYTES_READ];
    
    [self.responseBytes appendBytes:[data mutableBytes] length:localBytesRead];
    
    bytesRead += localBytesRead;
    
    if (self.debugOutput) {
        NSString *junk = [[[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"> %@", junk);
    }
    
    if (currentCommand == LBCONNECTING) {
        
        NSString *res = [self firstLineOfData:[self responseBytes]];
        if (!res) {
            // haven't gotten our crlf yet.
            return;
        }
        
        NSError *err = nil;
        
        if (![res hasPrefix:@"220 "]) {
            NSString *junk  = [NSString stringWithFormat:@"Could not connect: '%@'", [self responseAsString]];
            LBQuickError(&err, LBCONNECTING, 0, junk);
        }
        
        [self callBlockWithError:err];
    }
    if (currentCommand == LBSMTPHello) {
        
        NSString *res = [self firstLineOfData:[self responseBytes]];
        if (!res) {
            // haven't gotten our crlf yet.
            return;
        }
        
        NSError *err = nil;
        
        if (![res hasPrefix:@"250 "]) {
            NSString *junk  = [NSString stringWithFormat:@"Could not connect: '%@'", [self responseAsString]];
            LBQuickError(&err, LBCONNECTING, 0, junk);
        }
        
        [self callBlockWithError:err];
    }
}


- (void) test {
    
    [self setDebugOutput:[LBPrefs boolForKey:@"debugIMAPMessages"]];
    
    [self connectUsingBlock:^(NSError *error) {
        
        debug(@"got connected");
        
        if (error) {
            // FIXME: show a warning or something?
            NSLog(@"error: %@", error);
        }
        else {
            debug(@"hurray! Time to hello.");
            
            [self helloWithBlock:^(NSError *error) {
                if (error) {
                    // FIXME: show a warning or something?
                    NSLog(@"error: %@", error);
                }
                else {
                    debug(@"hurra with hello!");
                }
                
            }];
        }
    }];
}


@end
