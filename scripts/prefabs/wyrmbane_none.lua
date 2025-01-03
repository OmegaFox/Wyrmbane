local assets =
{
	Asset( "ANIM", "anim/wyrmbane.zip" ),
	Asset( "ANIM", "anim/ghost_wyrmbane_build.zip" ),
}

local skins =
{
	normal_skin = "wyrmbane",
	ghost_skin = "ghost_wyrmbane_build",
}

return CreatePrefabSkin("wyrmbane_none",
{
	base_prefab = "wyrmbane",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"wyrmbane", "CHARACTER", "BASE"},
	build_name_override = "wyrmbane",
	rarity = "Character",
})