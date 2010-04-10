//
//  LADocument.h
//  Letters
//
//  Created by August Mueller on 1/19/10.
//


#import <Cocoa/Cocoa.h>
#import "LAAddressBookViewController.h"
#import "LAAddressEntryTokenSource.h"

@interface LADocument : NSDocument <LAAddressBookViewDelegate>{
    
    // FIXME: this should all probably go in a window controller subclass...
    
    IBOutlet NSProgressIndicator *progressIndicator;
	LAAddressBookViewController *addressBookVC;
	LAAddressEntryTokenSource *tokenSource;
	
	NSTokenField *toField;
}

@property (retain) NSString *toList;
@property (retain) NSString *fromList;
@property (retain) NSString *subject;
@property (retain) NSString *message;

@property (retain) NSString *statusMessage;

@property (retain) LAAddressBookViewController *addressBookVC;

@property (retain) LAAddressEntryTokenSource *tokenSource;

@property (retain) IBOutlet NSTokenField *toField;

- (IBAction)openAddressBookPicker:(id)sender;
- (void)addToAddress:(LAAddressEntryToken *)address;
@end
