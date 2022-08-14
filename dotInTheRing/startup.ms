//Here we will draw the images we will need using the gfx display
import "mouseUtil"
import "buttons"
import "mathUtil"
clear

disp = display(4)
display(2).mode = displayMode.sprite
gui = display(2)
gui.clear
display(1).mode = displayMode.pixel
top = display(1)
top.clear color.black
tiltyOffset = 0.65
//if tiltyOffset < 0 then tiltyOffset = tiltyOffset * -1

posOrNeg = function(v)
	if v < 0 then return -1
	if v > 0 then return 1
	return 0
end function
pos = function(v)
	if v < 0 then return v * -1
	return v
end function
neg = function(v)
	if v > 0 then return v * -1
	return v
end function

screenShake = 0
updateScroll = function()
	disp.scrollX = player.x - 480
	disp.scrollY = player.y - 320
	if screenShake > 0 then
		disp.scrollX = disp.scrollX + rnd * screenShake
		disp.scrollY = disp.scrollY + rnd * screenShake
		globals.screenShake = screenShake - 2
	end if
	gfx.scrollX = disp.scrollX
	gfx.scrollY = disp.scrollY
end function


configs = file.readLines("configs.ms")
gameState = "play"
axisx = 1
axisy = 1
score = 0
lastKillTime = 0 //We'll use this variable to detect double/triple/etc kills
sensibility = 1000
curRound = 1
curLife = 3
bonusLifesAwarded = 0
giveScore = function(scr)
	globals.score = score + scr
	top.fillRect 380, 610, 200, 30, color.clear
	top.print "Score: " + score, 380, 610, "#88EE88", "large"
end function
//Difficulty levels
newDifficulty = function(name, ringSize, enemyQuantity, enemyReloadTime, playerReloadTime, lifes, description, playerBltSpeed=100, enemyBltSpeed=100, roundTime)
	l = {}
	l.name = name
	l.ringSize = ringSize
	l.enemyQuantity = enemyQuantity
	l.enemyReloadTime = enemyReloadTime
	l.playerReloadVel = playerReloadTime
	l.lifes = lifes
	l.description = description
	l.playerBltSpeed = playerBltSpeed
	l.enemyBltSpeed = enemyBltSpeed
	l.roundTime = roundTime
	return l
end function
practice = newDifficulty("Practice", null, 4, 1, 0.1, 5, [
"No ring, four enemies, player reloads faster than enemies,",
"five lives. Player's bullets are faster than enemies'."], 100, 50, 30)
easy = newDifficulty("Easy", null, 15, 0.5, 0.2, 4, [
"No ring, fifteen enemies, player reloads faster than enemies,",
"four lives. Player's bullets are faster than enemies'."], 100, 70, 40)
normal = newDifficulty("Normal", 620, 20, 0.5, 0.5, 3, [
"Big ring, twenty enemies, player reloads as fast as enemies,",
"three lives. Player's bullets have same speed as enemies'."], 100, 100, 50)
hard = newDifficulty("Hard", 480, 20, 0.3, 0.3, 2, [
"Medium ring, twenty enemies, player reloads as fast as enemies,",
"two lives. Player's bullets have same speed as enemies' (120/s)."], 120, 120, 60)
impossible = newDifficulty("Impossible", 380, 30, 0.2, 0.3, 1, [
"Small ring, thirty enemies, player reloads slower than enemies,",
"one life. Sometimes enemies will calculate player's movement and",
"aim at player's future position. Enemies' bullets are faster than",
"player's (120 < 140)."], 120, 140, 70)
difficulty = globals[configs[7]]
ringSize = difficulty.ringSize

textColor = text.color
//text.color = color.clear

tones = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "A", "B", "C", "D", "E", "F"]
gfx.clear

//Draws the image we will use for the life bars
for i in range(0, 5)
	gfx.fillRect 10, 10 + i*5, 190, 70 - i*10, "#" + str(tones[i*2 + 2]) * 2 + "FF" + str(tones[i*2 + 2]) * 2
end for
gfx.drawRect 5, 5, 190, 80, "#555555", 10
gfx.drawRect 8, 8, 185, 75, "#778877", 5
barImg = gfx.getImage(0, 0, 215, 90)
gfx.fillRect 10, 10, 180, 70, "#444444"
emptyBarImg = gfx.getImage(0, 0, 215, 90)

//Draws the image we will use for the player, the enemies and the bullets
gfx.clear
gfx.fillEllipse 0, 0, 30, 30, "#aaaaaaaa"
gfx.fillEllipse 1, 1, 28, 28, "#dddddddd"
gfx.fillEllipse 3, 3, 24, 24, "#f5f5f5f5"
gfx.fillEllipse 6, 6, 18, 18
dotImage = gfx.getImage(0, 0, 30, 30)
gfx.clear

//Draw the image we see when we are defining the device's default inclination (on the game's configuration options)
gfx.drawEllipse 3, -10, 30, 30, "#AAAAAA", 7
gfx.drawEllipse 400, -10, 30, 30, "#AAAAAA", 7
gfx.line 21, 20, 415, 20, "#AAAAAA", 7
gfx.line 350, 23, 390, 23, "#AAAAAA", 7
gfx.line 8, 3, 426, 3, "#FFFFFF", 7
gfx.fillRect 21, 7, 390, 9, color.clear
deviceImg = gfx.getImage(0, 0, 434, 37)
gfx.clear

circle = file.loadImage("circle.png")
arrowImg = file.loadImage("arrow.png")
triangle = file.loadImage("triangle.png")

newBounds = function(x, y, width, height, onClick)
	b = new Bounds
	b.x = x
	b.y = y
	b.width = width
	b.height = height
	b.onClick = @onClick
	return b
end function

onScreen = function(spr)
	if spr.x + spr.image.width/2 > disp.scrollX and spr.x - spr.image.width/2 < disp.scrollX + 960 then
		if spr.y + spr.image.height/2 > disp.scrollY and spr.y - spr.image.height/2 < disp.scrollY + 640 then
			return 1
		end if
	end if
	return 0
end function

//Draws the ring, clears the displays, resets dipslays' scroll
setGameScreen = function()
	display(7).color = "#152615"
	gfx.clear
	gfx.drawEllipse 480 - ringSize / 2, 320 - ringSize / 2, ringSize, ringSize, "#bbffff", 10
	gfx.scrollX = 0
	gfx.scrollY = 0
	disp.scrollX = 0
	disp.scrollY = 0
end function

//The 'clear' function changes display(1)'s mode. This one cleans
//the screen without affecting the displays' modes.
clearGameScreen = function()
	text.clear
	disp.clear
	gui.clear
	gfx.clear
end function

setPauseScreen = function()
	globals.gameState = "paused"
	globals.cntd = 0
	top.clear "#00000099"
	top.print "Paused", 410, 600, "#AAFFAA", "large"
	
	top.print "Difficulty level description:", 20, 100, "#FFAAAA"
	for l in range(0, difficulty.description.len - 1)
		top.print difficulty.description[l], 20, 80 - 20 * l, "#FFAAAA"
	end for
	
	backToGame = function()
		top.clear
		if cntd then
			counter.reset
			counter.startFrom = 3
			counter.show
			counter.beginTime = time
			while counter.number != 0
				setDt
				countdown
			end while
			counter.hide
		end if
		giveScore 0
		globals.gameState = "play"
	end function
	
	setCountdown = function()
		top.fillRect 370, 340, 240, 20, "#00000099"
		if not cntd then
			top.print char(9745) +  "  With countdown", 370, 340, "#AAFFAA"
			globals.cntd = 1
		else
			top.print char(9744) +  "  With countdown", 370, 340, "#AAFFAA"
			globals.cntd = 0
		end if
		wait 0.1
	end function
	
	top.print "Back to menu", 360, 470, "#88FF88", "large"
	top.print "Continue", 400, 400, "#88FF88", "large"
	top.print char(9744) + "  With countdown", 370, 340, "#AAFFAA"
	
	globals.menu = newBounds(480, 490, 240, 40, @goto)
	globals.resume = newBounds(480, 420, 160, 40, @backToGame)
	globals.withCountdown = newBounds(480, 350, 240, 40, @setCountdown)
end function
pauseMain = function()
	for b in [menu, resume, withCountdown]
		if b.contains(mouse) and mouse.button then
			b.onClick
		end if
	end for
end function

fade = function(to, vel, dt = 1)
	if to == "on" then to = -1
	if to == "off" then to = 1
	
	clr = color.toList(display(1).pixel)
	for i in range(0, 2)
		if clr[i] != 0 then clr[i] = 0
	end for
	clr[3] = clr[3] + vel * to * dt
	if to == -1 and clr[3] < 0 then clr[3] = 0
	if to == 1 and clr[3] > 255 then clr[3] = 255
	display(1).clear color.fromList(clr)
end function

digitSheet = file.loadImage("digits.png")
digits = []
for y in range(0, 1)
	for x in range(0, 9)
		digits.push digitSheet.getImage(10 * x, 18 * y, 10, 18)
	end for
end for

counter = new Sprite
counter.x = 480
counter.y = 320
counter.scale = 10
counter.startFrom = 9
counter.number = null
counter.font = 1
counter.beginTime = null
counter.reset = function()
	self.number = null
	self.image = null
	self.startFrom = 9
	self.beginTime = null
end function
counter.hide = function()
	self.tint = color.clear
end function
counter.show = function(clr)
	if clr == null then clr = color.white
	self.tint = clr
	beep.play
end function

countdown = function()
	if counter.beginTime == null then counter.beginTime = time
	if counter.number == null then counter.number = counter.startFrom
	if floor(time - counter.beginTime + counter.number - counter.startFrom+ 1) > 1then
		counter.number = counter.number - 1
		beep.play
	end if
	counter.image = digits[counter.number + 10*counter.font]
end function


loseSnd = new Sound
loseSnd.init(0.2, 10, [1, 0], Sound.noiseWave)
beep = new Sound
beep.init(0.2, 200, 1, Sound.sineWave)

setDt = function()
	globals.dt = time - lastTime
	globals.lastTime = time
end function


player = new Sprite
player.color = "#EE00EE"
player.reloadColor = "#AA00AA"
player.bltColor = "#00FF00"

enemy = new Sprite
enemy.color = "#FFFFFF"
enemy.bltColor = "#FF0000"
enemy.reloadColor = "#EEAAAA"


goto = function(path = "menu")
	globals.lastTime = time
	while top.pixel != "#000000FF"
		setDt
		fade "off", 600, dt
	end while
	load path; run
end function
goto "menu"