-- ui functions that can be called for useful functions for all ui instances

local RepStorage = game:GetService("ReplicatedStorage")

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


return UIFunctions