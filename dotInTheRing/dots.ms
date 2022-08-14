text.clear
/////////////////////Sprite functions///////////////

//Removes a sprite from one or more lists
Sprite.erase = function(from)
	if from == null then from = [disp.sprites]
	for l in from
		l.remove l.indexOf(self)
	end for
end function

//Shoots a bullet from a sprite's position
Sprite.shoot = function(target, bltSpeed, tint)
	if tint == null then tint = color.red
	b = new bullet
	b.x = self.x
	b.y = self.y
	b.tint = tint
	b.speed = bltSpeed
	b.rotation = 180 / pi * atan(target.y - b.y, target.x - b.x)
	b.vx = bltSpeed * cos(b.rotation * pi/180)
	b.vy = bltSpeed * sin(b.rotation * pi/180)
	b.source = self
	b.birthTime = time
	disp.sprites.push b
	bullets.push b
end function

//Creates a sprite's localBounds
Sprite.setBounds = function()
	self.localBounds = new Bounds
	self.localBounds.width = self.image.width
	self.localBounds.height = self.image.height
end function

/////////////// Defining particle class ////////////
particle = new Sprite
particle.vx = 0
particle.vy = 0
particle.scale = 0.8
particle.fadeSpeed = 1.05
particle.image = dotImage
particle.gravity = 0
particle.disp = display(4)
particle.update = function()
	self.x = self.x + self.vx * dt
	self.vx = self.vx / 1.05
	self.y = self.y + self.vy * dt
	if self.gravity == 0 then self.vy = self.vy / 1.05 else self.vy = self.vy - self.gravity * dt
	self.scale = self.scale / self.fadeSpeed
	if self.scale < 0.06 then
		self.erase [self.disp.sprites, particles]
		return
	end if
	if self.x > disp.scrollX + 1160 or self.x < self.disp.scrollX - 200 then
		self.erase [self.disp.sprites, particles]
	else if self.y > disp.scrollY + 840 or self.y < self.disp.scrollY - 200 then
		self.erase [self.disp.sprites, particles]
	end if
end function
updateParticles = function()
	for p in particles
		p.update
	end for
end function
setParticle = function(x, y, tint, rotation = 0, speed = 30, scale = 0.8, gravity = 0, image, disp)
	if disp == null then disp = display(4)
	if tint == null then tint = color.white
	p = new particle
	p.x = x
	p.y = y
	p.tint = tint
	p.rotation = rotation
	p.fadeSpeed = 1.03 + rnd * 0.05
	if difficulty == normal or difficulty == hard then p.fadeSpeed = 1.05 + rnd * 1.05
	if difficulty == impossible then p.fadeSpeed = 1.1 + rnd * 1.05
	p.vx = speed * cos(p.rotation * pi/180)
	p.vy = speed * sin(p.rotation * pi/180)
	p.scale = scale
	p.gravity = gravity
	if image != null then p.image = image
	p.disp = disp
	disp.sprites.push p
	particles.push p
end function
particles = []

//////////////////Defining bullet class//////////////
bullet = new Sprite
bullet.image = dotImage
bullet.vx = 0
bullet.vy = 0
bullet.speed = 0
bullet.tint = color.red
bullet.scale = 0.7
bullet.birthTime = 0
bullet.update = function()
	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt
	
	//Erases the bullet if i's far away from the screen
	//I gotta find a way to only erase them if they have crossed the screen, else they get erased even before moving.
	//I think I will add a second ring.
	if ringSize != null then
		if self.x > 1160 + ringSize/2 or self.x < -200 - ringSize/2 then
			self.erase [disp.sprites, bullets]
			return
		else if self.y > 840 + ringSize/2 or self.y < -200 - ringSize/2 then
			self.erase [disp.sprites, bullets]
			return
		end if
	else
		if self.x > 1440 or self.x < -480 or self.y > 960 or self.y < -320 then
			if not onScreen(self) then self.erase([disp.sprites, bullets])
		end if
	end if
	
	//Checks if the bullet hit any enemy
	if self.source == player then
		for e in enemies
			//if mathUtil.distance([self.x, self.y], [e.x, e.y]) > 20 then continue
			distX = pos(self.x - e.x)
			distY = pos(self.y - e.y)
			if distX > 20 then continue
			if distY > 20 then continue
			if distX < 20 and distY < 20 then
				self.erase [disp.sprites, bullets]
				e.erase [disp.sprites, enemies]
				for i in range(0, 5 + floor(rnd * 10))
					setParticle e.x + rnd * 30 - 15, e.y + rnd * 30 - 15,
					e.tint, self.rotation + rnd * 20 - 10, self.speed + rnd * 200
				end for
				if enemies.len == 0 then globals.endTime = time
				loseSnd.play 0.2, 0, 0.6
				giveScore 10
				if time - lastKillTime < player.reloadTime + 0.3 then
					giveScore 20
				end if
				globals.lastKillTime = time
				globals.screenShake = 15
				return
			end if
		end for
	end if
	
	//Checks if the bullet hit the player
	if self.source != player and player.tint != color.clear then
		//if mathUtil.distance([self.x, self.y], [player.x, player.y]) > 20 then return
		distX = pos(self.x - player.x)
		distY = pos(self.y - player.y)
		if distX > 20 then return
		if distY > 20 then return
		if distX < 20 and distY < 20 then
			self.erase [disp.sprites, bullets]
			if player.life == 1 then
				for i in range(0, 5 + floor(rnd * 10))
					setParticle player.x + rnd * 30 - 15, player.y + rnd * 30 - 15,
					player.tint, self.rotation + rnd * 20 - 10, self.speed + rnd * 180
				end for
			end if
			player.loseLife
		end if
	end if
end function

bullets = []
updateBullets = function()
	for b in bullets
		b.update
	end for
end function


///////////////Defining enemy class////////////
enemy.image = dotImage
enemy.lastShootTime = 0
enemy.reloadTime = 1
enemy.tint = enemy.reloadColor
enemy.update = function()
	if time > self.lastShootTime + self.reloadTime then
		if self.tint != self.color then self.tint = self.color
		
		//This 'if' makes the enemy wait a little before shooting
		if rnd * 150 > 149 then
			tiltx = key.axis("Tilt X")
			tilty = key.axis("Tilt Y") + tiltyOffset
			p = {"x":player.x, "y":player.y}
			if difficulty == impossible and rnd * 20 > 19 then
				bltSteps = mathUtil.distance([self.x, self.y], [player.x, player.y]) / (self.bulletSpeed * dt)
				p.x = p.x + tiltx * sensibility * dt * bltSteps
				p.y = p.y + tilty * sensibility * dt * bltSteps
			end if
			self.shoot p, self.bulletSpeed, self.bltColor
			self.lastShootTime = time
			self.tint = self.reloadColor
		end if
	end if
end function
enemies = []

setEnemy = function(x, y)
	e = new enemy
	e.x = x
	e.y = y
	e.setBounds
	disp.sprites.push e
	enemies.push e
end function

updateEnemies = function()
	for e in enemies
		e.update
	end for
end function

////////////////// Defining the player //////////////
player.image = dotImage
player.x = 480
player.y = 320
player.setBounds
player.lastShootTime = 0
player.reloadTime = 0.5
player.tint = player.color
if gameState == "starting" then player.life = difficulty.lifes
player.update = function()
	if self.tint == color.clear then return
	
	tiltx = key.axis("Tilt X") * axisx
	//We add tiltyOffset to the tilt so the player won't need to keep the phone down and flat
	//to stop their dot
	tilty = (key.axis("Tilt Y") + tiltyOffset) * axisy
	
	self.vx = tiltx * sensibility * dt
	self.vy = tilty * sensibility * dt
	
	if ringSize == null then
		if self.x > 1440 then self.x = -1440
		if self.x < -1440 then self.x = 1440
		if self.y > 960 then self.y = -960
		if self.y < -960 then self.y = 960
		self.x = self.x + self.vx
		self.y = self.y + self.vy
	else
		if mathUtil.distance([self.x + self.vx, self.y], [480, 320]) < ringSize / 2 then
			if tiltx > 0.04 or tiltx < -0.04 then self.x = self.x + self.vx
		end if
		if mathUtil.distance([self.x, self.y + self.vy], [480, 320]) < ringSize / 2 then
			if tilty > 0.04 or tilty < -0.04 then self.y = self.y + self.vy
		end if
	end if
	
	if time > self.lastShootTime + self.reloadTime then
		if self.tint != self.color then self.tint = self.color
		if mouseState == 0 then
			self.shoot {"x" : mouse.x + disp.scrollX, "y" : mouse.y + disp.scrollY}, self.bulletSpeed, self.bltColor
			self.lastShootTime = time
			self.tint = self.reloadColor
		end if
	end if
end function

//Loses a life
player.loseLife = function()
	self.life = self.life - 1
	loseSnd.play 0.2
	b = lifeBars[self.life]
	b.image = emptyBarImg
	for i in range(0, floor(rnd * 10) + 15)
		setParticle b.x + rnd * 100 - 50, b.y + rnd * 34 - 17,
		["#00FF00", "#33FF33", "#66FF66", "#99FF99", "#CCFFCC", "#FFFFFF"][floor(rnd*6)],
		-rnd*260 + 40, rnd*200, 0.2 + rnd * 0.6, 200, circle, gui
	end for
	if self.life == 0 then
		player.erase [disp.sprites]
		self.tint = color.clear
		globals.endTime = time
		loseSnd.play 1, 0, 0.2
	end if
	globals.screenShake = 50
end function
disp.sprites.push player


endTime = null
checkEnd = function()
	if player.tint == color.clear and enemies.len > 0 and time > endTime + 4 then
		load "lose.ms"; run
	end if
	if enemies.len == 0 and time > endTime + 4 then
		load "win.ms"; run
	end if
end function

setGame = function()
	setGameScreen
	disp.clear
	gui.clear
	
	globals.bullets = []
	globals.particles = []
	globals.enemies = []
	
	player.x = 480
	player.y = 320
	player.bulletSpeed = difficulty.playerBltSpeed
	enemy.bulletSpeed = difficulty.enemyBltSpeed
	disp.sprites.push player
	
	globals.lastKillTime = -1
	
	for i in range(0, difficulty.enemyQuantity-1)
		setEnemy floor(rnd * 960), floor(rnd * 640)
		e = enemies[-1]
		while mathUtil.distance([e.x, e.y], [player.x, player.y]) < ringSize / 2.3
			e.x = floor(rnd * 960)
			e.y = floor(rnd * 640)
		end while
	end for
	if player.life > curLife and gameState == "play" then curLife = player.life
	for b in range(0, curLife - 1)
		if player.life >= b + 1 then lifeBars[b].image = barImg
		gui.sprites.push lifeBars[b]
	end for
	
	buttons.clearButtons
	buttons.setButton 50, 600, triangle, 1, @setPauseScreen, gui, "#88EE88", -90
	gui.sprites.push counter
	counter.reset
	counter.startFrom = 3
	counter.show "#00FFFF"
	while counter.number != 0
		if mouse.y > 550 and mouse.x < 100 and mouse.button then goto("menu")
		globals.dt = time - lastTime
		globals.lastTime = time
		fade "on", 400, dt
		countdown
		lastTime = time
	end while
	counter.hide
	globals.lastTime = time
	
	top.print "Round: " + curRound, 830 - 15 * str(curRound).len, 600, "#88FF88"
end function

//Creating the life bars
if gameState == "starting" or player.life > curLife then
	curLife = player.life
	lifeBar = new Sprite
	lifeBar.image = emptyBarImg
	lifeBar.y = 70
	lifeBar.scale = 0.6
	lifeBars = []
	
	for x in range(0, curLife)
		b = new lifeBar
		b.x = (545 - 130 * (curLife/2)) + 130 * x
		gui.sprites.push b
		lifeBars.push b
	end for
end if

dt = function()
	return time - lastTime
end function

lastTime = time
main = function()
	while true
		setDt
		if gameState == "paused" then
			pauseMain
			continue
		end if
		globals.mouseState = mouseUtil.mouseState
		player.update
		updateScroll
		updateEnemies
		updateBullets
		updateParticles
		if mouse.y > 550 and mouse.x < 100 and mouse.button then goto("menu")
		checkEnd
	end while
end function

setGame
giveScore 0
gameState = "play"

main