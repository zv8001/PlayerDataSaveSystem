--[[
An open-source solution for easily storing player data
Scripted by VexTheProtogen: https://www.roblox.com/users/4071774573/profile

You can set values for a player by using the following syntax:

require(game.Players["PlayerName"].PlayerData).MainData["Example1"] = "whatever value here"

Important Notes:

You must hardcode all values. You cannot create new ones on the fly using a script.

Do not override a player's data table entirely—doing so will also prevent the data from saving. 

]]




local TemplatePlayerData = script.PlayerData
--[[
^^^^  This should be a module script structured in the following way:

local PlayerData = {}

PlayerData.MainData = {
	["Example1"] = 0;
	["Example2"] = false;
}


return PlayerData

]]
local DebugWarns = true
local MaxRetrys = 5 --The amount of times the game will try the data storage after failing before giving up


local DataStoreService = game:GetService("DataStoreService")
local GPlayerData = DataStoreService:GetDataStore("GPlayerData2")

local Players = game:GetService("Players")


local TemplatePlayerDatarequire = require(TemplatePlayerData)

local PlayerDataFailsafeCheckCompletedId = game:GetService("HttpService"):GenerateGUID()




local warn = function(...)
	if DebugWarns then
		warn(...)
	end
end

Players.PlayerAdded:Connect(function(Player)
	local ClonePlayerData = TemplatePlayerData:Clone()
	ClonePlayerData.Parent=Player
	ClonePlayerData.Name = "PlayerData"

	local LoadedPlayerDataTemplate = require(ClonePlayerData)	

	local function CheckIfInClonedPlayerData(Item)
		for Key,Value in pairs(LoadedPlayerDataTemplate.MainData) do
			if Key == Item then
				return true
			end
		end
		return false
	end
	
	local S = nil
	local Message = nil
	
	
	for i = 1,MaxRetrys do
		local S0,Message0 = pcall(function()
			return GPlayerData:GetAsync(Player.UserId)
		end)
		
		if S0 then
			S = S0
			Message = Message0
			break
		else
			warn("failed to receive player data retrying...")
			task.wait(2)
		end
	end
	
	
	if S then
		if Message ~= nil then
			for Key,Data in pairs(Message) do
				if CheckIfInClonedPlayerData(Key) then
					LoadedPlayerDataTemplate.MainData[Key] = Data
				end
			end
		else
		end

		Player:AddTag(PlayerDataFailsafeCheckCompletedId)
	else
		warn("")
		warn(Message)
	end
end)


local function checkforerrt(t)
	for i,v in pairs(t) do
		return false
	end
	return true
end

local function SavePlayerData(Player:Player)
	if Player:HasTag(PlayerDataFailsafeCheckCompletedId) then
		if Player:FindFirstChild("PlayerData") then
			local PlayerData = require(Player.PlayerData).MainData
			if checkforerrt(PlayerData) then warn("Main data table corruption detected table cannot be empty FAILED TO SAVE DATA") return false end

			local S,Message = pcall(function()
				GPlayerData:SetAsync(Player.UserId,PlayerData)
			end)
			
			if not S then
				warn("FAILED TO SAVE DATA")
				return false
			else
				return true
			end

		else
			warn("PlayerData table not found failed to save..")
		end
	else
		warn("Player data failed to save..")
	end
end

Players.PlayerRemoving:Connect(function(Player)
	for i = 1,MaxRetrys do
		if SavePlayerData(Player) then
			break
		end
		task.wait(1)
		warn("Failed to save data retrying....")
	end
	
end)

game:BindToClose(function()
	for _,Player in pairs(Players:GetPlayers()) do
		SavePlayerData(Player)
	end
end)
