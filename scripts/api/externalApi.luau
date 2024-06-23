--!strict
-- external api globals/methods or things that aren't defined in the api dump

return {
	vars = {
		["P1"] = "Player",
		["P2"] = "Player",

		--> mirin template
		["foreground"] = "ActorFrame",
		["scx"] = "number",
		["scy"] = "number",
		["sw"] = "number",
		["sh"] = "number",
		["dw"] = "number",
		["dh"] = "number",
	},

	funcs = {
		-- mirin template
		-- TODO: add the rest later
		["aft"] = { args = { { name = "self", type = "ActorFrameTexture" } }, returns = {} },
		["sprite"] = { args = { { name = "self", type = "Sprite" } }, returns = {} },
		["backToSongWheel"] = { args = { { name = "message", type = "string" } }, returns = {} },
	},
}
