function GMR.CustomCombatConditions() 
	local class = GMR.GetClass("player")
	if class == "HUNTER" then 
		local chimera_shot = GetSpellInfo(53209)
		if GMR.IsCastable(chimera_shot)
		and GMR.GetDistance("player", "target", "<", 35) then 
			GMR.Cast(chimera_shot)
		end 
	elseif class == "DRUID" then 
		-- Do some druid rotation stuff
	end
end 