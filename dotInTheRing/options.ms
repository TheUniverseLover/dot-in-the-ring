clearGameScreen

gfx.print "Options", 400, 590, "#88EE88", "large"
gfx.print "Sensibility:", 60, 480, "#88EE88", "large"
gfx.print "Difficulty:", 60, 420, "#88EE88", "large"
gfx.print "Colors", 60, 360, "#88EE88", "large"
gfx.print "Control settings", 60, 300, "#88EE88", "large"
gfx.print "< Back to menu", 15, 20, "#88EE88", "large"
gfx.print "Difficulty level description:", 60, 200, "#FFCCCC"


changeSens = function()
	globals.sensibility = sensibility + 50
	if sensibility > 2000 then globals.sensibility = 200
	configs[6] = sensibility
	file.writeLines "configs.ms", configs
	showOpts
	wait 0.01
end function
difficulties = [practice, easy, normal, hard, impossible]
changeDiff = function()
	if difficulties.indexOf(difficulty) != difficulties.len - 1 then
		globals.difficulty = difficulties[difficulties.indexOf(difficulty) + 1]
	else
		globals.difficulty = practice
	end if
	globals.ringSize = difficulty.ringSize
	configs[7] = difficulty.name.lower
	file.writeLines("configs.ms", configs)
	showOpts
	wait 0.1
end function
changeColor = function()
	goto "colors"
	showOpts
end function
controlSettings = function()
	goto "controlSettings"
end function

showOpts = function()
	gfx.fillRect 310, 480, 80, 35, color.clear
	gfx.print sensibility, 310, 480, "#EE8888", "large"
	gfx.fillRect 290, 420, 200, 35, color.clear
	gfx.print difficulty.name, 290, 420, "#EE8888", "large"
	gfx.fillRect 40, 110, 960, 82, color.clear
	for l in range(0, difficulty.description.len - 1)
		gfx.print difficulty.description[l], 60, 170 - 20 * l, "#CCFFCC"
	end for
end function

showOpts
optionBtns = []
optionBtns.push newBounds(180, 470, 240, 55, @changeSens)
optionBtns.push newBounds(170, 410, 220, 55, @changeDiff)
optionBtns.push newBounds(120, 360, 120, 35, @changeColor)
optionBtns.push newBounds(200, 300, 320, 35, @controlSettings)
optionBtns.push newBounds(145, 20, 280, 35, @goto)

lastTime = time
while true
	setDt
	fade "on", 400, dt
	for b in optionBtns
		if b.contains(mouse) and mouse.button then
			b.onClick
		end if
	end for
	yield
end while