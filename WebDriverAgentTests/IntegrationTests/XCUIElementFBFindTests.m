/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import "FBIntegrationTestCase.h"
#import "XCUIElement.h"
#import "XCUIElement+FBFind.h"
#import "XCElementSnapshot+FBHelpers.h"
#import "XCUIElement+FBIsVisible.h"
#import "FBXPath.h"

@interface XCUIElementFBFindTests : FBIntegrationTestCase
@property (nonatomic, strong) XCUIElement *testedView;
@end

@implementation XCUIElementFBFindTests

- (void)setUp
{
  [super setUp];
  self.testedView = self.testedApplication.otherElements[@"MainView"];
  XCTAssertTrue(self.testedView.exists);
  [self.testedView resolve];
}

- (void)testDescendantsWithClassName
{
  NSSet<NSString *> *expectedLabels = [NSSet setWithArray:@[
    @"Alerts",
    @"Attributes",
    @"Scrolling",
    @"Deadlock app",
  ]];
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingClassName:@"XCUIElementTypeButton" shouldReturnAfterFirstMatch:NO];
  XCTAssertEqual(matchingSnapshots.count, expectedLabels.count);
  NSArray<NSString *> *labels = [matchingSnapshots valueForKeyPath:@"@distinctUnionOfObjects.label"];
  XCTAssertEqualObjects([NSSet setWithArray:labels], expectedLabels);

  NSArray<NSNumber *> *types = [matchingSnapshots valueForKeyPath:@"@distinctUnionOfObjects.elementType"];
  XCTAssertEqual(types.count, 1, @"matchingSnapshots should contain only one type");
  XCTAssertEqualObjects(types.lastObject, @(XCUIElementTypeButton), @"matchingSnapshots should contain only one type");
}

- (void)testSingleDescendantWithClassName
{
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingClassName:@"XCUIElementTypeButton" shouldReturnAfterFirstMatch:YES];
  XCTAssertEqual(matchingSnapshots.count, 1);
  XCTAssertEqual(matchingSnapshots.lastObject.elementType, XCUIElementTypeButton);
}

- (void)testDescendantsWithIdentifier
{
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingIdentifier:@"Alerts" shouldReturnAfterFirstMatch:NO];
  XCTAssertEqual(matchingSnapshots.count, 1);
  XCTAssertEqual(matchingSnapshots.lastObject.elementType, XCUIElementTypeButton);
  XCTAssertEqualObjects(matchingSnapshots.lastObject.label, @"Alerts");
}

- (void)testSingleDescendantWithIdentifier
{
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingIdentifier:@"Alerts" shouldReturnAfterFirstMatch:YES];
  XCTAssertEqual(matchingSnapshots.count, 1);
  XCTAssertEqual(matchingSnapshots.lastObject.elementType, XCUIElementTypeButton);
  XCTAssertEqualObjects(matchingSnapshots.lastObject.label, @"Alerts");
}

- (void)testSingleDescendantWithMissingIdentifier
{
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingIdentifier:@"blabla" shouldReturnAfterFirstMatch:YES];
  XCTAssertEqual(matchingSnapshots.count, 0);
}

- (void)testDescendantsWithXPathQuery
{
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingXPathQuery:@"//XCUIElementTypeButton[@label='Alerts']" shouldReturnAfterFirstMatch:NO];
  XCTAssertEqual(matchingSnapshots.count, 1);
  XCTAssertEqual(matchingSnapshots.lastObject.elementType, XCUIElementTypeButton);
  XCTAssertEqualObjects(matchingSnapshots.lastObject.label, @"Alerts");
}

- (void)testSingleDescendantWithXPathQuery
{
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingXPathQuery:@"//XCUIElementTypeButton" shouldReturnAfterFirstMatch:YES];
  XCTAssertEqual(matchingSnapshots.count, 1);
  XCUIElement *matchingSnapshot = [matchingSnapshots firstObject];
  XCTAssertNotNil(matchingSnapshot);
  XCTAssertEqual(matchingSnapshot.elementType, XCUIElementTypeButton);
  XCTAssertEqualObjects(matchingSnapshot.label, @"Alerts");
}

- (void)testSingleDescendantWithXPathQueryNoMatches
{
  XCUIElement *matchingSnapshot = [[self.testedView fb_descendantsMatchingXPathQuery:@"//XCUIElementTypeButtonnn" shouldReturnAfterFirstMatch:YES] firstObject];
  XCTAssertNil(matchingSnapshot);
}

- (void)testSingleLastDescendantWithXPathQuery
{
  XCUIElement *matchingSnapshot = [[self.testedView fb_descendantsMatchingXPathQuery:@"(//XCUIElementTypeButton)[last()]" shouldReturnAfterFirstMatch:YES] firstObject];
  XCTAssertNotNil(matchingSnapshot);
  XCTAssertEqual(matchingSnapshot.elementType, XCUIElementTypeButton);
}

- (void)testDescendantsWithXPathQueryNoMatches
{
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingXPathQuery:@"//XCUIElementTypeButton[@label='Alerts1']" shouldReturnAfterFirstMatch:NO];
  XCTAssertEqual(matchingSnapshots.count, 0);
}

- (void)testDescendantsWithComplexXPathQuery
{
    NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingXPathQuery:@"//*[@label='Scrolling']/preceding::*[boolean(string(@label))]" shouldReturnAfterFirstMatch:NO];
    XCTAssertEqual(matchingSnapshots.count, 3);
}

- (void)testDescendantsWithWrongXPathQuery
{
  XCTAssertThrowsSpecificNamed([self.testedView fb_descendantsMatchingXPathQuery:@"//*[blabla(@label, Scrolling')]" shouldReturnAfterFirstMatch:NO],
                               NSException, XCElementSnapshotInvalidXPathException);
}

- (void)testFirstDescendantWithWrongXPathQuery
{
  XCTAssertThrowsSpecificNamed([self.testedView fb_descendantsMatchingXPathQuery:@"//*[blabla(@label, Scrolling')]" shouldReturnAfterFirstMatch:YES],
                               NSException, XCElementSnapshotInvalidXPathException);
}

- (void)testVisibleDescendantWithXPathQuery
{
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingXPathQuery:@"//XCUIElementTypeButton[@name='Alerts' and @enabled='true' and @visible='true']" shouldReturnAfterFirstMatch:NO];
  XCTAssertEqual(matchingSnapshots.count, 1);
  XCTAssertEqual(matchingSnapshots.lastObject.elementType, XCUIElementTypeButton);
  XCTAssertTrue(matchingSnapshots.lastObject.isEnabled);
  XCTAssertTrue(matchingSnapshots.lastObject.fb_isVisible);
  XCTAssertEqualObjects(matchingSnapshots.lastObject.label, @"Alerts");
}

- (void)testInvisibleDescendantWithXPathQuery
{
  [self goToAttributesPage];
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedApplication fb_descendantsMatchingXPathQuery:@"//XCUIElementTypePageIndicator[@visible='false']" shouldReturnAfterFirstMatch:NO];
  XCTAssertEqual(matchingSnapshots.count, 1);
  XCTAssertEqual(matchingSnapshots.lastObject.elementType, XCUIElementTypePageIndicator);
  XCTAssertFalse(matchingSnapshots.lastObject.fb_isVisible);
}

- (void)testDescendantsWithPredicateString
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label = 'Alerts'"];
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingPredicate:predicate shouldReturnAfterFirstMatch:NO];
  XCTAssertEqual(matchingSnapshots.count, 1);
  XCTAssertEqual(matchingSnapshots.lastObject.elementType, XCUIElementTypeButton);
  XCTAssertEqualObjects(matchingSnapshots.lastObject.label, @"Alerts");
}

- (void)testSingleDescendantWithPredicateString
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"elementType = %lu", (unsigned long)XCUIElementTypeButton]];
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingPredicate:predicate shouldReturnAfterFirstMatch:YES];
  XCTAssertEqual(matchingSnapshots.count, 1);
  XCTAssertEqual(matchingSnapshots.lastObject.elementType, XCUIElementTypeButton);
}

- (void)testDescendantsWithPropertyStrict
{
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingProperty:@"label" value:@"Alert" partialSearch:NO];
  XCTAssertEqual(matchingSnapshots.count, 0);
  matchingSnapshots = [self.testedView fb_descendantsMatchingProperty:@"label" value:@"Alerts" partialSearch:NO];
  XCTAssertEqual(matchingSnapshots.count, 1);
  XCTAssertEqual(matchingSnapshots.lastObject.elementType, XCUIElementTypeButton);
  XCTAssertEqualObjects(matchingSnapshots.lastObject.label, @"Alerts");
}

- (void)testDescendantsWithPropertyPartial
{
  NSArray<XCUIElement *> *matchingSnapshots = [self.testedView fb_descendantsMatchingProperty:@"label" value:@"Alerts" partialSearch:NO];
  XCTAssertEqual(matchingSnapshots.count, 1);
  XCTAssertEqual(matchingSnapshots.lastObject.elementType, XCUIElementTypeButton);
  XCTAssertEqualObjects(matchingSnapshots.lastObject.label, @"Alerts");
}

@end
