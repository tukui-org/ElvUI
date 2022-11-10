-- LibAnim by Hydra
local Version = 2.901 -- based on 2.03

-- Note, deprecated items will be removed next version.
-- Please update your usage accordingly. (ctrl + f - "Deprecated")

if _G._LibAnim and _G._LibAnim >= Version then
	return
end

local Updater = CreateFrame("StatusBar", nil, nil, "BackdropTemplate")
local Texture = Updater:CreateTexture()
local FontString = Updater:CreateFontString()
local Initialize, Update, Easing = {}, {}, {}
local Callbacks = {onplay = {}, onpause = {}, onresume = {}, onstop = {}, onreset = {}, onfinished = {}}
local pi, cos, sin, sqrt, floor = math.pi, math.cos, math.sin, math.sqrt, math.floor
local type, pairs, ipairs, tonumber = type, pairs, ipairs, tonumber
local tinsert, tremove, strlower = tinsert, tremove, strlower

-- Update all current animations
local AnimationOnUpdate = function(self, elapsed)
	for i = 1, #self do
		if self[i] then -- Double check that the index still exists, due to pauses/stops removing them on the fly
			self[i]:Update(elapsed, i)
		end
	end

	if #self == 0 then
		self:SetScript("OnUpdate", nil)
	end
end

local StartUpdating = function(anim)
	tinsert(Updater, anim)

	if not Updater:GetScript("OnUpdate") then
		Updater:SetScript("OnUpdate", AnimationOnUpdate)
	end
end

local GetColor = function(p, r1, g1, b1, r2, g2, b2)
	return r1 + (r2 - r1) * p, g1 + (g2 - g1) * p, b1 + (b2 - b1) * p
end

local Set = {
	backdrop = Updater.SetBackdropColor,
	border = Updater.SetBackdropBorderColor,
	statusbar = Updater.SetStatusBarColor,
	text = FontString.SetTextColor,
	texture = Texture.SetTexture,
	vertex = Texture.SetVertexColor
}

local Get = {
	backdrop = Updater.GetBackdropColor,
	border = Updater.GetBackdropBorderColor,
	statusbar = Updater.GetStatusBarColor,
	text = FontString.GetTextColor,
	texture = Texture.GetVertexColor,
	vertex = Texture.GetVertexColor
}

-- Linear
local Linear = function(t, b, c, d)
	return c * t / d + b
end

-- Quadratic
local InQuadratic = function(t, b, c, d)
	t = t / d

	return c * (t ^ 2) + b
end

local OutQuadratic = function(t, b, c, d)
	t = t / d

	return -c * t * (t - 2) + b
end

local InOutQuadratic = function(t, b, c, d)
	t = t / d * 2

	if t < 1 then
		return c / 2 * (t ^ 2) + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

-- Cubic
local InCubic = function(t, b, c, d)
	t = t / d

	return c * (t ^ 3) + b
end

local OutCubic = function(t, b, c, d)
	t = t / d - 1

	return c * (t ^ 3 + 1) + b
end

local InOutCubic = function(t, b, c, d)
	t = t / d * 2

	if t < 1 then
		return c / 2 * (t ^ 3) + b
	else
		t = t - 2

		return c / 2 * (t ^ 3 + 2) + b
	end
end

-- Quartic
local InQuartic = function(t, b, c, d)
	t = t / d

	return c * (t ^ 4) + b
end

local OutQuartic = function(t, b, c, d)
	t = t / d - 1

	return -c * (t ^ 4 - 1) + b
end

local InOutQuartic = function(t, b, c, d)
	t = t / d * 2

	if t < 1 then
		return c / 2 * t ^ 4 + b
	else
		t = t - 2

		return -c / 2 * (t ^ 4 - 2) + b
	end
end

-- Quintic
local InQuintic = function(t, b, c, d)
	t = t / d

	return c * (t ^ 5) + b
end

local OutQuintic = function(t, b, c, d)
	t = t / d - 1

	return c * (t ^ 5 + 1) + b
end

local InOutQuintic = function(t, b, c, d)
	t = t / d * 2

	if t < 1 then
		return c / 2 * t ^ 5 + b
	else
		t = t - 2

		return c / 2 * (t ^ 5 + 2) + b
	end
end

-- Sinusoidal
local InSinusoidal = function(t, b, c, d)
	return -c * cos(t / d * (pi / 2)) + c + b
end

local OutSinusoidal = function(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end

local InOutSinusoidal = function(t, b, c, d)
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

-- Exponential
local InExponential = function(t, b, c, d)
	if t == 0 then
		return b
	else
		return c * (2 ^ (10 * (t / d - 1))) + b - c * 0.001
	end
end

local OutExponential = function(t, b, c, d)
	if t == d then
		return b + c
	else
		return c * 1.001 * (-(2 ^ (-10 * t / d)) + 1) + b
	end
end

local InOutExponential = function(t, b, c, d)
	if t == 0 then
		return b
	end

	if t == d then
		return b + c
	end

	t = t / d * 2

	if t < 1 then
		return c / 2 * (2 ^ (10 * (t - 1))) + b - c * 0.0005
	else
		t = t - 1

		return c / 2 * 1.0005 * (-(2 ^ (-10 * t)) + 2) + b
	end
end

-- Circular
local InCircular = function(t, b, c, d)
	t = t / d

	return (-c * (sqrt(1 - t * t) - 1) + b)
end

local OutCircular = function(t, b, c, d)
	t = t / d - 1

	return (c * sqrt(1 - t * t) + b)
end

local InOutCircular = function(t, b, c, d)
	t = t / d * 2

	if t < 1 then
		return -c / 2 * (sqrt(1 - t * t) - 1) + b
	else
		t = t - 2

		return c / 2 * (sqrt(1 - t * t) + 1) + b
	end
end

-- Bounce
local OutBounce = function(t, b, c, d)
	t = t / d

	if t < (1 / 2.75) then
		return c * (7.5625 * t * t) + b
	elseif t < (2 / 2.75) then
		t = t - (1.5 / 2.75)

		return c * (7.5625 * t * t + 0.75) + b
	elseif t < (2.5 / 2.75) then
		t = t - (2.25 / 2.75)

		return c * (7.5625 * t * t + 0.9375) + b
	else
		t = t - (2.625 / 2.75)

		return c * (7.5625 * t * t + 0.984375) + b
	end
end

local InBounce = function(t, b, c, d)
	return c - OutBounce(d - t, 0, c, d) + b
end

local InOutBounce = function(t, b, c, d)
	if t < d / 2 then
		return InBounce(t * 2, 0, c, d) * 0.5 + b
	else
		return OutBounce(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
	end
end

-- Elastic
local InElastic = function(t, b, c, d)
	if t == 0 then
		return b
	end

	t = t / d

	if t == 1 then
		return b + c
	end

	local a = c
	local p = d * 0.3
	local s = p / 4

	t = t - 1

	return -(a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

local OutElastic = function(t, b, c, d)
	if t == 0 then
		return b
	end

	t = t / d

	if t == 1 then
		return b + c
	end

	local a = c
	local p = d * 0.3
	local s = p / 4

	return a * 2 ^ (-10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

local InOutElastic = function(t, b, c, d)
	if t == 0 then
		return b
	end

	t = t / d * 2

	if t == 2 then
		return b + c
	end

	local a = c
	local p = d * (0.3 * 1.5)
	local s = p / 4

	if t < 1 then
		t = t - 1

		return -0.5 * (a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
	else
		t = t - 1

		return a * 2 ^ (-10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
	end
end

Easing["linear"] = Linear
Easing["in-quadratic"] = InQuadratic
Easing["out-quadratic"] = OutQuadratic
Easing["inout-quadratic"] = InOutQuadratic
Easing["in-cubic"] = InCubic
Easing["out-cubic"] = OutCubic
Easing["inout-cubic"] = InOutCubic
Easing["in-quartic"] = InQuartic
Easing["out-quartic"] = OutQuartic
Easing["inout-quartic"] = InOutQuartic
Easing["in-quintic"] = InQuintic
Easing["out-quintic"] = OutQuintic
Easing["inout-quintic"] = InOutQuintic
Easing["in-sinusoidal"] = InSinusoidal
Easing["out-sinusoidal"] = OutSinusoidal
Easing["inout-sinusoidal"] = InOutSinusoidal
Easing["in-exponential"] = InExponential
Easing["out-exponential"] = OutExponential
Easing["inout-exponential"] = InOutExponential
Easing["in-circular"] = InCircular
Easing["out-circular"] = OutCircular
Easing["inout-circular"] = InOutCircular
Easing["in-bounce"] = InBounce
Easing["out-bounce"] = OutBounce
Easing["inout-bounce"] = InOutBounce
Easing["in-elastic"] = InElastic
Easing["out-elastic"] = OutElastic
Easing["inout-elastic"] = InOutElastic

-- Some fallbacks / lazy options
Easing["in"] = Easing["in-quadratic"]
Easing["out"] = Easing["out-quadratic"]
Easing["inout"] = Easing["inout-quadratic"]
Easing["bounce"] = Easing["out-bounce"] -- Deprecated, don't use bounce without an explicit motion anymore

local AnimMethods = {
	All = {
		Play = function(self)
			if not self.Paused then
				Initialize[self.Type](self)
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
				if Updater[i] == self then
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
				if Updater[i] == self then
					tremove(Updater, i)

					break
				end
			end

			self.Playing = false
			self.Paused = false
			self.Stopped = true
			self.Timer = 0

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

		SetEasing = function(self, easing)
			easing = strlower(easing)

			self.Easing = Easing[easing] and easing or "linear"
		end,

		GetEasing = function(self)
			return self.Easing
		end,

		SetSmoothing = function(self, easing) -- Deprecated, change "SetSmoothing" to "SetEasing"
			easing = strlower(easing)

			self.Easing = Easing[easing] and easing or "linear"
		end,

		GetSmoothing = function(self) -- Deprecated, change "GetSmoothing" to "GetEasing"
			return self.Easing
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

			if order > self.Group.MaxOrder then
				self.Group.MaxOrder = order
			end
		end,

		GetOrder = function(self)
			return self.Order
		end,

		GetParent = function(self)
			return self.Parent
		end,

		AddChild = function(self, child, mainChild)
			if not self.children then self.children = {} end
			if not self.mainChild then
				self.mainChild = mainChild or child
			elseif mainChild then
				self.mainChild = mainChild
			end
			tinsert(self.children, child)
		end,

		RemoveChild = function(self, child)
			if not self.children then return end
			local checkIndex = type(child) == 'number'
			for index, tchild in ipairs(self.children) do
				if (checkIndex and index == child) or tchild == child then
					tremove(self.children, index)
					break
				end
			end
		end,

		SetScript = function(self, handler, func)
			handler = strlower(handler)

			if Callbacks[handler] then
				Callbacks[handler][self] = func
			end
		end,

		GetScript = function(self, handler)
			handler = strlower(handler)

			if Callbacks[handler] and Callbacks[handler][self] then
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
			self.XSetting = x or 0
			self.YSetting = y or 0
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
			self.Timer = 0
			self.Parent:ClearAllPoints()
			self.Parent:SetPoint(self.A1, self.P, self.A2, self.StartX, self.StartY)

			if self.IsRounded then
				self.ModTimer = 0
			end
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
			self.Timer = 0
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
			self.Timer = 0
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
			self.Timer = 0
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

		SetColorType = function(self, region)
			region = strlower(region)

			self.ColorType = (Set[region] and region) or "border"
		end,

		GetColorType = function(self)
			return self.ColorType
		end,

		GetProgress = function(self)
			return self.ColorOffset
		end,

		Reset = function(self)
			self.Timer = 0
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
			self.Timer = 0
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

		SetStart = function(self, value)
			self.StartNumber = value
		end,

		GetStart = function(self, value)
			return self.StartNumber
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
			self.Timer = 0
			self.Parent:SetText(self.StartNumber)
		end,
	},

	sleep = {
		GetProgress = function(self)
			return self.Timer
		end,

		Reset = function(self)
			self.Timer = 0
		end,
	},
}

local GroupMethods = {
	Play = function(self)
		for i = 1, #self.Animations do
			if self.Animations[i].Order == self.Order then
				self.Animations[i]:Play()
			end
		end

		self.Playing = true
		self.Paused = false
		self.Stopped = false

		self:Callback("OnPlay")
	end,

	IsPlaying = function(self)
		return self.Playing
	end,

	Pause = function(self)
		for i = 1, #self.Animations do
			if self.Animations[i].Order == self.Order then
				self.Animations[i]:Pause()
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

	Stop = function(self)
		for i = 1, #self.Animations do
			self.Animations[i]:Stop()
		end

		self.Playing = false
		self.Paused = false
		self.Stopped = true
		self.Order = 1

		self:Callback("OnStop")
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

	SetScript = function(self, handler, func)
		handler = strlower(handler)

		if Callbacks[handler] then
			Callbacks[handler][self] = func
		end
	end,

	GetScript = function(self, handler)
		handler = strlower(handler)

		if Callbacks[handler] and Callbacks[handler][self] then
			return Callbacks[handler][self]
		end
	end,

	Callback = function(self, handler)
		handler = strlower(handler)

		if Callbacks[handler][self] then
			Callbacks[handler][self](self)
		end
	end,

	CheckOrder = function(self)
		-- Check if we're done all animations at the current order, then proceed to the next order.
		local NumAtOrder = 0
		local NumDoneAtOrder = 0

		for i = 1, #self.Animations do
			if self.Animations[i].Order == self.Order then
				NumAtOrder = NumAtOrder + 1

				if not self.Animations[i].Playing then
					NumDoneAtOrder = NumDoneAtOrder + 1
				end
			end
		end

		-- All the animations at x order finished, go to next order
		if NumAtOrder == NumDoneAtOrder then
			self.Order = self.Order + 1

			-- We exceeded max order, reset to 1 and bail the function, or restart if we're looping
			if self.Order > self.MaxOrder then
				self.Order = 1

				self:Callback("OnFinished")

				if self.Stopped or not self.Looping then
					self.Playing = false

					return
				end
			end

			-- Play!
			for i = 1, #self.Animations do
				if self.Animations[i].Order == self.Order then
					self.Animations[i]:Play()
				end
			end
		end
	end,

	CreateAnimation = function(self, style)
		style = strlower(style)

		if not Initialize[style] then
			return
		end

		local Animation = {}

		-- General methods
		for key, func in pairs(AnimMethods.All) do
			Animation[key] = func
		end

		-- Animation specific methods
		if AnimMethods[style] then
			for key, func in pairs(AnimMethods[style]) do
				Animation[key] = func
			end
		end

		-- Set some attributes and defaults
		Animation.Paused = false
		Animation.Playing = false
		Animation.Stopped = false
		Animation.Looping = false
		Animation.Type = style
		Animation.Group = self
		Animation.Parent = self.Parent
		Animation.Order = 1
		Animation.Duration = 0.3
		Animation.Easing = "linear"
		Animation.Update = Update[style]

		tinsert(self.Animations, Animation)

		return Animation
	end,
}

_G.CreateAnimationGroup = function(parent)
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
Initialize.move = function(self)
	if self.Playing then
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
		if self.XChange == 0 or self.YChange == 0 then -- Double check if we're valid to be rounded
			self.IsRounded = false
		else
			self.ModTimer = 0
		end
	end

	StartUpdating(self)
end

Update.move = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed

	if self.Timer >= self.Duration then
		tremove(Updater, i)
		self.Parent:SetPoint(self.A1, self.P, self.A2, self.EndX, self.EndY)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	else
		if self.IsRounded then
			self.ModTimer = Easing[self.Easing](self.Timer, 0, self.Duration, self.Duration)
			self.XOffset = self.StartX - (-1) * (self.XChange * (1 - cos(90 * self.ModTimer / self.Duration)))
			self.YOffset = self.StartY + self.YChange * sin(90 * self.ModTimer / self.Duration)
		else
			self.XOffset = Easing[self.Easing](self.Timer, self.StartX, self.XChange, self.Duration)
			self.YOffset = Easing[self.Easing](self.Timer, self.StartY, self.YChange, self.Duration)
		end

		self.Parent:SetPoint(self.A1, self.P, self.A2, (self.EndX ~= 0 and self.XOffset or self.StartX), (self.EndY ~= 0 and self.YOffset or self.StartY))
	end
end

-- Fade
Initialize.fade = function(self)
	if self.Playing then
		return
	end

	self.Timer = 0
	self.StartAlpha = (self.mainChild or self.Parent):GetAlpha() or 1
	self.EndAlpha = self.EndAlphaSetting or 0
	self.Change = self.EndAlpha - self.StartAlpha

	StartUpdating(self)
end

Update.fade = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed

	if self.Timer >= self.Duration then
		tremove(Updater, i)

		if self.children then
			for _, child in pairs(self.children) do
				child:SetAlpha(self.EndAlpha)
			end
		else
			self.Parent:SetAlpha(self.EndAlpha)
		end

		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	elseif self.children then
		self.AlphaOffset = Easing[self.Easing](self.Timer, self.StartAlpha, self.Change, self.Duration)
		for _, child in pairs(self.children) do
			if child:IsShown() then
				child:SetAlpha(self.AlphaOffset)
			end
		end
	elseif self.Parent:IsShown() then
		self.AlphaOffset = Easing[self.Easing](self.Timer, self.StartAlpha, self.Change, self.Duration)
		self.Parent:SetAlpha(self.AlphaOffset)
	end
end

-- Height
Initialize.height = function(self)
	if self.Playing then
		return
	end

	self.Timer = 0
	self.StartHeight = self.Parent:GetHeight() or 0
	self.EndHeight = self.EndHeightSetting or 0
	self.HeightChange = self.EndHeight - self.StartHeight

	StartUpdating(self)
end

Update.height = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed

	if self.Timer >= self.Duration then
		tremove(Updater, i)
		self.Parent:SetHeight(self.EndHeight)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	else
		self.HeightOffset = Easing[self.Easing](self.Timer, self.StartHeight, self.HeightChange, self.Duration)
		self.Parent:SetHeight(self.HeightOffset)
	end
end

-- Width
Initialize.width = function(self)
	if self.Playing then
		return
	end

	self.Timer = 0
	self.StartWidth = self.Parent:GetWidth() or 0
	self.EndWidth = self.EndWidthSetting or 0
	self.WidthChange = self.EndWidth - self.StartWidth

	StartUpdating(self)
end

Update.width = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed

	if self.Timer >= self.Duration then
		tremove(Updater, i)
		self.Parent:SetWidth(self.EndWidth)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	else
		self.WidthOffset = Easing[self.Easing](self.Timer, self.StartWidth, self.WidthChange, self.Duration)
		self.Parent:SetWidth(self.WidthOffset)
	end
end

-- Color
Initialize.color = function(self)
	self.Timer = 0
	self.ColorType = self.ColorType or "backdrop"
	self.StartR, self.StartG, self.StartB = Get[self.ColorType](self.mainChild or self.Parent)
	self.EndR = self.EndRSetting or 1
	self.EndG = self.EndGSetting or 1
	self.EndB = self.EndBSetting or 1

	StartUpdating(self)
end

Update.color = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed

	if self.Timer >= self.Duration then
		tremove(Updater, i)
		if self.children then
			for _, child in pairs(self.children) do
				Set[self.ColorType](child, self.EndR, self.EndG, self.EndB)
			end
		else
			Set[self.ColorType](self.Parent, self.EndR, self.EndG, self.EndB)
		end
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	elseif self.children then
		self.ColorOffset = Easing[self.Easing](self.Timer, 0, self.Duration, self.Duration)
		for _, child in pairs(self.children) do
			Set[self.ColorType](child, GetColor(self.Timer / self.Duration, self.StartR, self.StartG, self.StartB, self.EndR, self.EndG, self.EndB))
		end
	else
		self.ColorOffset = Easing[self.Easing](self.Timer, 0, self.Duration, self.Duration)
		Set[self.ColorType](self.Parent, GetColor(self.Timer / self.Duration, self.StartR, self.StartG, self.StartB, self.EndR, self.EndG, self.EndB))
	end
end

-- Progress
Initialize.progress = function(self)
	self.Timer = 0
	self.StartValue = self.Parent:GetValue() or 0
	self.EndValue = self.EndValueSetting or 0
	self.ProgressChange = self.EndValue - self.StartValue

	StartUpdating(self)
end

Update.progress = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed

	if self.Timer >= self.Duration then
		tremove(Updater, i)
		self.Parent:SetValue(self.EndValue)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	else
		self.ValueOffset = Easing[self.Easing](self.Timer, self.StartValue, self.ProgressChange, self.Duration)
		self.Parent:SetValue(self.ValueOffset)
	end
end

-- Sleep
Initialize.sleep = function(self)
	self.Timer = 0

	StartUpdating(self)
end

Update.sleep = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed

	if self.Timer >= self.Duration then
		tremove(Updater, i)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	end
end

-- Number
Initialize.number = function(self)
	self.Timer = 0

	if not self.StartNumber then
		self.StartNumber = tonumber(self.Parent:GetText()) or 0
	end

	self.EndNumber = self.EndNumberSetting or 0
	self.NumberChange = self.EndNumberSetting - self.StartNumber
	self.Prefix = self.Prefix or ""
	self.Postfix = self.Postfix or ""

	StartUpdating(self)
end

Update.number = function(self, elapsed, i)
	self.Timer = self.Timer + elapsed

	if self.Timer >= self.Duration then
		tremove(Updater, i)
		self.Parent:SetText(self.Prefix..floor(self.EndNumber)..self.Postfix)
		self.Playing = false
		self:Callback("OnFinished")
		self.Group:CheckOrder()
	else
		self.NumberOffset = Easing[self.Easing](self.Timer, self.StartNumber, self.NumberChange, self.Duration)
		self.Parent:SetText(self.Prefix..floor(self.NumberOffset)..self.Postfix)
	end
end

-- Global exposure
_G._LibAnim = Version
_G.LibAnimStartUpdating = StartUpdating
_G.LibAnimUpdater = Updater
_G.LibAnimAddType = function(name, init, update)
	if type(init) ~= "function" or type(update) ~= "function" then
		return
	end

	name = strlower(name)

	if Initialize[name] then
		return
	end

	Initialize[name] = init
	Update[name] = update
end

--[[
	Want to create your own animations for this system? Follow the example below
	If you make a custom animation I would love to see it!

	Example:

	local MyInitialize = function(self)
		self.Timer = 0

		-- do any initialization right before the animation plays

		LibAnimStartUpdating(self)
	end

	local MyUpdate = function(self, elapsed, i)
		self.Timer = self.Timer + elapsed

		if self.Timer >= self.Duration then
			table.remove(LibAnimUpdater, i)

			-- Set finished attributes here

			self.Playing = false
			self:Callback("OnFinished")
			self.Group:CheckOrder()
		else
			-- Do any updating necessary here
		end
	end

	LibAnimAddType("MyAnim", MyInitialize, MyUpdate)
--]]
