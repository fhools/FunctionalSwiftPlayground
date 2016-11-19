//: Playground - noun: a place where people can play

import Cocoa
import XCPlayground

typealias Filter = CIImage -> CIImage


func blur(radius: Double) -> Filter {
    return { image in
        let parameters = [
            kCIInputRadiusKey: radius,
            kCIInputImageKey: image
        ]
        let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: parameters)
        return filter.outputImage
    }
}

// This must be called with a Color that has alpha component < 1.0
func colorGenerator(color: NSColor) -> Filter {
    return { _ in
        let parameters = [kCIInputColorKey: color]
        let filter = CIFilter(name: "CIConstantColorGenerator", withInputParameters: parameters)
        return filter.outputImage
    }
}

func compositeSourceOver(overlay: CIImage) -> Filter {
    return { image in
        let parameters = [
            kCIInputBackgroundImageKey: image,
            kCIInputImageKey: overlay
        ]
        let filter = CIFilter(name: "CISourceOverCompositing", withInputParameters: parameters)
        let cropRect = image.extent()
        return filter.outputImage.imageByCroppingToRect(cropRect)
    }
}

func colorOverlay(color: NSColor) -> Filter {
    return { image in
        let overlay = colorGenerator(color)(image)
        return compositeSourceOver(overlay)(image)
    }
}

var blurFilter = blur(10.0)

var image = NSImage(named: "AngryBird")

var ciimage =  CIImage(data: image?.TIFFRepresentation)


var imageBlurred = blurFilter(ciimage)

var red = colorGenerator(NSColor.redColor().colorWithAlphaComponent(0.3))

colorOverlay(NSColor.blueColor().colorWithAlphaComponent(0.25))(ciimage)

let url = NSURL(string: "https://lh4.googleusercontent.com/-YCRFnjDOiwk/AAAAAAAAAAI/AAAAAAAAAAA/akhx39n7XyA/photo.jpg")
let image2 = CIImage(contentsOfURL: url)

let blurredImage = blur(5.0)(image2)
let overlaidImage = colorOverlay(NSColor.redColor().colorWithAlphaComponent(0.2))(blurredImage)

infix operator >>> { associativity left }

func >>> (filter1: Filter, filter2: Filter) -> Filter {
    return { image in filter2(filter1(image)) }
}

let overlayColor = NSColor.redColor().colorWithAlphaComponent(0.3)
let myFilter2 = blur(5.0) >>> colorOverlay(overlayColor)
let result2 = myFilter2(image2)









