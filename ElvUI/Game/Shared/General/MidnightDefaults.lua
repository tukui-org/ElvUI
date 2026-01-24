-- Midnight SECRET aura handling defaults
-- This is loaded after Profile.lua to inject midnight defaults

local E, L, V, P, G = unpack(ElvUI)

-- MIDNIGHT: CYCLE 4 - Add midnight configuration defaults for UnitFrames
P.unitframe = P.unitframe or {}
P.unitframe.midnight = {
	hideSecretAuras = false,      -- When true, SECRET auras are completely hidden
	neutralSecretAuras = true,    -- When true, SECRET auras shown with neutral (gray) border
	redactSecretDurations = true, -- When true, duration text is suppressed for SECRET auras
}
