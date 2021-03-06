#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
# * Psycho Tactics Engine
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
# Author: Eshra
# Compatibility: RPG Maker VX Ace
# Work Started: 21 Sept 2012
# Alpha Release Date: 16 Jan 2013
#
# Dependencies: 
# - Era helper module
# - Lightweight Map Highlights
# - Reproduce Events
# - Eshra Bouncy Text
#
#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
# Terms of Use
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# The script is free to use. There will be no support for this version of the
# script once the alpha is over. Not recommended to be used in serious projects, 
# a lot may change by the time the final version is released.
#
#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
# Version Notes 1.5.3
#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
# Ai picks target based on how much remaining hp/mp target will have and if it
# can reach target in one turn or not now. Next time finish up basics to get this
# working correctly, 
# - pass which skill to use, 
# - check if skill actually does hit, 
# - add in a minimum distance when determining when to move unit when using a skill,
# - add basic support for non-simple skills (check around the area of unit to see
# if it can hit anything). 
# - Finish optimizing Aoe skill targeting. (look ups on team groups)
# - Add parametrization to support non aggressive units
# - Resouce collection ai
# - Decide which unit to construct if able 
# - Add customizable ai styles on a per unit basis

# July 30, 2013 - 1.5.3
#   Basic support for additional teams working. Can place more than one ai team 
#     on map to combat player.
#
# July 21, 2013 - 1.5.2
#   More parametrization for multiple teams, turn control flow modified to support
#     as well. Bug fixes for starting event during tb (1.5.1). Can now specify 
#     amount of pool actions a unit grants with notetags.
#
# July 20, 2013 - 1.5.1
#   Shared actions betweeen all units. Start events at the end of a specific turn.
# 
#------------------------------------------------------------------------------

#
#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
# Bug fix Log:
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# 6 August 2013 - Help window no longer stays up after tb ends if player moved
# `               last.
# 5 August 2013 - Ai could hit units from events that were not on 
#                 their active page. If the ai killed a unit that was not on its
#                 active page, a different no ai turn end bug would happen.
#
#                 Was using distance formula to calculate distances when ai was
#                 using skills, etc. Was incorrect, need to simply count no. of
#                 squares between two units. (Took fucking forever to discover)
#
# 31 July 2013 - Need to check all four directions when ai is using aoe skill.
#                AI units no longer line up, they pick a new square to move to
#                if their goal was occupied. Improved logic for determining where
#                to move to. AI no longer refuses to move if it can't get close
#                enough/ far enough away from the player.
# 
# 30 July 2013 - Enemies turn should no longer continue forever occasionally 
#                (acts_tb_done not set to false at start of each turn per ev). 
#
# 21 July 2013 - No longer remain in wait tone on next turn. Equipment now modify
#                actions in all cases when specified (didn't work for a few).
#
# 20 July 2013 - Couldn't start battle if all party members were on the map 
#                without having to place them. Fixed now
#
# 4 June 2013 - Camera no longer centers around any event that moves.
#
# 14 April 2013 - Fixed bug which caused a crash after loading a saved game and
# destroying an enemy during a tactical battle.
# 
#____________
# How To Use
#
#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
# * Table of Contents
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - 
# * Section 1.0 - Getting Started
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
#   - 1.1 Setting Up the Event Map
#   - 1.2 Setting Up the Tactical Battle Map
#   - 1.3 Starting a Tactical Battle 
#   - 1.4 Exiting a Tactical Battle
#   - 1.5 Cursor Graphic
#
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - 
# * Section 2.0 - Tactical Battle Units
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
#   - 2.1 Unit Events 
#   - 2.2 Unit Actions
#     - 2.2.1 Unit Movement
#     - 2.2.2 Unit Skills
#     - 2.2.3 Unit Items
#     - 2.2.4 Skill and Item Types
#     - 2.2.5 Action Pool All Units
#   - 2.3 Unit Equipment
#     - 2.3.1 Action Modifiers   
#
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
# * Section 3.0 - Unit Production
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
#   - 3.1 Production Setup
#   - 3.2 Production Event
#
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
# * Section 4.0 - Other features
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
#   - 4.1 Unit Colors
#
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
# * Section 5.0 - AI
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
#   - 5.1 Setup
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
# * Section 6.0 - Script Calls
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
#  - 6.1 Checking End Result
#  - 6.2 Exiting and Entering the tactical battle 
#    - 6.2.1 Starting Events inbetween turns
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
# * Section 10.0 - Definitions
# - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ - ~ -
#   - 10.1 Glossary
#   - 10.2 Quick Notetag Reference
#
#╔-----------------------------------------------------------------------------╗ 
#║ Getting Started - Section 1.0                                               ║
#╚-----------------------------------------------------------------------------╝ 
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Setting Up the Event Map - Section 1.1                                    ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝ 
#   Units that are on the map during tactical battles are just events. All of 
# the events that will be used in any tactical battle in your project will be 
# loaded from one map.
#
#   After you've create the 'Events Map' you'll need to change the value of the 
# EventMap constant inside of the TactBattleManager::Defaults module to the 
# id of this map. This will tell the script where to load events from. 
#
#   Events inside your 'Events Map' map are associated with actors or enemies 
# through their name. An event that is named 'Slime', for example will pull all 
# of its stats from the enemy named 'Slime' in the database. You should make 
# events for each actor that you want to use as well. For now, just give the
# events in this map the appropriate name to correctly associate them with an
# actor or enemy from the database and make sure their trigger is set to 
# 'Action Button'. You must make an event for each actor in your project. 
#
# *** For more about events see secion 2.1. The above is all that is necessary 
# to get a simple tactical battle started. ***
#
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Setting Up the Tactical Battle Map - Section 1.2                          ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#   Each map from which the player will be able to enter into a tactical battle
# must be marked with a note-tag that will tell the script where the party 
# should be placed at the start of the battle.
#   From the editor, mark the map with a note-tag like this:
#
# <tb init area:
#   PATTERN
# >
#
# to specify a pattern relative to the position of the game_player that will be
# used when deciding which squares the party can be placed at.
#
# For a quick example:
# 
# <tb init area:
# x x
# xcx
# x x
# >
#
# Would allow units to be placed in two vertical lines alongside the location 
# of the Game Player at the start of a tactical battle.
#
# See section 5.0 for a more indepth explanation of how to create a pattern.
#
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Starting a Tactical Battle - Section 1.3                                  ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
# Tactical Battles take place directly on the current map (inside Scene_Map)
# there is no transition to another scene. With this in mind, when you want to
# enter a tactical battle make the script call:
#
# TactBattleManager.setup
#
# And the tactical battle will start. 
#
# If you pass in an integer to the setup method, the event with that id will
# run after the battle is over. To check whether or not the player won the 
# last battle call TactBattleManager.won_last_battle? which returns true
# if the player won and false otherwise.
#
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Exiting a Tactical Battle - Section 1.4                                   ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝ 
#   The normal way to exit a tactical battle is through win or loss conditions 
# which determine whether or not the party has won or lost the tactical battle.
# However, if you want to force the tactical battle to end, this can be done 
# with the script call:
#
# TactBattleManager.exit_tb
# 
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Cursor Graphic - Section 1.5                                              ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝ 
#   At the start of a tactical battle the script will try to change the graphic
# of the game player to an image from a file called 'Selection.png'. If you 
# don't have a file named 'Selection.png' in your graphics/character folder 
# pull the file from the demo. Or just change the name of the expected file
# to something inside your project already.
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# * Notes
# The above is all that is necessary to setup and start a tactial battle,
# but none of the units will have any usable skills and there will be no enemy
# units on the map. The next section covers how to fix this.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#╔-----------------------------------------------------------------------------╗ 
#║ Tactical Battle Units - Section 2.0                                         ║
#╚-----------------------------------------------------------------------------╝ 
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Unit Events - Section 2.1                                                 ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#   The units inside the 'Events Map' mentioned in section 1.1 are associated
# with an actor or event through their name. The same holds for units that
# are already on the map at the start of a tactical battle.
#
#   If you want to have units pre-deployed on the map when a tactical battle
# starts, create an event with its trigger set to 'Action Button' and give it
# an appropriate name. In addition to doing this, it is also necessary to give
# the event a comment that will tell the script which team that specific event
# is on (actors and enemies can both be on either the player's team OR the 
# ai's team).
#
# Use this comment in any spot in the event's command list: 
#   <tb enemy>
# to set the unit to be on the ai's team when the tactical battle starts.
# Use this comment:
#   <tb friend>
# to set the unit to be on the player's team when the tactical battle starts.
#
#   Make sure that the page the comment is on will be active when the tactical
# battle starts. 
#
#   Other than this, the event is just a normal event, and its behavior can be 
# specified through the editor with event comamnds as normal.
#
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Unit Actions - Section 2.2                                                ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#   During the player's turn each unit that is alive can perform actions. An 
# action is one of: using an item, using a skill, or moving. How many of these
# actions that can be performed can be specified with notetags on a unit by 
# unit basis.
#
# The following notetags should be placed in the notes box of the appropriate 
# actors and/or enemies in the database.
# 
# If you want a unit to be able to be able to make an additional movement action
# use the notetag 
#   <tb move acts INTEGER>
# 
# ** Note - this is not the same as specifying how far a unit can move each
#     turn, which is explained in section 2.2.1 **
#
# To specify how many skill actions a unit can make use the notetag:
#   <tb skill acts INTEGER>
# To specify how many attack actions a unit can make use the notetag:
#   <tb atk acts INTEGER>
# To specify how many item actions a unit can make use the notetag:
#   <tb item acts INTEGER>
# 
# There are additional action specification notetags that can be used to 
# specify more exact behavior for a unit.
# 
# To specify the number of base actions a unit can make use this notetag:
#   <tb all acts INTEGER>
#
# These two notetags might be used, for example if you want units to only be 
# be able to move and then use a skill or item
#   <tb all acts 1>
#   <tb skill acts 1>
#   <tb item acts 1>
# Or if you only want the unit to be able to perform one action a turn:
#   <tb all acts 1>
# etc.
#
# Skills can share actions. 
#
# To mark a unit as sharing two or more actions use the notetag:
# <tb shared TYPE1, TYPE2, ...>
#
# currently four types are supported: atk, skill, item, and move.
# _ _ _ _ _
# Example:
#
# If you wanted a unit to be able to 
# either use a basic attack twice, use a skill twice, or use a basic attack 
# once and a skill once, that unit would be "sharing" the skill and attack 
# action limits to do this you'd use these notetags:
#
# <tb atk acts 2>
# <tb skill acts 2>
# <tb all acts 1>
# 
# ** Important **
#    When specifying action limits it is important to make sure that the "all"
# limit is smaller than any of the other limits, otherwise unintuitve results 
# may occur.
# ╔ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Unit Movement - Section 2.2.1                                  ║
# ╚ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#   To specify how far an actor or enemy can move mark that actor or enemy with
# the notetag:
#   <tb move INTEGER>
# For example, <tb move 7> would mean that a unit could move up to 7 spaces
# away from its current location upon using a movement action.
#   
# ╔ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Unit Skills - Section 2.2.2                                    ║
# ╚ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#   Units interact with other units using skills from the database.
# Once a unit is on the map you can use the 'S' key (by default) to scroll 
# through the available skills that unit has to use, or you can use the 'A' key
# to use that unit's basic attack (these options can also be used through the 
# unit menu by pressing 'X' while the cursor is ontop of a unit).
# 
# In order for a skill to be used during a tactical battle, it must be given a
# range.
# Ranges can be specified with a pattern or with two integers.
# To specify a range with a pattern use the notetag:
# <tb area DIRECTION:
#   PATTERN
# >
# - ** -
#
# To specify a range with two integers use the notetag:
# <tb range INTEGER - INTEGER>
# where the first integer is the minimum of the range and the second is
# the max, for example: <tb range 2 - 4>
#
# Skills can be given area of effect (aoe) ranges as well. These function
# as secondary ranges that are specified under the initial range.
# 
# An aoe notetag is specified in this way:
# <tb aoe DIRECTION:
#   PATTERN
# >
# - ** -
#
# This should be placed under one of the initial notetags.
#
# Notes:
# - ** replace 'DIRECTION' with either the word 'up', 'right', 'left', or 'down'
#   and replace 'PATTERN' with a pattern, see secion 5.0 for an explanation of
#   how to create a pattern -
#
# ╔ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Unit Items - Section 2.2.3                                     ║
# ╚ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#   At the start of a tacticl battle, the player can distribute the game party's
# items to individual members of the party, then, during the tactical battle,
# those units can trade with the other units on the player's team to further
# distribute the items across the units on the field.
#   These items can then be used by opening up the command menu for a unit 
# (pressing the 'X' key while the cursor is over a unit), selecting the 'item'
# option, and then selecting the appropriate item. Items use the same notetags
# that skills do and must be given appropriate range specification notetags
# inorder to be used during a tactical battle. 
#   See section 2.2.2 for an explanation of how to setup the notetags. The 
# notetags for items should be placed inside notes box of items.
#
# ╔ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Skill and Item Types - Section 2.2.4                           ║
# ╚ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#   Skills and items can be given types that can be used later by other parts of
# the script. To give a skill or an item a type, use the notetag:
#
# <tb type TYPE>
# ** Replace 'TYPE' with any string of characters **
# For example, you might want to mark certain skills with the notetag
# <tb type FIRE>
# and later you might have a piece of equipment that increases the range of all
# of the skills with type FIRE by a certain amount (See section 2.3 for more).
#
# ╔ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Action Pool All Units - Section 2.2.5                          ║
# ╚ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#   The script supports pooling all actions together such that when any unit 
#  uses an action, intead of that action counting only for that unit, the action
#  is used based on the amount amount of available actions left in the action 
#  pool.
#  
#  To do this, before starting the tactical battle, make the script call:
#
#   TactBattleManager.is_shared_acts = true
#
#  This will tell the script that all units on the players team are sharing an 
#  action pool. By default, the script will create the pool based on the 
#  sum of the pool actions specified in the note tags of each unit on the 
#  players team.
#
#  To specify a unit as adding to the total pool actions use the notetag:
#
#  <tb pool acts INTEGER>
#
#  Doing so will cause te unit to add INTEGER actions to the action pool if it 
#   is on the map during a tactical battle.
# 
#  Equipment can also modify the action pool, add this notetag to any equipment
#  to have it modify the action pool by the specified amount:
#
#  <tb pool actions +INTEGER>
#
#  ** the '+' can be replaced by a '-' sign **
# 
#  The modification will take place at the start of the turn. If equipment is
#   added or removed during the turn, the changes won't be registered until the
#   next turn.
#  
#  To explicitly set the amount of actions available in the pool, use the 
#   script call:
#
#   TactBattleManager.preset_shared_acts = INTEGER
#  
#  To set how many actions will be available in the action pool during the next
#  battle.
# ╔ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Unit Equipment - Section 2.3                                   ║
# ╚ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#   Units which are associated with actors in the database can be equipped with
# armor and/or weapons during a tactical battle. At the start of a tactical 
# battle all actors on the player's team will have the equipment on they would 
# have on otherwise. This equipment can be changed by going to the command menu 
# (pressing the 'X' key while the cursor is over a unit) and selecting the 
# equipment option. Equipment can only be equipped if it is in that units 
# inventory.
#   Equipment can be given notetags to increase the amount of actions a unit 
# can perform per turn, to increase their basic attack range, to increase their 
# movement range, or to increase the skill range for specific skills. This will 
# only work for skills whoose attack area was specified by a range using two
# integers, i.e. the <tb range MIN - MAX> notetag. It will not work for skills 
# whose target area was specified with a pattern.
#
# ╔ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Action Modifiers - Section 2.3.1                               ║
# ╚ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
# _________
# Movement
#
# To allow a piece of equipment to increase the movement range of a unit by 
# certain amount, mark it with this notetag:
# <tb move +INTEGER>
# _ _ _ _ _  
# Example:
#
# A pair of boots marked with this notetag:
# <tb move +2>
# would increase the equipped unit's movement by 2
# ______________
# Basic Attacks
#
# To allow a piece of equipment to increase the basic attack range of a unit by 
# certain amount, mark it with this notetag:
# <tb basic atk +INTEGER>
# _ _ _ _ _ 
# Example:
# A bow marked with this notetag:
# <tb basic atk max +1>
# would increase the equipped unit's basic attack range by 1
# _______
# Skills
#
# To allow a piece of equipment to increase the target area of skill by 
# certain amount, mark it with this notetag
#
# <tb skills SKILL_TYPE max +INTEGER> or <tb skills ITEM_TYPE min +INTEGER>
#
# The min and max keyword in the above notetags refer to the upper or lower
# limit of the range they are going to be modifying. 
# _ _ _ _ _ 
# Example:
#
# If a skill has the notetag <tb range 3 - 7> and <tb type BASIC_SKILL>, and 
# you wanted a piece of equipment to change the range of that skill to 5 - 6, 
# you would mark the equipment with the notetags:
#
# <tb skills BASIC_SKILL max -1>
# <tb skills BASIC_SKILL min +2>
#
# The above two notetags would decrease the upper limit of the skill by 1, and 
# increase the lower limit of the skill by 2.
#
# A staff marked with this notetag:
# <tb skills MAGIC max +4>
# would increase the target area of all skills marked with the notetag 
# <tb type MAGIC> by 4.
# ______
# Items
# To allow a piece of equipment to increase the target area of an item by a
# certain amount, mark it with this notetag:
# <tb items ITEM_TYPE max +INTEGER> or <tb items ITEM_TYPE min +INTEGER>
# _ _ _ _ _ 
# Example:
#
# A pair of gloves marked with this notetag:
# <tb items THROWN max +1>
# would increase the target area of all items marked with the notetag 
# <tb type THROWN> by 1
# ________
# Actions
#
# Equipment can also be marked to increase the amount of times unit can perform 
# an action. Mark a piece of equipment with the following notetags to modify 
# the specified units action limits:
#
# To increase the total amount of actions a unit can perform:
# <tb all action +INTEGER>
#
# To increase the amount of basic attacks a unit can perform:
# <tb basic atk action +INTEGER>
#
# To increase the amount of movement actions a unit can peform:
# <tb move action +INTEGER>
#
# To increase the amount of skills a unit can use per turn:
# <tb skill action +INTEGER>
#
# To increase the amount of items a unit can use per turn:
# <tb item action +INTEGER>
#
# - ** 'INTEGER' in the above examples should be replaced with an 
# integer value, addionally all '+' signs can be replaced with '-' signs to
# imply deduction instead of addition. 'ITEM_TYPE' and 'SKILL_TYPE' refer to 
# the 'type' the item or skill was given as specified by the <tb type TYPE> 
# notetag) - 
#
#╔-----------------------------------------------------------------------------╗ 
#║ Unit Production - Section 3.0                                               ║
#╚-----------------------------------------------------------------------------╝ 
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Production Setup - Section 3.1                                            ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#   The units that can be produced during a tactiacal battle are defined inside
# of the TBUnit module. Inside TBUnit there is a hash table, Constructable.
# This table maps symbols to arrays of strings: sym => ["ex1", "ex2",...]
# The array is a list of unit names (according to their names in the database)
# and the symbol is what is used by the production event to determine which 
# units can be produced by that event.
#   For example you might add an entry to the table:
#     Constructable = {
#       :basic_units => ["soldier", "scout", "archer", "mage"]
#     }
# this would allow "soldiers", "scouts", "archers", and "mages" to be produced
# by all production events that were using the :basic_units symbol. The units
# listed in each array do not have to be unique and can overlap, for example:
#   Constructable = {
#     :group1 => ["soldier", "archer"]
#     :group2 => ["soldier", "mage"]
#   }
# In addition to deciding how you want your units to be grouped, it's necessary 
# to give each unit a cost. The cost for any given unit is 
# measured in currency, items, armor, and weapons. Each unit can be given a 
# unique cost, for example 100 currency and two of armor 2 or they can be 
# listed as free to make.
# 
# The Units hash is where costs are determined. The Units hash is orgaized as
# follows:
#   Units = {
#     "Unit1 Name" => { :cost => {}, :max => INTEGER },
#     "Unit2 Name" => { :cost => {}, :max => INTEGER},
#      ...
#   }
# As can be seen above, the costs are organized on a unit by unit basis, each
# unit functions as a key that maps to a hash of its cost. This hash is 
# organized such that the symbol :cost maps to another hashtable which actually
# holds the cost data, and the symbol :max maps to an integer value. :max 
# represents the maximum amount of units of the corresponding type that can be
# produced.
#   
# The inner hashtable mapped to from the :cost symbol is organized such that 
# each of the folowing symbols, :item, :armor, :weapon, and :currency all map to 
# hash tables which finally hold the actual cost data. Each of these inner hash
# tables simply map ids to amounts where the id is the id of the corresponding 
# item, weapon, or armor, and the amount is the number of that item/armor/weapon
# that is needed to pay the cost of that unit. The :currency symbole maps to 
# an integer representing how much currency is required to pay the cost.
#
# Additionally, there is a default table name FREE inside the source which
# can be used to label a unit as free to make.
#
# In order to pay the cost of a unit the appropriate material and currency must
# be present in the $game_party's inventory.
#
# The following example will explain a hypothetical Units table in which the
# costs for three units, a "Sentry", a "Mercenary", and an "Archer" are defined.
# _ _ _ _ _ 
# Example:
# Units = {
#   "Sentry" => FREE
#   "Wolf" => { :cost=> {:currency => 100}, :max=>100},
#   "Archer" => { 
#                 :cost=>{ :item => {91 => 2, 68 => 2}, 
#                          :armor => {43 => 2}, 
#                          :weapon => {7 => 1}, 
#                          :currency => 1200 
#                         }, 
#                 :max => 10
#               }
# }
# 
#   The unit named "Sentry" simply maps to the built in constant named FREE.
# This is just a hash table which represents a unit being free to make.
# So the sentry costs no resources to actually make.
#   The next unit listed is named "Wolf", walking through its associated table
# we can see that the :cost symbol maps to a hash table which specifies no 
# required items and 100 currency to make. We can also see that the :max symbol
# maps to 100 which means that no more than 100 "Wolf" units can be constructed
# at a time.
#   The third unit listed is named "Archer". This unit's :cost symbol maps to 
# a hash table which lists several required items, armors, and weapons to make
# as well as an additional 1200 currency. We can see that the archer requires
# two instances of the item with id 91 and 2 intances of the item with id 68 to
# make., as well as two instances of armor 43 and one instance of weapon 7. 
# The :max symbol shows that no more than 10 "Archer" units can be produced. 
#
# That's all the setup that is required here for unit production. The next
# step is setting up the event that the units will be produced from.
# 
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║  Production Event - Section 3.2                                           ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝ 
#   Events are produced by pressing the 'Z' key while the cursor is ontop of 
# a production event during a tactical battle. Doing so will bring up a list of
# units that can be made from that event.
#   The production event should have a comment on an active page describing 
# which units can be produced from it. The comment must be in this form:
#   <produce GROUP>
# where 'GROUP' corresponds to an associated symbol inside the Constructable 
# table in the TBUnit module. If you want the event to be able to produce more
# than one group you can place additional comments on the event for those other
# groups. The comments must be separate though.
#
# ** Important ** the production event must have its passability set to through
#     Only enemies from the database should be produceable in a quantity greater
#     than 1 (if more than 1 actor is on the field, all of the events 
#     representing that actor will point to the same object internally)
# 
# _ _ _ _ _
# Example:
# The following comments on an event,
#
# Comment: <produce basic_units>
# Comment: <produce advanced_units>
# 
# would allow that event to produce units from the basic_units group and the 
# advanced units group. Note, don't include "Comment:" inside the actual comment
# it's there to denote the two comments are separate from one another.
#
#╔-----------------------------------------------------------------------------╗ 
#║ Other Features - Section 4.0                                                ║
#╚-----------------------------------------------------------------------------╝
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║  Team Colors - Section 4.1                                                ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#   Team colors can be specified inside the TEAM_COLOR hash in the 
# TactBattleManager module. To turn team colors on set the ColorTeams constant
# inside TactBattleManager::Defaults to true.
#
#╔-----------------------------------------------------------------------------╗ 
#║ AI - Section 5.0                                                            ║
#╚-----------------------------------------------------------------------------╝
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║  Setup - Section 5.1                                                      ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#   Enemy units should be marked with the comment <tb enemy>. To make an enemy
# unit, create an event on the map and then name the event so that it is the
# same as the entry of an actor or enemy in the database. After adding the 
# above comment a new enemy unit as been created.
#   If you want the ai to be able to produce units mark an event with the
# the notetag <ai produce GROUP> where GROUP matches one of the keys of the
# Constructable hash inside Era::TBUnit. Don't forget to set the event's 
# passability to through.
#
#╔-----------------------------------------------------------------------------╗ 
#║ Script Calls - Section 6.0                                                  ║
#╚-----------------------------------------------------------------------------╝
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║  Checking End Result - Section 6.1                                        ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
#
# Use the script call:
#
# TactBattleManager.show_tb_stats
#
# to see the results of the last tactical battle. If you just want to know who
# won use:
# TactBattleManager.won_last_battle?
# which returns true if the player won.
#
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Exiting and Entering the tactical battle - Section 6.2                    ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
# Use the script call:
# 
# TactBattleManager.exit_tb
#
# to exit a tactical battle directly. Normally this is processed through 
# process_win or process_loss. exiting directly is useful for debugging.
#
# Use the script call:
#
# TactBattleManager.setup
#
# to enter a tactical battle. The setup method can be passed the id of an event
# to run at the end of a battle.
# ╔ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║ Starting Events inbetween turns - Section 6.2.1                ║
# ╚ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
# Use the script call:
#
# TactBattleManager.setup(event_id, hash)
#
# The first parameter is the event_id of the event that will be started at the
#   end of the tactical battle.
# The second parameter is a hash table. The table maps turn numbers to arrays of
# event ids. Each event in the array will be started at the end of the turn
# specified by the key.
#
# Example:
#
# TactBattleManager.setup(22, {1 => [3,54,9], 13 => [2]})
#
# This script call would start a tactical battle. Once the battle was over event
# 22 would run. After turn 1 was over events 3, 54, and 9 would run. After turn
# 13 was over event 2 would run.
#╔-----------------------------------------------------------------------------╗ 
#║ Definitions - Section 10.0                                                  ║
#╚-----------------------------------------------------------------------------╝
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║  Glossary - Section 10.1                                                  ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
# _______
# PATTERN
# 
#   A pattern is a set of characters that specifies the location of something 
# relative to the location of the cursor during a tactical battle. 
# A pattern is specified using four characters, 'x', 'c', 'v', and whitespace. 
# The three characters can be modified inside of the TactBattleManager::Defaults 
# module. Their names there are HitChar, OrigChar, and OrigCharAndHit. The 
# pattern represents where highlights will be displayed on the map upon making
# certain actions during a tactical battle.
#
# A pattern can be specified in any way using these four characters, however
# the characters 'c' and 'v' should not show up in the same pattern. The default
# meaning of each character is as follows:
#
# 'x' = a hit
# whitespace = a miss
# 'c' = location of the cursor and a miss
# 'v' = location of the cursor and a hit
#
# The locations that are marked as a hit are relative to the 'c' or 'v' character
# in the pattern. If a 'c' is specified, that location is
# analogous to a whitespace. If a 'v' is specified, that location is analogous
# to an 'x' the only difference is that all other points in the pattern are now
# relative to that 'c' or 'v'. Once the pattern is translated into highlights 
# that are shown on the map.
#
# ** Important ** be careful when creating patterns with whitespaces in the 
# note boxes for elements in the database as they will not always line up how
# you may expect. Each individual whitespace will be counted so the correct 
# pattern my appear somewhat skewered in the notes box.
# _ _ _ _ _ 
# Example:
# 1)
#
# xxx
# xcx
# xxx
# 
# specifies a square around the location of the cursor.
# 
# 2)
#
#   x
#  x x
# x c x
#  x x
#   x
#
# specifies a diamond around the location of the cursor
#
# 3)
# 
# x x
#  v
# x x
#
# specifies an x, note if the v was replaced with a c the pattern would instead
# specify the four corners of a square instead of an x.
#
# 4) Patterns can be complex but be sure there is at least one and only one 'c' 
#     or at least one and only one 'v', for instance:
# 
# xxx     xx     xxxxx  xxxx   xxxxx
# x  x   x  x      x    x   x  x
# xxx    xxxx  c   x    xxx    xxxxx
# x  x   x  x      x    x   x      x
# x   x  x  x      x    xxxx   xxxxx
#
# Would specify a pattern which would display the letters RA TBS around the 
# cursor once applied.
#
# ╔- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╗ 
# ║  Notetags Reference - Section 10.2                                        ║
# ╚- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -╝
# _______________
# Actors/Enemies (9)
#
# Specify Movement range:
# <tb move INTEGER> 
#
# Specify skill id to use for basic attack:
# <tb atk INTEGER> 
#
# Specify jumps:
# <tb jump length INTEGER over INTEGER,INTEGER,...> 
#
# Specify impassable terrain tags:
# <tb no pass INTEGER,INTEGER,...> 
#
# Specify item action limit
# <tb item acts INTEGER>
# 
# Specify Skill action limit
# <tb skill acts INTEGER>
#
# Specify basic attack action limit
# <tb atk acts INTEGER>
#
# Specify maximum total actions
# <tb all acts INTEGER>
#
# Specify pool actions modifier
# <tb pool acts INTEGER>
#
# Specify shared actions
# <tb shared atk, skill, item, move> 
# _____________
# Skills/Items (4)
#
# Specify a range:
# <tb range INTEGER - INTEGER>
#
# Specify a range:
# <tb area DIRECTION:
#   PATTERN
# >
# 
# Specify an Area of Effect range
# <tb aoe DIRECTION:
#   PATTERN
# >
# 
# Specify a skill as being able to target the user (simple ranges)
# <target self>
# 
# Specify an additional type
# <tb type STRING>
#
# _______________
# Weapons/Armors (10)
# 
# Specify movement range modifier
# <tb move +INTEGER>
#
# Specify skill modifier
# <tb skills TYPE max +INTEGER>
# <tb skills TYPE min +INTEGER>
#
# Specify item modifier
# <tb items TYPE max +INTEGER>
# <tb items TYPE min +INTEGER>
#
# Specify basic atk modifier
# <tb basic atk max +INTEGER>
# <tb basic atk min +INTEGER>
#
# Specify all actions modifier
# <tb all action +INTEGER>
#
# Specify target actions modifier
# <tb target action +INTEGER>
#
# Specify move actions modifier
# <tb move action +INTEGER>
#
# Specify atk actions modifier
# <tb basic atk action +INTEGER>
#
# Specify skill actions modifier
# <tb skill action +INTEGER>
#
# Specify item actions modifier
# <tb item action +INTEGER>
#
# Specify pool actions modifer
# <tb pool action +INTEGER>
#
# _________
# Map Info (3)
#
# Specify initial area characters spawn in:
# <tb init area: 
#   PATTERN
# >
#
# Specify origin when placing characters:
# <tb init pos INTEGER, INTEGER> 
#
# Specify location to spawn party at end of battle:
# <tb end INTEGER, INTEGER>
# 
# _______________
# Event Comments (4)
#
# Specify ai group production
# <ai produce GROUP>
#
# Specify player group production
# <produce GROUP>
#
# Specify Unit as controlable by player
# <tb friend>
#
# Specify unit as controalable by ai
# <tb enemy>







#------------------------------------------------------------------------------
# Additional notes on usage:
#------------------------------------------------------------------------------
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 1) UNIQUE NAMES
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   All enemies and actors should have unique names (in the database).
# Events that are on the map that have the same name as an actor or an enemy
# in the database will be treated as that actor or enemy. If for some reason 
# you need an event to share the name of an actor or enemy but don't want that
# event to be treated as that actor or enemy...(Currently no support to deal
# with this case).
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2) RESTRICT PRODUCTION
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Determining which units can be used on which map inside Era::TBUnit::Constructable
# is not dynamic enough to handle units which might "die", etc. during gameplay
# and should be treated as 'dead' forever. In order to prevent a unit from being 
# able to be produced it is necessary to set $data_enemies[i].tb_usable = false.
# or for actors, $data_actors[i].tb_usable = false. @tb_usable is checked before
# the unit is added to the map, if it is false it won't be added.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 3) SKILLS/ITEMS DURING TACTICAL BATTLE
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# In order for a skill or item to be able to be used during a tactical battle it
# must have a tb range (tacitcal battle range) specified in the database using
# one of the two types** of range notetags. The simple range notetag is specified
# in the following way:
# <tb range NUMBER - NUMBER> 
# * replace number with an integer value *
# ** See the help file, section 2.2.2, for an explanation of the more specific
# method of specifying unique ranges ** 
# One of these notetags must be specified on the skill in the database or it
# will not show up on a units skill list during skill selection while in a
# tactical battle. All of the above information is exactly the same for items.

