text.clear


player.vx = key.axis("Tilt X") * sensibility
player.vy = (key.axis("Tilt Y") + tiltyOffset) * sensibility

stopPlayer = function()
	if mathUtil.distance([480, 320], [player.x + player.vx * dt,
	player.y + player.vy * dt]) < difficulty.ringSize / 2 then
		if player.vx != 0 then
			player.vx = player.vx / 1.1
			player.x = player.x + player.vx * dt
		end if
		if player.vy != 0 then
			player.vy = player.vy / 1.1
			player.y = player.y + player.vy * dt
		end if
	end if
end function

scrollVel = 0
lastTime = time
while top.scrollY < 640 * top.scale
	setDt
	top.scrollY = top.scrollY + scrollVel * dt
	if scrollVel < 800 then scrollVel = scrollVel + 30
	updateBullets
	updateParticles
	updateScroll
	stopPlayer
	yield
end while
timelist = file.readLines(difficulty.name+ ".ms")
file.writeLines difficulty.name+ ".ms", timelist+[endTime]


endTime = ceil(endTime)
top.clear "#00000088"
top.scrollY = -640
top.scale = 3
top.print "You Win.", 85, 100, "#88FF88", "large"
top.print "Next round", 90, 40, "#55FF55"
top.print "< Menu", 10, 10, "#55FF55", "small"
timestr = "Time: " + endTime
timeBonus = difficulty.roundTime - endTime

curRound = curRound + 1

lifeValue = ceil(10 * (1 - difficulty.lifes))
lifeBonus = difficulty.lifes - (difficulty.lifes - player.life)

bip = new Sound
bip.init 0.03, 1000, 0.2, Sound.sawtoothWave


//How much score a life is worh, base on difficulty level's lifes
scorestr = function()
	return "Score: " + score
end function
timeBonusStr = "Time bonus: " + timeBonus
top.print timestr, 170 - 10 * (timestr.len / 2), 85, "#FF5555", "small"
if timeBonus > 0 then top.print timeBonusStr, 170 - 10 * (timeBonusStr.len / 2), 75, "#FF5555", "small"
top.print scorestr, 170 - 10 * (scorestr.len / 2), 65, "#FF5555", "small"
scrollVel = 20

//How many bonus lifes the player got
bonusLife = 0
if score + timeBonus + (lifeBonus * lifeValue) > 1000 * floor(curLife - difficulty.lifes + 1) then
	bonusLife = floor((score - 1000 * floor(curLife - difficulty.lifes))/1000)
	bonusLife = bonusLife - bonusLifesAwarded
	if bonusLife < 0 then bonusLife = 0
end if


next = newBounds(480, 0, 450, 80)
menu = newBounds(110, 0, 200, 65)

lastTime = time
while scrollVel > 0
	setDt
	top.scrollY = top.scrollY + scrollVel
	scrollVel = scrollVel - 0.317
	next.y = 165 + top.scrollY * -1
	menu.y = 55 + top.scrollY * -1
	if next.contains(mouse) and mouse.button then
		score = score + timeBonus
		score = score + lifeBonus * lifeValue
		player.life = player.life + bonusLife
		bonusLifesAwarded = bonusLifesAwarded + bonusLife
		goto "dots.ms"
	else if menu.contains(mouse) and mouse.button then
		goto "menu.ms"
	end if
	updateBullets
	updateParticles
	stopPlayer
	yield
end while

lastTime = time
x = 215
y = 76
while true
	setDt
	if key.pressed("escape") then
		text.color = textColor
		exit
	end if
	if next.contains(mouse) and mouse.button then
		score = score + timeBonus
		score = score + lifeBonus * lifeValue
		top.print timeBonusStr, 170 - 10 * (timeBonusStr.len / 2), 75, "#FF5555", "small"
		top.print scorestr, 170 - 10 * (scorestr.len / 2), 65, "#FF5555", "small"
		player.life = player.life + bonusLife
		bonusLifesAwarded = bonusLifesAwarded + bonusLife
		goto "dots.ms"
	else if menu.contains(mouse) and mouse.button then
		goto "menu.ms"
	end if
	if time > 3 and timeBonus > 0 then
		if timeBonus > 4 then
			timeBonus = timeBonus - 5
			score = score + 5
			t = time
		else
			timeBonus = 0
			score = score + timeBonus
			t = time
		end if
		timeBonusStr = "Time bonus: " + timeBonus
		top.fillRect 0, 65, 960, 22, "#00000088"
		top.print timeBonusStr, 170 - 10 * (timeBonusStr.len / 2), 75, "#FF5555", "small"
		top.print scorestr, 170 - 10 * (scorestr.len / 2), 65, "#FF5555", "small"
		bip.play
	else if lifeBonus > 0 then
		if time - t > 0.3 and time - t < 0.8 then
			top.fillRect 0, 65, 960, 22, "#00000088"
			lifeBonusStr = "Life bonus: " + lifeBonus
			top.print lifeBonusStr, 170 - 10 * (lifeBonusStr.len / 2), 75, "#FF5555", "small"
			top.print scorestr, 170 - 10 * (scorestr.len / 2), 65, "#FF5555", "small"
		else if time - t > 0.5 then
			top.fillRect 0, 65, 960, 22, "#00000088"
			if time - t > 0.8 then
				bip.play
				lifeBonus = lifeBonus - 1
				score = score + lifeValue
				t = time
			end if
			lifeBonusStr = "Life bonus: " + lifeBonus
			top.print lifeBonusStr, 170 - 10 * (lifeBonusStr.len / 2), 75, "#FF5555", "small"
			top.print scorestr, 170 - 10 * (scorestr.len / 2), 65, "#FF5555", "small"
		end if
	else if bonusLife > 0 then
		if time - t > 0.3 and x == 215 then
			top.fillRect 70, 77, 140, 12, "#00000088"
			top.print "Bonus life!", 115, 75, "#00FF00", "small"
		end if
		if time - t > 0.3 then
			top.drawImage barImg, x, y, barImg.width / 8, barImg.height / 8
			x = x + barImg.width / 7
			if x > 300 then
				x = 215
				y = y - 15
			end if
			t = time
			player.life = player.life + 1
			bonusLifesAwarded = bonusLifesAwarded + 1
			bonusLife = bonusLife - 1
		end if
	end if
	updateBullets
	updateParticles
	stopPlayer
	yield
end while