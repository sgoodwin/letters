//
//  LAEmailAddressTokenFieldDelegate.m
//  Letters
//
//  Created by Samuel Goodwin on 4/10/10.
//  Copyright 2010 Letters App. All rights reserved.
//

#import "LAAddressEntryTokenSource.h"
#import "LAAddressBookViewController.h"
#import <AddressBook/AddressBook.h>

@implementation LAAddressEntryTokenSource

- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject{
	NSLog(@"representedObject: %@, name: %@", representedObject, [representedObject name]);
	return [representedObject name];
}

- (NSTokenStyle)tokenField:(NSTokenField *)tokenField styleForRepresentedObject:(id)representedObject{
	if([representedObject respondsToSelector:@selector(editingString)])
		return NSRoundedTokenStyle;
	return NSPlainTextTokenStyle;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex{
	ABAddressBook *book = [ABAddressBook sharedAddressBook];
	ABSearchElement *search = [ABPerson searchElementForProperty:kABFirstNameProperty label:nil key:nil value:substring comparison:kABContainsSubStringCaseInsensitive];
	NSArray *matchingEntries = [book recordsMatchingSearchElement:search];
	
	search = [ABPerson searchElementForProperty:kABLastNameProperty label:nil key:nil value:substring comparison:kABContainsSubStringCaseInsensitive];
	matchingEntries  = [matchingEntries arrayByAddingObjectsFromArray:[book recordsMatchingSearchElement:search]];
	
	search = [ABPerson searchElementForProperty:kABEmailProperty label:nil key:nil value:substring comparison:kABContainsSubStringCaseInsensitive];
	matchingEntries  = [matchingEntries arrayByAddingObjectsFromArray:[book recordsMatchingSearchElement:search]];
	return [self tokenArrayFromPeople:matchingEntries];
}

- (NSString *)tokenField:(NSTokenField *)tokenField editingStringForRepresentedObject:(id)representedObject{
	if([representedObject respondsToSelector:@selector(editingString)])
		return [(LAAddressEntryToken*)representedObject editingString];
	return representedObject;
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString{
	return [LAAddressEntryToken entryTokenFromEditingString:editingString];
}

- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index{
	return tokens;
}

- (NSArray *)tokenArrayFromPeople:(NSArray*)people{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[people count]];
	LAAddressEntryToken *token = [[LAAddressEntryToken alloc] init];
	[people enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		ABMultiValue *values = [(ABPerson*)obj valueForProperty:kABEmailProperty];
		NSString *nameString = [[NSString alloc] initWithFormat:@"%@ %@", 
								[(ABPerson*)obj valueForProperty:kABFirstNameProperty], 
								[(ABPerson*)obj valueForProperty:kABLastNameProperty]];
		for(NSUInteger i = 0; i < [values count];i++){
			NSString *email = [values valueAtIndex:i];
			token.name = nameString;
			token.email = email;
			[result addObject:[token editingString]];
		}
		//[nameString release];
		return;
	}];
	NSLog(@"Results: %@", result);
	return result;
}
@end
