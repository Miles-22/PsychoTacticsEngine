# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ** Psycho Tactics Engine
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   * Dependencies
# -----------------------------------------------------------------------------
# - Era helper module
# - Lightweight Map Highlights
# - Reproduce Events
# - Eshra Bouncy Text
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



########################### DEPENDENCIES BELOW ################################



#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
# * Era Module
#   Author: Eshra
#   Compatibility: Rpg Maker VX Ace
#   Released: Unreleased
#   Dependencies: ** no dependencies **
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Provides helper and utility methods for scripts I've written.
#   Standardizes loading notetags from the db so that it's not iterated 
#   through multiple times when getting notes data.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Update Log:
# 18 Jan. 2013 - Moved set_revs method from Era to TBM, added core save obj.
# 10 Jan. 2013 - Rounding and tbs revival settings
# 30 Dec. 2012 - Notetag Loading standardization
# 20 Nov. 2012 - added valid_comments
# 18 Nov. 2012 - added new_event
#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~

($imported ||= {})["Era Module"] = 0.1
module Era
  
  module LoadDB
    # Turn loading notetags on/off
    # No scripts modify the default off constants as of 18 Jan. 2013
    
    LOAD_CLASSES = false
    LOAD_SKILLS = true
    LOAD_ITEMS = true
    LOAD_WEAPONS = true
    LOAD_ARMORS = true
    LOAD_ENEMIES = true
    LOAD_TROOPS = false
    LOAD_STATES = true
    LOAD_ANIMATIONS = false
    LOAD_TILESETS = false
    LOAD_COMMON_EVENTS = false
    LOAD_MAPINFOS = false
    LOAD_ACTORS = true
  end # LoadDB
  
  module RE
    WinNL = /[\r\n]+/
    Num = /\A(?:-|)\d+(?:\.|)(?:\d+|)\Z/ # Regex representing a number
  end # RE
  
  #============================================================================
  # ** Era::Event
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  #   API: 
  #      valid_comments(id) => array of comments for event with id = to param 
  #           events active page, => nil if no active pages.
  #      new_event(spawn_map_id, opts = {}) => spawns an event on the map,
  #           requires reproduce events.
  #      round(float, power of ten) => rounds the float to arg power of ten
  #
  #============================================================================
  module Event
    #--------------------------------------------------------------------------
    # * New Event
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    #     Places a new event on the map using the "Reproduce Events" Script.
    #--------------------------------------------------------------------------
    def self.new_event(spawn_map_id, opts = {})
      return unless $imported["Ra Event Spawn"] >= 0.2
      
      player = $game_player
      options = {
        :x => player.x, :y => player.y, :persist => false, :init_dir => -1,
        :opts => {}, :name => nil, :id => 0
      }.merge(opts)
    
      persist,x,y,id = options[:persist], options[:x], options[:y], options[:id] 
      init_dir, opts, name = options[:init_dir], options[:opts], options[:name]
      EventSpawn.spawn_event(spawn_map_id, id, x, y, persist, init_dir, 
        opts, name)
    end
    #--------------------------------------------------------------------------
    # * Valid Comments
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    #     Returns the comments for the event with param: id on its active page
    #     => nil if no page conditions are met or no comments are found.
    #--------------------------------------------------------------------------
    def self.valid_comments(id)
      return if !(ev = $game_map.events[id]) || !(page = ev.find_proper_page)
      page.list.inject([]){ |a,c| c.code == 108 ? a.push(c.parameters[0]) : a }
    end
  end # Event
  
  #______________________
  # Convienience methods
  
  #--------------------------------------------------------------------------
  # * Round a float to the nearest place specified as a power of ten.
  #--------------------------------------------------------------------------
  def self.round(f, pten)
    (f*pten).round.to_f / pten
  end
  
end # Era

#==============================================================================
# ** DataManager
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#       Note-tag helper methods. Alias eval_note_era to evaluate notes for 
#   the entire database. Determine type by the regex the note matches.
#==============================================================================
module DataManager
  class <<self 
    alias load_db_era load_database 
    alias load_game_era load_game
  end
  def self.load_database
    load_db_era
    
    if !$BTEST
      load_classes_era if Era::LoadDB::LOAD_CLASSES
      load_actors_era if Era::LoadDB::LOAD_ACTORS
      load_enemies_era if Era::LoadDB::LOAD_ENEMIES
      load_troops_era if Era::LoadDB::LOAD_TROOPS
      load_animations_era if Era::LoadDB::LOAD_ANIMATIONS
      load_tilesets_era if Era::LoadDB::LOAD_TILESETS
      load_common_events_era if Era::LoadDB::LOAD_COMMON_EVENTS
      load_map_infos_era if Era::LoadDB::LOAD_MAPINFOS
      load_skills_era if Era::LoadDB::LOAD_SKILLS
      load_items_era if Era::LoadDB::LOAD_ITEMS
      load_weapons_era if Era::LoadDB::LOAD_WEAPONS
      load_armors_era if Era::LoadDB::LOAD_ARMORS
      load_states_era if Era::LoadDB::LOAD_STATES
    end
  end
  
  #--------------------------------------------------------------------------
  # * Alias, load_game
  #--------------------------------------------------------------------------
  def self.load_game(index)
    success = load_game_era(index)
    $game_system.init_era if $game_system # init core obj. if just installed
    success
  end
  
  #----------------------------------------------------------------------------
  # * Load Notetags
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Methods to perform processing on each item in the database. The benefit is
  # that now if two scripts I wrote needed to for example access all of the 
  # armors, there would only be one iteration over $data_armors instead of
  # two. The speed up would only be noticable for large databases using several
  # scripts I've written.
  #
  # Methods split up to facillitate extendibility later on.
  #----------------------------------------------------------------------------
  
  def self.load_classes_era; $data_classes.each{|c| each_class_era(c)}; end
  #----------------------------------------------------------------------------
  # * Processing for each class in the database
  #----------------------------------------------------------------------------
  def self.each_class_era(param)
    return if param.nil?
    param.note.split(Era::RE::WinNL).each{ |line| eval_note_era(param, line)}
  end
  
  def self.load_actors_era; $data_actors.each{|a| each_actor_era(a)}; end
  #----------------------------------------------------------------------------
  # * Processing for each actor 
  #----------------------------------------------------------------------------
  def self.each_actor_era(param)
    return if param.nil?
    param.note.split(Era::RE::WinNL).each{ |line| eval_note_era(param, line)}
  end
  
  def self.load_enemies_era; $data_enemies.each{|e| each_enemy_era(e)}; end
  #----------------------------------------------------------------------------
  # * Processing for each enemy
  #----------------------------------------------------------------------------
  def self.each_enemy_era(param)
    return if param.nil?
    param.note.split(Era::RE::WinNL).each{ |line| eval_note_era(param, line)}
  end
  
  def self.load_troops_era; $data_troops.each{|t| each_troop_era(t)}; end
  #----------------------------------------------------------------------------
  # * Processing for each troop
  #----------------------------------------------------------------------------
  def self.each_troop_era(param)
    param.note.split(Era::RE::WinNL).each{ |line| eval_note_era(param, line)}
  end
  
  def self.load_animations_era;$data_animations.each{|a|each_animation_era(a)};end
  #----------------------------------------------------------------------------
  # * Processing for each animation
  #----------------------------------------------------------------------------
  def self.each_animation_era(param)
    return if param.nil?
    param.note.split(Era::RE::WinNL).each{ |line| eval_note_era(param, line)}
  end
  
  def self.load_tilesets_era; $data_tilesets.each{|t|each_tileset_era(t)}; end
  #----------------------------------------------------------------------------
  # * Processing for each tileset
  #----------------------------------------------------------------------------
  def self.each_tileset_era(param)
    return if param.nil?
    param.note.split(Era::RE::WinNL).each{ |line| eval_note_era(param, line)}
  end
  
  def self.load_common_events_era
    $data_common_events.each{|c| each_common_event_era(c) } 
  end
  #----------------------------------------------------------------------------
  # * Processing for each common event
  #----------------------------------------------------------------------------
  def self.each_common_event_era(param)
    return if param.nil?
    param.note.split(Era::RE::WinNL).each{ |line| eval_note_era(param, line)}
  end
  
  def self.load_map_infos_era; $data_mapinfos.each{|m| each_map_info_era(m)};end
  #----------------------------------------------------------------------------
  # * Processing for each map info
  #----------------------------------------------------------------------------
  def self.each_map_info_era(param)
    return if param.nil?
    param.note.split(Era::RE::WinNL).each{ |line| eval_note_era(param, line)}
  end
    
  def self.load_skills_era; $data_skills.each{|s| each_skill_era(s)}; end
  #----------------------------------------------------------------------------
  # * Processing for each skill
  #----------------------------------------------------------------------------
  def self.each_skill_era(arg)
    arg.note.split(Era::RE::WinNL).each{ |line| eval_note_era(arg, line)} if arg
  end
    
  def self.load_items_era; $data_items.each{|i| each_item_era(i)}; end
  #----------------------------------------------------------------------------
  # * Processing for each item
  #----------------------------------------------------------------------------
  def self.each_item_era(param)
    return if param.nil?
    param.note.split(Era::RE::WinNL).each{ |line| eval_note_era(param, line)}
  end
    
  def self.load_weapons_era; $data_weapons.each{|w| each_weapon_era(w)}; end
  #----------------------------------------------------------------------------
  # * Processing for each weapon
  #----------------------------------------------------------------------------
  def self.each_weapon_era(param)
    return if param.nil?
    param.note.split(Era::RE::WinNL).each{ |line| eval_note_era(param, line)}
  end
  
  def self.load_armors_era; $data_armors.each{|a| each_armor_era(a)}; end
  #----------------------------------------------------------------------------
  # * Processing for each armor
  #----------------------------------------------------------------------------
  def self.each_armor_era(param)
    return if param.nil?
    param.note.split(Era::RE::WinNL).each{ |line| eval_note_era(param, line)}
  end
  
  def self.load_states_era; $data_states.each{|s| each_state_era(s)}; end
  #----------------------------------------------------------------------------
  # * Processing for each state
  #----------------------------------------------------------------------------
  def self.each_state_era(param)
    return if param.nil?
    param.note.split(Era::RE::WinNL).each{ |line| eval_note_era(param, line)}
  end
  #----------------------------------------------------------------------------
  # * Only one method to evaluate notetags
  #     assumes type of data can be inferred based on matching regex
  #----------------------------------------------------------------------------
  def self.eval_note_era(data, line)
  end
end # DataManager

#==============================================================================
# ** Game_System
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#==============================================================================
class Game_System
  #--------------------------------------------------------------------------
  # * Alias, initialize
  #--------------------------------------------------------------------------
	alias initialize_cera initialize
	def initialize
		initialize_cera
		init_era(:force => true)
	end
	#--------------------------------------------------------------------------
	# * Init Core Era object
	#--------------------------------------------------------------------------
	def init_era(opts = {})
		options = {:force => false, :opts => {}}.merge(opts)
    opts2 = options[:opts]
		options[:force] ? @era_save = CEra.new(opts2): @era_save ||= CEra.new(opts2)
	end
  #--------------------------------------------------------------------------
  # * Get Core object
  #--------------------------------------------------------------------------
  def era_obj; @era_save; end
end # Game_System
  
#==============================================================================
# ** CEra
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Allows easier and more organized inclusion in save data. Less namespace
#     pollution etc.
#==============================================================================
class CEra
  #--------------------------------------------------------------------------
  # * Init
  #--------------------------------------------------------------------------
	def initialize(opts = {})
	end
end # CEra

#==============================================================================
# ** Game_Event
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     Adds:
#       attr_readers for @event and @list
#==============================================================================
class Game_Event < Game_Character; attr_reader :event, :list; end # Game_Event


  
  
  
  
  
  
  
  

#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
# ** Lightweight Map Highlights
#    Author: Eshra
#    First Verison: 4 Oct. 2012
#    Compatibility: RPG Maker VX Ace
#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
#
#    Use this to draw bitmaps representing highlights on the current map. 
#    Supports Drawing from sprite sheets. Much lighter than using 
#    Sprite_Characters but the functionality is greatly reduced.
#
#    Was made to support generating a large amount of highlights on a
#    large map, otherwise it's probably better to just use a Game_Character.
#
#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
# 
#------------------------------------------------------------------------------
# * How to Use
#------------------------------------------------------------------------------
#   Highlights can now be placed on the game_map from inside of Scene_Map.
#
#   use: @spriteset.add_highlight_tb(x,y) 
#   to place a highlight on the map at position x,y
#
#   use: @spriteset.add_highlight_tb(x,y,nil,true)
#   to place a persistent highlight on the map which will be redrawn each time
#   the map is reloaded. 
#
#   Persistant highlights can be removed with: 
#     remove_saved_highlight(x,y,map_id) 
#     param: map_id is optional (uses $game_map.map_id if not passed)
#
#   Sprite sheets can be used as well, see the Sheet_Data class below.
#   
#   To organize the highlights on the map, use param: hloc.
#   this should be a symbol. The highlights added to the spriteset map will be
#   grouped according to symbol (in a hash). This makes it easier to remove
#   specific groups of highlights.
#   See method header below.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#
# Original Release Date: 7 Nov. 2012
#
# Upate Log
# 7 Dec. 2012 - Added nil check to remove_highlight
# 5 Dec. 2012 - save_highlight inside Game_System now saves all of the optional
#               data about each retained highlight instead of just the sprite sheet.
#
# 3 Dec. 2012 - Added helper method for adding highlights which takes in an options
#              hash. The method is called add_highlight.
#              add_highlights can take options:
#             :x => x placement location
#             :y => y placement location
#             :sh => sprite sheet
#             :retain => true or false, is the highlight remembered after leaving map and returning?
#             :hloc => "hash location", can be used to group certain highlights 
#                       together
#             :sym => symbol of the method used to create and update the highlight
#             :opacity => the opacity value the highlight will be placed on the map with.
#
# v0.2 Updates 11/17, 11/18:
# 18 Nov. 2012 - Highlights can now be organized: header for add_highlight_tb changed:
#             ...(x,y,sh = nil, retain = false, sym = :default_move, hloc = :def)
#             param: hloc should is the symbol defining where the highlight will
#             be added.
#             This makes it easier to remove specific highlights. Just pass in
#             the same symbol to the remove method to remove specific highlights.
# 17 Nov. 2012 - Support for removing highlights. Iterates through an array so slow.
#            changed @path_hightlights_tb to @path_highlights_tb
#            Can force all default highlights to fade at same rate.
# 30 Oct. 2012 - Reorganized updating to match the default engine's organization.
#            That is, $game_map stores the information about the highlights
#            and scene_map refreshes the highlights when @map_id != game_map.map_id
# 29 Oct. 2012 - Version 0.1 finished, added support for persistant highlights
# 4 Oct. 2012 - First Version finished
#
#------------------------------------------------------------------------------

($imported||={})["Ra Highlights"] = 0.2
#==============================================================================
# ** Era Module
#==============================================================================
module Era

  module Fade
    
    Max = 160             # Largest opacity for default highlights
    Min = 52              # Smallest opacity for default highlights
    Rate = 3              # Rate Opacity changes each update
    SameRate = true       # All default highlights flicker at the same rate
    @@opacity = 160       # Current opacity
    #--------------------------------------------------------------------------
    # * Get Opacity
    #--------------------------------------------------------------------------
    def self.opacity
      @@opacity
    end
    #--------------------------------------------------------------------------
    # * Setter
    #--------------------------------------------------------------------------
    def self.opacity=(val)
      @@opacity = val
    end

  end # Fade

end # Era
#==============================================================================
# * Spriteset_Map
#==============================================================================
class Spriteset_Map
  attr_accessor :viewport1
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  alias initialize_highlights_tb initialize
  def initialize
    initialize_highlights_tb
    create_highlights_tb
  end
  #----------------------------------------------------------------------------
  # * Create Highlights
  #----------------------------------------------------------------------------
  def create_highlights_tb
    @path_highlights_tb = {}
    @hl_mod = -Era::Fade::Rate
    make_hls_visible_for_map
  end
  #----------------------------------------------------------------------------
  # * make_hls_visible_for_map
  #----------------------------------------------------------------------------
  def make_hls_visible_for_map
    gh = $game_map.map_highlights_era
    gh.keys.each{|xy|
      add_highlight(gh[xy])
    }
  end
  #----------------------------------------------------------------------------
  # * Alias Update
  #----------------------------------------------------------------------------
  alias highlights_spritesetmap_update_tb update
  def update
    update_highlights
    highlights_spritesetmap_update_tb
  end
  #----------------------------------------------------------------------------
  # * Update Highlights
  #----------------------------------------------------------------------------
  def update_highlights
    refresh_highlights if @map_id != $game_map.map_id
    return if @path_highlights_tb.nil?
    @path_highlights_tb.values.each do |arr|
      arr.each{ |sp| sp.update }
    end
    update_hl_global
  end
  #----------------------------------------------------------------------------
  # * Update global highlight opacity value
  #----------------------------------------------------------------------------
  def update_hl_global
    min, max, rate = Era::Fade::Min, Era::Fade::Max, Era::Fade::Rate
    opacity = Era::Fade.opacity
    @hl_mod = opacity <= min ? rate : (opacity >= max ? -rate : @hl_mod)
    Era::Fade.opacity = opacity + @hl_mod
  end
  #----------------------------------------------------------------------------
  # * Add a highlight
  #----------------------------------------------------------------------------
  def add_highlight_tb(x,y,sh = nil, retain = false, sym = :default_move, 
      hloc = :def, opacity = Era::Fade.opacity, vport_no = 1)
    hls = (@path_highlights_tb||={})
    hls[hloc] ||= []
    view = @viewport1
    case vport_no
    when 2; view = @viewport2;
    when 3; view = @viewport3;
    end
      
    if sh.nil?
      hls[hloc].push(s=Sprite_Highlight.new(view, sym).place(x,y, opacity))
    else
      hls[hloc].push(s=Sprite_Highlight.new(view, :hl_sheet, sh).place(x,y, opacity))
    end
  end
  
  def add_highlight(opts = {})
    options = {
      :x => 0, :y => 0, :sh => nil, :retain => false, :sym => :default_move, 
      :hloc => :def, :opacity => Era::Fade.opacity, :vport => 1
    }.merge(opts)
    add_highlight_tb(options[:x], options[:y], options[:sh], options[:retain],
      options[:sym], options[:hloc], options[:opacity], options[:vport])
      
    $game_system.save_highlight(options[:x], options[:y], options) if options[:retain]
  end
  #----------------------------------------------------------------------------
  # * Remove Highlights
  #----------------------------------------------------------------------------
  def dispose_highlights_tb
    print "disposing hls\n"
    @path_highlights_tb.values.each do |arr|
      arr.each{ |sp| sp.dispose }
    end
    @path_highlights_tb = {}
  end
  #----------------------------------------------------------------------------
  # * Alias Dispose
  #----------------------------------------------------------------------------
  alias sp_highl_spmap_mod_dispose dispose
  def dispose
    sp_highl_spmap_mod_dispose
    dispose_highlights_tb
  end
  #----------------------------------------------------------------------------
  # * Refresh Highlights
  #----------------------------------------------------------------------------
  def refresh_highlights
    print "refreshing hls\n"
    dispose_highlights_tb
    create_highlights_tb
  end
  #----------------------------------------------------------------------------
  # * Removes highlight at pos x,y in the group specified by sym.
  #----------------------------------------------------------------------------
  def remove_highlight(x,y, sym = :def)
    sz, i = (@path_highlights_tb[sym]||=[]).size, 1
    @path_highlights_tb[sym].reverse_each do |hl|
      
      if hl.sx == x && hl.sy == y
        del = @path_highlights_tb[sym].delete_at(sz - i) 
        hl.dispose
        break
      end # end if
      
      i+=1
    end
  end
  #----------------------------------------------------------------------------
  # * Remove the group of highlights specified by sym
  #----------------------------------------------------------------------------
  def remove_group(sym)
    hls = @path_highlights_tb[sym]||=[]
    hls.each{|hl| hl.dispose}
    @path_highlights_tb[sym] = []
  end
  #----------------------------------------------------------------------------
  # * Get a group of highlights
  #----------------------------------------------------------------------------
  def get_hl_group(sym)
    return if @path_highlights_tb.nil?
    @path_highlights_tb[sym]
  end
end # Spriteset_Map

#==============================================================================
# * Sprite_Highlight_Base
#------------------------------------------------------------------------------
#   Provies methods for drawing a highlight on the screen.
#==============================================================================
class Sprite_Highlight_Base < Sprite_Base
  attr_reader :sx, :sy
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    @disp_x, @disp_y = 0, 0
    @val = 1 # Used lazily as a variable for manipulating the bitmap
    
    # Add creation and update methods to these hashes for custom highlights:
    # The hash maps symbols => method names
    @create_methods = {
                        :default_move => :create_default_move_highlight, 
                        :default_attack => :create_default_attack_highlight,
                        :hl_sheet => :create_bitmap_from_sprite_sheet,
                        :attack_2 => :create_attack_highlight2
                      }
    @update_methods = {
                        :default_move => :update_default,
                        :default_attack => :update_default,
                        :attack_2 => :update_default,
                        :hl_sheet => :update_sprite_from_sheet
                      }
  end
  #--------------------------------------------------------------------------
  # * Create Bitmap
  #--------------------------------------------------------------------------
  def create_highlight_bitmap
    method(@create_methods[@method_symbol]).call
  end
  #---------------------------------------------------------------------------
  # * Create Default Movement Highlight
  #---------------------------------------------------------------------------
  def create_default_move_highlight
    self.bitmap = Bitmap.new(32, 32)
    self.bitmap.fill_rect(0,0,32,32,Color.new(23,52,123))
    color_border(Color.new(28,91,145))
    @default = true
  end
  #---------------------------------------------------------------------------
  # * Create Default Attack Highlight
  #---------------------------------------------------------------------------
  def create_default_attack_highlight
    self.bitmap = Bitmap.new(32, 32)
    self.bitmap.fill_rect(0,0,32,32,Color.new(250,82,77))
    color_border(Color.new(255,216,107))
    @default = true
  end
  #---------------------------------------------------------------------------
  # * Create Attack Highlight2
  #---------------------------------------------------------------------------
  def create_attack_highlight2
    self.bitmap = Bitmap.new(32, 32)
    self.bitmap.fill_rect(0,0,32,32,Color.new(250,193,18))
    color_border(Color.new(255,246,77))
    @default = true
  end
  def color_border(color)
    self.bitmap.fill_rect(0,0,1,32, color)
    self.bitmap.fill_rect(0,0,32,1, color)
    self.bitmap.fill_rect(31,0,32,32, color)
    self.bitmap.fill_rect(0,31,32,32, color)
  end
  #---------------------------------------------------------------------------
  # * Create Bitmap from Spritesheet
  #---------------------------------------------------------------------------
  def create_bitmap_from_sprite_sheet
    self.bitmap = Cache.character(@sheet_data.name)
    sign = @sheet_data.name[/^[\!\$]./]
    if sign && sign.include?('$')
      @cw = bitmap.width / 3
      @ch = bitmap.height / 4
    else
      @cw = bitmap.width / 12
      @ch = bitmap.height / 8
    end
    @default = false
  end
  #---------------------------------------------------------------------------
  # * Update Sprite From Sheet
  #---------------------------------------------------------------------------
  def update_sprite_from_sheet
      if @sheet_data.pattern == (@sheet_data.frequency*3)-1
        @val = -1
        @sheet_data.pattern = @sheet_data.frequency*2
      elsif @sheet_data.pattern == 0
        @val = 1
        @sheet_data.pattern = @sheet_data.frequency-1
      end
      @sheet_data.pattern += @val
      
      sx = (@sheet_data.index % 4 * 3 + @sheet_data.pattern/@sheet_data.frequency) * @cw
      sy = (@sheet_data.index/4 * 4 + @sheet_data.row)*@ch
      self.src_rect.set(sx, sy, @cw, @ch)
  end
  #---------------------------------------------------------------------------
  # * Place
  #---------------------------------------------------------------------------
  def place(x,y, opacity = Era::Fade.opacity)
    @sx, @sy = x,y
    self.ox = 0
    self.oy = 0
    @orx = x
    @ory = y
    self.x = (x - (@disp_x = $game_map.display_x)) * 32
    self.y = (y - (@disp_y = $game_map.display_y)) * 32
    self.opacity = opacity
    self 
  end
  #---------------------------------------------------------------------------
  # * Update
  #---------------------------------------------------------------------------
  def update
    return unless !self.bitmap.nil?
    super
    if @disp_x != $game_map.display_x || @disp_y != $game_map.display_y
      update_position
    end
    method(@update_methods[@method_symbol]).call
  end
  #---------------------------------------------------------------------------
  # * Update Default
  #---------------------------------------------------------------------------
  def update_default
    
    if Era::Fade::SameRate
      self.opacity = Era::Fade.opacity
    else
      @val = self.opacity < Era::Fade::Min ? Era::Fade::Rate : (self.opacity > Era::Fade::Max ? -Era::Fade::Rate : @val)
      self.opacity += @val
    end
    
  end # update_default
  #---------------------------------------------------------------------------
  # * Update Position
  #---------------------------------------------------------------------------
  def update_position
    return unless @orx && @ory
    self.x = $game_map.adjust_x(@orx) * 32
    self.y = $game_map.adjust_y(@ory) * 32 
    self.z = 10
    @disp_x = $game_map.display_x
    @disp_y = $game_map.display_y
  end
  #---------------------------------------------------------------------------
  # * Clear contents of highlight
  #---------------------------------------------------------------------------
  def clear
    self.bitmap.clear
  end
end # Sprite_Highlight_Base
#==============================================================================
# * Sprite_Highlight
#------------------------------------------------------------------------------
#     Extra parameters are added in this subclass to prevent crowding the base
#     initialize method to support extendibility.
#==============================================================================
class Sprite_Highlight < Sprite_Highlight_Base
  def initialize(viewport, method_sym = :default_move, sheet_data = nil)
    super(viewport)
    @sheet_data = sheet_data
    @method_symbol = method_sym
    create_highlight_bitmap
    update
  end
end # Sprite_Highlight
#==============================================================================
# * Sprite Sheet Data for Custom Highlights
#------------------------------------------------------------------------------
#     Create a new instance of this class and call the setup method on it. Then
#     pass that instance to a Sprite_Highlight to use it as a sprite sheet.
#     use :hl_sheet as the method symbol. This provides the default method 
#     sprite sheet animation method for highlights.
#==============================================================================
class Sheet_Data
  attr_reader :index       # Index of the sprites to use
  attr_reader :row         # Animation row that should be used
  attr_reader :name        # Name of the spritesheet
  attr_accessor :pattern   # Used to calculate which part of spritesheet to show
  attr_accessor :frequency # Number of frames before modifying bitmap
  #---------------------------------------------------------------------------
  # * Initialize
  #---------------------------------------------------------------------------
  def initialize(name, index, row, freq = 18, pattern = 1)
    @index = index
    @row = row
    @name = name
    @pattern = pattern
    @frequency = freq
    self
  end
end # Sheet_Data

#==============================================================================
# ** Game_System
#==============================================================================
class Game_System
  attr_reader :highlights_drawn
  attr_reader :game_highlights
  
  def save_highlight(x,y, opts = {})
    ((@game_highlights||={})[$game_map.map_id]||={})[[x,y]] = opts
  end
  
  def remove_saved_highlight(x,y, map_id = nil)
    map_id = !map_id ? $game_map.map_id : map_id
    ((@game_highlights||={})[map_id]||={}).delete([x,y])
  end
  
  def curr_highlights(map_id)
    (@game_highlights||={})[map_id]||={}
  end
end

#==============================================================================
# ** Game_Map
#==============================================================================
class Game_Map
  attr_accessor :need_to_remove_highlights
  attr_accessor :map_highlights_era
  
  alias setup_add_support_rem_hl_when_ch setup
  def setup(map_id)
    setup_add_support_rem_hl_when_ch(map_id)
    setup_map_highlights_era(map_id)
  end
  
  def setup_map_highlights_era(map_id)
    @map_highlights_era = $game_system.curr_highlights(map_id)
  end
end # Game_Map









#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
# ** Reproduce Events
#    Author: Eshra
#    First Version: 21 Sept. 2012
#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
#
#   Allows events to be loaded from other maps in your project and placed on 
#   the current map. Also adds functionality for persistent events which will
#   stay on the map even if it is reloaded (switching maps or loading save 
#   files).
#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
#
#------------------------------------------------------------------------------
# * How to Use
#------------------------------------------------------------------------------
# Use the EventSpawn.spawn_event(...) to place an event on the map, see source
# the parameters it takes are:
#
# spawn_from_map_id - the id of the map the event will be spawned from
# event_id - the id of the event to spawn
# x - the x coordinate to place the event
# y - the y coordinate to place the event
# persistent - if the event is persistant
# init_dir - currently not used
# opts = {} - an optional hash representing the self switches that will be on when
#             the event is spawned
#
# Example: EventSpawn.spawn_event(2,15,$game_player.x+1, $game_player.y, false,2)
#
# Heavily modified aliases:
# straighten inside Game_CharacterBase
# events are now "straightened" to correspond to their original pattern, not 1
#
# tileset_bitmap inside Sprite_Character
# now checks if the character has a specific map which the bitmap should be 
# loaded from.
#

# Original Release Date: 7 Nov.2012
#
# Update Log
# June 4, 2013, Corrected alias to move_straight random event routes work now
# Novemeber 18, 2012: v0.2, Events can now be spawned by name.
# October 28, 2012: Can now remove spawned events.
# October 27, 2012: Finished adding support for persistent events, made code
#                   more extendible. Added code to allow use of tile graphics.
#
# Sepetember 21, 2012: Code reorganized made into it's own script for portability.
#
# August 2012: Version 0.0 completed

($imported ||= {})["Ra Event Spawn"] = 0.2

#==============================================================================
# * EventSpawn
#==============================================================================
module EventSpawn
  #----------------------------------------------------------------------------
  # * Constants
  #----------------------------------------------------------------------------
  module Constants
    SS = ['A','B','C','D']
    Tiles_On = true # can use tilesets from offscreen maps as event graphics
  end
  #----------------------------------------------------------------------------
  # * Spawn Event
  #----------------------------------------------------------------------------
  def self.spawn_event(spawn_from_map_id, _event_id, _x, _y, persistent, init_dir, opts = {}, name = nil)
    return unless SceneManager.scene_is?(Scene_Map)

    return if _event_id.nil? || spawn_from_map_id.nil?
    
    options = { :A => false, :B => false, :C => false, :D => false}.merge(opts)
    map = load_data(sprintf("Data/Map%03d.rvdata2", spawn_from_map_id))
    event_id = next_id
    
    _event_id = name.nil? ? _event_id : map.event_from_name(name).id # get from name if passed

    preprocessed_event = map.events[_event_id]

    preprocessed_event.id = event_id
    event = create_event(preprocessed_event, event_id)

    event.gen_from_map_id = spawn_from_map_id
    event.moveto(_x, _y)
    add_to_spmap(event)
    
    event.persistent = persistent
    persistent ? store_pev(event) : $game_map.spawned_event_ids.push(event_id)
    $game_map.need_refresh = true
    
    EventSpawn::Constants::SS.each{|letter|
      is_on = options[letter.to_sym]
      $game_self_switches[[$game_map.map_id, event_id, letter]] = is_on
    }
    return event
  end # End - spawn_event
  
  def self.next_id
    max_id = $game_system.max_evn_id
    keys = $game_map.events.keys
    id = keys==[] ? 1 : keys.max + 1
    max_id = id > max_id ? max_id = id : max_id+1
    
    $game_system.max_evn_id = max_id # store the largest event id used so far
    return max_id
  end
  #----------------------------------------------------------------------------
  # * Helper method
  #----------------------------------------------------------------------------
  def self.add_to_spmap(ev)
    spm = SceneManager.scene.instance_eval('@spriteset')
    sp_map_sps = spm.instance_eval('@character_sprites')
    sp_map_sps.push(Sprite_Character.new(spm.instance_eval('@viewport1'), ev))
  end
  #----------------------------------------------------------------------------
  # * Create Event
  #----------------------------------------------------------------------------
  def self.create_event(preprocessed_event, event_id)
    $game_map.events[event_id] = Game_Event.new($game_map.map_id, preprocessed_event)
  end
  #----------------------------------------------------------------------------
  # * Process Persistent Events
  #----------------------------------------------------------------------------
  def self.store_pev(event)
    sys = $game_system
    $game_map.spawned_event_ids.push(event.id) # note: ** 1
    (sys.persistent_events[$game_map.map_id] ||= []).push(event) # Set persistance data
    
    # Update the wrapped event's coordinates for reloading
    event.event.x = event.x
    event.event.y = event.y
  end # store_pev
  #----------------------------------------------------------------------------
  # * Set all selfswitches to false for the event on the current map
  #----------------------------------------------------------------------------
  def self.clean_self_switches(event_id)
    map_id = $game_map.map_id
    EventSpawn::Constants::SS.each{ |ch|
      $game_self_switches[[map_id,event_id,ch]] = false
    }
  end
end # EventSpawn

#==============================================================================
# * Game_System
#==============================================================================
class Game_System
 
  attr_accessor :persistent_events #stores persistent events information
  attr_accessor :max_evn_id # save the largest id used so far to prevent using
                              # the save id twice.
  #----------------------------------------------------------------------------
  # * Alias initialize
  #----------------------------------------------------------------------------
  alias reprod_evs_initialize_event_hash initialize
  def initialize
    reprod_evs_initialize_event_hash
    @persistent_events = {}
    @max_evn_id = 0
  end # End - initialize
  #----------------------------------------------------------------------------
  # * Alias on_after_load
  #----------------------------------------------------------------------------
  alias rep_evs_on_after_load on_after_load
  def on_after_load
    $game_map.remove_temporary_spawned_events #remove previously spawned events
    rep_evs_on_after_load
  end # on_after_load
  
end # Game_System

#==============================================================================
# * Game_Map
#==============================================================================
class Game_Map
  attr_reader :spawned_event_ids
  attr_accessor :spawned_event_ids
  attr_accessor :events
  #----------------------------------------------------------------------------
  # * Alias setup
  #----------------------------------------------------------------------------
  alias reprod_evs_game_map_setup setup
  def setup(map_id)
    $game_map.clean_self_switches
    @spawned_event_ids = Array.new #the ids of the events that have been spawned
    reprod_evs_game_map_setup(map_id)
  end # End - setup
  #----------------------------------------------------------------------------
  # * Alias setup_events
  #----------------------------------------------------------------------------
  alias ra_dep_setup_evs_al_meth setup_events
  def setup_events
    ra_dep_setup_evs_al_meth
    
    # Correct the self switches if there are persistent events on the map
    correct_self_switches if $game_system.persistent_events[@map_id] != nil
  end # End - setup_events
  #----------------------------------------------------------------------------
  # * Correct Self Switches
  #     Corrects $selfswitches hash so that they correctly correlate to the events'
  #     ids upon reloading the map (The ids may change b/c of removed events).
  #----------------------------------------------------------------------------
  def correct_self_switches
    p_events = $game_system.persistent_events[@map_id]
    new_self_switches = {}     # the new global self switch hash
    loaded_events = []
    @spawned_event_ids = []    # reset spawned events
    p_events.each{ |ev|
        
        #initialize new id and self_switches
        new_event_id = @events.keys.max + 1
        new_self_switches[new_event_id] = get_self_switches(ev.id)
        
        ev.event.id = new_event_id # update interior events id
        
        loaded_event = Game_Event.new(@map_id, ev.event)
        
        #update extra unhandled information for the new event
        loaded_event.persistent = true
        
        #place the new event in the map's event hash
        @events[loaded_event.id] = loaded_event
        
        loaded_events.push(loaded_event)
        @spawned_event_ids.push(loaded_event.id) #update spawned events
      } # End - p_events.each
      
      #update the persistent_events hash with the new information
      $game_system.persistent_events[@map_id] = loaded_events
      
      local_ss = $game_self_switches
      new_self_switches.keys.each{|id|
        count = 0
        EventSpawn::Constants::SS.each{ |letter|
          $game_self_switches[[@map_id,id,letter]] = new_self_switches[id][count]
          count += 1
        }
      }
      
      # Refresh the events so they are placed on the map on the correct page
      # also reset the ids of the events inside @spawned_event_ids
      @events.keys.each{ |id|
        @events[id].refresh
      }
      refresh_tile_events
  end # End - correct_self_switches
  #----------------------------------------------------------------------------
  # * Get Self Switches
  #     returns an array of the selfswitches for the given event id and then 
  #     deletes those values from $game_self_switches.
  #----------------------------------------------------------------------------
  def get_self_switches(event_id)
    local_ss = $game_self_switches
    vals = []
    EventSpawn::Constants::SS.each{ |letter|
      vals.push(local_ss[[@map_id, event_id, letter]])
      local_ss[[@map_id, event_id, letter]] = false
    }
    vals
  end # End - get_self_switches
  #----------------------------------------------------------------------------
  # * Clean Self Switches
  #     self-switches are handled globally, not on an event by event basis
  #     so the global hash needs to be cleaned out of all the temporarily
  #     spawned events when changing maps/loading the game, etc.
  #----------------------------------------------------------------------------
  def clean_self_switches
    local_ss = $game_self_switches
    
    return if @spawned_event_ids == nil 
    @spawned_event_ids.each{ |id|
      if !@events[id].persistent #don't clean up persistant event self switches
        EventSpawn::Constants::SS.each{ |letter|
          local_ss[[@map_id, id, letter]] = false #reset self_switches of temp events
        }
      end # End if
    }
  end # End - clean_self_switches
  #----------------------------------------------------------------------------
  # Removes all of the nonpersistent spawned events from the current map
  #----------------------------------------------------------------------------
  def remove_temporary_spawned_events
    return if @spawned_event_ids.nil?
    clean_self_switches
    clean_temp_evs_helper
    need_refresh = true
  end # End - remove_temporary_spawned_events
  #----------------------------------------------------------------------------
  # * Cleans out temporary events
  #----------------------------------------------------------------------------
  def clean_temp_evs_helper
    @spawned_event_ids.each{|id| @events.delete(id) unless @events[id].persistent}
    @spawned_event_ids = []
  end # End - clean_temp_evs_helper
  
  #---------------------------------------------------------------------------- 
  # * Removes an event from the current map, including persistant events
  #----------------------------------------------------------------------------
  def destroy_event_any(id)
    return unless !(ev = @events[id]).nil?
    EventSpawn.clean_self_switches(id)
    ev.set_intp_repr_ev(0)
    
    ev.erase # to hide the graphic
    
    if persistants = $game_system.persistent_events[@map_id]
      persistants.each_with_index{ |ev, i|
        if ev.id == id
          persistants.delete_at(i)
          break
        end
      }
    end
    
    @spawned_event_ids.delete(id)   # delete from array
    @events.delete(id)              #   "     "   hash
    
    refresh
  end
end # End - Game_Map

#==============================================================================
# * Game_Character
#==============================================================================
class Game_Character < Game_CharacterBase
  attr_accessor :gen_from_map_id           # map the event was generated from
end

#==============================================================================
# * Game_Event
#==============================================================================
class Game_Event < Game_Character
  attr_accessor :event                   # wrapped event
  attr_accessor :id                      # id of this event
  attr_accessor :persistent              # does event stay after switching maps
  
  #attr_accessor :init_dir                # used to specify direction with throw!
  #----------------------------------------------------------------------------
  # * Alias method initialize
  #----------------------------------------------------------------------------
  alias ra_extra_fields_dep_init initialize
  def initialize(map_id, event)
    ra_extra_fields_dep_init(map_id,event)
    @persistent = false
    #@init_dir = -1
  end # End - initialize
  
  #--------------------------------------------------------------------------
  # * Alias straighten - sets pattern to orig_pattern
  #--------------------------------------------------------------------------
  alias straight_ev_sp_ed_st_orig straighten
  def straighten
    straight_ev_sp_ed_st_orig
    @pattern = @original_pattern ? @original_pattern : 1 if @walk_anime || @step_anime
  end
   
  #--------------------------------------------------------------------------
  # * Alias move_straight - Store updated postion for persistent events
  #--------------------------------------------------------------------------
  alias move_str_ed_fr_persis_support move_straight
  def move_straight(dir, turn_ok = true)
    move_str_ed_fr_persis_support(dir)
    @event.x, @event.y = @x, @y if @persistent
  end
  
  #--------------------------------------------------------------------------
  # * Alias move_diagonal- Store updated postion for persistent events
  #--------------------------------------------------------------------------
  alias move_diag_ed_fr_pesis_support move_diagonal
  def move_diagonal(horz, vert)
    move_diag_ed_fr_pesis_support(horz, vert)
    @event.x, @event.y = @x, @y if @persistent
  end
  
  def set_intp_repr_ev(id)
    @interpreter.set_ev_id_repr_ev(id) unless @interpreter.nil?
  end
end # Game_Event

#==============================================================================
# * Sprite_Character
#==============================================================================
class Sprite_Character < Sprite_Base
  
  #--------------------------------------------------------------------------
  # * Alias tileset_bitmap - load tiles from offscreen maps
  #--------------------------------------------------------------------------
  alias ts_bm_sprt_fr_offscr_maps tileset_bitmap
  def tileset_bitmap(tile_id)
    
    if (id = @character.gen_from_map_id) && id > 0
       map = load_data(sprintf("Data/Map%03d.rvdata2", id))
      return Cache.tileset($data_tilesets[map.tileset_id].tileset_names[5 + tile_id / 256])
    else
      return ts_bm_sprt_fr_offscr_maps(tile_id) 
    end
    
  end # tileset_bitmap
  
end # Sprite_Character
#==============================================================================
# ** Game_Interpreter
#==============================================================================
class Game_Interpreter
  def set_ev_id_repr_ev(id)
    @event_id = id
  end # set_ev_id_repr_ev
end # Game_Interpreter
#==============================================================================
# ** RPG::Map
#==============================================================================
class RPG::Map
  #----------------------------------------------------------------------------
  # * Get Event From Name
  #----------------------------------------------------------------------------
  def event_from_name(name)
    @events.values.each{|ev| return ev if ev.name.eql?(name)}
    return nil
  end
end # RPG::Map












#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
# * Eshra Bouncy Text
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Author: Eshra
# Compatibility: RPG Maker VX Ace
# Release Date: Unreleased
# Dependencies: ** no dependencies **
#
#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
# Terms of Use
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# The script is free to use. 
#-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
#
#------------------------------------------------------------------------------
# * Installation
#------------------------------------------------------------------------------
#
# Place below materials and above main. ** no dependencies **
#
#------------------------------------------------------------------------------
# * How to Use
#------------------------------------------------------------------------------
#
# Use this to add some temporary text to the screen during Scene_Map which
# will bounce a bit, then disappear.
#
# Call add_bouncy_text_era(text, x = -1, y = -1) internally to add some bouncy
# text to the spriteset for scenemap. Call during Scene_Map.
#
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Upate Log
#
# 29 Oct. 2012 - Version 0.1 finished
#
#------------------------------------------------------------------------------

($imported||={})["Ra Bouncy Text"] = 0.1

#==============================================================================
# ** Spriteset_Map
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#     Add methods to support adding instances of Sprite_BouncyText to the spm
#==============================================================================
class Spriteset_Map
  #----------------------------------------------------------------------------
  # * Alias - initialize
  #----------------------------------------------------------------------------
  alias init_spgt_teserir_pam_spm_ali_era initialize
  def initialize
    init_spgt_teserir_pam_spm_ali_era
    create_bouncy_txt_arr
  end
  #----------------------------------------------------------------------------
  # * Alias - Dispose
  #----------------------------------------------------------------------------
  alias dis_sprmt_esopsi_disp_b_chars dispose
  def dispose
    dis_sprmt_esopsi_disp_b_chars
    dispose_bouncytext_era
  end
  #----------------------------------------------------------------------------
  # * Alias - Update
  #----------------------------------------------------------------------------
  alias etad_upd_sprm_txtbm_disp_era update
  def update
    etad_upd_sprm_txtbm_disp_era
    update_bouncytext_era
  end
  #----------------------------------------------------------------------------
  # * Create Sprite Garden Text Array
  #----------------------------------------------------------------------------
  def create_bouncy_txt_arr
    @bouncy_text_era = []
  end
  #----------------------------------------------------------------------------
  # * Update Sprite Garden Text
  #----------------------------------------------------------------------------
  def update_bouncytext_era
    return unless @bouncy_text_era
    @bouncy_text_era.each{|sp| sp.update}
  end
  #----------------------------------------------------------------------------
  # * Dispose Sprite Garden Text
  #----------------------------------------------------------------------------
  def dispose_bouncytext_era
    @bouncy_text_era.each{|spgt| spgt.dispose}
  end
  #----------------------------------------------------------------------------
  # * Add Sprite Garden to Spritesetmap
  #----------------------------------------------------------------------------
  def add_bouncy_text_era(text, x = -1, y = -1)
    @bouncy_text_era.push(Sprite_BouncyText.new(@viewport3).give(text,x,y))
  end
  
end # Spriteset_Map
#==============================================================================
# ** Sprite_BouncyText
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#     Displays bouncing text on the screen.
#==============================================================================
class Sprite_BouncyText < Sprite_Base
  #----------------------------------------------------------------------------
  # * Initialize
  #----------------------------------------------------------------------------
  def initialize(*args)
    super(*args)
    self
  end
  #----------------------------------------------------------------------------
  # * Give
  #----------------------------------------------------------------------------
  def give(text = "!", x = -1, y = -1)
    @bounce_min = 23
    @bounce_min_count = 0
    @val = -4
    x,y  = $game_player.x, $game_player.y if x == -1 && y == -1
    self.bitmap = Bitmap.new(200,35)
    self.bitmap.font.color.set(200,220,100)
    self.bitmap.font.size = 24
    self.bitmap.draw_text(0,0,200,35,text)
    self.y = ((@org_y = y) - $game_map.display_y)*32
    self.x = ((@org_x = x) - $game_map.display_x)*32
    self.ox = bitmap.width/5
    self.oy = bitmap.height/3
    @inc_x, @inc_y = 0, 0
    self
  end
  #----------------------------------------------------------------------------
  # * Update
  #----------------------------------------------------------------------------
  def update
    return if self.bitmap.disposed?
    
    if @bounce_min <= 0 
      self.opacity -= 5.5
      
      if !@set_new_org
        @org_x = self.x/32 + (map = $game_map).display_x
        @org_y = self.y/32 + map.display_y
        @off_dx = self.x % 32
        @off_dy = self.y % 32
        @set_new_org = true
      end
      
      self.x = (map = $game_map).adjust_x(@org_x) * 32 + @off_dx
      self.y = map.adjust_y(@org_y) * 32 + @off_dy
      self.bitmap.dispose if self.opacity <= 1
      return 
    end
    
    self.x = (@org_x - (map = $game_map).display_x) * 32
    self.x += @inc_x += 1
    self.y = (@org_y - map.display_y) * 32 
    self.y += (@inc_y += @val)
    self.zoom_x+=0.003
    self.zoom_y+=0.003
    
    @bounce_min_count += 5.5
    return if @val > 0 && @bounce_min_count/2 < @bounce_min
    
    if @bounce_min_count >= @bounce_min || (@val < 0 ? @bounce_min_count >= @bounce_min/2 : false)
      @val *= -1
      @bounce_min -= 7 if @val < 0
      @bounce_min_count = -@bounce_min_count/2
    end
  end # update
  #----------------------------------------------------------------------------
  # * Dispose
  #----------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
  end # dispose
end # Sprite_BouncyText


########################### END OF DEPENDENCIES ################################