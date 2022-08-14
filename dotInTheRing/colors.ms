clearGameScreen
setGameScreen

d.x = 480
d.y = 320
d.tint = player.color
d.bltColor = player.bltColor
d.color = player.color
d.reloadColor = player.reloadColor
d.shotTime = 0
disp.sprites.push d

e = new Sprite
e.image = dotImage
e.x = 890
e.y = 400
e.tint = enemy.color
e.bltColor = "#FF0000"
e.color = enemy.color
e.reloadColor = enemy.reloadColor
e.shotTime = 0
disp.sprites.push e

b = new Sprite
b.image = dotImage
b.scale = 0.7
b.tint = enemy.bltColor
b.y = 390
b.x = 840
disp.sprites.push b

pb = new Sprite
pb.image = dotImage
pb.x = 530
pb.y = 330
pb.scale = 0.7
pb.tint = player.bltColor
disp.sprites.push pb


gfx.print "Colors", 405, 600
gfx.print "< Back to options", 15, 10, "#AAEEAA", "large"
gfx.print "Default", 800, 10, "#AAEEAA", "large"
btns = [
["Player's color", 40, 550, player.color, player, "color"],
["Player's reloading color", 40, 500, player.reloadColor, player, "reloadColor"],
["Player's bullets color", 40, 450, player.bltColor, player, "bltColor"],
["Enemies' color", 40, 400, enemy.color, enemy, "color"],
["Enemies' reloading color", 40, 350, enemy.reloadColor, enemy, "reloadColor"],
["Enemies' bullets color", 40, 300, enemy.bltColor, enemy, "bltColor"]]
selectedBtn = btns[0]

showBtn = function(b)
	if selectedBtn == b then x = "> " else x = null
	if selectedBtn == b then c = "#2f2f2f" else c = "#282828"
	gfx.fillRect 40, b[2], 400, 50, c
	gfx.print x + b[0], b[1], b[2], b[3]
end function

for btn in btns
	showBtn btn
end for

gfx.drawImage file.loadImage("colorWheel.png"), 40, 70
knob = new Sprite
knob.x = 150
knob.y = 180
knob.scale = 1.5
knob.image = file.loadImage("knob.png")
disp.sprites.push knob


lastTime = time
while display(1).pixel != "#00000000"
	setDt
	fade "on", 400, dt
end while

checkMouse = function()
	if mouse.button then
		if mathUtil.distance([150, 180], [x, y]) < 110 then
			clr = gfx.pixel(x, y)
			selectedBtn[3] = clr
			knob.x = x
			knob.y = y
			selectedBtn[4][selectedBtn[5]] = clr
			showBtn selectedBtn
		else if x > 40 and x < 400 and y > 300 and y < 570 then
			prev = selectedBtn
			globals.selectedBtn = btns[6-floor((y - 300) / 50)-1]
			showBtn prev
			showBtn selectedBtn
		else if mouse.x < 400 and mouse.y < 30 then
			goto "options"
		else if mouse.x > 780 and mouse.y < 30 then
			for c in range(0, 5)
				btns[c][4][btns[c][5]] = configs[c]
				btns[c][3] = configs[c]
				showBtn btns[c]
			end for
		end if
	end if
end function

while true
	x = mouse.x
	y = mouse.y
	fade "on", 600, dt
	checkMouse
	if time > d.shotTime + 1 then
		d.tint = player.color
		if time > d.shotTime + 3 then
			pb.x = d.x
			pb.y = d.y
			d.shotTime = time
		end if
	else
		d.tint = player.reloadColor
	end if
	pb.tint = player.bltColor
	if time > e.shotTime + 1 then
		e.tint = enemy.color
		if time > e.shotTime + 3 then
			b.x = e.x
			b.y = e.y
			e.shotTime = time
		end if
	else
		e.tint = enemy.reloadColor
	end if
	b.tint = enemy.bltColor
	b.x = b.x - 6
	b.y = b.y - 2
	pb.x = pb.x + 6
	pb.y = pb.y + 0.7
	yield
end while