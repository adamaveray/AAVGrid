#import <XCTest/XCTest.h>
#import "OCMock.h"

#import "AAVGrid.h"

@interface AAVGridStructTests : XCTestCase
@end

@implementation AAVGridStructTests

#pragma mark - Management

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}


#pragma mark - Utilities

- (NSString *)numbersToString:(NSInteger)a
							 :(NSUInteger)b {
	return [NSString stringWithFormat:@"{%lu, %lu}", a, b];
}


#pragma mark - Test Cases

- (void)testCellMake {
	NSUInteger column	= 3;
	NSUInteger row		= 4;
	
	AAVGridCell cell	= AAVGridCellMake(column, row);
	
	XCTAssertEqual(column, cell.x, @"Cell x should equal column");
	XCTAssertEqual(row, cell.y, @"Cell y should equal row");
}

- (void)testSizeMake {
	NSUInteger columns	= 3;
	NSUInteger rows		= 4;
	
	AAVGridSize size	= AAVGridSizeMake(columns, rows);
	
	XCTAssertEqual(columns, size.columns, @"Size columns should equal columns");
	XCTAssertEqual(rows, size.rows, @"Size rows should equal rows");
}

- (void)testStringFromCell {
	NSUInteger col	= 2;
	NSUInteger row	= 3;
	
	NSString *expected	= [self numbersToString:col
											  :row];
	AAVGridCell cell		= AAVGridCellMake(col, row);
	
	XCTAssertTrue([expected isEqualTo:NSStringFromAAVGridCell(cell)], @"Cell string should be correct format");
}

- (void)testCellFromString {
	NSUInteger col	= 2;
	NSUInteger row	= 3;
	
	NSString *source	= [self numbersToString:col
											:row];
	AAVGridCell cell		= AAVGridCellMake(col, row);
	
	XCTAssertEqual(cell, AAVGridCellFromString(source), @"Cell should be loaded correctly from string");
}

- (void)testSizeFromString {
	NSUInteger columns	= 2;
	NSUInteger rows		= 3;
	
	NSString *source	= [self numbersToString:columns
											:rows];
	AAVGridSize size		= AAVGridSizeMake(columns, rows);
	
	XCTAssertEqual(size, AAVGridSizeFromString(source), @"Size should be loaded correctly from string");
}

- (void)testStringFromSize {
	NSUInteger columns	= 2;
	NSUInteger rows		= 3;
	
	NSString *expected	= [self numbersToString:columns
											  :rows];
	AAVGridSize size		= AAVGridSizeMake(columns, rows);
	
	XCTAssertTrue([expected isEqualTo:NSStringFromAAVGridSize(size)], @"Size string should be correct format");
}

@end
