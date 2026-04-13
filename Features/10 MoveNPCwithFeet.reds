module SplatGroundKick

public class SGK_Settings {

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Enable")
  public let enabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.displayName", "Show Move NPCs Corpse w/Feet")
  public let showDetector: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Detector Tick (sec)")
  @runtimeProperty("ModSettings.description", "How often the detector checks for a valid kick.")
  @runtimeProperty("ModSettings.min", "0.01")
  @runtimeProperty("ModSettings.max", "0.25")
  @runtimeProperty("ModSettings.step", "0.01")
  public let intervalSec: Float = 0.06;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Contact Range (m)")
  @runtimeProperty("ModSettings.description", "Maximum flat distance from the player to the body for the kick to fire.")
  @runtimeProperty("ModSettings.min", "0.10")
  @runtimeProperty("ModSettings.max", "2.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let contactDistM: Float = 0.95;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Keep Current Target Radius (m)")
  @runtimeProperty("ModSettings.description", "How far the last valid body can stay selected when you are not looking directly at it.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "10.00")
  @runtimeProperty("ModSettings.step", "0.10")
  public let stickyNearbyRadiusM: Float = 2.50;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Minimum Player Speed (m/s)")
  @runtimeProperty("ModSettings.description", "Minimum flat movement speed required before a kick can fire.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "10.0")
  @runtimeProperty("ModSettings.step", "0.1")
  public let minSpeedMps: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Require Moving Toward Body")
  @runtimeProperty("ModSettings.description", "Higher values require you to move more directly toward the body. 0 disables this check.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let movingIntoDot: Float = 0.15;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Settle Time (sec)")
  @runtimeProperty("ModSettings.description", "How long the same body must stay selected before the kick can fire.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.50")
  @runtimeProperty("ModSettings.step", "0.01")
  public let settleTimeSec: Float = 0.20;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Push Strength (XY)")
  @runtimeProperty("ModSettings.description", "Main forward kick force.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "30.0")
  @runtimeProperty("ModSettings.step", "0.25")
  public let pushXY: Float = 7.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Side Strength (XY)")
  @runtimeProperty("ModSettings.description", "Extra sideways roll when you approach off center.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "15.0")
  @runtimeProperty("ModSettings.step", "0.25")
  public let sideXY: Float = 1.25;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Down Strength (Z)")
  @runtimeProperty("ModSettings.description", "Keeps the body grounded instead of popping upward.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "20.0")
  @runtimeProperty("ModSettings.step", "0.25")
  public let downZ: Float = 3.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Lift Strength (Z)")
  @runtimeProperty("ModSettings.description", "Small upward lift. Keep this low.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "10.0")
  @runtimeProperty("ModSettings.step", "0.25")
  public let liftZ: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Impulse Radius")
  @runtimeProperty("ModSettings.description", "Radius of the ragdoll impulse event.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "3.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let radius: Float = 1.15;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Impact Pause (sec)")
  @runtimeProperty("ModSettings.description", "Delay between detection and the actual kick.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.20")
  @runtimeProperty("ModSettings.step", "0.01")
  public let impactPauseSec: Float = 0.02;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Move NPCs Corpse w/Feet")
  @runtimeProperty("ModSettings.category.order", "28")
  @runtimeProperty("ModSettings.dependency", "showDetector")
  @runtimeProperty("ModSettings.displayName", "Cooldown (sec)")
  @runtimeProperty("ModSettings.description", "Wait time before another kick can fire.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "2.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let cooldownSec: Float = 0.25;

}

public class SGK_TickEvt extends Event {}
public class SGK_ResetCdEvt extends Event {}
public class SGK_ApplyEvt extends Event {
  public let target: wref<NPCPuppet>;
  public let pos: Vector4;
  public let imp: Vector4;
  public let radius: Float;
}
public class SGK_ArmEvt extends Event {}

@addField(PlayerPuppet) private let sgk_active: Bool;
@addField(PlayerPuppet) private let sgk_cd: Bool;

@addField(PlayerPuppet) private let sgk_lastPosValid: Bool;
@addField(PlayerPuppet) private let sgk_lastPos: Vector4;

@addField(PlayerPuppet) private let sgk_contactID: EntityID;
@addField(PlayerPuppet) private let sgk_holdAccum: Float;

@addField(PlayerPuppet) private let sgk_armQueued: Bool;
@addField(PlayerPuppet) private let sgk_armTarget: wref<NPCPuppet>;
@addField(PlayerPuppet) private let sgk_armPos: Vector4;
@addField(PlayerPuppet) private let sgk_armImp: Vector4;
@addField(PlayerPuppet) private let sgk_armRadius: Float;

@addField(PlayerPuppet) private let sgk_settleID: EntityID;
@addField(PlayerPuppet) private let sgk_settleAccum: Float;
@addField(PlayerPuppet) private let sgk_settlePos: Vector4;
@addField(PlayerPuppet) private let sgk_settlePosValid: Bool;

@addField(PlayerPuppet) private let sgk_stickyTarget: wref<NPCPuppet>;



private func SGK_TickDelay(t: Float) -> Float {
  if t <= 0.00 {
    return 0.01;
  };
  return t;
}

private func SGK_Len2D(v: Vector4) -> Float {
  return SqrtF(v.X * v.X + v.Y * v.Y);
}

private func SGK_Norm2D(v: Vector4) -> Vector4 {
  let len: Float = SGK_Len2D(v);
  if len <= 0.001 {
    return new Vector4(0.0, 0.0, 0.0, 1.0);
  };
  return new Vector4(v.X / len, v.Y / len, 0.0, 1.0);
}

private func SGK_Sched(go: wref<GameObject>, e: ref<Event>, t: Float) -> Void {
  let ds: ref<DelaySystem>;
  if !IsDefined(go) || !IsDefined(e) {
    return;
  };
  ds = GameInstance.GetDelaySystem(go.GetGame());
  if !IsDefined(ds) {
    return;
  };
  ds.DelayEvent(go, e, MaxF(0.001, t), false);
}

private func SGK_GetLookAtNPC(p: wref<PlayerPuppet>) -> wref<NPCPuppet> {
  let ts: ref<TargetingSystem>;
  let obj: ref<GameObject>;
  if !IsDefined(p) {
    return null;
  };
  ts = GameInstance.GetTargetingSystem(p.GetGame());
  if !IsDefined(ts) {
    return null;
  };
  obj = ts.GetLookAtObject(p, false, false);
  return obj as NPCPuppet;
}

private func SGK_IsValidCorpseTarget(npc: wref<NPCPuppet>, s: ref<SGK_Settings>) -> Bool {
  if !IsDefined(npc) {
    return false;
  };

  return npc.IsDead();
}

private func SGK_IsStickyNearbyValid(p: wref<PlayerPuppet>, npc: wref<NPCPuppet>, s: ref<SGK_Settings>) -> Bool {
  let ppos: Vector4;
  let npos: Vector4;
  let dist: Float;

  if !IsDefined(p) || !IsDefined(npc) {
    return false;
  };

  if !SGK_IsValidCorpseTarget(npc, s) {
    return false;
  };

  if s.stickyNearbyRadiusM <= 0.00 {
    return false;
  };

  ppos = p.GetWorldPosition();
  npos = npc.GetWorldPosition();

  dist = SGK_Len2D(npos - ppos);
  if dist > s.stickyNearbyRadiusM {
    return false;
  };

  return true;
}


private func SGK_GetPreferredCorpseTarget(p: wref<PlayerPuppet>, s: ref<SGK_Settings>) -> wref<NPCPuppet> {
  let npc: wref<NPCPuppet>;

  if !IsDefined(p) {
    return null;
  };

  npc = SGK_GetLookAtNPC(p);
  if SGK_IsValidCorpseTarget(npc, s) {
    p.sgk_stickyTarget = npc;
    return npc;
  };

  if SGK_IsStickyNearbyValid(p, p.sgk_stickyTarget, s) {
    return p.sgk_stickyTarget;
  };

  p.sgk_stickyTarget = null;
  return null;
}




private func SGK_IsGroundReady(p: wref<PlayerPuppet>, npc: wref<NPCPuppet>, s: ref<SGK_Settings>) -> Bool {
  let npos: Vector4;
  let id: EntityID;

  if !IsDefined(p) || !IsDefined(npc) {
    return false;
  };

  if s.settleTimeSec <= 0.00 {
    return true;
  };

  npos = npc.GetWorldPosition();
  id = npc.GetEntityID();

  if p.sgk_settleID != id {
    p.sgk_settleID = id;
    p.sgk_settleAccum = 0.0;
    p.sgk_settlePos = npos;
    p.sgk_settlePosValid = true;
    return false;
  };

  if !p.sgk_settlePosValid {
    p.sgk_settlePos = npos;
    p.sgk_settlePosValid = true;
    p.sgk_settleAccum = 0.0;
    return false;
  };

  p.sgk_settleAccum += SGK_TickDelay(s.intervalSec);
  p.sgk_settlePos = npos;

  return p.sgk_settleAccum >= s.settleTimeSec;
}


@addMethod(PlayerPuppet)
protected cb func OnSGK_ResetCdEvt(e: ref<SGK_ResetCdEvt>) -> Bool {
  this.sgk_cd = false;
  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnSGK_ApplyEvt(e: ref<SGK_ApplyEvt>) -> Bool {
  if IsDefined(e) && IsDefined(e.target) {
    e.target.QueueEvent(CreateRagdollApplyImpulseEvent(e.pos, e.imp, e.radius));
  };
  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnSGK_ArmEvt(e: ref<SGK_ArmEvt>) -> Bool {
  let s: ref<SGK_Settings> = new SGK_Settings();
  let npc: wref<NPCPuppet>;
  let ie: ref<SGK_ApplyEvt>;

  if !s.enabled {
    return true;
  };

  if this.sgk_cd {
    return true;
  };

  if !this.sgk_armQueued {
    return true;
  };

  npc = this.sgk_armTarget;
  this.sgk_armQueued = false;

  if !SGK_IsValidCorpseTarget(npc, s) {
    return true;
  };

  ie = new SGK_ApplyEvt();
  ie.target = npc;
  ie.pos = this.sgk_armPos;
  ie.imp = this.sgk_armImp;
  ie.radius = this.sgk_armRadius;
  SGK_Sched(this, ie, 0.00);

  if s.cooldownSec > 0.00 {
    this.sgk_cd = true;
    SGK_Sched(this, new SGK_ResetCdEvt(), s.cooldownSec);
  };

  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnSGK_TickEvt(e: ref<SGK_TickEvt>) -> Bool {
  let s: ref<SGK_Settings> = new SGK_Settings();
  let npc: wref<NPCPuppet>;
  let ppos: Vector4;
  let npos: Vector4;
  let moveVec: Vector4;
  let moveDir: Vector4;
  let moveLen: Float;
  let pspd: Float;
  let toNPC: Vector4;
  let dirToNPC: Vector4;
  let dist: Float;
  let moveDot: Float;
  let id: EntityID;
  let rightDir: Vector4;
  let sideDot: Float;
  let sidePush: Float;
  let kickZ: Float;
  let p: Vector4;
  let tickT: Float;

  tickT = SGK_TickDelay(s.intervalSec);

  if !s.enabled {
    this.sgk_active = false;
    return true;
  };

  if !this.sgk_active {
    SGK_Sched(this, new SGK_TickEvt(), tickT);
    return true;
  };

  ppos = this.GetWorldPosition();

  pspd = 0.0;
  moveLen = 0.0;

  if this.sgk_lastPosValid {
    moveVec = ppos - this.sgk_lastPos;
    moveLen = SGK_Len2D(moveVec);
    pspd = moveLen / tickT;
  } else {
    this.sgk_lastPosValid = true;
    this.sgk_lastPos = ppos;
    SGK_Sched(this, new SGK_TickEvt(), tickT);
    return true;
  };

  this.sgk_lastPos = ppos;

  if this.sgk_cd || this.sgk_armQueued {
    SGK_Sched(this, new SGK_TickEvt(), tickT);
    return true;
  };

  if s.minSpeedMps > 0.00 && pspd < s.minSpeedMps {
    this.sgk_holdAccum = 0.0;
    SGK_Sched(this, new SGK_TickEvt(), tickT);
    return true;
  };

  npc = SGK_GetPreferredCorpseTarget(this, s);
  if !SGK_IsValidCorpseTarget(npc, s) {
    this.sgk_holdAccum = 0.0;
    this.sgk_settleAccum = 0.0;
    this.sgk_settlePosValid = false;
    SGK_Sched(this, new SGK_TickEvt(), tickT);
    return true;
  };

  npos = npc.GetWorldPosition();
  toNPC = npos - ppos;
  dist = SGK_Len2D(toNPC);

  if s.contactDistM > 0.00 && dist > s.contactDistM {
    this.sgk_holdAccum = 0.0;
    this.sgk_settleAccum = 0.0;
    this.sgk_settlePosValid = false;
    SGK_Sched(this, new SGK_TickEvt(), tickT);
    return true;
  };

  if !SGK_IsGroundReady(this, npc, s) {
    this.sgk_holdAccum = 0.0;
    SGK_Sched(this, new SGK_TickEvt(), tickT);
    return true;
  };

  if moveLen <= 0.001 {
    this.sgk_holdAccum = 0.0;
    SGK_Sched(this, new SGK_TickEvt(), tickT);
    return true;
  };

  moveDir = SGK_Norm2D(moveVec);
  dirToNPC = SGK_Norm2D(toNPC);

  if s.movingIntoDot > 0.00 {
    moveDot = Vector4.Dot(moveDir, dirToNPC);
    if moveDot < s.movingIntoDot {
      this.sgk_holdAccum = 0.0;
      SGK_Sched(this, new SGK_TickEvt(), tickT);
      return true;
    };
  };  rightDir = this.GetWorldRight();
  sideDot = Vector4.Dot(dirToNPC, rightDir);
  sidePush = sideDot * s.sideXY;
  kickZ = s.liftZ - s.downZ;

  this.sgk_armTarget = npc;

  p = npos;
  p.Z += 0.50;
  this.sgk_armImp = new Vector4(
    moveDir.X * s.pushXY + rightDir.X * sidePush,
    moveDir.Y * s.pushXY + rightDir.Y * sidePush,
    kickZ,
    1.0
  );
  this.sgk_armRadius = s.radius;

  this.sgk_armPos = p;
  this.sgk_armQueued = true;
  this.sgk_holdAccum = 0.0;
  this.sgk_settleAccum = 0.0;
  this.sgk_settlePosValid = false;

  SGK_Sched(this, new SGK_ArmEvt(), s.impactPauseSec);
  SGK_Sched(this, new SGK_TickEvt(), tickT);
  return true;
}

private func SGK_Start(p: wref<PlayerPuppet>) -> Void {
  if !IsDefined(p) {
    return;
  };
  p.sgk_active = true;
  SGK_Sched(p, new SGK_TickEvt(), 0.10);
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let res: Bool = wrappedMethod();
  SGK_Start(this);
  return res;
}

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
  let res: Bool = wrappedMethod(ri);
  SGK_Start(this);
  return res;
}