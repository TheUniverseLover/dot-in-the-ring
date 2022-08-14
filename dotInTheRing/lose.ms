text.clear

lastTime = time
scrollVel = 0
while top.scrollY < 640 * top.scale
	setDt
	top.scrollY = top.scrollY + scrollVel * dt
	if scrollVel < 800 then scrollVel = scrollVel + 20
	updateBullets
	updateParticles
	yield
end while


top.clear "#00000088"
top.scrollY = -640
top.scale = 3
top.print "You lose.", 75, 100, "#88FF88", "large"
top.print "Again", 40, 60, "#55FF55"
top.print "Menu", 220, 60, "#55FF55"
scorestr = "Score: " + score
top.print scorestr, 170 - 10 * (scorestr.len / 2), 90, "#FF5555", "small"
roundstr = "Rounds won: " + (curRound - 1)
top.print roundstr, 170 - 10 * (roundstr.len / 2), 80, "#FF5555", "small"
scrollVel = 20

again = function()
	buttons.clearButtons
	load "dots.ms"; run
end function

againBtn = new Bounds
againBtn.width = 240
againBtn.height = 80
againBtn.x = 220

menu = newBounds(750, 0, 200, 80)

score = 0
lastTime = time
curRound = 1
bonusLifesAwarded = 0
gameState = "starting"
while scrollVel > 0
	setDt
	top.scrollY = top.scrollY + scrollVel
	scrollVel = scrollVel - 0.317
	againBtn.y = 225 + (top.scrollY * -1)
	menu.y = 225 + (top.scrollY * -1)
	if againBtn.contains(mouse) and mouse.button then
		goto "dots"
	else if menu.contains(mouse) and mouse.button then
		goto "menu"
	end if
	updateBullets
	updateParticles
	yield
end while

lastTime = time
while true
	setDt
	if key.pressed("escape") then
		text.color = textColor
		exit
	end if
	if againBtn.contains(mouse) and mouse.button then
		goto "dots"
	else if menu.contains(mouse) and mouse.button then
		goto "menu"
	end if
	updateBullets
	updateParticles
end while