--
-- This is an actual example of how trees_lib can be used
--

local modname = minetest.get_current_modname();

-- this is taken as an example from https://github.com/duane-r/valleys_c/blob/master/*
-- Create and initialize a table for a schematic.
local function vmg_schematic_array(width, height, depth)
        -- Dimensions of data array.
        local s = {size={x=width, y=height, z=depth}}
        s.data = {}

        for x = 0,width-1 do
                for y = 0,height-1 do
                        for z = 0,depth-1 do
                                local i = x*width*height + y*width + z + 1
                                s.data[i] = {}
                                s.data[i].name = "air"
                                s.data[i].param1 = 000
                        end
                end
        end

        s.yslice_prob = {}

        return s
end


-- this is taken as an example from https://github.com/duane-r/valleys_c/blob/master/deco_banana.lua
-- A shock of leaves at the top and some fruit.
local function vmg_generate_banana_schematic(trunk_height)
        local height = trunk_height + 3
        local radius = 1
        local width = 3
        local s = vmg_schematic_array(width, height, width)

        -- the main trunk
        for y = 0,trunk_height do
                local i = (0+radius)*width*height + y*width + (0+radius) + 1
                s.data[i].name = modname..":example_tree"
                s.data[i].param1 = 255
        end

        -- leaves at the top
        for x = -1,1 do
                for y = trunk_height+1, height-1 do
                        for z = -1,1 do
                                local i = (x+radius)*width*height + y*width + (z+radius) + 1
                                if y > height - 2 then
                                        s.data[i].name = modname..":example_leaves"
                                        if x == 0 and z == 0 then
                                                s.data[i].param1 = 255
                                        else
                                                s.data[i].param1 = 127
                                        end
                                elseif x == 0 and z == 0 then
                                        s.data[i].name = modname..":example_leaves"
                                        s.data[i].param1 = 255
                                elseif x ~= 0 or z ~= 0 then
                                        s.data[i].name = modname..":cfruit"
                                        s.data[i].param1 = 75
                                end
                        end
                end
        end

        return s
end


-- this function allows the tree to chose between diffrent growth functions (or provide its own)
local example_tree_select_how_to_grow = function( pos, node, sapling_data_how_to_grow, ground_found )
	-- grow into a normal fruit tree on dirt or grass
	if(     ground_found == "default:dirt"
	    or  ground_found == "default:dirt_with_grass" ) then
		return 1;

	-- if growing on desert sand, then grow like an acacia
	elseif( ground_found == "default:desert_sand" ) then
		return 2;
	-- on normal sand, grow like the banana tree from valleys_c
	elseif( ground_found == "default:sand" ) then
		return 3;

	-- on soil, grow like one of the birches from moretrees
	elseif( ground_found == "group:soil" ) then
		return math.random(4,5);

	-- stone is not the ideal ground to grow on...
	elseif( ground_found == "group:stone" ) then
		-- this shows that we can also return new tree types
		return {
				use_function = trees_lib.generate_unhappy_tree,
				xoff = 1, zoff = 1, yoff = 0, height = 3,
			};
	end
end


--- the actual example tree; it will grow in very diffrent ways depending on where it is placed;
-- most of the node names and descriptions can be created automaticly;
-- all we have to supply in such cases are the texture names
trees_lib.register_tree( "example",
	{  tree = {
		--node_name    = modname..":example_tree",
		--description  = "example Tree",
		tiles        = {"default_tree_top.png^[colorize:#015dbb70", "default_tree_top.png^[colorize:#015dbb70", "default_tree.png^[colorize:#015dbb70"},
	}, wood = {
		--node_name    = modname..":example_wood",
		--description  = "example Wooden Planks",
		tiles        = {"default_wood.png^[colorize:#015dbb70"},
	}, leaves = {
		--node_name    = modname..":example_leaves",
		--description  = "example Leaves",
		tiles        = {"default_leaves.png^[colorize:#01ffd870"},
		special_tiles= {"default_leaves_simple.png^[colorize:#01ffd870"},
	}, sapling = {
		--node_name    = modname..":example_sapling",
		--description  = "example Tree Sapling",
		tiles        = {"default_sapling.png^[colorize:#ff840170"},

		--rarity       = 20,
	}, fruit = {
		-- the fruit diverges in name and description from what would automaticly be created
		node_name    = modname..":cfruit",
		description  = "Yellow Copper Fruit",
		tiles        = {"default_copper_lump.png^[colorize:#e3ff0070"},
		-- the fruit can be eaten
		on_use = minetest.item_eat(2),
	}},
	-- the diffrent ways of how a tree can be grown
	{
		    -- version 1
		-- one of these methods will be choosen randomly
		{
			-- a function - like that used to create the trees/apple trees in mapgen v6
			use_function = trees_lib.generate_fruit_tree,
			-- How far will the tree reach in each direction? We need to load a
			-- sufficiently large voxelmanip area.
			xoff = 2, zoff = 2, yoff = 0, height = 12,
		}, { -- version 2
			-- schematics can be used as well
			use_schematic = minetest.get_modpath("default").."/schematics/acacia_tree_from_sapling.mts",
			-- TODO: determine these values automaticly
			xoff = 4, zoff = 4, yoff = 0, height = 10,
			-- use a schematic with diffrent nodes
			use_replacements = {
				{"default:acacia_tree",  modname..":example_tree"},
				{"default:acacia_leaves",modname..":example_leaves"},
			}
		}, { -- version 3
			-- schematics in table form are also acceptable
			use_schematic = vmg_generate_banana_schematic(3),
			-- TODO: determine these values automaticly
			xoff = 1, zoff = 1, yoff = 0, height = 8,
			-- TODO: minetest.place_schematic does not apply replacements for tables
			-- use a schematic with diffrent nodes
			use_replacements = {
				{"default:acacia_tree",  modname..":example_tree"},
				{"default:acacia_leaves",modname..":example_leaves"},
			}
		}, { -- version 4
			-- this is moretrees.birch_model1
			use_lsystem = {
				axiom="FFFFFdddccA/FFFFFFcA/FFFFFFcB",
				rules_a="[&&&dddd^^ddddddd][&&&---dddd^^ddddddd][&&&+++dddd^^ddddddd][&&&++++++dddd^^ddddddd]",
				rules_b="[&&&ddd^^ddddd][&&&---ddd^^ddddd][&&&+++ddd^^ddddd][&&&++++++ddd^^ddddd]",
				rules_c="/",
				rules_d="F",
				trunk=modname..":example_tree", --"moretrees:birch_trunk",
				leaves=modname..":example_leaves", --"moretrees:birch_leaves",
				angle=30,
				iterations=2,
				random_level=0,
				trunk_type="single",
				thin_branches=true
			}
		},{ -- version 5
			-- this is moretrees.birch_model2
			use_lsystem = {
				axiom="FFFdddccA/FFFFFccA/FFFFFccB",
				rules_a="[&&&dFFF^^FFFdd][&&&---dFFF^^FFFdd][&&&+++dFFF^^FFFdd][&&&++++++dFFF^^FFFdd]",
				rules_b="[&&&dFF^^FFFd][&&&---dFFF^^FFFd][&&&+++dFF^^FFFd][&&&++++++dFF^^FFFd]",
				rules_c="/",
				rules_d="F",
				trunk=modname..":example_tree", --"moretrees:birch_trunk",
				leaves=modname..":example_leaves", --"moretrees:birch_leaves",
				angle=30,
				iterations=2,
				random_level=0,
				trunk_type="single",
				thin_branches=true
			}
		},
	},
	-- grows_on_node_type_list - the tree only grows on nodes of this type
	{"default:cobble", "group:soil", "default:dirt", "default:dirt_with_grass", "default:desert_sand","default:sand","group:soil","group:stone"},
	-- no (additional) limits as to where the tree can grow (no can_grow_function)
	nil,
	-- the tree will grow in a diffrent way depending on the ground it grows on; see the function below for details
	example_tree_select_how_to_grow,
	-- the interval for the sapling-growing abm in seconds
	10,
	-- the chance of the abm actually firing and growing the sapling (the higher the smaller)
	1
);

