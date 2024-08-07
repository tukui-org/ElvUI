--[[---------------------------------------------------------------------------------
  General Library providing an alternate StartMoving() that allows you to
  specify a number of frames to snap-to when moving the frame around

  Example Usage:

	<OnLoad>
		this:RegisterForDrag("LeftButton")
	</OnLoad>
	<OnDragStart>
		StickyFrames:StartMoving(this, {WatchDogFrame_player, WatchDogFrame_target, WatchDogFrame_party1, WatchDogFrame_party2, WatchDogFrame_party3, WatchDogFrame_party4},3,3,3,3)
	</OnDragStart>
	<OnDragStop>
		StickyFrames:StopMoving(this)
		StickyFrames:AnchorFrame(this)
	</OnDragStop>

------------------------------------------------------------------------------------
This is a modified version by Elv and Simpy for ElvUI
------------------------------------------------------------------------------------]]

local MAJOR, MINOR = "LibSimpleSticky-1.0", 4
local StickyFrames, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not StickyFrames then return end

local _G = _G
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local GetCursorPosition = GetCursorPosition
local IsShiftKeyDown = IsShiftKeyDown
local WorldFrame = WorldFrame
local UIParent = UIParent
local tostring = tostring
local ipairs = ipairs

--[[---------------------------------------------------------------------------------
  Class declaration, along with a temporary table to hold any existing OnUpdate
  scripts.
------------------------------------------------------------------------------------]]

StickyFrames.data = StickyFrames.data or {}
StickyFrames.scripts = StickyFrames.scripts or {}
StickyFrames.sticky = StickyFrames.sticky or {}
StickyFrames.rangeX = 15
StickyFrames.rangeY = 15

--[[---------------------------------------------------------------------------------
  StickyFrames:StartMoving() - Sets a custom OnUpdate for the frame so it follows
  the mouse and snaps to the frames you specify

	frame:	 	The frame we want to move.  Is typically "this"

	frameList: 	A integer indexed list of frames that the given frame should try to
				stick to.  These don't have to have anything special done to them,
				and they don't really even need to exist.  You can inclue the
				moving frame in this list, it will be ignored.  This helps you
				if you have a number of frames, just make ONE list to pass.

				{WatchDogFrame_player, WatchDogFrame_party1, .. WatchDogFrame_party4}

	left:		If your frame has a tranparent border around the entire frame
				(think backdrops with borders).  This can be used to fine tune the
				edges when you're stickying groups.  Refers to any offset on the
				LEFT edge of the frame being moved.

	top:		same
	right:		same
	bottom:		same
------------------------------------------------------------------------------------]]

function StickyFrames:StartMoving(frame, frameList, left, top, right, bottom, anchor)
	local aX, aY = frame:GetCenter()

	local x, y
	if anchor and anchor ~= frame then
		local bX, bY = anchor:GetCenter()
		x, y = aX - bX, aY - bY
	else
		local cx, cy = GetCursorPosition()
		local aS = frame:GetEffectiveScale()
		x, y = (aX * aS) - cx, (aY * aS) - cy
	end

	if not self.data[frame] then
		self.data[frame] = {}
	end

	local info = self.data[frame]
	info.frameList = frameList
	info.left = left
	info.top = top
	info.right = right
	info.bottom = bottom
	info.xoffset = x
	info.yoffset = y
	info.anchor = anchor

	self.scripts[frame] = frame:GetScript("OnUpdate")
	frame:SetScript("OnUpdate", self.GetUpdateFunc)
end

--[[---------------------------------------------------------------------------------
  This stops the OnUpdate, leaving the frame at its last position.  This will
  leave it anchored to UIParent.  You can call StickyFrames:AnchorFrame() to
  anchor it back "TOPLEFT" , "TOPLEFT" to the parent.
------------------------------------------------------------------------------------]]

function StickyFrames:StopMoving(frame)
	frame:SetScript("OnUpdate", self.scripts[frame])
	self.scripts[frame] = nil
	self.data[frame] = nil

	local sticky = StickyFrames.sticky[frame]
	if sticky then
		StickyFrames.sticky[frame] = nil
		return true, sticky
	else
		return false, nil
	end
end

--[[---------------------------------------------------------------------------------
  This can be called in conjunction with StickyFrames:StopMoving() to anchor the
  frame right back to the parent, so you can manipulate its children as a group
  (This is useful in WatchDog)
------------------------------------------------------------------------------------]]

function StickyFrames:AnchorFrame(frame)
	local xA,yA = frame:GetCenter()
	local parent = frame:GetParent() or UIParent
	local xP,yP = parent:GetCenter()
	local sA,sP = frame:GetEffectiveScale(), parent:GetEffectiveScale()

	xP,yP = (xP*sP) / sA, (yP*sP) / sA

	local xo,yo = (xP - xA)*-1, (yP - yA)*-1

	frame:ClearAllPoints()
	frame:SetPoint("CENTER", parent, "CENTER", xo, yo)
end

--[[---------------------------------------------------------------------------------
  Internal Functions -- Do not call these.
------------------------------------------------------------------------------------]]

function StickyFrames:GetUpdateFunc() -- self is frame
	local data = StickyFrames.data[self]
	if not data then return end

	local x, y = GetCursorPosition()
	local s = self:GetEffectiveScale()
	if s > 0 then x, y = x / s, y / s end

	self:ClearAllPoints()
	self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x + data.xoffset, y + data.yoffset)

	StickyFrames.sticky[self] = nil

	local frameList = not IsShiftKeyDown() and (not data.anchor or data.anchor == self) and data.frameList
	if frameList then
		local left, right, top, bottom = data.left, data.right, data.top, data.bottom
		for _, other in ipairs(frameList) do
			if (self ~= other and self ~= other:GetParent() and other:IsVisible()) and StickyFrames:SnapFrame(self, other, left, top, right, bottom) then
				StickyFrames.sticky[self] = other
				break
			end
		end
	end
end

--[[---------------------------------------------------------------------------------
  Internal debug function.
------------------------------------------------------------------------------------]]

function StickyFrames:debug(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00StickyFrames: |r"..tostring(msg))
end

--[[---------------------------------------------------------------------------------
  This is called when finding an overlap between two sticky frame.  If frameA is near
  a sticky edge of frameB, then it will snap to that edge and return true.  If there
  is no sticky edge collision, will return false so we can test other frames for
  stickyness.
------------------------------------------------------------------------------------]]
function StickyFrames:SnapFrame(frameA, frameB, left, top, right, bottom)
	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale()
	local xA, yA = frameA:GetCenter()
	local xB, yB = frameB:GetCenter()
	local hA, wA = frameA:GetHeight() * 0.5, frameA:GetWidth() * 0.5

	local newX, newY = xA, yA

	if not left then left = 0 end
	if not top then top = 0 end
	if not right then right = 0 end
	if not bottom then bottom = 0 end

	-- Lets translate B's coords into A's scale
	if not xB or not yB or not sB or not sA or not sB then return end
	xB, yB = (xB*sB) / sA, (yB*sB) / sA

	-- Grab the edges of each frame, for easier comparison
	local lA, tA, rA, bA = frameA:GetLeft(), frameA:GetTop(), frameA:GetRight(), frameA:GetBottom()
	local lB, tB, rB, bB = frameB:GetLeft(), frameB:GetTop(), frameB:GetRight(), frameB:GetBottom()
	local snap = nil

	-- Translate into A's scale
	lB, tB, rB, bB = (lB * sB) / sA, (tB * sB) / sA, (rB * sB) / sA, (bB * sB) / sA

	if (bA <= tB and bB <= tA) then
		-- Horizontal Centers
		if xA <= (xB + StickyFrames.rangeX) and xA >= (xB - StickyFrames.rangeX) then
			newX = xB
			snap = true
		end

		-- Interior Left
		if lA <= (lB + StickyFrames.rangeX) and lA >= (lB - StickyFrames.rangeX) then
			newX = lB + wA
			if frameB == UIParent or frameB == WorldFrame or frameB == _G.ElvUIParent then
				newX = newX + 4
			end
			snap = true
		end

		-- Interior Right
		if rA <= (rB + StickyFrames.rangeX) and rA >= (rB - StickyFrames.rangeX) then
			newX = rB - wA
			if frameB == UIParent or frameB == WorldFrame or frameB == _G.ElvUIParent then
				newX = newX - 4
			end
			snap = true
		end

		-- Exterior Left to Right
		if lA <= (rB + StickyFrames.rangeX) and lA >= (rB - StickyFrames.rangeX) then
			newX = rB + (wA - left)

			snap = true
		end

		-- Exterior Right to Left
		if rA <= (lB + StickyFrames.rangeX) and rA >= (lB - StickyFrames.rangeX) then
			newX = lB - (wA - right)
			snap = true
		end
	end

	if (lA <= rB and lB <= rA) then
		-- Vertical Centers
		if yA <= (yB + StickyFrames.rangeY) and yA >= (yB - StickyFrames.rangeY) then
			newY = yB
			snap = true
		end

		-- Interior Top
		if tA <= (tB + StickyFrames.rangeY) and tA >= (tB - StickyFrames.rangeY) then
			newY = tB - hA
			if frameB == UIParent or frameB == WorldFrame or frameB == _G.ElvUIParent then
				newY = newY - 4
			end
			snap = true
		end

		-- Interior Bottom
		if bA <= (bB + StickyFrames.rangeY) and bA >= (bB - StickyFrames.rangeY) then
			newY = bB + hA
			if frameB == UIParent or frameB == WorldFrame or frameB == _G.ElvUIParent then
				newY = newY + 4
			end
			snap = true
		end

		-- Exterior Top to Bottom
		if tA <= (bB + StickyFrames.rangeY + bottom) and tA >= (bB - StickyFrames.rangeY + bottom) then
			newY = bB - (hA - top)
			snap = true
		end

		-- Exterior Bottom to Top
		if bA <= (tB + StickyFrames.rangeY - top) and bA >= (tB - StickyFrames.rangeY - top) then
			newY = tB + (hA - bottom)
			snap = true
		end
	end

	if snap then
		frameA:ClearAllPoints()
		frameA:SetPoint("CENTER", UIParent, "BOTTOMLEFT", newX, newY)
		return true
	end
end
