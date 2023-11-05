-- ui functions that can be called for useful functions for all ui instances

local RepStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Trove = require(RepStorage.Packages.Trove)

local UIFunctions = {}

-- copied from devforum
function UIFunctions.AbbreviateNumber(number)
    local abbreviations = {"K","M","B","T","Qd","Qn","Sx","Sp","O","N"}

	local abbreviationIndex = math.floor(math.log(number,1000))
	local abbreviation = abbreviations[abbreviationIndex]

	if abbreviation then
		local shortNum = number/(1000^abbreviationIndex)
		local intNum = math.floor(shortNum)
		local str = intNum .. abbreviation
		if intNum < shortNum then
			str = str .. "+"
		end
		return str
	else
		return tostring(number)
	end
end

function UIFunctions.ApplyButtonClickAnim(button, info, shrinkFactor, expandFactor)
	info = info or TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	shrinkFactor = shrinkFactor or 1.15
	expandFactor = expandFactor or 1.15

	local origButtonSize = button.Size
	local buttonTrove = Trove.new()

	local shrinkTween = TweenService:Create(button, info, {Size = UDim2.fromScale(origButtonSize.X.Scale / shrinkFactor, origButtonSize.Y.Scale / shrinkFactor)})
	local expandTween = TweenService:Create(button, info, {Size = UDim2.fromScale(origButtonSize.X.Scale * expandFactor, origButtonSize.Y.Scale * expandFactor)})
	local revertTween = TweenService:Create(button, info, {Size = origButtonSize})

	local inArea = false

	buttonTrove:Connect(button.MouseButton1Down, function()
		shrinkTween:Play()
	end)

	buttonTrove:Connect(button.MouseButton1Up, function()
		if inArea then
			expandTween:Play()
		else
			revertTween:Play()
		end
	end)

	buttonTrove:Connect(button.MouseLeave, function()
		inArea = false
		revertTween:Play()
	end)
	
	buttonTrove:Connect(button.MouseEnter, function()
		inArea = true
		expandTween:Play()
	end)

	return buttonTrove
end

return UIFunctions