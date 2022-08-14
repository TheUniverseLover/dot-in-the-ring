text.clear
gfx.clear
gfx.print "Defining device default inclination", 130, 600, "#88EE88", "large"
gfx.print "The player's speed is zero when the device is at", 20, 540, "#AAFFAA"
gfx.print "its' default inclination.", 20, 515, "#AAFFAA"

gfx.print "Tap the screen to finish.", 20, 460, "#AAFFAA"

gfx.print "Warning: the inclination recognizing sustem is not", 20, 100, "#FFAAAA"
gfx.print "working properly. A too high or low default inclination will cause ", 20, 75, "#FFAAAA"
gfx.print "malfunction of the game. In this case reset the game.", 20, 50, "#FFAAAA"


disp.clear
phone = new Sprite
phone.x = 700
phone.y = 320
phone.tint = "#AAFFAA"
phone.scale = -1
phone.image = deviceImg
disp.sprites.push phone

default = {} + phone
default.rotation = tiltyOffset * -94
default.x = 700
default.y = 320
default.tint = "#FFAAAA"
disp.sprites.push default

lastTime = time
while true
	setDt
	fade "on", 600, dt
	tilt = key.axis("Tilt Y") * 94
	if phone.rotation > tilt then
		phone.rotation = phone.rotation - (phone.rotation - tilt) / 8
	else if phone.rotation < tilt then
		phone.rotation = phone.rotation - (phone.rotation - tilt) / 8
	end if
	if mouse.button and mouse.x > 0 and mouse.x < 960 and mouse.y > 0 and mouse.y < 640 then
		tiltyOffset = -tilt / 94
		disp.clear
		goto "controlSettings"
	end if
	yield
end while