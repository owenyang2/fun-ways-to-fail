local RepStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local Ragdoll = require(script.Parent.Parent.Classes.Ragdoll)

local Knit = require(RepStorage.Packages.Knit)

local RagdollService = Knit.CreateService {
    Name = "RagdollService",
    Client = {
        Reset = Knit.CreateSignal()
    }
}

local function getRagdollInst(plr)
    local ragdollInst = Ragdoll.GlobalRagdolls[plr]

    if not ragdollInst then warn("Could not find player's ragdoll instance.") return end

    return ragdollInst
end

function RagdollService.Client:ToggleRagdoll(plr, enable)
    local ragdollInst = getRagdollInst(plr)

    if enable ~= nil then
        ragdollInst:Toggle(enable)
    else
        ragdollInst:Toggle()
    end
end

function RagdollService.Client:EditCanRagdoll(plr, canRagdoll)
    local ragdollInst = getRagdollInst(plr)
    
    ragdollInst:EditCanRagdoll(canRagdoll)
end

function RagdollService.Client:GetRagdollStatus(plr)
    -- returns if ragdolled or not
    local ragdollInst = getRagdollInst(plr)

    return ragdollInst.Ragdolled
end

function RagdollService.Client:CheckCanRagdoll(plr)
    -- returns if can ragdoll
    local ragdollInst = getRagdollInst(plr)

    return ragdollInst.CanRagdoll
end

function RagdollService:SetupSignals()
    self.Client.Reset:Connect(function(plr)
        if not plr.Character then return end
        print("reset")

        plr.Character.Humanoid.Health = 0
    end)
end

function RagdollService:KnitInit()
    self.COLLISION_GROUP = "Players"
    PhysicsService:CreateCollisionGroup(self.COLLISION_GROUP)
end

function RagdollService:KnitStart()
    self.ProfileManager = Knit.GetService("ProfileManager")
    
    game.Players.PlayerAdded:Connect(function(plr)
        local ragdoll = Ragdoll.new(plr)
        ragdoll:Toggle(true)

        plr.CharacterAdded:Connect(function(chr)
            for _, part in ipairs(chr:GetDescendants()) do
                if not part:IsA("BasePart") then continue end
                
                PhysicsService:SetPartCollisionGroup(part, self.COLLISION_GROUP)
            end
        end)
    end)
    
    game.Players.PlayerRemoving:Connect(function(plr)
        if Ragdoll.GlobalRagdolls[plr] then
            Ragdoll.GlobalRagdolls[plr]:Destroy()
        end
    end)

    self:SetupSignals()
end

return RagdollService