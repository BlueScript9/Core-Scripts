local source = [[
local function Run(ChatService)
	
	local function DoWhisperCommand(fromSpeaker, message, channel)
		local speaker = ChatService:GetSpeaker(fromSpeaker)
		local channelObj = ChatService:GetChannel("To " .. message)
		if (channelObj and ChatService:GetSpeaker(message)) then
			
			if (channelObj.Name == "To " .. speaker.Name) then
				speaker:SendSystemMessage("You cannot whisper to yourself.", nil)
			else
				if (not speaker:IsInChannel(channelObj.Name)) then
					speaker:JoinChannel(channelObj.Name)
				end
			end
			
			
		else
			speaker:SendSystemMessage("Speaker '" .. message .. "' does not exist.", nil)
		end
	end
	
	local function WhisperCommandsFunction(fromSpeaker, message, channel)
		if (string.sub(message, 1, 3):lower() == "/w ") then
			DoWhisperCommand(fromSpeaker, string.sub(message, 4), channel)
			return true
			
		elseif (string.sub(message, 1, 9):lower() == "/whisper ") then
			DoWhisperCommand(fromSpeaker, string.sub(message, 10), channel)
			return true
			
		end
		
		return false
	end
	
	local function PrivateMessageReplicationFunction(fromSpeaker, message, channel)
		ChatService:GetSpeaker(fromSpeaker):SendMessage(fromSpeaker, channel, message)

		local toSpeaker = ChatService:GetSpeaker(string.sub(channel, 4))
		if (toSpeaker) then
			if (not toSpeaker:IsInChannel("To " .. fromSpeaker)) then
				toSpeaker:JoinChannel("To " .. fromSpeaker)
			end
			toSpeaker:SendMessage(fromSpeaker, "To " .. fromSpeaker, message)
		end
		
		return true
	end
	
	ChatService:RegisterProcessCommandsFunction("whisper_commands", WhisperCommandsFunction)
	
	ChatService.OnSpeakerAdded:connect(function(speakerName)
		if (ChatService:GetChannel("To " .. speakerName)) then
			ChatService:RemoveChannel("To " .. speakerName)
		end
		
		local channel = ChatService:AddChannel("To " .. speakerName)
		channel.Joinable = false
		channel.Private = true
		channel.Leavable = true
		channel.AutoJoin = false
		
		channel.WelcomeMessage = "You are now privately chatting with " .. speakerName .. "."
		
		channel:RegisterProcessCommandsFunction("replication_function", PrivateMessageReplicationFunction)
	end)
	
	ChatService.OnSpeakerRemoved:connect(function(speakerName)
		if (ChatService:GetChannel(speakerName)) then
			ChatService:RemoveChannel(speakerName)
		end
	end)
end

return Run
]]


local generated = Instance.new("ModuleScript")
generated.Name = "Generated"
generated.Source = source
generated.Parent = script