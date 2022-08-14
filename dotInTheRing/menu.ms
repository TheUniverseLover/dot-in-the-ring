clearGameScreen
display(7).color = "#152615"
gfx.clear
gfx.drawEllipse 480 - 300, 320 - 300, 600, 600, "#bbffff", 10
gfx.scrollX = 0
gfx.scrollY = 0
disp.scrollX = 0
disp.scrollY = 0

gfx.fillRect 90, 300, 100, 60, display(7).color
gfx.fillRect 700, 300, 100, 60, display(7).color
gfx.fillRect 390, 560, 180, 100, display(7).color
gfx.print "Start", 730, 315, "#88EE88", "large"
gfx.print "Quit", 110, 315, "#88EE88", "large"
gfx.print "Options", 410, 600, "#88EE88", "large"

curRound = 1
bonusLifesAwarded = 0

d = new Sprite
d.x = 480
d.y = 320
d.image = dotImage
d.update = function()
	tiltx = key.axis("Tilt X") * axisx
	tilty = (key.axis("Tilt Y") + tiltyOffset) * axisy
	dx = tiltx * sensibility * dt
	dy = tilty * sensibility * dt
	// if mathUtil.distance([self.x+dx, self.y+dy], [480, 320]) < ringSize / 2 or
	// self.y+dy > 300 and self.y+dy < 360 or self.x+dx > 390 and self.x+dx < 570 and self.y+dy > 500 then
	// if tiltx > 0.04 or tiltx < -0.04 then self.x = self.x + dx
	// if tilty > 0.04 or tilty < -0.04 then self.y = self.y + dy
	// end if
	if mathUtil.distance([self.x+dx, self.y], [480, 320]) < 300 or
	self.y+dy > 300 and self.y+dy < 360 or self.x+dx*2 > 390 and self.x+dx*2 < 570 and self.y+dy > 500 then
		if tiltx > 0.04 or tiltx < -0.04 then self.x = self.x + dx
	end if
	if mathUtil.distance([self.x, self.y+dy], [480, 320]) < 300 or
	self.y+dy*2 > 300 and self.y+dy*2 < 360 or self.x+dx > 380 and self.x+dx < 580 and self.y+dy*2 > 500 then
		if tilty > 0.04 or tilty < -0.04 then self.y = self.y + dy
	end if
	
	if self.x < -40 then
	clear
	exit
	else if self.x > 1010 then
		globals.gameState = "starting"
		globals.score = 0
		goto "dots"
	else if self.y > 690 then
		goto "options"
	else
		fade "on", 400, dt
	end if
end function
disp.sprites.push d

lastTime = time
while top.pixel != "#00000000"
	setDt
	fade "on", 500, dt
end while

lastTime = time
while true
	setDt
	d.update
end while
