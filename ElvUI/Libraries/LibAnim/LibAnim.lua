-- LibAnim by Hydra
local Version = 2.01

if (_LibAnim and _LibAnim >= Version) then
	return
end

local cos = cos
local sin = sin
local pairs = pairs
local floor = floor
local tinsert = tinsert
local tremove = tremove
local strlower = strlower
local Updater = CreateFrame("StatusBar")
local Texture = Updater:CreateTexture()
local Text = Updater:CreateFontString()
local AnimTypes = {}
local UpdateFuncs = {}
local Callbacks = {["onplay"] = {}, ["onpause"] = {}, ["onresume"] = {}, ["onstop"] = {}, ["onreset"] = {}, ["onfinished"] = {}}

-- Update all current animations
local AnimationOnUpdate = function(self, elapsed)
	for i = 1, #self do
		if self[i] then -- Double check the the index still exists, due to pauses/stops removing them on the fly
			self[i]:Update(elapsed, i)
		end
	end

	if (#self == 0) then
		self:SetScript("OnUpdate", nil)
	end
end

local StartUpdating = function(anim)
	tinsert(Updater, anim)

	if (not Updater:GetScript("OnUpdate")) then
		Updater:SetScript("OnUpdate", AnimationOnUpdate)
	end
end

local GetColor = function(p, r1, g1, b1, r2, g2, b2)
	return r1 + (r2 - r1) * p, g1 + (g2 - g1) * p, b1 + (b2 - b1) * p
end

local Set = {
	["backdrop"] = Updater.SetBackdropColor,
	["border"] = Updater.SetBackdropBorderColor,
	["statusbar"] = Updater.SetStatusBarColor,
	["text"] = Text.SetTextColor,
	["texture"] = Texture.SetTexture,
	["vertex"] = Texture.SetVertexColor,
}

local Get = {
	["backdrop"] = Updater.GetBackdropColor,
	["border"] = Updater.GetBackdropBorderColor,
	["statusbar"] = Updater.GetStatusBarColor,
	["text"] = Text.GetTextColor,
	["texture"] = Texture.GetVertexColor,
	["vertex"] = Texture.GetVertexColor,
}

local Smoothing = {
	["none"] = function(t, b, c, d)
		return c * t / d + b
	end,

	["in"] = function(t, b, c, d)
		t = t / d

		return c * t * t + b
	end,

	["out"] = function(t, b, c, d)
		t = t / d

		return -c * t * (t - 2) + b
	end,

	["inout"] = function(t, b, c, d)
		t = t / (d / 2)

		if (t < 1) then
			return c / 2 * t * t + b
		end

		t = t - 1
		return -c / 2 * (t * (t - 2) - 1) + b
	end,

	["bounce"] = function(t, b, c, d)
		t = t / d

		if (t < (1 / 2.75)) then
			return c * (7.5625 * t * t) + b
		elseif (t < (2 / 2.75)) then
			t = t - (1.5 / 2.75)

			return c * (7.5625 * t * t + 0.75) + b
		elseif (t < (2.5 / 2.75)) then
			t = t - (2.25 / 2.75)

			return c * (7.5625 * t * t + 0.9375) + b
		else
			t = t - (2.625 / 2.75)

			return c * (7.5625 * (t) * t + 0.984375) + b
		end
	end,
	["elastic"] = function(t, b, c, d)
		local s, p, a = 1.70158, d * .3, c;
		if t == 0 then
			return b
		end
		t = t / d

		if t == 1 then
			return b + c
		end

		if a < math.abs(c) then
			a = c
			s = p / 4
		else
			s = p / (2 * math.pi) * math.asin(c / a)
		end

		return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
	end
}

local AnimMethods = {
	All = {
		Play = function(self)
			if (not self.Paused) then
				AnimTypes[self.Type](self)
				self:Callback("OnPlay")
			else
				StartUpdating(self)
				self:Callback("OnResume")
			end

			self.Playing = true
			self.Paused = false
			self.Stopped = false
		end,

		IsPlaying = function(self)
			return self.Playing
		end,

		Pause = function(self)
			for i = 1, #Updater do
				if (Updater[i] == self) then
					tremove(Updater, i)

					break
				end
			end

			self.Playing = false
			self.Paused = true
			self.Stopped = false
			self:Callback("OnPause")
		end,

		IsPaused = function(self)
			return self.Paused
		end,

		Stop = function(self, reset)
			for i = 1, #Updater do
				if (Updater[i] == self) then
					tremove(Updater, i)

					break
				end
			end

			self.Playing = false
			self.Paused = false
			self.Stopped = true

			if reset then
				self:Reset()
				self:Callback("OnReset")
			else
				self:Callback("OnStop")
			end
		end,

		IsStopped = function(self)
			return self.Stopped
		end,

		SetSmoothing = function(self, smoothType)
			smoothType = strlower(smoothType)

			self.Smoothing = Smoothing[smoothType] and smoothType or "none"
		end,

		GetSmoothing = function(self)
			return self.Smoothing
		end,

		SetDuration = function(self, duration)
			self.Duration = duration or 0
		end,

		GetDuration = function(self)
			return self.Duration
		end,

		GetProgressByTimer = function(self)
			return self.Timer
		end,

		SetOrder = function(self, order)
			self.Order = order or 1

			if (order > self.Group.MaxOrder) then
				self.Group.MaxOrder = order
			end
		end,

		GetOrder = function(self)
			return self.Order
		end,

		GetParent = function(self)
			return self.Parent
		end,

		SetScript = function(self, handler, func)
			handler = strlower(handler)

			if (not Callbacks[handler]) then
				return
			end

			Callbacks[handler][self] = func
		end,

		GetScript = function(self, handler)
			handler = strlower(handler)

			if (Callbacks[handler] and Callbacks[handler][self]) then
				return Callbacks[handler][self]
			end
		end,

		Callback = function(self, handler)
			handler = strlower(handler)

			if Callbacks[handler][self] then
				Callbacks[handler][self](self)
			end
		end,
	},

	move = {
		SetOffset = function(self, x, y)
			self.XSetting  = x or 0
			self.YSetting  = y or 0
		end,

		GetOffset = function(self)
			return self.XSetting, self.YSetting
		end,

		SetRounded = function(self, flag)
			self.IsRounded = flag
		end,

		GetRounded = function(self)
			return self.IsRounded
		end,

		GetProgress = function(self)
			return self.XOffset, self.YOffset
		end,

		Reset = function(self)
			self.Parent:ClearAllPoints()
			self.Parent:SetPoint(self.A1, self.P, self.A2, self.StartX, self.StartY)
		end,
	},

	fade = {
		SetChange = function(self, alpha)
			self.EndAlphaSetting = alpha or 0
		end,

		GetChange = function(self)
			return self.EndAlphaSetting
		end,

		GetProgress = function(self)
			return self.AlphaOffset
		end,

		Reset = function(self)
			self.Parent:SetAlpha(self.StartAlpha)
		end,
	},

	height = {
		SetChange = function(self, height)
			self.EndHeightSetting = height or 0
		end,

		GetChange = function(self)
			return self.EndHeightSetting
		end,

		GetProgress = function(self)
			return self.HeightOffset
		end,

		Reset = function(self)
			self.Parent:SetHeight(self.StartHeight)
		end,
	},

	width = {
		SetChange = function(self, width)
			self.EndWidthSetting = width or 0
		end,

		GetChange = function(self)
			return self.EndWidthSetting
		end,

		GetProgress = function(self)
			return self.WidthOffset
		end,

		Reset = function(self)
			self.Parent:SetWidth(self.StartWidth)
		end,
	},

	color = {
		SetChange = function(self, r, g, b)
			self.EndRSetting = r or 1
			self.EndGSetting = g or 1
			self.EndBSetting = b or 1
		end,

		GetChange = function(self)
			return self.EndRSetting, self.EndGSetting, self.EndBSetting
		end,

		SetColorType = function(self, type)
			type = strlower(type)

			self.ColorType = Set[type] and type or "border"
		end,

		GetColorType = function(self)
			return self.ColorType
		end,

		GetProgress = function(self)
			return self.ColorOffset
		end,

		Reset = function(self)
			Set[self.ColorType](self.Parent, self.StartR, self.StartG, self.StartB)
		end,
	},

	progress = {
		SetChange = function(self, value)
			self.EndValueSetting = value or 0
		end,

		GetChange = function(self)
			return self.EndValueSetting
		end,

		GetProgress = function(self)
			return self.ValueOffset
		end,

		Reset = function(self)
			self.Parent:SetValue(self.StartValue)
		end,
	},

	number = {
		SetChange = function(self, value)
			self.EndNumberSetting = value or 0
		end,

		GetChange = function(self)
			return self.EndNumberSetting
		end,

		SetPrefix = function(self, text)
			self.Prefix = text or ""
		end,

		GetPrefix = function(self)
			return self.Prefix
		end,

		SetPostfix = function(self, text)
			self.Postfix = text or ""
		end,

		GetPostfix = function(self)
			return self.Postfix
		end,

		GetProgress = function(self)
			return self.NumberOffset
		end,

		Reset = function(self)
			self.Parent:SetText(self.StartNumer)
		end,
	},
}

local GroupMethods = {
	Play = function(self)
		-- Play!
		for i = 1, #self.Animations do
			if (self.Animations[i].Order == self.Order) then
				self.Animations[i]:Play()
			end
		end

		self.Playing = true
		self.Paused = false
		self.Stopped = false
	end,

	IsPlaying = function(self)
		return self.Playing
	end,

	Pause = function(self)
		-- Only pause current order
		for i = 1, #self.Animations do
			if (self.Animations[i].Order == self.Order) then
				self.Animations[i]:Pause()
			end
		end

		self.Playing = false
		self.Paused = true
		self.Stopped = false
	end,

	IsPaused = function(self)
		return self.Paused
	end,

	Stop = function(self)
		for i = 1, #self.Animations do
			self.Animations[i]:Stop()
		end

		self.Playing = false
		self.Paused = false
		self.Stopped = true
	end,

	IsStopped = function(self)
		return self.Stopped
	end,

	SetLooping = function(self, shouldLoop)
		self.Looping = shouldLoop
	end,

	GetLooping = function(self)
		return self.Looping
	end,

	GetParent = function(self)
		return self.Parent
	end,

	CheckOrder = function(self)
		-- Check if we're done all animations at the current order, then proceed to the next order.
		local NumAtOrder = 0
		local NumDoneAtOrder = 0

		for i = 1, #self.Animations do
			if (self.Animations[i].Order == self.Order) then
				NumAtOrder = NumAtOrder + 1

				if (not self.Animations[i].Playing) then
					NumDoneAtOrder = NumDoneAtOrder + 1
				end
			end
		end

		-- All the animations at x order finished, go to next order
		if (NumAtOrder == NumDoneAtOrder) then
			self.Order = self.Order + 1

			-- We exceeded max order, reset to 1 and bail the function, or restart if we're looping
			if (self.Order > self.MaxOrder) then
				self.Order = 1

				if (self.Stopped or not self.Looping) then
					self.Playing = false

					return
				end
			end

			-- Play!
			for i = 1, #self.Animations do
				if (self.Animations[i].Order == self.Order) then
					self.Animations[i]:Play()
				end
			end
		end
	end,

	CreateAnimation = function(self, type)
		type = strlower(type)

		if (not AnimTypes[type]) then
			return
		end

		local Animation = {}

		-- General methods
		for key, func in pairs(AnimMethods.All) do
			Animation[key] = func
		end

		-- Animation specific methods
		if AnimMethods[type] then
			for key, func in pairs(AnimMethods[type]) do
				Animation[key] = func
			end
		end

		-- Set some attributes and defaults
		Animation.Paused = false
		Animation.Playing = false
		Animation.Stopped = false
		Animation.Looping = false
		Animation.Type = type
		Animation.Group = self
		Animation.Parent = self.Parent
		Animation.Order = 1
		Animation.Duration = 0.3
		Animation.Smoothing = "none"
		Animation.Update = UpdateFuncs[type]

		tinsert(self.Animations, Animation)

		return Animation
	end,
}

CreateAnimationGroup = function(parent)
	local Group = {Animations = {}}

	-- Add methods to the group
	for key, func in pairs(GroupMethods) do
		Group[key] = func
	end

	Group.Parent = parent
	Group.Playing = false
	Group.Paused = false
	Group.Stopped = false
	Group.Order = 1
	Group.MaxOrder = 1

	return Group
end

-- Movement
UpdateFuncs["move"] = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed

	if self.IsRounded then
		self.ModTimer = Smoothing[self.Smoothing](self.Timer, 0, self.Duration, self.Duration)
		self.XOffset = self.StartX - (-1) * (self.XChange * (1 - cos(90 * self.ModTimer / self.Duration)))
		self.YOffset = self.StartY + self.YChange * sin(90 * self.ModTimer / self.Duration)
	else
		self.XOffset = Smoothing[self.Smoothing](self.Timer, self.StartX, self.XChange, self.Duration)
		self.YOffset = Smoothing[self.Smoothing](self.Timer, self.StartY, self.YChange, self.Duration)
	end

	self.Parent:SetPoint(self.A1, self.P, self.A2, (self.EndX ~= 0 and self.XOffset or self.StartX), (self.EndY ~= 0 and self.YOffset or self.StartY))

	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetPoint(self.A1, self.P, self.A2, self.EndX, self.EndY)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	end
end

AnimTypes["move"] = function(self)
	if self:IsPlaying() then
		return
	end

	local A1, P, A2, X, Y = self.Parent:GetPoint()

	self.Timer = 0
	self.A1 = A1
	self.P = P
	self.A2 = A2
	self.StartX = X
	self.EndX = X + self.XSetting or 0
	self.StartY = Y
	self.EndY = Y + self.YSetting or 0
	self.XChange = self.EndX - self.StartX
	self.YChange = self.EndY - self.StartY

	if self.IsRounded then
		if (self.XChange == 0 or self.YChange == 0) then -- Double check if we're valid to be rounded
			self.IsRounded = false
		else
			self.ModTimer = 0
		end
	end

	StartUpdating(self)
end

-- Fade
UpdateFuncs["fade"] = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	self.AlphaOffset = Smoothing[self.Smoothing](self.Timer, self.StartAlpha, self.Change, self.Duration)
	self.Parent:SetAlpha(self.AlphaOffset)

	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetAlpha(self.EndAlpha)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	end
end

AnimTypes["fade"] = function(self)
	if self:IsPlaying() then
		return
	end

	self.Timer = 0
	self.StartAlpha = self.Parent:GetAlpha() or 1
	self.EndAlpha = self.EndAlphaSetting or 0
	self.Change = self.EndAlpha - self.StartAlpha

	StartUpdating(self)
end

-- Height
UpdateFuncs["height"] = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	self.HeightOffset = Smoothing[self.Smoothing](self.Timer, self.StartHeight, self.HeightChange, self.Duration)
	self.Parent:SetHeight(self.HeightOffset)

	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetHeight(self.EndHeight)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	end
end

AnimTypes["height"] = function(self)
	if self:IsPlaying() then
		return
	end

	self.Timer = 0
	self.StartHeight = self.Parent:GetHeight() or 0
	self.EndHeight = self.EndHeightSetting or 0
	self.HeightChange = self.EndHeight - self.StartHeight

	StartUpdating(self)
end

-- Width
UpdateFuncs["width"] = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	self.WidthOffset = Smoothing[self.Smoothing](self.Timer, self.StartWidth, self.WidthChange, self.Duration)
	self.Parent:SetWidth(self.WidthOffset)

	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetWidth(self.EndWidth)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	end
end

AnimTypes["width"] = function(self)
	if self:IsPlaying() then
		return
	end

	self.Timer = 0
	self.StartWidth = self.Parent:GetWidth() or 0
	self.EndWidth = self.EndWidthSetting or 0
	self.WidthChange = self.EndWidth - self.StartWidth

	StartUpdating(self)
end

-- Color
UpdateFuncs["color"] = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	self.ColorOffset = Smoothing[self.Smoothing](self.Timer, 0, self.Duration, self.Duration)
	Set[self.ColorType](self.Parent, GetColor(self.Timer / self.Duration, self.StartR, self.StartG, self.StartB, self.EndR, self.EndG, self.EndB))

	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		Set[self.ColorType](self.Parent, self.EndR, self.EndG, self.EndB)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	end
end

AnimTypes["color"] = function(self)
	self.Timer = 0
	self.ColorType = self.ColorType or "backdrop"
	self.StartR, self.StartG, self.StartB = Get[self.ColorType](self.Parent)
	self.EndR = self.EndRSetting or 1
	self.EndG = self.EndGSetting or 1
	self.EndB = self.EndBSetting or 1

	StartUpdating(self)
end

-- Progress
UpdateFuncs["progress"] = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	self.ValueOffset = Smoothing[self.Smoothing](self.Timer, self.StartValue, self.ProgressChange, self.Duration)
	self.Parent:SetValue(self.ValueOffset)

	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetValue(self.EndValue)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	end
end

AnimTypes["progress"] = function(self)
	self.Timer = 0
	self.StartValue = self.Parent:GetValue() or 0
	self.EndValue = self.EndValueSetting or 0
	self.ProgressChange = self.EndValue - self.StartValue

	StartUpdating(self)
end

-- Sleep
UpdateFuncs["sleep"] = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed

	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	end
end

AnimTypes["sleep"] = function(self)
	self.Timer = 0

	StartUpdating(self)
end

-- Number
UpdateFuncs["number"] = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed
	self.NumberOffset = Smoothing[self.Smoothing](self.Timer, self.StartNumber, self.NumberChange, self.Duration)
	self.Parent:SetText(self.Prefix..floor(self.NumberOffset)..self.Postfix)

	if (self.Timer >= self.Duration) then
		tremove(Updater, i)
		self.Parent:SetText(self.Prefix..floor(self.EndNumber)..self.Postfix)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	end
end

AnimTypes["number"] = function(self)
	self.Timer = 0
	self.StartNumber = tonumber(self.Parent:GetText()) or 0
	self.EndNumber = self.EndNumberSetting or 0
	self.NumberChange = self.EndNumberSetting - self.StartNumber
	self.Prefix = self.Prefix or ""
	self.Postfix = self.Postfix or ""

	StartUpdating(self)
end

_G["_LibAnim"] = Version
