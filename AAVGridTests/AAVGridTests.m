#import <XCTest/XCTest.h>
#import "OCMock.h"

#import "AAVGrid.h"

// Private alias
@interface AAVGrid (PrivateTestAlias)

@property (nonatomic, strong) NSMutableArray *storage;

+ (NSMutableArray *)buildGridWithSize:(AAVGridSize)size;

@end


@interface AAVGridTests : XCTestCase

@property (nonatomic, strong) AAVGrid *grid;
@property (nonatomic, strong) NSObject *object;

@end

@implementation AAVGridTests

#pragma mark - Management

- (void)setUp {
	[super setUp];
	
	self.object	= [[NSObject alloc] init];
}

- (void)tearDown {
	[super tearDown];
	
	self.grid	= nil;
	self.object	= nil;
}


#pragma mark - Utilities

- (AAVGridSize)sizeForGrid:(AAVGrid *)grid {
	if(![grid respondsToSelector:@selector(size)]){
		@throw [NSException exceptionWithName:@"GRID_SIZE_NOT_FOUND"
									   reason:@"The grid does not have a size"
									 userInfo:nil];
	}
	
	return [grid size];
}

- (NSArray *)storageForGrid:(AAVGrid *)grid {
	if(![grid respondsToSelector:@selector(storage)]){
		@throw [NSException exceptionWithName:@"GRID_SIZE_NOT_FOUND"
									   reason:@"The grid does not have a size"
									 userInfo:nil];
	}
	
	return [[grid performSelector:@selector(storage)] copy];
}

- (NSMutableArray *)gridStorageWithSize:(AAVGridSize)size
							   useNulls:(BOOL)useNulls {
	NSMutableArray *grid	= [[NSMutableArray alloc] initWithCapacity:size.columns];
	for(int col = 0; col < size.columns; col++){
		NSMutableArray *rowArray	= [[NSMutableArray alloc] initWithCapacity:size.rows];
		for(int row = 0; row < size.rows; row++){
			rowArray[row]	= (useNulls ? [NSNull null] : [NSString stringWithFormat:@"[%i x %i]", col, row]);
		}
		grid[col]	= rowArray;
	}
	return grid;
}


#pragma mark - Test Cases

- (void)testInitWithSize {
	NSUInteger columns	= 2;
	NSUInteger rows		= 3;
	
	self.grid	= [[AAVGrid alloc] initWithSize:AAVGridSizeMake(columns, rows)];
	
	AAVGridSize size		= [self sizeForGrid:self.grid];
	XCTAssertEqual(columns, size.columns, @"Columns do not match");
	XCTAssertEqual(rows, size.rows, @"Rows do not match");
	
	NSArray *storage	= [self storageForGrid:self.grid];
	XCTAssertEqual(columns, storage.count, @"Storage size does not match");
	XCTAssertEqual(rows, ((NSArray *)[storage firstObject]).count, @"Storage size does not match");
}

- (void)testInitWithColumnsAndRows {
	NSUInteger columns	= 2;
	NSUInteger rows		= 3;
	
	self.grid	= [[AAVGrid alloc] initWithColumns:columns
										  andRows:rows];
	
	AAVGridSize size		= [self sizeForGrid:self.grid];
	XCTAssertEqual(columns, size.columns, @"Columns should match");
	XCTAssertEqual(rows, size.rows, @"Rows should match");
	
	NSArray *storage	= [self storageForGrid:self.grid];
	XCTAssertEqual(columns, storage.count, @"Storage size should match");
	XCTAssertEqual(rows, ((NSArray *)[storage firstObject]).count, @"Storage size should match");
}

- (void)testContainsCell {
	NSUInteger columns	= 2;
	NSUInteger rows		= 3;
	
	self.grid	= [[AAVGrid alloc] initWithColumns:columns
										  andRows:rows];
	
	XCTAssertTrue([self.grid containsCell:AAVGridCellMake(1, 1)], @"Should contain cells within grid");
	XCTAssertTrue([self.grid containsCell:AAVGridCellMake(columns-1, rows-1)], @"Should contain cells within grid");
	XCTAssertFalse([self.grid containsCell:AAVGridCellMake(10, 1)], @"Should not contain cells outside grid");
	XCTAssertFalse([self.grid containsCell:AAVGridCellMake(1, 10)], @"Should not contain cells outside grid");
	XCTAssertFalse([self.grid containsCell:AAVGridCellMake(columns, rows)], @"Should not contain cells within grid");
}

- (void)testObjectAtCell {
	NSUInteger columns	= 2;
	NSUInteger rows		= 3;
	
	self.grid	= [[AAVGrid alloc] initWithColumns:columns
										  andRows:rows];
	
	// Mock internal storage
	NSMutableArray *storage	= [self gridStorageWithSize:AAVGridSizeMake(columns, rows)
											   useNulls:NO];
	storage[0][0]	= self.object;
	
	OCMockObject *mock	= [OCMockObject partialMockForObject:self.grid];
	[[[mock expect] andReturn:storage] storage];
	
	self.grid	= (AAVGrid *)mock;
	
	XCTAssertEqualObjects(self.object, [self.grid objectAtCell:AAVGridCellMake(0, 0)], @"Object should match");
	XCTAssertNil([self.grid objectAtCell:AAVGridCellMake(10, 10)], @"Cell outside grid should be nil");
	XCTAssertNil([self.grid objectAtCell:AAVGridCellMake(1, 1)], @"Unset cell should be nil");
}

- (void)testSetObjectAtCell {
	NSUInteger columns	= 2;
	NSUInteger rows		= 3;
	NSUInteger targetX	= 1;
	NSUInteger targetY	= 2;
	
	self.grid	= [[AAVGrid alloc] initWithColumns:columns
										andRows:rows];
	
	// Mock internal storage
	NSMutableArray *storage	= [self gridStorageWithSize:AAVGridSizeMake(columns, rows)
											   useNulls:NO];
	
	OCMockObject *mock	= [OCMockObject partialMockForObject:self.grid];
	[[[mock expect] andReturn:storage] storage];
	
	self.grid	= (AAVGrid *)mock;
	
	[self.grid setObject:self.object
				  atCell:AAVGridCellMake(targetX, targetY)];
	
	XCTAssertEqual(self.object, storage[targetX][targetY], @"Object should be saved in storage");
}

- (void)testObjectAtXAndY {
	NSUInteger columns	= 2;
	NSUInteger rows		= 3;
	NSUInteger targetX	= 1;
	NSUInteger targetY	= 2;
	
	self.grid	= [[AAVGrid alloc] initWithColumns:columns
										andRows:rows];
	
	OCMockObject *mock	= [OCMockObject partialMockForObject:self.grid];
	[[mock expect] setObject:self.object
					  atCell:AAVGridCellMake(targetX, targetY)];
	
	self.grid	= (AAVGrid *)mock;
	
	[self.grid setObject:self.object
					 atX:targetX
					andY:targetY];
}

- (void)testObjectsSurroundingCell {
	NSUInteger columns	= 3;
	NSUInteger rows		= 4;
	NSUInteger targetX	= 1;
	NSUInteger targetY	= 2;
	
	self.grid	= [[AAVGrid alloc] initWithColumns:columns
										andRows:rows];
	
	// Mock internal storage
	NSMutableArray *storage  = [self gridStorageWithSize:AAVGridSizeMake(columns, rows)
												useNulls:NO];
	
	NSArray *targetCells	= @[
		storage[targetX-1][targetY],
		storage[targetX+1][targetY],
		storage[targetX][targetY-1],
		storage[targetX][targetY+1],
	];
	
	OCMockObject *mock	= [OCMockObject partialMockForObject:self.grid];
	[[[mock stub] andReturn:storage] storage];
	
	self.grid	= (AAVGrid *)mock;
	
	NSSet *cells		= [self.grid objectsSurroundingCell:AAVGridCellMake(targetX, targetY)
									  includingDiagonal:NO];
	
	for(int i = 0; i < targetCells.count; i++){
		XCTAssertTrue([cells containsObject:targetCells[i]], @"Cells should include cell %i (%@)", (i+1), targetCells[i]);
	}
	XCTAssertEqual(targetCells.count, cells.count, @"The correct number of cells should be found");
}

- (void)testObjectsSurroundingCellIncludingDiagonal {
	
}

- (void)testCellsSurroundingCell {
	NSUInteger columns	= 3;
	NSUInteger rows		= 4;
	NSUInteger targetX	= 1;
	NSUInteger targetY	= 2;
	
	self.grid	= [[AAVGrid alloc] initWithColumns:columns
										  andRows:rows];
	
	NSArray *targetCells	= @[
		NSStringFromAAVGridCell(AAVGridCellMake(targetX-1, targetY)),
		NSStringFromAAVGridCell(AAVGridCellMake(targetX+1, targetY)),
		NSStringFromAAVGridCell(AAVGridCellMake(targetX,	 targetY-1)),
		NSStringFromAAVGridCell(AAVGridCellMake(targetX,	 targetY+1)),
	];
	
	NSSet *cells		= [self.grid cellsSurroundingCell:AAVGridCellMake(targetX, targetY)
									includingDiagonal:NO];
	
	for(NSString *cell in cells){
		BOOL found = NO;
		for(NSString *targetCell in targetCells){
			if([targetCell isEqualTo:cell]){
				found	= YES;
			}
		}
		XCTAssertTrue(found, @"Surrounding cell should be found");
	}
	
	XCTAssertEqual(targetCells.count, cells.count, @"The correct number of surrounding cells should be found");
}

- (void)testCellsSurroundingCellIncludingDiagonal {
	NSUInteger columns	= 3;
	NSUInteger rows		= 4;
	NSUInteger targetX	= 1;
	NSUInteger targetY	= 2;
	
	self.grid	= [[AAVGrid alloc] initWithColumns:columns
										andRows:rows];
	
	NSArray *targetCells	= @[
		NSStringFromAAVGridCell(AAVGridCellMake(targetX-1, targetY-1)),
		NSStringFromAAVGridCell(AAVGridCellMake(targetX-1, targetY)),
		NSStringFromAAVGridCell(AAVGridCellMake(targetX-1, targetY+1)),
		NSStringFromAAVGridCell(AAVGridCellMake(targetX,	 targetY-1)),
		NSStringFromAAVGridCell(AAVGridCellMake(targetX,	 targetY+1)),
		NSStringFromAAVGridCell(AAVGridCellMake(targetX+1, targetY-1)),
		NSStringFromAAVGridCell(AAVGridCellMake(targetX+1, targetY)),
		NSStringFromAAVGridCell(AAVGridCellMake(targetX+1, targetY+1)),
	];
	
	NSSet *cells		= [self.grid cellsSurroundingCell:AAVGridCellMake(targetX, targetY)
									includingDiagonal:YES];
	
	for(NSString *cell in cells){
		BOOL found = NO;
		for(NSString *targetCell in targetCells){
			if([targetCell isEqualTo:cell]){
				found	= YES;
			}
		}
		XCTAssertTrue(found, @"Surrounding cell should be found");
	}
	
	XCTAssertEqual(targetCells.count, cells.count, @"The correct number of surrounding cells should be found");
}

- (void)testEnumerateCellsUsingBlock {
	NSUInteger columns	= 2;
	NSUInteger rows		= 3;
	
	self.grid	= [[AAVGrid alloc] initWithColumns:columns
										  andRows:rows];
	
	// Mock internal storage
	NSMutableArray *storage	= [self gridStorageWithSize:AAVGridSizeMake(columns, rows)
											   useNulls:NO];
	
	OCMockObject *mock	= [OCMockObject partialMockForObject:self.grid];
	[[[mock stub] andReturn:storage] storage];
	
	self.grid	= (AAVGrid *)mock;
	
	__block NSMutableSet *objects	= [[NSMutableSet alloc] init];
	__block NSUInteger total		= 0;
	[self.grid enumerateCellsUsingBlock:^(id object, AAVGridCell cell, BOOL *stop){
		total++;
		[objects addObject:object];
	}];
	XCTAssertEqual(columns*rows, total, @"The correct number of cells should be enumerated");
	XCTAssertEqual(columns*rows, objects.count, @"Each cell's object should be retrieved");
}

- (void)testEnumerateCellsUsingBlockStopping {
	NSUInteger columns	= 2;
	NSUInteger rows		= 3;
	
	self.grid	= [[AAVGrid alloc] initWithColumns:columns
										andRows:rows];
	
	// Mock internal storage
	NSMutableArray *storage	= [self gridStorageWithSize:AAVGridSizeMake(columns, rows)
											   useNulls:YES];
	OCMockObject *mock	= [OCMockObject partialMockForObject:self.grid];
	[[[mock expect] andReturn:storage] storage];
	
	self.grid	= (AAVGrid *)mock;
	
	__block BOOL isFirst	= YES;
	__block BOOL didFail	= NO;
	[self.grid enumerateCellsUsingBlock:^(id object, AAVGridCell cell, BOOL *stop){
		if(!isFirst){
			didFail	= YES;
		}
		
		isFirst	= NO;
		*stop	= YES;
	}];
	
	if(isFirst){
		XCTFail(@"Enumeration should run at least once");
	}
	if(didFail){
		XCTFail(@"Enumeration should not be called after stopping");
	}
}

- (void)testSetObjectsUsingBlock {
	NSUInteger columns	= 2;
	NSUInteger rows		= 3;
	__block NSUInteger targetX	= 1;
	__block NSUInteger targetY	= 2;
	
	self.grid	= [[AAVGrid alloc] initWithColumns:columns
										andRows:rows];
	
	// Mock internal storage
	NSMutableArray *storage	= [self gridStorageWithSize:AAVGridSizeMake(columns, rows)
											   useNulls:NO];
	
	OCMockObject *mock	= [OCMockObject partialMockForObject:self.grid];
	[[[mock stub] andReturn:storage] storage];
	
	self.grid	= (AAVGrid *)mock;
	
	__block id object			= self.object;
	__block NSUInteger total	= 0;
	
	[self.grid setObjectsUsingBlock:^id(AAVGridCell cell, BOOL *stop){
		total++;
		
		if(cell.x == targetX && cell.y == targetY){
			return object;
		}
		
		// Fill remainder
		return nil;
	}];
	XCTAssertEqual(self.object, storage[targetX][targetY], @"Set objects should be placed in storage");
	XCTAssertEqual(columns*rows, total, @"The correct number of cells should be enumerated");
}

- (void)testSetObjectsUsingBlockStopping {
	NSUInteger columns	= 2;
	NSUInteger rows		= 3;
	
	self.grid	= [[AAVGrid alloc] initWithColumns:columns
										andRows:rows];
	
	// Mock internal storage
	NSMutableArray *storage	= [self gridStorageWithSize:AAVGridSizeMake(columns, rows)
											   useNulls:YES];
	OCMockObject *mock	= [OCMockObject partialMockForObject:self.grid];
	[[[mock expect] andReturn:storage] storage];
	
	self.grid	= (AAVGrid *)mock;
	
	__block BOOL isFirst	= YES;
	__block BOOL didFail	= NO;
	[self.grid setObjectsUsingBlock:^id(AAVGridCell cell, BOOL *stop){
		if(!isFirst){
			didFail	= YES;
		}
		
		isFirst	= NO;
		*stop	= YES;
		
		return nil;
	}];
	
	if(isFirst){
		XCTFail(@"Enumeration should run at least once");
	}
	if(didFail){
		XCTFail(@"Enumeration should not be called after stopping");
	}
}

- (void)testBuildGridWithSize {
	NSUInteger columns	= 4;
	NSUInteger rows		= 3;
	
	NSMutableArray *grid	= [AAVGrid buildGridWithSize:AAVGridSizeMake(columns, rows)];
	XCTAssertEqual(columns, grid.count, @"Grid should have correct number of columns");
	
	for(int i = 0; i < grid.count; i++){
		id obj	= grid[i];
		if(![obj isKindOfClass:[NSMutableArray class]]){
			XCTFail(@"Columns should be arrays");
			break;
		}
		
		NSMutableArray *column	= obj;
		XCTAssertEqual(rows, column.count, @"Columns should have the correct number of rows");
	}
}

@end
