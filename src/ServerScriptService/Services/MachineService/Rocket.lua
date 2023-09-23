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

function Rocket:SetNight()
    local tween = TweenService:Create(game.Lighting, self.Config.FlyTimeInfo, {ClockTime = self.Config.EndClockTime})
    tween:Play()
end

function Rocket:Start()
    self.Instance.Enter.Touched:Connect(function(part)
        local chr = part.Parent
        local plr = game.Players:GetPlayerFromCharacter(chr)

        if plr then
            local realRocket = self.Instance.Rocket
            realRocket.Transparency = 1
            realRocket.CanCollide = false

            local fakeRocket = realRocket:Clone() -- clone after make actual rocket disappear fixes camera clipping
            fakeRocket.Transparency = 0 -- because of above, reset transparency
            fakeRocket.Name = "FakeRocket"
            fakeRocket.Parent = self.Instance

            chr:SetPrimaryPartCFrame(fakeRocket.CFrame)

            local chrWeld = Instance.new("WeldConstraint")
            chrWeld.Part0 = chr.PrimaryPart
            chrWeld.Part1 = fakeRocket
            chrWeld.Parent = fakeRocket

            task.wait(self.Config.LaunchDelay)

            fakeRocket.Anchored = false
            fakeRocket.CanCollide = false

            local att = Instance.new("Attachment", fakeRocket)

            local launchVelo = Instance.new("LinearVelocity")
            launchVelo.Attachment0 = att
            launchVelo.MaxForce = math.huge
            launchVelo.VectorVelocity = self.Config.LaunchVelo
            launchVelo.Parent = fakeRocket

            chr.Humanoid.WalkSpeed = 0
            chr.Humanoid.JumpHeight = 0

            self:SetNight()
            task.wait(self.Config.FlyTime)

            fakeRocket.Anchored = true
            launchVelo:Destroy()

            task.wait(self.Config.DropDelay)

            chrWeld:Destroy()

            local plrNoGrav = Instance.new("LinearVelocity")
            plrNoGrav.Attachment0 = chr.HumanoidRootPart.RootRigAttachment
            plrNoGrav.MaxForce = math.huge
            plrNoGrav.VectorVelocity = self.Config.GravVelo
            plrNoGrav.Parent = chr

            chr.Humanoid.WalkSpeed = game.StarterPlayer.CharacterWalkSpeed
            chr.Humanoid.JumpHeight = game.StarterPlayer.CharacterJumpHeight

            for _, bodyPart in ipairs(self.BodyColors) do
                local tween = TweenService:Create(chr["Body Colors"], self.Config.TurnWhiteInfo, {[bodyPart] = self.Config.WhiteColor})
                tween:Play()
            end

            local kTween = TweenService:create(chr.Humanoid, self.Config.KillInfo, {Health = 0})
            kTween:Play()

            -- reset time when player respawns
            local tempConnect
            tempConnect = plr.CharacterAdded:Connect(function()
                tempConnect:Disconnect()
                game.Lighting.ClockTime = self.Config.DefaultClockTime
            end)

            task.wait(self.Config.KillInfo.Time + game.Players.RespawnTime)
            fakeRocket:Destroy()

            -- reset
            realRocket.CanCollide = true
            realRocket.Transparency = 0
        end
    end)
end

function Rocket.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Rocket.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,

        BodyColors = {
            "HeadColor3",
            "LeftArmColor3",
            "RightArmColor3",
            "LeftLegColor3",
            "RightLegColor3",
            "TorsoColor3"
        },

        Config = {
            TurnWhiteInfo = TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
            KillInfo = TweenInfo.new(7, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
    
            WhiteColor = Color3.fromRGB(255, 255, 255),
    
            CameraZoom = 50,
    
            DefaultClockTime = game.Lighting.ClockTime, -- default should be 14.5 unless it's manually changed
            EndClockTime = 24,
    
            LaunchVelo = Vector3.new(0, 75, 0),
            GravVelo = Vector3.new(0, -15, 0),
    
            LaunchDelay = 3,
            FlyTime = 7,
            DropDelay = 1.5,
        },

        _trove = Trove.new()
    }), Rocket)

    self.Config.FlyTimeInfo = TweenInfo.new(self.Config.FlyTime - 1, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

    return self
end

return Rocket