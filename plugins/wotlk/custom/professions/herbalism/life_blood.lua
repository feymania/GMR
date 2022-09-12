--- version : 0.3
--- Author : spwlz
--- Community : GMR

--- Changelog:
--- 0.3
 --> changed filename to follow git syntax
 --> changed local name for better understanding and learning effectivity for new members
--- 0.2
 --> cleaner code by Marty
--- 0.1
 --> initial beta release

local lifeblood = GetSpellInfo(55503) -- Life Blood

C_Timer.NewTicker(0.1, function()
    if not IsMounted() and GMR.IsExecuting() then
        if GMR.GetHealth("player") < 60 -- change to the percentage u want/need
         and GMR.IsCastable(lifeblood) then
            GMR.Cast(lifeblood, "player")
        end
    end
end)