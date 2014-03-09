#import "AAVGrid.h"

#pragma mark - Struct Functions

NSTextCheckingResult *NSTextCheckingResultFromAAStructString(NSString *string){
	if(!string){
		return nil;
	}
	
	NSRegularExpression *regex	= [NSRegularExpression regularExpressionWithPattern:@"^\\{(\\d+), (\\d+)\\}$"
																		   options:0
																			 error:NULL];
	NSTextCheckingResult *match	= [regex firstMatchInString:string
													options:0
													  range:NSMakeRange(0, string.length)];
	
	return match;
};


NSString *NSStringFromAAVGridCell(AAVGridCell cell){
	return [NSString stringWithFormat:@"{%lu, %lu}", (unsigned long)cell.x, (unsigned long)cell.y];
}
AAVGridCell AAVGridCellFromString(NSString *string){
	NSTextCheckingResult *match	= NSTextCheckingResultFromAAStructString(string);
	
	NSUInteger x		= [[string substringWithRange:[match rangeAtIndex:1]] integerValue];
	NSUInteger y		= [[string substringWithRange:[match rangeAtIndex:2]] integerValue];
	
	return AAVGridCellMake(x, y);
}

NSString *NSStringFromAAVGridSize(AAVGridSize grid){
	return [NSString stringWithFormat:@"{%lu, %lu}", (unsigned long)grid.columns, (unsigned long)grid.rows];
}
AAVGridSize AAVGridSizeFromString(NSString *string){
	NSTextCheckingResult *match	= NSTextCheckingResultFromAAStructString(string);
	
	NSUInteger columns	= [[string substringWithRange:[match rangeAtIndex:1]] integerValue];
	NSUInteger rows		= [[string substringWithRange:[match rangeAtIndex:2]] integerValue];
	
	return AAVGridSizeMake(columns, rows);
}

#pragma mark - Class

@interface AAVGrid()

// storage[x] = columns, storage[x][y] = rows
@property (nonatomic, strong) NSMutableArray *storage;
@property (nonatomic, readwrite) AAVGridSize size;

@end


@implementation AAVGrid

- (instancetype)initWithSize:(AAVGridSize)size {
	self		= [self init];
	if(self){
		self.size	= size;
		self.storage	= [AAVGrid buildGridWithSize:size];
	}
	return self;
}

- (instancetype)initWithColumns:(NSUInteger)columnCount
						andRows:(NSUInteger)rowCount {
	return [self initWithSize:AAVGridSizeMake(columnCount, rowCount)];
}


#pragma mark - Access

- (BOOL)containsCell:(AAVGridCell)cell {
	return (cell.x < self.size.columns && cell.y < self.size.rows);
}

- (id)objectAtCell:(AAVGridCell)cell {
	if(![self containsCell:cell]){
		// Out of bounds
		return nil;
	}
	
	id object	= self.storage[cell.x][cell.y];
	
	if([object isEqual:[NSNull null]]){
		// No object
		return nil;
	}
	
	return object;
}


- (id)objectAtX:(NSUInteger)x
		   andY:(NSUInteger)y {
	return [self objectAtCell:AAVGridCellMake(x, y)];
}

- (void)setObject:(id)object
		   atCell:(AAVGridCell)cell {
	if(![self containsCell:cell]){
		// Out of bounds
		return;
	}
	
	if(!object){
		// Convert nil to object
		object	= [NSNull null];
	}
	
	self.storage[cell.x][cell.y]	= object;
}

- (void)setObject:(id)object
			  atX:(NSUInteger)x
			 andY:(NSUInteger)y {
	[self setObject:object
			 atCell:AAVGridCellMake(x, y)];
}

- (NSSet *)cellsSurroundingCell:(AAVGridCell)cell
			  includingDiagonal:(BOOL)diagonal {
	NSMutableSet *cells	= [[NSMutableSet alloc] init];
	
	for(int x = -1; x <= 1; x++){
		for(int y = -1; y <= 1; y++){
			if(!diagonal && (x != 0 && y != 0)){
				// Disallowed diagonal
				continue;
			}
			
			if(x == 0 && y == 0){
				// Current cell - exclude
				continue;
			}
			
			
			AAVGridCell neighboringCell	= AAVGridCellMake(cell.x + x, cell.y + y);
			if(![self containsCell:neighboringCell]){
				// Out of bounds
				continue;
			}
			
			[cells addObject:NSStringFromAAVGridCell(neighboringCell)];
		}
	}
	
	return [cells copy];
}

- (NSSet *)objectsSurroundingCell:(AAVGridCell)cell
				includingDiagonal:(BOOL)diagonal {
	NSSet *cells		= [self cellsSurroundingCell:cell
							   includingDiagonal:diagonal];
	
	__block NSMutableSet *objects	= [[NSMutableSet alloc] init];
	[cells enumerateObjectsUsingBlock:^(NSString *cellString, BOOL *stop){
		AAVGridCell cell	= AAVGridCellFromString(cellString);
		
		id obj	= [self objectAtCell:cell];
		if(!obj){
			// No value
			return;
		}
		
		[objects addObject:obj];
	}];
	
	return [objects copy];
}

- (void)enumerateCellsUsingBlock:(void (^)(id object, AAVGridCell cell, BOOL *stop))block {
	BOOL stop = NO;
	for(int x = 0; x < self.size.columns; x++){
		for(int y = 0; y < self.size.rows; y++){
			AAVGridCell cell	= AAVGridCellMake(x, y);
			
			block([self objectAtCell:cell], cell, &stop);
			
			if(stop){
				break;
			}
		}
		
		if(stop){
			break;
		}
	}
}

- (void)setObjectsUsingBlock:(id(^)(AAVGridCell cell, BOOL *stop))block {
	BOOL stop = NO;
	for(int y = 0; y < self.size.rows; y++){
		for(int x = 0; x < self.size.columns; x++){
			AAVGridCell cell	= AAVGridCellMake(x, y);
			
			id object	= block(cell, &stop);
			if(stop){
				break;
			}
			
			[self setObject:object
					 atCell:cell];
		}
		
		if(stop){
			break;
		}
	}
}


#pragma mark -

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@", [self class], NSStringFromAAVGridSize(self.size)];
}


#pragma mark - Class Methods

+ (NSMutableArray *)buildGridWithSize:(AAVGridSize)size {
	NSMutableArray *array	= [[NSMutableArray alloc] init];
	
	for(int x = 0; x < size.columns; x++){
		NSMutableArray *column	= [[NSMutableArray alloc] init];
		
		for(int y = 0; y < size.rows; y++){
			[column addObject:[NSNull null]];
		}
		
		[array addObject:column];
	}
	
	return array;
}

@end
