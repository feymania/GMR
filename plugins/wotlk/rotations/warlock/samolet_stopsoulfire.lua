C_Timer.NewTicker(0.1, function()
	local Decimation = GetSpellInfo(63167)
	local SoulFire = GetSpellInfo(30545)
	if UnitCastingInfo("player") == SoulFire
	and not AuraUtil.FindAuraByName(Decimation, "player", "HELPFUL") then
		GMR.SpellStopCasting()
	end
end)