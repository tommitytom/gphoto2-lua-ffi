package.path = "./?/init.lua;" .. package.path
package.loaded [ "gphoto2" ] = dofile ( "init.lua" )
local gphoto2 = require "gphoto2"

print "Acquiring camera..."
local camera = gphoto2.acquire_camera()
print "Displaying summary..."
print(camera:summary())
print "Capturing image..."
file = camera:capture_image()