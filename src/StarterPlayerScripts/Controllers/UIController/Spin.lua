local Spin = {}
Spin.__index = Spin

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Knit = require(RepStorage.Packages.Knit)

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

function Spin:SetupWinSections()
    for i, data in ipairs(self.Sections) do
        local sectionFrame = self.spinUI.SpinWheel["Section" .. tostring(i)]
        print(i, data)
        sectionFrame.Percent.Text = tostring(math.round(data.Percent * 100)) .. "%"
        sectionFrame.Image = data.Image
    end
end

function Spin:FixRot() -- fix rot to make sure rotation doesn't exceed 360
    local currentRot = self.spinUI.SpinWheel.Rotation
    if currentRot >= 360 then
        self.spinUI.SpinWheel.Rotation -= (math.floor(currentRot / 360) * 360)
    end
end

function Spin:PlaySpinAnim(rewardNum)
    -- to get calculations to return to the beginning
    -- (initialSpeed - stopSpeed) * step = total steps
    -- total steps / 360 = total rotations (should be whole number to end at start pos)
    local initialSpeed = 73
    local speedDecrease = 1
    local stopSpeed = 1
    local step = 10

    -- set to zero before doing target calculations
    if self.spinUI.SpinWheel.Rotation ~= 0 then
        local timeToSetZero = ((360 - self.spinUI.SpinWheel.Rotation) / step) * (1 / initialSpeed) -- time it would take to get to setup if it were the fastest
        local setToZero = TweenService:Create(self.spinUI.SpinWheel, TweenInfo.new(timeToSetZero, Enum.EasingStyle.Linear), {Rotation = 360})
        setToZero:Play()
        setToZero.Completed:Wait()
        self:FixRot()    
    end

    -- setup start position, each section is 60 degrees
    local setupRot = (rewardNum - 1) * 60 + math.random(0, 59)-- random position within the section

    local timeToComplete = ((setupRot - self.spinUI.SpinWheel.Rotation) / step) * (1 / initialSpeed) -- time it would take to get to setup if it were the fastest
    local setupTween = TweenService:Create(self.spinUI.SpinWheel, TweenInfo.new(timeToComplete, Enum.EasingStyle.Linear), {Rotation = setupRot})
    
    setupTween:Play()
    setupTween.Completed:Wait()

    local currSpeed = initialSpeed
    while currSpeed > stopSpeed do
        local info = TweenInfo.new(1 / currSpeed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(self.spinUI.SpinWheel, info, {Rotation = math.max(self.spinUI.SpinWheel.Rotation + step)})
    
        tween:Play()
        tween.Completed:Wait()
        
        currSpeed -= speedDecrease
    end

    self:FixRot()
end

function Spin:SpinWheel()
    local rewardNum = self.SpinService:GenReward()

    if not rewardNum then -- spin in progress
        print("Current spin not finished!")
        return
    end

    self:PlaySpinAnim(rewardNum)
    self.SpinService:ClaimReward()
    print("Won " .. self.SpinService:GetSections()[rewardNum].Reward)
end

function Spin:SetupAnims()
    --self.UIFuncs.ApplyButtonClickAnim(self.spinUI.Close)

    local animatedButtons = {
        self.spinUI.Buy15,
        self.spinUI.Buy35,
        self.spinUI.SpinButton,
    }

    for _, button in ipairs(animatedButtons) do
        self.UIFuncs.ApplyButtonClickAnim(button, nil, 1.05, 1.05)
    end
end

function Spin:SetupSpinUI()
    self:SetupWinSections()
    self:SetupAnims()
    
    self.spinUI.Close.Activated:Connect(function()
        self.spinUI.Visible = false
    end)
    self.spinUI.SpinButton.Activated:Connect(function()
        self:SpinWheel()
    end)
end

function Spin:Start()
    self:SetupSpinUI()
end

function Spin.new(baseTbl)
    --[[ 
    baseTbl comes with:
        UIFuncs : ModuleScript
        MainUI : ScreenGui
        Player : Player
    --]]

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        spinUI = baseTbl.MainUI.Menus.SpinFrame,

        SpinService = Knit.GetService("SpinService"),
        _trove = Trove.new()
    }), Spin)

    self.Sections = self.SpinService:GetSections()

    return self
end

return Spin