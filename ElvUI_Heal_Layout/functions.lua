local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales


if not C["unitframes"].enable == true and not C["raidframes"].enable == true then return end


E.LoadUFFunctions("Heal")