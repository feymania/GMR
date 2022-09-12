function GMR.CustomCombatConditions()
	local class = GMR.GetClass("player")
	if class == "WARLOCK" then
		local Haunt = GetSpellInfo(59164)
		local Corruption = GetSpellInfo(47813)
		local Curse_of_Agony = GetSpellInfo(47864)
		local Unstable_Affliction = GetSpellInfo(30405)
			if GMR.IsCastable(Haunt)
			and GMR.GetDistance("player", "target", "<", 30)
			and AuraUtil.FindAuraByName(Corruption, "target", "HARMFUL") then
				GMR.Cast(Haunt)
			end
		local Chaos = GetSpellInfo(59170)
			if GMR.IsCastable(Chaos)
			and GMR.GetDistance("player", "target", "<", 30) then
				GMR.Cast(Chaos)
			end
		local DemonEmpower = GetSpellInfo(47193)
			if GMR.IsCastable(DemonEmpower)
			and GMR.GetDistance("player", "target", "<", 30) then
				GMR.Cast(DemonEmpower)
			end
		local SoulFire = GetSpellInfo(30545)
		local Decimation = GetSpellInfo(63167)
			if GMR.IsCastable(SoulFire)
			and GMR.GetDistance("player", "target", "<", 30)
			and AuraUtil.FindAuraByName(Decimation, "player", "HELPFUL") then
				GMR.Cast(SoulFire)
			end	
	end	
end