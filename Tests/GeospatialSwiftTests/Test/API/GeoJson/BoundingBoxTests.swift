import XCTest

@testable import GeospatialSwift

class BoundingBoxTests: XCTestCase {
    private(set) var simpleBoundingBox: GeodesicBoundingBox!
    
    private(set) var pointBoundingBox: GeodesicBoundingBox!
    private(set) var horizontalBoundingBox: GeodesicBoundingBox!
    private(set) var verticalBoundingBox: GeodesicBoundingBox!

    private(set) var insideBoundingBox: GeodesicBoundingBox!
    private(set) var horizontalOverlapBoundingBox: GeodesicBoundingBox!
    private(set) var verticalOverlapBoundingBox: GeodesicBoundingBox!
    private(set) var horizontalVerticalOverlapBoundingBox: GeodesicBoundingBox!
    private(set) var noOverlapBoundingBox: GeodesicBoundingBox!
    
    let boundingBoxMinimumAdjustment = 0.00005
    
    private var boundingCoordinatesHorizontalOverlap: GeodesicBoundingBox { .init(minLongitude: simpleBoundingBox.minLongitude, minLatitude: simpleBoundingBox.minLatitude, maxLongitude: horizontalOverlapBoundingBox.maxLongitude, maxLatitude: simpleBoundingBox.maxLatitude) }
    
    private var boundingCoordinatesVerticalOverlap: GeodesicBoundingBox { .init(minLongitude: simpleBoundingBox.minLongitude, minLatitude: simpleBoundingBox.minLatitude, maxLongitude: simpleBoundingBox.maxLongitude, maxLatitude: verticalOverlapBoundingBox.maxLatitude) }
    
    private var boundingCoordinatesCornerOverlap: GeodesicBoundingBox { .init(minLongitude: simpleBoundingBox.minLongitude, minLatitude: simpleBoundingBox.minLatitude, maxLongitude: horizontalOverlapBoundingBox.maxLongitude, maxLatitude: verticalOverlapBoundingBox.maxLatitude) }
    
    private var boundingCoordinatesNoOverlap: GeodesicBoundingBox { .init(minLongitude: simpleBoundingBox.minLongitude, minLatitude: simpleBoundingBox.minLatitude, maxLongitude: noOverlapBoundingBox.maxLongitude, maxLatitude: noOverlapBoundingBox.maxLatitude) }
    
    override func setUp() {
        super.setUp()
        
        simpleBoundingBox = .init(minLongitude: 0, minLatitude: 1, maxLongitude: 2, maxLatitude: 4)
        
        pointBoundingBox = .init(minLongitude: 0, minLatitude: 1, maxLongitude: 0, maxLatitude: 1)
        horizontalBoundingBox = .init(minLongitude: 0, minLatitude: 1, maxLongitude: 2, maxLatitude: 1)
        verticalBoundingBox = .init(minLongitude: 0, minLatitude: 1, maxLongitude: 0, maxLatitude: 3)
        
        // 0 - 2, 1 - 4
        // 1 - 1.5, 2 - 3
        insideBoundingBox = .init(minLongitude: 1, minLatitude: 2, maxLongitude: 1.5, maxLatitude: 3)
        // 1 - 2, 3 - 3
        horizontalOverlapBoundingBox = .init(minLongitude: 1, minLatitude: 2, maxLongitude: 3, maxLatitude: 3)
        verticalOverlapBoundingBox = .init(minLongitude: 1, minLatitude: 2, maxLongitude: 1.5, maxLatitude: 5)
        horizontalVerticalOverlapBoundingBox = .init(minLongitude: 1, minLatitude: 2, maxLongitude: 3, maxLatitude: 5)
        noOverlapBoundingBox = .init(minLongitude: 5, minLatitude: 6, maxLongitude: 7, maxLatitude: 9)
    }
    
    func testBoundingCoordinates() {
        XCTAssertEqual(simpleBoundingBox.points[0].longitude, simpleBoundingBox.minLongitude)
        XCTAssertEqual(simpleBoundingBox.points[0].latitude, simpleBoundingBox.minLatitude)
        XCTAssertEqual(simpleBoundingBox.points[2].longitude, simpleBoundingBox.maxLongitude)
        XCTAssertEqual(simpleBoundingBox.points[2].latitude, simpleBoundingBox.maxLatitude)
    }
    
    func testOverlaps_WhenSame_ThenTrue() {
        let overlaps = simpleBoundingBox.overlaps(boundingBox: simpleBoundingBox, tolerance: 0)
        
        XCTAssertEqual(overlaps, true)
    }
    
    func testOverlaps_WhenInside_ThenTrue() {
        let overlaps = simpleBoundingBox.overlaps(boundingBox: insideBoundingBox, tolerance: 0)
        
        XCTAssertEqual(overlaps, true)
    }
    
    func testOverlaps_WhenOutside_ThenTrue() {
        let overlaps = insideBoundingBox.overlaps(boundingBox: simpleBoundingBox, tolerance: 0)
        
        XCTAssertEqual(overlaps, true)
    }
    
    func testOverlaps_WhenHorizontalOverlap_ThenTrue() {
        let overlaps = simpleBoundingBox.overlaps(boundingBox: horizontalOverlapBoundingBox, tolerance: 0)
        
        XCTAssertEqual(overlaps, true)
    }
    
    func testOverlaps_WhenVerticalOverlap_ThenTrue() {
        let overlaps = simpleBoundingBox.overlaps(boundingBox: verticalOverlapBoundingBox, tolerance: 0)
        
        XCTAssertEqual(overlaps, true)
    }
    
    func testOverlaps_WhenHorizontalVerticalOverlap_ThenTrue() {
        let overlaps = simpleBoundingBox.overlaps(boundingBox: horizontalVerticalOverlapBoundingBox, tolerance: 0)
        
        XCTAssertEqual(overlaps, true)
    }
    
    func testOverlaps_WhenNoOverlap_ThenFalse() {
        let overlaps = simpleBoundingBox.overlaps(boundingBox: noOverlapBoundingBox, tolerance: 0)
        
        XCTAssertEqual(overlaps, false)
    }
    
    func testContains_WhenInside_ThenTrue() {
        let contains = simpleBoundingBox.contains(point: simpleBoundingBox.centroid, tolerance: 0)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_WhenOn_ThenTrue() {
        let contains = simpleBoundingBox.contains(point: SimplePoint(longitude: simpleBoundingBox.minLongitude, latitude: simpleBoundingBox.minLatitude), tolerance: 0)
        
        XCTAssertEqual(contains, true)
    }
    
    func testContains_WhenOutside_ThenFalse() {
        let contains = simpleBoundingBox.contains(point: SimplePoint(longitude: noOverlapBoundingBox.minLongitude, latitude: noOverlapBoundingBox.minLatitude), tolerance: 0)
        
        XCTAssertEqual(contains, false)
    }
    
    func testLongitudeDelta() {
        XCTAssertEqual(pointBoundingBox.longitudeDelta, 0, "longitudeDelta should be the difference in min and max longitude")
        XCTAssertEqual(horizontalBoundingBox.longitudeDelta, 2, "longitudeDelta should be the difference in min and max longitude")
        XCTAssertEqual(verticalBoundingBox.longitudeDelta, 0, "longitudeDelta should be the difference in min and max longitude")
        XCTAssertEqual(simpleBoundingBox.longitudeDelta, 2, "longitudeDelta should be the difference in min and max longitude")
    }
    
    func testLatitudeDelta() {
        XCTAssertEqual(pointBoundingBox.latitudeDelta, 0, "latitudeDelta should be the difference in min and max latitude")
        XCTAssertEqual(horizontalBoundingBox.latitudeDelta, 0, "latitudeDelta should be the difference in min and max latitude")
        XCTAssertEqual(verticalBoundingBox.latitudeDelta, 2, "latitudeDelta should be the difference in min and max latitude")
        XCTAssertEqual(simpleBoundingBox.latitudeDelta, 3, "latitudeDelta should be the difference in min and max latitude")
    }
    
    func testCentroid() {
        XCTAssertEqual(pointBoundingBox.centroid.longitude, 0, "centerCoordinate.longitude should be the center point of min and max longitude")
        XCTAssertEqual(pointBoundingBox.centroid.latitude, 1, "centerCoordinate.latitude should be the center point of min and max latitude")
        XCTAssertEqual(simpleBoundingBox.centroid.longitude, 1, "centerCoordinate.longitude should be the center point of min and max longitude")
        XCTAssertEqual(simpleBoundingBox.centroid.latitude, 2.5, "centerCoordinate.latitude should be the center point of min and max latitude")
    }
    
    func testPoints() {
        XCTAssertEqual(simpleBoundingBox.points.count, 4, "coordinates should have 4 points")
        XCTAssertEqual(simpleBoundingBox.points[0].longitude, simpleBoundingBox.minLongitude)
        XCTAssertEqual(simpleBoundingBox.points[0].latitude, simpleBoundingBox.minLatitude)
        XCTAssertEqual(simpleBoundingBox.points[1].longitude, simpleBoundingBox.minLongitude)
        XCTAssertEqual(simpleBoundingBox.points[1].latitude, simpleBoundingBox.maxLatitude)
        XCTAssertEqual(simpleBoundingBox.points[2].longitude, simpleBoundingBox.maxLongitude)
        XCTAssertEqual(simpleBoundingBox.points[2].latitude, simpleBoundingBox.maxLatitude)
        XCTAssertEqual(simpleBoundingBox.points[3].longitude, simpleBoundingBox.maxLongitude)
        XCTAssertEqual(simpleBoundingBox.points[3].latitude, simpleBoundingBox.minLatitude)
    }
    
    func testAdjustedBoundingBox_WhenMinAndMaxLongitudeAreEqual_ThenAdjust() {
        let verticalAdjustedBoundingBox = verticalBoundingBox.validBoundingBox(minimumAdjustment: boundingBoxMinimumAdjustment)
        
        XCTAssertEqual(verticalAdjustedBoundingBox.minLongitude, verticalBoundingBox.minLongitude - boundingBoxMinimumAdjustment)
        XCTAssertEqual(verticalAdjustedBoundingBox.maxLongitude, verticalBoundingBox.maxLongitude + boundingBoxMinimumAdjustment)
    }
    
    func testAdjustedBoundingBox_WhenMinAndMaxLatitudeAreEqual_ThenAdjust() {
        let horizontalAdjustedBoundingBox = horizontalBoundingBox.validBoundingBox(minimumAdjustment: boundingBoxMinimumAdjustment)
        
        XCTAssertEqual(horizontalAdjustedBoundingBox.minLatitude, horizontalBoundingBox.minLatitude - boundingBoxMinimumAdjustment)
        XCTAssertEqual(horizontalAdjustedBoundingBox.maxLatitude, horizontalBoundingBox.maxLatitude + boundingBoxMinimumAdjustment)
    }
    
    func testAdjustedBoundingBox_WhenMinAndMaxLongitudeAreDifferent_ThenNoAdjustment() {
        let horizontalAdjustedBoundingBox = horizontalBoundingBox.validBoundingBox(minimumAdjustment: boundingBoxMinimumAdjustment)
        
        XCTAssertEqual(horizontalAdjustedBoundingBox.minLongitude, horizontalBoundingBox.minLongitude)
        XCTAssertEqual(horizontalAdjustedBoundingBox.maxLongitude, horizontalBoundingBox.maxLongitude)
    }
    
    func testAdjustedBoundingBox_WhenMinAndMaxLatitudeAreDifferent_ThenNoAdjustment() {
        let verticalAdjustedBoundingBox = verticalBoundingBox.validBoundingBox(minimumAdjustment: boundingBoxMinimumAdjustment)
        
        XCTAssertEqual(verticalAdjustedBoundingBox.minLatitude, verticalBoundingBox.minLatitude)
        XCTAssertEqual(verticalAdjustedBoundingBox.maxLatitude, verticalBoundingBox.maxLatitude)
    }

    func testEqual() {
        XCTAssertEqual(simpleBoundingBox, simpleBoundingBox)
        XCTAssertEqual(horizontalBoundingBox, horizontalBoundingBox)
        XCTAssertEqual(verticalBoundingBox, verticalBoundingBox)
        XCTAssertEqual(pointBoundingBox, pointBoundingBox)
    }
    
    func testNotEqual() {
        XCTAssertNotEqual(horizontalBoundingBox, simpleBoundingBox)
        XCTAssertNotEqual(verticalBoundingBox, simpleBoundingBox)
        XCTAssertNotEqual(pointBoundingBox, simpleBoundingBox)
    }
    
    func testBest_WhenEmpty_ThenNil() {
        XCTAssertEqual(GeodesicBoundingBox.best([]), nil)
    }
    
    func testBest_WhenOnlySelf_ThenSelf() {
        XCTAssertEqual(GeodesicBoundingBox.best([simpleBoundingBox]), simpleBoundingBox)
    }
    
    func testBest_WhenSame_ThenSelf() {
        XCTAssertEqual(GeodesicBoundingBox.best([simpleBoundingBox, simpleBoundingBox]), simpleBoundingBox)
    }
    
    func testBest_WhenInside_ThenSelf() {
        XCTAssertEqual(GeodesicBoundingBox.best([simpleBoundingBox, insideBoundingBox]), simpleBoundingBox)
    }
    
    func testBest_WhenHorizontalOverlap_ThenBest() {
        XCTAssertEqual(GeodesicBoundingBox.best([simpleBoundingBox, horizontalOverlapBoundingBox]), boundingCoordinatesHorizontalOverlap)
    }
    
    func testBest_WhenVerticalOverlap_ThenBest() {
        XCTAssertEqual(GeodesicBoundingBox.best([simpleBoundingBox, verticalOverlapBoundingBox]), boundingCoordinatesVerticalOverlap)
    }
    
    func testBest_WhenHorizontalVerticalOverlap_ThenBest() {
        XCTAssertEqual(GeodesicBoundingBox.best([simpleBoundingBox, horizontalVerticalOverlapBoundingBox]), boundingCoordinatesCornerOverlap)
    }
    
    func testBest_Multiple_ThenBest() {
        XCTAssertEqual(GeodesicBoundingBox.best([simpleBoundingBox, pointBoundingBox, horizontalOverlapBoundingBox, verticalOverlapBoundingBox]), boundingCoordinatesCornerOverlap)
    }
    
    func testBest_WhenNoOverlap_ThenBest() {
        XCTAssertEqual(GeodesicBoundingBox.best([simpleBoundingBox, noOverlapBoundingBox]), boundingCoordinatesNoOverlap)
    }
}
