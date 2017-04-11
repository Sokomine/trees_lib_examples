
These are examples as to how trees_lib for Minetest can be used.

Files:
	init.lua                         Just does dofile(..)
	example_tree.lua                 A complex tree example.
        trees_lib_growing_functions.lua  Some adjusted growth functions
                                         taken from other mods.
        trees.lua                        Taken from and for minetest_game.

The example tree will look blueish and carry fruits that look like
copper lumps. It exists only to demonstrate what can be done. Depending
on the ground on which the sapling is placed, diffrent methods of
growing are used, and the tree will display diffrent forms of growth.

trees.lua is not executed. If you want to use it, copy it to
minetest_game/mods/default/trees.lua Create a backup of the existing file
there first. Then comment out all definitions of tree trunks, wood,
leaves and fruit nodes (=apple) in minetest_game/mods/default/nodes.lua
as those will be created by trees.lua. All calls to leafdecay in nodes.lua
have to be removed as well. Also remove the function leafdecay_after_destruct
in minetest_game/mods/default/functions.lua

trees.lua and trees_lib have not yet been adjusted to the most recent
changes in minetest_game (i.e. using of LBMs and timers instead of 
ABMs).

trees.lua is taken from minetest_game and modified so that trees_lib can be
used by minetest_game.
