local gphoto2 = require "gphoto2"

print "Acquiring camera..."
local camera = gphoto2.acquireCamera()
print "Displaying summary..."
print(camera:summary())
print "Capturing image..."
file = camera:captureImage()