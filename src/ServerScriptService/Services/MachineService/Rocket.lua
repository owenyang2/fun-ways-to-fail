local Rocket = {}
Rocket.__index = Rocket

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

Rocket.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Rocket")
}

function Rocket:Start()
    self.Instance.Enter.Touched:Connect(function(part)
        local chr = part.Parent

        if game.Players:GetPlayerFromCharacter(chr) then
            local rocketModel = self.Instance.Rocket

            chr:SetPrimaryPartCFrame(rocketModel.PrimaryPart.CFrame)

            local chrWeld = Instance.new("WeldConstraint")
            chrWeld.Part0 = chr.PrimaryPart
            chrWeld.Part1 = rocketModel.PrimaryPart
            chrWeld.Parent = rocketModel

            rocketModel.PrimaryPart.Anchored = false
            rocketModel.PrimaryPart.CanCollide = false

            for _, rocketPart in ipairs(rocketModel:GetChildren()) do
                if not rocketPart:IsA("BasePart") or rocketPart == rocketModel.PrimaryPart then continue end
                rocketPart.Anchored = false
                rocketPart.CanCollide = false

                local weld = Instance.new("WeldConstraint")
                weld.Part0 = rocketModel.PrimaryPart
                weld.Part1 = rocketPart
                weld.Parent = rocketPart
            end

            local att = Instance.new("Attachment", rocketModel.PrimaryPart)

            local vf = Instance.new("VectorForce")
            vf.Attachment0 = att
            vf.Force = Vector3.new(0, 1000000, 0)
            vf.ApplyAtCenterOfMass = true
            vf.Parent = rocketModel.PrimaryPart
        end
    end)
end

function Rocket.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Rocket.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        
        _trove = Trove.new()
    }), Rocket)

    return self
end

return Rocket