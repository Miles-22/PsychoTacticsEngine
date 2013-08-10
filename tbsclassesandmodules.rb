#==============================================================================
# ** BitmapUtils
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     Useful methods inside a module instead of Window_Base.
#==============================================================================
module BitmapUtils
  #--------------------------------------------------------------------------
  # * Set Character Bitmap
  #--------------------------------------------------------------------------
  def self.draw_character_bitmap(bm, x, y, name, dir, index, pattern = 1, 
    op = 255, adjust = false)
    
    bitmap = Cache.character(name)
    sign = name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    
    sx = (index % 4 * 3 + pattern) * cw
    sy = (index / 4 * 4 + (dir - 2) / 2) * ch
    
    rect = Rect.new(sx,sy,cw,ch)
    if adjust && ch < 33
      y += bm.height/6
    end
    bm.blt(x,y, bitmap, rect, op)
    [bm.width,bm.height]
  end
  #--------------------------------------------------------------------------
  # * Character Width and Height
  #--------------------------------------------------------------------------
  def self.character_wh(name,index)
    bitmap = Cache.character(name)
    sign = name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    [cw,ch]
  end # character_wh
end # BitmapUtils

#==============================================================================
# ** RPG::BaseItem
#==============================================================================
class RPG::BaseItem
  attr_accessor :base_passables, :base_jumpables
  def set_base_jumpables(tags)
    @base_jumpables = {}
    tags.split(",").each do |tag|
      @base_jumpables[tag.strip.to_i] = true
    end
  end
  
  def set_base_passables(tags)
    @base_passables = {}
    tags.split(",").each do |tag|
      @base_passables[tag.strip.to_i] = true
    end
  end
  
  def friendly_target?
    [7,8].include?(@scope)
  end
  
  def hostile_target?
    [1,2,3,4,5,6].include?(@scope)
  end
end # RPG::BaseItem
#==============================================================================
# ** RPG::Actor
#==============================================================================
class RPG::Actor < RPG::BaseItem
  attr_accessor :base_move_range # base move range (int)
  # attr_accessor :base_attack_range # base attack range (int)
  attr_accessor :base_jump      # base jump length
  attr_accessor :base_jumpables # hash of terrain tags which can be jumped over
  attr_accessor :base_passables # hash, passable terrain even if marked as blocked
  attr_accessor :basic_atk_id_tb
  attr_accessor :target_tb_lmt
  attr_accessor :shared_acts, :pool_acts_mod
  attr_accessor :is_support_unit
  attr_reader :tb_usable
  #----------------------------------------------------------------------------
  # * Set tb_usable
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  #   Set usablility during a tactical battle. @tb_usable is checked before
  # adding this actor to the production list. If it is false this unit won't be
  # added. This is useful if you have an actor that "dies" during your game and
  # you never want that actor to be usable again. It would be difficult to 
  # enforce this using just Era::TBUnit::Constructable.
  #----------------------------------------------------------------------------
  def tb_usable=(b); @tb_usable = b; end
  
  def move_action_lmt=(v); @move_action_lmt = v; end
  def attack_action_lmt=(v); @attack_action_lmt = v; end
  def item_action_lmt=(v); @item_action_lmt = v; end
  def skill_action_lmt=(v); @skill_action_lmt = v; end
  def all_action_lmt=(v); @all_action_lmt = v; end
  def pool_acts_mod=(v); @pool_acts_mod = v; end
    
  def move_action_lmt; @move_action_lmt; end
  def attack_action_lmt; @attack_action_lmt; end 
  def item_action_lmt; @item_action_lmt; end 
  def skill_action_lmt; @skill_action_lmt; end 
  def all_action_lmt; @all_action_lmt; end
  def pool_acts_mod; @pool_acts_mod; end
    
  def parse_shared_acts(str)
    new_lst = []
    str.split(",").each do |type|
      new_lst.push(type.strip.to_sym)
    end
    (@shared_acts ||= []).push(new_lst)
  end
end # RPG::Actor
#==============================================================================
# ** RPG::Enemy
#==============================================================================
class RPG::Enemy < RPG::BaseItem
  attr_accessor :base_move_range
  attr_accessor :base_jump
  attr_accessor :base_jumpables, :base_passables
  attr_accessor :basic_atk_id_tb
  attr_accessor :target_tb_lmt
  attr_accessor :shared_acts, :pool_acts_mod
  attr_accessor :is_support_unit
  attr_reader :tb_usable
  #----------------------------------------------------------------------------
  # * Set tb_usable
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  #   Set usablility during a tactical battle. @tb_usable is checked before
  # adding this enemy to the production list. If it is false this unit won't be
  # added. This is useful mainly for actors (if an actor died and you don't want
  # them to be usable again during the tactical battle) but it can also
  # potentially be useful for enemies, for example if there is an optional
  # battle at one point during the game and this enemy should only be used
  # if that battle never occured. It would be difficult to enforce this using
  # Era::TBUnit::Constructable.
  #----------------------------------------------------------------------------
  def tb_usable=(b); @tb_usable = b; end
  
  def move_action_lmt=(v); @move_action_lmt = v; end
  def attack_action_lmt=(v); @attack_action_lmt = v; end
  def item_action_lmt=(v); @item_action_lmt = v; end
  def skill_action_lmt=(v); @skill_action_lmt = v; end
  def all_action_lmt=(v); @all_action_lmt = v; end
  def pool_acts_mod=(v); @pool_acts_mod = v; end
    
  def move_action_lmt; @move_action_lmt; end
  def attack_action_lmt; @attack_action_lmt; end 
  def item_action_lmt; @item_action_lmt; end 
  def skill_action_lmt; @skill_action_lmt; end 
  def all_action_lmt; @all_action_lmt; end
  def pool_acts_mod; @pool_acts_mod; end
    
  def parse_shared_acts(str)
    new_lst = []
    str.split(",").each do |type|
      new_lst.push(type.strip.to_sym)
    end
    (@shared_acts ||= []).push(new_lst)
  end
end # RPG::Enemy
  
#=============================================================================
# * New attributes for skills, range data.
#=============================================================================
class RPG::UsableItem < RPG::BaseItem
  attr_accessor :tbs_spec_range # specified range in db with picture opposed to 
                                # using scalars to label range.
                                # (:right | :left | :up | :down) => points
  attr_accessor :tbs_hl_color   # The color that the highlights for this item
                                # will show up in. Not used currently
  attr_accessor :tb_range_min   # int, min range item can target
  attr_accessor :tb_range_max   # int, max range item can target
  attr_accessor :tbs_simple_range # array of points
  attr_accessor :tb_self_target # skill/ item can target the user
  attr_accessor :tb_aoe
  attr_accessor :tbs_aoe_range  # area of effect range
  attr_accessor :tb_type        # user specified type
  attr_accessor :is_healer_tb
  
  #----------------------------------------------------------------------------
  # * Alias, for_friend?
  #----------------------------------------------------------------------------
  alias gd_for_frie_nd_era for_friend?
  def for_friend?
    return false if TactBattleManager.tact_battle? # no party during tact battle
    gd_for_frie_nd_era
  end
  #----------------------------------------------------------------------------
  # * Make Simple Range
  #----------------------------------------------------------------------------
  def make_simple_range
    @tbs_simple_range = Unit_Range.get_possible_points(0, 0, 
      @tb_range_min-1, @tb_range_max-1, :p_at_dist, {:source => @tb_self_target})
  end
  #----------------------------------------------------------------------------
  # * Aoe From Diagram
  #----------------------------------------------------------------------------
  def aoe_from_diagram(str_arr, dir)
    range_from_diagram(str_arr, dir, true)
  end
  #----------------------------------------------------------------------------
  # calculate the spec_range from a diagram provided from the db
  #----------------------------------------------------------------------------
  def range_from_diagram(str_arr, dir, aoe = false)
    
    if !aoe
      @tbs_spec_range = {} 
      @tbs_spec_range[dir] = []
    else
      @tbs_aoe_range = {}
      @tbs_aoe_range[dir] = []
    end
    
    ox,oy = -1,-1
    
    # initial pass finds origin
    str_arr.each_with_index do |arr,i|
      arr.each_with_index do |letter,j|
        if TactBattleManager.orig_char?(letter)
          ox, oy = j, i
        end
      end
    end
    
    raise "Invaid range in db notes for skill #{@id}.\n" if ox == -1 || oy == -1
    
    # second pass offsets coordinates based on origin
    str_arr.each_with_index do |arr,i|
      arr.each_with_index do |letter,j|
        
        if TactBattleManager.hit_char?(letter)
          case aoe
          when false # pos relative to player
            @tbs_spec_range[dir].push(Vertex.new(j-ox,i-oy))
          when true
            @tbs_aoe_range[dir].push(Vertex.new(j-ox,i-oy))
          end
        end # if TactBattleManager.hit_char?(letter)
        
      end   # arr.each_with_index
    end     # str_arr.each_with_index
    
    if aoe
      load_other_ranges(dir, @tbs_aoe_range)
    else
      load_other_ranges(dir, @tbs_spec_range)
      r = @tbs_spec_range
      @tbs_spec_range[:all] = r[:up] + r[:down] + r[:right] + r[:left]
    end
  end
  
  #----------------------------------------------------------------------------
  # * Item can be used in a tactical battle
  #----------------------------------------------------------------------------
  def tb_ok?
    @tbs_spec_range || tbs_simple_range
  end
  
  #----------------------------------------------------------------------------
  # * Add position of user to item range
  #----------------------------------------------------------------------------
  def load_tb_target_self
    return unless @tb_self_target
    if !@tbs_spec_range.nil?
      [:up,:down,:left,:right].each{|d| (@tbs_spec_range[d]||=[]).push(Vertex.new(0,0))}
    elsif !@tbs_simple_range.nil?
      @tbs_simple_range.push(Vertex.new(0,0))
    end
  end
  #----------------------------------------------------------------------------
  # * Load range data for other directions
  #----------------------------------------------------------------------------
  def load_other_ranges(dir, struct)
    case dir
    when :up
      up = struct[:up]
      struct[:down] ||= flip_range_x(up)
      struct[:left] ||= flip_range_neg_xy(up)
      struct[:right] ||= flip_range_xy(up)
    when :down
      down = struct[:down]
      struct[:up] ||= flip_range_x(down)
      struct[:left] ||= flip_range_xy(down)
      struct[:right] ||= flip_range_neg_xy(down)
    when :left
      left = struct[:left]
      struct[:down] ||= flip_range_xy(left)
      struct[:right] ||= flip_range_y(left)
      struct[:up] ||= flip_range_neg_xy(left)
    when :right
      right = struct[:right]
      struct[:down] ||= flip_range_neg_xy(right)
      struct[:left] ||= flip_range_y(right)
      struct[:up] ||= flip_range_xy(right)
    end
  end
  #----------------------------------------------------------------------------
  # flip range across y = x + b, solve for b for each point
  #----------------------------------------------------------------------------
  def flip_range_xy(points); points.collect{ |v| Vertex.new(-v.y,-v.x)}; end
  #----------------------------------------------------------------------------
  # flip each point across y = -x + b, solve for b based on point
  #----------------------------------------------------------------------------
  def flip_range_neg_xy(points); points.collect{ |v| Vertex.new(v.y,v.x)}; end
  #----------------------------------------------------------------------------
  # flip range across y = b, solve for b for each point
  #----------------------------------------------------------------------------
  def flip_range_y(points); points.collect{ |v| Vertex.new(-v.x,v.y)}; end
  #----------------------------------------------------------------------------
  # flip range across x = b, solve for b for each point
  #----------------------------------------------------------------------------
  def flip_range_x(points); points.collect{ |v| Vertex.new(v.x, -v.y)}; end
  #----------------------------------------------------------------------------
  # * Remove this
  #----------------------------------------------------------------------------
  def to_s; "Skill #{@id}: #{@name}"; end
end # RPG::UsableItem 

#==============================================================================
# ** EquipItem
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class RPG::EquipItem < RPG::BaseItem
  # Modifiers to actions possible per turn as determined by notetags
  attr_accessor :all_acts_mod, :target_acts_mod, :move_acts_mod, 
    :skill_acts_mod, :item_acts_mod, :batk_acts_mod, :pool_acts_mod
  # Modifiers to ranges
  attr_accessor :move_mod_tb, :batk_mod_tb
  attr_accessor :skill_mod_tb, :item_mod_tb    # hash types => [min, max]
  
  attr_accessor :batk_mod_min, :batk_mod_max   # hash, types => min or max
  attr_accessor :skill_mod_min, :skill_mod_max # hash, types => min or max
  attr_accessor :item_mod_min, :item_mod_max   # hash, types => min or max
  
end # RPG::EquipItem

#==============================================================================
# RPG::Enemy::Action
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class RPG::Enemy::Action; attr_reader :skill_id; end
# RPG::Enemy::Action

#==============================================================================
# ** DataManager
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
module DataManager
  #----------------------------------------------------------------------------
  # * Aliases
  #----------------------------------------------------------------------------
  class <<self 
    alias load_db_enemies_wn_tb load_database 
    alias init_reset_tb_data init
    alias save_game_tb_era save_game
  end
  #----------------------------------------------------------------------------
  # * Save game without rescue
  #----------------------------------------------------------------------------
  def self.save_game(index)
    save_tb
    save_game_tb_era(index)
  end
  #----------------------------------------------------------------------------
  # * Save TB
  #----------------------------------------------------------------------------
  def self.save_tb
    $game_system.save_tb_data
  end
  #----------------------------------------------------------------------------
  # * Load Database
  #----------------------------------------------------------------------------
  def self.load_database
    load_db_enemies_wn_tb
    if !$BTEST
      load_actor_names
      load_enemy_names
      load_tags_tb(:actors)
      load_tags_tb(:enemies)
      load_tags_usables_tb_era
    end
  end
  #----------------------------------------------------------------------------
  # * Init
  #----------------------------------------------------------------------------
  def self.init
    init_reset_tb_data
    TactBattleManager.exit_tb if TactBattleManager.tact_battle? # reset w/ f12
  end
  #----------------------------------------------------------------------------
  # * Load Tags
  #----------------------------------------------------------------------------
  def self.load_tags_tb(sym)
    iter = sym == :actors ? $data_actors : $data_enemies
    iter.each do |battler|
      next unless battler
      
      init_tb_defaults(battler)
      battler.note.split(/[\r\n]+/).each do |line|
        case line
        when TactBattleManager::Regex::Unit_Move
          battler.base_move_range = $1.to_i
        when TactBattleManager::Regex::Unit_Jump
          battler.base_jump = $1.to_i
          battler.set_base_jumpables($2)
        when TactBattleManager::Regex::Unit_Pass
          battler.set_base_passables($1)
        when TactBattleManager::Regex::MoveActionLmt
          battler.move_action_lmt = $1.to_i
        when TactBattleManager::Regex::SkillActionLmt
          battler.skill_action_lmt = $1.to_i
        when TactBattleManager::Regex::ItemActionLmt
          battler.item_action_lmt = $1.to_i
        when TactBattleManager::Regex::AttackActionLmt
          battler.attack_action_lmt = $1.to_i
        when TactBattleManager::Regex::AllActionLmt
          battler.all_action_lmt = $1.to_i
        when TactBattleManager::Regex::BasicAttack
          battler.basic_atk_id_tb = $1.to_i
        when TactBattleManager::Regex::TargetActionLmt
          battler.target_tb_lmt = $1.to_i
        end
      end
    end
  end
  #----------------------------------------------------------------------------
  # * Init action limits to 1 if not set
  #----------------------------------------------------------------------------
  def self.init_tb_defaults(battler)
    tm = TactBattleManager
    battler.all_action_lmt ||= 1
    battler.attack_action_lmt ||= 1
    battler.move_action_lmt ||= 1
    battler.item_action_lmt ||= 1
    battler.skill_action_lmt ||= 1
    battler.target_tb_lmt ||= 1
    battler.basic_atk_id_tb ||= 1
    battler.pool_acts_mod ||= 1
    
    battler.base_move_range = tm::Defaults::Move
    battler.base_jump = tm::Defaults::Jump
    battler.base_jumpables = tm::Defaults::Jumpables
    battler.base_passables = tm::Defaults::Passables
  end
  #----------------------------------------------------------------------------
  # * Load notetags for usable items
  #----------------------------------------------------------------------------
  def self.load_tags_usables_tb_era
    iter = [$data_items, $data_skills]
    loading_spec = [] # array for splitting up spec range
    dir = nil
    load_rn = false # trigger loading chars
    load_aoe = false
    
    iter.each do |set|
      set.each do |usable|
        next unless !usable.nil?
        usable.note.split(/[\r\n]+/).each do |line|
          case line
          when TactBattleManager::Regex::Spec_Range
            load_rn = true
            dir = $1.to_sym
            next
          when TactBattleManager::Regex::Spec_Range_End # specific item range
            if load_rn
              usable.range_from_diagram(loading_spec, dir)
              load_rn = false
            elsif load_aoe
              usable.aoe_from_diagram(loading_spec, dir)
              load_aoe = false
            end
            loading_spec = []
          when TactBattleManager::Regex::Simple_Range # simple item range
            usable.tb_range_min = $1.to_i
            usable.tb_range_max = $2.to_i
            usable.make_simple_range
          when TactBattleManager::Regex::Range_Target_Self
            usable.tb_self_target = true
          when TactBattleManager::Regex::Skill_Aoe
            usable.tb_aoe = true
            load_aoe = true
            dir = $1.to_sym
            next
          end
          loading_spec.push(line.split("")) if load_rn || load_aoe
        end
        usable.load_tb_target_self
      end
    end # iter.each
  end # load_tags_usbales_tb_era
  #----------------------------------------------------------------------------
  # * Used for quick access to an actor based on their name
  #----------------------------------------------------------------------------
  def self.load_actor_names
    @data_names_actors = {}
    da = $data_actors
    da.each_with_index do |actor, index|
      # Store the index not enemy to keep refs in one place 
      @data_names_actors[actor.name] = index unless !actor
    end # da.each_with_index 
  end # load_actor_names
  #----------------------------------------------------------------------------
  # * Used to quickly retrieve an enemy based on it's name
  #----------------------------------------------------------------------------
  def self.load_enemy_names
    @data_names_enemies = {}
    de = $data_enemies
    de.each_with_index{ |enemy, index|
      # Store the index instead of the enemy to keep all enemies in one place 
      @data_names_enemies[enemy.name] = index unless !enemy
    }
  end
  #----------------------------------------------------------------------------
  # * actor_index_by_name
  #----------------------------------------------------------------------------
  def self.actor_index_by_name(name)
    @data_names_actors[name]
  end
  #----------------------------------------------------------------------------
  # * enemy_index_by_name
  #----------------------------------------------------------------------------
  def self.enemy_index_by_name(name)
    @data_names_enemies[name]
  end
  #----------------------------------------------------------------------------
  # * Loading Notetags using Ra DB notetag methods
  #----------------------------------------------------------------------------
  class << self; alias eval_note_era_tb eval_note_era; end
  def self.eval_note_era(data, line)
    eval_note_era_tb(data,line)
    tm = TactBattleManager
    case line
    when tm::Regex::Shared_Acts
      data.parse_shared_acts($1)
    when tm::Regex::SIType; data.tb_type = $1.upcase
    when tm::Regex::EModMove
      data.move_mod_tb = $1.to_s.eql?("+") ? $2.to_i : $2.to_i * -1
    when tm::Regex::EModBatk
      data.batk_mod_tb = $1.to_s.eql?("+") ? $2.to_i : $2.to_i * -1
    when tm::Regex::EModSkill
      no = $3.to_s.eql?("+") ? $4.to_i : $4.to_i * -1
      t = $1.upcase
      data.skill_mod_min ||= {}
      data.skill_mod_max ||= {}
      $2.eql?("max") ? (data.skill_mod_max[t]=no) : (data.skill_mod_min[t]=no)
    when tm::Regex::EModItem
      # changed to skill for now
      no = $3.to_s.eql?("+") ? $4.to_i : $4.to_i * -1
      t = $1.upcase
      data.skill_mod_min ||= {}
      data.skill_mod_max ||= {}
      $2.eql?("max") ? data.skill_mod_max[t] = no : data.skill_mod_min[t] = no
    when tm::Regex::EModBatk
      no = $2.to_s.eql?("+") ? $3.to_i : $3.to_i * -1
      $1.eql?("max") ? data.batk_mod_max = no : data.batk_mod_min = no
    when tm::Regex::EAllActs
      data.all_acts_mod = $1.to_s.eql?("+") ? $2.to_i : $2.to_i * -1
    when tm::Regex::ETargetActs
      data.target_acts_mod = $1.to_s.eql?("+") ? $2.to_i : $2.to_i * -1
    when tm::Regex::EMoveActs
      data.move_acts_mod = $1.to_s.eql?("+") ? $2.to_i : $2.to_i * -1
    when tm::Regex::EBAtkActs
      data.batk_acts_mod = $1.to_s.eql?("+") ? $2.to_i : $2.to_i * -1
    when tm::Regex::ESkillActs
      data.skill_acts_mod = $1.to_s.eql?("+") ? $2.to_i : $2.to_i * -1
    when tm::Regex::EItemActs
      data.item_acts_mod = $1.to_s.eql?("+") ? $2.to_i : $2.to_i * -1
    when tm::Regex::PoolActs
      data.pool_acts_mod = $1.to_i
    when tm::Regex::EPoolActs
      data.pool_acts_mod = $1.to_s.eql?("+") ? $2.to_i : $2.to_i * -1
    when tm::Regex::HealItem
      data.is_healer_tb = true
    when tm::Regex::SupportUnit
      data.is_support_unit = true
    end
  end
end # DataManager

#==============================================================================
# ** SceneManager
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
module SceneManager
  #----------------------------------------------------------------------------
  # * Aliases
  #----------------------------------------------------------------------------
  class << self
    alias snapsfor_backgd_ra_251790 snapshot_for_background
  end
  #----------------------------------------------------------------------------
  # * Get the stack
  #----------------------------------------------------------------------------
  def self.get_stack; @stack; end
  #----------------------------------------------------------------------------
  # * Create Snapshot to Use as Background
  #----------------------------------------------------------------------------
  def self.snapshot_for_background
    return snapsfor_backgd_ra_251790 if !TactBattleManager.tact_battle?
    @background_bitmap.dispose if @background_bitmap
    return @background_bitmap = Graphics.snap_to_bitmap
  end # snapshot_for_background
end # SceneManager

#==============================================================================
# ** Game_Map
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class Game_Map
  attr_accessor :next_hl_locs, :next_hl_color
  attr_reader :party_init_ox, :party_init_oy, :placement_arr_tb, :map,
                :spawn_pos_tb
  #----------------------------------------------------------------------------
  # * Setup
  #----------------------------------------------------------------------------
  alias setup_era_63495325008 setup
  def setup(map_id)
    setup_era_63495325008(map_id)
    
    loading_spec = []
    load_sq = false
    @spawn_pos_tb = End_PosTB.new
    
    @map.note.split(/[\r\n]+/).each do |line|
      case line
      when TactBattleManager::Regex::Party_Init_Sq; load_sq = true; next;
      when TactBattleManager::Regex::Spec_Range_End
        store_party_place_rng(loading_spec)
        load_sq = false
      when TactBattleManager::Regex::Party_Init_xy
        @party_init_ox, @party_init_oy = $1.to_i, $2.to_i
      when TactBattleManager::Regex::Party_Respawn
        @spawn_pos_tb.add_spawn([$1.to_i, $2.to_i])
      end
      loading_spec.push(line.split("")) if load_sq 
    end
  end
  #----------------------------------------------------------------------------
  # * Placement for party at the end of a tactical battle
  #----------------------------------------------------------------------------
  def end_pos_data_tb
    @spawn_pos_tb ||= End_PosTB.new
  end
  #----------------------------------------------------------------------------
  # * Store Party Placement Range
  #     Range party can be placed in for this map.
  #----------------------------------------------------------------------------
  def store_party_place_rng(str_arr)
    
    # CHANGE, VERY SIMILAR CODE IN RPG::USABLEITEM
    
    ox,oy = -1,-1
    @placement_arr_tb = []
    # initial pass finds origin
    str_arr.each_with_index do |arr,i|
      arr.each_with_index do |letter,j|
        ox, oy = j, i if TactBattleManager.orig_char?(letter)
      end
    end
    
    raise "Invaid placement tags for map #{@map_id}.\n" if ox == -1 || oy == -1
    
    # second pass offsets coordinates based on origin
    str_arr.each_with_index do |arr,i|
      arr.each_with_index do |letter,j|
        
        if TactBattleManager.hit_char?(letter)
          @placement_arr_tb.push(Vertex.new(j-ox,i-oy));
        end
        
      end
    end # str_arr.each_with_index
    
  end
  #----------------------------------------------------------------------------
  # * Highlights that should be added to spriteset map for Scene_Map upon
  #     returning to it
  #----------------------------------------------------------------------------
  def next_att_highlights(locs, color)
    @next_hl_locs = locs
    @next_hl_color = color
  end
  #----------------------------------------------------------------------------
  # * Clear Next Highlights
  #----------------------------------------------------------------------------
  def clear_next_highlights
    @next_hl_locs, @next_hl_color = nil, nil
  end
  #----------------------------------------------------------------------------
  # * Passable any direction?
  #----------------------------------------------------------------------------
  def passable_any_dir?(x,y)
    [2,4,6,8].each{ |d|return true if passable?(x,y,d)}
    return false
  end
  #----------------------------------------------------------------------------
  # * Reset exy_cache based on event data
  #----------------------------------------------------------------------------
  def reset_exy_cache
    @events.keys.each do |id|
      e = @events[id]
      next if !e
      @exy_cache[[e.x,e.y]].push(id) if !(@exy_cache[[e.x,e.y]]||=[]).include?(id)
    end
  end
  #----------------------------------------------------------------------------
  # * Alias, Set up Events
  #----------------------------------------------------------------------------
  alias setup_events_tb_era setup_events
  def setup_events
    @exy_cache = {}
    # will cause events to be passed over twice but better than overwriting
    @map.events.each do |i, event|
      (@exy_cache[[event.x, event.y]] ||= []).push(i)
    end
    setup_events_tb_era
    refresh_tile_events
  end
  #----------------------------------------------------------------------------
  # * It's too slow to use events_xy(x,y) to obtain the events at a specific 
  #     xy location when running the ai and generating graphs so they are 
  #     mapped to their locations instead.
  #
  #   Assumption is that there will almost never be more than 3 events at the
  #   same location so it will actually be better to just use an array so that
  #   the actual iterations made when checking a value will be smaller. (Hash 
  #   with 3 elements actually means ~10 iterations are made when obtaining 
  #   those elements).
  #----------------------------------------------------------------------------
  def cache_event_xy(x,y,id)
    @exy_cache[[x,y]] ||= []
    @exy_cache[[x,y]].push(id) if !@exy_cache[[x,y]].include?(id)
  end
  #----------------------------------------------------------------------------
  # * Returns the id of the tb_unit at this location if there is one, otherwise
  #     it returns the first event
  #----------------------------------------------------------------------------
  def tbu_id_xy(x,y)
    if list = @exy_cache[[x,y]]
      list.each do |id| 
        e = @events[id]
        return id if e && e.tb_unit.battler 
      end
    end
    0
  end
  #----------------------------------------------------------------------------
  # * => tb_unit id, highest priority, otherwise any other event id 
  #----------------------------------------------------------------------------
  def tbu_1st_xy(x,y)
    t=0
    if list = @exy_cache[[x,y]]
      list.each do |id| 
        e = @events[t=id]
        return id if e && e.tb_unit.battler 
      end
    end
    t
  end
  #---------------------------------------------------------------------------
  # * return list of hashed ids
  #---------------------------------------------------------------------------
  def cache_ids_xy(x,y)
    (ids = @exy_cache[[x,y]]) ? ids : []
  end
  #---------------------------------------------------------------------------
  # * Doesn't return erased events, events with through passability, or events
  #     that can produe units.
  #---------------------------------------------------------------------------
  def cache_ids_xy_no_etp(x,y)
    es = @events
    r = cache_ids_xy(x,y).inject([]) do |a,id| e = es[id]
      a.push(id) if !e.erased && !e.through #&& !e.tb_prod
    end
    r.nil? ? [] : r
  end
  #---------------------------------------------------------------------------
  # * Remove id from hahsed xy 
  #---------------------------------------------------------------------------
  def remove_exy_cached(x,y,id)
    if list = @exy_cache[[x,y]]
      list.delete(id)
    end
  end
  #---------------------------------------------------------------------------
  # * Alias, Reproduce Events - destory_event_any, remove from cache as well
  #---------------------------------------------------------------------------
  alias destroy_event_any_tb_era destroy_event_any
  def destroy_event_any(id)
    e=@events[id]
    remove_exy_cached(e.x,e.y,id) if e
    destroy_event_any_tb_era(id)
  end
  #--------------------------------------------------------------------------
  # * Setter for events
  #--------------------------------------------------------------------------
  def events=(events)
    @events = events
    @need_refresh = true
  end
end # Game_Map

#==============================================================================
# ** Game_CharacterBase
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class Game_CharacterBase
  attr_accessor :flash_soft_tb
  #--------------------------------------------------------------------------
  # * Symbol to Direction
  #--------------------------------------------------------------------------
  def sym_to_dir_era(sym)
    case sym
    when :down; return 2;
    when :left; return 4;
    when :right; return 6;
    when :up; return 8;
    end
  end
  #--------------------------------------------------------------------------
  # * Directon to symbol
  #--------------------------------------------------------------------------
  def dir_to_sym_era(dir = nil)
    dir ||= @direction
    case dir
    when 2; return :down;
    when 4; return :left;
    when 6; return :right;
    when 8; return :up;
    end
  end
  
end # Game_CharacterBase
#=============================================================================
# ** Game_Character
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#=============================================================================
class Game_Character < Game_CharacterBase
  attr_accessor :started_tb_flash
  #----------------------------------------------------------------------------
  # * Save Tones in a hash mapping a symbol to an array of tones
  #     array ordered: gray, green, red, blue
  #----------------------------------------------------------------------------
  def save_tones_tb(sym, tones)
    @tones_tb ||= {}
    @tones_tb[sym] = tones
  end
  #----------------------------------------------------------------------------
  # * Get saved tones
  #     return value is an array ordered: gray, green, red, blue
  #----------------------------------------------------------------------------
  def saved_tones_tb(sym)
    (@tones_tb ||= {})[sym]
  end
end # Game_Character
#=============================================================================
# ** Game_Event
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#=============================================================================
class Game_Event < Game_Character
  attr_accessor :move_speed, :direction, :tb_unit
  attr_reader :erased
  attr_accessor :spotlight     # Centers screen over event when true
  attr_accessor :acts_done_tb  # actions finished for this turn
  attr_reader :tb_dj_path      # used to prevent rerunning djikstra's if it has 
                               # already been run for the event's coordinates.
  attr_reader :tb_dj_distances
  attr_reader :tb_prod         # true if the event can produce units.
                               # production events are special, units can be 
                               # placed on top of them. That unit must be moved
                               # off of them before another can be produced.
  attr_reader :tb_prod_syms
  attr_accessor :waiting_tb    # put unit in easy to identify waiting state
  attr_accessor :tb_response_wait # bool, waiting for event to finish response
  attr_reader :target_evs_tb # list of target events. [0] is highest priority
  attr_accessor :id
  attr_accessor :interpreter
  attr_accessor :list
  
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  alias initiali_tb_ge_mod_ra initialize
  def initialize(*args)
    initiali_tb_ge_mod_ra(*args)
    @tb_unit = Tactical_Unit.new
    @tb_unit.after_init(@id)
    @tb_unit.init_battler(event.name)
    @old_x_tb = @event.x
    @old_y_tb = @event.y
    @acted_tb = false
    @tb_prod_syms = []
    @ai_prod_syms = []
    @target_evs_tb = []
    refresh_tb_production
  end
  #----------------------------------------------------------------------------
  # Alias * Collide With Characters
  #----------------------------------------------------------------------------
  alias ra_tbs_collide_with_char collide_with_characters?
  def collide_with_characters?(x, y)
    super || (TactBattleManager.tact_battle? ? false : collide_with_player_characters?(x, y))
  end
  #--------------------------------------------------------------------------
  # * Add an event to this units targets
  #--------------------------------------------------------------------------
  def add_target_tb(ev, priority = 0)
    @target_evs_tb[priority] = ev
  end
  #--------------------------------------------------------------------------
  # * Alias, refresh
  #--------------------------------------------------------------------------
  alias refresh_tb_era refresh
  def refresh
    refresh_tb_era
    refresh_tb_production
  end
  #----------------------------------------------------------------------------
  # * Production symbols
  #----------------------------------------------------------------------------
  def load_tb_production_symbols
    @tb_prod_syms = []
    @ai_prod_syms = []
    return @tb_prod_syms if (comments = Era::Event.valid_comments(id)).nil?
    comments.each do |str|
      case str
      when TactBattleManager::Regex::ProdUnit
        @tb_prod_syms.push($1.to_sym)
      when TactBattleManager::Regex::AIProdUnit
        @ai_prod_syms.push($1.to_sym)
      end
    end
    TactBattleManager.ai_produce(@id, @ai_prod_syms) if !@ai_prod_syms.empty? 
    @tb_prod_syms
  end
  def refresh_tb_production
    @tb_prod = true if !load_tb_production_symbols.empty?
  end
  #----------------------------------------------------------------------------
  # * Update Scroll
  #----------------------------------------------------------------------------
  def update_scroll(last_real_x, last_real_y)
    ax1 = $game_map.adjust_x(last_real_x)
    ay1 = $game_map.adjust_y(last_real_y)
    ax2 = $game_map.adjust_x(@real_x)
    ay2 = $game_map.adjust_y(@real_y)
    $game_map.scroll_down (ay2 - ay1) if ay2 > ay1 && ay2 > $game_player.center_y
    $game_map.scroll_left (ax1 - ax2) if ax2 < ax1 && ax2 < $game_player.center_x
    $game_map.scroll_right(ax2 - ax1) if ax2 > ax1 && ax2 > $game_player.center_x
    $game_map.scroll_up   (ay1 - ay2) if ay2 < ay1 && ay2 < $game_player.center_y
  end # End - update_scroll
  
  #----------------------------------------------------------------------------
  # * Alias update
  #----------------------------------------------------------------------------
  alias update_event_spotlight_ra_tbs update
  def update
    last_real_x = @real_x
    last_real_y = @real_y
    update_exy_cache                       # update before @move_route_forcing
    update_event_spotlight_ra_tbs
    
    center_camera_tb(last_real_x, last_real_y)
    
    if @temp_ghost && !@move_route_forcing # through was on temporarily
      @through = @old_through
      @temp_ghost = false
    end
    
    
    update_fading_tb
  end
  #----------------------------------------------------------------------------
  # * Ceneter Camera on this event if this is the event that is currently moving
  #     during a tactical battle
  #----------------------------------------------------------------------------
  def center_camera_tb(last_real_x, last_real_y)
    scene = SceneManager.scene
    return if !scene.is_a?(Scene_Map)
    
    scmap_evw = scene.instance_eval('@event_waiting_for')
    update_scroll(last_real_x, last_real_y) if scmap_evw && scmap_evw == @id
  end
  #----------------------------------------------------------------------------
  # * 
  #----------------------------------------------------------------------------
  def update_exy_cache
    $game_map.cache_event_xy(@x,@y,@id) if @move_route_forcing
    
    if @old_x_tb != @x || @old_y_tb != @y 
      $game_map.remove_exy_cached(@old_x_tb, @old_y_tb, @id)
      @old_x_tb, @old_y_tb = @x, @y
    end
  end
  #----------------------------------------------------------------------------
  # * Fade out event
  #----------------------------------------------------------------------------
  def start_fading_tb(rate, min_fade, rm_when_done = false)
    @fading_tb = true
    @fading_rate_tb = rate
    @fading_min_tb = min_fade
    @rm_after_fade = rm_when_done
  end
  def fading_tb?; @fading_tab; end
  def update_fading_tb
    return if !@fading_tb
    @opacity-=@fading_rate_tb
    if @opacity <= @fading_min_tb
      @fading_tb = false 
      $game_map.destroy_event_any(@id) if @rm_after_fade
    end
  end
  #----------------------------------------------------------------------------
  # * Give Spotlight
  #----------------------------------------------------------------------------
  def give_spotlight
    @spotlight = true
    $game_player.center(@x, @y) 
  end
  #----------------------------------------------------------------------------
  # * Temp Ghost
  #     set passability to through and treat this tb_unit as a ghost
  #----------------------------------------------------------------------------
  def temp_ghost
    @temp_ghost = true
    @through = true
  end
  #----------------------------------------------------------------------------
  # * Battler
  #     Get the battler associated with this event's tb_unit
  #----------------------------------------------------------------------------
  def battler
    return nil if @tb_unit.nil?
    @tb_unit.battler
  end
  def give_path(path); @tb_dj_path = path; end
  def give_distances(ds); @tb_dj_distances = ds; end
  #----------------------------------------------------------------------------
  # * TB Party Event
  #     Check if this event has the same name as a party member
  #----------------------------------------------------------------------------
  def tb_party_event?
    pty = $game_party
    pty.members.each{|a| return true if a.name.eql?(@event.name)}
    return false
  end
  
  # REMOVE ON RELEASE
  def to_s
    "Event #{@id}: #{@event.name}"
  end
  #----------------------------------------------------------------------------
  # * Modify lock so enemy units won't turn toward the player during a 
  #     tactial battle.
  #----------------------------------------------------------------------------
  alias lock_era_43939834115 lock
  def lock
    return lock_era_43939834115 unless TactBattleManager.tact_battle?
    
    unless @locked
      @prelock_direction = @direction
      # original method calls turn_toward_player here
      @locked = true
    end
  end
  #----------------------------------------------------------------------------
  # * Save list before telling event to move.
  #----------------------------------------------------------------------------
  def save_list_tb
    @saved_list_tb = @list
  end
  #----------------------------------------------------------------------------
  # * Restore saved list
  #----------------------------------------------------------------------------
  def restore_list_tb
    @list = @saved_list_tb
  end
  #----------------------------------------------------------------------------
  # * Set movement speed
  #----------------------------------------------------------------------------
  def set_speed_tb_era(s); @move_speed = s; end
  def event_id_tb; @id; end
end # Game_Event

#==============================================================================
# * Game_Player
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class Game_Player
  attr_accessor :move_speed
  #--------------------------------------------------------------------------
  # * Alias Initialize
  #--------------------------------------------------------------------------
  alias initialize_tb_era initialize
  def initialize
    initialize_tb_era
    @tb_grid_mv = 0 # offset movement so it is choppy
  end
  #--------------------------------------------------------------------------
  # * Start map event
  #--------------------------------------------------------------------------
  def start_map_event_prox(id, triggers, normal)
    # return if $game_map.interpreter.running? # Expect bugs since removed!
    event = $game_map.events[id]
    event.start if event.trigger_in?(triggers) && event.normal_priority? == normal
  end
  #--------------------------------------------------------------------------
  # * Determine if Front Event is Triggered
  #--------------------------------------------------------------------------
  alias tb_chk_ev_trigg_there_mod check_event_trigger_there
  def check_event_trigger_there(triggers)
    return if TactBattleManager.tact_battle?
    tb_chk_ev_trigg_there_mod(triggers)
  end
  #--------------------------------------------------------------------------
  # * Determine if Touch Event is Triggered
  #--------------------------------------------------------------------------
  alias tb_chk_ev_trigg_touch check_event_trigger_touch
  def check_event_trigger_touch(x, y)
    return if TactBattleManager.tact_battle?
    tb_chk_ev_trigg_touch(x,y)
  end
  #--------------------------------------------------------------------------
  # * Turn off Encounter Processing
  #--------------------------------------------------------------------------
  alias enc_t_off_tbs_mod encounter
  def encounter
    return false if TactBattleManager.tact_battle?
    enc_t_off_tbs_mod
  end
  #--------------------------------------------------------------------------
  # * Trigger Map Event
  #     triggers : Trigger array
  #     normal   : Is priority set to [Same as Characters] ?
  #--------------------------------------------------------------------------
  alias st_map_ev_tbs_mod start_map_event
  def start_map_event(*args)
    return if TactBattleManager.tact_battle?#@is_cursor
    st_map_ev_tbs_mod(*args)
  end
  #--------------------------------------------------------------------------
  # * Determine if Same Position Event is Triggered
  #--------------------------------------------------------------------------
  alias chk_ev_trigg_here_tbs_mod check_event_trigger_here
  def check_event_trigger_here(triggers)
    chk_ev_trigg_here_tbs_mod(triggers) unless TactBattleManager.tact_battle?
  end  
  #---------------------------------------------------------------------------
  # * Alias move_by_input
  #---------------------------------------------------------------------------
  alias mv_by_input_tb_mod move_by_input
  def move_by_input
    return if TactBattleManager.selecting?
    return choppy_movement_tb if TactBattleManager.tact_battle?
    mv_by_input_tb_mod 
  end
  #---------------------------------------------------------------------------
  # * Choppy cursor movement during a tactical battle
  #---------------------------------------------------------------------------
  def choppy_movement_tb
    @tb_grid_mv = @tb_grid_mv == 3 ? 0 : @tb_grid_mv + 1
    if TactBattleManager.tact_battle? &&  @tb_grid_mv == 2 
        Sound.play_cursor if Input.dir4 > 0 && @x == @real_x && @y == @real_y
        mv_by_input_tb_mod
    end
  end
end # Game_Player

#=============================================================================
# ** Game_Actor
#     Ignore state updates for player while treating as cursor on map.
#=============================================================================
class Game_Actor < Game_Battler
  attr_accessor :actions
  attr_accessor :tb_unit          # reference to associated tb_unit during a tb
  #------------------------- -------------------------------------------------
  # * Processing Performed When Player Takes 1 Step
  #--------------------------------------------------------------------------
  alias on_pl_wk_tbs_cursor_mod on_player_walk
  def on_player_walk
    return if TactBattleManager.tact_battle?
    on_pl_wk_tbs_cursor_mod
  end
  #--------------------------------------------------------------------------
  # * Is support unit? (AI use)
  #--------------------------------------------------------------------------
  def is_support_unit
    $data_actors[@actor_id].is_support_unit
  end
  #--------------------------------------------------------------------------
  # * Base Move Range
  #--------------------------------------------------------------------------
  def base_move_range_tb
    $data_actors[@actor_id].base_move_range
  end
  #--------------------------------------------------------------------------
  # * Base Jump Range
  #--------------------------------------------------------------------------
  def base_jump_range_tb
    $data_actors[@actor_id].base_jump
  end
  #--------------------------------------------------------------------------
  # * Base Jumpables
  #--------------------------------------------------------------------------
  def base_jumpables_tb
    $data_actors[@actor_id].base_jumpables
  end
  #--------------------------------------------------------------------------
  # * Base Passables
  #--------------------------------------------------------------------------
  def base_passables_tb
    $data_actors[@actor_id].base_passables
  end
  #--------------------------------------------------------------------------
  # * Getters
  #--------------------------------------------------------------------------
  def all_action_lmt; $data_actors[@actor_id].all_action_lmt; end
  def move_action_lmt; $data_actors[@actor_id].move_action_lmt; end
  def skill_action_lmt; $data_actors[@actor_id].skill_action_lmt; end
  def item_action_lmt; $data_actors[@actor_id].item_action_lmt; end
  def attack_action_lmt; $data_actors[@actor_id].attack_action_lmt; end
  def basic_atk_tb; $data_actors[@actor_id].basic_atk_id_tb; end
  def target_tb_lmt; $data_actors[@actor_id].target_tb_lmt; end
  def shared_acts; $data_actors[@actor_id].shared_acts ||= []; end
  def pool_acts_mod; $data_actors[@actor_id].pool_acts_mod; end
    
  #--------------------------------------------------------------------------
  # * Optimize Equipments **Need to modify how this works during a tb (?)
  #--------------------------------------------------------------------------
  alias optimize_equipments_tb_era optimize_equipments
  def optimize_equipments
    if @tb_unit && TactBattleManager.tact_battle?
      clear_equipments
      equip_slots.size.times do |i|
        next if !equip_change_ok?(i)
        items = tb_unit.equip_items.select do |item|
          item.etype_id == equip_slots[i] &&
          equippable?(item) && item.performance >= 0
        end
        change_equip(i, items.max_by {|item| item.performance })
      end
    else
      optimize_equipments_tb_era
    end
  end
  #--------------------------------------------------------------------------
  # need to modify how this works during atb
  #--------------------------------------------------------------------------
  def clear_equipments
    equip_slots.size.times do |i|
      change_equip(i, nil) if equip_change_ok?(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Change Equip
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    return unless trade_item_with_party(item, equips[slot_id])
    return if item && equip_slots[slot_id] != item.etype_id
    @equips[slot_id].object = item
    refresh
  end
  #--------------------------------------------------------------------------
  # * Alias, trade_item_with_party
  #--------------------------------------------------------------------------
  alias trade_item_with_party_tb_era trade_item_with_party
  def trade_item_with_party(new_item, old_item)
    if @tb_unit && TactBattleManager.tact_battle?
      return false if new_item && !@tb_unit.has_item?(new_item)
      @tb_unit.gain_item(old_item, 1)
      @tb_unit.lose_item(new_item, 1)
      return true
    else
      return trade_item_with_party_tb_era(new_item, old_item)
    end
  end
  #--------------------------------------------------------------------------
  # * Equip Range Max
  #--------------------------------------------------------------------------
  def eqp_r_max(item)
    max, type = 0, item.tb_type
      equips.each do |e| next if e.nil?
        e.skill_mod_max ||={}
        max+= (e.skill_mod_max[type]||=0) 
      end
    max
  end
  #--------------------------------------------------------------------------
  # * Equip Range Min
  #--------------------------------------------------------------------------
  def eqp_r_min(item)
    min, type = 0, item.tb_type
      equips.each do |e|  next if e.nil? 
        e.skill_mod_min||={}
        min+=(e.skill_mod_min[type]||=0) 
      end
    min
  end
end # Game_Actor

#==============================================================================
# ** Game_Enemy
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class Game_Enemy < Game_Battler
  attr_accessor :tb_unit # reference to its tb_unit
  #--------------------------------------------------------------------------
  # * Is support unit? (AI use)
  #--------------------------------------------------------------------------
  def is_support_unit
    $data_enemies[@enemy_id].is_support_unit
  end
  #--------------------------------------------------------------------------
  # * Base Movement Range
  #--------------------------------------------------------------------------
  def base_move_range_tb
    $data_enemies[@enemy_id].base_move_range
  end
  #--------------------------------------------------------------------------
  # * Base Jump Range
  #--------------------------------------------------------------------------
  def base_jump_range_tb
    $data_enemies[@enemy_id].base_jump
  end
  #--------------------------------------------------------------------------
  # * Base Jumpables
  #--------------------------------------------------------------------------
  def base_jumpables_tb
    $data_enemies[@enemy_id].base_jumpables
  end
  #--------------------------------------------------------------------------
  # * Base Passables
  #--------------------------------------------------------------------------
  def base_passables_tb
    $data_enemies[@enemy_id].base_passables
  end
  #--------------------------------------------------------------------------
  # * Getters
  #--------------------------------------------------------------------------
  def all_action_lmt; $data_enemies[@enemy_id].all_action_lmt; end
  def move_action_lmt; $data_enemies[@enemy_id].move_action_lmt; end
  def skill_action_lmt; $data_enemies[@enemy_id].skill_action_lmt; end
  def item_action_lmt; $data_enemies[@enemy_id].item_action_lmt; end
  def attack_action_lmt; $data_enemies[@enemy_id].attack_action_lmt; end
  def basic_atk_tb; $data_enemies[@enemy_id].basic_atk_id_tb; end
  def target_tb_lmt; $data_enemies[@enemy_id].target_tb_lmt; end
  def shared_acts; $data_enemies[@enemy_id].shared_acts ||= []; end
  def pool_acts_mod; $data_enemies[@enemy_id].pool_acts_mod; end
  #--------------------------------------------------------------------------
  # * Skills
  #--------------------------------------------------------------------------
  def skills
    enemy.actions.inject([]){|a,r| a.push($data_skills[r.skill_id])}
  end
end # Game_Enemy

#==============================================================================
# ** Game_BattlerBase
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class Game_BattlerBase
  #----------------------------------------------------------------------------
  # * Check if the unit that wants to use the item has the item instead of
  #     Game_Party during a tactical battle
  #----------------------------------------------------------------------------
  alias itm_cond_met_mod_edi_era_858934 item_conditions_met?
  def item_conditions_met?(item)
    if TactBattleManager.tact_battle?
      has_item = (tbe=$game_temp.tb_event).nil? || tbe.tb_unit.has_item?(item)
      usable_item_conditions_met?(item) && has_item
    else
      itm_cond_met_mod_edi_era_858934(item)
    end
  end # item_conditions_met?
  #--------------------------------------------------------------------------
  # * Alias, occasion_ok? Check When Skill/Item Can Be Used
  #--------------------------------------------------------------------------
  alias ocassion_ok_tb_era occasion_ok?
  def occasion_ok?(item)
    if TactBattleManager.tact_battle?
      item.battle_ok?
    else
      ocassion_ok_tb_era(item)
    end
  end
end # GameBattlerBase

#==============================================================================
# ** Game_Battler 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#      Pass around information about what spots need to be highlighted during
#      the next jump to Scene_Map.
#==============================================================================
class Game_Battler < Game_BattlerBase
  #----------------------------------------------------------------------------
  # * Alias use_item - add task, show highlights upon return to scene_map
  #----------------------------------------------------------------------------
  alias us_it_edi_use_game_bat_era use_item
  def use_item(item)
    tb = TactBattleManager.tact_battle? && !TactBattleManager.selecting_target?
    return tbs_use_item_era(item) if tb
    us_it_edi_use_game_bat_era(item)
  end # use_item
  #----------------------------------------------------------------------------
  # * Don't Apply global effects during a tactical battle until target is selected
  #----------------------------------------------------------------------------
  alias glob_eff_appl_edi_era item_global_effect_apply
  def item_global_effect_apply(*args)
    return if TactBattleManager.tact_battle? && !TactBattleManager.selecting_target?
    glob_eff_appl_edi_era(*args)
  end
  #--------------------------------------------------------------------------
  # * Apply Effect of Skill/Item
  #--------------------------------------------------------------------------
  alias tb_mod_itm_apply_ali item_apply
  def item_apply(user, item)
    tb_mod_itm_apply_ali(user, item)
    @result
  end
  #----------------------------------------------------------------------------
  # * Modifiers to range minimum by equipment
  #----------------------------------------------------------------------------
  def eqp_r_min(item)
  end
  #----------------------------------------------------------------------------
  # * Modifiers to range max by equipment 
  #----------------------------------------------------------------------------
  def eqp_r_max(item)
  end
  #----------------------------------------------------------------------------
  # * Shannanigans for using item during a TBS
  #----------------------------------------------------------------------------
  def tbs_use_item_era(item)
    
    tb = TactBattleManager.tact_battle?
    ch_tar = tb && TactBattleManager.selecting_target? # remove
    
    # Case during a tact battle, and not selecting a target
    if tb && !ch_tar
      return if (tb_event = $game_temp.tb_event).nil?
      dir = tb_event.dir_to_sym_era
      r1,r2 = item.tbs_spec_range, item.tbs_simple_range
      
      range = r1.nil? ? r2 : r1[dir]
      return no_range_set_tb(item) if r1.nil? && r2.nil?
      
      if r1.nil?
        if self.is_a?(Game_Actor)
          
          n,m = item.tb_range_min-1, item.tb_range_max-1
          range=Unit_Range.points(0,0,eqp_r_min(item) + n,eqp_r_max(item)+m)
        else; range = r2; end
      else; range = r1[dir]; end
      
      if !range.nil?
        range = relative_range_era(range)
        $game_map.next_att_highlights(range, item.tbs_hl_color)
      end
    
      # instead of doing this here, alias use_item inside game_battler, and call
      # it twice. Once when using the item initially, and then again after the
      # target has been selected.
      TactBattleManager.set_selecting_target(true)
      $game_temp.tb_item = item
      
      if !SceneManager.scene.is_a?(Scene_Map) && SceneManager.get_stack.size > 0
        SceneManager.return 
      end
      # SceneManager.return # <= this fucking line of code... omfg wow.. fucking noob shit
                            # was causing SceneManager to pop off last scene from stack
                            # and seemingly exit strangely. Scariest error of my life,
                            # had no call stack to debug with
    end
  end
  #----------------------------------------------------------------------------
  # * No Range set
  #----------------------------------------------------------------------------
  def no_range_set_tb(item)
    msgbox("no range set for #{item.class} #{item.id}\n")
  end
  #----------------------------------------------------------------------------
  # * Converts points to locations relative to the players x,y
  #----------------------------------------------------------------------------
  def relative_range_era(points)
    relative_range = []
    player = $game_player
    x,y = player.x, player.y
    points.each do |v|
      relative_range.push(Vertex.new(v.x + x, v.y + y))
    end
    relative_range
  end # relative_range_era
  #----------------------------------------------------------------------------
  # * Movement Range
  #----------------------------------------------------------------------------
  def move_range_tb
    @tb_move_offset ||=0; b = base_move_range_tb
    msgbox(no_movement_range_tb) if b.nil?
    b + @tb_move_offset
  end
  #----------------------------------------------------------------------------
  # * No Movement Range
  #----------------------------------------------------------------------------
  def no_movement_range_tb
    text = self.is_a?(RPG::Actor) ? "actor #{@actor_id}" : "enemy #{@enemy_id}" 
  end
  #----------------------------------------------------------------------------
  # * Base Movement Range
  #----------------------------------------------------------------------------
  def base_move_range_tb;end;
  #----------------------------------------------------------------------------
  # * Set Action
  #----------------------------------------------------------------------------
  def tb_set_action(action)
    @actions[0] = action
  end
  #----------------------------------------------------------------------------
  # * Calc tb Limits
  #     Calculate overall max and min skill distances and max and min skill
  #     distances for friendly/aggressive skills.
  #----------------------------------------------------------------------------
  def calc_tb_limits
    skils = skills 
    
    skils.push($data_skills[@basic_atk_id_tb]) if @basic_atk_id_tb
    max, min = 0, 1<<31
    maxF, minF = 0, 1<<31
    maxE, minE = 0, 1<<31
    
    @max_s, @min_s = nil, nil 
    @max_sf, @min_sf = nil, nil     #friendly skills
    @max_se, @min_se = nil, nil     #aggressive skills
    r_maxF = r_minF = r_maxE = r_minE = nil
    
    skils.each do |s| 
      r_max = s.tb_range_max
      r_min = s.tb_range_min
      
      r_maxF = s.tb_range_max if s.friendly_target?
      r_minF = s.tb_range_min if s.friendly_target?
      
      r_maxE = s.tb_range_max if s.hostile_target?
      r_minE = s.tb_range_min if s.hostile_target?
      
      (@max_s = s; max = r_max) if r_max && r_max > max
      (@min_s = s; min = r_min) if r_min && r_min < min
      
      (@max_sf = s; maxF = r_maxF) if r_maxF && r_maxF > maxF
      (@min_sf = s; minF = r_minF) if r_minF && r_minF < minF
      
      (@max_se = s; maxE = r_maxE) if r_maxE && r_maxE > maxE
      (@min_se = s; minE = r_minE) if r_minE && r_minE < minE
    end
  end
  #----------------------------------------------------------------------------
  # * Max Range
  #----------------------------------------------------------------------------
  def max_tb_range; @max_s; end
  #----------------------------------------------------------------------------
  # * Min Range
  #----------------------------------------------------------------------------
  def min_tb_range; @min_s; end
  #----------------------------------------------------------------------------
  # * Max Range Aggressive Skills
  #----------------------------------------------------------------------------
  def max_tb_rangeE; @max_se; end
  #----------------------------------------------------------------------------
  # * Min Range Aggresive Skills
  #----------------------------------------------------------------------------
  def min_tb_rangeE; @min_se; end
  #----------------------------------------------------------------------------
  # * Max Range Friendly Skills (not targetting dead units)
  #----------------------------------------------------------------------------
  def max_tb_rangeF; @max_sf; end
  #----------------------------------------------------------------------------
  # * Min Range Friendly Skills (not targetting dead units)
  #----------------------------------------------------------------------------
  def min_tb_rangeF; @min_sf; end
  #----------------------------------------------------------------------------
  # * Skills
  #----------------------------------------------------------------------------
  def skills; []; end
  #----------------------------------------------------------------------------
  # * Skills_tb
  #----------------------------------------------------------------------------
  def skills_tb
    skills.inject([]){ |m,s| s && s.tb_ok? ? m.push(s) : m }
  end
  #----------------------------------------------------------------------------
  # * Alias, Apply Variance
  #----------------------------------------------------------------------------
  alias apply_variance_tb_era apply_variance
  def apply_variance(damage, variance)
    tm = TactBattleManager
    if tm.tact_battle?
      tm.raw_damage = damage 
      tm.raw_amp = [damage.abs * variance / 100, 0].max.to_i
    end
    apply_variance_tb_era(damage, variance)
  end
end # Game_Battler

#==============================================================================
# ** Game_Temp
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class Game_Temp
  # remember the tb unit when switching off of scene_map
  attr_accessor :tb_event, :tb_item
end # Game_Temp

#==============================================================================
# ** Game_Interpreter
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class Game_Interpreter
  #----------------------------------------------------------------------------
  # * New Event
  #----------------------------------------------------------------------------
  def new_event(mid, opts = {}); 
    Era::Event.new_event(mid, opts); 
  end
  #----------------------------------------------------------------------------
  # * Response Wait
  #----------------------------------------------------------------------------
  def response_wait_tb(b=false, destroy = false, restore = true)
    wait(20)
    e = (map = $game_map).events[@event_id]
    e.tb_response_wait = b if e
    event.restore_list_tb if restore
    map.destroy_event_any(@event_id) if destroy
  end
  #----------------------------------------------------------------------------
  # * Fade out event on death
  #----------------------------------------------------------------------------
  def fade_out_tb_era(rate, min, destroy = true, restore = true)
    event = (map=$game_map).events[@event_id]
    event.start_fading_tb(rate, min)
    Fiber.yield while event.fading_tb?
    # event.restore_list_tb if restore
  end
  #----------------------------------------------------------------------------
  # * Display move route highlights
  #----------------------------------------------------------------------------
  def show_hls(x,y)
    Era::AI.show_move_range_tb(x,y, Era::AI::SHOW, false)
  end
  #----------------------------------------------------------------------------
  # * Remove displayed highlights
  #----------------------------------------------------------------------------
  def remove_hls
    return unless (s=SceneManager.scene).is_a?(Scene_Map)
    spm = s.instance_eval('@spriteset')
    spm.remove_group(Era::AI::SHOW)
  end
  #----------------------------------------------------------------------------
  # * Move the tb cursor (the player)
  #----------------------------------------------------------------------------
  def mvtb_cursor(x,y)
    (p=$game_player).x = x; p.y = y
  end
  #----------------------------------------------------------------------------
  # * End Actions
  #----------------------------------------------------------------------------
  def end_acts_tb
    (event=$game_map.events[@event_id]).restore_list_tb
    event.acts_done_tb = true
  end
  #----------------------------------------------------------------------------
  # * Start Actions
  #----------------------------------------------------------------------------
  def start_acts_tb
  end
  #----------------------------------------------------------------------------
  # * Recalculate the target if current target is dead
  #----------------------------------------------------------------------------
  #def check_target_ok_tb
  #  m = $game_map
  #  this = m.events[@event_id]
  #  target = nil
  #  
  #  this.target_evs_tb.each do |e|
  #    if m.events[e.id]
  #      target = e; break
  #    end
  #  end
  #  
  #  if !target
  #    this.restore_list_tb
  #    this.acts_done_tb = true
  #    TactBattleManager.new_ai_target(@event_id)
  #  end
  #end
  #----------------------------------------------------------------------------
  # * Turn Towards the character at position x,y
  #----------------------------------------------------------------------------
  def turn_towards_tb(x,y)
    map = $game_map
    event = map.events[@event_id]
    target = map.events[map.tbu_id_xy(x,y)]
    event.turn_toward_character(target) if !target.nil?
  end
  #----------------------------------------------------------------------------
  # * TB Use Item/Skill helper
  #----------------------------------------------------------------------------
  def use_item_tb_era(x,y,id,type, dir = nil)
    item=$data_skills[id] if type == 1
    item=$data_items[id] if type == 0
    
    e = $game_map.events[@event_id]
    dir = e.dir_to_sym_era(dir) #if !dir
    xy = [nil,nil]
    
    xy = Era::AI.aoe_target(x, y, dir, item, @event_id) if item.tb_aoe
    dir = xy[2]
    
    Era::AI.show_act_hls(mx=e.x,my=e.y,dir,item, e.tb_unit.battler)
    # print "calling show_aoe_hls dir #{dir}\n"
    Era::AI.show_aoe_hls(mx=xy[0],my=xy[1],dir,item) if !xy[0].nil? && !xy[1].nil?
    
    mvtb_cursor(mx,my)
    wait(TactBattleManager::Defaults::Speed)
    Era::AI.use_item(x, y, item, @event_id, nil, xy[0], xy[1])
  end
  #----------------------------------------------------------------------------
  # * execute_dynamic_route
  #----------------------------------------------------------------------------
  def execute_dynamic_route(fx, fy)#, restore = true)
    event = $game_map.events[@event_id]
    x,y = event.x, event.y
    return if fx == x && fy == y
    path = event.tb_dj_path
    spec_edges = event.tb_unit.spec_edges
    temp = MoveUtils.find_move_route(event.x,event.y,fx,fy,event,path,spec_edges)
    $game_map.refresh if $game_map.need_refresh
    event.force_move_route(temp)
    event.temp_ghost # IN FINAL IMPLEMENTATION, DONT USE TEMP GHOSTS, ALIAS PASSABLE METHODS 
    event.give_spotlight
    Fiber.yield while event.move_route_forcing if temp.wait
  end # execute_dynamic_route
end # Game_Interpreter

#==============================================================================
# ** Game_Party
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class Game_Party
  def items_era; @items; end
  def arms_era; @armors; end
  def weps_era; @weapons; end
end # Game_Party

#==============================================================================
# ** Sprite_Character
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#       Flash the selected character.
#==============================================================================
class Sprite_Character < Sprite_Base
  #----------------------------------------------------------------------------
  # * Alias, Update
  #----------------------------------------------------------------------------
  alias spc_update_tb_era update
  def update
    spc_update_tb_era
    update_flash_soft
    update_tb
  end
  #----------------------------------------------------------------------------
  # * Update for tactical battle
  #----------------------------------------------------------------------------
  def update_tb
    return check_waitng_tb if !TactBattleManager::Defaults::ColorTeams
    if TactBattleManager.tact_battle?
      tones = [tone.gray, tone.green, tone.red, tone.blue]
      if (e=@character).is_a?(Game_Event) && (team=e.tb_unit.team) != @old_team
        t = TactBattleManager::TEAM_COLOR[team] 
        
        @character.save_tones_tb(:tb_start, tones)
        set_tone_tb(t) if !t.nil?
        @old_team = team
      end
    else
      
      # print "not tb  @character.saved_tones_tb(:tb_start) = #{@character.saved_tones_tb(:tb_start)}\n"
      reset_tone_tb(:tb_start) if @character.saved_tones_tb(:tb_start)
    end
    check_waitng_tb
  end
  #----------------------------------------------------------------------------
  # * Update Flash
  #----------------------------------------------------------------------------
  def update_flash_soft
    if !@character.started_tb_flash
      tones = @character.saved_tones_tb(:flash_orig)
      if tones
        tone.blue = tones[3] unless !tones[3]
        tone.red = tones[2] unless !tones[2]
        tone.green = tones[1] unless !tones[1]
        tone.gray = tones[0] unless !tones[0]
      end
    end
    
    if (@character.started_tb_flash && !@character.flash_soft_tb)
      @character.started_tb_flash = false 
    end
    
    return unless @character.flash_soft_tb
    
    if !@character.started_tb_flash
      tones = [tone.gray, tone.green, tone.red, tone.blue]
      @character.save_tones_tb(:flash_orig, tones)
      @character.started_tb_flash = true
    end
    
    @bc_tb ||= 0; @rc_tb ||= 0; @gc_tb ||= 0; @gyc_tb ||= 0
    mod = 1.5
    if tone.blue > 51; @bc_tb = -mod
    elsif tone.blue <= 0; @bc_tb = mod
    end
    
    if tone.gray > 51; @gyc_tb = -mod
    elsif tone.gray <= 0; @gyc_tb = mod
    end
    
    if tone.red > 51; @rc_tb = -mod
    elsif tone.red <= 0; @rc_tb = mod
    end
    
    if tone.green > 51; @gc_tb = -mod
    elsif tone.green <= 0; @gc_tb = mod
    end
    
    tone.gray += @gyc_tb
    tone.green += @gc_tb
    tone.red += @rc_tb
    tone.blue += @bc_tb
  end
  #----------------------------------------------------------------------------
  # * Set Tone
  #----------------------------------------------------------------------------
  def set_tone_tb(tone_vals)
    save_old_tones_tb
    tone.red = tone_vals[0]
    tone.green = tone_vals[1]
    tone.blue = tone_vals[2]
    tone.gray = tone_vals[3]
  end
  #----------------------------------------------------------------------------
  # * Save_old_tones_tb
  #----------------------------------------------------------------------------
  def save_old_tones_tb
    @saved_tones_tb = true
    @old_tone_red_tb = tone.red
    @old_tone_blue_tb = tone.blue
    @old_tone_green_tb = tone.green
    @old_tone_gray_tb = tone.gray
  end
  #----------------------------------------------------------------------------
  # * Wait Tone
  #----------------------------------------------------------------------------
  def wait_tone 
    tm = TactBattleManager::Defaults
    @set_wait_tb = true
    tone.gray = tm::WAIT_GRAY
    tone.red = tm::WAIT_RED
    tone.blue = tm::WAIT_BLUE
    tone.green = tm::WAIT_GREEN
  end
  #----------------------------------------------------------------------------
  # * Reset Tone
  #----------------------------------------------------------------------------
  def reset_tone_tb(sym = :orig)
    
    tones = @character.saved_tones_tb(sym)
    return if !tones
    tone.gray = tones[0]
    tone.green = tones[1]
    tone.red = tones[2]
    tone.blue = tones[3]
    @character.save_tones_tb(sym, nil)
  end
  #----------------------------------------------------------------------------
  # * Check if Waiting
  #----------------------------------------------------------------------------
  def check_waitng_tb
    if @character.is_a?(Game_Event)
      
      if @character.waiting_tb 
        if !@character.saved_tones_tb(:orig)
          tones = nil
          
          if @character.started_tb_flash
            tones = @character.saved_tones_tb(:flash_orig) 
          else 
            tones = [tone.gray, tone.green, tone.red, tone.blue]
          end
          
          print "tones for #{@character.event.name} #{tones.inspect}\n"
          @character.save_tones_tb(:orig, tones)
        end
        wait_tone
      else 
        reset_tone_tb
      end
      
    end
=begin    
    if @character.is_a?(Game_Event)
      if @character.waiting_tb && !@set_wait_tb
        print "waiting for #{@character.event.name}\n"
        save_old_tones_tb
        wait_tone 
      #elsif @set_wait_tb; reset_tone_tb; end
      else !@character.waiting_tb && @set_wait_tb
        reset_tone_tb
      end
    end
=end
  end # check_waitng_tb
end # Sprite_Character

#=============================================================================
# ** Tactical_Unit     
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#      Wrapped inside of an event. Organizes information pertaining to a unit 
#      on a tactical battle map. Acts like a Game_Party somewhat so inherits it.
#=============================================================================
class Tactical_Unit < Game_Party
  attr_accessor :move  # how far the unit can move
  attr_accessor :jump_length, :jumpables
  attr_reader   :valid_moves, :event_id, :sorted_passables, :sorted_jumpables
  TM = TactBattleManager
  #---------------------------------------------------------------------------
  # * Initialize
  #---------------------------------------------------------------------------
  def initialize
    super
    @tb_valid_moves = {}
    init_tb_actions
    init_tb_state
  end
  #---------------------------------------------------------------------------
  # * init_shared_acts
  #---------------------------------------------------------------------------
  def init_shared_acts
    return if !(b=battler)
    @shared_acts = Shared_ActsTB.new(self)
    b.shared_acts.each{|arr| @shared_acts.add_shared(arr) }
  end
  #---------------------------------------------------------------------------
  # * Maximum Possible number of actions
  #     params
  #       sym, the symbol of the action to check
  #---------------------------------------------------------------------------
  def max_possible_acts(sym)
    act_lmt = nil
    case sym
    when :move; act_lmt = move_action_lmt;
    when :skill; act_lmt = skill_action_lmt;
    when :atk; act_lmt = atk_action_lmt;
    when :item; act_lmt = item_action_lmt;
    end
    [act_lmt, all_action_lmt].max
  end
  #---------------------------------------------------------------------------
  # * Base movement range
  #---------------------------------------------------------------------------
  def move
    @move + move_equip_mod
  end
  #---------------------------------------------------------------------------
  # * Move Equip Modifier
  #---------------------------------------------------------------------------
  def move_equip_mod
    return 0 if battler.nil? || battler.is_a?(Game_Enemy)
    battler.equips.inject(0) do |sum,e| 
      mod = e.nil? ? 0 : (e.move_mod_tb ||= 0)
      sum += mod
    end
  end
  #---------------------------------------------------------------------------
  # * After Initialize, should be called after object initialization
  #---------------------------------------------------------------------------
  def after_init(id)
    @event_id = id
  end
  #---------------------------------------------------------------------------
  # * Set event_id
  #---------------------------------------------------------------------------
  def event_id=(id); @event_id = id; end
  #---------------------------------------------------------------------------
  # * Initialize Actions
  #     Maps symbols to how many times that action has been performed.
  #     :move => how far the unit has moved (not implemented yet).
  #---------------------------------------------------------------------------
  def init_tb_actions
    @tb_actions = { :move => 0, :item => 0, :atk => 0, :skill => 0, :all => 0,
      :targets => 0}
  end
  #---------------------------------------------------------------------------
  # * Maximum actions of any type that can be performed
  #---------------------------------------------------------------------------
  def all_action_lmt
    return 0 if (b=battler).nil?
    b.all_action_lmt + all_lmt_equip_mod
  end
  #---------------------------------------------------------------------------
  # * Maximum actions of any type that can be performed
  #---------------------------------------------------------------------------
  def all_lmt_equip_mod
    return 0 if battler.nil? || !battler.is_a?(Game_Actor)
    battler.equips.inject(0) do |sum,e| 
      mod = e.nil? ? 0 : (e.all_acts_mod ||= 0)
      sum += mod
    end
  end 
  #---------------------------------------------------------------------------
  # * Basic attack action limit
  #---------------------------------------------------------------------------
  def atk_action_lmt
    return 0 if (b=battler).nil?
    b.attack_action_lmt + atk_lmt_equip_mod
  end
  #---------------------------------------------------------------------------
  # * Pool Actions Modifier
  #---------------------------------------------------------------------------
  def pool_acts_mod
    return 0 if (b=battler).nil?
    b.pool_acts_mod + pool_acts_equip_mod
  end
  #---------------------------------------------------------------------------
  # * Modifier for pool actions by equipment
  #---------------------------------------------------------------------------
  def pool_acts_equip_mod
    return 0 if battler.nil? || !battler.is_a?(Game_Actor)
    battler.equips.inject(0) do |sum,e| 
      mod = e.nil? ? 0 : (e.pool_acts_mod ||= 0)
      sum += mod
    end
  end
  #---------------------------------------------------------------------------
  # * Attack action limit boosts given by equipment
  #---------------------------------------------------------------------------
  def atk_lmt_equip_mod
    return 0 if battler.nil? || !battler.is_a?(Game_Actor)
    battler.equips.inject(0) do |sum,e| 
      mod = e.nil? ? 0 : (e.batk_acts_mod ||= 0)
      sum += mod
    end
  end
  #---------------------------------------------------------------------------
  # * Move action limit
  #---------------------------------------------------------------------------
  def move_action_lmt
    return 0 if (b=battler).nil?
    b.move_action_lmt + move_lmt_equip_mod
  end
  #---------------------------------------------------------------------------
  # * Move action limit boosts given by equipment
  #---------------------------------------------------------------------------
  def move_lmt_equip_mod
    return 0 if battler.nil? || !battler.is_a?(Game_Actor)
    battler.equips.inject(0) do |sum,e| 
      mod = e.nil? ? 0 : (e.move_acts_mod ||= 0)
      sum += mod
    end
  end
  #---------------------------------------------------------------------------
  # * Item action limit
  #---------------------------------------------------------------------------
  def item_action_lmt
    return 0 if (b=battler).nil?
    b.item_action_lmt + item_lmt_equip_mod
  end
  #---------------------------------------------------------------------------
  # * Item action limit boosts given by equipment
  #---------------------------------------------------------------------------
  def item_lmt_equip_mod
    return 0 if battler.nil? || !battler.is_a?(Game_Actor)
    battler.equips.inject(0) do |sum,e| 
      mod = e.nil? ? 0 : (e.item_acts_mod ||= 0)
      sum += mod
    end
  end
  #---------------------------------------------------------------------------
  # * Skill action limit
  #---------------------------------------------------------------------------
  def skill_action_lmt
    return 0 if (b=battler).nil?
    b.skill_action_lmt + skill_lmt_equip_mod
  end
  #---------------------------------------------------------------------------
  # * Skill action limit boosts given by equipment, not implemented yet
  #---------------------------------------------------------------------------
  def skill_lmt_equip_mod
    return 0 if battler.nil? || !battler.is_a?(Game_Actor)
    battler.equips.inject(0) do |sum,e| 
      mod = e.nil? ? 0 : (e.skill_acts_mod ||= 0)
      sum += mod
    end
  end
  #---------------------------------------------------------------------------
  # * No. times total of items+skills+attacks can be used
  #---------------------------------------------------------------------------
  def target_tb_lmt
    return 0 if (b=battler).nil?
    b.target_tb_lmt + target_lmt_equip_mod
  end
  #---------------------------------------------------------------------------
  # * Mod to target action limits (atk + skill + item) based on equipment
  #---------------------------------------------------------------------------
  def target_lmt_equip_mod
    return 0 if battler.nil? || !battler.is_a?(Game_Actor)
    battler.equips.inject(0) do |sum,e| 
      mod = e.nil? ? 0 : (e.target_acts_mod ||= 0)
      sum += mod
    end
  end
  #---------------------------------------------------------------------------
  # * Initialize TB State
  #--------------------------------------------------------------------------- 
  def init_tb_state
    @tb_state = :active
  end
  #---------------------------------------------------------------------------
  # * initialize_battler
  #---------------------------------------------------------------------------
  def init_battler(name)
    @actor_id = DataManager.actor_index_by_name(name)
    @enemy_id = DataManager.enemy_index_by_name(name)
    
    set_unit_data
    set_unit_type
    
    set_base_stats unless is_neutral?# base jump, move, atk
    use_defaults_if_nil
    init_shared_acts
  end
  #---------------------------------------------------------------------------
  # * Set Unit Data
  #---------------------------------------------------------------------------
  def set_unit_data
    set_tb_neutral if @actor_id.nil? && @enemy_id.nil?
    set_data_actor if !@actor_id.nil? && !is_neutral?
    set_data_enemy if !@enemy_id.nil? && !is_neutral? && !is_actor?
  end
  
  def set_unit_type
   
  end
  #---------------------------------------------------------------------------
  # * Set Data Actor
  #---------------------------------------------------------------------------
  def set_data_actor
    @is_actor = true#@enemy_id = nil
    @battler_id = @actor_id
    $game_actors[@battler_id].tb_unit = self
  end
  #---------------------------------------------------------------------------
  # * Set Data Enemy
  #---------------------------------------------------------------------------
  def set_data_enemy
    @is_actor = false
    @battler_id = @enemy_id
    @enemy = Game_Enemy.new(0,@battler_id)
    @enemy.tb_unit = self
  end
  #----------------------------------------------------------------------------
  # * Unit Control Methods
  #----------------------------------------------------------------------------
  def is_neutral?; @tb_type == TactBattleManager::NEUTRAL; end
    
  # Change to check @tb_type == '@current_team_turn'
  def is_friend?(team = TactBattleManager::PLAYER); @tb_type == team; end
  def set_tb_neutral; @tb_type = TactBattleManager::NEUTRAL; end
  def team; @tb_type;end
  #----------------------------------------------------------------------------
  # * Set Control
  #----------------------------------------------------------------------------
  def set_control(team)
    @tb_type = team
  end
  #----------------------------------------------------------------------------
  # * Is Actor?
  #----------------------------------------------------------------------------
  def is_actor?; @is_actor; end
  #----------------------------------------------------------------------------
  # * Set Base Stats
  #----------------------------------------------------------------------------  
  def set_base_stats
    battler = nil
    is_actor? ? battler = $game_actors[@battler_id] : battler = @enemy
    @move = battler.base_move_range_tb
    @jump_length = battler.base_jump_range_tb
    @jumpables = battler.base_jumpables_tb
    @passables = battler.base_passables_tb
    
    @sorted_passables = @passables.keys.sort if @passables
    @sorted_jumpables = @jumpables.keys.sort if @jumpables
  end
  #----------------------------------------------------------------------------
  # * Use Defauls if Nil
  #----------------------------------------------------------------------------
  def use_defaults_if_nil
    @move = TactBattleManager::Defaults::Move if @move.nil?
    @jump_length = TactBattleManager::Defaults::Jump if @jump_length.nil?
    @passables = TactBattleManager::Defaults::Passables if @passables.nil?
    @jumpables = TactBattleManager::Defaults::Jumpables if @jumpables.nil?
  end
  #----------------------------------------------------------------------------
  # * Add Valid Move
  #----------------------------------------------------------------------------
  def add_valid_move(v); @valid_moves[v] = true; end
  #----------------------------------------------------------------------------
  # * overloaded.. kinda
  #----------------------------------------------------------------------------
  def tb_valid_move?(x,y); @valid_moves[Vertex.new(x,y)]; end
  #----------------------------------------------------------------------------
  # * empty_valid_moves
  #----------------------------------------------------------------------------
  def empty_valid_moves; @valid_moves = {}; end
  #----------------------------------------------------------------------------
  # * Get Actor
  #----------------------------------------------------------------------------
  def actor; $game_actors[@actor_id] unless @actor_id.nil?; end
  #----------------------------------------------------------------------------
  # * Set Friendly
  #----------------------------------------------------------------------------
  def set_friend
  end
  #----------------------------------------------------------------------------
  # * spec_edges
  #     @passables does not store 0, explicitly, it is assumed 0 is passable for
  #     all units.
  #----------------------------------------------------------------------------
  def spec_edges
    { :jump_length => @jump_length, :pass => @passables, :jump => @jumpables, :move => move}
  end
  #----------------------------------------------------------------------------
  # * spec_edges used as a key in the graphs cache, module Era::Ai
  #----------------------------------------------------------------------------
  def se_hash_key
    [@jump_length, @sorted_jumpables]
  end
  #----------------------------------------------------------------------------
  # * battler
  #----------------------------------------------------------------------------
  def battler
    @is_actor ? $game_actors[@battler_id] : @enemy
  end
  #----------------------------------------------------------------------------
  # * For now enemies will not be able to use items.
  #----------------------------------------------------------------------------
  def usable?(item)
    return false if item.nil?
    tb = battler
    return tb.usable?(item) # tb.is_a?(Game_Actor) ? <- : false
  end
  #----------------------------------------------------------------------------
  # * Use item method for tactical battles after target has been selected.
  #----------------------------------------------------------------------------
  def use_item(item)
    battler.use_item(item)
  end
  #----------------------------------------------------------------------------
  # * Used Action
  #----------------------------------------------------------------------------
  def used_action(sym, val)
    
    case sym
    when :move
      @tb_actions[:move] += val
    when :atk
      # @tb_actions[:targets] += val
      @tb_actions[:atk] += val
    when :skill
      # @tb_actions[:targets] += val
      @tb_actions[:skill] += val
    when :item
      # @tb_actions[:targets] += val
      @tb_actions[:item] += val
    end
    
    n_val = val
    if sym == :move
      n_val = val.to_f/spec_edges[:move]
      @tb_actions[:all] += n_val
    else; @tb_actions[:all] += val
    end
    
    TactBattleManager.mod_curr_shared_acts(n_val)
  end
  #---------------------------------------------------------------------------
  # * Can Move
  #---------------------------------------------------------------------------
  def can_move?
    tm = TactBattleManager
    if tm.use_shared_actions? # processing for sharing actions b/w all units
      ret = tm.shared_act_ok?
    else
      mv = @tb_actions[:move]
      ret = all_ok? || (mv.to_f/move < move_action_lmt && @shared_acts.ok?(:move))
    end
    ret && @tb_state != :wait
  end
  #----------------------------------------------------------------------------
  # * sum of all actions used so far
  #----------------------------------------------------------------------------
  def all
    @tb_actions[:all]
  end
  #----------------------------------------------------------------------------
  # * Getters atk, item, skill, move
  #----------------------------------------------------------------------------
  def atk_acts
    @tb_actions[:atk]
  end
  def item_acts
    @tb_actions[:item]
  end
  def skill_acts
   @tb_actions[:skill]
  end
  def move_acts
    @tb_actions[:move]
  end
  #----------------------------------------------------------------------------
  # * Ok to use any action? 
  #----------------------------------------------------------------------------
  def all_ok?
    tm = TactBattleManager
    all_sh_ok = tm.shared_act_ok? && @tb_state != :wait
    tbu_all_ok = @tb_actions[:all] < all_action_lmt && @tb_state != :wait
    tm.use_shared_actions? ? all_sh_ok : tbu_all_ok
  end
  #----------------------------------------------------------------------------
  # * Ok to use basic attack?
  #----------------------------------------------------------------------------
  def atk_ok?
    check_ok?(:atk) || all_ok?
  end
  #----------------------------------------------------------------------------
  # * Ok to use an item
  #----------------------------------------------------------------------------
  def item_ok?
    check_ok?(:item) || all_ok?
  end
  #----------------------------------------------------------------------------
  # * Ok to use a skill
  #----------------------------------------------------------------------------
  def skill_ok?
    check_ok?(:skill) || all_ok?
  end
  #----------------------------------------------------------------------------
  # * Ok checking helper
  #----------------------------------------------------------------------------
  def check_ok?(sym)
    tm = TactBattleManager
    lmt = @tb_actions[sym];
    ret = nil
    
    if tm.use_shared_actions?
      ret = tm.shared_act_ok?
    else
      case sym
      when :atk
        ret = (lmt < atk_action_lmt) && @shared_acts.ok?(:atk)
      when :skill
        ret = (lmt < skill_action_lmt) && @shared_acts.ok?(:skill)
      when :item
        ret = (lmt < item_action_lmt) && @shared_acts.ok?(:item)
      end
    end
    ret && @tb_state != :wait
  end
  #----------------------------------------------------------------------------
  # * Available actions
  #----------------------------------------------------------------------------
  def tb_actions; @tb_actions; end
  #----------------------------------------------------------------------------
  # * Tactical Battle specific states
  #     :wait => can't perform actions
  #     :guard => can't perform actions, reduced damage
  #     :rest => can't perform actions, healing hp
  #     :active => can perform actions
  #     Not implemented currently
  #----------------------------------------------------------------------------
  def tb_state; @tb_state; end
  #---------------------------------------------------------------------------
  # * set tb state
  #---------------------------------------------------------------------------
  def tb_state=(sym); @tb_state = sym; end
  #---------------------------------------------------------------------------
  # * Unit can't act
  #---------------------------------------------------------------------------
  def exhaust
    e = $game_map.events[@event_id]
    @tb_state = :wait
    e.waiting_tb = true if e
    @tb_actions[:all] = 2147483647
  end
end # Tactical_Unit
#==============================================================================
# ** Shared Actions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#    Data organization for actions that share limits.
#==============================================================================
class Shared_ActsTB
  TYPES = [:atk, :skill, :item, :move]
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(tbu, opts = {})
    @shared = {}
    @tbu = tbu
    TYPES.each{ |t| @shared[t] = [t] }
  end
  #--------------------------------------------------------------------------
  # * Maximum actions possible
  #--------------------------------------------------------------------------
  def max_acts_possible
    # tricky to calculate not going to bother atm
  end
  #--------------------------------------------------------------------------
  # * Check ok
  #--------------------------------------------------------------------------
  def ok?(sym)
    sibs = @shared[sym]
    sum = sibs.inject(0){ |m,type| m += curr(type) }
    max(sibs) > sum
  end
  #--------------------------------------------------------------------------
  # * Add list of shared actions list contains symbols :move, :atk, :item,
  #     :skill, etc.
  #--------------------------------------------------------------------------
  def add_shared(arr)
    arr.each{ |t| add_types(t, arr) }
  end
  #--------------------------------------------------------------------------
  # * Add types to shared types hash
  #--------------------------------------------------------------------------
  def add_types(type, arr)
    lst = @shared[type]
    arr.each{ |t| lst.push(t) if !lst.include?(t) }
  end
  #--------------------------------------------------------------------------
  # * Max lmt from types
  #--------------------------------------------------------------------------
  def max(types)
    max = 0
    types.each{ |t| v = [lmt(t), @tbu.all_action_lmt].max; max = v if v > max }
    max
  end
  #--------------------------------------------------------------------------
  # * Current actions made from symbol
  #--------------------------------------------------------------------------
  def curr(sym)
    return if !@tbu
    ret = nil
    case sym
    when :atk; ret = @tbu.atk_acts
    when :item; ret = @tbu.item_acts
    when :skill; ret = @tbu.skill_acts
    when :move; ret = @tbu.move_acts
    end
    ret
  end
  #--------------------------------------------------------------------------
  # * Symbol to Limit
  #--------------------------------------------------------------------------
  def lmt(sym)
    return if !@tbu
    ret = nil
    case sym
    when :move; ret = @tbu.move_action_lmt 
    when :atk; ret = @tbu.atk_action_lmt
    when :skill; ret = @tbu.skill_action_lmt
    when :item; ret = @tbu.item_action_lmt
    end
    ret
  end
  #--------------------------------------------------------------------------
  # * to string
  #--------------------------------------------------------------------------
  def to_s
    @shared.inspect
  end
end # Shared_ActsTB
#==============================================================================
# ** End_PosTB
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#   Data organization for respawning characters on the map at the end of a 
#     tactical battle.
#==============================================================================
class End_PosTB
  DEF = :def        # Default symbol
  #---------------------------------------------------------------------------
  # * Init
  #---------------------------------------------------------------------------
  def initialize(type = DEF)
    @type = type    # type of respawning
    @respawns = {}  # type => [x,y]
  end
  #---------------------------------------------------------------------------
  # * Add a spawn to the currently stored spawn locations
  #     param: type is the type of spawn that is being added.
  #            xy is an array of length 2 representing the x,y position to
  #            respawn at.
  #---------------------------------------------------------------------------
  def add_spawn(xy, type = DEF)
    @respawns[type] = xy
  end
  #---------------------------------------------------------------------------
  # * Get a stored position
  #---------------------------------------------------------------------------
  def pos(type = @type)
    @respawns[type] ||= []
  end
end # End_PosTB

($imported||={})["Ra - Graph"] = true
#==============================================================================
# ** Class representing a directed graph = G(V,E).
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class Graph
  #---------------------------------------------------------------------------
  # * Initialize
  #---------------------------------------------------------------------------
	def initialize(*args) # args[0] = source for subclasses
		@verticies = {}
	end
  #---------------------------------------------------------------------------
  # * Add Vertex
  #---------------------------------------------------------------------------
	def add_vertex(v); @verticies[v]=v; end
  #---------------------------------------------------------------------------
  # * Set Vertexes
  #---------------------------------------------------------------------------
	def set_verticies(v); @verticies = v; end
  #---------------------------------------------------------------------------
  # * Get all Vertexes
  #---------------------------------------------------------------------------
	def verticies; @verticies; end
  #---------------------------------------------------------------------------
  # * To String
  #---------------------------------------------------------------------------
  def to_s
    concat = ""
    @verticies.keys.each do |v| 
      concat+= "v: " + v.to_s + " edges: "
      v.edges.each do |edge|
        concat+= "  #{edge.vertex.to_s}, w=#{edge.weight}"   
      end
      concat += "\n"
    end
    concat
  end
  #---------------------------------------------------------------------------
  # * Condensed to String, only displayes connected portions of graph
  #---------------------------------------------------------------------------
  def condensed_to_s 
    concat = ""
    tmp = ""
    count = 0
    
    @verticies.keys.each do |v| 
      if v.edges.length > 0 # only display connected portions of graph
        
        v.edges.each do |edge|
          if edge.passable
            tmp += "  #{edge.vertex.to_s}, w=#{edge.weight}" 
            count+=1
          end
        end
        if count > 0
          concat += "v: " + v.to_s + " edges: "
          concat += tmp + "\n"
          count = 0
        end
        tmp = ""
      end
    end
    concat
  end
  #---------------------------------------------------------------------------
  # * Delete Edge
  #---------------------------------------------------------------------------
  def delete_edge(v1,v2)  
    @verticies[v1].delete_edge(v2)
    @verticies[v2].delete_edge(v1)
  end
  #---------------------------------------------------------------------------
  # * Add Edge
  #---------------------------------------------------------------------------
  def add_edge(v1,v2, opts = {}, dir1=-1, dir2=-1)
    opts[:direction] = dir1
    @verticies[v1].add_edge(Edge.new(v2,opts))
    opts[:direction] = dir2
    @verticies[v2].add_edge(Edge.new(v1,opts))
  end
end # Graph
#==============================================================================
# ** Vertex
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     Representation of a 2d vertex.
#==============================================================================
class Vertex
  attr_accessor :terrain_tag
  #---------------------------------------------------------------------------
  # * Initialize
  #---------------------------------------------------------------------------
	def initialize(x=0,y=0, t_tag = 0)
		@edges = [] # list of vertices this vertex is connected to
		@x = x
		@y = y
    @terrain_tag = t_tag
	end
  #---------------------------------------------------------------------------
  # * Add Edge
  #---------------------------------------------------------------------------
	def add_edge(e)
    if (d=e.dir) != -1
      e.passable = e.passable && $game_map.passable?(@x,@y,d==4 ? 6 : d== 6 ? 4 : d == 8 ? 2 : d== 2 ? 8 : -1)
    end
    @edges.push(e) 
    self 
  end
  #---------------------------------------------------------------------------
  # deletes the edge with vertex equal to param: v
  #---------------------------------------------------------------------------
  def delete_edge(v)
    count = 0
    @edges.each do |e|
      @edges.delete_at(count)if e.vertex.eql?(v)
      count+=1
    end
  end
  #---------------------------------------------------------------------------
  # * Getters/Setters/Utility
  #---------------------------------------------------------------------------
	def set(x,y); @x, @y = x,y;	self; end
	def eql?(v); self.class.equal?(v.class) &&  @x == v.x && @y == v.y; end
	def hash; ("#{@x} #{@y}").hash; end
	def x; @x; end
	def y; @y; end
	def edges; @edges; end
  def edges_loc; @edges_loc; end
  def to_s; "(#{x},#{y})"; end
  def -(v); Vertex.new(@x-v.x,@y-v.y); end
  def +(v); Vertex.new(@x-v.x,@y-v.y); end
  #---------------------------------------------------------------------------
  # * Print edges
  #---------------------------------------------------------------------------
  def p_edges
    concat = to_s + " -> \n"
    edges.each{|e| concat += "    -#{e.vertex.to_s}\n"}
  end
  #---------------------------------------------------------------------------
  # * Direction, the direction from this vertex to param: v
  #---------------------------------------------------------------------------
  def dir(v)
    if @x == v.x
      return 8 if v.y > @y # down
      return 2             # up
    elsif @y == v.y
      return 6 if v.x > @x # right
      return 4             # left
    end
  end
  #---------------------------------------------------------------------------
  # * are vertexes adjacent?
  #---------------------------------------------------------------------------
  def adjacent?(v)
    return true if eql?(v)
    if @y == v.y 
      return @x-1 == v.x || @x+1 == v.x
    elsif @x == v.x
      return @y-1 == v.y || @y+1 == v.y
    end
  end
end # Vertex
#==============================================================================
# ** Edge
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     Representation of an Edge of a graph.
#==============================================================================
class Edge
  attr_reader :jump               # if > 0 must jump to reach associated edge
  attr_reader :weight             # cost to get to this edge
  attr_accessor :passable           # directional passability from tile
  attr_reader :dir                # directioonal heading along this edge
  #---------------------------------------------------------------------------
  # * Initialize
  #---------------------------------------------------------------------------
  def initialize(v, opts = {})
    options = {
      :weight => 1,
      :jump => 0,
      :passable => true,
      :direction => -1
    }.merge(opts)
    
    @vertex = v
    @weight = options[:weight] + (@jump = options[:jump])
    @passable = options[:passable]
    @dir = options[:direction]
    if @dir != 1
      @passable = $game_map.passable?(v.x,v.y,@dir)
    end
  end
  #---------------------------------------------------------------------------
  # * Getters
  #---------------------------------------------------------------------------
  def vertex; @vertex; end
  def weight; @weight; end
  def to_s; @vertex.to_s; end
end # Edge
#==============================================================================
# ** Game_MapGraph
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   A graph representation of the map
#==============================================================================
class Game_MapGraph < Graph
  attr_accessor :source
  #---------------------------------------------------------------------------
  # * Initialize
  #---------------------------------------------------------------------------
  def initialize(*args)
    super
    len = args.length
    @source = args[0] unless len == 0 # the event that was clicked
    @last_access_id = 0
  end
  #---------------------------------------------------------------------------
  # * New Sub Graph
  #---------------------------------------------------------------------------
  def self.new_sub_graph(source, spec_edges, size)
    Game_MapGraph.new(source).create_sub_graph(spec_edges,size)
  end
  #---------------------------------------------------------------------------
  # * Adjacents - array: [above, left, right, below]
  #---------------------------------------------------------------------------
  def self.adjacents(x,y)
    [Vertex.new(x,y-1), Vertex.new(x-1,y), Vertex.new(x+1,y), Vertex.new(x,y+1)]
  end
  #---------------------------------------------------------------------------
  # * Expand Graph - add valid adjacent verticies
  #   params: vertex, source vertex for adjacents
  #           pass, hash of integers representing passable  tiles
  #---------------------------------------------------------------------------
  def expand_graph_adj(vertex, pass = nil)
    m = $game_map
    add_vertex(vertex)
    
    tp = vertex.x == 21 && vertex.y == 5
    
    t = Time.now
    vx,vy = vertex.x, vertex.y
    return if !MoveUtils.ev_passable?(vx,vy, @source)
    
    ([Vertex.new(vx-1,vy, m.terrain_tag(vx-1,vy)),Vertex.new(vx,vy-1, m.terrain_tag(vx,vy-1))]).each_with_index do |v,i|
      next if !@verticies[v]
      x,y = v.x,v.y
      dir = (i+1)*4
      ev_pass = MoveUtils.ev_passable?(x,y,@source)
      next if !ev_pass
      add_edge(vertex, v, {} , opp_dir(dir), dir)
    end
  end
  #---------------------------------------------------------------------------
  # * Opposite Direction
  #---------------------------------------------------------------------------
  def opp_dir(dir)
    if dir == 8; return 2
    elsif dir == 2; return 8
    elsif dir == 6; return 4
    elsif dir == 4; return 6
    end
  end
  #---------------------------------------------------------------------------
  # * Graph with jumpable edges and passability values on edges
  #   param: spec edges is a hash mapping:
  #     :jump => hash of jumpable terrain tags, int => boolean
  #     :jump_length => maximum length of a jump in the graph (unit len - 1)
  #     :pass => hash of passable terrain tags (don't forget 0), int => boolean
  #---------------------------------------------------------------------------
  def create_sub_graph(spec_edges, move_dist = nil)
    # declare locals
    time = Time.now
    m = $game_map
    map_width,map_height = m.width, m.height
    MoveUtils.init_ev_passables
    
    if !move_dist
      dist = spec_edges[:move] ||= TactBattleManager::Defaults::Move
    else
      dist = move_dist
    end
    
    x_low = x_high = y_low = y_high = nil
    if @source
      x_low, x_high = [@source.x-dist, 0].max, [@source.x+dist,map_width-1].min
      y_low, y_high = [@source.y-dist, 0].max, [@source.y+dist,map_height-1].min 
    else
      x_low, x_high = 0, [dist,map_width-1].min
      y_low, y_high = 0, [dist,map_height-1].min
    end
    
    @jump_time = 0
    @optim_cache = {}
    x_low.upto(x_high).each do |x|
      y_low.upto(y_high).each do |y|
        expand_graph_adj(v=Vertex.new(x,y, m.terrain_tag(x,y)), spec_edges[:pass])
        add_adjacent_jumpables(v.x,v.y,dist,spec_edges)if spec_edges[:jump_length]>0
      end
    end
    self
  end
  #---------------------------------------------------------------------------
  # * Create Graph of the Entire Map
  #---------------------------------------------------------------------------
  def create_full_graph(spec_edges)
    create_sub_graph(spec_edges, $game_map.width+$game_map.height)
  end
  #---------------------------------------------------------------------------
  # * Get Jump Edges, only "adjacent" jumps from param: source are added to the 
  #   graph, diagonal jumps are not considered.
  #   dist specifies the length of a side of the graph
  #---------------------------------------------------------------------------
  def add_adjacent_jumpables(x,y,dist,jump_tags)
    add_adj_jumps(x,y,2,-1,false,dist,jump_tags)
    add_adj_jumps(x,y,4,-1, true,dist,jump_tags)
    add_adj_jumps(x,y,6,1,true,dist,jump_tags)
    add_adj_jumps(x,y,8,1,false,dist,jump_tags)
  end
  #---------------------------------------------------------------------------
  # * Add adjacent jump edges along a row/column in a given direction from (x,y)
  #   current implementation allows verticies to be connected by a jump to
  #   verticies that are not in the graph!
  #---------------------------------------------------------------------------
  def add_adj_jumps(x,y,dir, step, horz, dist,jump_tags)
    jump_length = 0 # number of "tiles" the jump will leap over.
    map = $game_map
    passables = jump_tags[:pass]
    
    ox, oy = x, y
    orig_valid = MoveUtils.ev_passable?(ox,oy,@source) && 
      (map.passable?(ox,oy,dir) || passables[map.terrain_tag(ox,oy)])
    return if !orig_valid
    horz ? x+= step : y+=step # don't check start point, begin at an adjacent one

    while(jump_length < dist && map.valid?(x,y) && jump_tags[:jump][map.terrain_tag(x,y)] && !map.passable?(x,y,dir))
      jump_length+=1
      horz ? x+= step : y+=step
    end

    valid_jump = jump_length <= jump_tags[:jump_length] && jump_length > 0
    ev_pass = MoveUtils.ev_passable?(x,y,@source)
    map_valid = map.valid?(x,y)

    if  ev_pass && map_valid && valid_jump
        v = Vertex.new(x,y,map.terrain_tag(x,y))
        v2 = Vertex.new(ox,oy,map.terrain_tag(ox,oy))
        add_vertex(v) if !@verticies[v]
        add_edge(v,v2,{:jump=>jump_length}, opp_dir(dir), dir)
    end
  end
end # Game_MapGraph

#==============================================================================
# ** MoveUtils
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#       Methods for moving Character around on the map using Dijkstra's Alg.
#==============================================================================
module MoveUtils
  #----------------------------------------------------------------------------
  # * Check Event Passability
  #----------------------------------------------------------------------------
  def self.ev_passable?(x,y,v=nil)
    map = $game_map
    id = map.tbu_1st_xy(x,y)# should be checking if there is any event at the
                            # location that is not passable, not just if the 
                            # their is a tb_unit or not. Not fixing yet because
                            # it isn't causing a problem right now.
    stpass = !TactBattleManager.units[TactBattleManager.turn][:event][id].nil? # friendly unit at x,y
    ret = id == 0 || ((te=map.events[id]) && te.through) || stpass 
    return true if !ret && v != nil && x == v.x && y == v.y
    return ret
  end
  #----------------------------------------------------------------------------
  # * Start Breadth-first 
  #----------------------------------------------------------------------------
  def self.dj_start(g,source, goal, spec_edges = {})
    visited, distances, paths, already_queued = {}, {}, {}, {}
    
    #print "dj_start goal #{goal}\n"
    curr = g.verticies[source]
    queue = []
    
    g.verticies.keys.each{ |v|
      visited[v] = false
      distances[v] = 2<<30
    }
    
    queue.push(curr)
    already_queued[curr] = true
    distances[curr] = 0
    paths[curr] = curr
    
    while(!queue.empty?)
      run_breadth(g, visited, distances, paths, queue, already_queued, goal,
        spec_edges)
    end
    return [paths, distances]
  end
  #----------------------------------------------------------------------------
  # * Run Dijkstra
  #----------------------------------------------------------------------------
  def self.run_breadth(g, visited, distances, paths, queue, already_queued, 
      goal, spec_edges = {})
    curr = g.verticies[queue.delete_at(0)]
    visited[curr] = true
    #print "run_breadth paths = #{paths}\n"
    #print "curr.edges = #{curr.edges}\n"
    curr.edges.each do |e|
      next if !e.passable || spec_edges[:pass][e.vertex.terrain_tag]
      
        nd = e.weight+distances[curr]
        next if nd > spec_edges[:move] # optimization, only search up to edges 
                                       # which are within movement range
        if !already_queued[e.vertex] && !visited[e.vertex]
          queue.push(e.vertex) 
          already_queued[e.vertex] = true
        end
        if nd < distances[e.vertex]
          distances[e.vertex] = nd
          paths[e.vertex] = curr
          
          if e.vertex.eql?(goal) # minor optimization
            queue = []
            return 1 # Code for exit due to this very minor optimization
          end
        end # end distance check
    end
  end
  #----------------------------------------------------------------------------
  # * Do a breadth-first search without using a graph
  #----------------------------------------------------------------------------
  def self.bfs_no_graph_start(sx,sy, goal, spec_edges = {})
    visited, distances, paths, already_queued = {}, {}, {}, {}
    
    curr = [sx,sy]# g.verticies[source]
    queue = []
    
    queue.push(curr)              # param arr
    already_queued[curr] = true   # param arr  
    vert = Vertex.new(curr[0],curr[1]) # other code expects to operate on vertexes
    paths[vert] = vert            # param vert
    distances[vert] = 0           # param vert
    
    while(!queue.empty?)
      run_breadth_no_graph(visited, distances, paths, queue, already_queued, goal,
        spec_edges)
    end
    return [paths, distances]
  end
  #----------------------------------------------------------------------------
  # * bfs with no graph
  #----------------------------------------------------------------------------
  def self.run_breadth_no_graph(visited, distances, paths, queue, already_queued, 
      goal, spec_edges = {})
      
    curr = queue.delete_at(0) # queue now holds [x,y] locations
    visited[curr] = true
    
    vc = Vertex.new(curr[0],curr[1])
    
    get_edges(curr, spec_edges).each do |e|
        nd = e[2]+distances[vc]
        next if nd > spec_edges[:move] # optimization, only search up to edges 
                                       # which are within movement range
        v = [e[0],e[1]]
        ve = Vertex.new(e[0],e[1])
        
        if !already_queued[v] && !visited[v]
          queue.push(v) 
          already_queued[v] = true
        end
        
        if distances[ve].nil? || nd < distances[ve]
          distances[ve] = nd
          paths[ve] = vc
        end # end distance check
    end
  end
  #----------------------------------------------------------------------------
  # * Get Edges
  #----------------------------------------------------------------------------
  def self.get_edges(xy, spec_edges)
    # an edge is 2D array with 4 arrays of 3 elemens x,y, weight
    
    jl = spec_edges[:jump_length]
    x,y = xy[0],xy[1]
    r = next_passable(x,y, 6, 1, true, jl, spec_edges)# [xy[0]+1,xy[1], true]
    l = next_passable(x,y, 4, -1, true, jl, spec_edges)
    u = next_passable(x,y, 8, -1, false, jl, spec_edges)
    d = next_passable(x,y, 2, 1, false, jl, spec_edges)
    ret = []
    ret.push(r) unless r.nil?
    ret.push(l) unless l.nil?
    ret.push(u) unless u.nil?
    ret.push(d) unless d.nil?
    ret
  end

  def self.next_passable(x,y,dir, step, horz, dist,jump_tags)
    jump_length = 0 # number of "tiles" the jump will leap over.
    map = $game_map
    passables = jump_tags[:pass]
    
    ox, oy = x, y
    horz ? x+= step : y+=step # don't check start point, begin at an adjacent one
      
    while(jump_length < dist && map.valid?(x,y) && jump_tags[:jump][map.terrain_tag(x,y)] && !map.passable?(x,y,dir))
      jump_length+=1
      horz ? x+= step : y+=step
    end
    
    valid_jump = jump_length <= jump_tags[:jump_length]
    pass = passables[map.terrain_tag(x,y)]
    ev_pass = MoveUtils.ev_passable?(x,y,@source)
    map_valid = map.valid?(x,y)

    
    if  ev_pass && map_valid && valid_jump && !pass
        if dir == 2 
          opp_dir = 8
        elsif dir == 8
          opp_dir = 2
        elsif dir == 6
          opp_dir = 4
        else 
          opp_dir = 6
        end
        jump_length = 1 if jump_length <= 0
        
        return map.passable?(ox,oy,opp_dir) && map.passable?(x,y,opp_dir) ? [x,y,jump_length] : nil
      end
      nil
  end

  # 0 = end route, 1 = down, 2 = left, 3  = right, 4 = up
  COMMANDS = [RPG::MoveCommand.new(0,[]), RPG::MoveCommand.new(4,[]),
              RPG::MoveCommand.new(2,[]), RPG::MoveCommand.new(3,[]),
              RPG::MoveCommand.new(1,[])]
  #----------------------------------------------------------------------------
  # * Find Move Route
  #----------------------------------------------------------------------------
  def self.find_move_route(x,y,fx,fy,event,path=nil,spec_edges = {})
      if path
        return translate_to_dirs(path, Vertex.new(x,y), Vertex.new(fx,fy))
      else
        sps = MoveUtils.bfs_no_graph_start(x,y, Vertex.new(fx, fy),spec_edges)[0]
        
        if sps.eql?(:TIME_OUT)
          print "Timed out while calculating move route\n"
        else
          return translate_to_dirs(sps, t, Vertex.new(fx,fy))
        end
      end
  end
  #----------------------------------------------------------------------------
  # * Translate to Directions
  #----------------------------------------------------------------------------
  def self.translate_to_dirs(shortest_paths, start, goal)
    tt, commands = [],[]
    i = 1
    curr = goal
    tt.insert(0,curr)
    while (!curr.eql?(curr = shortest_paths[curr]))
      tt.insert(0,curr)
      i+=1
    end
    
    (0...i-1).each{ |pos|
      if((v1=tt[pos]) && (v2=tt[pos+1]))
        if !v2.adjacent?(v1) # if not adjacent it's necessary to jump to
          commands.push(RPG::MoveCommand.new(14,[v2.x-v1.x,v2.y-v1.y]))
          next
        end
        commands.push(COMMANDS[v1.dir(v2)/2])
      end
    }
    commands.push(COMMANDS[0])
    move_route = RPG::MoveRoute.new
    move_route.list = commands
    move_route.wait = true
    move_route.skippable = true
    move_route.repeat = false
    move_route
  end
  #----------------------------------------------------------------------------
  # * Init Ev Passables
  #----------------------------------------------------------------------------
  def self.init_ev_passables
    @ev_pass_cache = {}
  end
end # Move Utils

#==============================================================================
# * Unit_Range
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     This class is responsible for generating the data for where to show
#     highlights on the screen when a unit is using an action (moving, using a 
#     skill, etc.).
#==============================================================================
class Unit_Range
  attr_reader :path, :distances
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  def initialize
    @path = nil # need to calculate a path before calling execute_move_route
    @distances = nil
  end
  #----------------------------------------------------------------------------
  # * Calculate Range 
  #     Return an array of points in between params min and max (distances)
  #     inclusive which are passable
  #----------------------------------------------------------------------------
  def calc_range(sx, sy, min, max, event, move_dist = nil, graph= nil, goal = nil)
    return if !event
    
    #print "calc range sx #{sx} sy #{sy} min #{min} max #{max} move_dist #{move_dist} goal #{goal}\n"
    
    points = Unit_Range.get_possible_points(sx,sy,min,max)
    source = Vertex.new(sx,sy)
    
    #print "points = #{points}\n"
    #print "source = #{source}\n"
    
    spec_edges = event.tb_unit.spec_edges#TempMod::SpecEdges
    
    #print "spec edge = #{spec_edges}\n"
    spec_edges[:move] = move_dist unless move_dist.nil?
    
    if graph
      reachables = MoveUtils.dj_start(graph,source, goal, spec_edges)
    else
      reachables = MoveUtils.bfs_no_graph_start(source.x,source.y, 
        goal, spec_edges)
    end
    
    # print "reachables = #{reachables}\n"
    
    @path = reachables[0]
    @distances = reachables[1]
    valids = []
    points.each do |p|
      if reachables[0][p] && reachables[1][p] <= max
        valids.push(p)
      end
    end
    valids
  end
  #----------------------------------------------------------------------------
  # * Get Range
  #----------------------------------------------------------------------------
  def get_range(sx,sy,min,max, event)
    @path = event.tb_dj_path
    @distances = event.tb_dj_distances
    valids = []
    points = Unit_Range.get_possible_points(sx,sy,min,max)
    
    points.each do |p|
      valids.push(p) if @path[p] && @distances[p] <= max
    end
    valids
  end
  #----------------------------------------------------------------------------
  # * Basic Range Calculation, returns all the points at a distance from x,y
  #   inbetween the range min - max inclusive
  #----------------------------------------------------------------------------
  def self.get_possible_points(x,y,min,max,method_sym=:p_at_dist, opts = {})
    points = []#method(@create_methods[@method_symbol]).call
    min.upto(max).each{ |i| method(method_sym).call(points, i, x,y,opts) }
    points
  end
  #----------------------------------------------------------------------------
  # * Shorter method call/helper for get_possible_points(...)
  #----------------------------------------------------------------------------
  def self.points(x,y,min,max,method_sym=:p_at_dist, opts={})
    get_possible_points(x,y,min,max,method_sym,opts)
  end
  
  #^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^
  # * Action Range calculation methods:
  #   These methods return a "range" (an array) of points which represent where
  #   an event will be able to perform its action (i.e. the points an event can
  #   move to, perform a skill at, etc.)
  #   
  #   The methods will be called one time per distance, i.e. if a range is being
  #   calculated for points at a distance of 2 to 4, first 2 would be passed to
  #   the method and it would have to calculate all of the points inside its
  #   action range at a distance of 2 from the source. Next it would be called
  #   with 3 as the distance. It would then have to calculate all the valid
  #   points in its action range at a distance of 3... etc.
  #^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^
  
  #----------------------------------------------------------------------------
  # * Points At Distance
  #   Returns a circle of points that are exactly param: dist points away from
  #   param: x,y
  #   param: points is the array each x,y pair will be pushed into
  #----------------------------------------------------------------------------
  def self.p_at_dist(points, dist, x, y, opts = {})
    options = {:source => false}.merge(opts)
    points.push(Vertex.new(x,y)) if options[:source]
    max = dist+1
    (0..dist).each{ |i|
      points.push(Vertex.new( x+i, y-(max-i) ))
      points.push(Vertex.new( x-i, y+(max-i) ))
      points.push(Vertex.new( x+(max-i), y+i ))
      points.push(Vertex.new( x-(max-i), y-i ))
    }
    points
  end
  #----------------------------------------------------------------------------
  # * Returns the point in the direction of opts[:dir] at a distance of 
  #   param: dist from x,y
  #----------------------------------------------------------------------------
  def self.p_straight_line(points, dist, x, y, opts = {})
    options = {:dir => 2}.merge(opts)
    dir = options[:dir]
    mod = (dir == 6 || dir == 8) ? 1 : -1
    vert = (dir == 2 || dir == 8) ? true : false
    v = vert ? Vertex.new(x,y+(mod*dist)) : Vertex.new(x+(mod*dist),y)
    points.push(v)
  end
  #----------------------------------------------------------------------------
  # * Returns the points above, below, to the left, and to the right of x,y at
  #   a distance of param: dist from it.
  #----------------------------------------------------------------------------
  def self.p_cross(points, dist, x, y, opts = {})
    p_straight_line(points, dist, x, y, opts = {:dir => 2})
    p_straight_line(points, dist, x, y, opts = {:dir => 4})
    p_straight_line(points, dist, x, y, opts = {:dir => 6})
    p_straight_line(points, dist, x, y, opts = {:dir => 8})
  end  
end # Unit_Range

#==============================================================================
# ** Game Player
#==============================================================================
class Game_Player < Game_Character
  attr_accessor :x
  attr_accessor :y
  #----------------------------------------------------------------------------
  # * Passable
  #     Allows the cursor to pass through everything during a tactical battle
  #----------------------------------------------------------------------------
  alias ra_tbs_passable_mod_et passable?
  def passable?(x, y, d)
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    return true if TactBattleManager.tact_battle? && $game_map.valid?(x2,y2)
    ra_tbs_passable_mod_et(x, y, d)
  end
end # Game_Player
#==============================================================================
# * Window_UnitCommandTB
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Command window when selecting a unit on the map
#==============================================================================
class Window_UnitCommandTB < Window_Command
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_original_commands
    add_main_commands
  end
  #--------------------------------------------------------------------------
  # * Add Main Commands to List
  #--------------------------------------------------------------------------
  def add_main_commands
    tm = TactBattleManager
    add_command(tm::VocabTB::Status, :status, true)
    add_command(tm::VocabTB::Attack,  :attack,  can_attack?)
    add_command(tm::VocabTB::Skill,  :skill,  skill_ok_tb?)
    add_command(tm::VocabTB::Move,  :move,  unit_movable?)
    add_command(tm::VocabTB::Item,   :item,   item_ok_tb?)
    add_command(tm::VocabTB::Equip,  :equip,  equip_ok?)
    add_command(tm::VocabTB::Trade, :trade, true)
    add_command(tm::VocabTB::Turn, :turn, true)
    add_command("Wait", :wait, true)
  end
  #--------------------------------------------------------------------------
  # * For Adding Original Commands
  #--------------------------------------------------------------------------
  def add_original_commands; end
  #--------------------------------------------------------------------------
  # * Get Activation State of Main Commands
  #--------------------------------------------------------------------------
  def main_commands_enabled
    TactBattleManager.tact_battle?
  end
  #--------------------------------------------------------------------------
  # * Set the tb_unit for this window
  #--------------------------------------------------------------------------
  def set_tb_unit(tb_unit)
    @tb_unit = tb_unit
    refresh
  end
  #--------------------------------------------------------------------------
  # * Check if the selected unit can move
  #--------------------------------------------------------------------------
  def unit_movable?
    return false if @tb_unit.nil?
    @tb_unit.can_move?
  end
  #--------------------------------------------------------------------------
  # * Can Attack?
  #--------------------------------------------------------------------------
  def can_attack?
    return false if @tb_unit.nil?
    @tb_unit.atk_ok?
  end
  #--------------------------------------------------------------------------
  # * Skill Ok?
  #--------------------------------------------------------------------------
  def skill_ok_tb?
    return false if @tb_unit.nil?
    @tb_unit.skill_ok?
  end
  #--------------------------------------------------------------------------
  # * Item Ok?
  #--------------------------------------------------------------------------
  def item_ok_tb?
    return false if @tb_unit.nil?
    @tb_unit.item_ok?
  end
  #--------------------------------------------------------------------------
  # * Equip Ok?
  #--------------------------------------------------------------------------
  def equip_ok?; 
    return false if @tb_unit.nil?
    @tb_unit.battler.is_a?(Game_Actor)
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    return hide if !TactBattleManager.tact_battle?
    super
  end
end # Window_UnitCommandTB

#==============================================================================
# ** Window_UnitDirectionTB
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     Window for selecting unit direction.
#==============================================================================
class Window_UnitDirectionTB < Window_MenuCommand
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize
    Window_UnitDirectionTB::init_command_position
    super
    self.x = 160
    self.y = 180
  end
  #--------------------------------------------------------------------------
  # * Make Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_original_commands
    add_main_commands
  end
  #--------------------------------------------------------------------------
  # * Add Main Commands
  #--------------------------------------------------------------------------
  def add_main_commands
    add_command("Up",  :up,  true)
    add_command("Right",   :right,   true)
    add_command("Left",  :left,  true)
    add_command("Down", :down, true)
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    return hide if !TactBattleManager.tact_battle?
    super
  end
end # Window_UnitDirectionTB

#============================================================================
# ** Window_UnitHud
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     Displays information about the unit currently under the map curosr.
#============================================================================
class Window_UnitHud < Window_Base
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  def initialize(x,y,w,h)
    super(x,y,w,h)
    @delay = 0
    @inc = 1
  end
  #----------------------------------------------------------------------------
  # * Standard Padding
  #----------------------------------------------------------------------------
  def standard_padding
    return 6
  end
  #----------------------------------------------------------------------------
  # * Draw Contents
  #----------------------------------------------------------------------------
  def draw_contents(battler, is_left, event, pat_c = 1, inc = 1)
    return unless battler
    @battler = battler
    @event = event
    @is_left = is_left
    @pat_c = pat_c
    @inc = inc
    
    bar_w = self.width*0.6
    bar_x = self.width/5 + 20
    bar_y = self.height/7
    contents.font.size = 19
    
    max = @battler.mhp
    cur = @battler.hp
    
    draw_bar_stat(0, bar_x, bar_y, bar_w, cur, max, hp_gauge_color1,
      hp_gauge_color2, "HP", [cur, max].max > 9999 ? 50 : 45)
      
    max = @battler.mmp
    cur = @battler.mp
    
    draw_bar_stat(1, bar_x, bar_y, bar_w, cur, max, mp_gauge_color1,
      mp_gauge_color2, "MP", [cur, max].max > 9999 ? 50 : 45)
      
    draw_param_stat(2, bar_x, bar_y, "MV", @event.tb_unit.spec_edges[:move])
    draw_event_sprite(0,0,true)    
    draw_actor_icons(@battler, bar_x, 0)
  end
  #----------------------------------------------------------------------------
  # * Draw Bar Stat
  #----------------------------------------------------------------------------
  def draw_bar_stat(row, bar_x, bar_y, bar_w, cur, max, c1, c2, text, tw = 45, lh = 20)
    bar_y = bar_y + (row * self.height/5) + 5
    #bar_x -= 17
    val_x = bar_w/4 + bar_x
    draw_gauge(bar_x, bar_y, bar_w, cur.to_f/(max==0 ? 1 : max), c1, c2)
    draw_text(val_x, bar_y + 5, tw, lh, cur.to_s + "/")
    draw_text(val_x + tw, bar_y + 5, tw, lh, max.to_s)
    draw_text(bar_x - 17, bar_y + 5,tw,lh,text)
    
  end
  #----------------------------------------------------------------------------
  # * Draw Parameter Stat
  #----------------------------------------------------------------------------
  def draw_param_stat(row, base_x, base_y, text, stat, tw = 30, lh = 20)
     base_y = base_y + (row * self.height/5) + 9
     base_x -= 17
     draw_text(base_x, base_y,tw,lh,text)
     draw_text(base_x + tw, base_y, tw, lh, stat)
  end
  #----------------------------------------------------------------------------
  # * Draw Event Sprite
  #----------------------------------------------------------------------------
  def draw_event_sprite(x,y,adjust = false)
    BitmapUtils.draw_character_bitmap(contents, x, y, @event.character_name, 
        2, @event.character_index, @pat_c, 255, adjust)
  end
  #----------------------------------------------------------------------------
  # * Update
  #----------------------------------------------------------------------------
  def update
    return hide if !TactBattleManager.tact_battle?
    super
    return unless @battler
    if @delay == 10
      @delay = 0
      contents.clear
      draw_contents(@battler, @is_left, @event, @pat_c, @inc)
      
      if @pat_c == 2
        @inc = -1
      elsif @pat_c == 0
        @inc = 1
      end
      @pat_c += @inc
    end
    @delay+=1
  end
end # Window_UnitHud

#==============================================================================
# ** Window_ShowRange 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#      Window displayed when cursor hovers over skill, displays the range 
#      pattern for that skill.
#==============================================================================
class Window_ShowRange < Window_Base
  attr_accessor :grid_square_size
  
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  def initialize(x,y,w,h)
    super(x,y,w,h)
    
    # determines the size of one square in the grid. The grid is drawn based on
    # this value and the size of the window's contents
    @grid_square_size = 9
  end
  def set_scene(scene)
    @scene = scene
  end
  #----------------------------------------------------------------------------
  # * Set Skill Window
  #----------------------------------------------------------------------------
  def give_skill_window(s_win)
    @skill_window = s_win
  end
  #----------------------------------------------------------------------------
  # * Update
  #----------------------------------------------------------------------------
  def update
    super
    return if (item = @skill_window.item).nil?
    return if @item == item
    
    contents.clear
    
    @item = item
    draw_grid
    color_valid_positions
  end
  #----------------------------------------------------------------------------
  # * Draws a grid as specified by @grid_square_size 
  #----------------------------------------------------------------------------
  def draw_grid
    i,j = 0,0
    side_length = ((contents.width-@grid_square_size)/@grid_square_size) * @grid_square_size + 1
    while i < side_length
      contents.fill_rect(i,0,1,side_length, Color.new(0,0,0))
      i+=@grid_square_size
    end
    
    while j < side_length
      contents.fill_rect(0,j,side_length,1, Color.new(0,0,0))
      j+=@grid_square_size
    end
  end
  #----------------------------------------------------------------------------
  # * Color grid according to the attack range of the skill
  #----------------------------------------------------------------------------
  def color_valid_positions
    return if @item.nil?
    
    center_color = Color.new(83,142,250)
    outer_color =  Color.new(250,40,100)
    
    cx = cy = (contents.width-@grid_square_size)/@grid_square_size/2 * @grid_square_size + 1
    sq = @grid_square_size-1

    points = !(t = @item.tbs_spec_range).nil? ? t[$game_temp.tb_event.dir_to_sym_era] : simple_range
    
    return if points.nil?
    
    points.each do |v|
      offset_x, offset_y = v.x * @grid_square_size, v.y * @grid_square_size
      sz = grid_side
      px,py = cx + offset_x + sq, cy + offset_y + sq
      contents.fill_rect(px-sq,py-sq,sq,sq, outer_color) if px < sz && py < sz
    end
    contents.fill_rect(cx, cy,sq,sq, center_color) # center
  end
  #----------------------------------------------------------------------------
  # * grid_side
  #----------------------------------------------------------------------------
  def grid_side
    ((contents.width-@grid_square_size)/@grid_square_size)*@grid_square_size + 1
  end
  #----------------------------------------------------------------------------
  # * Simple Range
  #----------------------------------------------------------------------------
  def simple_range
    return [] if @item.nil?
    return @item.tbs_simple_range if !(actor=@scene.tb_battler).is_a?(Game_Actor)
    m,n = @item.tb_range_max-1, @item.tb_range_min-1
    Unit_Range.points(0,0,n+actor.eqp_r_min(@item), m+actor.eqp_r_max(@item))
  end
end # Window_ShowRange

#==============================================================================
# ** Window_SkillListTB
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     Used to display skills during a tb.
#==============================================================================
class Window_SkillListTB < Window_SkillList
  def col_max; return 1; end
end # Window_SkillListTB

#==============================================================================
# ** Window_UnitItemCategory
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     Used to display item categories for unit items.
#==============================================================================
class Window_UnitItemCategory < Window_ItemCategory
  #--------------------------------------------------------------------------
  # * Column Max
  #--------------------------------------------------------------------------
  def col_max
    return 4
  end
  #--------------------------------------------------------------------------
  # * Window Width
  #--------------------------------------------------------------------------
  def window_width
    @arg_width.nil? ? 190 : @arg_width
  end
  #--------------------------------------------------------------------------
  # * Set Width
  #--------------------------------------------------------------------------
  def set_width(w)
    @arg_width = w
  end
  #--------------------------------------------------------------------------
  # * Item Width
  #--------------------------------------------------------------------------
  def item_width
    38
  end
  #--------------------------------------------------------------------------
  # * Spacing
  #--------------------------------------------------------------------------
  def spacing
    3
  end
  #--------------------------------------------------------------------------
  # * Getter
  #--------------------------------------------------------------------------
  def get_contents; contents; end
end # Window_UnitItemCategory

#==============================================================================
# ** Window_UICsub
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class Window_UICsub < Window_UnitItemCategory
  def window_width; 300; end
  def item_width; 65; end
end # Window_UICsub

#==============================================================================
# ** Window_UnitItemListTB
#==============================================================================
class Window_UnitItemListTB < Window_ItemList
  attr_accessor :tb_unit
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(*args)
    super(*args)
  end
  #--------------------------------------------------------------------------
  # * Enable All Items Selectable
  #--------------------------------------------------------------------------
  def enable_all(b = true)
    @enable_all = b
  end
  #--------------------------------------------------------------------------
  # * set_tb_unit
  #--------------------------------------------------------------------------
  def set_tb_unit(tactical_unit)
    @tb_unit = tactical_unit
  end
  #--------------------------------------------------------------------------
  # * Make Item List
  #--------------------------------------------------------------------------
  def make_item_list
    return if @tb_unit.nil?
    return @data = [] unless !@tb_unit.nil?
    @data= @tb_unit.all_items.select {|item| include?(item) }
  end
  #--------------------------------------------------------------------------
  # * enable?
  #--------------------------------------------------------------------------
  def enable?(item)
    return false if @tb_unit.nil?
    @tb_unit.usable?(item) || @enable_all
  end
  #--------------------------------------------------------------------------
  # * Column Max
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # * Draw Item Number
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
    return if @tb_unit.nil?
    rect.x += 24 # hardcoded icon width
    draw_text(rect, "x#{@tb_unit.item_number(item)}")
  end
  #--------------------------------------------------------------------------
  # * Draw_Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_icon(item.icon_index, rect.x, rect.y, enable?(item))
      draw_item_number(rect, item)
    end
  end
end # Window_UnitItemListTB

class Window_UILsub < Window_UnitItemListTB; def enable?(item); true; end; end

#============================================================================
# ** Window_TbHelp
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     Used to display item descriptions during Scene_TbTrade
#============================================================================
class Window_TbHelp < Window_Help
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(line_number = 2)
    super(2)
    self.windowskin = Bitmap.new(width,height)
    refresh
  end
  #----------------------------------------------------------------------------
  # * Refresh
  #----------------------------------------------------------------------------
  def refresh
    contents.clear
    contents.font.size = 22
    draw_background(Rect.new(0,0,width,height))
    draw_text(0, 0, width, line_height, @text)
  end
  #----------------------------------------------------------------------------
  # * Draw Background
  #----------------------------------------------------------------------------
  def draw_background(rect)
    temp_rect = rect.clone
    temp_rect.width /= 2
    contents.gradient_fill_rect(temp_rect, back_color2, back_color1)
    temp_rect.x = temp_rect.width
    contents.gradient_fill_rect(temp_rect, back_color1, back_color2)
  end
  #--------------------------------------------------------------------------
  # * Get Background Color 1
  #--------------------------------------------------------------------------
  def back_color1
    Color.new(0, 0, 0, 192)
  end
  #--------------------------------------------------------------------------
  # * Get Background Color 2
  #--------------------------------------------------------------------------
  def back_color2
    Color.new(0, 0, 0, 0)
  end
end # Window_TbHelp

#==============================================================================
# ** Window_TbTrading
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#       Used as a trade window.
#==============================================================================
class Window_TbTrading < Window_UnitItemListTB
  attr_reader :prox_party
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(*args)
    super(*args)
    @prox_party = Game_Party.new      # to have access to item gaining, etc.
  end
  #--------------------------------------------------------------------------
  # * Make Item List
  #--------------------------------------------------------------------------
  def make_item_list
    @data = @prox_party.items + @prox_party.weapons + @prox_party.armors
  end
  #--------------------------------------------------------------------------
  # * Add Item
  #--------------------------------------------------------------------------
  def add_item(item)
    @prox_party.gain_item(item, 1)
  end
  #--------------------------------------------------------------------------
  # * Col Max
  #--------------------------------------------------------------------------
  def col_max
    return 4
  end
  #--------------------------------------------------------------------------
  # * Enable
  #--------------------------------------------------------------------------
  def enable?(*)
    return true
  end
  #--------------------------------------------------------------------------
  # * Spacing
  #--------------------------------------------------------------------------
  def spacing
    return 10
  end
  #--------------------------------------------------------------------------
  # * Draw Item Number
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
    rect.x += 24 # hardcoded icon width
    (hold = contents.font.size)
    contents.font.size = 14
    draw_text(rect, "x#{@prox_party.item_number(item)}")
    contents.font.size = hold
  end
  #--------------------------------------------------------------------------
  # * Items
  #--------------------------------------------------------------------------
  def items
    @data
  end
  #--------------------------------------------------------------------------
  # * Clear Data
  #--------------------------------------------------------------------------
  def clear_data
    @data = []
    @prox_party = Game_Party.new
    contents.clear
  end
  #--------------------------------------------------------------------------
  # * Standard Padding
  #--------------------------------------------------------------------------
  def standard_padding
    return 3.5
  end
  #--------------------------------------------------------------------------
  # * Item Number
  #--------------------------------------------------------------------------
  def item_number(item)
    @prox_party.item_number(item)
  end
end # Window_TbTrading

#=============================================================================
# ** Window_TbTradeCom
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#       Options available when trading.
#=============================================================================
class Window_TbTradeCom < Window_HorzCommand
  #--------------------------------------------------------------------------
  # * Commands
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Unit1", :unit1)
    add_command("Unit2", :unit2)
    add_command("Accept", :accept)
    add_command("Reset", :reset)
  end
  #--------------------------------------------------------------------------
  # * Window Width
  #--------------------------------------------------------------------------
  def window_width
    230
  end
end # Window_TbTradeCom

#=============================================================================
# ** Window_TbUnitProduction
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     This is the window which displays producable units.
#============================================================================= 
class Window_TbUnitProduction < Window_Command
  FONT_SIZE = 18
  attr_reader :syms
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(*o)
    @data = []
    super(*o)
  end
  #--------------------------------------------------------------------------
  # * Make Command List
  #--------------------------------------------------------------------------
  def make_command_list
    p = $game_player
    
    @data.each do |name| 
      
      # print "make command list Era::TBUnit.placement_ok?(p.x,"
      # print "p.y,name) #{Era::TBUnit.placement_ok?(p.x, p.y,name)}\n"
    
      
      add_command(name, :put, can_afford?(name) && Era::TBUnit.placement_ok?(p.x,
        p.y,name)) 
    end
  end
  #--------------------------------------------------------------------------
  # * Set Production
  #     An array which should correspond to one of the values of 
  #     Era::TBUnit::Contructable. Or it will be an internally made array
  #     consisting of the names of the party members (when placing the party
  #     on the map).
  #--------------------------------------------------------------------------
  def set_production(syms)
    @syms = syms
    @syms.each do |sym|
      list = sym.eql?(Era::TBUnit::GameParty) ? make_party_data : Era::TBUnit[sym]
      
      if list.nil? 
        reminder(sym)
        next
      end
      
      @data = @data + list
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # * Reminder
  #--------------------------------------------------------------------------
  def reminder(sym)
    msgbox("No data set for #{sym.to_s}")
  end
  #--------------------------------------------------------------------------
  # * Party can pay the cost for this unit?
  #--------------------------------------------------------------------------
  def can_afford?(name)
    Era::TBUnit.makable?(name)
  end
  #--------------------------------------------------------------------------
  # * Places a unit on the map
  #--------------------------------------------------------------------------
  def produce
    return_scene
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    super
    self.height = window_height/2 + line_height
  end
  #--------------------------------------------------------------------------
  # * Name of the Currently selected unit
  #--------------------------------------------------------------------------
  def unit_name
    @data[@index]
  end
  #--------------------------------------------------------------------------
  # * Make Party Data
  #--------------------------------------------------------------------------
  def make_party_data; pty = $game_party; pty.members.collect{|a|a.name}; end
  #--------------------------------------------------------------------------
  # * Column Max
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    contents.font.size = FONT_SIZE
    change_color(normal_color, command_enabled?(index))
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
end # Window_TbUnitProduction

#==============================================================================
# ** Window_PlacementOpts
#==============================================================================
class Window_PlacementOpts < Window_Command
  #--------------------------------------------------------------------------
  # * Make Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Units", :select)
    add_command("Items", :items)
    add_command("Done", :confirm)
    add_command("Cancel", :cancel)
  end
end # Window_PlacementOpts

#==============================================================================
# ** Window_TBMainMenu
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     The menu brought up when pressing 'X' during a tactical battle when the 
#     cursor is not over a unit.
#==============================================================================
class Window_TBMainMenu < Window_Command
  #--------------------------------------------------------------------------
  # * Make Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("End Turn", :end_turn)
    add_command("Save", :save)
    add_command("Cancel", :cancel)
  end
end # Window_TBMainMenu

#==============================================================================
# ** Window_BattlerSkills
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Used to select unit skills during a tactical battle
#==============================================================================
class Window_BattlerSkills < Window_Selectable
  @@last_index = 0
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(x,y,w,h)
    super
    @data = []
    @stypes= {}
  end
  #--------------------------------------------------------------------------
  # * group by stype_id
  #--------------------------------------------------------------------------
  def group_by_stype_id
    return if @battler.nil?
    battler.skills.each{ |s| @stypes[$data_skills[s.id].stype_id] = s}
  end
  #--------------------------------------------------------------------------
  # * Battler
  #--------------------------------------------------------------------------
  def battler; @battler; end
  #--------------------------------------------------------------------------
  # * Battler
  #--------------------------------------------------------------------------
  def battler=(bt)
    @battler=bt
    group_by_stype_id
    refresh
  end
  #--------------------------------------------------------------------------
  # * Skill types
  #--------------------------------------------------------------------------
  def stypes; @stypes; end
  #--------------------------------------------------------------------------
  # * Skill Type Window
  #--------------------------------------------------------------------------
  def skill_type_window=(w); @skill_type_win = w; end
  #--------------------------------------------------------------------------
  # * Skill Type
  #--------------------------------------------------------------------------
  def skill_type
    return unless @skill_type_win
    @skill_type_win.current_ext
  end
  #--------------------------------------------------------------------------
  # * Should Include?
  #--------------------------------------------------------------------------
  def include?(skill)
    skill && skill_type == skill.stype_id && skill.tb_ok?
  end
  #--------------------------------------------------------------------------
  # * Make Skill List
  #--------------------------------------------------------------------------
  def make_skill_list
    @data = @battler ? @battler.skills.select{|s|include?(s)} : []
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    make_skill_list
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    if skill = @data[index]
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(skill, rect.x, rect.y, enable?(skill))
      draw_skill_cost(rect, skill)
    end
  end
  #--------------------------------------------------------------------------
  # * activate
  #--------------------------------------------------------------------------
  def activate
    super
    select(@@last_index)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Alias, process_cursor_move
  #--------------------------------------------------------------------------
  alias process_cr_ve_era_9983429401 process_cursor_move
  def process_cursor_move
    last_index = @index
    super
    @@last_index = [last_index,0].max # store last index if super doesn't return
  end
  #--------------------------------------------------------------------------
  # * Enable
  #--------------------------------------------------------------------------
  def enable?(skill); @battler && @battler.usable?(skill); end
  #--------------------------------------------------------------------------
  # * Item max
  #--------------------------------------------------------------------------
  def item_max; @data ? @data.size : 0; end
  #--------------------------------------------------------------------------
  # * Get item
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # * Draw Skill Use Cost
  #--------------------------------------------------------------------------
  def draw_skill_cost(rect, skill)
    if @battler.skill_tp_cost(skill) > 0
      change_color(tp_cost_color, enable?(skill))
      draw_text(rect, @battler.skill_tp_cost(skill), 2)
    elsif @battler.skill_mp_cost(skill) > 0
      change_color(mp_cost_color, enable?(skill))
      draw_text(rect, @battler.skill_mp_cost(skill), 2)
    end
  end
end # Window_BattlerSkills

#==============================================================================
# ** Window_SkillTypes
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#    Skill types during a tactical battle.
#==============================================================================
class Window_SkillTypes < Window_Command
  #--------------------------------------------------------------------------
  # * Make Command List
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @battler
    if @battler.is_a?(Game_Actor)
      @battler.added_skill_types.sort.each do |stype_id|
        name = $data_system.skill_types[stype_id]
        add_command(name, :skill, true, stype_id)
      end
    else
      @skill_win.stypes.keys.each do |stype_id|
        name = $data_system.skill_types[stype_id]
        add_command(name, :skill, true, stype_id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * skill_window=
  #--------------------------------------------------------------------------
  def skill_window=(win)
    @skill_win = win
    @battler = win.battler
    refresh
  end
  #--------------------------------------------------------------------------
  # * skill_window
  #--------------------------------------------------------------------------
  def skill_window
    @skill_win
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    super
    self.height = window_height
  end
end # Window_SkillTypes

#==============================================================================
# Used to show the current turn during a tb
#==============================================================================
class Window_ShowTurn < Window_MapName
  def initialize(*args)
    super(*args)
    # self.openness = 255
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_background(contents.rect)
    draw_text(contents.rect, TactBattleManager.turn_to_s, 1)
  end
  #def openness_is
  #  self.openness
  #end
  #def openness=(v)
  #  self.openness = v
  #end
  def contents_opacity_is
    self.contents_opacity
  end
end # Window_ShowTurn

#==============================================================================
# ** Window_TBProductionCost
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#    Used to show the cost of producing a unit
#==============================================================================
class Window_TBProductionCost < Window_Base
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(*a)
    super(*a)
    @name = ""
  end
  #--------------------------------------------------------------------------
  # * Set Production
  #--------------------------------------------------------------------------
  def set_production(win_tb_unit_production)
    @production_window = win_tb_unit_production
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    return if name.nil?
    contents.clear
    @data = Era::TBUnit::Units[name][:cost]
    @name = name
    draw_gold_cost
    draw_item_costs
    draw_wep_costs
    draw_arm_costs
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    refresh if !@name.eql?(name)
  end
  #--------------------------------------------------------------------------
  # * Name
  #--------------------------------------------------------------------------
  def name
    return nil if @production_window.nil?
    @production_window.unit_name
  end
  #--------------------------------------------------------------------------
  # * Get Party Gold
  #--------------------------------------------------------------------------
  def cost; @data[:currency]; end
  #--------------------------------------------------------------------------
  # Get Currency Unit
  #--------------------------------------------------------------------------
  def currency_unit; Vocab::currency_unit; end
  #--------------------------------------------------------------------------
  # * Item Column
  #--------------------------------------------------------------------------
  def item_col; 0; end
  #--------------------------------------------------------------------------
  # * Wep Column
  #--------------------------------------------------------------------------
  def wep_col; width/3 - 2*standard_padding; end
  #--------------------------------------------------------------------------
  # * Armor Column
  #--------------------------------------------------------------------------
  def arm_col; width*2/3- 2*standard_padding;end
  #--------------------------------------------------------------------------
  # * Body
  #--------------------------------------------------------------------------
  def body; height/5; end
  #--------------------------------------------------------------------------
  # * Standard Padding
  #--------------------------------------------------------------------------
  def standard_padding; 4; end
  #--------------------------------------------------------------------------
  # * Generic Draw Costs
  #--------------------------------------------------------------------------
  def generic_draw_costs(items, db_array, x)
    etb = Era::TBUnit
    px = (p=$game_player).x; py = p.y
    wid = 24 # hard coded item icon side length
    y = body
    items.keys.each do |id|
      icon_index = db_array[id].icon_index
      enable = etb.makable?(@name) && etb.placement_ok?(px,py,@name)
      draw_icon(icon_index, x, y, enable)
      draw_text(x+wid,y,width/3,line_height,"x#{items[id]}")
      y+=wid 
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item Costs
  #--------------------------------------------------------------------------
  def draw_item_costs
    return if (items = @data[:item]).nil?
    generic_draw_costs(items, $data_items, item_col)
  end
  #--------------------------------------------------------------------------
  # * Draw Wep Costs
  #--------------------------------------------------------------------------
  def draw_wep_costs
    return if (weps = @data[:weapon]).nil?
    generic_draw_costs(weps, $data_weapons, wep_col)
  end
  #--------------------------------------------------------------------------
  # * Draw Arm Costs
  #--------------------------------------------------------------------------
  def draw_arm_costs
    return if (arms = @data[:armor]).nil?
    generic_draw_costs(arms, $data_armors, arm_col)
  end
  #--------------------------------------------------------------------------
  # * Draw Gold Cost
  #--------------------------------------------------------------------------
  def draw_gold_cost
    draw_text(4,0,contents.width-8,line_height,"Cost: ")
    draw_currency_value(cost, currency_unit, 4, 0, contents.width - 8)
  end
end # Window_TBProductionCost

#==============================================================================
# ** Window_BasicTextTB
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#    Extra organization for easily drawing text
#==============================================================================
class Window_BasicTextTB < Window_Base
  #--------------------------------------------------------------------------
  # * Setter Text
  #--------------------------------------------------------------------------
  def text=(str)
    contents.clear
    draw_text(0,0,width,line_height,str)
  end
  #--------------------------------------------------------------------------
  # * standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    13
  end
  #--------------------------------------------------------------------------
  # * no_skin
  #--------------------------------------------------------------------------
  def no_skin
    self.windowskin = Bitmap.new(contents.width,contents.height)
  end
  #--------------------------------------------------------------------------
  # * lineup_text
  #--------------------------------------------------------------------------
  def lineup_text(txt_hsh, lh)
    y = -lh
    txt_hsh.keys.sort.each{ |key| draw_text(0,y += lh, width, lh, txt_hsh[key])}
  end
  #--------------------------------------------------------------------------
  # * Setter font_size
  #--------------------------------------------------------------------------
  def font_size=(v); contents.font.size=v; end
end # Window_BasicTextTB

#==============================================================================
# Used to display unit information during production scene
#==============================================================================
class Window_TBUnitData < Window_Base
  ICON_SIDE = 24
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    return unless @production_menu
    refresh if !@name.eql?(name)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    @name = name
    load_event_map  
    draw_unit_event 
  end
  #--------------------------------------------------------------------------
  # * Getter Name
  #--------------------------------------------------------------------------
  def name; @production_menu.unit_name; end
  #--------------------------------------------------------------------------
  # * Setter Production Menu
  #--------------------------------------------------------------------------
  def production_menu=(w); @production_menu = w; end
  #--------------------------------------------------------------------------
  # * Load Event Map
  #--------------------------------------------------------------------------
  def load_event_map
    @loaded = true
    tm = TactBattleManager
    map = tm.map
    data = tm.unit_data(@name)
    return msgbox("No event was found on the event map for: #{@name}") if !data
    @event = Game_Event.new(-1, data)
  end
  #--------------------------------------------------------------------------
  # * Draw Unit Event
  #--------------------------------------------------------------------------
  def draw_unit_event
    contents.clear
    wh = BitmapUtils.character_wh(@event.character_name,@event.character_index)
    
    x = width/2 - wh[0]
    ty = wh[1]
    BitmapUtils.draw_character_bitmap(contents, x, 0, @event.character_name, 
        2, @event.character_index, 1, 255, false)
        
    c = Era::TBUnit::Constructable
    c.keys.each do |type|
      @type = type if c[type].include?(@name)
    end
    
    color = Era::TBUnit::Color[@type]
    contents.font.color.set(color ? method(color).call : color1)
    draw_text(0,ty+10,width,line_height, @name)
    
    contents.font.size = 19
    tb = @event.tb_unit
    mv = (t=tb.spec_edges[:move]).nil? ? 0 : t
    jmp = (t=tb.spec_edges[:jump_length]).nil? ? 0 : t
    draw_text(0,ty+=line_height+7,width,line_height, "Move: #{mv} Jump: #{jmp}")
    draw_text(0,ty+=line_height+7,width/3,line_height, "Skills: ")
    
    draw_item_icons(ty) if !tb.battler.nil?
  end
  #--------------------------------------------------------------------------
  # * Draw Item Icons
  #--------------------------------------------------------------------------
  def draw_item_icons(y)
    oy = y+=ICON_SIDE
    x = 0
    max_rows = (contents.height - y)/ICON_SIDE
    skills = @event.tb_unit.battler.skills
    
    skills.each do |s|
      icon_index =  $data_skills[s.id].icon_index
      draw_icon(icon_index, x, y, true)
      y+=ICON_SIDE
      if (y-oy)/ICON_SIDE >= max_rows
        y = oy
        x+=ICON_SIDE
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Colors
  #--------------------------------------------------------------------------
  # light blue
  def color1; Color.new(67,139,247); end
    
  # purplish
  def color2; Color.new(104,58,212); end
  
  # gold
  def color3; Color.new(220,192,49); end
    
  # red
  def color4; Color.new(220, 89, 49); end
    
end # Window_TBUnitData

# Units equipment only for actors currently
class Window_TBunitEquipItem < Window_EquipItem
  #--------------------------------------------------------------------------
  # * Setter Event
  #--------------------------------------------------------------------------
  def event=(e); @event = e; end
  #--------------------------------------------------------------------------
  # * Make Item List
  #--------------------------------------------------------------------------
  def make_item_list
    return if @event.nil?
    @data = @event.tb_unit.all_items.select {|item| include?(item) }
    @data.push(nil) if include?(nil)
  end
  #--------------------------------------------------------------------------
  # * Enable?
  #--------------------------------------------------------------------------
  def enable?(item)
    true
  end
  #--------------------------------------------------------------------------
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
    select(@data.index(@event.tb_unit.last_item.object) || 0)
  end
  #--------------------------------------------------------------------------
  # * Draw Number of Items
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
    draw_text(rect, sprintf(":%2d", @event.tb_unit.item_number(item)), 2)
  end
end # Window_TBunitEquipItem

class Window_UnitsItemOrganization < Window_Selectable
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(*o)
    super(*o)
    @data = []
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    a = $game_party.members[index]
    @data[index] = a
    draw_text(0,index*line_height,width,line_height,a.name)
  end
  #--------------------------------------------------------------------------
  # * Item Max
  #--------------------------------------------------------------------------
  def item_max
    $game_party.members.size
  end
  #--------------------------------------------------------------------------
  # * Actor
  #--------------------------------------------------------------------------
  def actor
    @data[@index]
  end
  
end # Window_UnitsItemOrganization

# categroy window displayed when organizing unit items.
class Window_UnitItemCatOrganization < Window_ItemCategory
  #--------------------------------------------------------------------------
  # * Window Width
  #--------------------------------------------------------------------------
  def window_width
    300
  end
end # Window_UnitItemCatOrganization

class Window_UnitItemOrganizationList < Window_ItemList
  #--------------------------------------------------------------------------
  # * Item Width
  #--------------------------------------------------------------------------
  def item_width
    (300 - standard_padding * 2 + spacing) / col_max - spacing
  end
  #--------------------------------------------------------------------------
  # * Enable?
  #--------------------------------------------------------------------------
  def enable?(item)
    true
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(*o)
    contents.font.size = 17
    super(*o)
  end
end # Window_UnitItemOrganizationList

# window displayed when player inventory or unit item list.
class Window_UnitPartyChoice < Window_HorzCommand
  #--------------------------------------------------------------------------
  # * Make Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Party",  :party,  true)
    add_command("Unit",   :unit,   true)
  end
  #--------------------------------------------------------------------------
  # * Window Width
  #--------------------------------------------------------------------------
  def window_width
    300
  end
  #--------------------------------------------------------------------------
  # * Column Max
  #--------------------------------------------------------------------------
  def col_max
    2
  end
end # Window_UnitPartyChoice

#==============================================================================
# ** Utility to organize saving and extracting data from a TBM for/from a game
#       save file.
#==============================================================================
class TB_DataSave
  attr_reader :events, :units
  TM = TactBattleManager
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize
    save_tb
    self
  end
  #--------------------------------------------------------------------------
  # * Save Events
  #--------------------------------------------------------------------------
  def save_events; 
    events, @events = $game_map.events,{}
    events.keys.each{|k|@events[k]=events[k]}
  end
  #--------------------------------------------------------------------------
  # * Load Events
  #--------------------------------------------------------------------------
  def load_events 
    map = $game_map
    map.events = @events 
    map.reset_exy_cache
  end
  #--------------------------------------------------------------------------
  # * Save TB
  #--------------------------------------------------------------------------  
  def save_tb
    save_events
    @valid_pos = TM.valid_pos
    @ai_production = TM.ai_production
    @turn = TM.turn
    @turn_number = TM.turn_number
    @one_produced = TM.one_produced
    @party_on_map = TM.party_on_map
    @tact_battle = TM.tact_battle
    @selecting_command = TM.selecting_command
    @selecting_target = TM.selecting_target
    @ai_cache = TM.ai_cache
    @popup_queue = TM.popup_queue
    @unit_items_actors_tb = TM.unit_items_actors_tb
    @old_graphic_index = TM.old_graphic_index
    @old_graphic_name = TM.old_graphic_name
    @follower_visibility = TM.follower_visibility
    @old_py = TM.old_py
    @old_px = TM.old_px
    @units = TM.units
    @unit_queue = TM.unit_queue
    @map = TM.map
    @unit_ev_data = TM.unit_ev_data
    @placing_party = TM.placing_party
    @pp_initx = TM.pp_initx
    @pp_inity = TM.pp_inity
    @transition_to_exit = TM.transition_to_exit
    @old_player_speed = TM.old_player_speed
    @start_queue = TM.start_queue
    @response_queue = TM.response_queue
    @rev_dead_type = TM.rev_dead_type
    @goto_stats = TM.goto_stats
    @retarget_que = TM.retarget_que
    @run_end_ev = TM.run_end_ev
    @end_ev_id = TM.end_ev_id
    @last_tb_result = TM.last_tb_result
  end
  #--------------------------------------------------------------------------
  # * Load TB
  #--------------------------------------------------------------------------
  def load_tb
    TM.valid_pos = @valid_pos
    TM.ai_production = @ai_production
    TM.turn = @turn
    TM.turn_number = @turn_number
    TM.one_produced = @one_produced
    TM.party_on_map = @party_on_map
    TM.tact_battle = @tact_battle
    TM.selecting_command = @selecting_command
    TM.selecting_target = @selecting_target
    TM.ai_cache = @ai_cache
    TM.popup_queue = @popup_queue
    TM.unit_items_actors_tb = @unit_items_actors_tb
    TM.old_graphic_index = @old_graphic_index
    TM.old_graphic_name = @old_graphic_name
    TM.follower_visibility = @follower_visibility
    TM.old_py = @old_py
    TM.old_px = @old_px
    TM.units = @units
    TM.unit_queue = @unit_queue
    TM.map = @map
    TM.unit_ev_data = @unit_ev_data
    TM.placing_party = @placing_party
    TM.pp_initx = @pp_initx
    TM.pp_inity = @pp_inity
    TM.transition_to_exit = @transition_to_exit
    TM.old_player_speed = @old_player_speed
    TM.start_queue = @start_queue
    TM.response_queue = @response_queue
    TM.rev_dead_type = @rev_dead_type
    TM.goto_stats = @goto_stats
    TM.retarget_que = @retarget_que
    TM.run_end_ev = @run_end_ev
    TM.end_ev_id = @end_ev_id
    TM.last_tb_result = @last_tb_result
    load_events
  end
end # TB_DataSave

#==============================================================================
# ** Window_UnitStats
#     Used to display the stats of a unit durring a tactical battle
#==============================================================================
class Window_UnitStats < Window_Base
  DEFAULT_FACE = 96
  BLUE = Color.new(16,177,236)
  WHITE = Color.new(255,255,255)
  TM = TactBattleManager
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    return hide if !TactBattleManager.tact_battle?
    super
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Data
  #--------------------------------------------------------------------------
  def draw_actor_data(x,y,text,val,mid="x")
    contents.font.color.set(BLUE)
    draw_text(x+7,y,width-DEFAULT_FACE-standard_padding,line_height, text)
    
    contents.font.color.set(WHITE)
    draw_text(x+57,y,width-DEFAULT_FACE-standard_padding, 
      line_height, mid+val.to_s)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    return if @tb_event.nil?
    contents.clear
    is_actor = (b=@tb_event.tb_unit.battler).is_a?(Game_Actor)
    ty = 0
    tbu = @tb_event.tb_unit
    lh = line_height-10
    contents.font.size = 19
    
    if is_actor
      draw_actor_face(b,0,0)
      ty = DEFAULT_FACE
      
      offy = 0
      contents.font.color.set(BLUE)
      draw_text(DEFAULT_FACE+7,offy,width-96-standard_padding,line_height, 
        @tb_event.event.name)
        
      all = tbu.all_action_lmt

      draw_base_h(DEFAULT_FACE, offy, lh, tbu)
    else
      wh = BitmapUtils.character_wh(@tb_event.character_name,@tb_event.character_index)
      x = width/2 - wh[0]
      ty = wh[1]-lh
      BitmapUtils.draw_character_bitmap(contents, x, 0, @tb_event.character_name, 
        2, @tb_event.character_index, 1, 255, false)
      draw_text(0,ty,width-DEFAULT_FACE-standard_padding,
        line_height, @tb_event.event.name)
      
      ty = draw_base_h(0,ty,lh,tbu) + lh
    end
    
    draw_stat(ty, b.atk, "atk ")
    draw_stat(ty+=lh, b.def, "def ")
    draw_stat(ty+=lh, b.mat, "mat ")
    draw_stat(ty+=lh, b.mdf, "mdf ")
    draw_stat(ty+=lh, b.agi, "agi ")
    draw_stat(ty+=lh, Era.round(b.hit*100,10).to_s+"%", "hit ")
    draw_stat(ty+=lh, Era.round(b.eva*100,10).to_s+"%", "evasion ")
    draw_stat(ty+=lh, Era.round(b.mev*100,10).to_s+"%", "mag evasion ")
    draw_stat(ty+=lh, Era.round(b.hrg*100,10).to_s+"%", "hp regen ")
    draw_stat(ty+=lh, Era.round(b.mrg*100,10).to_s + "%", "mp regen ")
    draw_stat(ty+=lh, Era.round(b.mrf*100,10).to_s + "%", "mag reflect ")
    draw_stat(ty+=lh, Era.round(b.pdr*100,10).to_s + "%", "atk dmg rate ")
    draw_stat(ty+=lh, Era.round(b.mdr*100,10).to_s + "%", "mag dmg rate ")
  end
  #--------------------------------------------------------------------------
  # * draw_base_h
  #--------------------------------------------------------------------------
  def draw_base_h(x,y,lh,tbu)
    all = tbu.all_action_lmt
    draw_actor_data(x,y+=lh,"skill",[tbu.skill_action_lmt,all].max)
    draw_actor_data(x,y+=lh,"atk",[tbu.atk_action_lmt,all].max)
    draw_actor_data(x,y+=lh,"item",[tbu.item_action_lmt,all].max)
    draw_actor_data(x,y+=lh,"move",tbu.move, "")
    draw_actor_data(x,y+=lh,"jump",tbu.spec_edges[:jump_length],"")
    y
  end
  #--------------------------------------------------------------------------
  # * Draw Stat
  #--------------------------------------------------------------------------
  def draw_stat(y,stat,text)
    contents.font.color.set(BLUE)
    draw_text(0,y,width,line_height, text)
    contents.font.color.set(WHITE)
    draw_text(115,y,width,line_height, stat.to_s)
  end
  #--------------------------------------------------------------------------
  # * Tb Event
  #--------------------------------------------------------------------------
  def tb_event=(e); @tb_event = e; refresh; end
  #--------------------------------------------------------------------------
  # * Colors
  #--------------------------------------------------------------------------
  def color1; Color.new(191, 119, 28); end
  def color2; Color.new(255, 179, 47); end
  
end # Window_UnitStats

#=============================================================================
# ** SceneTBMainMenu
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#    Main menu during a tactical battle. Press 'X' while not over a unit to 
#     start this scene.
#=============================================================================
class SceneTBMainMenu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start
  #--------------------------------------------------------------------------
  def start
    super
    create_tb_main_menu
    orient_windows
    cache_ai_next_turn if TactBattleManager::Defaults::CacheTime > 0.0
  end
  #--------------------------------------------------------------------------
  # * Orient Windows
  #--------------------------------------------------------------------------
  def orient_windows
    cx = Graphics.width/2 - @tb_main_menu.width/2
    cy = Graphics.height/2 - @tb_main_menu.height/2
    @tb_main_menu.x, @tb_main_menu.y = cx, cy
  end
  #--------------------------------------------------------------------------
  # * Create Main menu
  #--------------------------------------------------------------------------
  def create_tb_main_menu
    @tb_main_menu = Window_TBMainMenu.new(0,0)
    @tb_main_menu.set_handler(:end_turn, method(:end_player_turn))
    @tb_main_menu.set_handler(:save, method(:save_tb))
    @tb_main_menu.set_handler(:cancel, method(:cancel))
    @tb_main_menu.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # * End Player Turn
  #--------------------------------------------------------------------------
  def end_player_turn
    #TactBattleManager.next_teams_turn
    TactBattleManager.go_next_turn
    #TactBattleManager.ai_turn
    return_scene
  end
  #--------------------------------------------------------------------------
  # * Save tb
  #--------------------------------------------------------------------------
  def save_tb
    SceneManager.call(Scene_Save)
  end
  #--------------------------------------------------------------------------
  # * Cancel
  #--------------------------------------------------------------------------
  def cancel
    return_scene
  end
  #--------------------------------------------------------------------------
  # * Start caching for ai turn if allowed to
  #--------------------------------------------------------------------------
  def cache_ai_next_turn
    
    return # method no longer used, ai moves no longer calculated all at once.
    
    print "cache_ai_next_turn\n"
    t = Time.now
    
    tm = TactBattleManager
    tm.empty_ai_cache
    
    nxt_team = tm.whos_turn_next
    #tm.turn = tm::ENEMY
    gs = Era::AI.gen_map_graphs(nxt_team)
    #tm.turn = tm::PLAYER
    m = $game_map
    
    gs.keys.each{|key| tm.cache(key, gs[key])} if gs != nil
    
    eu = tm.units[nxt_team][:event]
    ai_cache = tm.ai_cache
    
    c = t = Time.now - t
    while c < tm::Defaults::CacheTime
      t = Time.now
      eu.values.each do |e|
        tbu=e.tb_unit
        if !ai_cache[:graph][tbu.se_hash_key] && !ai_cache[:path][e.id]
          
          r = MoveUtils.bfs_no_graph_start(e.x,e.y, nil, tbu.spec_edges)
          
          ai_cache[:path][e.id] = r[0]
          ai_cache[:dist][e.id] = r[1]
        end
      end
      c+=Time.now - t 
    end
    
    # if a graph would be generated for the entire graph, make that graph
    # then run pathfinding on upto 10 units effected by that graph
  end
end # SceneTBMainMenu

#=============================================================================
# ** Scene_Base
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   No game over on party death during a tactical battle, check loss instead.
#=============================================================================
class Scene_Base
  #--------------------------------------------------------------------------
  # * Alias, check_gameover
  #--------------------------------------------------------------------------
  alias check_gameover_tb_era check_gameover
  def check_gameover
    tm = TactBattleManager
    if !TactBattleManager.tact_battle?
      check_gameover_tb_era 
    end
  end
  #--------------------------------------------------------------------------
  # * Waiting for a response
  #--------------------------------------------------------------------------
  def waiting_for_response_tb?
    true # done waiting during scene_map otherwise need to wait
  end 
  
end # Scene_Base

#=============================================================================
# * Scene_Map
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Processing for enemy and player turn during a tactical battle.
#=============================================================================
class Scene_Map < Scene_Base
  attr_reader :wait_on_ai
  TM = TactBattleManager  # namespace pollu. need to change
  TB_AOE = :tb_aoe
  DISPLAY_TB = :quick_display
  #---------------------------------------------------------------------------
  # * Alias start
  #---------------------------------------------------------------------------
  alias scene_map_tbs_start start
  def start
    scene_map_tbs_start
    init_tb_vals
    init_tb_highlghts
    tbs_start_era if TactBattleManager.tact_battle?
  end
  #---------------------------------------------------------------------------
  # * Alias, Create All Windows
  #---------------------------------------------------------------------------
  alias create_all_windows_tb_era create_all_windows
  def create_all_windows
    create_all_windows_tb_era
    create_windows_tb_era
  end
  #---------------------------------------------------------------------------
  # * Initialize Values that will be used during a tactical battle
  #---------------------------------------------------------------------------
  def init_tb_vals
    @tb_player_info = {}            # info used when resetting player movement
    @tb_unit_range = Unit_Range.new # has shortest path for curr unit
    @party_index_tb = 1
    @atk_hl_disp = 0        # counter for the skill that is displayed on A press
    @wait_on_ai = false
    @event_waiting_for = 0
    @tb_ev_respond_id = 0
    @safety_tb = 0
  end
  #---------------------------------------------------------------------------
  # * Initialize Highlights
  #---------------------------------------------------------------------------
  def init_tb_highlghts
    map = $game_map
    nhls = map.next_hl_locs
    add_hl_store_att(nhls) if !nhls.nil?
    map.clear_next_highlights
    temp = $game_temp
    @tb_event, @tb_item = temp.tb_event, temp.tb_item
  end
  #---------------------------------------------------------------------------
  # * Reset @tb_event, @tb_item, map highlights, etc.
  #---------------------------------------------------------------------------
  def clean_tb_turn_data
    turn_off_flash_tbe
    @tb_event = nil
    @tb_item = nil
    @wait_on_ai = false
    @safety_tb = 0
    @player_turn_init = false
    @enemy_turn_init = false
    @event_waiting_for = 0
    @tb_ev_respond_id = 0
    
    (temp = $game_temp).tb_event = nil
    temp.tb_item = nil
    TactBattleManager.set_selecting_target(false)
    $game_map.clear_next_highlights
  end
  def turn_off_flash_tbe
    return if !@tb_event
    @tb_event.flash_soft_tb = false
  end
  #---------------------------------------------------------------------------
  # * tbs_start_era
  #     Used when starting a tactical battle map
  #---------------------------------------------------------------------------
  def tbs_start_era
    create_windows_tb_era
  end
  #---------------------------------------------------------------------------
  # * Place Party Members
  #---------------------------------------------------------------------------
  def place_party_members_tb
    xy = TactBattleManager.pp_xy # location of player at the start of the tb
    
    map, player = $game_map, $game_player
    x, y = map.party_init_ox, map.party_init_oy
    x, y = xy[0], xy[1] if x.nil? || y.nil? # init with player pos if !set
    
    return no_init_pos_tb if map.placement_arr_tb.nil?
    
    map.placement_arr_tb.each do |v|
      TactBattleManager.add_valid_pos([vx = x+v.x, vy = y+v.y])
      @spriteset.add_highlight_tb(vx,vy,nil,false,:default_move,:tb_party_init)
    end
    TactBattleManager.party_on_map = false         # Checked in update
    TactBattleManager.placing_party = false
    
  end
  #---------------------------------------------------------------------------
  # * Helpful message box when no initial tb party position was defined for the
  #     current map.
  #---------------------------------------------------------------------------
  def no_init_pos_tb
    TactBattleManager.exit_tb
    msgbox("Map #{$game_map.map_id}: no party start positions defined.") 
  end
  #---------------------------------------------------------------------------
  # * orient_windows
  #---------------------------------------------------------------------------
  def orient_windows
    @tb_command_window.y = @team_turn_window.height
    @unit_window.y = Graphics.height - @unit_window.height
    @status_window_tb.x = @tb_command_window.x + @tb_command_window.width
    @status_window_tb.y = @tb_command_window.y
    @all_shared_acts_win.y = @help_win_tb.y + @help_win_tb.height
    @all_shared_acts_win.x = @help_win_tb.x
    @windows_oriented = true
  end
  #---------------------------------------------------------------------------
  # * Alias update
  #---------------------------------------------------------------------------
  alias ratabs_scmap_update_meth update
  def update
    ratabs_scmap_update_meth
    tb_update if TM.tact_battle?
    start_end_tb_ev if TM.run_end_ev
  end
  #---------------------------------------------------------------------------
  # * start_end_tb_ev, run an event at the end of a tactical battle
  #---------------------------------------------------------------------------
  def start_end_tb_ev
    return if !(e = $game_map.events[TM.end_ev_id])
    Era::AI.start_event(e.id)
    TM.done_starting_end_ev
  end
  #---------------------------------------------------------------------------
  # * Hide Help Window
  #---------------------------------------------------------------------------
  def hide_help_window_tb
    @help_win_tb.hide if @help_win_tb && TM.turn != TM::PLAYER || !TM.tact_battle?
  end
  #---------------------------------------------------------------------------
  # * Show help window
  #---------------------------------------------------------------------------
  def show_help_window_tb
    @help_win_tb.show if @help_win_tb && TM.turn == TM::PLAYER
  end
  #---------------------------------------------------------------------------
  # * Tactical Battle Update
  #---------------------------------------------------------------------------
  def tb_update
    
    # Flow control for additional teams update works by:
    #
    # 1.) At start of Tb fill up queue based on the current set of teams that
    #       exist.
    # 2.) dequeue and let that team go, if it's ai controlled, start the ai with
    #     that team name as a parameter if it's player controlled, start the 
    #     player turn with that team name as a parameter.
    #     (not actually dequeue though, just incrementing a counter, when last
    #      team's position in the queue is reached the counter goes back to the
    #      beginning).
    # 3.) whenever a team is added or removed from the list of current teams in
    #     the tactical battle, store the position of the next team that would
    #     get to move (based on the current turn's team's position in the queue)
    #     and then empty all elements from the queue and refill it based on the
    #     new set of teams that exist. The next team that moves is based on the 
    #     number that was stored previously.
    
    #print "0\n"
    return if run_on_busy_tb?
    #print "1\n"
    check_end_tb
    return if waiting_btw_turns?
    #print "2\n"
    open_team_actions_window if TM.turn.eql?(TM::PLAYER)
    # return if wait_on_turn_window
    show_help_window_tb
    hide_help_window_tb
    return clean_up_tb if scene_changing? || TM.leaving?
    #print "3\n"
    update_fog_tb
    
    put_queued_units     # places all unit is the tb queue onto the map
    create_windows_tb_era if !@windows_oriented # do when switching to a tb
    place_party_members_tb if TM.placing_party?
    return place_party_events if !TM.party_on_map
    #print "4\n"
    # Make sure that everything that wanted to respond got the chance to repond
    #   before continuing
    return eval_response_tb_era if !TM.response_queue.empty? #|| @tb_ev_respond_id != 0
    #print "5\n"
    return if waiting_for_response_tb?
    
    # Player's Turn
    tb_first_turn # first turn upon returning to map if necessary
    
    go_next_turn_tb if forcing_next_turn?
    
    # eval_team_turn(TM.turn)
    do_player_turn if player_turn_ok? # TM.turn.eql?(TM::PLAYER) && !@wait_on_ai
    
    # Enemy Turn
    do_enemy_turn if TM.is_npc_turn? && !@wait_on_ai
    do_finish_ai if @wait_on_ai
    
    do_end_turn_routine if TM.no_ones_turn?
    # print "TM.start_queue #{TM.start_queue}\n"
    #do_turn_end_evs if !player_turn_ok? && !@wait_on_ai
    #finish_turn_end_evs if @wait_on_turn_end_evs
    # safety_start_player_turn if !TM.turn.eql?(TM::PLAYER)
  end
  #---------------------------------------------------------------------------
  # * Update fog data
  #---------------------------------------------------------------------------
  def update_fog_tb
    TM.fog_ctrl.update
    
    create_fog if TM.fog_ctrl.want_fog
    # create fog highlights if necessary
    # remove fog highlights if necessary
    # update fog highlights based on unit vision
  end
  #---------------------------------------------------------------------------
  # * Create Fog
  #---------------------------------------------------------------------------
  def create_fog
    TM.fog_ctrl.create_fog(@spriteset)
    
  end
  #---------------------------------------------------------------------------
  # * Set whether or not tb runs while game_message is up
  #---------------------------------------------------------------------------
  def run_on_busy_tb?
    $game_message.busy?
  end
  #---------------------------------------------------------------------------
  # * Waiting between turns?
  #---------------------------------------------------------------------------
  def waiting_btw_turns? 
    @waiting_between_turns ||= 0 
    @waiting_between_turns-=1 if @waiting_between_turns > 0
  end
  #---------------------------------------------------------------------------
  # * Forcing next turn?
  #---------------------------------------------------------------------------
  def forcing_next_turn?
    TM.force_next_turn
  end
  #---------------------------------------------------------------------------
  # * Routine run after all other teams have finished
  #---------------------------------------------------------------------------
  def do_end_turn_routine
    # print "end_turn_routine TM.no_ones_turn? = #{TM.no_ones_turn?} TM.turn = #{TM.turn}\n"
    do_turn_end_evs if TM.curr_teams_queue.empty? # skip after first call here
    TM.curr_teams_queue.push(:EVAL_END_TURN)
    
    finish_turn_end_evs if @wait_on_turn_end_evs
    
    if !@wait_on_turn_end_evs
      TM.restart_all_turns
      go_next_turn_tb 
    end
  end
  #---------------------------------------------------------------------------
  # * Start running events at end of turn
  #---------------------------------------------------------------------------
  def do_turn_end_evs
    @wait_on_turn_end_evs = true
    ev_ids = TM.ev_turn_start[TM.turn_no]
    print "do_turn_end_evs, ev_ids = #{ev_ids} turn_no = #{TM.turn_no}\n"
    if ev_ids
      ev_ids.each{|id| Era::AI.start_event(id)}
    end
  end
  #---------------------------------------------------------------------------
  # * Wait for turn end events to finish running
  #---------------------------------------------------------------------------
  def finish_turn_end_evs
    events = $game_map.events
    not_done = false
    ev_ids = TM.ev_turn_start[TM.turn_no]
    if ev_ids
      ev_ids.each do |id|
        e = events[id]
        intp = events[id].interpreter
        not_done = not_done || (e.starting || (intp && intp.running?)) # don't want to break
      end
    end
    @wait_on_turn_end_evs = false if !not_done
  end
  #---------------------------------------------------------------------------
  # * Initialize values for the first turn if it's being started
  #---------------------------------------------------------------------------
  def tb_first_turn
    TM.init_first_turn if TM.do_first_turn
  end
  #---------------------------------------------------------------------------
  # * A temporary safety check to help fix a bug that occurs (difficult to 
  #     replicate) in which the ai turn will not end.
  #---------------------------------------------------------------------------
  def safety_start_player_turn
     ai_done_tb if (@safety_tb+=1)> TM::Defaults::SafetyTimer &&TM.queues_empty?
  end
  #---------------------------------------------------------------------------
  # * Player Turn Ok
  #---------------------------------------------------------------------------
  def player_turn_ok? 
    !waiting_for_response_tb? && TM.start_queue.empty? &&
      @event_waiting_for == 0 && !@wait_on_ai && player_ctrl_turn?
    end
  #---------------------------------------------------------------------------
  # * Player controlled turn?
  #---------------------------------------------------------------------------
  def player_ctrl_turn?
    TM.player_ctrl_turn?
  end
  #---------------------------------------------------------------------------
  # * Eval Response Tb Era
  #---------------------------------------------------------------------------  
  def eval_response_tb_era
    if @tb_ev_respond_id == 0 
      @tb_ev_respond_id = TM.next_response
      Era::AI.start_event(@tb_ev_respond_id)
      e = $game_map.events[@tb_ev_respond_id]
      e.tb_response_wait = true if e
    else
      e = $game_map.events[@tb_ev_respond_id] # destroyed or call when q-m-t
      @tb_ev_respond_id = 0 if e.nil? || !e.tb_response_wait 
    end
  end
  #---------------------------------------------------------------------------
  # * Waiting for an event to finish
  #---------------------------------------------------------------------------
  def waiting_for_response_tb?
    e = $game_map.events[@tb_ev_respond_id]
    # print "e.list:\n #{e.list}\n" if e
    !TM.response_queue.empty? || (e && e.tb_response_wait)
  end
  #---------------------------------------------------------------------------
  # * Flow during player's turn
  #---------------------------------------------------------------------------
  def do_player_turn
    eval_popup_queue
    start_player_turn if !@player_turn_init
    tbs_unit_selection 
    
    map = $game_map
    show_unit_hud(map.events[map.tbu_id_xy($game_player.x,$game_player.y)])
    update_all_sh_acts_win
    update_hl_follow if TM.selecting_target?
    hide_skill_disp_win
    preview_effect_tb
  end
  #---------------------------------------------------------------------------
  # * Update window showing team actions
  #---------------------------------------------------------------------------
  def update_all_sh_acts_win(opts = {})
    c_acts = TM.curr_shared_acts.to_i
    s_acts = TM.sum_shared_acts.to_i
    diff = s_acts - c_acts
    @all_shared_acts_win.text = "#{actions_left_txt_era} #{diff}/#{s_acts}"
  end
  #---------------------------------------------------------------------------
  # * Preview effect_tb
  #---------------------------------------------------------------------------
  def preview_effect_tb
    # Effects should be previewed as a percentage over each individual unit
    # that could be effected by the attack percentage represents 
    
    disp_prev_win(TM.selecting_target?||@showing_temp_hls)
  end
  #---------------------------------------------------------------------------
  # * Hide Skill display window
  #---------------------------------------------------------------------------
  def hide_skill_disp_win
    display_skill_tb(nil) if !TM.selecting_target && !@showing_temp_hls
  end
  #---------------------------------------------------------------------------
  # * Start Player Turn
  #---------------------------------------------------------------------------
  def start_player_turn
    open_team_turn_window
    open_team_actions_window
    @player_turn_init = true
  end
  #---------------------------------------------------------------------------
  # * Open actions window if sharing actions between all units
  #---------------------------------------------------------------------------
  def open_team_actions_window
    @all_shared_acts_win.show if TM.use_shared_actions?
  end
  def close_team_acts_win
    @all_shared_acts_win.hide
  end
  #---------------------------------------------------------------------------
  # * params -> 0 = text, 1 = x, 2 = y, 3 = event
  #---------------------------------------------------------------------------
  def eval_popup_queue
    queue = TM.popup_queue
    queue.keys.each do |xy|
      if (params=queue[xy])[2].animation_id == 0
        @spriteset.add_bouncy_text_era("#{params[1]} " + params[0],xy[0],xy[1])
        queue.delete(xy)
      end
    end
  end
  #---------------------------------------------------------------------------
  # * Do Enemy Turn
  #---------------------------------------------------------------------------
  def do_enemy_turn
    # start_enemy_turn if !@enemy_turn_init
    print " - - - doing enemy turn - - - \n"
    ai = Era::AI
    ai.routine(:easy, TM.turn)
    @wait_on_ai = true
  end
  #---------------------------------------------------------------------------
  # * Finish the ai's turn
  #---------------------------------------------------------------------------
  def do_finish_ai
    # print "in do_finish_ai @wait_on_ai #{@wait_on_ai}\n"
    # print "@event_waiting_for #{@event_waiting_for}\n"
    # print "TM.response_queue #{TM.response_queue}\n"
    
    if @event_waiting_for == 0 && TM.response_queue.empty?
      
      # At the start of the enemies turn, just push all of them into next start
      # change start_event so that that is when everything happens.
      
      @event_waiting_for = TM.next_start
      # print "@event_waiting_for = #{@event_waiting_for} start_queue #{TM.start_queue}\n"
      # print "@event_waiting_for = #{@event_waiting_for}\n"
      
      if @event_waiting_for != 0
        
        # print "routine for #{@event_waiting_for}\n"
        Era::AI.easy_main_routine(@event_waiting_for)
        Era::AI.start_event(@event_waiting_for)
      else
        ai_done_tb
      end
    else
      # set the event to 0 here responses are evaluted in base control flow.
      e = $game_map.events[@event_waiting_for]
      intp = e.interpreter
      intp_running = intp && intp.running?
      #print "e.acts_done_tb #{e.acts_done_tb}\n" if e
      #print "intp_running = #{intp_running}\n"
      #print "event.list #{e.list}\n"
      if !e || (e.acts_done_tb)# && !(intp_running || e.starting))
        @event_waiting_for = 0
      end
    end
  end
  #---------------------------------------------------------------------------
  # * Called after start queue is empty, ai finished acting
  #---------------------------------------------------------------------------
  def ai_done_tb
    # print "\n\n\n~~~~~~~ AI DONE ~~~~~~~~~~ \nstart_queue=#{TM.start_queue}\n\n\n"
    
    @wait_on_ai = false # nothing left in queue
    Era::AI.produce_units 
    # do_turn_end_evs
    # start_player_turn_tb
    go_next_turn_tb
  end
  #---------------------------------------------------------------------------
  # * The current team's turn is done and now the next team can go
  #---------------------------------------------------------------------------
  def go_next_turn_tb(options = {})
    opts = {wait: true}.merge(options)
    TM.next_teams_turn
    clean_tb_turn_data
    
    if TM.player_ctrl_turn?
      start_player_turn_tb 
    elsif TM.is_npc_turn?
      start_enemy_turn
    end
    
    TM.force_next_turn = false
    @waiting_between_turns = TM.wait_speed if opts[:wait]
    # TM.player_ctrl_turn? ? start_player_turn_tb : start_enemy_turn
  end
  #---------------------------------------------------------------------------
  # * Start Enemy Turn
  #---------------------------------------------------------------------------
  def start_enemy_turn
    # print "start_enemy_turn"
    open_team_turn_window
    close_team_acts_win
    @enemy_turn_init = true
    TM.ai_turn
  end
  #---------------------------------------------------------------------------
  # * all_enemies_done?
  #---------------------------------------------------------------------------
  #def all_enemies_done?
  #  ai_teams = TM.curr_teams.collect{|t| t if TM.is_npc_turn?(t)}
  #  print "all_enemies_done?  ai_teams = #{ai_teams}\n"
  #  TM.units[TM::ENEMY][:event].values.each{|e| return false if !e.acts_done_tb}
  #  return true
  #end
  #---------------------------------------------------------------------------
  # * Start Player Turn
  #---------------------------------------------------------------------------
  def start_player_turn_tb
    # print "start_player_turn_tb"
    clean_tb_turn_data # clean up data from last turn
    # TM.ready_next_turns
    TM.players_turn
  end
  #---------------------------------------------------------------------------
  # * Make New Units from queue
  #---------------------------------------------------------------------------
  def put_queued_units
    queue = TactBattleManager.unit_queue
    queue.each do |args| 
      opts = {:x => args[2], :y => args[3], :wait => args[4][:wait]}
      TactBattleManager.new_unit_h(args[0],args[1],opts)
    end
    TactBattleManager.empty_unit_queue
  end
  #---------------------------------------------------------------------------
  # * Place party events on the map
  #---------------------------------------------------------------------------
  def place_party_events
    if Input.trigger?(:C)
      on_click
      SceneManager.call(Scene_TbPartyPlacement)
      SceneManager.scene.prepare(["$game_party".to_sym])
    end
  end
  #---------------------------------------------------------------------------
  # * Produce Units
  #---------------------------------------------------------------------------
  def produce_units
      map, p = $game_map, $game_player
      return false if map.tbu_id_xy(x=p.x,y=p.y) != 0 # can't produce if tb_unit is ontop
      return false if (ids = map.cache_ids_xy(x,y)).empty? # no event
      
      prod = []
      ids.each do |id| e = map.events[id]
        prod = prod + e.tb_prod_syms
      end
      return false if prod.empty?
      
      TM.add_valid_pos([x, y])
      
      SceneManager.call(Scene_UnitProduction)
      SceneManager.scene.prepare(prod)
      
      after_produce_tb
      true
  end
  #---------------------------------------------------------------------------
  # * Processing after clicking produce unit
  #---------------------------------------------------------------------------
  def after_produce_tb
    TM.set_selecting_target(false)
    @move_pos_selecting =false
    @showing_temp_hls =false
  end
  #---------------------------------------------------------------------------
  # * Helper for getting party members when placing on map
  #---------------------------------------------------------------------------
  def pt_memb_name
    {:name=>$game_party.members[@party_index_tb].name}
  end
  #---------------------------------------------------------------------------
  # * Create Windows
  #---------------------------------------------------------------------------
  def create_windows_tb_era
    create_unit_hud
    create_unit_turn_dir_window_tb
    create_tb_command_window_tb
    create_team_turn_window_tb
    create_status_window_tb
    create_skill_display_wtb
    create_skill_preview_wtb
    create_help_window_tb
    create_all_shared_acts_win
    orient_windows
  end
  #---------------------------------------------------------------------------
  # * Window for displaying total shared actions left
  #---------------------------------------------------------------------------
  def create_all_shared_acts_win
    h,w = Graphics.height, Graphics.width
    @all_shared_acts_win = Window_BasicTextTB.new(0,0,200,55)
    @all_shared_acts_win.viewport = @viewport
    
    @all_shared_acts_win.text = actions_left_txt_era
    @all_shared_acts_win.no_skin
    @all_shared_acts_win.font_size = 14
    @all_shared_acts_win.hide
  end
  #---------------------------------------------------------------------------
  # * Text constant
  #---------------------------------------------------------------------------
  def actions_left_txt_era
    " Moves: "
  end
  #---------------------------------------------------------------------------
  # * Create Help Window Tb
  #---------------------------------------------------------------------------
  def create_help_window_tb
    return if !TM::Defaults::Show_HelpWin
    w = 200; h = 80; g = Graphics; x = g.width-w; y = 0; sz = 14
    @help_win_tb = Window_BasicTextTB.new(x,y,w,h)
    @help_win_tb.no_skin
    @help_win_tb.font_size = sz
    @help_win_tb.lineup_text(TM::Defaults::Help_Text, sz)
    @help_win_tb.hide
  end
  #---------------------------------------------------------------------------
  # * Create window for previewing the effect of a skill being used
  #---------------------------------------------------------------------------
  def create_skill_preview_wtb
    w,h,g = 155, 55, Graphics
    @skill_prev_win = Window_BasicTextTB.new(g.width-w, g.height-h, w,h)
    @skill_prev_win.viewport = @viewport
    @skill_prev_win.font_size = 20
    @skill_prev_win.hide
  end
  #---------------------------------------------------------------------------
  # * Create window for displaying the name of the skill that is currently 
  #     being used
  #---------------------------------------------------------------------------
  def create_skill_display_wtb
    w,h,g = 360, 53, Graphics
    @skill_disp_win = Window_BasicTextTB.new(g.width/2,0,w,h)
    @skill_disp_win.viewport = @viewport
    @skill_disp_win.no_skin
    @skill_disp_win.font_size = 20
    @skill_disp_win.hide
  end
  #---------------------------------------------------------------------------
  # * Create Turn Window
  #---------------------------------------------------------------------------
  def create_team_turn_window_tb
    @team_turn_window = Window_ShowTurn.new
    @team_turn_window.viewport = @viewport
  end
  def wait_on_turn_window
    # print "wait on turn_window? #{@team_turn_window.contents_opacity_is > 100} contents_opacity #{@team_turn_window.contents_opacity_is}\n"
    @team_turn_window.contents_opacity_is > 100 
  end
  #---------------------------------------------------------------------------
  # * Open Team Turn Window
  #---------------------------------------------------------------------------
  def open_team_turn_window
    @team_turn_window.open
  end
  #---------------------------------------------------------------------------
  # * Alias, update_scene
  #---------------------------------------------------------------------------
  alias update_scene_tb_era update_scene
  def update_scene
    update_scene_tb_era
  end
  #---------------------------------------------------------------------------
  # * Check if the tb should end
  #---------------------------------------------------------------------------
  def check_end_tb
    return if !TM.tact_battle?
    if !waiting_for_response_tb?
      TM.process_win if TM.player_success?
      TM.process_loss if TM.enemy_success?
    end
  end
  #---------------------------------------------------------------------------
  # * Update Highlight follows
  #---------------------------------------------------------------------------
  def update_hl_follow
    return unless !@tb_event.nil? && !@tb_item.nil? && !(r = @tb_item.tbs_aoe_range).nil?
    tb_hl_follow(@tb_item.tbs_aoe_range[@tb_event.dir_to_sym_era])
  end
  #---------------------------------------------------------------------------
  # * Stored in the sprite highlights hash in :quick_display
  #---------------------------------------------------------------------------
  def next_atk_hls(x,y, basic_atk = false)
    # init
    map, p = $game_map, $game_player
    reset_aoe_follows
    @tb_item = nil
    id = 1
    e = map.events[map.tbu_id_xy(x,y)]
    return unless !e.nil? && !(battler = e.tb_unit.battler).nil?
    
    # Check should display basic attack
    if !basic_atk
      return if (sz = battler.skills_tb.size) < 1
      @atk_hl_disp += 1; id = @atk_hl_disp % sz
      return if !(s=set_up_use_skill(id, e))
      @showing_temp_hls = true
    else
      id = battler.basic_atk_tb
      return if id < 1 || !(s=set_up_use_skill(nil, e, id))
      @showing_temp_hls = true
    end
    
    # Check, should set selecting-item-target to true
    is_skill = s.is_a?(RPG::Skill)
    is_item = s.is_a?(RPG::Item)
    if e.tb_unit.is_friend?
      if !(tbu=e.tb_unit).atk_ok? && is_skill && s.id == tbu.battler.basic_atk_tb
        return
      elsif is_skill && !tbu.skill_ok?; return
      elsif is_item && !tbu.item_ok?; return
      end
      TactBattleManager.set_selecting_target(true) 
      turn_off_flash_tbe
      @tb_item, @tb_event = s, e
    end
    
    @tb_item = s
    disp_prev_win(true, true)
  end
  #---------------------------------------------------------------------------
  # * Set up item or skill to be used
  #---------------------------------------------------------------------------
  def set_up_use_skill(pos, event, id = nil)
    unit = event
    s = !id ? event.tb_unit.battler.skills_tb[pos] : $data_skills[id]
    return if !s || !s.tb_ok?
    dir = unit.dir_to_sym_era
    spec = s.tbs_spec_range
    range = spec.nil? ? simple_rwith_mod(s) : spec[dir]

    opts = {:offx=>event.x, :offy=>event.y, :hloc=>DISPLAY_TB, 
            :meth => :default_attack, :opacity => 100}
    add_hl_store_att(range, opts) unless range.nil?
    display_skill_tb(s.name)
    s
  end
  #---------------------------------------------------------------------------
  # * Display skill name, hide when name is nil
  #---------------------------------------------------------------------------
  def display_skill_tb(name)
    return @skill_disp_win.hide if name.nil?
    @skill_disp_win.text= name
    @skill_disp_win.show
  end
  #---------------------------------------------------------------------------
  # * Display preview window
  #---------------------------------------------------------------------------
  def disp_prev_win(show, force = false)
    # init
    ai = Era::AI
    map,p = $game_map, $game_player
    x,y = p.x,p.y
    
    return @skill_prev_win.hide if !show || !@tb_item 
    same_xy = x == @old_show_x_tb_un_var && y == @old_show_y_tb_un_var
    return if same_xy && !force
    
    e = map.events[map.tbu_id_xy(x,y)]
    has_target = e && (b = e.tb_unit.battler)
    
    if has_target
      res = ai.invoke_on_target(e, @tb_event, @tb_item, true)
      return if !res
      show_prev_tb(res, b)
    else 
      @skill_prev_win.hide
    end
    update_disp_prev_xy(x,y)
  end
  #---------------------------------------------------------------------------
  # * Update coordinates of last unit whose damage preview was shown
  #---------------------------------------------------------------------------
  def update_disp_prev_xy(x,y)
    @old_show_x_tb_un_var = x; @old_show_y_tb_un_var = y
  end
  #---------------------------------------------------------------------------
  # * Show preview window
  #---------------------------------------------------------------------------
  def show_prev_tb(res, battler)
    @skill_prev_win.text = prev_text_tb(res, battler)
    @skill_prev_win.show
  end
  #---------------------------------------------------------------------------
  # * Preview Text
  #---------------------------------------------------------------------------
  def prev_text_tb(res, battler)
    raw, amp = 0, 0
    if res != 0.0
      raw = TM.raw_damage.to_f * -1
      amp = TM.raw_amp
    end
    min = [raw.abs - amp, 0].max
    max = [raw.abs + amp, 0].max
    min = (min.to_f/battler.mhp)*100
    max = (max.to_f/battler.mhp)*100
    min = Era.round(min,10)
    max = Era.round(max,10)
    sign = raw > 0 ? "+" : ""
    "Pw: #{sign}#{min}% - #{sign}#{max}%  "
  end
  #---------------------------------------------------------------------------
  # * Simple range with equipment modifiers applied
  #---------------------------------------------------------------------------
  def simple_rwith_mod(item)
    actor = @tb_event.tb_unit.battler
    return item.tbs_simple_range if actor.nil? || !actor.is_a?(Game_Actor)
    m,n = item.tb_range_max-1, item.tb_range_min-1
    Unit_Range.points(0,0,n+actor.eqp_r_min(item), m+actor.eqp_r_max(item))
  end
  #---------------------------------------------------------------------------
  # * Show Highlights for movement range
  #---------------------------------------------------------------------------
  def show_move_hls(x,y, hloc = :def)
    reset_aoe_follows
    @spriteset.remove_group(hloc)
    
    TactBattleManager.set_selecting_target(false)
    
    show_move_range_tb(x,y, hloc)
    @showing_temp_hls = !check_no_unit? ? true : false
  end
  #---------------------------------------------------------------------------
  # * On Map Unit Selection
  #---------------------------------------------------------------------------
  def tbs_unit_selection
    map, p = $game_map, $game_player
    x,y = p.x, p.y
    
    if Input.trigger?(TM::Defaults::ShowAtt) #&& !TM.selecting_target?
      on_click
      set_tb_event(x,y)
      return if TM.selecting? # command window is up
      next_atk_hls(x,y) 
    # Press Z to show route then Z again to move the unit
    elsif Input.trigger?(TM::Defaults::ShowMove) 
      on_click
      return tb_enter_trade unless @selecting_tb_trade.nil?
      return if TM.selecting? # command window is up
      return tbs_target_selection if TM.selecting_target?
      return move_unit_tb(x,y) if @move_pos_selecting && can_move?
      return next_menu_ok_tb if @showing_temp_hls # @showing_temp_hls = false
      pok = produce_units if !TM.selecting_target?
      return SceneManager.call(SceneTBMainMenu) if show_mm_ok_tb?(x,y, pok)
      @menu_ok_tb = false
    elsif Input.trigger?(TM::Defaults::SelectAtk)
      on_click
      set_tb_event(x,y)
      return if TM.selecting? # command window is up
      next_atk_hls(x,y, true) 
    elsif Input.trigger?(:B) 
      on_click
      on_cancel_select if !@showing_status
      return if !@tb_event.nil? && @tb_event.move_route_forcing
      return @selecting_tb_trade = nil if @selecting_tb_trade 
      if TM.selecting_target? || @move_pos_selecting || @showing_temp_hls
        end_select
      elsif @showing_status
        @showing_status = false
        @status_window_tb.hide
        @tb_command_window.activate
      else
        turn_off_flash_tbe
        @tb_event = nil
        check_unit_to_show
        SceneManager.call(SceneTBMainMenu) if !TM.selecting? && @tb_event.nil?
      end
      end_click
    end
  end
  #---------------------------------------------------------------------------
  # * Show Main Menu ok?
  #---------------------------------------------------------------------------
  def show_mm_ok_tb?(x,y, pok)
    ((show_menu_if_no_tb(x,y)&&pok) || menu_from_move_key?(x,y, pok)) &&
      tb_event_still?
  end
  #-----------------------------------------------------------------------------
  # * Check if the tb_event is moving or not
  #-----------------------------------------------------------------------------
  def tb_event_still?
    !@tb_event || !@tb_event.move_route_forcing
  end
  #-----------------------------------------------------------------------------
  # * Ok to show menu next time
  #-----------------------------------------------------------------------------
  def next_menu_ok_tb 
    @showing_temp_hls = false
    @menu_ok_tb = true
  end
  #-----------------------------------------------------------------------------
  # * Set tb event from an x y coordinate
  #-----------------------------------------------------------------------------
  def set_tb_event(x,y)
    turn_off_flash_tbe
    @tb_event = (map = $game_map).events[map.tbu_1st_xy(x,y)]
  end
  #-----------------------------------------------------------------------------
  # * Menu from Move Selection key ok?
  #---------------------------------------------------------------------------
  def menu_from_move_key?(x,y, prod_ok)
    !show_move_hls(x, y, DISPLAY_TB) && !TM.selecting? && !prod_ok && 
      !TM.selecting_target? && !@move_pos_selecting && check_no_unit?
  end
  #---------------------------------------------------------------------------
  # * Show main menu if no unit is selected
  #---------------------------------------------------------------------------
  def show_menu_if_no_tb(x,y)
    return false if !@menu_ok_tb
    @menu_ok_tb = false
    (e=(map=$game_map).events[map.tbu_1st_xy(x,y)]).nil? ? true : false
  end
  #---------------------------------------------------------------------------
  # * set tb event to a tb_unit or nil
  #---------------------------------------------------------------------------
  def check_make_tbe_nil(x=$game_player.x,y=$game_player.y)
    e=(map=$game_map).events[map.tbu_1st_xy(x,y)]
    turn_off_flash_tbe
    @tb_event = e if e.nil? || e.tb_unit.battler.nil?
    @tb_event
  end
  def check_no_unit?(x=$game_player.x,y=$game_player.y)
    e=(map=$game_map).events[map.tbu_1st_xy(x,y)]
    e.nil? || e.tb_unit.battler.nil?
  end
  #---------------------------------------------------------------------------
  # * Check to show commands
  #---------------------------------------------------------------------------
  def check_unit_to_show(x = $game_player.x, y = $game_player.y)
    show_tb_ev_coms(x,y)
  end
  #---------------------------------------------------------------------------
  # * Show Commands
  #---------------------------------------------------------------------------
  def show_tb_ev_coms(x,y)
    set_tb_event_xy(x,y)
    select_show_com_menu
  end
  #---------------------------------------------------------------------------
  # * Check if already moved max times
  #---------------------------------------------------------------------------
  def can_move?
    return false if @tb_event.nil?
    @tb_event.tb_unit.can_move?
  end
  #---------------------------------------------------------------------------
  # * On default keyboard 'X' button press
  #---------------------------------------------------------------------------
  def on_cancel_select
    @tb_item = nil
    $game_temp.tb_item = nil
    move_pos_off
  end
  #---------------------------------------------------------------------------
  # * Execution on any trigger
  #---------------------------------------------------------------------------
  def on_click
    @status_window_tb.hide
    $game_map.clear_next_highlights
    reset_aoe_follows
    #@spriteset.remove_group(DISPLAY_TB) # @spriteset.dispose_highlights_tb
    remove_show_hls
  end
  #---------------------------------------------------------------------------
  # * Remove display and aoe
  #---------------------------------------------------------------------------
  def remove_show_hls
    @spriteset.remove_group(DISPLAY_TB)
    @spriteset.remove_group(TB_AOE)
  end
  #---------------------------------------------------------------------------
  # * End Click
  #---------------------------------------------------------------------------
  def end_click
    move_pos_off 
    TM.set_selecting_target(false)
  end
  #---------------------------------------------------------------------------
  # * Move a Unit
  #---------------------------------------------------------------------------
  def move_unit_tb(x,y)
    valid_move_command?(x,y) ? unit_move_tb(x,y) : Sound.play_buzzer
    move_pos_off
    @showing_temp_hls = false
  end
  #---------------------------------------------------------------------------
  # * Show Com Menu
  #---------------------------------------------------------------------------
  def select_show_com_menu
    if @tb_event && @tb_event.tb_unit.is_friend? # check if is an actor for now later change to check if is a controllable unit
      @tb_command_window.set_tb_unit(@tb_unit = @tb_event.tb_unit)
      show_unit_hud
      show_com_menu 
    end
  end
  #---------------------------------------------------------------------------
  # * Set @tb_event based on params: x,y
  #---------------------------------------------------------------------------
  def set_tb_event_xy(x,y)
    @tb_event.flash_soft_tb = false unless !@tb_event
    id = (map=$game_map).tbu_id_xy(x, y)
    turn_off_flash_tbe
    @tb_event = map.events[id] # get the actual event
    @tb_event.flash_soft_tb = true if @tb_event
  end
  #---------------------------------------------------------------------------
  # * Processing when setting movement command
  #---------------------------------------------------------------------------
  def unit_move_tb(x,y)
    @tb_event.flash_soft_tb = false if @tb_event
    give_move_command(@tb_event)
    @tb_event.tb_unit.used_action(:move, @tb_event.tb_unit.move)
    @showing_temp_hls = false
  end
  #---------------------------------------------------------------------------
  # * Processing when turning off move_pos_selecting
  #---------------------------------------------------------------------------
  def move_pos_off
    @move_pos_selecting = false
    remove_show_hls
    # @spriteset.remove_group(DISPLAY_TB) # @spriteset.dispose_highlights_tb
  end
  #---------------------------------------------------------------------------
  # * Highlights which will follow cursor around, param array has points with
  #     relative locations
  #---------------------------------------------------------------------------
  def tb_hl_follow(rel_points)
    p = $game_player
    x, y = p.real_x, p.real_y
    
    return unless x != @tlx || y != @tly
    
    ok = !@tlx.nil? && !@tly.nil?
    @spriteset.remove_group(TB_AOE)
    rel_points.each{ |v| @spriteset.add_highlight_tb(x+v.x,y+v.y,nil,false,:attack_2, TB_AOE) } 
    @tlx, @tly = x, y
  end
  #---------------------------------------------------------------------------
  # * Enter into a trade with an adjacent unit
  #---------------------------------------------------------------------------
  def tb_enter_trade
    map, player = $game_map, $game_player
    v = Vertex.new(player.x, player.y)
    trading_with = map.events[map.tbu_id_xy(v.x,v.y)]
    tbe = @tb_event
    team = tbe.tb_unit.team
    oteam = trading_with.tb_unit.team unless trading_with.nil?
    return @selecting_tb_trade = nil unless !trading_with.nil? && team==oteam
    
    return @selecting_tb_trade=nil if @tb_event.nil? || tbe.x == v.x&&tbe.y == v.y
    
    SceneManager.call(Scene_TbTrade) if v.adjacent?(@selecting_tb_trade)
    SceneManager.scene.prepare(@tb_event.tb_unit)
    SceneManager.scene.prepare2(trading_with.tb_unit)
    
    @selecting_tb_trade = nil
  end
  #---------------------------------------------------------------------------
  # * Selecting the target of a skill
  #---------------------------------------------------------------------------
  def tbs_target_selection
    @tb_event.flash_soft_tb = false if @tb_event
    select_tb_unit($game_player.x, $game_player.y)
    @showing_temp_hls = false
  end
  #---------------------------------------------------------------------------
  # * Select Unit to target with an action
  #---------------------------------------------------------------------------
  def select_tb_unit(x,y)
    tm = TactBattleManager
    return tm.set_selecting_target(false) if !(@hl_att_points||={})[Vertex.new(x,y)]
    tbu = @tb_event.tb_unit
    is_skill = @tb_item.is_a?(RPG::Skill)
    b = @tb_event.tb_unit.battler
    tl = tbu.tb_actions[:targets]
    type = nil
    if is_skill && @tb_item.id == b.basic_atk_tb
      lmt = tbu.tb_actions[:atk]
      return end_select if !tbu.atk_ok? # lmt >= tbu.atk_action_lmt || tl >= tbu.target_tb_lmt
      type = :atk
    elsif is_skill
      lmt = tbu.tb_actions[:skill]
      return end_select if !tbu.skill_ok? # lmt >= tbu.skill_action_lmt || tl>=tbu.target_tb_lmt
      type = :skill
    else
      lmt = tbu.tb_actions[:item]; 
      return end_select if !tbu.item_ok? # lmt >= tbu.item_action_lmt || tl>=tbu.target_tb_lmt
      type = :item
    end
    
    map = $game_map 
    res, use = false, false
    dir = @tb_event.dir_to_sym_era
      
    if @tb_item.tb_aoe
      use = Era::AI.apply_aoe_item(x,y,@tb_item, @tb_event.id, dir)
    else
      use = Era::AI.apply_item(x,y,@tb_item, @tb_event.id, dir)
    end
    
    if use
      @tb_event.tb_unit.use_item(@tb_item)
      tbu.used_action(type,1)
      tbu.lose_item(@tb_item, 1)
    end
    reset_aoe_follows
    # @spriteset.remove_group(DISPLAY_TB) # @spriteset.dispose_highlights_tb      # for now remove all highlights
    remove_show_hls
    end_select
  end
  #---------------------------------------------------------------------------
  # * End Select
  #---------------------------------------------------------------------------
  def end_select
    TactBattleManager.set_selecting_target(false)
    @showing_temp_hls = false # no longer showing move/skill highlights
  end
  #---------------------------------------------------------------------------
  # * Reset Aoe Highlights
  #---------------------------------------------------------------------------
  def reset_aoe_follows
    @tlx, @tly = nil, nil
  end
  #---------------------------------------------------------------------------
  # * Passing the skill that needs to be used from Scene_UnitSkill
  #---------------------------------------------------------------------------
  def set_item_tb(item)
    @tb_item = item
  end
  #---------------------------------------------------------------------------
  # * Is a Valid Move Command?
  #---------------------------------------------------------------------------
  def valid_move_command?(x,y)
    @tb_event && @tb_event.tb_unit.tb_valid_move?(x,y) && $game_map.tbu_id_xy(x,y) == 0
  end
  #---------------------------------------------------------------------------
  # * Execute movement command
  #---------------------------------------------------------------------------
  def give_move_command(event, fx = $game_player.x, fy = $game_player.y, path_set = false)
    return unless event
    x,y = event.x, event.y
    remove_show_hls
    # @spriteset.remove_group(DISPLAY_TB) # @spriteset.dispose_highlights_tb
    event.save_list_tb # save old commands before resetting + giving move commands
    event.list = []
    event.list.push(RPG::EventCommand.new(355,0,["execute_dynamic_route(#{fx}, #{fy})"]))
    event.list.push(RPG::EventCommand.new(0,0,[]))
    $game_player.start_map_event_prox(event.id, [0,1,2], true) # from here next time
    remove_show_hls
    # @spriteset.remove_group(DISPLAY_TB) # @spriteset.dispose_highlights_tb # for now, until hash is implemented with hls
                                     # to organize removing
  end
  #---------------------------------------------------------------------------
  # * Movement command selected
  #---------------------------------------------------------------------------
  def command_move_unit
    amt = @tb_unit.tb_actions[:move]
    tbu = @tb_unit
    b = tbu.battler
    if amt >= b.move_range_tb && amt/tbu.spec_edges[:move] >= tbu.move_action_lmt
        
      Sound.play_buzzer
      return @tb_command_window.activate
    end
      
    @move_pos_selecting = true if can_move?
    x,y = $game_player.x, $game_player.y
    show_move_range_tb(x,y)# , :def)# , @tb_unit_range)
    
    exit_command_select
    @tb_event.flash_soft_tb = true
  end
  #---------------------------------------------------------------------------
  # * Show the highlights for unit at location x,y and add those positions
  #     to its valid moves.
  #---------------------------------------------------------------------------
  def show_move_range_tb(x,y, hloc = :def)
    e = Era::AI.show_move_range_tb(x, y, hloc)
    turn_off_flash_tbe
    can_move = e && e.tb_unit.is_friend? && (@tb_event = e) && can_move?
    @move_pos_selecting = true if can_move
  end
  #---------------------------------------------------------------------------
  # * currently no support for color, will place highlights representing an
  #     attacked location on map.
  #---------------------------------------------------------------------------
  def add_hl_store_att(locs, opts={})
    @hl_att_points = {}
    options = {:offx=>0,:offy=>0,:hloc=>DISPLAY_TB, :meth=>:default_attack,
              :opacity=>Era::Fade.opacity}.merge(opts)
    offx, offy = options[:offx], options[:offy]
    hloc, meth = options[:hloc], options[:meth]
    opacity = options[:opacity]
    locs.each do |loc| 
      x,y = loc.x + offx,loc.y + offy
      @spriteset.add_highlight(:x=>x,:y=>y,:sym=>meth,:hloc=>hloc, :opacity=>opacity) 
      @hl_att_points[Vertex.new(x,y)] = 1
    end
  end
  #---------------------------------------------------------------------------
  # * command_turn_unit_dir
  #---------------------------------------------------------------------------
  def command_turn_unit_dir
    return unless @tb_event
    @turn_window_tb.show
    @turn_window_tb.activate
  end
  #---------------------------------------------------------------------------
  # * Directional Modification
  #---------------------------------------------------------------------------
  def turn_up; tb_turn_dir(8); end
  def turn_right; tb_turn_dir(6); end
  def turn_left; tb_turn_dir(4); end
  def turn_down; tb_turn_dir(2); end
    
  #---------------------------------------------------------------------------
  # * Direction Turn
  #---------------------------------------------------------------------------
  def tb_turn_dir(d)
    @tb_event.direction = d
    @tb_event.update
    hide_turn_dir_window
    @tb_command_window.activate
  end
  #---------------------------------------------------------------------------
  # * Show tactical battle command window for units
  #---------------------------------------------------------------------------
  def show_tb_command_window_tb
    remove_show_hls
    # @spriteset.remove_group(DISPLAY_TB) # @spriteset.dispose_highlights_tb # Erase any highlights currently being shown
    @tb_command_window.show
    @tb_command_window.activate
  end
  #---------------------------------------------------------------------------
  # * Hide command window
  #---------------------------------------------------------------------------
  def hide_tb_command_window_tb
    @tb_command_window.hide
    @tb_command_window.deactivate
  end
  #---------------------------------------------------------------------------
  # * Unit Hud
  #---------------------------------------------------------------------------
  def show_unit_hud(event = @tb_event)
    return if event == @displayed_event
    return hide_unit_hud if event.nil?
    return unless (tb_unit = event.tb_unit) && (battler = tb_unit.battler)
    @displayed_event = event
    @unit_window.draw_contents(battler, true, event)
    @unit_window.show
  end
  #---------------------------------------------------------------------------
  # * Hide Unit Hud
  #---------------------------------------------------------------------------
  def hide_unit_hud
    @displayed_event = nil
    @unit_window.hide
  end
  #---------------------------------------------------------------------------
  # * hide_turn_dir_window
  #---------------------------------------------------------------------------
  def hide_turn_dir_window
    @turn_window_tb.hide
    @turn_window_tb.deactivate
  end
  #---------------------------------------------------------------------------
  # * Start up command window
  #---------------------------------------------------------------------------
  def show_com_menu
    TactBattleManager.selecting(true)
    show_tb_command_window_tb
  end
  #---------------------------------------------------------------------------
  # * Create Command Window
  #---------------------------------------------------------------------------
  def create_tb_command_window_tb
    @tb_command_window = Window_UnitCommandTB.new(4,15)
    @tb_command_window.index = 0
    @tb_command_window.set_handler(:status,    method(:command_status))
    @tb_command_window.set_handler(:item,      method(:command_item))
    @tb_command_window.set_handler(:move,      method(:command_move_unit))
    @tb_command_window.set_handler(:attack,      method(:command_unit_attack))
    @tb_command_window.set_handler(:skill,     method(:command_unit_skill))
    @tb_command_window.set_handler(:cancel,    method(:exit_command_select))
    @tb_command_window.set_handler(:turn,      method(:command_turn_unit_dir))
    @tb_command_window.set_handler(:trade,     method(:command_tb_trade_with))
    @tb_command_window.set_handler(:wait,      method(:command_wait_tb))
    @tb_command_window.set_handler(:equip,     method(:command_equip))
    @tb_command_window.hide
    @tb_command_window.deactivate
  end
  def command_equip
    SceneManager.call(Scene_TBunitEquip)
    SceneManager.scene.tb_event=@tb_event
    @tb_command_window.deactivate
  end
  def create_status_window_tb
    @status_window_tb = Window_UnitStats.new(0,0,200,350)
    @status_window_tb.hide
  end
  #--------------------------------------------------------------------------
  # * create_unit_turn_dir_window_tb
  #--------------------------------------------------------------------------
  def create_unit_turn_dir_window_tb
    @turn_window_tb = Window_UnitDirectionTB.new
    @turn_window_tb.set_handler(:up, method(:turn_up))
    @turn_window_tb.set_handler(:right, method(:turn_right))
    @turn_window_tb.set_handler(:left, method(:turn_left))
    @turn_window_tb.set_handler(:down, method(:turn_down))
    @turn_window_tb.set_handler(:cancel, method(:on_turn_cancel_tb))
    
    @turn_window_tb.deactivate
    @turn_window_tb.hide
  end
  #--------------------------------------------------------------------------
  # * Create Unit Hud
  #--------------------------------------------------------------------------  
  def create_unit_hud
    x,y = TactBattleManager::HudDisplay::X_Left, TactBattleManager::HudDisplay::Y_Left
    @unit_window = Window_UnitHud.new(x,y,187,85)
    @unit_window.hide
  end
  #--------------------------------------------------------------------------
  # * command_status
  #--------------------------------------------------------------------------  
  def command_status
    @showing_status = true
    @status_window_tb.tb_event = @tb_event
    @tb_command_window.deactivate
    @status_window_tb.show
  end
  #--------------------------------------------------------------------------
  # * Command unit attack
  #--------------------------------------------------------------------------
  def command_unit_attack
    id = @tb_event.tb_unit.battler.basic_atk_tb
    set_up_use_skill(nil, @tb_event, id)
    @tb_item = $data_skills[id]
    TactBattleManager.set_selecting_target(true)
    exit_command_select
  end
  #--------------------------------------------------------------------------
  # * command_unit_skill
  #--------------------------------------------------------------------------
  def command_unit_skill
    SceneManager.call(Scene_UnitSkill)
    SceneManager.scene.prepare(@tb_event.tb_unit)
  end
  #--------------------------------------------------------------------------
  # * Item Command
  #---------------------------------------------------------------------------
  def command_item
    SceneManager.call(Scene_UnitItem) 
    SceneManager.scene.prepare(@tb_event.tb_unit)
  end
  #---------------------------------------------------------------------------
  # * Command Wait
  #---------------------------------------------------------------------------
  def command_wait_tb
    @tb_event.tb_unit.tb_state = :wait
    @tb_event.waiting_tb = true
    @tb_event.tb_unit.tb_actions[:all] = 2147483647
    exit_command_select
  end
  #---------------------------------------------------------------------------
  # * Command Trade
  #---------------------------------------------------------------------------
  def command_tb_trade_with
    @tb_command_window.hide
    player = $game_player
    tb_highlight_adjacent_pos(player.x,player.y) # highlight adjacent locations
    @selecting_tb_trade = Vertex.new(player.x, player.y)
    exit_command_select
  end
  #---------------------------------------------------------------------------
  # * Highlight positions adjacent to x,y
  #---------------------------------------------------------------------------
  def tb_highlight_adjacent_pos(x,y)
    @spriteset.remove_group(DISPLAY_TB)
    @spriteset.add_highlight(:x=>x,:y=>y+1, :hloc=>DISPLAY_TB)
    @spriteset.add_highlight(:x=>x,:y=>y-1, :hloc=>DISPLAY_TB)
    @spriteset.add_highlight(:x=>x+1,:y=>y, :hloc=>DISPLAY_TB)
    @spriteset.add_highlight(:x=>x-1,:y=>y, :hloc=>DISPLAY_TB)
  end
  #---------------------------------------------------------------------------
  # * Turn cancel
  #---------------------------------------------------------------------------
  def on_turn_cancel_tb
    @turn_window_tb.deactivate
    @turn_window_tb.hide
    @tb_command_window.activate
  end
  #---------------------------------------------------------------------------
  # * Exit Command Selection - called when finished choosing a unit command
  #---------------------------------------------------------------------------
  def exit_command_select
    hide_turn_dir_window
    hide_tb_command_window_tb
    hide_unit_hud
    @tb_event.flash_soft_tb = false unless !@tb_event
    TactBattleManager.selecting(false)
  end
  #---------------------------------------------------------------------------
  # * Clean Up TB
  #---------------------------------------------------------------------------
  def clean_up_tb
    $game_temp.tb_event = @tb_event
    @move_pos_selecting = false
    @event_waiting_for = 0
    @tb_ev_respond_id = 0
    @safety_tb = 0
    @skill_disp_win.hide
    @spriteset.dispose_highlights_tb
    reset_aoe_follows
    hide_help_window_tb
    TactBattleManager.selecting(false)
    TactBattleManager.set_selecting_target(false)
    TactBattleManager.finished_cleaning
  end # clean_up_tb
end # Scene_Map

#==============================================================================
# * Scene_TBunitEquip
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Equipment scene during a tactical battle
#==============================================================================
class Scene_TBunitEquip < Scene_Equip
  #---------------------------------------------------------------------------
  # * Start
  #---------------------------------------------------------------------------
  def start
    @real_actor = @actor
    super
    @item_window.actor = @real_actor
    @slot_window.actor = @real_actor
    @status_window.actor = @real_actor
    @actor = @real_actor
  end
  #--------------------------------------------------------------------------
  # * Set Tactical Battle Event
  #--------------------------------------------------------------------------
  def tb_event=(e)
    @tb_event = e
    @actor = @tb_event.tb_unit.battler
  end
  #--------------------------------------------------------------------------
  # * Create Item Window
  #--------------------------------------------------------------------------
  def create_item_window
    wx = 0
    wy = @slot_window.y + @slot_window.height
    ww = Graphics.width
    wh = Graphics.height - wy
    @item_window = Window_TBunitEquipItem.new(wx, wy, ww, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.status_window = @status_window
    @item_window.actor = @actor
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @slot_window.item_window = @item_window
    @item_window.event=@tb_event
  end
  #--------------------------------------------------------------------------
  # * Switch to Next Actor
  #--------------------------------------------------------------------------
  def next_actor
    @actor
  end
  #--------------------------------------------------------------------------
  # * Switch to Previous Actor
  #--------------------------------------------------------------------------
  def prev_actor
    @actor
  end
  #----------------------------------------------------------------------------
  # * Command Clear
  #----------------------------------------------------------------------------
  def command_clear
    Sound.play_equip
    @actor.clear_equipments
    @status_window.refresh
    @slot_window.refresh
    @command_window.activate
  end
end # Scene_TBunitEquip

#==============================================================================
# ** Game_System
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#    Saving and loading state of tactical battle
#==============================================================================
class Game_System
  attr_reader :tb_state
  #----------------------------------------------------------------------------
  # * Store tactical battle data for saving
  #----------------------------------------------------------------------------
  def save_tb_data
    @tb_state = TB_DataSave.new
  end
  #----------------------------------------------------------------------------
  # * Load tacitcal battle
  #----------------------------------------------------------------------------
  def load_tb_data
    return if @tb_state.nil? 
    @tb_state.load_tb
  end
  #----------------------------------------------------------------------------
  # * Alias, on_after_load load saved data for the tactical battle
  #----------------------------------------------------------------------------
  alias on_after_load_tb_era on_after_load
  def on_after_load
    on_after_load_tb_era
    load_tb_data
  end
end # Game_System

#==============================================================================
# ** Scene_TbPartyPlacement
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#       Allows party to be placed at the beginning of a tactical battle. Also
#       supports distributing items to different party members from the game
#       party's inventory. (not implemented yet)
#==============================================================================
class Scene_TbPartyPlacement < Scene_Base
  TM = TactBattleManager
  MinOne = TM::Defaults::OnePartyMemb
  MinAll = TM::Defaults::AllPartyMembs
  
  WIDTH = 300
  @@place_count = 0
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_background
    create_production_menu
    create_placement_commands
    create_unit_list_itm_orgn
    create_basic_txt
    create_unit_item_list
    create_category_window
    create_item_window
    create_select_txt
    create_select_party_or_unit_win
    create_unit_category_list
    orient_windows
  end
  #--------------------------------------------------------------------------
  # * Orient Windows
  #--------------------------------------------------------------------------
  def orient_windows
    @category_window.x = @item_window.x
    @category_window.y = @item_window.y - @category_window.height
    @unit_list_swap_items.y= @basic_text_win.y + @basic_text_win.height
    @select_text_win.x = @item_window.x
    @select_text_win.y = @category_window.y - @select_text_win.height
    @party_or_unit_win.x = @item_window.x
    @party_or_unit_win.y = @category_window.y
    @unit_item_list.y = @item_window.y
    @unit_category_list.y = @category_window.y
    @unit_item_list.x = Graphics.width/2 - @unit_item_list.width/2
    @unit_category_list.x = @unit_item_list.x
    @item_window.height = @unit_item_list.height
    @unit_category_list.item_window = @unit_item_list
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_background
  end
  #--------------------------------------------------------------------------
  # * Create Production Menu
  #--------------------------------------------------------------------------
  def create_production_menu
    @production_menu = Window_TbUnitProduction.new(0,0)
    @production_menu.set_production(@syms)
    @production_menu.viewport = @viewport
    @production_menu.set_handler(:cancel, method(:on_cancel))
    @production_menu.set_handler(:put, method(:produce_unit))
    @production_menu.deactivate
    @production_menu.hide
  end
  #--------------------------------------------------------------------------
  # * Placement Command Window
  #--------------------------------------------------------------------------
  def create_placement_commands
    @place_coms = Window_PlacementOpts.new(Graphics.width/2,Graphics.height/2)
    @place_coms.x = Graphics.width/2 - @place_coms.width/2
    @place_coms.y =  Graphics.height/2 - @place_coms.height/2
    @place_coms.viewport = @viewport
    @place_coms.set_handler(:select, method(:command_select_units))
    @place_coms.set_handler(:cancel, method(:on_cancel))
    @place_coms.set_handler(:items,  method(:organize_items))
    @place_coms.set_handler(:confirm, method(:confirm_placement))
    @place_coms.activate
  end
  #--------------------------------------------------------------------------
  # * Create Background
  #--------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
  end
  #--------------------------------------------------------------------------
  # * Create Unit list for item organization
  #--------------------------------------------------------------------------
  def create_unit_list_itm_orgn
    @unit_list_swap_items = Window_UnitsItemOrganization.new(10,50,180,200)
    @unit_list_swap_items.set_handler(:cancel, method(:on_uio_cancel))
    @unit_list_swap_items.set_handler(:ok, method(:on_uio_ok))
    @unit_list_swap_items.deactivate
    @unit_list_swap_items.hide
  end
  #--------------------------------------------------------------------------
  # * Create Basic Text
  #--------------------------------------------------------------------------
  def create_basic_txt
    @basic_text_win = Window_BasicTextTB.new(10,10,180,49)
    @basic_text_win.text = "Organize Items"
    @basic_text_win.hide
  end
  #--------------------------------------------------------------------------
  # * create_select_txt
  #--------------------------------------------------------------------------
  def create_select_txt
    @select_text_win = Window_BasicTextTB.new(0,0,WIDTH,46)
    @select_text_win.hide
  end
  #--------------------------------------------------------------------------
  # * create_category_window
  #--------------------------------------------------------------------------
  def create_category_window
    @category_window = Window_UnitItemCatOrganization.new
    @category_window.viewport = @viewport
    @category_window.y = 100
    @category_window.width = 300
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:on_category_cancel))
    @category_window.deactivate
    @category_window.hide
  end
  #--------------------------------------------------------------------------
  # * Create Item Window
  #--------------------------------------------------------------------------
  def create_item_window
    wy = @category_window.y + @category_window.height
    wh = Graphics.height - wy
    wx = Graphics.width/2 - WIDTH/2
    @item_window = Window_UnitItemOrganizationList.new(wx, wy, WIDTH, wh)
    @item_window.viewport = @viewport
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @category_window.item_window = @item_window
    @item_window.deactivate
    @item_window.hide
  end
  #--------------------------------------------------------------------------
  # * Category party inv or units inv
  #--------------------------------------------------------------------------
  def create_select_party_or_unit_win
    @party_or_unit_win = Window_UnitPartyChoice.new(0,0)
    @party_or_unit_win.set_handler(:unit,     method(:on_unit_ok))
    @party_or_unit_win.set_handler(:party,     method(:on_pou_ok))
    @party_or_unit_win.set_handler(:cancel, method(:on_pou_cancel))
    @party_or_unit_win.viewport = @viewport
    @party_or_unit_win.deactivate
    @party_or_unit_win.hide
  end
  #----------------------------------------------------------------------------
  # * Create Unit Item List
  #----------------------------------------------------------------------------
  def create_unit_item_list
    @unit_item_list = Window_UILsub.new(50,50,WIDTH,200)
    @unit_item_list.set_handler(:ok,  method(:unit_item_ok))
    @unit_item_list.set_handler(:cancel,  method(:unit_item_cancel))
    @unit_item_list.deactivate
    @unit_item_list.hide
  end
  #----------------------------------------------------------------------------
  # * Create Unit Category List
  #----------------------------------------------------------------------------
  def create_unit_category_list
    @unit_category_list = Window_UICsub.new
    @unit_category_list.set_handler(:ok,     method(:on_ucategory_ok))
    @unit_category_list.set_handler(:cancel, method(:on_ucategory_cancel))
    @unit_category_list.set_width(WIDTH)
    @unit_category_list.deactivate
    @unit_category_list.hide
  end
  #--------------------------------------------------------------------------
  # * Free Background
  #--------------------------------------------------------------------------
  def dispose_background
    @background_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Give list of units 
  #     param: sym is a symbol specified in Era::TBUnit.Constructable
  #     The default sym to specfiy that party members should be used is:
  #       :$game_party
  #--------------------------------------------------------------------------
  def prepare(syms)
    @syms = syms
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    @production_menu.set_production(@syms)
  end
  #--------------------------------------------------------------------------
  # * command_select_units
  #--------------------------------------------------------------------------
  def command_select_units
    @production_menu.activate
    @production_menu.show
    @place_coms.hide
    @place_coms.deactivate
  end
  #--------------------------------------------------------------------------
  # * On Ok
  #--------------------------------------------------------------------------
  def on_ok
  end
  #--------------------------------------------------------------------------
  # * On Ok
  #--------------------------------------------------------------------------
  def on_cancel
    exit_still_pp
  end
  #--------------------------------------------------------------------------
  # * Produce Unit
  #--------------------------------------------------------------------------
  def produce_unit
    p = $game_player; x,y = p.x,p.y
    TactBattleManager.queue_unit(unit_name, TactBattleManager::PLAYER,x,y) 
    fast_start? ? confirm_placement : exit_still_pp
  end
  #----------------------------------------------------------------------------
  # * Fast Start
  #----------------------------------------------------------------------------
  def fast_start?
    (@@place_count+=1) == $game_party.members.size && TM::Defaults::StartQuick
  end
  #--------------------------------------------------------------------------
  # * Exit Still Placing party
  #--------------------------------------------------------------------------
  def exit_still_pp
    TactBattleManager.placing_party = true # party placement highlights
    return_scene
  end
  #--------------------------------------------------------------------------
  # * Name of the currently selected unit
  #--------------------------------------------------------------------------
  def unit_name
    @production_menu.unit_name
  end
  #--------------------------------------------------------------------------
  # * Confirm Placement
  #     Finished placing the party on the map.
  #--------------------------------------------------------------------------
  def confirm_placement
    return @place_coms.activate && buz if @@place_count < 1 && min_one
    size = $game_party.members.size
    return @place_coms.activate && buz if @@place_count < size && MinAll
    @@place_count = 0
    TactBattleManager.first_turn if !TactBattleManager.party_on_map # 1st units
    TactBattleManager.clear_valid_pos
    return_scene
  end
  #--------------------------------------------------------------------------
  # * Minimum of one party member has been placed on the map or all of the 
  #     party members are already on the map
  #--------------------------------------------------------------------------
  def min_one
    MinOne && !TactBattleManager.all_party_events_on_map
  end
  #--------------------------------------------------------------------------
  # * All party members have events on the map
  #--------------------------------------------------------------------------
  def min_all
    MinAll || TactBattleManager.all_party_events_on_map
  end
  #--------------------------------------------------------------------------
  # * Shorter method call efficiency not as important here
  #--------------------------------------------------------------------------
  def buz; Sound.play_buzzer; end
  #--------------------------------------------------------------------------
  # * Redistribute the current Game_Party's inventory to individual members
  #--------------------------------------------------------------------------
  def organize_items
    # just hash actor ids -> item containers -> item ids and store it
    # in the tactical battle manager. When bringing up this scene, display
    # previously organized items to the player by consulting the hash.
    # Then when a tactical unit is loaded all it just looks at the hash
    # in the TBM module and loads its items from there. 
    # Make a note of this, in addition to the equipment problem when detailing 
    # why no more than one Game_Actor should be able to be produced as a 
    # produceable unite
    
    @unit_list_swap_items.show
    @unit_list_swap_items.select(0)
    deactivate_all_but(@unit_list_swap_items)
    @unit_list_swap_items.activate
    @unit_list_swap_items.refresh
    @basic_text_win.show
    @place_coms.hide
  end
  #--------------------------------------------------------------------------
  # * Unit Item Organization Cancel
  #--------------------------------------------------------------------------
  def on_uio_cancel
    @unit_list_swap_items.hide
    @basic_text_win.hide
    deactivate_all_but(@place_coms)
    @place_coms.activate
    @place_coms.show
  end
  #--------------------------------------------------------------------------
  # * Select unit to give items to
  #--------------------------------------------------------------------------
  def on_uio_ok
    @actor = @unit_list_swap_items.actor
    @party_or_unit_win.show
    deactivate_all_but(@party_or_unit_win)
    @party_or_unit_win.activate
    @party_or_unit_win.select(0)
    tbu = (e=TM.unit_on_map?(@actor.name)) ? e.tb_unit : Tactical_Unit.new
    TactBattleManager.init_tbu_items(@actor, tbu)
    @unit_item_list.set_tb_unit(tbu)
    @unit_item_list.refresh
  end
  #--------------------------------------------------------------------------
  # * Category [OK]
  #--------------------------------------------------------------------------
  def on_category_ok
    deactivate_all_but(@item_window)
    @item_window.activate
    @item_window.select_last
  end
  #--------------------------------------------------------------------------
  # * Category Cancel
  #--------------------------------------------------------------------------
  def on_category_cancel
    @category_window.hide
    @item_window.hide
    @party_or_unit_win.show
    deactivate_all_but(@party_or_unit_win)
    @party_or_unit_win.activate
    @select_text_win.hide
  end
  #----------------------------------------------------------------------------
  # * Give the item to the tb_unit
  #----------------------------------------------------------------------------
  def on_item_ok
    return back_to_items if (item = @item_window.item).nil?
    $game_party.lose_item(item, 1)
    @unit_item_list.tb_unit.gain_item(item, 1)
    TactBattleManager.store_unit_item(@actor.id, item)
    back_to_items
  end
  #----------------------------------------------------------------------------
  # * Back to Items
  #----------------------------------------------------------------------------
  def back_to_items
    refresh_items
    @item_window.activate
  end
  #----------------------------------------------------------------------------
  # * Refresh Items
  #----------------------------------------------------------------------------
  def refresh_items
    @unit_item_list.refresh
    @item_window.refresh
  end
  #----------------------------------------------------------------------------
  # * Unit Item seleection ok
  #     Place the item in the party's inventory
  #----------------------------------------------------------------------------
  def unit_item_ok
    return refresh_items if @unit_item_list.tb_unit.nil?
    @unit_item_list.activate
    return if (item = @unit_item_list.item).nil?
    @unit_item_list.tb_unit.lose_item(item, 1) 
    TactBattleManager.rm_unit_item(@actor.id, item)
    $game_party.gain_item(item, 1)
    refresh_items
  end
  #----------------------------------------------------------------------------
  # * On Item Cancel
  #----------------------------------------------------------------------------
  def on_item_cancel
    @item_window.unselect
    deactivate_all_but(@category_window)
    @category_window.activate
  end
  #----------------------------------------------------------------------------
  # * party or unit ok
  #----------------------------------------------------------------------------
  def on_pou_ok
    @party_or_unit_win.hide
    @select_text_win.text = "Select the items to give to #{@actor.name}"
    @select_text_win.show
    @category_window.show
    deactivate_all_but(@category_window)
    @category_window.activate
    @item_window.show
  end
  #----------------------------------------------------------------------------
  # * Unit Item Cancel
  #----------------------------------------------------------------------------
  def unit_item_cancel
    deactivate_all_but(@unit_category_list)
    @unit_category_list.activate
  end
  #----------------------------------------------------------------------------
  #  * Unit ok, party unit item organization
  #----------------------------------------------------------------------------
  def on_unit_ok
    @select_text_win.text="Choose items to take from #{@actor.name}"
    @select_text_win.show
    @unit_item_list.show
    @unit_category_list.show
    deactivate_all_but(@unit_category_list)
    @unit_category_list.activate
    @party_or_unit_win.hide
  end
  #----------------------------------------------------------------------------
  # * On Party or Unit Cancel
  #----------------------------------------------------------------------------
  def on_pou_cancel
    @unit_list_swap_items.show
    @unit_list_swap_items.select(0)
    deactivate_all_but(@unit_list_swap_items)
    @unit_list_swap_items.activate
    @unit_list_swap_items.refresh
    @basic_text_win.show
    @party_or_unit_win.hide
  end
  #----------------------------------------------------------------------------
  # * On category ok
  #----------------------------------------------------------------------------
  def on_ucategory_ok
    deactivate_all_but(@unit_item_list)
    @unit_item_list.activate
    @unit_item_list.select_last
  end
  #----------------------------------------------------------------------------
  # * On category cancel
  #----------------------------------------------------------------------------
  def on_ucategory_cancel
    @select_text_win.hide
    @unit_category_list.hide
    @unit_item_list.hide
    deactivate_all_but(@party_or_unit_win)
    @party_or_unit_win.activate
    @party_or_unit_win.show
  end
  #----------------------------------------------------------------------------
  # * Deactivate all but
  #----------------------------------------------------------------------------
  def deactivate_all_but(win)
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      next if ivar == win
      ivar.deactivate if ivar.is_a?(Window_Selectable)
    end
  end
end # Scene_TbPartyPlacement

#==============================================================================
# ** Scene_UnitProduction
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#      Scene for producing a unit
#==============================================================================
class Scene_UnitProduction < Scene_TbPartyPlacement
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_background
    create_production_menu
    create_placement_commands
    create_gold_window
    create_cost_window
    create_text_window
    create_unit_data_window
    orient_windows_sub
  end
  #--------------------------------------------------------------------------
  # * Orient Windows Sub 
  #--------------------------------------------------------------------------
  def orient_windows_sub
    
    @production_menu.width = 168
    @unit_data_win.x = Graphics.width/2 - @unit_data_win.width/2
    
    @production_menu.y = Graphics.height/2 - @production_menu.height/2
    @production_menu.x = @unit_data_win.x-@production_menu.width
   
    @production_title.width = @gold_window.width
    @cost_window.x = @gold_window.x = @unit_data_win.width+@unit_data_win.x
    @cost_window.y = @production_menu.y + @production_menu.height - @cost_window.height# @gold_window.height + @gold_window.y
    @cost_window.width = @gold_window.width
    @gold_window.y = @cost_window.y - @gold_window.height 
    
    @production_title.x = @unit_data_win.x
    @unit_data_win.y = @production_menu.height + @production_menu.y - @unit_data_win.height
    @production_title.y = @unit_data_win.y - @production_title.height
    @cost_window.set_production(@production_menu)
    @unit_data_win.production_menu = @production_menu
    
    @cost_window.show
    @gold_window.show
    @production_title.show
    @unit_data_win.show
    @production_menu.show
    @production_menu.activate
  end
  #--------------------------------------------------------------------------
  # * Create Cost Window
  #--------------------------------------------------------------------------
  def create_cost_window
    @cost_window = Window_TBProductionCost.new(0,0,160,105)
    @cost_window.hide
  end
  #--------------------------------------------------------------------------
  # * Create Gold Window
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.hide
  end
  #--------------------------------------------------------------------------
  # * Create Text Window
  #--------------------------------------------------------------------------
  def create_text_window
    @production_title = Window_BasicTextTB.new(0,0,150,46)
    @production_title.text = "Unit Production"
    @production_title.hide
  end
  #--------------------------------------------------------------------------
  # * Create Production Menu
  #--------------------------------------------------------------------------
  def create_production_menu
    @production_menu = Window_TbUnitProduction.new(0,0)
    @production_menu.set_production(@syms)
    @production_menu.viewport = @viewport
    @production_menu.set_handler(:cancel, method(:on_cancel))
    @production_menu.set_handler(:put, method(:produce_unit))
    @production_menu.hide
  end
  #--------------------------------------------------------------------------
  # * Create Unit Data Window
  #--------------------------------------------------------------------------
  def create_unit_data_window
    @unit_data_win = Window_TBUnitData.new(0,0,160,195)
    @unit_data_win.hide
  end
  #--------------------------------------------------------------------------
  # * Placement Command Window
  #--------------------------------------------------------------------------
  def create_placement_commands
  end
  #--------------------------------------------------------------------------
  # * Create Background
  #--------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
  end
  #--------------------------------------------------------------------------
  # * Free Background
  #--------------------------------------------------------------------------
  def dispose_background
    @background_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Give list of units 
  #     param: sym is a symbol specified in Era::TBUnit.Constructable
  #     The default sym to specfiy that party members should be used is:
  #       :$game_party
  #--------------------------------------------------------------------------
  def prepare(syms)
    @syms = syms
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
  end
  #--------------------------------------------------------------------------
  # * command_select_units
  #--------------------------------------------------------------------------
  def command_select_units
    @production_menu.activate
    @production_menu.show
  end
  #--------------------------------------------------------------------------
  # * On Ok
  #--------------------------------------------------------------------------
  def on_ok
  end
  #--------------------------------------------------------------------------
  # * On Ok
  #--------------------------------------------------------------------------
  def on_cancel
    TactBattleManager.clear_valid_pos
    SceneManager.return
  end
  #--------------------------------------------------------------------------
  # * Produce Unit
  #--------------------------------------------------------------------------
  def produce_unit(opts = {})
    oh = {:wait => true}.merge(opts)
    p = $game_player; x,y = p.x,p.y
    Era::TBUnit.pay_cost(unit_name) # pay cost from party's items/currency
    TactBattleManager.queue_unit(unit_name, TactBattleManager::PLAYER,x,y,oh) 
    SceneManager.return
  end
  #--------------------------------------------------------------------------
  # * Exit Still Placing party
  #--------------------------------------------------------------------------
  def exit_still_pp
  end
  #--------------------------------------------------------------------------
  # * Name of the currently selected unit
  #--------------------------------------------------------------------------
  def unit_name
    @production_menu.unit_name
  end
  #--------------------------------------------------------------------------
  # * Confirm Placement
  #     Finished placing the party on the map.
  #--------------------------------------------------------------------------
  def confirm_placement
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_background
  end
end # Scene_UnitProduction

#==============================================================================
# ** Scene_UnitSkill
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#      Make sure skills don't show up if they aren't usable
#==============================================================================
class Scene_UnitSkill < Scene_ItemBase
  attr_accessor :active
  attr_reader :tb_battler
  #----------------------------------------------------------------------------
  # * Create Background
  #----------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
  end
  #----------------------------------------------------------------------------
  # * Start
  #----------------------------------------------------------------------------
  def start
    super    
    create_skill_window_tb
    create_skill_type_window_tb
    set_windows_unit
    create_range_win
    orient_windows
  end
  #--------------------------------------------------------------------------
  # * Orient Windows
  #--------------------------------------------------------------------------
  def orient_windows
    @item_window.width = @skill_type_window.x+@skill_type_window.width
    @item_window.x = @item_window.width
    @item_window.width = @win_range.x - @item_window.width
  end
  #--------------------------------------------------------------------------
  # * set_windows_unit
  #--------------------------------------------------------------------------
  def set_windows_unit
    @item_window.battler = @tb_battler
    @skill_type_window.skill_window = @item_window
    @item_window.skill_type_window = @skill_type_window
  end
  #--------------------------------------------------------------------------
  # * Create range window
  #--------------------------------------------------------------------------
  def create_range_win
    x = @item_window.x+@item_window.width
    @win_range = Window_ShowRange.new(x,0,150,150)
    @win_range.give_skill_window(@item_window)
    @win_range.set_scene(self)
  end
  #--------------------------------------------------------------------------
  # * create_skill_window_tb
  #--------------------------------------------------------------------------
  def create_skill_window_tb
    @item_window = Window_BattlerSkills.new(200,0,150,200)
    @item_window.viewport = @viewport
    @item_window.set_handler(:ok,       method(:on_item_ok))
    @item_window.set_handler(:cancel,   method(:on_item_cancel))
  end
  #--------------------------------------------------------------------------
  # * create_skill_type_window_tb
  #--------------------------------------------------------------------------
  def create_skill_type_window_tb
    @skill_type_window = Window_SkillTypes.new(0,0)
    @skill_type_window.viewport = @viewport
    @skill_type_window.set_handler(:skill,     method(:stype_ok))
    @skill_type_window.set_handler(:cancel,     method(:stype_cancel))
  end
  #--------------------------------------------------------------------------
  # * Prepare with a tb_unit
  #--------------------------------------------------------------------------
  def prepare(unit)
    @tb_battler = unit.battler
  end
  #--------------------------------------------------------------------------
  # * on_item_ok
  #--------------------------------------------------------------------------
  def on_item_ok
    return on_item_cancel if item.nil?
    use_item
  end
  #--------------------------------------------------------------------------
  # * User
  #--------------------------------------------------------------------------
  def user
    @tb_battler                # correct actor for super class
  end
  #--------------------------------------------------------------------------
  # * on_item_cancel
  #--------------------------------------------------------------------------
  def on_item_cancel
    @skill_type_window.activate
    @item_window.deactivate
    @item_window.unselect
  end
  #--------------------------------------------------------------------------
  # * stype_cancel
  #--------------------------------------------------------------------------
  def stype_cancel
    return_scene
  end
  #--------------------------------------------------------------------------
  # * stype_ok
  #--------------------------------------------------------------------------
  def stype_ok
    @skill_type_window.deactivate
    @item_window.activate
  end
  #--------------------------------------------------------------------------
  # * Play Se for item
  #--------------------------------------------------------------------------
  def play_se_for_item
    # Don't play the sound
  end
end # Scene_UnitSkill

#==============================================================================
# ** Scene_UnitItem
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#    Scene for processing a unit useing an item during a tactical battle.
#==============================================================================
class Scene_UnitItem < Scene_Item
  #----------------------------------------------------------------------------
  # * Start
  #----------------------------------------------------------------------------
  def start
    super
    orient_windows
  end
  #---------------------------------------------------------------------------
  # * Prepare
  #---------------------------------------------------------------------------
  def prepare(tb_unit)
    @tb_unit = tb_unit
  end
  #---------------------------------------------------------------------------
  # * User
  #---------------------------------------------------------------------------
  def user
    raise "no unit linked to unit" if !@tb_unit || !@tb_unit.battler
    @tb_unit.battler
  end
  #---------------------------------------------------------------------------
  # * Create Item Window
  #---------------------------------------------------------------------------
  def create_item_window(unitNo = 1)
    case unitNo
    when 1
      tb = @tb_unit
      base = init_item_window_helper(cw = @category_window,1, tb)
    when 2
      tb = @tb_unit
      base = init_item_window_helper(cw = @category_window2,2, tb)
    end
    base.viewport = @viewport
    base.help_window = @help_window
    str = unitNo == 2 ? "2" : "" 
    base.set_handler(:ok,     method("on_item_ok#{str}".to_sym))
    base.set_handler(:cancel, method("on_item_cancel#{str}".to_sym))
    base.set_tb_unit(tb)
    cw.item_window = @item_window
  end 
  #--------------------------------------------------------------------------
  # * Helper for creating item_window
  #--------------------------------------------------------------------------
  def init_item_window_helper(cw,num, tb)
    wy = cw.y + cw.height
    wh = Graphics.height - wy
    len = [tb.items.length, tb.armors.length, tb.weapons.length].max
    height = [24*(len/2 + 2),wh].min
    
    case num
    when 1; return @item_window = Window_UnitItemListTB.new(0, wy, 190, height);
    when 2; return @item_window2 = Window_UnitItemListTB.new(0, wy, 190, height);
    end
  end
  
  #--------------------------------------------------------------------------
  # * Create Category Window
  #--------------------------------------------------------------------------
  def create_category_window(unitNo = 1)
    case unitNo
    when 1; base = @category_window = Window_UnitItemCategory.new;
    when 2; base = @category_window2 = Window_UnitItemCategory.new;
    end
    base.viewport = @viewport
    base.help_window = @help_window
    base.y = @help_window.height
    str = unitNo == 2 ? "2" : "" 
    base.set_handler(:ok,     method("on_category_ok#{str}".to_sym))
    base.set_handler(:cancel, method(:on_category_cancel))
  end
  #----------------------------------------------------------------------------
  # * Create Background
  #----------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
  end
  #--------------------------------------------------------------------------
  # * Create Help Window
  #--------------------------------------------------------------------------
  def create_help_window(unitNo = 1)
    @help_window = Window_TbHelp.new
    @help_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # * Orient Windows
  #--------------------------------------------------------------------------
  def orient_windows
    @help_window.y = Graphics.height - @help_window.height
  end
  #--------------------------------------------------------------------------
  # * On Category Cancel
  #--------------------------------------------------------------------------
  def on_category_cancel
    return_scene
  end
end # Scene_UnitItem

#==============================================================================
# ** Scene_TbTrade
#     Very disorganized needs to be rewritten, no will right now... fuck guis.
#==============================================================================
class Scene_TbTrade < Scene_UnitItem
  #--------------------------------------------------------------------------
  # * Start
  #--------------------------------------------------------------------------
  alias sc_tb_trade_era_56948711 start
  def start
    sc_tb_trade_era_56948711
    create_category_window(2)
    create_item_window(2)
    create_trade_windows
    create_com_win
    organize_second_unit_windows
    init_prior
    setup_trade_win_vals
  end
  #--------------------------------------------------------------------------
  # * Setup Trade Window Values
  #--------------------------------------------------------------------------
  def setup_trade_win_vals
    @item_window.enable_all(true)
    @item_window2.enable_all(true)
    
    @item_window2.set_tb_unit(@tb_unit2)
    
    @category_window.item_window = @item_window
    @category_window2.item_window = @item_window2
  end
  #--------------------------------------------------------------------------
  # * Prepare Second Unit
  #--------------------------------------------------------------------------
  def prepare2(tb_unit2); @tb_unit2 = tb_unit2; end
  #--------------------------------------------------------------------------
  # * Set Actication States
  #--------------------------------------------------------------------------  
  def init_prior
    @item_window2.deactivate
    @item_window.deactivate
    @category_window.deactivate
    @category_window2.deactivate
    @item_window2.unselect
    @item_window.unselect
  end
  #--------------------------------------------------------------------------
  # * Category Window Unit2
  #--------------------------------------------------------------------------
  def on_category_ok2
    @item_window2.activate
    @item_window2.select_last
  end
  #--------------------------------------------------------------------------
  # * Category Cancel
  #--------------------------------------------------------------------------
  def on_category_cancel
    @command_window.activate
    @category_window.deactivate
    @category_window2.deactivate
    # clean_up
  end
  #--------------------------------------------------------------------------
  # * Item Ok Unit 2
  #--------------------------------------------------------------------------
  def on_item_ok2; item_ok(@item_window2, @trade_win2, @tb_unit2); end
  #--------------------------------------------------------------------------
  # * Item Ok Unit 1
  #--------------------------------------------------------------------------
  def on_item_ok; item_ok(@item_window, @trade_win1, @tb_unit); end
  #--------------------------------------------------------------------------
  # * Item [OK]
  #--------------------------------------------------------------------------
  def item_ok(item_win, trade_win, unit)
    trade_win.add_item(ti=item_win.item)
    unit.lose_item(ti, 1)
    trade_win.refresh
    item_win.refresh
    item_win.activate
  end
  #--------------------------------------------------------------------------
  # * Item Cancel Unit 2
  #--------------------------------------------------------------------------
  def on_item_cancel2; item_cancel(@item_window2, @category_window2); end
  #--------------------------------------------------------------------------
  # * Item Cancel Unit 1
  #--------------------------------------------------------------------------
  def on_item_cancel; item_cancel(@item_window, @category_window); end
  #--------------------------------------------------------------------------
  # * Item Cancel
  #--------------------------------------------------------------------------
  def item_cancel(item_win, cat_win)
    item_win.unselect
    cat_win.activate
  end
  #--------------------------------------------------------------------------
  # * Create Background
  #--------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
  end
  #--------------------------------------------------------------------------
  # * Create Command Window
  #--------------------------------------------------------------------------
  def create_com_win
    @command_window = Window_TbTradeCom.new(0,0)
    @command_window.viewport = @viewport
    @command_window.set_handler(:unit1, method(:command_unit1))
    @command_window.set_handler(:unit2, method(:command_unit2))
    @command_window.set_handler(:accept, method(:do_trade))
    @command_window.set_handler(:reset, method(:trade_reset))
    @command_window.set_handler(:cancel, method(:exit_trade))
  end
  #--------------------------------------------------------------------------
  # * Exit Trade
  #--------------------------------------------------------------------------
  def exit_trade
    clean_up
    return_scene
  end
  #--------------------------------------------------------------------------
  # * Go to Unit 1 Items
  #--------------------------------------------------------------------------
  def command_unit1
    @command_window.deactivate
    activate_c1
  end
  #--------------------------------------------------------------------------
  # * Go to Unit 2 Items
  #--------------------------------------------------------------------------
  def command_unit2
    @command_window.deactivate
    activate_c2
  end
  #--------------------------------------------------------------------------
  # * Perform Trade
  #--------------------------------------------------------------------------
  def do_trade
    @trade_win1.items.each{|i| @tb_unit2.gain_item(i,@trade_win1.item_number(i))}
    @trade_win2.items.each{|i| @tb_unit.gain_item(i,@trade_win2.item_number(i))}
    @trade_win1.clear_data
    @trade_win2.clear_data
    @trade_win2.refresh
    @trade_win2.refresh
    @item_window.refresh
    @item_window2.refresh
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # * Reset the Trade
  #--------------------------------------------------------------------------
  def trade_reset
    reset_items_unit1
    reset_items_unit2
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # * Clean up on Exiting Scene
  #--------------------------------------------------------------------------
  def clean_up
    reset_items_unit1
    reset_items_unit2
  end
  #--------------------------------------------------------------------------
  # * Push items back into correct unit inventory
  #--------------------------------------------------------------------------
  def reset_items(trade_win, item_win, unit)
    trade_win.items.each do |item|
      unit.gain_item(item, trade_win.item_number(item))
    end
    trade_win.clear_data
    trade_win.refresh
    item_win.refresh
  end
  #--------------------------------------------------------------------------
  # * Reset Items Unit 2
  #--------------------------------------------------------------------------
  def reset_items_unit2; reset_items(@trade_win2, @item_window2,@tb_unit2); end
  #--------------------------------------------------------------------------
  # * Reset Items Unit 1
  #--------------------------------------------------------------------------
  def reset_items_unit1; reset_items(@trade_win1, @item_window,@tb_unit); end
  #--------------------------------------------------------------------------
  # * Get Item for Unit 2
  #--------------------------------------------------------------------------
  def item2
    @item_window2.item
  end
  #--------------------------------------------------------------------------
  # * Activate Category Window 1 & 2
  #--------------------------------------------------------------------------
  def activate_c1; activate_cat(@category_window); end
  def activate_c2;activate_cat(@category_window2); end
  #--------------------------------------------------------------------------
  # * Activate Category Window Helper
  #--------------------------------------------------------------------------
  def activate_cat(cat_win)
    cat_win.activate
    cat_win.select(0)
  end
  #--------------------------------------------------------------------------
  # * create_trade_windows
  #--------------------------------------------------------------------------
  def create_trade_windows
    @trade_win1 = Window_TbTrading.new(0,0,100,190)
    @trade_win2 = Window_TbTrading.new(0,0,100,190)
  end
  #--------------------------------------------------------------------------
  # * organize_second_unit_windows
  #--------------------------------------------------------------------------
  def organize_second_unit_windows
    @item_window2.x = @category_window2.x = Graphics.width - @category_window2.width
    @trade_win1.width = @trade_win2.width = (@category_window2.x - (@category_window.width + @category_window.x))
    @trade_win1.y = t=@category_window.y
    @trade_win2.y = (t+@category_window.height+@item_window.height) - (@category_window.height+@item_window.height)/2
    @trade_win1.height = @trade_win2.height = ((@item_window.height+@item_window.y) - @trade_win1.y)/2
    @trade_win1.x = @trade_win2.x = @category_window.width+@category_window.x
  end
end # Scene_TbTrade

#==============================================================================
# ** Scene_EndTB
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     End of a tacitcal battle, report statistics, etc.
#==============================================================================
class Scene_EndTB < Scene_Base
  TM = TactBattleManager
  #--------------------------------------------------------------------------
  # * Start
  #--------------------------------------------------------------------------
  def start
    super
    create_background
    create_title_win
  end
  #--------------------------------------------------------------------------
  # * Create Title Window
  #--------------------------------------------------------------------------
  def create_title_win
    g = Graphics
    @title_win = Window_BasicTextTB.new(0,0,g.width,g.height/7)
    @title_win.viewport = @viewport
    @title_win.text = @title_text ||= "?"
    @title_win.show
  end
  #--------------------------------------------------------------------------
  # * Upate
  #--------------------------------------------------------------------------
  def update
    super
    try_leave
  end
  #--------------------------------------------------------------------------
  # * Prepare
  #--------------------------------------------------------------------------
  def prepare(won=true)
    @title_text = won ? TM::VocabTB::Win : TM::VocabTB::Lose
  end
  #--------------------------------------------------------------------------
  # * Try to leave
  #--------------------------------------------------------------------------
  def try_leave
    return_scene if Input.trigger?(:C) || Input.trigger?(:B)
  end
  #--------------------------------------------------------------------------
  # * Return Scene
  #--------------------------------------------------------------------------
  def return_scene
    super
  end
  #--------------------------------------------------------------------------
  # * Create Background
  #--------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.color.set(16, 16, 16, 128)
  end
end # Scene_EndTB
#==============================================================================
# ** TB_Acts_Data
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     Stores data about actions made during a tactical battle
#==============================================================================
class TB_Acts_Data
  # :move, :skill, :item, :atk, 
  # :damage_dealt, :damage_taken, :damage_healed, :units_destroyed, :units_lost
  # :total_actions, :distance_moved, :mp
  def initialize
    teams_data = {}
  end
  #--------------------------------------------------------------------------
  # * Modify Total Moves Made
  #--------------------------------------------------------------------------
  def mod_moves(team, v, set = false)
    gen_mod_data(team, v, :move, set)
  end
  #--------------------------------------------------------------------------
  # * Modify Total Distance Moved
  #--------------------------------------------------------------------------
  def mod_distance_moved(team, v, set = false)
    gen_mod_data(team, v, :distance_moved, set)
  end
  #--------------------------------------------------------------------------
  # * Modify Total mp Used
  #--------------------------------------------------------------------------
  def mod_mp_used(team, v, set = false)
    gen_mod_data(team, v, :mp, set)
  end
  #--------------------------------------------------------------------------
  # * Modify Total Skills Used
  #--------------------------------------------------------------------------
  def mod_skills_used(team, v, set = false)
    gen_mod_data(team, v, :skill, set)
  end
  #--------------------------------------------------------------------------
  # * Modify Total Items Used
  #--------------------------------------------------------------------------
  def mod_items_used(team, v, set = false)
    gen_mod_data(team, v, :item, set)
  end
  #--------------------------------------------------------------------------
  # * Modify Total Attacks Made
  #--------------------------------------------------------------------------
  def mod_atks(team, v, set = false)
    gen_mod_data(team, v, :atk, set)
  end
  #--------------------------------------------------------------------------
  # * Modify Total Damage Dealt
  #--------------------------------------------------------------------------
  def mod_damage_dealt(team, v, set = false)
    gen_mod_data(team, v, :damage_dealt, set)
  end
  #--------------------------------------------------------------------------
  # * Modify Total Damage Taken
  #--------------------------------------------------------------------------
  def mod_damage_taken(team, v, set = false)
    gen_mod_data(team, v, :damage_taken, set)
  end
  #--------------------------------------------------------------------------
  # * Modify Total Damage Healed
  #--------------------------------------------------------------------------
  def mod_damage_healed(team, v, set = false)
    gen_mod_data(team, v, :damage_healed, set)
  end
  #--------------------------------------------------------------------------
  # * Modify Total Units Destroyed
  #--------------------------------------------------------------------------
  def mod_units_destroyed(team, v, set = false)
    gen_mod_data(team, v, :units_destroyed, set)
  end
  #--------------------------------------------------------------------------
  # * Modify Total Units Lost
  #--------------------------------------------------------------------------
  def mod_units_lost(team, v, set = false)
    gen_mod_data(team, v, :units_lost, set)
  end
  #--------------------------------------------------------------------------
  # * Modify Total Actions
  #--------------------------------------------------------------------------
  def mod_total_actions(team, v, set = false)
    gen_mod_data(team, v, :total_actions, set)
  end
  #--------------------------------------------------------------------------
  # * General modify helper
  #--------------------------------------------------------------------------
  def gen_mod_data(team, val, sym, set)
    teams_data[team][sym] ||= 0
    set ? teams_data[team][sym] = val : teams_data[team][sym]+=val 
  end
end
#==============================================================================
# ** EventSpawn
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#    Adds call to location cache when spawning events
#==============================================================================
module EventSpawn
  class << self
    alias spawn_event_tb_era spawn_event
  end
  #--------------------------------------------------------------------------
  # * Spawn Event
  #--------------------------------------------------------------------------
  def self.spawn_event(*args)
    e = spawn_event_tb_era(*args)
    $game_map.cache_event_xy(e.x,e.y,e.id)
    e
  end
end # EventSpawn

class Game_Event < Game_Character
  attr_reader :interpreter
end

class Game_Enemy # Remove
  def to_s # Remove
    "Game_Enemy hp: #{@hp} mp: #{@mp}\n" # Remove
  end # Remove
end # Remove
