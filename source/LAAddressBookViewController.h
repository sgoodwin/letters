//
//  LAAddressBookViewController.h
//  Letters
//
//  Created by Samuel Goodwin on 3/25/10.
//  Copyright 2010 Letters App. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/ABPeoplePickerView.h>
#import "LAAddressEntryToken.h"

// The actual AddressBook selection controller. Implement the delegate protocol to get the info back.
@protocol LAAddressBookViewDelegate;
@interface LAAddressBookViewController : NSWindowController {
	ABPeoplePickerView *peoplePicker;
	NSView *accessoryView;
	id<LAAddressBookViewDelegate, NSObject> delegate;
}
@property(nonatomic, retain) IBOutlet ABPeoplePickerView *peoplePicker;
@property(nonatomic, retain) IBOutlet NSView *accessoryView;
@property(nonatomic, assign) IBOutlet id<LAAddressBookViewDelegate, NSObject> delegate;

+ (LAAddressBookViewController*)newAddressBookViewControllerWithDelegate:(id<LAAddressBookViewDelegate, NSObject>)aDelegate;
- (LAAddressEntryToken *)selectedEntry;
- (IBAction)to:(id)sender;
- (IBAction)cc:(id)sender;
- (IBAction)bcc:(id)sender;
@end

@protocol LAAddressBookViewDelegate
- (void)addToAddress:(LAAddressEntryToken *)address;

@optional
- (void)addCcAddress:(LAAddressEntryToken*)address;
- (void)addBccAddress:(LAAddressEntryToken*)address;
@end