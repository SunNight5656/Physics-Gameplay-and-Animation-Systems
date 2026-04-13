module SplatBumpLookAtBackup

public class SBL_Settings {

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.displayName", "Show Backup LookAt")
  @runtimeProperty("ModSettings.description", "Show the Backup LookAt settings.")
  public let showBackupLookAt: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Enable")
  public let enabled: Bool = true;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Tick Interval (sec)")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.25")
  @runtimeProperty("ModSettings.step", "0.01")
  public let intervalSec: Float = 0.06;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Range: Contact Distance (m)")
  @runtimeProperty("ModSettings.description", "0 disables this gate.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "3.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let contactDistM: Float = 0.95;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Keep Current Target Radius (m)")
  @runtimeProperty("ModSettings.description", "Keep the last valid NPC as the fallback target within this radius. 0 disables it.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "10.00")
  @runtimeProperty("ModSettings.step", "0.10")
  public let stickyNearbyRadiusM: Float = 2.50;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Gate: Min Player Speed (m/s)")
  @runtimeProperty("ModSettings.description", "0 disables this gate.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "10.00")
  @runtimeProperty("ModSettings.step", "0.10")
  public let minSpeedMps: Float = 1.70;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Gate: Impact Pause (sec)")
  @runtimeProperty("ModSettings.description", "Small pause before ragdoll so target feels solid for a split moment.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.25")
  @runtimeProperty("ModSettings.step", "0.01")
  public let impactPauseSec: Float = 0.05;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Impulse: Push Strength (XY)")
  @runtimeProperty("ModSettings.min", "-100.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "0.25")
  public let pushXY: Float = 5.00;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Impulse: Side Strength (XY)")
  @runtimeProperty("ModSettings.min", "-100.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "0.25")
  public let sideXY: Float = 0.00;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Impulse: Down Strength (Z)")
  @runtimeProperty("ModSettings.min", "-100.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "0.25")
  public let downZ: Float = 5.00;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Impulse: Lift Strength (Z)")
  @runtimeProperty("ModSettings.min", "-100.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "0.25")
  public let liftZ: Float = 0.00;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Impulse Radius")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let radius: Float = 1.15;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Impulse: Delay After Ragdoll (sec)")
  @runtimeProperty("ModSettings.description", "Shove happens after ragdoll cut so it reads like impact momentum.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.25")
  @runtimeProperty("ModSettings.step", "0.01")
  public let impulseDelaySec: Float = 0.03;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Cooldown (sec)")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "2.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let cooldownSec: Float = 0.45;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Workspot: Exit Wait (sec)")
  @runtimeProperty("ModSettings.description", "Delay after exit signal before ragdoll.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.50")
  @runtimeProperty("ModSettings.step", "0.01")
  public let workspotExitWaitSec: Float = 0.25;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Workspot: Exit Retries")
  @runtimeProperty("ModSettings.description", "How many times to retry exit before forcing ragdoll.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "6")
  @runtimeProperty("ModSettings.step", "1")
  public let workspotExitRetries: Int32 = 4;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Backup LookAt")
  @runtimeProperty("ModSettings.category.order", "27")
  @runtimeProperty("ModSettings.dependency", "showBackupLookAt")
  @runtimeProperty("ModSettings.displayName", "Workspot: Reaction Delay (sec)")
  @runtimeProperty("ModSettings.description", "Delay after a workspot reaction signal before ragdoll.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.60")
  @runtimeProperty("ModSettings.step", "0.01")
  public let workspotReactionDelaySec: Float = 0.25;

}

public class SBL_TickEvt extends Event {}
public class SBL_ResetCdEvt extends Event {}
public class SBL_ImpulseEvt extends Event {
  public let target: wref<NPCPuppet>;
  public let pos: Vector4;
  public let imp: Vector4;
  public let radius: Float;
}
public class SBL_ArmEvt extends Event {}

@addField(PlayerPuppet) private let sbl_active: Bool;
@addField(PlayerPuppet) private let sbl_cd: Bool;

@addField(PlayerPuppet) private let sbl_lastPosValid: Bool;
@addField(PlayerPuppet) private let sbl_lastPos: Vector4;

@addField(PlayerPuppet) private let sbl_contactID: EntityID;

@addField(PlayerPuppet) private let sbl_armQueued: Bool;
@addField(PlayerPuppet) private let sbl_armTarget: wref<NPCPuppet>;
@addField(PlayerPuppet) private let sbl_armPos: Vector4;
@addField(PlayerPuppet) private let sbl_armImp: Vector4;
@addField(PlayerPuppet) private let sbl_armRadius: Float;

@addField(PlayerPuppet) private let sbl_stickyTarget: wref<NPCPuppet>;
@addField(PlayerPuppet) private let sbl_exitPending: Bool;
@addField(PlayerPuppet) private let sbl_exitTries: Int32;

private func SBL_TickDelay(t: Float) -> Float {
  if t <= 0.00 {
    return 0.01;
  };
  return t;
}

private func SBL_Sched(go: wref<GameObject>, e: ref<Event>, t: Float) -> Void {
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


private func SBL_SendMeleeStim(player: wref<PlayerPuppet>, npc: wref<NPCPuppet>) -> Void {
  let stimComp: ref<StimBroadcasterComponent>;

  if !IsDefined(player) || !IsDefined(npc) {
    return;
  };

  stimComp = player.GetStimBroadcasterComponent();
  if !IsDefined(stimComp) {
    return;
  };

  stimComp.SendDrirectStimuliToTarget(npc, gamedataStimType.MeleeHit, npc);
}


private func SBL_GetLookAtNPC(p: wref<PlayerPuppet>) -> wref<NPCPuppet> {
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

private func SBL_IsStickyNearbyValid(p: wref<PlayerPuppet>, npc: wref<NPCPuppet>, s: ref<SBL_Settings>) -> Bool {
  let ppos: Vector4;
  let npos: Vector4;
  let dist: Float;

  if !IsDefined(p) || !IsDefined(npc) {
    return false;
  };

  if !ScriptedPuppet.CanRagdoll(npc) {
    return false;
  };

  if s.stickyNearbyRadiusM <= 0.00 {
    return false;
  };

  ppos = p.GetWorldPosition();
  npos = npc.GetWorldPosition();

  dist = Vector4.Length(npos - ppos);
  if dist > s.stickyNearbyRadiusM {
    return false;
  };


  return true;
}

private func SBL_GetPreferredTarget(p: wref<PlayerPuppet>, s: ref<SBL_Settings>) -> wref<NPCPuppet> {
  let npc: wref<NPCPuppet>;

  if !IsDefined(p) {
    return null;
  };

  npc = SBL_GetLookAtNPC(p);
  if IsDefined(npc) && ScriptedPuppet.CanRagdoll(npc) {
    p.sbl_stickyTarget = npc;
    return npc;
  };

  if SBL_IsStickyNearbyValid(p, p.sbl_stickyTarget, s) {
    return p.sbl_stickyTarget;
  };

  p.sbl_stickyTarget = null;
  return null;
}

@addMethod(PlayerPuppet)
protected cb func OnSBL_ResetCdEvt(e: ref<SBL_ResetCdEvt>) -> Bool {
  this.sbl_cd = false;
  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnSBL_ImpulseEvt(e: ref<SBL_ImpulseEvt>) -> Bool {
  if IsDefined(e) && IsDefined(e.target) {
    e.target.QueueEvent(CreateRagdollApplyImpulseEvent(e.pos, e.imp, e.radius));
  };
  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnSBL_ArmEvt(e: ref<SBL_ArmEvt>) -> Bool {
  let s: ref<SBL_Settings> = new SBL_Settings();
  let npc: wref<NPCPuppet>;

  // second-stage execution after stim / workspot reaction
  if !this.sbl_armQueued {
    npc = this.sbl_armTarget;

    if !IsDefined(npc) || !ScriptedPuppet.CanRagdoll(npc) {
      return true;
    };

    npc.TriggerRagdollBehavior();
    npc.QueueEvent(CreateForceRagdollEvent(n"SPLAT_LOOKAT_BACKUP"));

    let ie2: ref<SBL_ImpulseEvt> = new SBL_ImpulseEvt();
    ie2.target = npc;
    ie2.pos = this.sbl_armPos;
    ie2.imp = this.sbl_armImp;
    ie2.radius = this.sbl_armRadius;
    SBL_Sched(this, ie2, s.impulseDelaySec);

    if s.cooldownSec > 0.00 {
      this.sbl_cd = true;
      SBL_Sched(this, new SBL_ResetCdEvt(), s.cooldownSec);
    };

    return true;
  };

  if !s.enabled {
    return true;
  };

  if this.sbl_cd {
    return true;
  };

  if !this.sbl_armQueued {
    return true;
  };

  npc = this.sbl_armTarget;
  this.sbl_armQueued = false;

  if !IsDefined(npc) {
    return true;
  };

  if !ScriptedPuppet.CanRagdoll(npc) {
    return true;
  };

  let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(this.GetGame());
  if IsDefined(ws) && ws.IsActorInWorkspot(npc) {
    if !this.sbl_exitPending {
      this.sbl_exitPending = true;
      this.sbl_exitTries = 0;

      if ws.IsReactionAvailable(npc, n"bump") {
        ws.SendReactionSignal(npc, n"bump");
      } else if ws.IsReactionAvailable(npc, n"hit") {
        ws.SendReactionSignal(npc, n"hit");
      } else if ws.IsReactionAvailable(npc, n"flinch") {
        ws.SendReactionSignal(npc, n"flinch");
      } else if ws.IsReactionAvailable(npc, n"stagger") {
        ws.SendReactionSignal(npc, n"stagger");
      } else {
        ws.SendSlowExitSignal(npc, n"", true);
      };

      this.sbl_armTarget = npc;
      this.sbl_armQueued = true;
      SBL_Sched(this, new SBL_ArmEvt(), SBL_TickDelay(s.workspotReactionDelaySec));
      return true;
    };
  };

  this.sbl_exitPending = false;
  this.sbl_exitTries = 0;

  // local AI interruption before physics
  SBL_SendMeleeStim(this, npc);

  // queue second stage after stim has a frame to process
  SBL_Sched(this, new SBL_ArmEvt(), 0.03);

  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnSBL_TickEvt(e: ref<SBL_TickEvt>) -> Bool {
  let s: ref<SBL_Settings> = new SBL_Settings();
  let npc: wref<NPCPuppet>;
  let ppos: Vector4;
  let npos: Vector4;
  let moveVec: Vector4;
  let moveLen: Float;
  let pspd: Float;
  let toNPC: Vector4;
  let dist: Float;
  let dirToNPC: Vector4;
  let moveDir: Vector4;
  let id: EntityID;
  let rightDir: Vector4;
  let sideDot: Float;
  let sidePush: Float;
  let kickZ: Float;
  let pos: Vector4;

  if !s.enabled {
    this.sbl_active = false;
    return true;
  };

  if !this.sbl_active {
    SBL_Sched(this, new SBL_TickEvt(), SBL_TickDelay(s.intervalSec));
    return true;
  };

  ppos = this.GetWorldPosition();

  pspd = 0.0;
  moveLen = 0.0;

  if this.sbl_lastPosValid {
    moveVec = ppos - this.sbl_lastPos;
    moveLen = Vector4.Length(moveVec);
    pspd = moveLen / SBL_TickDelay(s.intervalSec);
  } else {
    this.sbl_lastPosValid = true;
    this.sbl_lastPos = ppos;
    SBL_Sched(this, new SBL_TickEvt(), SBL_TickDelay(s.intervalSec));
    return true;
  };

  this.sbl_lastPos = ppos;

  if this.sbl_cd || this.sbl_armQueued {
    SBL_Sched(this, new SBL_TickEvt(), SBL_TickDelay(s.intervalSec));
    return true;
  };

  if s.minSpeedMps > 0.00 && pspd < s.minSpeedMps {
    SBL_Sched(this, new SBL_TickEvt(), SBL_TickDelay(s.intervalSec));
    return true;
  };

  npc = SBL_GetPreferredTarget(this, s);
  if !IsDefined(npc) {
    SBL_Sched(this, new SBL_TickEvt(), SBL_TickDelay(s.intervalSec));
    return true;
  };

  npos = npc.GetWorldPosition();
  toNPC = npos - ppos;
  dist = Vector4.Length(toNPC);

  if s.contactDistM > 0.00 && dist > s.contactDistM {
    SBL_Sched(this, new SBL_TickEvt(), SBL_TickDelay(s.intervalSec));
    return true;
  };

  if moveLen <= 0.001 {
    SBL_Sched(this, new SBL_TickEvt(), SBL_TickDelay(s.intervalSec));
    return true;
  };

  moveDir = Vector4.Normalize(moveVec);
  dirToNPC = Vector4.Normalize(toNPC);


  id = npc.GetEntityID();
  if this.sbl_contactID != id {
    this.sbl_contactID = id;
  };


  rightDir = this.GetWorldRight();
  sideDot = Vector4.Dot(dirToNPC, rightDir);
  sidePush = sideDot * s.sideXY;
  kickZ = s.liftZ - s.downZ;

  pos = npos;
  pos.Z += 0.50;

  this.sbl_armTarget = npc;
  this.sbl_armPos = pos;
  this.sbl_armImp = new Vector4(
    moveDir.X * s.pushXY + rightDir.X * sidePush,
    moveDir.Y * s.pushXY + rightDir.Y * sidePush,
    kickZ,
    1.0
  );
  this.sbl_armRadius = s.radius;
  this.sbl_armQueued = true;

  SBL_Sched(this, new SBL_ArmEvt(), s.impactPauseSec);
  SBL_Sched(this, new SBL_TickEvt(), SBL_TickDelay(s.intervalSec));
  return true;
}

private func SBL_Start(p: wref<PlayerPuppet>) -> Void {
  if !IsDefined(p) {
    return;
  };
  p.sbl_active = true;
  SBL_Sched(p, new SBL_TickEvt(), 0.10);
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let res: Bool = wrappedMethod();
  SBL_Start(this);
  return res;
}

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
  let res: Bool = wrappedMethod(ri);
  SBL_Start(this);
  return res;
}

@wrapMethod(ReactionManagerComponent)
protected cb func OnPlayerProximityStartEvent(evt: ref<PlayerProximityStartEvent>) -> Bool {
  return wrappedMethod(evt);
}

@wrapMethod(ReactionManagerComponent)
protected cb func OnPlayerProximityStopEvent(evt: ref<PlayerProximityStopEvent>) -> Bool {
  return wrappedMethod(evt);
}

@wrapMethod(ReactionManagerComponent)
protected cb func OnProximityLookatEvent(evt: ref<ProximityLookatEvent>) -> Bool {
  return false;
}
