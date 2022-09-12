local lifeblood = GetSpellInfo(55503) -- Life Blood

C_Timer.NewTicker(0.1, function()
    if not IsMounted() and GMR.IsExecuting() then
        if GMR.GetHealth("player") < 60 -- change to the percentage u want/need
         and GMR.IsCastable(lifeblood) then
            GMR.Cast(lifeblood, "player")
        end
    end
end)