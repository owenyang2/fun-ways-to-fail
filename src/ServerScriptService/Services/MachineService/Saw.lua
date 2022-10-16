local Saw = {}
Saw.__index = Saw

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

Saw.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Saw")
}

function Saw:GetSawList()
    local saws = {}

    for _, saw in ipairs(self.Instance:GetChildren()) do
        if saw.Name ~= "Saw" then continue end
        table.insert(saws, saw)
    end

    return saws
end

function Saw:Enable()
    for _, saw in ipairs(self.SawList) do
        task.spawn(function()
            while true do
                local tween = TweenService:Create(saw, self.SpinInfo, {CFrame = saw.CFrame * CFrame.Angles(0, 0, math.rad(180))})
                tween:Play()
                tween.Completed:Wait()
            end
        end)

        RunService.Heartbeat:Connect(function(dt)
            local parts = game.Workspace:GetPartsInPart(saw, self.MachineFuncs.GetHitboxParams())
    
            for _, part in ipairs(parts) do
                local chr = part.Parent
                local plr = game.Players:GetPlayerFromCharacter(chr)
                if not plr then return end
                
                for _, motor6d in ipairs(part:GetChildren()) do
                    if not motor6d:IsA("Motor6D") then continue end

                    if not motor6d.Enabled then
                        local socketJoint = part.Parent.RagdollJoints:FindFirstChild(motor6d.Name)

                        if socketJoint then
                            socketJoint:Destroy()
                        end
                    end

                    motor6d:Destroy()
                end
            end
        end)
    end
end

function Saw:Start()
    self:Enable()
end

function Saw.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Saw.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        SpinInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
        _trove = Trove.new(),
    }), Saw)

    self.SawList = self:GetSawList()

    print("new saw")

    return self
end

return Saw