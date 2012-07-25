local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function SkinPowerAuras(self, aura, elapsed)
	local returnValue = PowaAuras.OldUpdateAura(self, aura, elapsed)
	
	if (aura == nil) or (aura.off) then
		return false;
	end

	if (aura.Showing) then
		local frame = aura:GetFrame();
		if (frame == nil) then
			return false;
		end
		
		if frame and not frame.backdrop then
			frame:CreateBackdrop('Default')
			frame.backdrop:Hide()
		end
		
		if frame and aura.owntex then
			local texture = aura:GetTexture()
			if not frame.backdrop:IsShown() then
				frame.backdrop:Show()
			end
			texture:SetTexCoord(unpack(E.TexCoords))
		elseif frame and frame.backdrop:IsShown() then
			frame.backdrop:Hide()
		end
	end
	
	return returnValue
end

local function PowerAuras_LoadSkin()
	PowaAuras.OldUpdateAura = PowaAuras.UpdateAura
	PowaAuras.UpdateAura = SkinPowerAuras
end

local function Skin_WeakAuras(frame)
	if not frame.backdrop then
		frame:CreateBackdrop('Default')
		frame.icon.OldAlpha = frame.icon.SetAlpha
		frame.icon.SetAlpha = function(self, ...)
			frame.icon.OldAlpha(self, ...)
			frame.backdrop:SetAlpha(...)
		end
	end

	frame.icon:SetTexCoord(unpack(E.TexCoords))
	frame.icon.SetTexCoord = E.noop
end

local function Create_WeakAuras(parent, data)
	local region = WeakAuras.regionTypes.icon.OldCreate(parent, data)
	Skin_WeakAuras(region)
	
	return region
end

local function Modify_WeakAuras(parent, region, data)
	WeakAuras.regionTypes.icon.OldModify(parent, region, data)

	Skin_WeakAuras(region)
end

local function WeakAuras_LoadSkin()
	WeakAuras.regionTypes.icon.OldCreate = WeakAuras.regionTypes.icon.create
	WeakAuras.regionTypes.icon.create = Create_WeakAuras
	
	WeakAuras.regionTypes.icon.OldModify = WeakAuras.regionTypes.icon.modify
	WeakAuras.regionTypes.icon.modify = Modify_WeakAuras
	
	for weakAura, _ in pairs(WeakAuras.regions) do
		if WeakAuras.regions[weakAura].regionType == 'icon' then
			Skin_WeakAuras(WeakAuras.regions[weakAura].region)
		end
	end
end

S:RegisterSkin('PowerAuras', PowerAuras_LoadSkin)
S:RegisterSkin('WeakAuras', WeakAuras_LoadSkin)
