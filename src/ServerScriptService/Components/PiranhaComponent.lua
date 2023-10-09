local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Knit = require(RepStorage.Packages.Knit)
local Component = require(RepStorage.Packages.Component)
local MachineFuncs = require(RepStorage.Common.MachineFunctions)
local Trove = require(RepStorage.Packages.Trove)

local Piranha = Component.new {
    Tag = "Piranha"
}

function Piranha:TargetMovement()
    local targetPlr = self.FollowBehaviour.FollowingPlr

    self.Instance.AlignPosition.Enabled = false
    self.Instance.AlignOrientation.Enabled = false
    self.Instance.LinearVelocity.Enabled = true

    self.Instance:SetNetworkOwner(self.FollowBehaviour.FollowingPlr)

    local counter = self.FollowBehaviour.VeloDelay -- immediately start folliwng player
    local didKill = false -- is this the piranha that killed

    self._trove:Connect(RunService.Heartbeat, function(dt)
        counter += dt
        if counter < self.FollowBehaviour.VeloDelay then return end

        if targetPlr.Character.Humanoid.Health == 0 then
            if didKill then return end

            self._trove:Clean()
            self:DefaultMovement()
        end

        self.Instance.LinearVelocity.VectorVelocity = (targetPlr.Character.HumanoidRootPart.Position - self.Instance.Position).Unit * self.FollowBehaviour.Speed
        
        local parts = game.Workspace:GetPartsInPart(self.Instance, MachineFuncs.GetHitboxParams())

        for _, part in ipairs(parts) do
            local plr = game.Players:GetPlayerFromCharacter(part:FindFirstAncestorOfClass("Model"))
            if not plr then continue end

            didKill = true

            plr.Character.Humanoid.Health = 0
            self.Instance.LinearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
            Debris:AddItem(self.Instance, game.Players.RespawnTime)
            self._trove:Clean()
            break
        end
    end)

    print("?")
end

function Piranha:DefaultMovement()
    self.Instance.AlignPosition.Enabled = true
    self.Instance.AlignOrientation.Enabled = true
    self.Instance.LinearVelocity.Enabled = false

    self._trove:Connect(RunService.Heartbeat, function(dt) -- in the future, maybe use perlin noise to make fish swim left/right, up/down random
        if self.DefaultBehaviour.Deg == 360 then
            self.DefaultBehaviour.Deg = 0
        end

        local x = self.DefaultBehaviour.Radius * math.cos(math.rad(self.DefaultBehaviour.Deg))
        local z = self.DefaultBehaviour.Radius * math.sin(math.rad(self.DefaultBehaviour.Deg))

        self.Instance.AlignPosition.Position = self.ParentInst.Water.Position + Vector3.new(-x, 0, -z) + self.DefaultBehaviour.Offset
        self.Instance.AlignOrientation.CFrame = CFrame.Angles(0, math.rad(-self.DefaultBehaviour.Deg), 0)
        
        self.DefaultBehaviour.Deg += self.DefaultBehaviour.DegInc

        -- check plr in radius

        local parts = game.Workspace:GetPartBoundsInRadius(self.Instance.Position, self.FollowBehaviour.DetectionRad, MachineFuncs.GetHitboxParams())

        for _, part in ipairs(parts) do
            local chr = part:FindFirstAncestorOfClass("Model")
            local plr = game.Players:GetPlayerFromCharacter(chr)
            if not plr or chr.Humanoid.Health == 0 then continue end

            self.FollowBehaviour.FollowingPlr = plr
            self._trove:Clean()
            self:TargetMovement()

            return
        end
    end)
end

function Piranha:Setup()
    self:DefaultMovement()
end

function Piranha:Start(part, parentInst)
    self.ParentInst = game.Workspace.PlaceModels.Piranhas
    self.DefaultBehaviour = {
        Radius = math.random(7, self.ParentInst.Water.Size.Z / 2 - 7),
        Deg = math.random(0, 359),
        DegInc = math.random(50, 150) / 100,
        --Offset = Vector3.new(math.random(-50, 50), math.random(-2, 2), math.random(-50, 50))
        Offset = Vector3.new(math.random(-5, 5), math.random(-0.5, 0.5), math.random(-5, 5))
    }

    self.FollowBehaviour = {
        DetectionRad = 10,
        FollowingPlr = nil,
        TweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        VeloDelay = 0.5,
        Speed = 50
    }

    self._trove = Trove.new()

	self:Setup()
end

return Piranha