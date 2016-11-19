//: Playground - noun: a place where people can play

import Cocoa

typealias Position = CGPoint
typealias Distance = CGFloat

// Test if target is within range
func inRange1(target: Position, #range: Distance) -> Bool {
    return sqrt(target.x * target.x + target.y * target.y) <= range
}


var isInRange = inRange1(Position(x: 3, y: 5), range: 5.0)

// Test if target is within range of a position
func inRange2(#target: Position, #ownPosition: Position, #range: Distance) -> Bool {
    let dx = ownPosition.x - target.x
    let dy = ownPosition.y - target.y
    let targetDistance = sqrt(dx * dx + dy * dy)
    return targetDistance <= range
}

isInRange = inRange2(target: Position(x: 3, y: 3), ownPosition: Position(x: 1, y: 1), range: 2)

// Test whether target is in range of position and is not too close to position
func inRange3(#target: Position, #ownPosition: Position, #range: Distance, #minimumDistance: Distance) -> Bool {
    let dx = ownPosition.x - target.x
    let dy = ownPosition.y - target.y
    let targetDistance = sqrt(dx * dx + dy * dy)
    return targetDistance <= range && targetDistance > minimumDistance
}

// Test whether target is in range of position and is not too close to position
// and that no friends are too close too target
func inRange4(#target: Position, #ownPosition: Position, #friendlyPosition: Position, #range: Distance, #minimumDistance: Distance) -> Bool {
    let dx = ownPosition.x - target.x
    let dy = ownPosition.y - target.y
    let targetDistance = sqrt(dx * dx + dy * dy)
    let friendlyDx = friendlyPosition.x - target.x
    let friendlyDy = friendlyPosition.y - target.y
    let friendlyDistance = sqrt(friendlyDx * friendlyDx + friendlyDy * friendlyDy)
    return targetDistance <= range && targetDistance > minimumDistance &&
            friendlyDistance > minimumDistance
}

// Above code is getting complex. Functional programming to the rescue

// Region is a transform a predicate function transforming a point
// in space and determining if it is within a region
// Note: Authors would not name this RegionTest or CheckInRegion 
// because this would emphasize that this is a function and not
// a value. Functional programming is about values, specifically that
// functions are first class values.
typealias Region = Position -> Bool

func circle(radius: Distance) -> Region {
    // Note: Its interesting that we don't have to define
    // the type of point. It is deferred by type inference of Region
    // Spefically, because we are returning a Region the argument
    // to Region is a Position and so the closure argument also
    // must be a Position.
    return { point in
        sqrt(point.x * point.y + point.y * point.y) <= radius
    }
}


// What if we want to test that a point is within circle with origin not at 0,0?
// Instead of writing another factory method that takes in a origin lets make
// something more generic
// Write a transformer!
func shift(offset: Position, region: Region) -> Region {
    return { point in
        let relativePositionFromOffset = Position(x: point.x - offset.x, y: point.y - offset.y)
        return region(relativePositionFromOffset)
    }
}

var testWithinCircleAtPosition = shift(Position(x: 5, y: 5), circle(10))

// Test if a point is not within a region
func invert(region: Region) -> Region {
    return { point in !region(point) }
}

// Test if a point is in the intersection of two regions

func intersection(region1: Region, region2: Region) -> Region {
    return { point in region1(point) && region2(point) }
}


// Test if a point is in the union of two regions
func union(region1: Region, region2: Region) -> Region {
    return { point in region1(point) || region2(point) }
}

// Test if a point is in the difference of a region minus a piece of that region
func difference(region: Region, minusRegion: Region) -> Region {
    return intersection(region, invert(minusRegion))
}


// Now we can rewrite inRange4 a lot cleaner

func inRange(ownPosition: Position, target: Position, friendly: Position, range: Distance, minimumDistance: Distance) -> Bool {
    let rangeRegion = difference(circle(range), circle(minimumDistance))
    let targetRegion = shift(ownPosition, rangeRegion)
    let friendlyRegion = shift(friendly, circle(minimumDistance))
    let validRegion = difference(targetRegion, friendlyRegion)
    return validRegion(target)
}














