local gphoto2 = require "gphoto2"

print "Acquiring camera..."
local camera = gphoto2.acquireCamera()
print "Displaying summary..."
--print(camera:summary())
print "Capturing image..."
camera:setConfig("capturetarget", "1")
file = camera:captureImage({ aperture = "5.6", shutterspeed = "1/200" })
file = camera:captureImage({ aperture = "2.8", shutterspeed = "1/15", iso = "3200" })

--print(camera:lensName())
--camera:setConfig("aperture", "5.6")
--camera:setConfig("shutterspeed", "1/200")