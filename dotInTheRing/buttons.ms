//This library lets you create buttons using the setButton function.
//To use it you have to import "mouseUtil" and add the 'checkMouseState'
//function on your main loop.
import "mouseUtil"

button = new Sprite
button.onClick = null
button.setBounds = function()
	self.localBounds = new Bounds
	if self.image != null then self.localBounds.width = self.image.width
	if self.image != null then self.localBounds.height= self.image.height
end function
button.check = function()
	if self.followDisp then
		x = mouse.x + self.disp.scrollX
		y = mouse.y + self.disp.scrollY
	else
		x = mouse.x - self.disp.scrollX
		y = mouse.y - self.disp.scrollY
	end if
	
	if self.contains({"x":x, "y":y}) and mouseState == 1 then
		self.onClick
	end if
end function
setButton = function(x, y, image, scale, onClick, sprDisp, tint, rotation = 0, followDisp = 1)
	if sprDisp == null then sprDisp = display(4)
	b = new button
	b.x = x
	b.y = y
	b.image = image
	b.scale = scale
	if tint != null then b.tint = tint
	b.rotation = rotation
	b.setBounds
	b.onClick = @onClick
	b.disp = sprDisp
	b.followDisp = followDisp
	sprDisp.sprites.push b
	buttons.push b
end function
buttons = []
checkButtons = function()
	for b in buttons
		b.check
	end for
end function
clearButtons = function()
	for b in buttons
		if b.disp.sprites.indexOf(b) != null then b.disp.sprites.remove b.disp.sprites.indexOf(b)
		globals.buttons.buttons.remove buttons.indexOf(b)
	end for
end function