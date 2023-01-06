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
        local plr = game.Players:GetPlayerFromCharacter(chr)

        if plr then
            local realRocket = self.Instance.Rocket

            local rocketModel = realRocket:Clone()
            rocketModel.Name = "FakeRocket"
            rocketModel.Parent = self.Instance

            for _, part in ipairs(realRocket:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                    part.CanCollide = false
                end
            end

            chr:SetPrimaryPartCFrame(rocketModel.PrimaryPart.CFrame)

            local chrWeld = Instance.new("WeldConstraint")
            chrWeld.Part0 = chr.PrimaryPart
            chrWeld.Part1 = rocketModel.PrimaryPart
            chrWeld.Parent = rocketModel

            task.wait(self.DelayTime)

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

            local launchVelo = Instance.new("LinearVelocity")
            launchVelo.Attachment0 = att
            launchVelo.MaxForce = math.huge
            launchVelo.VectorVelocity = self.LaunchVelo
            launchVelo.Parent = rocketModel.PrimaryPart

            chr.Humanoid.WalkSpeed = 0
            chr.Humanoid.JumpHeight = 0

            task.wait(self.FlyTime)

            launchVelo:Destroy()
            for _, obj in ipairs(rocketModel:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Anchored = true
                end
            end
            chrWeld:Destroy()

            local plrNoGrav = Instance.new("LinearVelocity")
            plrNoGrav.Attachment0 = chr.HumanoidRootPart.RootRigAttachment
            plrNoGrav.MaxForce = math.huge
            plrNoGrav.VectorVelocity = self.GravVelo
            plrNoGrav.Parent = chr

            chr.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
            chr.Humanoid.JumpHeight = game.StarterPlayer.CharacterJumpHeight

            for _, bodyPart in ipairs(self.BodyColors) do
                local tween = TweenService:Create(chr["Body Colors"], self.TurnWhiteInfo, {[bodyPart] = self.WhiteColor})
                tween:Play()
            end

            local kTween = TweenService:create(chr.Humanoid, self.KillInfo, {Health = 0})
            kTween:Play()

            task.wait(self.KillInfo.Time + 3)
            rocketModel:Destroy()

            -- reset

            for _, part in ipairs(realRocket:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
        end
    end)
end

function Rocket.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Rocket.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,

        LaunchVelo = Vector3.new(0, 75, 0),
        GravVelo = Vector3.new(0, -15, 0),

        DelayTime = 3,
        FlyTime = 7,
        
        BodyColors = {
            "HeadColor3",
            "LeftArmColor3",
            "RightArmColor3",
            "LeftLegColor3",
            "RightLegColor3",
            "TorsoColor3"
        },

        TurnWhiteInfo = TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
        KillInfo = TweenInfo.new(7, Enum.EasingStyle.Sine, Enum.EasingDirection.In),

        WhiteColor = Color3.fromRGB(255, 255, 255),

        CameraZoom = 50,

        _trove = Trove.new()
    }), Rocket)

    return self
end

return Rocket