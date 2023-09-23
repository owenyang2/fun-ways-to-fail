local HydraulicPress = {}
HydraulicPress.__index = HydraulicPress

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

HydraulicPress.AvailableInstances = { -- available presses
    game.Workspace.PlaceModels:FindFirstChild("Hydraulic Press")
} 

local function findPartNormal(part)
    -- find which side of the part is being pressed (facing up) by casting a straight ray down above it, and checking the result's normal
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    params.FilterDescendantsInstances = {part}

    local result = workspace:Raycast(part.Position + Vector3.new(0, 1, 0), Vector3.new(0, -10, 0), params)

    if not result then return end

    return result.Normal
end

function HydraulicPress:Idle()
    self._trove:Connect(RunService.Heartbeat, function(dt)
        local parts = game.Workspace:GetPartsInPart(self.Instance.Hitbox, self.MachineFuncs.GetHitboxParams())
        local foundChrs = {}

        for _, part in ipairs(parts) do
            local chr = part:FindFirstAncestorOfClass("Model")

            if not game.Players:GetPlayerFromCharacter(chr) and not table.find(foundChrs, chr) then continue end

            table.insert(foundChrs, chr)
        end

        if #foundChrs > 0 then
            self:ChangeState("Pressing")
        end
    end)
end

function HydraulicPress:KillSquishedPlrs()
    local parts = game.Workspace:GetPartsInPart(self.Instance.TopPushHitbox, self.MachineFuncs.GetHitboxParams())

    print(parts)

    local doneChrs = {}

    for _, part in ipairs(parts) do
        local chr = part:FindFirstAncestorOfClass("Model")
        if not game.Players:GetPlayerFromCharacter(chr) and not table.find(doneChrs, chr) then return end
        if chr.Humanoid.FloorMaterial == Enum.Material.Air then return end -- if jumping

        table.insert(doneChrs, chr)

        chr.Humanoid.HumanoidDescription.HeadScale = 0 -- completely make head disappear for better visual
        chr.Humanoid:ApplyDescription(chr.Humanoid.HumanoidDescription)
        print("kill")
        chr.Humanoid.Health = 0
    end
end

function HydraulicPress:GetChrFacingDir(chr)
    local current = {}

    for _, dir in ipairs({"LookVector", "UpVector", "RightVector"}) do
        local yAmt = math.abs(chr.UpperTorso.CFrame[dir].Y) -- how much the part's face is facing up, use abs in case is facing down

        if current.Dir == nil or current.Amt < yAmt then
            current.Amt = yAmt
            current.Dir = dir
        end
    end

    return current.Dir
end

function HydraulicPress:Press()
    self._tweens.Press:Play()
    self._tweens.PressHitbox:Play()

    -- TODO: constantly detect player limbs facing up and squish them
    
    self._trove:Connect(RunService.Heartbeat, function(dt)
        local parts = game.Workspace:GetPartsInPart(self.Instance.TopPushHitbox, self.MachineFuncs.GetHitboxParams())

        local doneChrs = {}

        for _, part in ipairs(parts) do
            local chr = part:FindFirstAncestorOfClass("Model")
            if not game.Players:GetPlayerFromCharacter(chr) and not table.find(doneChrs, chr) then print("a") return end
            if chr.Humanoid.FloorMaterial == Enum.Material.Air then print("b") return end -- if jumping

            table.insert(doneChrs, chr)

            local dir = self:GetChrFacingDir(chr)
            local property = self.DirToScale[dir]

            if chr.Humanoid.HumanoidDescription[property] - self.Config.PressSizeDecrease > self.Config.PressLimit then
                print(chr.Humanoid.HumanoidDescription[property])
                chr.Humanoid.HumanoidDescription[property] -= self.Config.PressSizeDecrease
            else
                chr.Humanoid.HumanoidDescription[property] = self.Config.PressLimit
            end

            local least = math.huge

            for _, scale in pairs(self.DirToScale) do -- get averages of scaled down proportions to set head to
                if chr.Humanoid.HumanoidDescription[scale] < least then
                    least = chr.Humanoid.HumanoidDescription[scale]
                end
            end

            chr.Humanoid.HumanoidDescription.HeadScale = least
            chr.Humanoid:ApplyDescription(chr.Humanoid.HumanoidDescription)
        end
    end)

    self._tweens.Press.Completed:Wait()
    self._trove:Clean() -- so don't press after done

    self:KillSquishedPlrs()

    task.wait(self.Config.PressTime)

    self:ChangeState("Resetting")
end

function HydraulicPress:Reset()
    self._tweens.Reset:Play()
    self._tweens.ResetHitbox:Play()
    self._tweens.Reset.Completed:Wait()

    self:ChangeState("Idle")
end

function HydraulicPress:ChangeState(state)
    task.spawn(function() -- incase there is a wait, prevent freezing of main thread
        self._trove:Clean()

        if state == "Idle" then
            self:Idle()
        elseif state == "Pressing" then
            self:Press()
        elseif state == "Resetting" then
            self:Reset()
        end
    end)
end

function HydraulicPress:Start()
    self:ChangeState("Idle")
end

function HydraulicPress:CreateTweens()
    local info = TweenInfo.new(self.Config.LowerTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    local pushGoal = self.Instance.Press.CFrame + self.Config.PressHitboxOffset

    self._tweens = {
        Press = TweenService:Create(self.Instance.Press, info, {CFrame = pushGoal}), 
        PressHitbox = TweenService:Create(self.Instance.TopPushHitbox, info, 
            {CFrame = pushGoal - Vector3.new(0, self.Instance.TopPushHitbox.Size.Y, 0) - Vector3.new(0, self.Instance.Press.Size.Y / 2, 0)}
        ),
        
        Reset = TweenService:Create(self.Instance.Press, info, {CFrame = self.Instance.Press.CFrame}),
        ResetHitbox = TweenService:Create(self.Instance.TopPushHitbox, info, {CFrame = self.Instance.TopPushHitbox.CFrame}),
    }
end

function HydraulicPress.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(HydraulicPress.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        State = nil, -- Idle, Active, Resetting
        
        _trove = Trove.new(),

        DirToScale = {
            RightVector = "WidthScale",
            UpVector = "HeightScale",
            LookVector = "DepthScale",
        },

        Config = {
            MinPressAmt = 0.5, -- minimum lookvector component magnitude to compress that part's appropriate size
            PressSizeDecrease = 0.005, -- by how many studs should the part being pressed shrink
            LowerTime = 5,
            PressTime = 1,

            PressLimit = 0,

            PressHitboxOffset = Vector3.new(0, -9.04, 0)
        }
    }), HydraulicPress)

    self:CreateTweens()

    return self
end

return HydraulicPress