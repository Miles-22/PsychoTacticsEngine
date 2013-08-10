#==============================================================================
# ** Era::AI
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#    Ai action calculation. Currently everything is calculated at once then all
#    moves are made which causes a very noticable delay on larger maps, this
#    will be changed later on, calculating paths one unit at a time or grouping
#    units, then calculating actions groups at a time.
#==============================================================================
module Era
  #--------------------------------------------------------------------------
  # Desired Basic Logic:
  #
  # Generate targets (choosing weakest unit)
  #   group units with the same targets so they can attack that unit together
  #   check if threat level is ok.
  #   if threat level is ok proceed with the attack on the target
  #   if threat level is too high try to run away. or get in a defensive formation
  #   or something.
  #
  # Old implementation:
  #   Pick an arbitrary skill to use from the skills list.
  #   Pick the closest player unit and mark it as a target
  #   move within range of using the skill or find a path to get within range
  #      over the next several turns
  #   use the skill.
  #--------------------------------------------------------------------------
  module AI
    TM = TactBattleManager
    DEF = TM::Defaults
    SHOW = :Movement_Hls
    DIRS = [:up, :down, :left, :right]
    RepickTries = 7 # number of times to pick a new location to move to, avoid
                    # lining up
    MAX_NO = 2147483647
    #--------------------------------------------------------------------------
    # * Unit Min Max
    #--------------------------------------------------------------------------
    def self.unit_min_max(unit)
      unit.calc_tb_limits
      mx,mn = unit.max_tb_rangeE, unit.min_tb_rangeE
      mx && mn ? [mn.id,mx.id] : []
    end
    #--------------------------------------------------------------------------
    # * Init Ai Vals
    #--------------------------------------------------------------------------
    def self.init_ai_vals
      @t1 = 0; @t2 = 0; @t3 = 0; @t4 = 0; @t5 = 0; @t6 = 0; @t7 = 0
      @move_taken = {}            # [x,y] => event id
      @move_taken_by_id = {}      # event id => [x,y]
      @delayed_moves = {}         # events => [x,y, skill_id]
      @attack_targets = {}        # enemy unit ids => locations
      $game_player.move_speed = 7 # for graphic when moving units
      
      @graphs = {}
      # gen_map_graphs(TactBattleManager.turn)#(team name) #Pass in current team here
    end
    #def self.old_speed; @old_speed; end
    #--------------------------------------------------------------------------
    # * Generate all map graphs
    #--------------------------------------------------------------------------
    def self.gen_map_graphs(team = TactBattleManager.turn, quick = false)
      
      @graphs = {}
      tm = TactBattleManager
      all_spec_edges = tm.all_spec_edges(team)
      
      # decide which graphs to generate based on data in all_spec_edges
      
      threads = []
      all_spec_edges.keys.each do |se|
        jump_len = se[0]
        jump = array_to_hash(se[1])
        spec_edges = {:jump_length => jump_len, :jump => jump, :pass => {}} # :pass => pass

        if cache_full_g?(se, all_spec_edges[se])
          threads.push(Thread.new{new_graph(spec_edges, se)})
        end
      end
      
      threads.each{|t| t.join} 
      #print "generated graphs for #{team}:\n#{@graphs}\n"
      @graphs
    end
    #--------------------------------------------------------------------------
    # * Generate graph for a unit
    #     Graph is still hashed only based on the spec_edges key which is not
    #     unique per unit. This is in acknowledgment of the old way the ai worked
    #     (calculating everything at once over all units).
    #--------------------------------------------------------------------------
    def self.gen_unit_graph(tbu)
      tm = TactBattleManager
      se = tbu.se_hash_key
      
      jump_len = se[0]
      jump = array_to_hash(se[1])
      spec_edges = {:jump_length => jump_len, :jump => jump, :pass => {}} # :pass => pass
      
      new_graph(spec_edges, se)
    end
    #--------------------------------------------------------------------------
    # * New Graph
    #--------------------------------------------------------------------------
    def self.new_graph(spec, key)
      g = TactBattleManager.ai_cache[:graph][key]
      g ||= Game_MapGraph.new.create_full_graph(spec)
      @graphs[key] = g
    end
    #--------------------------------------------------------------------------
    # * Optimization, decide if it's worth caching the full map graph or it if
    #     it would be better to just make smaller graphs for each of the units
    #     with param key
    #--------------------------------------------------------------------------
    def self.cache_full_g?(key, amt)
      map = $game_map
      
      size = map.width*map.height
      jump = key[0]/3 + 1
      
      graph_cost = size*4     # 4 edges evaluated for each vertex in graph
      jump_cost = jump*4      # jump in 4 dirs, no more than 'jump' iterations
      
      full_cost = graph_cost * jump_cost
      max_mv = TactBattleManager::Defaults::MaxAIMove
      sub_cost = max_mv*max_mv*4  # generate a sub graph side len = max_mv
      partial_cost = jump_cost * sub_cost
      (full_cost/partial_cost).to_i < amt
    end
    #--------------------------------------------------------------------------
    # * Converts an array to a hash table
    #--------------------------------------------------------------------------
    def self.array_to_hash(array)
      h = {}
      return h if array.nil?
      array.each{|element| h[element] = true}
      h
    end
    #--------------------------------------------------------------------------
    # * Routine
    # params:
    #   ctrl_sym, the symbol of the team the ai will be controlling.
    #   method_sym, the difficulty level of the ai
    #   enemies, list of symbols for the teams the ai will target: hostile
    #   friends, list of symbols for the teams the ai will target: friendly
    #--------------------------------------------------------------------------
    def self.routine(method_sym, ctrl_sym, options = {})
      init_ai_vals
      opts = {
              friends: [ctrl_sym], 
              enemies: [TactBattleManager::PLAYER]
             }.merge(options)
      method(:easy).call(ctrl_sym)
    end
    #--------------------------------------------------------------------------
    # * Can move to postion xy?
    #--------------------------------------------------------------------------
    def self.xy_ok?(x,y);$game_map.event_id_xy(x,y)==0; end
    #--------------------------------------------------------------------------
    # * Closest Player Unit
    #--------------------------------------------------------------------------
    def self.closest_target_unit(x,y, options = {})
      tm = TactBattleManager
      
      opts = {
        move: 5,      teams: [tm::PLAYER],
        tb_unit: nil, ev_id: -1
      }.merge(options)
      
      ev = $game_map.events[opts[:ev_id]]
      tbu = opts[:tb_unit]
      move_d = tbu ? tbu.move : opts[:move]
      too_close_dist = MAX_NO
      targets = opts[:teams]
      
      mx,my = -1, -1
      
      potential_targets = [] # list of potential targets.
      # potentials_low_hp = {}
      
      # 1. Target units based on which one is likely to die, 2. which one will
      # be very low on health after the attack 3. which unit will take the most
      # damage.
      
      # need to choose a high priority target, then see if that unit can be
      # targeted using some skill, if it can be then choose that unit.
      
      # Logic to use
      # Note all units with the close range (can be reached in 1 turn). If
      # no units in close range, double the close range, etc.
      #
      # Determine highest priority target from the units in the close range.
      
      tbu.battler.calc_tb_limits
      
      #print "tbu.battler.max_tb_rangeE = #{tbu.battler.max_tb_rangeE}\n"
      #print "tbu.battler.max_tb_rangeF = #{tbu.battler.max_tb_rangeF}\n"
      
      # need to make sure the skill is an offensive skill, not a friendly use
      # skill
      
      #print "battler.move_action_lmt #{tbu.battler.move_action_lmt}\n"
      #print "battler.attack_action_lmt #{tbu.battler.attack_action_lmt}\n"
      #print "battler.skill_action_lmt #{tbu.battler.skill_action_lmt}\n"
      #print "battler.all_action_lmt #{tbu.battler.all_action_lmt}\n"
      #print "tbu.max_possible_acts(:move) #{tbu.max_possible_acts(:move)}\n"
      
      # need to take into consideration action limits. Tricky to determine best
      # order to use actions in, for now just determine if the unit can attack/skill
      # and move once or do either one at least once.
      
      if tbu
        battler = tbu.battler
        supporter = battler.is_support_unit
        minsk, maxsk = -1, -1
        if supporter
          maxsk = battler.max_tb_rangeF; minsk = battler.min_tb_rangeF
        else
          maxsk = battler.max_tb_rangeE; minsk = battler.min_tb_rangeE
        end
        
        
        # s = tbu.battler.max_tb_rangeE
        mod = maxsk ? maxsk.tb_range_max : 0
        tmp_r = tbu.max_possible_acts(:move)
        close_unit_d = (tbu.move * tmp_r) + mod 
        #close_unit_d = (tmp_r * tmp_r) + 1 # if unit dist <= this then it's close
        
        mod = minsk ? [minsk.tb_range_min - tbu.move,0].max : 0
        
        # print "minsk.tb_range_min = #{minsk.tb_range_min}\n"
         #print "mod #{mod} minsk.tb_range_min - tbu.move #{minsk.tb_range_min - tbu.move}\n"
        too_close = [mod*mod,0].max # minimum distance targetable
        
        # print "closest_target_unit move_d = #{close_unit_d}\n"
        # print "too close = #{too_close}\n"
      end
      
      # print "before potential_targets too_close = #{too_close}\n"
      potential_targets=find_potential_h(x,y,targets,
              close_unit_d,too_close,tbu.move)
      
      # print "#{$game_map.events[tbu.event_id]}: potential targets = #{potential_targets.inspect}\n"
      # for now just use first while writing rest of this, need to retry getting
      # target pool if pool is empty here.
      
      potential_targets = order_potents(potential_targets, ev)
      
      # print "#{potential_targets}\n"
      
      if (pt = potential_targets[0])
        p_ev = $game_map.events[pt]
        print "target_event = #{p_ev} for #{ev}\n"
        mx,my = p_ev.x, p_ev.y
      end
      
      $game_map.tbu_id_xy(mx, my)
    end # closest_target_unit
    #--------------------------------------------------------------------------
    # * Order Potential Targets
    #     targets ordered based on how much damage unit can do to them (or heal
    #     them for).
    #
    #     params
    #       targets, array of potential targets to order
    #       tbu, the unit that will be targeting the potentials
    #--------------------------------------------------------------------------
    def self.order_potents(targets, ev)
      return targets if !(tbu = ev.tb_unit)
      # print "tbu = #{tbu}\n"
      battler = tbu.battler
      supporter = battler.is_support_unit
      map_evs = $game_map.events
      
      skills = battler.skills
      
      # maps event_id => {skill_ids => [hp percent left, mp...] }
      damage_table = {}
      
      # Going to choose the skill to use here. Afterwards need to determine
      # ranges based on the skill that was chosen here (wrt each enemy).
      
      # can check if skill is usable on unit based on range of skill. if skill
      # not usable then don't use that skill when deciding high priority target
      # + skill usage combination.
      
      # high priority unit is wrong if can't target that unit with the skill that
      # was chosen to hit that unit with in 1 turn?
      
      targets.each do |id|
        
        tgt = map_evs[id]
        tgt_bat = tgt.tb_unit.battler
        damage_table[id] = {}
        
        skills.each do |sk|
        
          skill_id = sk.id
          res = invoke_on_target(tgt, ev, sk, true, true)
          
          res_hp = [tgt_bat.hp - res.hp_damage , 0].max
          res_mp = [tgt_bat.mp - res.mp_damage , 0].max
          
          hp_pctleft = res_hp.to_f/tgt_bat.mhp
          mp_pctleft = res_mp.to_f/tgt_bat.mmp
          
          damage_table[id][skill_id] = [hp_pctleft, mp_pctleft]
        end
      end
      
      # print "damage_table = #{damage_table.inspect}\n"
      
      semi_ord = {}
      damage_table.keys.each do |tEv_id| 
        semi_ord[tEv_id] = skill_to_pick(tEv_id, ev.id, damage_table[tEv_id])
      end
      
      # print "semi_ord #{semi_ord.inspect}\n"
      
      tgts = semi_ord.keys
      
      tgts.sort! do |a,b|
        
        # max_times = [semi_ord[a].size,semi_ord[b].size]
        # i = 0
        reachA, reachB = nil, nil
        # sk_dataA, sk_dataB = nil, nil
        # aCount, bCount = 0,0
        ret = nil
        
        # while(!reachA && !reachB && i < max-times) do
          sk_dataA = semi_ord[a][0] ||= [-MAX_NO, false] # skill data
          sk_dataB = semi_ord[b][0] ||= [-MAX_NO, false]
          
          # print "sk_dataA #{sk_dataA}, sk_dataB #{sk_dataB}\n"
          
          reachA, reachB = sk_dataA[1], sk_dataB[1]
          
          if !reachA && reachB
            ret = 1 
          elsif reachA && !reachB
            ret = -1 
          else
            ret = damage_table[a][sk_dataA[0]].min <=> damage_table[b][sk_dataB[0]].min
          end
          #(aCount+=1; next) if !reachA
          #(bCount+=1; next) if !reachB
          
          # print "reachA #{reachA}, reachB #{reachB}\n"
          # print "damage_table[a][sk_dataA[0]] #{damage_table[a][sk_dataA[0]]}\n"
          # print "damage_table[b][sk_dataB[0]] #{damage_table[b][sk_dataB[0]]}\n"
          
          #i += 1
        # end
        
        #damage_table[a][sk_dataA[0]].min <=> damage_table[b][sk_dataB[0]].min
        ret
      end
      
      print "tgts #{tgts} skills: \n"
      tgts.each{|t| print "   #{semi_ord[t][0]}\n"}
      
      tgts
    end
    #--------------------------------------------------------------------------
    # * Pick a  high priority skill to use on event (with id ev_id)
    #     params
    #       tEv_id, id of the event skill is being used on
    #       uEv_id, id fo the event using the skill
    #       sk_data, hash of resultant % of hp/mp target has after using skill
    #                   {id => result hp/mp, ... }
    #--------------------------------------------------------------------------
    def self.skill_to_pick(tEv_id, uEv_id, sk_data)
      evs = $game_map.events
      tgt_ev, user_ev = evs[tEv_id], evs[uEv_id]
      
      rev_hash = {} # invert hash so sk_data values can be sorted retaining keys
      ordered = []
      dist = dist_to_p(tgt_ev.x, tgt_ev.y, user_ev.x, user_ev.y)
      move_d = user_ev.tb_unit.move
      
      kv_pairs = []
      sk_data.keys.each{ |k| kv_pairs.push([k, sk_data[k]]) }
      
      # kv pairs has key, [hp left, mp left] so take min of hp/mp left
      kv_pairs.sort!{|a,b| a[1].min <=> b[1].min}
      
      # print "kv_pairs #{kv_pairs}\n"
      
      kv_pairs.each_with_index do |kv, i|
        sk_id = kv[0]
        skill = $data_skills[sk_id]
        
        next if !skill.tbs_simple_range # only eval simple ranges for now
        
        # check if it looks like target is reachable in 1 turn with skill
        reach_1_turn = move_d + skill.tb_range_max >= dist
        reach_1_turn = reach_1_turn && skill.tb_range_min - move_d <= dist
        
        if reach_1_turn
          ordered.push([sk_id, true]) # skill id, looks reachable 1 turn
          kv_pairs[i] = nil
        end
      end
      
      kv_pairs.each{ |kv| ordered.push([kv[0], false]) if kv}
      
      # print "ordered = #{ordered.inspect}\n"
=begin
      sk_data.keys.each{|k| rev_hash[sk_data[k]] = k}
      rKeys = rev_hash.keys.sort!
      
      rKeys.each do |res_hmp|
        
        skill = $data_skills[rev_hash[res_hmp]]
        print "init eval skill #{skill}\n"
        next if !skill.tbs_simple_range # only eval simple ranges for now
        
        reach_1_turn = move_d + skill.tb_range_max >= dist
        reach_1_turn = reach_1_turn && skill.tb_range_min - move_d <= dist
        
        print "tg #{tgt_ev} r1turn? #{reach_1_turn} skill #{skill} range_max #{skill.tb_range_max}\n"
        
        if reach_1_turn                 # reachable in 1 turn
          prioritized.push(rev_hash[res_hmp]) 
          rev_hash[res_hmp] = nil       # used so clear for next iteration
        end
        
      end
      
      print "early prioritized = #{prioritized.inspect}\n"
      
      rKeys.each{ |k| s_id = rev_hash[k]; prioritized.push(s_id) if s_id }
      
      print "later prioritized = #{prioritized.inspect}\n"
=end
      ordered
    end
    #--------------------------------------------------------------------------
    # * Find potential targets helper
    #--------------------------------------------------------------------------
    def self.find_potential_h(x,y,targets, max_d, too_close, b_move, tts = 0)
      return [] if tts >= 6 # only inc. search size 4 times for now
      tm = TactBattleManager
      potential_targets = []
      targets.each do |target|
        
        tm.units[target][:event].values.each do |ev|
          
          ex,ey=ev.x,ev.y
          #x_diff = ex > x ? ex-x : x-ex
          #y_diff = ey > y ? ey-y : y-ey
          
          dist = dist_to_p(x,y,ex,ey)#x_diff*x_diff + y_diff*y_diff
          
          #print "dist #{dist} max_d #{max_d} too_close #{too_close}\n"
          
          potential_targets.push(ev.id) if dist <= max_d && dist>=too_close
        end
        
      end # targets.each
      ret = potential_targets
      
      if potential_targets.empty?
        too_close = [too_close - b_move,0].max
        ret = find_potential_h(x,y,targets, max_d * 2, too_close, b_move*2, tts+1)
      end
      
      ret
    end
    #--------------------------------------------------------------------------
    # * when param: close_d, calculate minimum distance greater than or equal to 
    #     close_d
    #     param no_xy is an array of coordinates not to choose.
    #     keep_d is the minimum distance this unit would like to keep between
    #     itself and its target, not applied yet. Aim to be as far away as
    #     possible while still attacking (close_d) but if that is not possible
    #     simply take something within the range of close_d.
    #
    #  params:
    #     x,y - target x,y location to find points near
    #     cx, cy - location of unit targeting x,y
    #     range - of points to pick from
    #     close_d - the closest preferred distance to x,y
    #     no_xy - array of invalid points that may appear in the range.
    #--------------------------------------------------------------------------
    def self.closest_to_xy_in_range(x,y,range, cx = nil, cy = nil, close_d = nil,
      no_xy = nil, keep_d = nil)
      
      # METHOD NOT RETURNING CORRECT POINT ATM 8 5 2013
      # 
      # Cannot just add distances to curr to the new poin and from the new point
      # to target.
      #
      # For long range units still need to add in a second parameter in pair
      # with close_d. This parameter would tell the unit to aim for a square that
      # is within close_d and inner_d away if it can't quite reach close_d.
      
      # print "closest_to_xy_in_range\n"
       print "x,y #{x},#{y} cx,cy #{cx},#{cy} close_d #{close_d}\n"
       
      
      nxt_bestx, nxt_besty, nxt_bestd = -1, -1, MAX_NO # next best options
      
      if cx && cy
        # print "\ncx and cy passed in ~!\n"
        xd, yd = (cx-x).abs, (cy-y).abs 
        range.push(Vertex.new(cx,cy))
        # print "pushed new vertex into range #{cx},#{cy}\n"
      end
      
      # print "range length: #{range.size}\n range = #{range}\n"
      
      # curr_cd is the distance to get to the current point from the point with
      # the current minimal distance. Must choose minimal point first then 
      # inimal cd point.
      min_d, curr_cd, mx, my = MAX_NO, MAX_NO, -1,-1
      #if close_d
      #  close_d = (close_d-close_d/2) 
      #end
       
      #if close_d && (cx || cy)
      #  t=xd*xd+yd*yd
      #  close_d < t ? (min_d,mx,my = t, cx, cy) : (min_d, mx, my=1<<31,-1,-1)
      # else
      # min_d,mx,my = (!cx || !cy || close_d ? 1<<31 : xd*xd + yd*yd),cx, cy
      #end
      
      range.each do |v| vx, vy = v.x, v.y
        next unless xy_ok?(vx, vy) if vx != cx && vy != cy
        d = dist_to_p(x,y,vx,vy)       # distance to target location
        cd = dist_to_p(cx, cy, vx, vy) # distance to current unit
        # d+=cd if !close_d || close_d == 0
        # combd = d + cd
        dcd = d# + cd
        # print "d, x, y, vx, vy #{d}, #{x}, #{y}, #{vx}, #{vy}\n"
        ok = !no_xy.include?([vx,vy])
        if ok && (close_d - d).abs < (close_d - nxt_bestd).abs
          nxt_bestd, nxt_bestx, nxt_besty = d, vx, vy
        end
        
        if ok
          if close_d
            # print "checking d #{d} x,y #{vx},#{vy} close_d #{close_d} min_d #{min_d}\n"
            if d >= close_d && dcd < min_d
              (mx,my,min_d=vx,vy,dcd) 
              curr_cd = cd
              # print "new min_d #{min_d} x,y #{mx}, #{my}\n"
            elsif d == min_d && cd < curr_cd
              (mx,my,min_d=vx,vy,dcd) 
              curr_cd = cd
            end
          else
            # print "no close_d ??? close_d = #{close_d}\n"
            (mx,my,min_d=vx,vy,dcd) if dcd < min_d
          end
        end
        
        #(mx,my,min_d=vx,vy,d) if ok&&(close_d ? d >= close_d && min_d >= d : min_d >= d)
        # print "mx,my #{mx},#{my} min_d #{min_d} d #{d} close_d #{close_d}\n"
      end
      
      #print "min_d = #{min_d}\n"
      #print "mx, my are -1\n" if mx == -1 && my == -1
      mx = nxt_bestx if mx == -1
      my = nxt_besty if my == -1
      #print "mx, my = #{mx}, #{my}\n"
      Vertex.new(mx,my)
    end
    #--------------------------------------------------------------------------
    # * Dist to point
    #--------------------------------------------------------------------------
    def self.dist_to_p(sx,sy,fx,fy)
      #xd,yd= sx > fx ? sx-fx : fx-sx, sy > fy ? sy-fy : fy-sy
      #xd*xd+yd*yd
      (sx-fx).abs + (sy-fy).abs     # not distance formula
    end
    #--------------------------------------------------------------------------
    # * Step along a larger path param 'steps' number of times
    #     adds locations to tb units valid moves if a tb_unit is passed
    #   params: min_d is closest allowable distance from tx,ty
    #--------------------------------------------------------------------------
    def self.path_from_steps(v,steps,path, distances, event, min_d = nil,
        tx=nil,ty=nil,p_event = nil)
      rpath, npath, cur = {}, [], v; length = 0; min_d*=min_d if min_d
      tu = event.tb_unit
      
      begin
        npath.push(cur) 
        cur = path[cur]; length += 1
      end while(path[cur] != cur); # path[v] == v when at first vertex in path
        
      fx,fy = nil,nil; no = [steps,length].min; i = 0; mod = 1
      too_close = min_d>=dist_to_p(event.x,event.y,tx,ty) # move as far away
                            # as possible if already closer than want to be
                            # choose closest open xy along path
      print "too_close = #{too_close}\n"                      
      # jumps are not actually considered here, they are considered one move
      # remember to actually calculate how far away the next square on the path is.
      while i > -1 && i < no
        walk = npath[length-1-i]; org = path[walk]
        rpath[walk] = org
        tu.add_valid_move(walk) if mod == 1
        
        if i == no-1 && walk 
          if @move_taken[[fx = walk.x,fy=walk.y]] || (min_d >= dist_to_p(tx,ty,fx,fy)&&!too_close)
            mod = -1; i += mod; 
            rpath.delete(walk) # so the highlight won't show up
            next
          else break end
        end
        
        if walk&&!@move_taken[[fx=walk.x,fy=walk.y]]&&mod==-1&&min_d<dist_to_p(tx,ty,fx,fy)
          break
        elsif mod == -1
          rpath.delete(walk) # so the highlight won't show up
        end
        fx,fy = nil,nil; i+=mod 
      end
      
      already_there = fx == p_event.x && fy == p_event.y
      delay = true if !$game_map.cache_ids_xy(fx,fy).empty? && !already_there
      
      print "fx, fy = #{fx}, #{fy}\n"
      # if delayed just try to move to a different fx,fy
      
      if fx && fy 
        @move_taken[[fx, fy]] = tu.event_id 
        @move_taken_by_id[tu.event_id] = [fx,fy] # for quickly deciding if an 
                                                 # event has decided to move
        v = Vertex.new(fx,fy)
      else v = Vertex.new(-1<<31,-1<<31) end
      [rpath, v, delay, distances]
    end
    #--------------------------------------------------------------------------
    #   :friend, :hostile, :neutral => 
    #             {:amounts => {name => quantity,...}},
    #             {:event => {id => event,...}}
    #--------------------------------------------------------------------------
    def self.easy(units_sym = TactBattleManager.turn)
      tm = TactBattleManager
      
      events = tm.units[units_sym][:event].values
      events.each{ |e| tm.queue_start_act(e.id) }

      # queue_start_act
      return
      
      # define locals
      
      events = tm.units[units_sym][:event].values
      events.each{ |e| easy_main_routine(e.id) }

      # eval_delays
    end
    #----------------------------------------------------------------------------
    # * Evaluate all delayed events. Param, push is false when it's not necessary
    #     to add the event to the start queue.
    #----------------------------------------------------------------------------
    def self.eval_delays(push = true)
      map = $game_map
      @delayed_moves.keys.each do |ev_id|
        event = map.events[ev_id]
        move_delayed(ev_id, event, push) if can_move?(ev_id)
      end 
    end
    #----------------------------------------------------------------------------
    # * Push command to act for an event who needed to wait to check if it could
    #     move.
    #----------------------------------------------------------------------------
    def self.move_delayed(ev_id, event, push)
      move_data = @delayed_moves[ev_id]
      dest = move_data[1]
      event.give_path(move_data[0])
      event.give_distances(move_data[3])
      act_start(event.id)
      give_move_command(event, dest.x, dest.y)
      ats = @attack_targets[ev_id]
      give_use_command(ats[0],ats[1],ats[2],:SKILL,ev_id)
      act_end(event.id, push)
    end
    #----------------------------------------------------------------------------
    # * Routine used for each thread is passed when calculating a units moves
    #     this turn.
    #----------------------------------------------------------------------------
    def self.easy_main_routine(id, options = {})
      
      init_ai_vals # take out for original method
      
      map = $game_map
      ev = map.events[id]
      ev_id = id
      tm = TactBattleManager
      
      gen_unit_graph(ev.tb_unit)
      
      opts = {teams: [tm::PLAYER], tb_unit: ev.tb_unit, 
              :ev_id=>ev.id }.merge(options)
      cps = closest_target_unit(ev.x,ev.y, opts)
      
      
      return unless top_ev = map.events[cps]
      return unless (t=map.events[ev_id].tb_unit) && t.battler
      
      ev.add_target_tb(top_ev)
      
      # Must do test to see if target actually can be reached, if it can't,
      # go to next highest priority target
      
      tbu = ev.tb_unit
      bat = tbu.battler
      
      friend_target = opts[:teams].include?(tbu.team)
      
      # print "target is friend = #{friend_target}\n"
      skill = friend_target ? bat.max_tb_rangeF : bat.max_tb_rangeE
      
      ms_data = [skill.tb_range_max, skill.id]
      
      @attack_targets[ev_id] = [top_ev.x, top_ev.y, ms_data[1]]
      
      min_d = ms_data[0] < 2 ? 0 : ms_data[0]
      gcd = path_over_turns(ev,top_ev.x,top_ev.y, 
              min_d ,tm::Defaults::AdvAITurns)
      
      # print "ms_data = #{ms_data.inspect} gcd = #{gcd}\n"
      
      if gcd != :DELAYED
        act_start(ev.id)
        give_move_command(gcd[0], gcd[1], gcd[2])
        give_use_command(top_ev.x,top_ev.y,ms_data[1],:SKILL,ev.id)
        act_end(ev.id)
      else
        ev.acts_done_tb = true # just skip this event for now if it needs to pick
                               # a new location to move to.
      end
      
      #print "\n~~~~~~~~~~~~~~~~\ngcd = #{gcd}\n~~~~~~~~~~~~~~~~\n" if id == 8
    end
    #----------------------------------------------------------------------------
    # * Save an event's list
    #----------------------------------------------------------------------------
    def self.reset_and_save_list(id)
      event = $game_map.events[id]
      event.save_list_tb # save old commands before resetting + giving move commands
      event.list = [] 
    end
    #----------------------------------------------------------------------------
    # * Give start actions command
    #----------------------------------------------------------------------------
    def self.act_start(id)
      return if !(event=$game_map.events[id])
      
      tm = TactBattleManager
      reset_and_save_list(id) # if reset
      event.list.push(RPG::EventCommand.new(355,0,["start_acts_tb"]))
      event.acts_done_tb = false
    end
    #----------------------------------------------------------------------------
    # * Give finished actions command
    #----------------------------------------------------------------------------
    def self.act_end(id, push = false) # default was true
      return if !(event=$game_map.events[id])
      
      tm = TactBattleManager
      event.list.push(RPG::EventCommand.new(355,0,["end_acts_tb"]))
      TM.queue_start_act(id) if push
    end
    #----------------------------------------------------------------------------
    # * Start an event
    #----------------------------------------------------------------------------
    def self.start_event(id)
      event = $game_map.events[id]
      return print "TRIED TO START EVENT BUT NOT ON MAP!" if !event
      event.list.push(RPG::EventCommand.new(0,0,[]))
      $game_player.start_map_event_prox(id, [0,1,2], true)
    end
    #----------------------------------------------------------------------------
    # * Use Command
    #----------------------------------------------------------------------------
    def self.give_use_command(tx,ty,item_id,item_type,user_id)#, restore = true, reset_list = false, start = true)
      return if !(event=$game_map.events[user_id]) || item_id.nil?
      tm = TactBattleManager
      item_type = item_type == :SKILL ? 1 : (item_type == :ITEM ? 0 : -1)
      event.list.push(RPG::EventCommand.new(355,0,["use_item_tb_era(#{tx},#{ty},#{item_id},#{item_type},#{event.direction})"]))
      event.list.push(RPG::EventCommand.new(355,0,["turn_towards_tb(#{tx},#{ty})"]))
      event.list.push(RPG::EventCommand.new(230,0,[DEF::Speed])) # tm.tb_speed wait 40 frames after using skill
      event.list.push(RPG::EventCommand.new(355,0,["remove_hls"]))
    end
    #---------------------------------------------------------------------------
    # * Execute movement command
    #---------------------------------------------------------------------------
    def self.give_move_command(event, fx = $game_player.x, fy = $game_player.y)
      return unless event
      x,y = event.x, event.y
      event.list.push(RPG::EventCommand.new(355,0,["mvtb_cursor(#{x}, #{y})"]))
      event.list.push(RPG::EventCommand.new(355,0,["show_hls(#{x}, #{y})"]))
      event.list.push(RPG::EventCommand.new(230,0,[DEF::Speed]))
      event.list.push(RPG::EventCommand.new(355,0,["mvtb_cursor(#{fx}, #{fy})"]))
      event.list.push(RPG::EventCommand.new(355,0,["execute_dynamic_route(#{fx}, #{fy})"]))
      event.list.push(RPG::EventCommand.new(355,0,["remove_hls"]))
    end
    #--------------------------------------------------------------------------
    # * can_move?
    #--------------------------------------------------------------------------
    def self.can_move?(event_id)
      move_data = @delayed_moves[event_id] # [0]= path, [1] = dest, [2] = delayed?
      dest = move_data[1]
      ids = $game_map.cache_ids_xy(dest.x,dest.y)
      ids.each{|id| return false if !will_move?(event_id, id)}
      return true
    end
    #---------------------------------------------------------------------------
    # * Recursive method, checks if the unit at one location will move then 
    #     the unit at the location it wants to move to, and so on to see if
    #     the 'next' space will be open for the event with param: first_id
    #---------------------------------------------------------------------------
    def self.will_move?(first_id, curr_id)
      map = $game_map
      curr_event = map.events[curr_id]
      return true if first_id == curr_id
      return false if (xy=@move_taken_by_id[curr_id]).nil?
      return false if curr_event.x == xy[0] && curr_event.y == xy[1]
      ids = $game_map.cache_ids_xy(xy[0],xy[1])
      return true if ids.empty? 
      ids.each{|id| return will_move?(first_id, id)}
    end
    #--------------------------------------------------------------------------
    # * Logic to get close to a unit over multiple turns
    #--------------------------------------------------------------------------
    def self.path_over_turns(event,fx,fy,min_d,turns)
      return unless event.tb_unit
      
      tm = TactBattleManager
      sx,sy,tb_unit = event.x,event.y,event.tb_unit
      max_mv = tm::Defaults::MaxAIMove
      event_id = event.id
      
      move_d = [tb_unit.move * turns, max_mv].min
      range_util = Unit_Range.new
      
      # g = tm.ai_cache[:graph][event_id]   # check if this event's graph was cached
      g ||= @graphs[tb_unit.se_hash_key]  # should not happen that the event's graph was
                                          # calculated twice but for now check both
      t = Time.now
      # p = tm.ai_cache[:path][event_id]
      # d = tm.ai_cache[:dist][event_id]
      
      x, y, locs = event.x, event.y, nil
      
      if p && d
        event.give_path(p)
        event.give_distances(d)
        locs = range_util.get_range(x,y,0,move_d, event)
      else
        
        # For now cheat a little bit, always give the unit a chance to move 
        #   twice as far as its minimum desired distance. 
        
        # mindd2 = min_d * 2
        # move_d = mindd2 if move_d < mindd2
        
        locs = range_util.calc_range(x,y, 0, move_d, event, move_d, g)
      end
      # print "min_d = #{min_d}\n"
      # final implementation should probably do something like, generate 3 points
      # the event wants to move to, ordered by priority. If they can't move
      # to the first, try the second, if no, try the third, if no, try to move
      # as close to the first as possible, etc.
      
      delayed = true; max_tries = RepickTries;  count = 0
      data = [nil,nil,true]; choice = nil; bad_choice = []
      first_ok = nil
      re_try = true
      while(re_try && max_tries > count)
        choice = closest_to_xy_in_range(fx,fy,locs,x,y,[min_d,0].max, bad_choice)
        print "choice = #{choice}\n"
        bad_choice.push([choice.x,choice.y])
        
        
        # get the sub path that the unit will be able to walk along this turn
        tb_unit.empty_valid_moves
        data = path_from_steps(choice,tb_unit.move,range_util.path, 
          range_util.distances, event,min_d,fx,fy,event)
          
        first_ok = Marshal.load(Marshal.dump(data)) if !first_ok && !data[2]
        
        print "data[1] = #{data[1]} choice #{choice}\n"
        
        
        if !data[1].eql?(choice)
          print "\n\nCHOICES + RESULT DON'T MATCH\n\n" 
          re_try = true
        else
          re_try = data[2]
        end
        #  re_try = true
        #else
        #  re_try = data[2]
        #end
        
        #data[2] = true if !data[1].eql?(choice) # pick again if couldn't reach
        #delayed = data[2]
        
        count+=1
      end
      
      data = first_ok if !data[2]
      
      # print "all choices evaled = #{bad_choice.inspect}\n"
      
      if data[2] # need to delay giving movement command
        @delayed_moves[event.id] = data
        
        print "Cant move to location, tried #{data[1].x},#{data[1].y}\n"
      else
        path, travelp, ds = data[0], data[1], data[3]
        event.give_path(path)
        event.give_distances(ds)
        
        # maybe try an implementation that allows the events to pick a second location
        # if they find they are still outside of their target range after moving to
        # their available position.
        
        return [event, travelp.x, travelp.y, true]# command params
      end  
      return :DELAYED
    end
    
    #--------------------------------------------------------------------------
    # * Skill Range Max
    #--------------------------------------------------------------------------
    #def self.skill_range_max(event_id)
    #  return if (tb_unit = (t=$game_map.events[event_id]) ? t.tb_unit : nil).nil?
    #  skill_id, max = nil, -2
    #  tb_unit.battler.skills.each{ |s|
    #    next if s.nil? || (r_max = s.tb_range_max).nil?
    #    (max, skill_id = r_max, s.id) if r_max > max
    #  }
    #  [max, skill_id]
    #end
    #----------------------------------------------------------------------------
    # * Recalculate aoe target
    #     Aoe skills may not necessarily want to target the specific unit they are
    #     trying to hit. It my be better to target a location on the map. This
    #     method gets passed the target x and y, tx,ty and returns the position
    #     that should be targetted to hit that target in an optimal fashion.
    #     i.e. minimizing damage to own units and maximizing amount of units
    #     healed, etc.
    #
    #     calling this method also changes the direction of the event using the
    #     skill if necessary to hit target.
    #
    #     returns array => [target x,target y,dir event should face when using
    #----------------------------------------------------------------------------
    def self.aoe_target(tx,ty,dir, tb_item, tb_event_id, opts = {})
      tm = TactBattleManager; units = tm.units
      u,d,l,r = DIRS[0], DIRS[1], DIRS[2], DIRS[3]
      hit_dir = nil # direction to turn event when using skill
      
      options = { :team => tm.turn, :heal => false,
                  :target_teams => [tm::PLAYER]}.merge(opts)
      healing = options[:heal]; team = options[:team];
      target_teams = options[:target_teams]
      
      # print "team = #{team}, units[team] = #{units[team]}\n"
      
      range = (t=tb_item.tbs_spec_range) ? t[dir] : tb_item.tbs_simple_range
      
      aoe_range = tb_item.tbs_aoe_range

      all_ranges = nil
      
      if t # tb_item.tbs_spec_range
        all_ranges = {}
        up, down, left, right = t[u], t[d], t[l], t[r]
        all_ranges[u], all_ranges[d] = up, down
        all_ranges[l], all_ranges[r]  = left, right
      end
      
      # print "all_ranges = #{all_ranges.inspect}\n"
      # print "aoe_range #{aoe_range}\n"
      # print "tb_event_id #{tb_event_id}\n"
      
      new_target = nil
      targets = {}; targets[:hit] = {}; targets[:data] = {}
      optimal_xy = nil
      
      map = $game_map
      event = map.events[tb_event_id]
      
      # calculate preferred direction to use when attacking. turn_towards_tb
      pref_dirs = pref_turn_dirs(tb_event_id, tx, ty)
     
      print "pref_dirs = #{pref_dirs.inspect}\n"
      
      range.each do |rv| 
        x,y = rv.x + event.x, rv.y + event.y
        targets[:data][[rv.x,rv.y]] = {}
        
        aoe_range.keys.each do |dir|
          aoe_range[dir].each do |aoev|
          
            if x+aoev.x == tx && y+aoev.y == ty
              targets[:hit][[x, y]] = dir 
              # print "Registered a hit at #{x},#{y} dir #{dir} pref_dirs.include?(dir #{pref_dirs.include?(dir)}\n"
            end
            targets[:data][[rv.x,rv.y]][:same_team] ||= 0
            ids_xy = map.cache_ids_xy(x+aoev.x,y+aoev.y)
            ids_xy.each do |id|
              targets[:data][[rv.x,rv.y]][:same_team]+=1 if units[team][:event][id]
            end
          end # aoe_range.each
        
        
        hit = targets[:hit][[x, y]]; st_amt = targets[:data][[rv.x,rv.y]][:same_team]

        if hit
          
          if optimal_xy.nil?
            optimal_xy = [x,y,st_amt]
            
            hit_dir = hit#ch_hit_dir_helper(hit, event.id)
            #print "hit dir = #{hit}\n"
            
          elsif healing && optimal_xy[2] < st_amt # want to hit more when healing
            optimal_xy = [x,y,st_amt]
            
            hit_dir = hit#ch_hit_dir_helper(hit, event.id)
            #print "hit dir = #{hit}\n"
            
          elsif optimal_xy[2] > st_amt
            optimal_xy = [x,y,st_amt]
            
            hit_dir = hit#ch_hit_dir_helper(hit, event.id)
            #print "hit dir = #{hit}\n"
          elsif optimal_xy[2] == st_amt && pref_dirs.include?(hit)
            
            optimal_xy = [x,y,st_amt]
            
            hit_dir = hit#ch_hit_dir_helper(hit, event.id)
            
            #print "overwrote hit loc due to preferred dir #{hit}\n"
            
          end
          
        end # if hit
        end
      end # range.each
      
      event.set_direction(event.sym_to_dir_era(hit_dir)) if hit_dir
      !optimal_xy.nil? ? [optimal_xy[0],optimal_xy[1],hit_dir] : []
    end
    #--------------------------------------------------------------------------
    # * Change returns direction event was turned
    #--------------------------------------------------------------------------
    #def self.ch_hit_dir_helper(d, event_id)
    #  (ev = $game_map.events[event_id]).set_direction(ev.sym_to_dir_era(d))
    #  d
    #end
    #--------------------------------------------------------------------------
    # * Try to use an aoe item on the units at position x,y
    #--------------------------------------------------------------------------
    def self.apply_aoe_item(x,y,tb_item, tb_event_id, dir)
      map, consume, tm = $game_map, false, TactBattleManager
      user = map.events[tb_event_id]
      
      units = TM.units
      
      tb_item.tbs_aoe_range[dir].each do |v| 
        tx,ty = v.x + x, v.y + y
        map.cache_ids_xy(tx,ty).each do |id|
          
          e = nil
          units.keys.each{ |team| break if (e = units[team][:event][id]) }
          next unless e
          
          # e = map.events[id]
          res = invoke_on_target(e,user,tb_item)
          consume ||= res
          team = TactBattleManager.event_team(e.id)
          tu = e.tb_unit
          tm.rm_unit(e.id, team) if tu && (b=tu.battler) && b.death_state? 
        end
      end
      return consume
    end
    #--------------------------------------------------------------------------
    # * Try to use a non aoe item on the units at position x,y
    #
    #   The scope of effects.
    #     0: None 
    #     1: One Enemy 
    #     2: All Enemies 
    #     3: One Random Enemy 
    #     4: Two Random Enemies 
    #     5: Three Random Enemies 
    #     6: Four Random Enemies 
    #     7: One Ally 
    #     8: All Allies 
    #     9: One Ally (Dead) 
    #     10: All Allies (Dead) 
    #     11: The User 
    #--------------------------------------------------------------------------
    def self.apply_item(x,y,tb_item, tb_event_id, dir)
      
      map = $game_map
      ins, hit, target = false, false, nil 
      tb_event = map.events[tb_event_id]
      actor = tb_event.tb_unit.battler
      
      range = (t=rwith_eqpmod(tb_item,actor)) ? t : tb_item.tbs_spec_range[dir]
      
      tx = x-tb_event.x; ty = y-tb_event.y
      range.each{ |v| break if ins = (v.x==tx && v.y ==ty) }
      return false if !ins
      
      ret = map.cache_ids_xy(x,y).each do |id|
        e = map.events[id]
        if (tu = e.tb_unit) && tu.battler
          hit = true
          invoke_on_target(e, tb_event, tb_item)
          team = TactBattleManager.event_team(id)
          TactBattleManager.rm_unit(id, team) if tu.battler.death_state? 
        end
      end
      
      return false if tb_item.scope == 1 && !hit
      
      ret
    end
    #--------------------------------------------------------------------------
    # * Use Item/Skill
    #--------------------------------------------------------------------------
    def self.use_item(x, y, tb_item, e_id, team = nil, aoex = nil, aoey = nil)
      map = $game_map; tb_event = map.events[e_id]
      res, use = false, false
      dir = tb_event.dir_to_sym_era
      print "use_item, dir = #{dir}\n"
      actor = tb_event.tb_unit.battler
      
      if tb_item.tb_aoe # Process an aoe skill/item
        
        coord = aoe_target(x, y, dir, tb_item, e_id) if aoex.nil? || aoey.nil?
        aoex ||= coord[0]; aoey ||= coord[1]
        print "aoex, aoey = #{aoex}, #{aoey}\n"
        use = (aoex.nil? || aoey.nil?) ? false : apply_aoe_item(aoex, aoey, 
          tb_item, e_id, dir)
      else              # process a non aoe item/skill
        use = apply_item(x,y, tb_item, e_id, dir)
      end
      tb_event.tb_unit.use_item(tb_item) if use
    end
    #--------------------------------------------------------------------------
    # * invoke on target
    #      (poorly organized)
    #     params
    #       ret_result, when true the result is returned.
    #--------------------------------------------------------------------------
    def self.invoke_on_target(target_ev, user_ev, tb_item, prev = false,
      ret_result = false)
      
      # add conditionals to support friendly hits on or off
      return false if target_ev.nil? || target_ev.tb_unit.nil? # or if the target is not an tb_unit.
      return false if (target = target_ev.tb_unit.battler).nil?
      
      user = user_ev.tb_unit.battler
      
      # Try to use the skill on the target...
        
      if tb_item.is_a?(RPG::Skill)
        user.tb_set_action(Game_Action.new(user).set_skill(tb_item.id))
      elsif tb_item.is_a?(RPG::Item)
        user.tb_set_action(Game_Action.new(user).set_item(tb_item.id))
      end
        
      if user.actions[0].valid?
         
        item = user.current_action.item
        if prev
          target = Marshal.load(Marshal.dump(target))
          user = Marshal.load(Marshal.dump(user))
        else
          temp = target_ev.animation_id = item.animation_id
          target_ev.animation_id = 1 if temp < 0 # default basic attack
        end
        
        result = target.item_apply(user, item)
        
        return result if ret_result
        return sar_brief(result, user_ev, target, target_ev, tb_item, prev)
      else; return false
      end
    end # invoke_on_target
    #---------------------------------------------------------------------------
    # * Shorter call to show_action_results_tb (avoid scouting for all calls)
    #---------------------------------------------------------------------------
    def self.sar_brief(*args); show_action_results_tb(*args); end
    #---------------------------------------------------------------------------
    # * Show Invoke Results
    #---------------------------------------------------------------------------
    def self.show_action_results_tb(result,user_ev, target, target_ev, tb_item,
        prev = false)
      return if !(scene = SceneManager.scene).is_a?(Scene_Map)
      tm = TactBattleManager
      user = user_ev.tb_unit.battler
      user.last_target_index = target.index
      hp, mp = result.hp_damage, result.mp_damage
      damage = hp.abs > mp.abs ? hp : mp
      
      return damage if prev
      
      op = damage < 0 ? "+" : ""
      spm = scene.instance_eval('@spriteset')
      if damage == 0
        spm.add_bouncy_text_era("Miss!",target_ev.x,target_ev.y)
      else
        spm.add_bouncy_text_era("#{op}#{-1*damage}",target_ev.x,target_ev.y)
      end
      is_skill = tb_item.is_a?(RPG::Skill)
      if user.is_a?(Game_Actor) && (xp=gexp(damage,target)) > 0 && is_skill
        tm.start_wait_for_anim("Exp",xp,user_ev.x, user_ev.y, target_ev) 
        user.gain_exp(xp)
      end
      true
    end
    #--------------------------------------------------------------------------
    # * Get Exp
    #--------------------------------------------------------------------------
    def self.gexp(val, target)
      exp = 0
      if target.is_a?(Game_Enemy)
        exp = val.to_f/target.mhp * target.exp
      else
        exp = val*0.1
      end
      exp *= -1 if exp < 0
      exp.to_i
    end
    #--------------------------------------------------------------------------
    # * Remove Unit
    #--------------------------------------------------------------------------
    def self.remove_unit(id)
      tm = TactBattleManager
      
      team = tm.event_team(id)
      tm.rm_unit(id, team)
    end
    #--------------------------------------------------------------------------
    # * Show Movement range
    #--------------------------------------------------------------------------
    def self.show_move_range_tb(x,y, hloc = :def, calc = true)
      return unless (s=SceneManager.scene).is_a?(Scene_Map)
      spm = s.instance_eval('@spriteset')
      event = $game_map.events[$game_map.tbu_id_xy(x,y)]
      range_util ||= Unit_Range.new
        
      return if event.nil?
        
      locs = nil
      if calc
        locs = range_util.calc_range(x, y, 0, event.tb_unit.move, event)
      else      # use the events current path to get range
        locs = range_util.get_range(x, y, 0, event.tb_unit.move, event)
      end
      
      event.tb_unit.empty_valid_moves
      
      locs.each do |loc| 
        spm.add_highlight(:x=>loc.x, :y=>loc.y, :hloc=>hloc) 
        event.tb_unit.add_valid_move(loc)
      end
      
      event.give_path(range_util.path)
      event.give_distances(range_util.distances)
      event
    end
    #--------------------------------------------------------------------------
    # * Place highlights
    #--------------------------------------------------------------------------
    def self.place_hls_spm(locs, opts={})
      return unless (s=SceneManager.scene).is_a?(Scene_Map)
      spm = s.instance_eval('@spriteset')
      options = {:offx=>0,:offy=>0,:hloc=>:def, :meth=>:default_attack,
                  :opacity=>Era::Fade.opacity}.merge(opts)
      offx, offy = options[:offx], options[:offy]
      hloc, meth, opacity = options[:hloc], options[:meth], options[:opacity]
      
      locs.each do |loc| 
        x,y = loc.x + offx,loc.y + offy
        spm.add_highlight(:x=>x,:y=>y,:sym=>meth,:hloc=>hloc, :opacity=>opacity) 
      end
    end
    #--------------------------------------------------------------------------
    # * Show action highlights
    #--------------------------------------------------------------------------
    def self.show_act_hls(x,y,dir,item, actor)
      range = (r=item.tbs_spec_range).nil? ? rwith_eqpmod(item, actor) : r[dir]
      place_hls_spm(range, {:offx=>x, :offy=>y, :hloc=>SHOW})
    end
    #--------------------------------------------------------------------------
    # * Range with equip modifers
    #--------------------------------------------------------------------------
    def self.rwith_eqpmod(item, actor)
      return item.tbs_simple_range if !actor.is_a?(Game_Actor)
      return if !item.tbs_simple_range
      m,n = item.tb_range_max-1, item.tb_range_min-1
      Unit_Range.points(0,0,n+actor.eqp_r_min(item), m+actor.eqp_r_max(item))
    end
    #--------------------------------------------------------------------------
    # * Show Aoe Highlights
    #--------------------------------------------------------------------------
    def self.show_aoe_hls(x,y,dir,item)
      print "show_aoe_hls dir = #{dir}\n"
      
      return if (range = item.tbs_aoe_range).nil?
      place_hls_spm(range[dir], {:offx=>x, :offy=>y, :hloc=>SHOW})
    end
    #--------------------------------------------------------------------------
    # * Preferred turn directions
    #--------------------------------------------------------------------------
    def self.pref_turn_dirs(ev_id, x, y)
      ch_turn = $game_map.events[ev_id]
      
      sx = ch_turn.distance_x_from(x)
      sy = ch_turn.distance_y_from(y)
      prefs = []
      
      if sx < 0;     prefs.push(DIRS[3])
      elsif sx > 0;  prefs.push(DIRS[2])
      end
      
      if sy < 0;     prefs.push(DIRS[1])
      elsif sy > 0;  prefs.push(DIRS[0])
      end
      
      prefs
    end
    #--------------------------------------------------------------------------
    # * Produce Units
    #--------------------------------------------------------------------------
    def self.produce_units(team = TactBattleManager.turn)
      m = $game_map
      
      TM.ai_production.keys.each do |id|
        e=m.events[id]
        if m.tbu_id_xy(x=e.x,y=e.y) == 0
          name = dumb_unit(TM.ai_production[id])
          TM.queue_unit(name, team, x,y)
        end
      end
    end
    #--------------------------------------------------------------------------
    # * Dumb_Unit
    #     returns the first unit that the ai can 'afford' AI funds are not
    #     implemented yet though.
    #--------------------------------------------------------------------------
    def self.dumb_unit(syms) 
      s=(u=Era::TBUnit::Constructable[syms[0]]).size
      u[rand(s)]
    end
    
  end # AI

#=============================================================================
# ** Construct_Unit
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#      Data organization for building/buying/spawning new tactical units on
#      the map.
#=============================================================================

  module TBUnit
    GameParty = "$game_party".to_sym    # Default symbol specifiying game party
    #--------------------------------------------------------------------------
    # Table: Constructable
    #--------------------------------------------------------------------------
    # Modify this hash to change which units can be created from the 
    # ... script call.
    #   Constructable maps symbols -> hash of event names
    # the symbols can be whatever you want them to be, they should be named so
    # that they describe a set of units.
    #   The data for the event names is then organized in the Units hash below.
    #
    Constructable = {
      :basic_units=>["Mage", "Medic"],
      :advanced_units=>["Valkyrie"],
      :basic_ai_units => ["Orc","Seraph"],
      :advanced_ai_units => ["Glee"]
    }
    #--------------------------------------------------------------------------
    # Table: Color
    #--------------------------------------------------------------------------
    # The names of the methods inside Window_TBUnitData will be used to determine
    # the color the units are drawn in.
    #
    Color = {
      :basic_units => :color1,
      :advanced_units => :color2
    }
    #--------------------------------------------------------------------------
    # Table: Units
    #--------------------------------------------------------------------------
    #  Units hash determines how much each unit costs to make, and how many u
    # units can be made. It also specifies if the unit's cost is paid in currency,
    # items, or both.
    #
    #   The hash consists of two keys one of which maps to another hash, the other
    # to a scalar value.
    #
    #   The valid keys for the outermost hash are :cost and :max 
    # :cost maps to a hash which has the following keys (symbols):
    #   :currency
    #   :item,
    #   :weapon
    #   :armor
    # :currency maps to a value representing how much currency a unit costs
    # to make. The other three symbols, :item, :weapon, and :armor map
    # to hashes. The hashes map the item ids to quantities. The  party must
    # have 'quantity' amount of the item/weapon/armor with the specified id.
    # To specify a unit that does not cost any items to make use an empty hash, 
    # {}.
    #
    # For example:
    # "Sentry" => {:cost=>{:item => {1=>3,12=>5}, :currency=>50}, :max=>100}
    #
    # Means that in order to produce the unit called "Sentry", the party
    # must pay 3 of item number one, 5 of item number twelve, and 50 currency (gold) 
    # in order to produce one "Sentry". Additionally, no more than 100 Sentries 
    # can be produced (during one tactical battle)
    #--------------------------------------------------------------------------
    
    # Constant representing a unit that is free to produce
    FREE = {:cost=>{:item => {}, :currency=>0}, :max=>1000}
    
    Units = {
      
      "Mage" => {:cost=>{:currency => 330}, :max => 3},
      "Archer" => {:cost=>{:item => {1=>1, 2=> 1}, :weapon => {1=>2}, :currency =>400}, :max => 1},
      "Knight" => {:cost=>{:currency => 200}, :max => 1},
      "Valkyrie" => {:cost => {:currency => 600}, :max => 3},
      "Orc" => {:cost => {:currency => 75}, :max => 10},
      "Glee" => {:cost => {:currency => 1500}, :max => 1},
      "Seraph" => {:cost => {:currency => 500}, :max => 3},
      "Medic" => {:cost => {:currency => 270}, :max => 2}
    }
    
    #--------------------------------------------------------------------------
    # * Helper for accessing Constructable
    #--------------------------------------------------------------------------
    def self.[](sym)
      Constructable[sym]
    end
    #--------------------------------------------------------------------------
    # * Helper for accessing cost
    #--------------------------------------------------------------------------
    def self.cost(name)
      Units[name]
    end
    #--------------------------------------------------------------------------
    # * Party can afford
    #--------------------------------------------------------------------------
    def self.makable?(name)
      return false if name.nil?
      
      pty = $game_party
      on_map = already_on_map(name)
      
      # Check if placing a party member on map, they are free to place
      pty.members.each do |a| 
        on_map && a.name.eql?(name) ? (return false) : (return !a.death_state? if a.name.eql?(name))
      end
      
      data = Units[name]
      cost = data[:cost]
      items = cost[:item] ||= {}
      weapons = cost[:weapon] ||= {}
      armors = cost[:armor] ||= {}
      
      items.keys.each do |id|
        return false if pty.item_number($data_items[id]) < items[id]
      end
        
      weapons.keys.each do |id|
        return false if pty.item_number($data_weapons[id]) < weapons[id]
      end
      armors.keys.each do |id| 
        return false if pty.item_number($data_armors[id]) < armors[id]
      end
      amt = TactBattleManager.friends[:amount][name]
      
      return false if !amt.nil? && amt >= data[:max]
      return false if pty.gold < (cost[:currency] ||= 0)
      return true
    end
    #--------------------------------------------------------------------------
    # * Already on Map
    #     Check if an event with param: name is already on the map
    #--------------------------------------------------------------------------
    def self.already_on_map(name)
      map = $game_map
      map.events.values.each{|e| return e if e.event.name.eql?(name) }
      return false
    end
    #--------------------------------------------------------------------------
    # * Actor or enemy data from a name
    #--------------------------------------------------------------------------
    def self.battler_from_name(name)
      $data_actors.each{|a| return a if !a.nil? && a.name == name}
      $data_enemies.each{|e| return e if !e.nil? && e.name == name}
      nil
    end
    #--------------------------------------------------------------------------
    # * Placement Ok?
    #     Can the Unit with the specified name be placed at location x,y?
    #--------------------------------------------------------------------------
    def self.placement_ok?(x,y,unit_name)
      battler, map = battler_from_name(unit_name), $game_map
      return false if battler.nil?
      return false if battler.tb_usable == false # nil is considered true here
      return false if !TactBattleManager.valid_pos_of([x,y])
      return false unless map.cache_ids_xy_no_etp(x,y).empty? # map.tb_prod(x,y)
      tag = map.terrain_tag(x,y)
      pbls = battler.base_passables
      tag_ok = tag == 0 || (!pbls.nil? && pbls[tag])
      valid_pos = tag_ok || map.passable_any_dir?(x,y) # The correct check should be an and but this has not been fixed yet.
      valid_pos = valid_pos && map.valid?(x,y)
    end
    #--------------------------------------------------------------------------
    # * Pay the cost of unit by taking items/ currency from party's inventory
    #--------------------------------------------------------------------------
    def self.pay_cost(name)
      pty = $game_party
      cost = Units[name][:cost] ||=0
      items = cost[:item] ||={}
      armors = cost[:armor] ||={}
      weapons = cost[:weapon] ||={}
      currency = cost[:currency] ||={}
      
      items.keys.each{|id| pty.lose_item($data_items[id], items[id]) }
      armors.keys.each{|id| pty.lose_item($data_armors[id], armors[id]) }
      weapons.keys.each{|id| pty.lose_item($data_weapons[id], weapons[id]) }
      
      pty.lose_gold(currency)
    end
  end # TBUnit
end # Era

