module RealisticPush

// ------------------------------------------------------------
// ReactionManagerComponent accessor
// ------------------------------------------------------------
public func RFC_GetReactCmp(p: wref<ScriptedPuppet>) -> ref<ReactionManagerComponent> {
  if !IsDefined(p) { return null; }
  return p.GetStimReactionComponent() as ReactionManagerComponent;
}

// Stairs

public struct RFC_SlopeImpulseCfg {
  public let fwdMulHead:   Float;
  public let fwdMulChest:  Float;
  public let fwdMulPelvis: Float;
  public let slamZ:        Float;
  public let radius:       Float;
  public let delayStep:    Float;
}


public func RFC_DefaultSlopeImpulse() -> RFC_SlopeImpulseCfg {
  let c: RFC_SlopeImpulseCfg;
  c.fwdMulHead   = 0.5;
  c.fwdMulChest  = 0.0;
  c.fwdMulPelvis = 0.0;
  c.slamZ        = -0.0; // extreme
  c.radius       = 0.95;
  c.delayStep    = 0.05;
  return c;
}

public func RFC_ApplyStairsImpulses(p: wref<NPCPuppet>, cfg: RFC_SlopeImpulseCfg) -> Void {
  if !IsDefined(p) { return; }
  if !ScriptedPuppet.CanRagdoll(p) { return; }

  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(p.GetGame());
  let pos: Vector4 = p.GetWorldPosition();
  let fwd: Vector4 = p.GetWorldForward();

  let len2D: Float = SqrtF(fwd.X * fwd.X + fwd.Y * fwd.Y);
  let dirX: Float = (len2D < 0.0001) ? 1.0 : (fwd.X / len2D);
  let dirY: Float = (len2D < 0.0001) ? 0.0 : (fwd.Y / len2D);

  let headPos: Vector4   = Vector4(pos.X, pos.Y, pos.Z + 1.36, 0.0);
  let chestPos: Vector4  = Vector4(pos.X, pos.Y, pos.Z + 1.12, 0.0);
  let pelvisPos: Vector4 = Vector4(pos.X, pos.Y, pos.Z + 0.95, 0.0);

  let headVec:   Vector4 = Vector4(dirX * cfg.fwdMulHead,   dirY * cfg.fwdMulHead,   cfg.slamZ, 0.0);
  let chestVec:  Vector4 = Vector4(dirX * cfg.fwdMulChest,  dirY * cfg.fwdMulChest,  cfg.slamZ, 0.0);
  let pelvisVec: Vector4 = Vector4(dirX * cfg.fwdMulPelvis, dirY * cfg.fwdMulPelvis, cfg.slamZ, 0.0);

  ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(headPos,   headVec,   cfg.radius), cfg.delayStep * 1.0, false);
  ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(chestPos,  chestVec,  cfg.radius), cfg.delayStep * 2.0, false);
  ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(pelvisPos, pelvisVec, cfg.radius), cfg.delayStep * 3.0, false);
}

public func RFC_ApplyStairPlank(
  ds: ref<DelaySystem>,
  p: wref<NPCPuppet>,
  headPos: Vector4,
  chestPos: Vector4,
  pelvisPos: Vector4,
  dirX: Float,
  dirY: Float,
  c: RFCConfig
) -> Void {
  if !c.stair_plankEnabled { return; }

  let headImp:   Vector4 = Vector4(dirX * c.stair_plankFwd, dirY * c.stair_plankFwd, c.stair_plankHeadDown,   1.0);
  let chestImp:  Vector4 = Vector4(dirX * c.stair_plankFwd, dirY * c.stair_plankFwd, c.stair_plankChestDown,  1.0);
  let pelvisImp: Vector4 = Vector4(dirX * (c.stair_plankFwd * 0.9), dirY * (c.stair_plankFwd * 0.9), c.stair_plankPelvisDown, 1.0);

  ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(headPos,   headImp,   c.stair_plankRadius), c.stair_plankDelay + 0.00, false);
  ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(chestPos,  chestImp,  c.stair_plankRadius), c.stair_plankDelay + 0.02, false);
  ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(pelvisPos, pelvisImp, c.stair_plankRadius), c.stair_plankDelay + 0.04, false);

  if AbsF(c.stair_plankBrakeFwd) > 0.001 && c.stair_plankBrakeRadius > 0.0 {
    let brake: Vector4 = Vector4(dirX * c.stair_plankBrakeFwd, dirY * c.stair_plankBrakeFwd, 0.0, 1.0);
    ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(chestPos, brake, c.stair_plankBrakeRadius), c.stair_plankBrakeDelay, false);
  }
}

// Remember when we last saw "stairs"
@addField(NPCPuppet) private let rfc_stairLastSeen: Float;

@addMethod(NPCPuppet)
public func RFC_MarkStairsNow() -> Void {
  this.rfc_stairLastSeen = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
}

@addMethod(NPCPuppet)
public func RFC_WasStairsRecent(window: Float) -> Bool {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  return this.rfc_stairLastSeen > 0.0 && (now - this.rfc_stairLastSeen) <= window;
}

// Stairs tag detector + recency + HEURISTICS (tags optional)
private func RFC_IsOnStairs(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }

  // A) Tags (nice-to-have, often absent)
  let tags: array<CName>;
  ArrayPush(tags, n"stairs");
  ArrayPush(tags, n"stairs_up");      ArrayPush(tags, n"stairs_down");
  ArrayPush(tags, n"stair");          ArrayPush(tags, n"stair_up");     ArrayPush(tags, n"stair_down");
  ArrayPush(tags, n"walk_stairs");    ArrayPush(tags, n"run_stairs");
  ArrayPush(tags, n"loco_stairs");    ArrayPush(tags, n"loco_stairs_up"); ArrayPush(tags, n"loco_stairs_down");
  ArrayPush(tags, n"stairsUp");       ArrayPush(tags, n"stairsDown");
  ArrayPush(tags, n"loco_stairsUp");  ArrayPush(tags, n"loco_stairsDown");

  if RFC_CountAnyTags(p, tags) > 0 {
    let np: wref<NPCPuppet> = p as NPCPuppet;
    if IsDefined(np) { np.RFC_MarkStairsNow(); }
    return true;
  }

  // B) Forward-tilt + planar motion (heuristic)
  let fwd: Vector4 = p.GetWorldForward();
  let tilt: Float = AbsF(fwd.Z);

  // C) Diagonal velocity (heuristic)
  let v: Vector4 = p.GetVelocity();
  let planar: Float = SqrtF(v.X * v.X + v.Y * v.Y);

  if (tilt > 0.06 && planar > 0.60) || (AbsF(v.Z) > 0.22 && planar > 0.60) {
    let np2: wref<NPCPuppet> = p as NPCPuppet;
    if IsDefined(np2) { np2.RFC_MarkStairsNow(); }
    return true;
  }

  return false;
}


// Cower tracking

@addMethod(NPCPuppet)
public func RFC_MarkCowerNow() -> Void {
  this.rfc_cowLastSeen = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
}

@addMethod(NPCPuppet)
public func RFC_WasCowerRecentCfg() -> Bool {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  let win: Float = ClampF(TweakDBInterface.GetFloat(t"RealisticPush.Cower.window", 0.80), 0.30, 2.50);
  return this.rfc_cowLastSeen > 0.0 && (now - this.rfc_cowLastSeen) <= win;
}

@addMethod(NPCPuppet)
public func RFC_WasCoweringRecently(window: Float) -> Bool {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  return this.rfc_cowLastSeen > 0.0 && (now - this.rfc_cowLastSeen) <= window;
}

private func RFC_TryMarkCow(p: wref<ScriptedPuppet>) -> Void {
  let np: wref<NPCPuppet> = p as NPCPuppet;
  if IsDefined(np) { np.RFC_MarkCowerNow(); }
}

// Tag-driven panic/fear detector
public func RFC_HasPanicOrFearTags(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { 
    return false; 
  };

  // Use the same AIReactionData helper you already use in RFC_IsCoweringStrict
  let d: ref<AIReactionData> = RFC_GetAIData(p);
  if IsDefined(d) {
    let tags: array<CName> = d.stimRecord.Tags();

    // Direct stim tags you've collected
    if ArrayContains(tags, n"PanicFear")
    || ArrayContains(tags, n"ChildDanger")
    || ArrayContains(tags, n"PotentialFear")
    || ArrayContains(tags, n"NonAggressiveCrowd")
    || ArrayContains(tags, n"AggressiveCrowd")
    || ArrayContains(tags, n"Combat")
    || ArrayContains(tags, n"Alert")
    || ArrayContains(tags, n"NavReach")
    || ArrayContains(tags, n"DirectThreat")
    || ArrayContains(tags, n"CrowdReaction")
    || ArrayContains(tags, n"TrafficPlayerOnly")
    || ArrayContains(tags, n"NoAutoCombatStart")
    || ArrayContains(tags, n"NoInitFearAnimation") {
      return true;
    };
  };

  // Fall back to your existing fear logic (stat pool + violent stims)
  if RFC_IsInFearState(p) {
    return true;
  };

  return false;
}


// Public fear helper built on top of RFC_IsFearAtOrOverThreshold + RFC_HasRecentFearStim
public func RFC_IsInFearState(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }

  // Fear stat pool over the character's own reaction preset threshold
  if RFC_IsFearAtOrOverThreshold(p) {
    return true;
  }

  // Recent "violent" fear stimulus (Explosion / GrenadeLanded / Scream)
  if RFC_HasRecentFearStim(p, 1.50) {
    return true;
  }

  return false;
}

private func RFC_IsFearAtOrOverThreshold(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  let sps: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(p.GetGame());
  if !IsDefined(sps) { return false; }
  let cur: Float = sps.GetStatPoolValue(Cast<StatsObjectID>(p.GetEntityID()), gamedataStatPoolType.Fear);
  let threshold: Float = TweakDBInterface.GetCharacterRecord(p.GetRecordID()).ReactionPreset().FearThreshold();
  if threshold <= 0.0 { return false; }
  return cur >= (threshold - 0.01);
}

private func RFC_HasRecentFearStim(p: wref<ScriptedPuppet>, recency: Float) -> Bool {
  let cmp: ref<ReactionManagerComponent> = RFC_GetReactCmp(p);
  if !IsDefined(cmp) { return false; }
  let cache: array<ref<StimEventTaskData>> = cmp.GetStimuliCache();
  if ArraySize(cache) == 0 { return false; }
  let evt: ref<StimuliEvent> = cache[ArraySize(cache) - 1].cachedEvt;
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(p.GetGame()));
  let t: gamedataStimType = evt.GetStimType();
  let violent: Bool =
      Equals(t, gamedataStimType.Explosion)
   || Equals(t, gamedataStimType.GrenadeLanded)
   || Equals(t, gamedataStimType.Scream);
  if !violent { return false; }
  let stimTime: Float = cmp.GetCurrentStimTimeStamp();
  return stimTime + recency >= now;
}


private func RFC_IsCoweringStrict(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  if RFC_IsClearlyRunning(p) { return false; }
  if Vector4.Length(p.GetVelocity()) > 0.25 { return false; }

  let cmp: ref<ReactionManagerComponent> = RFC_GetReactCmp(p);
  let d:   ref<AIReactionData>           = RFC_GetAIData(p);

  if IsDefined(cmp) && Equals(cmp.GetDesiredReactionName(), gamedataOutput.FearInPlace) { RFC_TryMarkCow(p); return true; }
  if IsDefined(d)   && Equals(d.reactionBehaviorName,       gamedataOutput.FearInPlace) { RFC_TryMarkCow(p); return true; }

  if IsDefined(cmp) {
    if cmp.GetPreviousFearPhase() == 2 { RFC_TryMarkCow(p); return true; }
    if cmp.GetWorkSpotReactionFlag()   { RFC_TryMarkCow(p); return true; }
  }

  if IsDefined(d) {
    let tags: array<CName> = d.stimRecord.Tags();
    if ArrayContains(tags, n"FearInPlace") || ArrayContains(tags, n"Cower") || ArrayContains(tags, n"Panic") { RFC_TryMarkCow(p); return true; }
    if d.initAnimInWorkspot && !d.skipInitialAnimation { RFC_TryMarkCow(p); return true; }
  }

  if RFC_IsFearAtOrOverThreshold(p) { RFC_TryMarkCow(p); return true; }
  if p.IsCrowd() && RFC_HasRecentFearStim(p, 1.50) && Vector4.Length(p.GetVelocity()) < 0.20 { RFC_TryMarkCow(p); return true; }
  return false;
}

// Panic-run = running + fear/panic tags + NOT cower + NOT stairs
public func RFC_IsPanicRun(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) {
    return false;
  };

  // Must clearly be moving/running
  if !RFC_IsClearlyRunning(p) {
    return false;
  };

  // Do not treat crouched / frozen civilians as "panic-run"
  if RFC_IsCoweringStrict(p) {
    return false;
  };

  // Don't fight stairs logic here
  if RFC_IsOnStairs(p) {
    return false;
  };

  // Finally, require fear/panic classification from tags / stims / statpool
  if !RFC_HasPanicOrFearTags(p) {
    return false;
  };

  return true;
}



