text.clear
gfx.clear

gfx.print "Adjust game controls", 60, 600, "#88EE88", "large"
gfx.print "Device's default inclination", 60, 500, "#88EE88", "large"
gfx.print "Invert horizontal controls:", 60, 450, "#88EE88", "large"
gfx.print "Invert vertical controls:", 60, 400, "#88EE88", "large"
gfx.print "Back to options", 60, 40, "#88EE88", "large"

if axisx == -1 then
	gfx.print "Yes", 620, 450, "#88EE88", "large"
else
	gfx.print "No", 620, 450, "#88EE88", "large"
end if

if axisy == -1 then
	gfx.print "Yes", 580, 400, "#88EE88", "large"
else
	gfx.print "No", 580, 400, "#88EE88", "large"
end if

inclination = newBounds(340, 515, 560, 40)
invertx = newBounds(370, 455, 620, 60)
inverty = newBounds(340, 405, 560, 60)
options = newBounds(230, 75, 560, 60)


lastTime = time
while true
	setDt
	fade "on", 600, dt
	if mouse.button then
		if inclination.contains(mouse) then
			goto "inclination"
		else if invertx.contains(mouse) then
			gfx.fillRect 620, 450, 100, 30, color.clear
			if axisx == 1 then
				axisx = -1
				gfx.print "Yes", 620, 450, "#88EE88", "large"
			else
				axisx = 1
				gfx.print "No", 620, 450, "#88EE88", "large"
			end if
		else if inverty.contains(mouse) then
			gfx.fillRect 580, 400, 100, 30, color.clear
			if axisy == 1 then
				axisy = -1
				gfx.print "Yes", 580, 400, "#88EE88", "large"
			else
				axisy = 1
				gfx.print "No", 580, 400, "#88EE88", "large"
			end if
		else if options.contains(mouse) then
			goto "options"
		end if
		wait 0.1
	end if
end while