#==============================================================================
# ** TactBattleManager
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#     Utility data managment for tactical battles
#==============================================================================
module TactBattleManager
  module Defaults
    # Default movment range for any unit
    Move = 5
    
    # Default jump range for any unit
    Jump = 0 
    
    # Default passable terrains for any unit
    Passables = {}
    
    # Default jumpable terrains for any unit
    Jumpables = {}
    
    # Used when diagraming skill spec range in db represents the player
    OrigChar = "c"
    
    # Used when diagraming skill spec range in db represents a hitable location 
    HitChar = "x"
    
    # The maximum moves an ai unit will make for performance's sake
    MaxAIMove = 15
    
    # When diagramming skill, specifies the player and that this location is hitable
    OrigCharAndHit = "v"
    
    # Key for showing an enemy units attack range
    ShowAtt = :Y
    
    # Key for showing an enemy units movement range
    ShowMove = :C
    
    # Key for selecting a unit
    SelectAtk = :X
    
    # The map which events are spawned from
    EventMap = 2
    
    # Lose the battle if all units are destroyed
    AllDeadLose = true
    
    # Win the battle if all enemy units are destroyed
    AllDeadWin = true
    
    # The number of turns the ai will look ahead when determining if a unit can
    # get to a certain location
    AdvAITurns = 2 # not quite how it works but similar.
    
    # Set the tone of a team's units to their tone settings when true
    ColorTeams = true
    
    # Tone values while a unit is waiting
    WAIT_GRAY = 100
    WAIT_RED = 100
    WAIT_GREEN = 100
    WAIT_BLUE = 100
    
    # Lose the battle if the return value of the method equivalent of this 
    #   symbol is true
    LoseMethod = :custom_lose
    
    # Lose the battle if the return value of the method equivalent of this 
    #   symbol is true
    WinMethod = :custom_win
    
    # The enemy will move first when this is true
    EnemyMoveFirst = false
    
    # When set to true the game over scene will be called upon losing a tb
    GameOverOnLoss = false
    
    # Default Speed settings higher value will cause the ai to wait longer b/w
    # moves
    # Slow = 40
    # Med = 20
    # Fast = 5
    # Fastest = 0
    
    Speed = 7
    
    # Cursor Movement Speed during a tactical battle
    MoveSpeedTB = 5.5
    
    # Prevents the tactical battle from starting immediately after placing all
    # party members when false. Leave as false for now small bug when set t true
    # The last unit placed won't be able to act, will be fixed when turn flow 
    # control is remodeled
    StartQuick = true
    
    # There must be >= 1 party member on the map when starting a tactical battle
    # useful if you don't have production factillities but want user to be able
    # to choose how many party members participate in the battle.
    OnePartyMemb = true
    
    # Setting to true stops a tactical battle from starting before all of the 
    # party members have been placed on the map. 
    AllPartyMembs = false
    
    # Amount of time spent caching data during players turn
    CacheTime = 0.0
    
    # Return unit's items to the game_party's inventory before the unit is
    # removed from the field.
    ReturnItemsDead = true
    
    # Return the items in all of the units on the player's team to the player's
    # inventory at the end of a tactical battle.
    RetAllItemsEnd = true
    
    # When set to true, if items are being returned to the game_party's 
    # inventory at the end of a tactical battle (RetAllItemsEnd = true), only 
    # the items from units that were part of the current game_party will be 
    # returned.
    RetPartyItemsEnd = false
    
    # Set to :ALL, :ONE, or a list of ids of the party members to revive at the end of
    # a tactical battle. This will allow some party members to be restored to
    # 1 health at the end fo a tactical battle to prevent the game going 
    # directly to the Game Over scene after the tb ends if all of the party 
    # members died during the tb.
    RevOption = :ALL
    
    # Help text for input help window
    Help_Text = {
      0 => "'A' basic atk",
      1 => "'S' scroll skills",
      2 => "'X' command menu",
      3 => "'Z' move unit or main menu"
    }
    Show_HelpWin = true
    
    # Number of frames to wait to start player's turn after all the queues are
    # empty.
    SafetyTimer = 900
    
    # Default for using shared actions across all units during a tb can be
    # mode can be changed during runtime be changing @is_shared_acts
    DefSharedActions = false
    
    # Amount of time in frames spent waiting between turns
    WaitSpeed = 20
    
    # The names of the terrain tags
    Tags = {
      0=>"",
      1=>"",
      2=>"",
      3=>"",
      4=>"",
      5=>"",
      6=>"",
      7=>""
    }
  end
  
  module Regex
    
    # Move distance for a unit
    Unit_Move = /<\s*tb\s*move\s*(\d+)\s*>/i
    
    # Default attack distance for a unit
    Unit_Attack = /<\s*tb\s*atk\s*(\d+)\s*>/i
    
    # Terrains a unit can jump over
    Unit_Jump = /<\s*tb\s*jump\s*length\s*(\d+)\s*over\s*(\d+\s*(?:,\s*\d+\s*)*)\s*>/i
    
    # Passable Terrains for a Unit
    Unit_Pass = /<\s*tb\s*no\s*pass\s*(\d+\s*(?:,\s*\d+\s*)*)\s*>/i
    
    # Shared Actions
    Shared_Acts = /<\s*tb\s*shared\s*(\w+\s*(?:,\s*\w+\s*)*)\s*>/i
    
    # A simple range for a skill/item. Specify a max and min usable distance
    Simple_Range = /<\s*tb\s*range\s*(\d+)\s*-\s*(\d+)\s*>/i
    
    # A specific range for a skill or item
    Spec_Range = /<\s*tb\s*area\s*(up|down|left|right)\s*:\s*/i
    
    # Ending character for specific ranges for a skill or item
    Spec_Range_End = /^>$/
    
    # The skill/item can target the user
    Range_Target_Self = /<\s*(self\s*target)|(target\s*self)\s*>/i
    
    # The skill/item will effect all units with its range
    Skill_Aoe = /<\s*tb\s*aoe\s*(up|down|left|right)\s*:\s*/i
    
    # Range the party will be spawned in:
    Party_Init_Sq = /<\s*tb\s*init\s*area\s*:/i
    
    # (x,y) = origin for the placement squares when putting party on map
    Party_Init_xy = /<\s*tb\s*init\s*pos\s*(\d+),(\d+)\s*>/i
    
    # The location the party will Spawn at the end of a tactical battle
    Party_Respawn = /<tb\s*end\s*(\d+)\s*,\s*(\d+)\s*>/i
    
    # The number of time a unit can perform a move action
    MoveActionLmt = /<\s*tb\s*move\s*acts\s*(\d+)>/i
    
    # The number of times a unit can use an item
    ItemActionLmt = /<\s*tb\s*item\s*acts\s*(\d+)>/i
    
    # The number of times a unit can use a skill
    SkillActionLmt = /<\s*tb\s*skill\s*acts\s*(\d+)>/i
    
    # The number of times a unit can use a basic attack
    AttackActionLmt = /<\s*tb\s*atk\s*acts\s*(\d+)>/i
    
    # The total number of actions that can be performed by the unit
    AllActionLmt = /<\s*tb\s*all\s*acts\s*(\d+)>/i
    
    # The max number of items+skills+basic attacks that can be used
    TargetActionLmt = /<\s*tb\s*target\s*acts\s*(\d+)>/i
    # The skill id that will be used for the units basic attack, if this is not 
    # set, the default will be 1
    BasicAttack = /<\s*tb\s*atk\s*(\d+)>/i
    
    # Produceable units comment:
    ProdUnit = /<produce\s*(.+)>/i
    
    # Produceable Units comment for ai production events
    AIProdUnit = /<ai produce\s*(.+)>/i
    
    # Event Comment, friend
    Ev_Friend = /<tb friend>/i
    # Event Comment, neutral
    Ev_Neutral = /<tb neutral>/i
    # Event Comment, hostile
    Ev_Hostile = /<tb enemy>/i
    
    # Event Comment for a player specified team
    Ev_OTeam = /<tb team (.+)>/i
    
    # Given an item or skill an additional type
    SIType = /<tb\s*type\s*(.+)>/i
    
    # Equipment notetags:
    #   Equip modifications to movement and item ranges
    EModMove = /<tb\s*move\s*(\+|-)(\d+)>/i
    EModSkill = /<tb\s*skills\s*(.+)\s(max|min)\s*(\+|-)(\d+)>/i
    EModItem = /<tb\s*items\s*(.+)\s(max|min)\s*(\+|-)(\d+)>/i
    EModBatk = /<tb\s*basic\s*atk\s*(max|min)\s*(\+|-)(\d+)>/i
    
    #   Equip modifications to actions
    EAllActs = /<tb\s*all\s*action\s*(\+|-)(\d+)>/i
    ETargetActs = /<tb\s*target\s*action\s*(\+|-)(\d+)>/i
    EMoveActs = /<tb\s*move\s*action\s*(\+|-)(\d+)>/i
    EBAtkActs = /<tb\s*basic\s*atk\s*action\s*(\+|-)(\d+)>/i
    ESkillActs = /<tb\s*skill\s*action\s*(\+|-)(\d+)>/i
    EItemActs = /<tb\s*item\s*action\s*(\+|-)(\d+)>/i
    EPoolActs = /<tb\s*pool\s*action\s*(\+|-)(\d+)>/i
    
    # Specify how many actions this unit contributes to the action pool when
    #   using that setting.
    PoolActs = /<tb\s*pool\s*acts\s*(\d+)>/i
    
    # AI Notetags
    
    # Mark a skill as being used to heal, speeds up calculations for ai
    HealItem = /<tb\s*ai\s*heal>/i
    # Mark a unit as being supportive, will priorities buffing/healing friendly
    # units opposed to attacking.
    SupportUnit = /<tb\s*ai\s*support>/i
  end
  
  #----------------------------------------------------------------------------
  # * Modify the default HUD, or ignore this if you made your own
  #----------------------------------------------------------------------------
  module HudDisplay
    
    X_Left = 5        # unused
    Y_Left = 332      # unused
    X_Right = 280     # unused
    Y_Right = 332     # unused
    
    # The text you want to be associtated with HP and MP
    HP = "HP" 
    MP = "MP"
    
    # The text associtated with stat 1 and stat 2
    Stat_1 = "ATK" 
    Stat_2 = "DEF"
    
    # The associated id for the stat (actor.param(2) = actor atk by default)
    Param_1 = 2 
    Param_2 = 3
  end
  #----------------------------------------------------------------------------
  # * VocabTB - used on menus during tactical battles
  #----------------------------------------------------------------------------
  module VocabTB
    Move = 'Move'
    Attack = 'Attack'
    Defend = 'Defend'
    Skill = 'Skill'
    Equip = 'Equip'
    Item = 'Item'
    Status = 'Status'
    Turn = 'Turn'
    Trade = 'Trade'
    Win = 'Success'
    Lose = 'Failure'
  end
  
  # Symbolic constants no need to modify
  PLAYER = :friend
  ENEMY = :hostile
  NEUTRAL = :neutral
  TB_AOE = :tb_aoe
  WIN = :WIN
  LOSS = :LOSS
  
  # Specify other teams (not used as of 21 July 2013)
  #def self.other_teams
    #@other_teams ||= [
    #  :player2, :player3, :player4,
    #  :enemy2, :enemy3, :enemy4
    #]
  #end
  
  # Teams controlled by the player by default.
  PlayerCtrlTeams = {PLAYER => true}
  
  # A four element array of tone values => [red, green, blue, gray]
  TEAM_COLOR = {
    PLAYER => [0,0,200,0],
    ENEMY => [200,0,0,0],
    :other => [50,200,240,0],
    :Zoo => [200,0,220,70]
  }

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# * End of Settings
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #----------------------------------------------------------------------------
  # * Auto generated setters/getters for saving and reloading the tb from file
  #----------------------------------------------------------------------------

  def self.valid_pos; @valid_pos; end
  def self.ai_production; @ai_production; end
  def self.turn; @turn; end
  def self.turn_number; @turn_number; end
  def self.one_produced; @one_produced; end
  def self.party_on_map; @party_on_map; end
  def self.tact_battle; @tact_battle; end
  def self.selecting_command; @selecting_command; end
  def self.selecting_target; @selecting_target; end
  def self.ai_cache; @ai_cache; end
  def self.popup_queue; @popup_queue; end
  def self.unit_items_actors_tb; @unit_items_actors_tb; end
  def self.old_graphic_index; @old_graphic_index; end
  def self.old_graphic_name; @old_graphic_name; end
  def self.follower_visibility; @follower_visibility; end
  def self.old_py; @old_py; end
  def self.old_px; @old_px; end
  def self.units; @units; end
  def self.unit_queue; @unit_queue; end
  def self.map; @map; end
  def self.unit_ev_data; @unit_ev_data; end
  def self.placing_party; @placing_party; end
  def self.pp_initx; @pp_initx; end
  def self.pp_inity; @pp_inity; end
  def self.transition_to_exit; @transition_to_exit; end
  def self.old_player_speed; @old_player_speed; end
  def self.start_queue; @start_queue; end  
  def self.response_queue; @response_queue; end
  def self.rev_dead_type; @rev_dead_type; end
  def self.goto_stats; @goto_stats; end
  def self.retarget_que; @retarget_que; end
  def self.units_lost; @units_lost; end
  def self.run_end_ev; @run_end_ev; end
  def self.end_ev_id; @end_ev_id; end 
  def self.last_tb_result; @last_tb_result; end
  def self.is_shared_acts; @is_shared_acts; end
  def self.sum_shared_acts; @sum_shared_acts; end
  def self.first_turn_team; @first_turn_team; end
  def self.do_first_turn; @do_first_turn; end
  def self.curr_shared_acts; @curr_shared_acts; end
  def self.all_acts_data; @all_acts_data; end
  def self.preset_shared_acts; @preset_shared_acts; end
  def self.ev_turn_start; @ev_turn_start; end
  def self.curr_teams; @curr_teams; end
  def self.curr_teams_queue; @curr_teams_queue; end
  def self.player_ctrl_teams; @player_ctrl_teams; end
  def self.force_next_turn; @force_next_turn; end
  def self.init_cursor_sp; @init_cursor_sp; end 
  def self.wait_speed; @wait_speed; end
  def self.team_groups; @team_groups; end
  def self.team_group_ids; @team_group_ids; end
  def self.fog_ctrl; @fog_ctrl; end
    
  def self.valid_pos=(v); @valid_pos=v; end
  def self.ai_production=(v); @ai_production=v; end
  def self.turn=(v); @turn=v; end
  def self.turn_number=(v); @turn_number=v; end
  def self.one_produced=(v); @one_produced=v; end
  def self.party_on_map=(v); @party_on_map=v; end
  def self.tact_battle=(v); @tact_battle=v; end
  def self.selecting_command=(v); @selecting_command=v; end
  def self.selecting_target=(v); @selecting_target=v; end
  def self.ai_cache=(v); @ai_cache=v; end
  def self.popup_queue=(v); @popup_queue=v; end
  def self.unit_items_actors_tb=(v); @unit_items_actors_tb=v; end
  def self.old_graphic_index=(v); @old_graphic_index=v; end
  def self.old_graphic_name=(v); @old_graphic_name=v; end
  def self.follower_visibility=(v); @follower_visibility=v; end
  def self.old_py=(v); @old_py=v; end
  def self.old_px=(v); @old_px=v; end
  def self.units=(v); @units=v; end
  def self.unit_queue=(v); @unit_queue=v; end
  def self.map=(v); @map=v; end
  def self.unit_ev_data=(v); @unit_ev_data=v; end
  def self.placing_party=(v); @placing_party=v; end
  def self.pp_initx=(v); @pp_initx=v; end
  def self.pp_inity=(v); @pp_inity=v; end
  def self.transition_to_exit=(v); @transition_to_exit=v; end
  def self.old_player_speed=(v); @old_player_speed=v; end
  def self.start_queue=(v); @start_queue = v; end
  def self.response_queue=(v); @response_queue = v; end
  def self.rev_dead_type=(v); @rev_dead_type = v; end
  def self.goto_stats=(v); @goto_stats = v; end
  def self.retarget_que=(v); @retarget_que = v; end
  def self.units_lost=(v); @units_lost = v; end
  def self.run_end_ev=(v); @run_end_ev = v; end
  def self.end_ev_id=(v); @end_ev_id = v; end
  def self.last_tb_result=(v); @last_tb_result = v; end
  def self.other_teams=(v); @other_teams = v; end
  def self.is_shared_acts=(v); @is_shared_acts = v; end
  def self.sum_shared_acts=(v); @sum_shared_acts = v; end
  def self.first_turn_team=(v); @first_turn_team = v; end
  def self.do_first_turn=(v); @do_first_turn = v; end
  def self.curr_shared_acts=(v); @curr_shared_acts = v; end
  def self.all_acts_data=(v); @all_acts_data = v; end
  def self.preset_shared_acts=(v); @preset_shared_acts = v; end
  def self.ev_turn_start=(v); @ev_turn_start = v; end
  def self.curr_teams=(v); @curr_teams = v; end
  def self.curr_teams_queue=(v); @curr_teams_queue = v; end 
  def self.player_ctrl_teams=(v); @player_ctrl_teams = v; end
  def self.force_next_turn=(v); @force_next_turn = v; end
  def self.init_cursor_sp=(v); @init_cursor_sp = v; end
  def self.wait_speed=(v); @wait_speed = v; end  
  def self.team_groups=(v); @team_groups = v; end
  def self.team_group_ids=(v); @team_group_ids = v; end
  def self.fog_ctrl=(v); @fog_ctrl = v; end
  #----------------------------------------------------------------------------
  # * Setup should be called before transferring to a tactical battle map
  #----------------------------------------------------------------------------
  def self.setup(id = 0, sthsh = {})
    return unless SceneManager.scene_is?(Scene_Map)
    init_tb_settings
    init_tb_cursor
    init_curr_teams
    init_team_groups         # how teams are friendly/hostile towards each other
    init_tb_units            # data on how many units have been built by type. 
    init_unit_queue
    init_event_map
    init_internal_ev_data
    init_end_ev_id(id)
    init_sthsh(sthsh)
    init_player_ctrl_teams
    load_map_units
     
    place_party              # Tell scene map to init party on map.
    
  end
  #----------------------------------------------------------------------------
  # * Initialize Team Groups - default for which teams are friends/ hostile
  #----------------------------------------------------------------------------
  def self.init_team_groups
    @team_groups = {0 => [PLAYER], 1 => [ENEMY]}
    @team_group_ids = {PLAYER => 0, ENEMY => 1}
  end
  #----------------------------------------------------------------------------
  # * Initialize Hash storing which events will start after which turns end.
  #     param: turn_hash maps turn numbers to arrays of event ids, i.e:
  #
  #       {1 => [34, 55], 12 => [19,42]} 
  #   after turn 1 is over event 34 and
  #   55 will run. After turn 12 is finished event 19 and 42 will run.
  #----------------------------------------------------------------------------
  def self.init_sthsh(turn_hash = {})
    @ev_turn_start = turn_hash
  end
  #----------------------------------------------------------------------------
  # * Player controlled teams
  #----------------------------------------------------------------------------
  def self.init_player_ctrl_teams
    @player_ctrl_teams ||= PlayerCtrlTeams
  end
  #----------------------------------------------------------------------------
  # * Default teams participating in the tb
  #----------------------------------------------------------------------------
  def self.init_curr_teams
    @curr_teams ||= [PLAYER, ENEMY]
  end
  #----------------------------------------------------------------------------
  # * Initialize the id of the event to run at the end of the tactical battle
  #----------------------------------------------------------------------------
  def self.init_end_ev_id(id)
    @end_ev_id = id
  end
  #----------------------------------------------------------------------------
  # * Init Unit Queue
  #----------------------------------------------------------------------------
  def self.init_unit_queue
    @unit_queue = []
  end
  #----------------------------------------------------------------------------
  # * Init Tb Settings
  #----------------------------------------------------------------------------
  def self.init_tb_settings
    @valid_pos = {}             # valid locations a unit can be placed when making
    @ai_production = {}         # locations the ai can use to produce units
    @turn = NEUTRAL
    @turn_number = 0
    @one_produced = {}          # whether or not a team has produced a unit
    @party_on_map =false
    @tact_battle = true         # True if inside a tactical battle
    @selecting_command = false  # True when unit command window is open
    @selecting_target = false   # true when selecting target location for a skill
    $game_system.menu_disabled = true
    @ai_cache = {}
    @popup_queue = {}
    @unit_items_actors_tb = {}
    @units_lost = {}
    @last_tb_result = nil
    @start_queue, @response_queue, @retarget_que = [], [], []
    @rev_dead_type = Defaults::RevOption
    @all_acts_data = TB_Acts_Data.new
    @init_cursor_sp = Defaults::MoveSpeedTB#$game_player.move_speed
    @wait_speed = Defaults::WaitSpeed
    @force_next_turn = false    # move to next teams turn once back at scene_map
    @fog_ctrl = FogTB.new       # Fog battle settings
    
    empty_ai_cache
  end
  #----------------------------------------------------------------------------
  # * Set up cursor
  #----------------------------------------------------------------------------
  def self.init_tb_cursor
    p = $game_player
    
    @old_graphic_index = p.character_index
    @old_graphic_name = p.character_name
    @follower_visibility = p.followers.visible
    @old_px, @old_py = p.x, p.y
    @old_player_speed = p.move_speed
    p.move_speed = Defaults::MoveSpeedTB
    p.followers.visible = false
    p.followers.refresh
    p.set_graphic("selection.png",0)
  end
  #----------------------------------------------------------------------------
  # * Initialize the map that will be used to accessing event data
  #----------------------------------------------------------------------------
  def self.init_event_map
    @map = load_data(sprintf("Data/Map%03d.rvdata2", Defaults::EventMap))
  end
  def self.init_internal_ev_data
    @unit_ev_data = {}
    Era::TBUnit::Units.keys.each{|n| @unit_ev_data[n] = @map.event_from_name(n)}
  end
  def self.unit_data(name); @unit_ev_data[name]; end
  #----------------------------------------------------------------------------
  # * Init TB Units
  #   :friend, :hostile, :neutral => 
  #             {:amounts => {name => quantity,...}},
  #             {:event => {id => event,...}}
  #----------------------------------------------------------------------------
  def self.init_tb_units
    @units = {}
    
    @curr_teams.each{ |team| add_team_hsh(team) }
  end
  #----------------------------------------------------------------------------
  # * Add new team
  #----------------------------------------------------------------------------
  def self.add_new_team(team)
    @curr_teams ||= []
    @curr_teams.push(team)
    
    # by default all new teams are in their own group
    add_new_group([team])
    
    add_team_hsh(team)
    
    print "@team_groups #{@team_groups}\n @team_group_ids #{@team_group_ids}\n"
  end
  #----------------------------------------------------------------------------
  # * New team group
  #----------------------------------------------------------------------------
  def self.add_new_group(teams)
    id = next_team_group_id
    @team_groups[id] = teams
    teams.each{|team| @team_group_ids[team] = id }
  end
  #----------------------------------------------------------------------------
  # * Next Team Group ID
  #----------------------------------------------------------------------------
  def self.next_team_group_id
    @team_groups.keys.max + 1
  end
  #----------------------------------------------------------------------------
  # * Add teams to one group. Adds all of the teams in the same group as the 
  #     params to one new larger team. The new team uses the team id of team1
  #----------------------------------------------------------------------------
  def self.mesh_teams(team1, team2)
    id1, id2 = @team_group_ids[team1], @team_group_ids[team2]
    
    teams2 = (@team_groups[id2] ||= [])
    @team_groups[id1] ||= []
    
    @team_groups[id1] += teams2
  end
  #----------------------------------------------------------------------------
  # * Split team groups
  #----------------------------------------------------------------------------
  def self.split_teams
  end
  #----------------------------------------------------------------------------
  # * Add unit data for new team
  #----------------------------------------------------------------------------
  def self.add_team_hsh(team)
    @units[team] = {}
    @units[team][:amount] = {}
    @units[team][:event] = {}
  end
  #----------------------------------------------------------------------------
  # * Load Map Units
  #----------------------------------------------------------------------------
  def self.load_map_units
    map = $game_map
    map.events.values.each do |ev|
      load_map_units_helper(ev)
    end
  end
  #----------------------------------------------------------------------------
  # * Helper for loading unit data 
  #     for events already on map when tb starts
  #----------------------------------------------------------------------------
  def self.load_map_units_helper(event)
    return unless comments = Era::Event.valid_comments(id = event.id)
    
    comments.each{ |comment|
      case comment
      when Regex::Ev_Friend
        store_unit_data(PLAYER, event.event.name, event); break;
        @one_produced[PLAYER] = true
      when Regex::Ev_Neutral
        store_unit_data(NEUTRAL, event.event.name, event); break;
      when Regex::Ev_Hostile
        store_unit_data(ENEMY, event.event.name, event);
        @one_produced[ENEMY] = true
      when Regex::Ev_OTeam
        #print "other team found\n"
        team = $1.to_sym
        store_unit_data(team, event.event.name, event)
        @one_produced[team] = true
      end
    }
  end
  #----------------------------------------------------------------------------
  # * store_unit_item
  #   Used to communicate which items were given to which party members when 
  #   moving from the party placement scene to a tactical battle.
  #----------------------------------------------------------------------------
  def self.store_unit_item(actor_id, item)
    (@unit_items_actors_tb[actor_id]||=[]).push(item)
  end
  #----------------------------------------------------------------------------
  # * Remove item from hash, for use during item reorganization from the tb
  #     party placement scene.
  #----------------------------------------------------------------------------
  def self.rm_unit_item(actor_id, item)
    list=(@unit_items_actors_tb[actor_id]||=[])
    list.delete_at(list.index(item))
  end
  #----------------------------------------------------------------------------
  # * Helper method, checks if a unit with the specified name is on the map
  #----------------------------------------------------------------------------
  def self.unit_on_map?(name)
    $game_map.events.values.each{|e| return e if e.event.name.eql?(name)}
    return nil
  end
  #----------------------------------------------------------------------------
  # * Initialize tactical battle unit items from unit_items_... hash
  #----------------------------------------------------------------------------
  def self.init_tbu_items(battler, tbu)
    return if !battler.is_a?(Game_Actor) # only valid for actors atm.
    (@unit_items_actors_tb[battler.id]||=[]).each do |item|
      tbu.gain_item(item,1)
    end
  end
  #----------------------------------------------------------------------------
  # * Exit_tb
  #     should be called before leaving from a tactical battle map.
  #----------------------------------------------------------------------------
  def self.exit_tb
    return unless @tact_battle = true
    reset_inv(Defaults::RetPartyItemsEnd) if Defaults::RetAllItemsEnd
    restore_all_lists
    clear_valid_pos
    remove_party_events
    init_tb_units
    start_ending_ev if @last_tb_result == WIN || @last_tb_result == LOSS
    m = $game_map
    @tact_battle = false
    @transition_to_exit = true
    @one_produced = {}
    @units_lost = {}
    @start_queue = []
    @response_queue = []
    @retarget_que = []
    @preset_shared_acts = nil
    
    m.clear_next_highlights
    $game_system.menu_disabled = false
    (player=$game_player).set_graphic(@old_graphic_name,@old_graphic_index)
    player.move_speed = @old_player_speed
    player.followers.visible = @follower_visibility
    player.followers.refresh
    
    if (s=SceneManager.scene).is_a?(Scene_Map) && !m.map.nil?
      spm = s.instance_eval('@spriteset'); spm.refresh_characters
    end
    relocate_party
  end
  #----------------------------------------------------------------------------
  # * Tell scene map to start the ending event
  #----------------------------------------------------------------------------
  def self.start_ending_ev
    @run_end_ev = true
  end
  #----------------------------------------------------------------------------
  # * Place the party back on the map at the end of a tactical battle
  #----------------------------------------------------------------------------
  def self.relocate_party
    m, p = $game_map, $game_player
    x = m.end_pos_data_tb.pos[0] ||= p.x; y = m.end_pos_data_tb.pos[1] ||= p.y
    p.moveto(x,y) if SceneManager.scene.is_a?(Scene_Map) && m.map
  end
  #----------------------------------------------------------------------------
  # * Remove Party Events
  #     O(|party| * |events on the map|)
  #     without cache so used a cache in expectation of large maps + large parties
  #----------------------------------------------------------------------------
  def self.remove_party_events
    map, pty = $game_map, $game_party
    csh = {}
    pty.members.each{|a| csh[a.name] = true}
    map.events.values.each{ |e| map.destroy_event_any(e.id) if csh[e.event.name] }
  end
  #----------------------------------------------------------------------------
  # * Leaving the tactical battle?
  #----------------------------------------------------------------------------
  def self.leaving?; @transition_to_exit; end
  #----------------------------------------------------------------------------
  # * Called from Scene_Map after finished cleaning up TactBattle Objects
  #----------------------------------------------------------------------------
  def self.finished_cleaning
    @transition_to_exit = false
  end
  #----------------------------------------------------------------------------
  # Used in Game_Map's setup method. Checks if current map is a tactical map.
  #----------------------------------------------------------------------------
  def self.tact_battle?
    @tact_battle.nil? ? false : @tact_battle 
  end
  #----------------------------------------------------------------------------
  # * Is the command window up?
  #----------------------------------------------------------------------------
  def self.selecting?
    @selecting_command.nil? ? false : @selecting_command
  end
  #----------------------------------------------------------------------------
  # * Set selecting_command
  #----------------------------------------------------------------------------
  def self.selecting(is_selecting)
    @selecting_command = is_selecting
  end
  #----------------------------------------------------------------------------
  # * Selecting Target ?
  #----------------------------------------------------------------------------
  def self.selecting_target?
    @selecting_target
  end
  #----------------------------------------------------------------------------
  # * Set Selecting Target
  #----------------------------------------------------------------------------
  def self.set_selecting_target(selecting)
    @selecting_target = selecting
  end # self.set_selecting_target
  #----------------------------------------------------------------------------
  # * helper method hit char refers to characters on skill range diagram
  #----------------------------------------------------------------------------
  def self.hit_char?(letter)
    return (letter.eql?(Defaults::HitChar) || 
      letter.eql?(Defaults::OrigCharAndHit))
    end
  #----------------------------------------------------------------------------
  # * helper method orig char refers to player pos on skill range diagram
  #----------------------------------------------------------------------------
  def self.orig_char?(letter)
    return (letter.eql?(Defaults::OrigChar) || letter.eql?(Defaults::OrigCharAndHit))
  end
  #----------------------------------------------------------------------------
  # * Event Map
  #----------------------------------------------------------------------------
  def self.map; @map; end
  #----------------------------------------------------------------------------
  # * Data for units on current map
  #   :friend, :hostile, :neutral => 
  #             {:amounts => {name => quantity,...}},
  #             {:event => {id => event,...}}
  #----------------------------------------------------------------------------
  def self.units; @units; end
  #----------------------------------------------------------------------------
  # * Friendly Units
  #----------------------------------------------------------------------------
  def self.friends; @units[PLAYER]; end
  #----------------------------------------------------------------------------
  # * Neutral Units
  #----------------------------------------------------------------------------
  def self.neutrals; @units[NEUTRAL]; end
  #----------------------------------------------------------------------------
  # * Hostile Units
  #----------------------------------------------------------------------------
  def self.hostiles; @units[ENEMY]; end
  #----------------------------------------------------------------------------
  # * Enemy Turn?
  #----------------------------------------------------------------------------
  def self.e_turn?; @turn == ENEMY; end
  #----------------------------------------------------------------------------
  # * Player Turn?
  #----------------------------------------------------------------------------
  def self.p_turn?; @turn == PLAYER; end
  #----------------------------------------------------------------------------
  # * Make Unit
  #     params: name = event.name, type = :friend||:hostile||:neutral
  #             wait = boolean, units can't move after being placed when true
  #----------------------------------------------------------------------------
  def self.new_unit(name, type, x=nil, y=nil, wait = false)
    p = $game_player
    x,y = p.x, p.y if x == nil || y == nil
    event = Era::Event.new_event(Defaults::EventMap, {:name=>name,:x=>x,:y=>y})
    (tbu=event.tb_unit).set_control(type)
    tbu.exhaust if wait
    init_tbu_items(tbu.battler,tbu)
    store_unit_data(type, name, event)
    @one_produced[type] = true
  end
  #----------------------------------------------------------------------------
  # * Helper method for new_unit with options hash
  #----------------------------------------------------------------------------
  def self.new_unit_h(name, team, opts = {})
    options = {:x => nil, :y => nil, :wait => false}.merge(opts)
    x = options[:x]; y = options[:y]; wait = options[:wait]
    new_unit(name, team, x, y, wait)
  end
  #----------------------------------------------------------------------------
  # * Store Unit Data
  #----------------------------------------------------------------------------
  def self.store_unit_data(team, name, event)
    team_hash = @units[team]
    #print "store_unit_data #{event.to_s}\n"
    if team_hash.nil?
      add_new_team(team) 
      #print "added new team #{team}\n"
      team_hash = @units[team]
    end
    
    team_hash[:event][event.id] = event
    (amt_hash = team_hash[:amount])[name] ||= 0
    amt_hash[name] += 1
    event.tb_unit.set_control(team)
  end
  #----------------------------------------------------------------------------
  # * Queue a Unit to be placd onto the map upon returning to Scene_Map
  #----------------------------------------------------------------------------
  def self.queue_unit(name, team, x=nil, y=nil, opts = {})
    @unit_queue.push([name, team, x, y, opts])
  end
  #----------------------------------------------------------------------------
  # * Unit Queue
  #----------------------------------------------------------------------------
  def self.unit_queue; @unit_queue; end
  #----------------------------------------------------------------------------
  # * Empty Unit Queue
  #----------------------------------------------------------------------------
  def self.empty_unit_queue; @unit_queue = []; end
  #----------------------------------------------------------------------------
  # * Place Party Events
  #     set party placement on when tactical battle starts
  #----------------------------------------------------------------------------
  def self.place_party
    @placing_party = true
    plyr = $game_player
    @pp_initx, @pp_inity = plyr.x, plyr.y # init xy of player if party is placed
                                          # on map based on players locations
  end
  #----------------------------------------------------------------------------
  # * x,y values for origin of highlight 'rect' when rect is based off of the
  #     players location when the tb started.
  #----------------------------------------------------------------------------                                     
  def self.pp_xy
    [@pp_initx,@pp_inity]
  end
  #----------------------------------------------------------------------------
  # * Placing Party ?
  #----------------------------------------------------------------------------
  def self.placing_party?; @placing_party; end
  #----------------------------------------------------------------------------
  # * Set Placing Party
  #----------------------------------------------------------------------------
  def self.placing_party=(b); @placing_party = b; end
  #----------------------------------------------------------------------------
  # * party_on_map
  #----------------------------------------------------------------------------
  def self.party_on_map=(v)
    @party_on_map = v
  end
  #----------------------------------------------------------------------------
  # * Party on Map
  #----------------------------------------------------------------------------
  def self.party_on_map
    @party_on_map
  end
  #----------------------------------------------------------------------------
  # * Check if there are already events for each party member on the map
  #----------------------------------------------------------------------------
  def self.all_party_events_on_map
    map, pty = $game_map, $game_party
    csh = {}
    count = 0
    pty.members.each{|a| csh[a.name] = true}
    map.events.values.each{ |e| count+=1 if csh[e.event.name] }
    count == pty.members.size
  end
  #----------------------------------------------------------------------------
  # * Whose turn
  #     return: 
  #        :enemy = not the player's turn
  #        :friend = player's turn
  #        :neutral = no one's turn
  #        Doesn't give the actual object, should only be changed through setters
  #----------------------------------------------------------------------------
  def self.turn; @turn; end
  #----------------------------------------------------------------------------
  # * Turn number
  #----------------------------------------------------------------------------
  def self.turn_no; @turn_number; end
  #----------------------------------------------------------------------------
  # * Set the turn manually
  #----------------------------------------------------------------------------
  def self.turn=(team); @turn = team; end
  #----------------------------------------------------------------------------
  # * Turn as string
  #----------------------------------------------------------------------------
  def self.turn_to_s
    if @turn == PLAYER; "Player Turn No. #{@turn_number}"
    elsif @turn == ENEMY; "Enemy Turn No. #{@turn_number}"
    else; "#{@turn.to_s} Turn No. #{@turn_number}"
    end
  end
  #----------------------------------------------------------------------------
  # * Called at the end of the last teams turn before the player goes again
  #----------------------------------------------------------------------------
  def self.ready_next_turns
    # End of turn processing is evaluated at the start of the players turn.
    $game_map.events.values.each do |ev|
      ev.tb_unit.battler.on_turn_end if !ev.nil? && !ev.battler.nil?
    end
    
    #players_turn
  end
  #----------------------------------------------------------------------------
  # * Player's Turn
  #     Processing when the player's turn starts
  #----------------------------------------------------------------------------
  def self.players_turn
    #print "player's turn\n"
    empty_ai_cache # clean out the ai cache from last turn

    @sum_shared_acts = 0
    @curr_shared_acts = 0
    
    map, p = $game_map, $game_player
    
    p.move_speed = @init_cursor_sp
    
    c = nil
    
    units[@turn][:event].values.each do |e| c = e
      #print "eval pturn start #{e}\n"
      e.waiting_tb = false
      tbu = e.tb_unit
      tbu.init_tb_state
      tbu.init_tb_actions
      
      # sum up total actions to use this turn if using shared actions
      @sum_shared_acts += tbu.pool_acts_mod
    end
    
    @sum_shared_acts = @preset_shared_acts if @preset_shared_acts
    center(c.x,c.y) unless c.nil?
  end
  
  def self.center(x,y)
    p = $game_player
    s = p.move_speed
    p.center(x,y)
    p.moveto(x,y)
  end
  #----------------------------------------------------------------------------
  # * Enemy Turn
  #----------------------------------------------------------------------------
  def self.ai_turn
     #@turn = ENEMY
     #print "ai_turn, @turn = #{@turn}\n"
     @units[@turn][:event].values.each{ |e| e.acts_done_tb = true }
     @units.keys.each do |team|
       @units[team][:event].values.each{ |e| e.waiting_tb = false}
     end
     
    #@units[PLAYER][:event].values.each{ |e| e.waiting_tb = false}
   end
  #----------------------------------------------------------------------------
  # * Switch which teams is currently active
  #----------------------------------------------------------------------------
  def self.next_teams_turn
    @turn = @curr_teams_queue.empty? ? nil : @curr_teams_queue.pop
  end
  #----------------------------------------------------------------------------
  # * Start First turn processing once on scene map again
  #----------------------------------------------------------------------------
  def self.first_turn
    @do_first_turn = true
    @party_on_map = true
    @curr_shared_acts = 0
    
    # not used to determine who moves first after multi teams are implemented
    #@turn = Defaults::EnemyMoveFirst ? ENEMY : PLAYER
    
    # Push current teams into queue
    reset_teams_queue
    @turn = @curr_teams_queue.pop
    
    # change this for multi teams
    # @turn_number = @turn == ENEMY ? 0 : 1
    @turn_number = 1 #@turn = 1
  end
  #----------------------------------------------------------------------------
  # * Reset the teams in the teams queue (start of next turn)
  #----------------------------------------------------------------------------
  def self.reset_teams_queue
    @curr_teams_queue = []
    @curr_teams.reverse_each{|t|  @curr_teams_queue.push(t) }
  end
  #----------------------------------------------------------------------------
  # * Restart All Turns 
  #     usd after everyone has moved for the current turn
  #----------------------------------------------------------------------------
  def self.restart_all_turns
    ready_next_turns
    reset_teams_queue
    #next_teams_turn
    @turn_number+=1
  end
  #----------------------------------------------------------------------------
  # * Processing for the first turn of the tactical battle once on scene_map 
  #----------------------------------------------------------------------------
  def self.init_first_turn
    if @preset_shared_acts
      @sum_shared_acts = @preset_shared_acts
    else
      @sum_shared_acts = count_total_acts(PLAYER) if use_shared_actions?
    end
     
    @do_first_turn = false
  end
  #----------------------------------------------------------------------------
  # * The team that moves first if the player controlled team isn't moving first
  #----------------------------------------------------------------------------
  def self.first_turn_team
    @first_turn_team ||= ENEMY
  end
  #----------------------------------------------------------------------------
  # * Returns the sum of the actions across all units
  #----------------------------------------------------------------------------
  def self.count_total_acts(team_sym)
    sum_acts = 0
    @units[team_sym][:event].values.each do |e|
      tbu = e.tb_unit
      sum_acts += tbu.pool_acts_mod
    end
    #print "Total actions = #{sum_acts}\n"
    sum_acts
  end
  #----------------------------------------------------------------------------
  # * Valid Placement Pos
  #     Used to communicate where a unit can be placed across scenes
  #----------------------------------------------------------------------------
  def self.add_valid_pos(xy)
    @valid_pos[xy] = true
  end
  #----------------------------------------------------------------------------
  # * Clear valid positions
  #----------------------------------------------------------------------------
  def self.clear_valid_pos
    @valid_pos = {}
  end
  #----------------------------------------------------------------------------
  # * Check valud of position
  #----------------------------------------------------------------------------
  def self.valid_pos_of(xy)
    @valid_pos[xy]
  end
  #----------------------------------------------------------------------------
  # * Display the text at x,y once the target_evs animation id is 0
  #----------------------------------------------------------------------------
  def self.start_wait_for_anim(text, value, x, y, target_ev)
    old_value = 0
    
    if o=@popup_queue[[x,y]] 
      o[0] = text
      o[1]+= value
      o[2] = target_ev
    else
      @popup_queue[[x,y]] = [text, value+old_value, target_ev]
    end
  end
  #--------------------------------------------------------------------------
  # * Getter Popup Queue
  #--------------------------------------------------------------------------
  def self.popup_queue; @popup_queue; end
  #----------------------------------------------------------------------------
  # * Remove a tactical unit event from the map
  #----------------------------------------------------------------------------
  def self.rm_unit(event_id, team = nil, fade = true, rate = 3, min = 0, 
    destroy = true, start = true, reset = true, restore = true)
    
    print "rm_unit for #{event_id}\n"
    
    map = $game_map
    ret_inv(e = map.events[event_id]) # return items to $game_party's inventory
    name = e.event.name
    
    fade_event(event_id, rate, min, destroy, start, reset, restore) if fade
    
    ok = (t=@units[team]) && t[:event] && t[:amount]
    return unless ok
    @units[team][:event].delete(event_id)
    
    if @units[team][:amount][name] && ok
      @units[team][:amount][name] -= 1
      # record_rm_unit(team, name)
    end
  end
  #----------------------------------------------------------------------------
  # * Store the number of units that were removed from the tb map
  #----------------------------------------------------------------------------
  def self.record_rm_unit(team, name)
    @units_lost[team] ||= {}
    @units_lost[team][name] ||= 0
    @units_lost[team][name] += 1
  end
  #----------------------------------------------------------------------------
  # * Fades out the event when it dies
  #     add functionality to support flipping certain self swithes, etc.
  #----------------------------------------------------------------------------
  def self.fade_event(event_id, rate = 3, min = 0, destroy = true, start = true, 
    reset = true, restore = true)
    event = $game_map.events[event_id]
    
    if reset
      event.save_list_tb # save old commands before resetting + giving move commands
      event.list = []
    end
    
    event.list.push(RPG::EventCommand.new(355,0,["fade_out_tb_era(#{rate}, #{min}, #{destroy},#{restore})"]))
    if start
      event.list.push(RPG::EventCommand.new(355,0,["response_wait_tb(#{true}, #{true}, #{false})"]))
      queue_response_act(event.id)
    end
  end
  #----------------------------------------------------------------------------
  # * Event Team
  #     Returns the team of an event based on its id.
  #----------------------------------------------------------------------------
  def self.event_team(id)
    @units.keys.each{ |team| return team if @units[team][:event][id] }
  end
  #----------------------------------------------------------------------------
  # * Speed setting for tactical battles
  #----------------------------------------------------------------------------
  def self.tb_speed; @tb_speed ||= 20; end
  #----------------------------------------------------------------------------
  # * set tb_speed
  #----------------------------------------------------------------------------
  def self.tb_speed=(v); @tb_speed = v; end
  #----------------------------------------------------------------------------
  # * Hash of all the unique spec_edges for a specific team.
  #     This is useful whean team has mostly the same spec edges, only a few
  #     graphs need to be generated for the entire team.
  #----------------------------------------------------------------------------
  def self.all_spec_edges(team)
    spec_edges = {}
    @units[team][:event].values.each do |e|
      next unless tu = e.tb_unit
      spec_edges[tu.se_hash_key] ||= 0
      spec_edges[tu.se_hash_key] += 1
    end
    
    spec_edges
  end 
  #----------------------------------------------------------------------------
  # * Stores graph and path data for events for the next enemies turn.
  #     This data is calculated for select units on the players turn when they
  #     open up the main menu in order to hide the delay which would otherwise
  #     be noticeable.
  #----------------------------------------------------------------------------
  def self.ai_cache; @ai_cache; end
  #----------------------------------------------------------------------------
  # * Cache value
  #----------------------------------------------------------------------------
  def self.ai_cache_graph(key)
    @ai_cache[:graph][key]
  end
  #----------------------------------------------------------------------------
  # * Ai Cache
  #----------------------------------------------------------------------------
  def self.cache(key, graph = nil, path = nil, distances = nil)
    @ai_cache[:graph][key] = graph unless graph.nil?
    @ai_cache[:path][key] = path unless path.nil?
    @ai_cache[:dist][key] = distances unless distances.nil?
  end
  #----------------------------------------------------------------------------
  # * Empty the ai cache
  #----------------------------------------------------------------------------
  def self.empty_ai_cache
    @ai_cache[:graph] = {}
    @ai_cache[:path] = {}
    @ai_cache[:dist] = {}
  end
  #----------------------------------------------------------------------------
  # * Store the events the ai can produce units at ahead of time to prevent
  #     Searching during the ai routine.
  #----------------------------------------------------------------------------
  def self.ai_produce(id, syms_list)
    (@ai_production||={})[id] = syms_list
  end
  #----------------------------------------------------------------------------
  # * AI production
  #----------------------------------------------------------------------------
  def self.ai_production; @ai_production; end
  #----------------------------------------------------------------------------
  # * Check enemy win state
  #----------------------------------------------------------------------------
  def self.enemy_success?
    dead = all_friends_dead? && Defaults::AllDeadLose
    (dead || method(Defaults::LoseMethod).call) && response_done
  end
  #----------------------------------------------------------------------------
  # * Player Success
  #----------------------------------------------------------------------------
  def self.player_success?
    all_dead = all_enemies_dead?&&Defaults::AllDeadWin
    custom_win = method(Defaults::WinMethod).call
    (all_dead || custom_win) && response_done
  end
  #----------------------------------------------------------------------------
  # * Processing on victory, the default is to exit the tactical battle
  #----------------------------------------------------------------------------
  def self.process_win
    rev_dead
    set_tb_results(WIN)
    exit_tb
  end
  #----------------------------------------------------------------------------
  # * Check if finished processing all waiting events
  #----------------------------------------------------------------------------
  def self.response_done; @response_queue.empty? && @popup_queue.empty?; end
  #----------------------------------------------------------------------------
  # * Processing on loss, the default is to go to scene game over
  #----------------------------------------------------------------------------
  def self.process_loss
    if Defaults::GameOverOnLoss
      return SceneManager.goto(Scene_Gameover) 
    else
      rev_dead
      set_tb_results(LOSS)
      exit_tb
    end
  end
  #----------------------------------------------------------------------------
  # * Set tb results
  #----------------------------------------------------------------------------
  def self.set_tb_results(sym)
    @last_tb_result = sym
  end
  #----------------------------------------------------------------------------
  # * Set the hp of all or at least 1 dead party members to 1 after a 
  #     tactical battle ends prevent game overs immediately
  #----------------------------------------------------------------------------
  def self.rev_dead
    if @rev_dead_type == :ALL
      $game_party.members.each{|a| a.hp = 1 if a.hp <= 0}
    elsif @rev_dead_type == :ONE
      $game_party.members.each do |a| 
        if a.hp <= 0
          a.hp = 1; break
        end
      end
    else
      @rev_dead_type.each{|id|  $game_actors[id].hp = 1 }
    end
  end
  #----------------------------------------------------------------------------
  # * Set the revival type during runtime
  #     param: :ALL, :ONE, or a list of ids of the actors to revive.
  #----------------------------------------------------------------------------
  def self.rev_dead=(type)
    @rev_dead_type = type
  end
  #----------------------------------------------------------------------------
  # * Show Tb stats scene
  #----------------------------------------------------------------------------
  def self.show_tb_stats
    
    SceneManager.call(Scene_EndTB) if SceneManager.scene.is_a?(Scene_Map)
    SceneManager.scene.prepare(@last_tb_result.eql?(WIN))
  end
  #----------------------------------------------------------------------------
  # * All friendly units are dead?
  #----------------------------------------------------------------------------
  def self.all_friends_dead?
    return false if @one_produced[PLAYER].nil?
    units[PLAYER][:amount].values.each{|amt| return false if amt > 0}
    return true
  end
  #----------------------------------------------------------------------------
  # * All Enemy Units Dead?
  #----------------------------------------------------------------------------
  def self.all_enemies_dead?
    return false if @one_produced[ENEMY].nil?
    units[ENEMY][:amount].values.each{|amt| return false if amt > 0}
    return true
  end
  #----------------------------------------------------------------------------
  # * Custom Lose
  #     Specify a custom method which returns a boolean value. If the return
  #     value is true at any time during the tactical battle, it will count as
  #     the party losing.
  #----------------------------------------------------------------------------
  def self.custom_lose
    # currently this method does nothing, remove this comment and write some
    #   code to specify a custom lose condition
  end
  #----------------------------------------------------------------------------
  # * Custom Win
  #     Specify a custom method which returns a boolean value. If the return
  #     value is true at any time during the tactical battle, it will count as
  #     the party winning.
  #----------------------------------------------------------------------------
  def self.custom_win
    # currently this method does nothing, remove this comment and write some
    #   code to specify a custom win condition
  end
  
  #----------------------------------------------------------------------------
  # * Queues up events that need to be started. Scene_Map looks in @start_queue
  #     and starts those events one by one, emptying the response queue
  #     after each one is finished.
  #----------------------------------------------------------------------------
  def self.queue_start_act(id)
    @start_queue.push(id)
  end
  #----------------------------------------------------------------------------
  # * Queues up events that are going to respond to the event (unit) that just
  #     finished acting
  #----------------------------------------------------------------------------
  def self.queue_response_act(id)
    @response_queue.push(id)
  end
  #----------------------------------------------------------------------------
  # * Next value in response queue
  #----------------------------------------------------------------------------
  def self.next_response
    @response_queue.delete_at(0)
  end
  #----------------------------------------------------------------------------
  # * Next id in the start queue of an event that is on the current map
  #----------------------------------------------------------------------------
  def self.next_start
    re = next_retarget
    return re if re != 0
    next_from_queue(@start_queue)
  end
  #----------------------------------------------------------------------------
  # * Queue of ids of events that need to have their targets recalculated
  #----------------------------------------------------------------------------
  def self.new_ai_target(id)
    @retarget_que.push(id)
  end
  #----------------------------------------------------------------------------
  # * Next event that needed its target recalculated
  #----------------------------------------------------------------------------
  def self.next_retarget
    0
    # re = next_from_queue(@retarget_que)
    # recalc_route(re)
  end
  #--------------------------------------------------------------------------
  # * Recalculate routine for ai unit
  #--------------------------------------------------------------------------
  #def self.recalc_route(re)
  #  return re if !(e = $game_map.events[re])
  #  e.restore_list_tb
  #  Era::AI.easy_main_routine(re)
  #  re
  #end
  #--------------------------------------------------------------------------
  # * Next From Queue
  #--------------------------------------------------------------------------
  def self.next_from_queue(queue)
    events = $game_map.events; curr = 0
    while !queue.empty? && !events[curr]
      curr = queue.delete_at(0)
    end
    events[curr] ? curr : 0
  end
  #--------------------------------------------------------------------------
  # * Check if start up queues are empty
  #--------------------------------------------------------------------------
  def self.queues_empty?
    @start_queue.empty? && @response_queue.empty?
  end
  #----------------------------------------------------------------------------
  # * Returns all units items on the field to the game_player's inventory.
  #----------------------------------------------------------------------------
  def self.reset_inv(only_party = false)
    
    if only_party
      
      party = {}
      $game_party.members.each{|a| party[a.name.upcase] = true}
      
      units[PLAYER][:event].values.each do |e|
        
        next if (tbu = e.tb_unit).nil?
        ret_inv(e) if (b=tbu.battler).is_a?(Game_Actor) && party[b.name.upcase] 
        
      end
      
    else; units[PLAYER][:event].values.each{ |e| ret_inv(e) if e}
    end
    
  end
  #--------------------------------------------------------------------------
  # * Return unit items to Game_Party's inventory
  #--------------------------------------------------------------------------
  def self.ret_inv(tb_event)
    return if tb_event.nil? || (tbu=tb_event.tb_unit).nil?
    return if (b=tbu.battler).nil? # || !b.is_a?(Game_Actor)
    tbu.all_items.each do |item|
      $game_party.gain_item(item, tbu.item_number(item))
      tbu.lose_item(item, tbu.item_number(item))
    end
  end
  #--------------------------------------------------------------------------
  # * Damage for use when previewing skill/item effects
  #--------------------------------------------------------------------------
  def self.raw_damage
    @raw_damage
  end
  #--------------------------------------------------------------------------
  # * Raw Damage
  #--------------------------------------------------------------------------
  def self.raw_damage=(v)
    @raw_damage = v
  end
  #--------------------------------------------------------------------------
  # * Setter Raw Amplifier
  #--------------------------------------------------------------------------
  def self.raw_amp=(v)
    @raw_amp = v
  end
  #--------------------------------------------------------------------------
  # * Getter Raw Amplifier
  #--------------------------------------------------------------------------
  def self.raw_amp; @raw_amp; end
  #--------------------------------------------------------------------------
  # * Show Stats?
  #--------------------------------------------------------------------------
  def self.show_stats?; @goto_stats; end
  #--------------------------------------------------------------------------
  # * Setter goto_stat
  #--------------------------------------------------------------------------
  def self.goto_stat=(v); @goto_stats = v; end
  #--------------------------------------------------------------------------
  # * done_starting_end_ev, done starting event to be run at the end of a tb
  #--------------------------------------------------------------------------
  def self.done_starting_end_ev
    @run_end_ev = false
  end
  #--------------------------------------------------------------------------
  # * Check if the player won the last battle
  #--------------------------------------------------------------------------
  def self.won_last_battle?
    @last_tb_result.eql?(WIN)
  end
  #--------------------------------------------------------------------------
  # * Restore all event lists at the end of the turn and on exiting the tb
  #--------------------------------------------------------------------------
  def self.restore_all_lists#(team = ENEMY)
    @curr_teams.each{|t| @units[t][:event].values.each{ |e| e.restore_list_tb} }
    #@units[team][:event].values.each{ |e| e.restore_list_tb}
  end
  #--------------------------------------------------------------------------
  # * Sets revival settings on loss. For use with Ra TBS
  #--------------------------------------------------------------------------
  def self.set_revs(type, intp, ch = "A")
    tm = TactBattleManager
    if tm.tact_battle?
      tm.rev_dead = type
      $game_self_switches[[$game_map.map_id, intp.event_id, ch]] = true
    end
  end
  #--------------------------------------------------------------------------
  # * Check whether or not actions are shared across all units
  #--------------------------------------------------------------------------
  def self.use_shared_actions?
    @is_shared_acts ||= Defaults::DefSharedActions
  end
  #--------------------------------------------------------------------------
  # * Checked from scene map to init first turn values
  #--------------------------------------------------------------------------
  def self.do_first_turn?
    @do_first_turn
  end
  #--------------------------------------------------------------------------
  # * Modifies the current number of shared actions between all units
  #--------------------------------------------------------------------------
  def self.mod_curr_shared_acts(v, set = false)
    set ? @curr_shared_acts = v : @curr_shared_acts += v
  end
  #--------------------------------------------------------------------------
  # * Enough shared actions for any unit to act
  #--------------------------------------------------------------------------
  def self.shared_act_ok?
    return false if !use_shared_actions?
    @sum_shared_acts > @curr_shared_acts
  end
  #--------------------------------------------------------------------------
  # * Player controlled turn?
  #--------------------------------------------------------------------------
  def self.player_ctrl_turn?(team = @turn)
    get_team_ctrl(team)
  end
  #--------------------------------------------------------------------------
  # * Check if all teams have gone for this turn
  #--------------------------------------------------------------------------
  def self.no_ones_turn?
    @turn.nil?
  end
  #--------------------------------------------------------------------------
  # * Is an NPC team?
  #--------------------------------------------------------------------------
  def self.is_npc_turn?(team = @turn)
    @curr_teams.include?(team) && !player_ctrl_turn?(team)
  end
  #--------------------------------------------------------------------------
  # * Check if player is in control of param: team
  #--------------------------------------------------------------------------
  def self.get_team_ctrl(team)
    @player_ctrl_teams[team]
  end
  #--------------------------------------------------------------------------
  # * Returns the symbol of the team that will be moving next
  #--------------------------------------------------------------------------
  def self.whos_turn_next
    team = @curr_teams_queue[0]
    team = @curr_team[0] if team.nil? # first team in list if restart turn nxt
    team
  end
  #--------------------------------------------------------------------------
  # * Go to the next teams turn upon returning to scene map
  #--------------------------------------------------------------------------
  def self.go_next_turn(b = true)
    @force_next_turn = b
  end
end # TactBattleManager