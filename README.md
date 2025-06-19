# An extremely easy way of storing player data

An open-source solution for easily storing player data
Scripted by VexTheProtogen: https://www.roblox.com/users/4071774573/profile

You can set values for a player by using the following syntax:

require(game.Players["PlayerName"].PlayerData).MainData["Example1"] = "whatever value here"

Important Notes:

You must hardcode all values. You cannot create new ones on the fly using a script.

Do not override a player's data table entirely—doing so will also prevent the data from saving. 
