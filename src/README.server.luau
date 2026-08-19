--[[
		-- README

		If you didn't save in Binary (rbxl) - it's recommended to save the game right away to take advantage of the binary format & to preserve values of certain properties if you used IgnoreDefaultProperties setting (as they might change in the future).
		You can do that by going to FILE -> Save to File As -> Make sure File Name ends with .rbxl -> Save

		ServerStorage, ServerScriptService and Server Scripts are IMPOSSIBLE to save because of FilteringEnabled.

		If your player cannot spawn into the game, please move the scripts in StarterPlayer somewhere else or delete them. Then run `game:GetService("Players").CharacterAutoLoads = true`.
		And use "Play Here" to start game instead of "Play" to spawn your Character where your Camera currently is.

		If the chat system does not work, please use the explorer and delete everything inside the TextChatService/Chat service(s). 
		Or run `game:GetService("Chat"):ClearAllChildren() game:GetService("TextChatService"):ClearAllChildren()`
				
		If Union and MeshPart collisions don't work, run the script below in the Studio Command Bar:
				
				
		local C = game:GetService("CoreGui")
		local D = Enum.CollisionFidelity.Default
				
		for _, v in game:GetDescendants() do
			if v:IsA("TriangleMeshPart") and not v:IsDescendantOf(C) then
				v.CollisionFidelity = D
			end
		end
		print("Done")
				
		If you can't move the Camera, run this script in the Studio Command Bar:
			
		workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
		
		Or Destroy the Camera.

		This file was generated with the following settings:
		{"SavePlayerCharacters":false,"SaveBytecode":false,"Callback":false,"ShowStatus":true,"IgnoreDefaultPlayerScripts":true,"NilInstancesFixes":{"BaseWrap":null,"Animator":null,"Attachment":null,"PackageLink":null,"AdPortal":null},"IgnoreList":["CoreGui","CorePackages"],"__DEBUG_MODE":false,"KillAllScripts":true,"DecompileJobless":false,"Decompile":true,"IgnoreNotArchivable":true,"Object":false,"DecompileIgnore":["TextChatService",null,null,null,null,null,null],"IgnoreSpecialProperties":true,"BoostFPS":true,"IsModel":false,"NilInstances":false,"ExtraInstances":[],"ReadMe":true,"OptionsAliasesInverse":{"noscripts":"Decompile","RemovePlayers":"IsolatePlayers","RemovePlayerCharacters":"SavePlayerCharacters"},"OptionsAliases":{"DecompileScripts":"Decompile","timeout":"DecompileTimeout","StatusText":"ShowStatus","SavePlayers":"IsolatePlayers","FileName":"FilePath","SaveCharacters":"SavePlayerCharacters","SaveNilInstances":"NilInstances","IgnoreArchivable":"IgnoreNotArchivable","SaveNonCreatable":"SaveNotCreatable","SaveLocalPlayer":"IsolateLocalPlayer","InstancesBlacklist":"IgnoreList","IsolatePlayerGui":"IsolateLocalPlayer","SavePlayerGui":"IsolateLocalPlayer","IgnoreDefaultProps":"IgnoreDefaultProperties"},"IgnoreSharedStrings":false,"TreatUnionsAsParts":false,"scriptcache":true,"SharedStringOverwrite":false,"AlternativeWritefile":true,"mode":"optimized","SaveCacheInterval":56320,"NotCreatableFixes":["","AdvancedDragger","AnimationTrack","Dragger","Player","PlayerGui","PlayerMouse","PlayerMouse","PlayerScripts","ScreenshotHud","StudioData","TextChatMessage","TextSource","TouchTransmitter","Translator"],"IsolatePlayers":false,"BytecodeTimeout":3,"FilePath":false,"IgnoreDefaultProperties":true,"Anonymous":false,"IsolateStarterPlayer":false,"IsolateLocalPlayerCharacter":false,"IgnorePropertiesOfNotScriptsOnScriptsMode":false,"AvoidFileOverwrite":true,"SaveNotCreatable":false,"IsolateLocalPlayer":false,"ShutdownWhenDone":false,"AntiIdle":true,"SafeMode":true,"IgnoreProperties":[],"DecompileTimeout":10}

		Elapsed time: 23.187312666666685 Date (UTC): 27 July 2026 18:31:12 PlaceId: 8542259458 PlaceVersion: 399 Client Version: 2.729.838 Platform: IOS Executor: Delta 1.0.729.838 arm64
]]
