//Some functions that I need sometimes to deal with the mouse.


//If the 'v' parameter is null: returns 1 if the mouse was just
//pressed, 2 if it's held pressed, 0 if it was just released and
//-1 if it's released. Use 'v' to check if the mouse is in a 
//particular state (e. g. set it to 0 to ask if it was just released).
wasPressed = 0
mouseState = function(v)
	r = 0
	if not mouse.button and not mouseUtil.wasPressed then
		r = -1
	else if mouse.button and not mouseUtil.wasPressed then
		r = 1
		mouseUtil.wasPressed = 1
	else if mouse.button and mouseUtil.wasPressed then
		r = 2
	else if not mouse.button and mouseUtil.wasPressed then
		r = 0
		mouseUtil.wasPressed = 0
	end if
	if v == null then return r
	return v == r
end function

checkMouseState = function()
	globals.mouseState = mouseState
end function