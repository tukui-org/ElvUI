local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

-- setup shadow border texture.
local shadows = {
	edgeFile = C["media"].glowTex, 
	edgeSize = 3.7,
	insets = { left = E.mult, right = E.mult, top = E.mult, bottom = E.mult }
}

-- create shadow frame
function E.CreateShadow(f)
	if f.shadow then return end
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(0)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint("TOPLEFT", -E.Scale(4), E.Scale(4))
	shadow:SetPoint("BOTTOMRIGHT", E.Scale(4), E.Scale(-4))
	shadow:SetBackdrop(shadows)
	shadow:SetBackdropColor(0, 0, 0, 0)
	shadow:SetBackdropBorderColor(0, 0, 0, .75)
	f.shadow = shadow
	return shadow
end

function E.SetTemplate(f)
	local r, g, b = RAID_CLASS_COLORS[E.myclass].r, RAID_CLASS_COLORS[E.myclass].g, RAID_CLASS_COLORS[E.myclass].b
	f:SetBackdrop({
	  bgFile = C["media"].blank, 
	  edgeFile = C["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = E.mult, 
	  insets = { left = -E.mult, right = -E.mult, top = -E.mult, bottom = -E.mult}
	})
	f:SetBackdropColor(unpack(C["media"].backdropcolor))
	if C["general"].classcolortheme == true then
		f:SetBackdropBorderColor(r, g, b)
	else
		f:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	end
end

function E.SetNormTexTemplate(f)
	local r, g, b = RAID_CLASS_COLORS[E.myclass].r, RAID_CLASS_COLORS[E.myclass].g, RAID_CLASS_COLORS[E.myclass].b
	f:SetBackdrop({
	  bgFile = C["media"].normTex, 
	  edgeFile = C["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = E.mult, 
	  insets = { left = -E.mult, right = -E.mult, top = -E.mult, bottom = -E.mult}
	})
	f:SetBackdropColor(unpack(C["media"].backdropcolor))
	if C["general"].classcolortheme == true then
		f:SetBackdropBorderColor(r, g, b)
	else
		f:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	end
end

function E.SetTransparentTemplate(f)
	local r, g, b = RAID_CLASS_COLORS[E.myclass].r, RAID_CLASS_COLORS[E.myclass].g, RAID_CLASS_COLORS[E.myclass].b
    f:SetFrameLevel(1)
    f:SetFrameStrata("BACKGROUND")
    f:SetBackdrop({
      bgFile = C["media"].blank,
      edgeFile = C["media"].blank,
      tile = false, tileSize = 0, edgeSize = E.mult,
      insets = { left = -E.mult, right = -E.mult, top = -E.mult, bottom = -E.mult}
    })
    f:SetBackdropColor(unpack(C["media"].backdropfadecolor))
	if C["general"].classcolortheme == true then
		f:SetBackdropBorderColor(r, g, b)
	else
		f:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	end
end

function E.CreatePanel(f, w, h, a1, p, a2, x, y)
	local _, class = UnitClass("player")
	local r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
	sh = E.Scale(h)
	sw = E.Scale(w)
	f:SetFrameLevel(1)
	f:SetHeight(sh)
	f:SetWidth(sw)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, E.Scale(x), E.Scale(y))
	E.SetTemplate(f)
end

function E.Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = E.dummy
	object:Hide()
end