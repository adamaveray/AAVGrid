#import <Foundation/Foundation.h>


#pragma mark - Structs

struct AAVGridCell {
	NSUInteger x;
	NSUInteger y;
};
typedef struct AAVGridCell AAVGridCell;
CG_INLINE AAVGridCell
AAVGridCellMake(NSUInteger x, NSUInteger y){
	AAVGridCell cell;
	cell.x	= x;
	cell.y	= y;
	return cell;
}

NSString *NSStringFromAAVGridCell(AAVGridCell cell);
AAVGridCell AAVGridCellFromString(NSString *string);


struct AAVGridSize {
	NSUInteger columns;
	NSUInteger rows;
};
typedef struct AAVGridSize AAVGridSize;
CG_INLINE AAVGridSize
AAVGridSizeMake(NSUInteger columns, NSUInteger rows){
	AAVGridSize grid;
	grid.columns		= columns;
	grid.rows		= rows;
	return grid;
}

NSString *NSStringFromAAVGridSize(AAVGridSize grid);
AAVGridSize AAVGridSizeFromString(NSString *string);



#pragma mark - Class

@interface AAVGrid : NSObject

@property (nonatomic, readonly) AAVGridSize size;

- (instancetype)initWithSize:(AAVGridSize)size;

- (instancetype)initWithColumns:(NSUInteger)columnCount
						andRows:(NSUInteger)rowCount;


/**
 * @param cell
 * @return Whether the cell is within the grid
 */
- (BOOL)containsCell:(AAVGridCell)cell;

/**
 * @param cell
 * @return The object at the given cell, or nil
 */
- (id)objectAtCell:(AAVGridCell)cell;

/**
 * @param x	The column index(0-indexed)
 * @param y	The row index (0-indexed)
 * @return The object at the given cell, or nil
 * @see objectAtCell:
 */
- (id)objectAtX:(NSUInteger)x
		   andY:(NSUInteger)y;

/**
 * @param object The object to store
 * @param cell   The position to store the object at
 */
- (void)setObject:(id)object
		   atCell:(AAVGridCell)cell;

/**
 * @param object		The object to store
 * @param x			The column index (0-indexed)
 * @param y			The row index (0-indexed)
 * @see setObject:atCell:
 */
- (void)setObject:(id)object
			  atX:(NSUInteger)x
			 andY:(NSUInteger)y;


/**
 * Retrieves the cells directly surrounding the given cell
 *
 * @param cell     The origin cell to find surrounding cells from
 * @param diagonal Whether to include diagonally-adjacent cells
 * @return A set of NSString-encoded AAVGridCells
 * @see AAVGridCellFromNSString
 * @see objectsSurroundingCell:includingDiagonal:
 */
- (NSSet *)cellsSurroundingCell:(AAVGridCell)cell
			  includingDiagonal:(BOOL)diagonal;

/**
 * Retrieves the objects stored in cells directly surrounding the given cell
 *
 * @param cell     The origin cell to find surrounding cells from
 * @param diagonal Whether to include diagonally-adjacent cells
 * @return A set of objects from the located cells
 * @see objectsSurroundingCell:includingDiagonal:
 */
- (NSSet *)objectsSurroundingCell:(AAVGridCell)cell
				includingDiagonal:(BOOL)diagonal;


/**
 * Enumerates the cells in the grid, through each column before beginning the next row
 *
 * @param block
 * @see setObjectsUsingBlock:
 */
- (void)enumerateCellsUsingBlock:(void(^)(id object, AAVGridCell cell, BOOL *stop))block;

/**
 * Allows setting all cells in the grid on a cell-by-cell basis
 *
 * @param block A block whose return values will be stored at the given cell
 * @see enumerateCellsUsingBlock:
 */
- (void)setObjectsUsingBlock:(id(^)(AAVGridCell cell, BOOL *stop))block;

@end
