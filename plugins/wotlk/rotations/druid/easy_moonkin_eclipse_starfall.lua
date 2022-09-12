C_Timer.NewTicker(0.1, function()
	if UnitClass("player") == "Druid" then 

		-- Spells
     faeriefire = GetSpellInfo(770)
     moonfire = GetSpellInfo(26988)
     insectswarm = GetSpellInfo(27013)
     starfall = GetSpellInfo(53199)
     forceofnature = GetSpellInfo(33831)
     wrath = GetSpellInfo(26985)
     starfire = GetSpellInfo(26986)
	 typhoon = GetSpellInfo(53225)
	 naturesgrasp = GetSpellInfo(27009)
	 lunareclipse = GetSpellInfo(48518)
	 solareclipse = GetSpellInfo(48517)
	 
  

		if not mounted and GMR.IsExecuting() and GMR.InLoS("target") and UnitExists("target") then
		  if AuraUtil.FindAuraByName("Moonkin Form", "player", "HELPFUL") then
		    if UnitAffectingCombat("player") then
			  -- Typhoon
			  if GetSpellInfo(typhoon) and IsUsableSpell(typhoon) and GMR.IsCastable(typhoon, "target") and GetSpellCooldown(typhoon) == 0 and GMR.GetHealth("target") > 15 and GMR.GetDistance("player", "target", "<", 19) then
			  GMR.Cast(typhoon)
			  end  
			  -- Faerie Fire
			  if GetSpellInfo(faeriefire) and GetSpellCooldown(faeriefire) == 0 and not
			  AuraUtil.FindAuraByName(faeriefire, "target", "HARMFUL") and GMR.GetHealth("target") > 60 then
			  GMR.Cast(faeriefire)
			  -- print("Faerie Fire")
			  end
			  -- Starfall
			  if GetSpellInfo(starfall) and IsUsableSpell(starfall) and GetSpellCooldown(starfall) == 0 and GMR.GetHealth("target") > 50 then
			  GMR.Cast(starfall)
			  -- print("Starfall")	
			  end
			  -- Eclipse Starfire
			  if GetSpellInfo(starfire) and IsUsableSpell(starfire) and GMR.IsCastable(starfire, "target") and AuraUtil.FindAuraByName("Eclipse (Lunar)", "player", "HELPFUL") then
              GMR.Cast(starfire)
              -- print("Starfire")	
			  end					  
			  -- Moonfire
			  if GetSpellInfo(moonfire) and IsUsableSpell(moonfire) and not AuraUtil.FindAuraByName(moonfire, "target", "HARMFUL") and not AuraUtil.FindAuraByName("Eclipse (Lunar)", "player", "HELPFUL") and not AuraUtil.FindAuraByName("Eclipse (Solar)", "player", "HELPFUL") and GMR.GetHealth("target") > 5 then
              GMR.Cast(moonfire)
              -- print("Moonfire")	
			  end		  
			  -- Insectswarm
			  if GetSpellInfo(insectswarm) and IsUsableSpell(insectswarm) and GMR.GetHealth("target") > 30 and not AuraUtil.FindAuraByName(insectswarm, "target", "HARMFUL") and not AuraUtil.FindAuraByName("Eclipse (Lunar)", "player", "HELPFUL") and not AuraUtil.FindAuraByName("Eclipse (Solar)", "player", "HELPFUL") and not (UnitCreatureType("target") == "Elemental") then
              GMR.Cast(insectswarm)
              -- print("Insectswarm")	  
			  end
			  -- Wrath
			  if GetSpellInfo(wrath) and IsUsableSpell(wrath) and GMR.IsCastable(wrath, "target") and not AuraUtil.FindAuraByName("Eclipse (Lunar)", "player", "HELPFUL") and not (UnitCreatureType("target") == "Elemental") then
              GMR.Cast(wrath)
              -- print("Wrath")	
			  end
			  -- Starfire
			  if GetSpellInfo(starfire) and IsUsableSpell(starfire) and GMR.IsCastable(starfire, "target") and (UnitCreatureType("target") == "Elemental") then
              GMR.Cast(starfire)
              -- print("Starfire")	
			  end
			else
			  -- Starfall
			  if GetSpellInfo(starfall) and IsUsableSpell(starfall) and GetSpellCooldown(starfall) == 0 and GMR.GetHealth("target") > 50 then
			  GMR.Cast(starfall)
			  -- print("Starfall")	
			  end			
			  if GetSpellInfo(starfire) and IsUsableSpell(starfire) and GMR.IsCastable(starfire, "target") and GMR.GetHealth("target") >= 100 then
              GMR.Cast(starfire)
              -- print("Starfire")	
			  end
			  -- Faerie Fire
			  if GetSpellInfo(faeriefire) and GetSpellCooldown(faeriefire) == 0 and not
			  AuraUtil.FindAuraByName(faeriefire, "target", "HARMFUL") and GMR.GetHealth("target") > 51 then
			  GMR.Cast(faeriefire)
			  -- print("Faerie Fire")
			  end
			  -- Moonfire
			  if GetSpellInfo(moonfire) and IsUsableSpell(moonfire) and not AuraUtil.FindAuraByName(moonfire, "target", "HARMFUL") and GMR.GetHealth("target") < 50 then
              GMR.Cast(moonfire)
              -- print("Moonfire")	
			  end		  			  
			end
		  end 
		end
	end
end)