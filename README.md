AAVGrid
=======

A generic grid storage structure.


Installation
------------

Use [Cocoapods](http://cocoapods.org)!

~~~ruby
pod 'AAVGrid', :podspec => "https://raw.github.com/adamaveray/AAVGridCell/master/AAVGridCell.podspec"
~~~


Usage
-----

### Basic

First, build a new grid:

~~~objc
AAVGrid *grid = [[AAVGrid alloc] initWithColumns:5
                                         andRows:3];
~~~

You can then set or retrieve objects stored at positions within the grid:

~~~objc
id obj = /* ... */;

[grid setObject:obj
            atX:column
           andY:row];
         
// ...

id retrieved = [grid getObjectAtX:column
                             andY:row];
~~~

Like coordinates, `x` is the column, and `y` is the row. These values are 0-indexed. Manually managing the `x` and `y` values like this often becomes frustrating however, so there are also...


### Structs

Working with `x` and `y` coordinates directly can get tedious, so there are helper structs and functions to work with the grid, as well as corresponding methods on the grid class:

~~~objc
AAVGridSize size = AAVGridSizeMake(10, 5); // width ✕ height
AAVGrid *grid    = [[AAVGrid alloc] initWithSize:size]

// ...

id obj = /* ... */;
AAVGridCell cell = AAVGridCellMake(1, 2); // x ✕ y

[grid setObject:obj
         atCell:cell];
         
// ...

AAVGridCell targetCell = AAVGridCellMake(3, 1); // x ✕ y
id retrieved = [grid objectAtCell:cell];

// ...

NSUInteger columns	= grid.size.columns;
~~~

You can also test if a given position is within the grid:

~~~objc
AAVGridCell cell = AAVGridCellMake(2, 3);

BOOL isInGrid = [grid containsCell:cell];
~~~

The are also `NSStringFromAAVGrid____` and `AAVGrid___FromNSString` utility functions available.


### Enumeration

You can also set and retrieve objects in the grid through enumeration:

~~~objc
[grid enumerateCellsUsingBlock:^(id object, AAGridCell cell, BOOL *stop){
    // object = stored object
    // cell = current cell
}];

// ...

[grid setObjectsUsingBlock:^id(AAGridCell cell, BOOL *stop){
    return theValue;    // The returned value will be stored for the current cell
}];
~~~


### Extra

You can access the cells surrounding a given cell, or the objects stored within, through additional methods:

~~~objc
AAVGridCell cell = AAVGridCellMake(2, 4);
NSSet *objects   = [grid objectsSurroundingCell:cell
                              includingDiagonal:NO]; // Can optionally include diagonal neighbours in addition to direct neighbours
~~~

The lower-level `cellsSurroundingCell:includingDiagonal:` method will return an `NSSet` of `NSString`-encoded `AAVGridCell`s, which can be converted back to the raw struct using the `AAVGridCellFromNSString` function.


Contributing
------------

See the brief [contributing docs](CONTRIBUTING.md) for information.
