local Ragdoll = require(script.Parent.Classes.Ragdoll)

game.Players.PlayerAdded:Connect(function(plr)
    local ragdoll = Ragdoll.new(plr)
    ragdoll:Enable()
end)

game.Players.PlayerRemoving:Connect(function(plr)
    if Ragdoll.GlobalRagdolls[plr] then
        Ragdoll.GlobalRagdolls[plr]:Destroy()
    end
end)