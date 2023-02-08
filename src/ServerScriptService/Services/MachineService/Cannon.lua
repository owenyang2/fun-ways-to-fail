local Cannon = {}
Cannon.__index = Cannon

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

Cannon.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Cannon")
}

function Cannon:Start()
    self.Instance.CannonLauncher.Enter.Triggered:Connect(function(plr)
        plr.Character:SetPrimaryPartCFrame(CFrame.new(self.Instance.LaunchPart.Position))
        
        local ragdoll = Ragdoll.GlobalRagdolls[plr]
        ragdoll:Toggle(true)
        ragdoll:EditCanRagdoll(false)
 
        local launchVelo = Instance.new("LinearVelocity")
        launchVelo.Attachment0 = plr.Character.HumanoidRootPart.RootRigAttachment
        launchVelo.MaxForce = math.huge
        launchVelo.VectorVelocity = self.LaunchForce
        launchVelo.Parent = plr.Character
        
        task.wait(self.LaunchTime)

        launchVelo:Destroy()

        --task.wait(self.KillTime) -- mabe instead use .touched on ground
       
        local done = false

        for _, part in ipairs(plr.Character:GetChildren()) do
            if not part:IsA("BasePart") then continue end

            part.Touched:Connect(function(hit)
                if hit == game.Workspace.Map.Baseplate and not done then
                    done = true
                    ragdoll:EditCanRagdoll(true)
                    ragdoll:Toggle(false)
                    plr.Character.Humanoid.Health = 0            
                end
            end)
        end
    end)
end

function Cannon.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Cannon.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        LaunchForce = Vector3.new(-100, 150, 0),
        LaunchTime = 1,
        KillTime = 3,

        _trove = Trove.new()
    }), Cannon)

    return self
end

return Cannon