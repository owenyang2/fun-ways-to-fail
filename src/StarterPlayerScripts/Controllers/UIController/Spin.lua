local Spin = {}
Spin.__index = Spin

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

function Spin:SetupSpinUI()
    self.spinUI.Close.Activated:Connect(function()
        self.spinUI.Visible = false
    end)
end

function Spin:SetupAnims()
    self.UIFuncs.ApplyButtonClickAnim(self.spinUI.Close)

    local animatedButtons = {
        self.spinUI.Buy15,
        self.spinUI.Buy35,
        self.spinUI.SpinButton,
    }

    for _, button in ipairs(animatedButtons) do
        self.UIFuncs.ApplyButtonClickAnim(button, nil, 1.05, 1.05)
    end
end

function Spin:Start()
    self:SetupAnims()
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

        _trove = Trove.new()
    }), Spin)

    return self
end

return Spin