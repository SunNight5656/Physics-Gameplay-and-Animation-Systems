module RealisticPush

// ============================================================
// BUMP -> TRIP RAGDOLL (ReactionManagerComponent.OnBumpEvent)
// - Uses Mod Settings via @runtimeProperty (like your working example)
// - No SimTime (EngineTime issues). Cooldown handled by delayed reset event.
// - No GameObject.IsAlive / npc.IsAlive (your build errors). We avoid alive checks.
// - Organic direction: uses evt.direction and converts it into the NPC's own forward/right axes.
// - Delay ragdoll so the bump anim can play first.
// ============================================================

// ------------------------------------------------------------
// Mod Settings (same pattern as your GS_Settings example)
// ------------------------------------------------------------
public class TRIP_Settings {

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.displayName", "Show Trip Animation")
  @runtimeProperty("ModSettings.description", "Show the Trip Animation settings.")
  public let showTripAnimation: Bool = false;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Enable")
  @runtimeProperty("ModSettings.description", "Enable bump to trip ragdoll using ReactionManagerComponent.OnBumpEvent.")
  public let enabled: Bool = true;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Chance (%)")
  @runtimeProperty("ModSettings.description", "Chance that a bump triggers a trip ragdoll.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "100.0")
  @runtimeProperty("ModSettings.step", "1.0")
  public let chancePct: Float = 35.0;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Cooldown (sec)")
  @runtimeProperty("ModSettings.description", "Cooldown between trips per NPC (prevents spam).")
  @runtimeProperty("ModSettings.min", "0.05")
  @runtimeProperty("ModSettings.max", "3.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let cooldownSec: Float = 0.65;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Min Bump Speed")
  @runtimeProperty("ModSettings.description", "Minimum evt.sourceSpeed to allow trip. Helps block punches or tiny nudges if those report low speed.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "6.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let minBumpSpeed: Float = 0.60;
@runtimeProperty("ModSettings.mod", "Splat Physics")
@runtimeProperty("ModSettings.category", "Bump: Trip Animation")
@runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
@runtimeProperty("ModSettings.displayName", "[TRIP] Combat Bypass")
@runtimeProperty("ModSettings.description", "If the NPC is alerted/in combat/targeting the player, bypass the bump speed gate so slow shoves still trip them.")
public let combatBypass: Bool = true;
@runtimeProperty("ModSettings.mod", "Splat Physics")
@runtimeProperty("ModSettings.category", "Bump: Trip Animation")
@runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
@runtimeProperty("ModSettings.displayName", "[TRIP] Combat Min Speed")
@runtimeProperty("ModSettings.description", "Min bump speed used only when Combat Bypass is enabled and the NPC is alerted/in combat/targeting the player.")
@runtimeProperty("ModSettings.min", "0.00")
@runtimeProperty("ModSettings.max", "6.00")
@runtimeProperty("ModSettings.step", "0.05")
public let combatMinBumpSpeed: Float = 0.00;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Ragdoll Delay (sec)")
  @runtimeProperty("ModSettings.description", "Delay before forcing ragdoll so the bump animation can play first.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.50")
  @runtimeProperty("ModSettings.step", "0.01")
  public let ragdollDelaySec: Float = 0.18;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Impulse Delay (sec)")
  @runtimeProperty("ModSettings.description", "Extra delay for the impulse after ragdoll (usually keep small or 0).")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.50")
  @runtimeProperty("ModSettings.step", "0.005")
  public let impulseDelaySec: Float = 0.00;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Radius (m)")
  @runtimeProperty("ModSettings.description", "Impulse radius.")
  @runtimeProperty("ModSettings.min", "0.10")
  @runtimeProperty("ModSettings.max", "12.00")
  @runtimeProperty("ModSettings.step", "0.10")
  public let radiusM: Float = 1.20;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Z Offset")
  @runtimeProperty("ModSettings.description", "Applies impulse at NPC position plus this Z offset (chest-ish).")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "2.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let zOffset: Float = 1.00;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Down Strength")
  @runtimeProperty("ModSettings.description", "Vertical downward impulse strength.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "20.0")
  @runtimeProperty("ModSettings.step", "0.25")
  public let downZ: Float = 4.25;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Base Push")
  @runtimeProperty("ModSettings.description", "Base horizontal push along bump direction.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "20.0")
  @runtimeProperty("ModSettings.step", "0.25")
  public let basePush: Float = 2.75;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Local Forward Scale")
  @runtimeProperty("ModSettings.description", "Scales horizontal push along the NPC's own forward/back axis instead of raw world XY.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "3.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let localForwardScale: Float = 1.00;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Local Side Scale")
  @runtimeProperty("ModSettings.description", "Scales horizontal push along the NPC's own left/right axis instead of raw world XY.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "3.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let localSideScale: Float = 1.00;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Debug Extreme")
  @runtimeProperty("ModSettings.description", "If ON, multiplies push/down so you can confirm it is firing.")
  public let extreme: Bool = false;
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Bump: Trip Animation")
  @runtimeProperty("ModSettings.category.order", "25")
  @runtimeProperty("ModSettings.dependency", "showTripAnimation")
  @runtimeProperty("ModSettings.displayName", "[TRIP] Extreme Mult")
  @runtimeProperty("ModSettings.description", "Multiplier used when Debug Extreme is ON.")
  @runtimeProperty("ModSettings.min", "1.0")
  @runtimeProperty("ModSettings.max", "25.0")
  @runtimeProperty("ModSettings.step", "0.5")
  public let extremeMult: Float = 6.0;

}

// ------------------------------------------------------------
// State stored on the component (no time math)
// ------------------------------------------------------------
@addField(ReactionManagerComponent) private let trip_cd: Bool;

// ------------------------------------------------------------
// Events
// ------------------------------------------------------------
public class TRIP_ResetCooldownEvt extends Event {}

public class TRIP_ForceEvt extends Event {}

public class TRIP_ImpulseEvt extends Event {
  public let dir: Vector4;
  public let push: Float;
  public let down: Float;
  public let radius: Float;
  public let zOff: Float;
  public let localForwardScale: Float;
  public let localSideScale: Float;
}

// ------------------------------------------------------------
// Helpers
// ------------------------------------------------------------
private func TRIP_ClampT(t: Float) -> Float {
  return MaxF(0.001, t);
}

private func TRIP_Clamp(v: Float, lo: Float, hi: Float) -> Float {
  if v < lo { return lo; }
  if v > hi { return hi; }
  return v;
}

private func TRIP_Clamp01(v: Float) -> Float {
  return TRIP_Clamp(v, 0.0, 1.0);
}

private func TRIP_Normalize2D(v: Vector4) -> Vector4 {
  let out: Vector4 = v;
  let len: Float;

  out.Z = 0.0;
  len = Vector4.Length(out);

  if len <= 0.001 {
    return new Vector4(0.0, 1.0, 0.0, 0.0);
  }

  return out / len;
}

private func TRIP_Schedule(ds: ref<DelaySystem>, target: wref<GameObject>, e: ref<Event>, t: Float) -> Void {
  if !IsDefined(ds) || !IsDefined(target) || !IsDefined(e) { return; }
  ds.DelayEvent(target, e, TRIP_ClampT(t), false);
}

private func TRIP_ApplyImpulse(p: wref<NPCPuppet>, e: ref<TRIP_ImpulseEvt>) -> Void {
  let pos: Vector4;
  let dir2: Vector4;
  let forward2: Vector4;
  let right2: Vector4;
  let localF: Float;
  let localR: Float;
  let world2: Vector4;
  let impulse: Vector4;

  if !IsDefined(p) { return; }
  if !ScriptedPuppet.CanRagdoll(p) { return; }

  pos = p.GetWorldPosition();
  pos.Z += e.zOff;

  dir2 = TRIP_Normalize2D(e.dir);
  forward2 = TRIP_Normalize2D(p.GetWorldForward());
  right2 = TRIP_Normalize2D(p.GetWorldRight());

  localF = Vector4.Dot(dir2, forward2);
  localR = Vector4.Dot(dir2, right2);

  world2 = new Vector4(
    forward2.X * (localF * e.push * e.localForwardScale) + right2.X * (localR * e.push * e.localSideScale),
    forward2.Y * (localF * e.push * e.localForwardScale) + right2.Y * (localR * e.push * e.localSideScale),
    0.0,
    0.0
  );

  impulse = new Vector4(
    world2.X,
    world2.Y,
    -e.down,
    1.0
  );

  p.QueueEvent(CreateRagdollApplyImpulseEvent(pos, impulse, e.radius));
}

private func TRIP_HasAnyWorkspotLock(p: wref<GameObject>) -> Bool {
  if !IsDefined(p) { return false; }

  // Workspot locks (exclude JohnnySceneWorkspot on purpose)
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.SyncAnimation") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.SyncAnimation_inline0") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.SyncAnimation_inline1") { return true; }

  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Busy") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.LoreAnim") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Sleep") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Unconscious") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.NoSenses") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.SwimTube") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Braindance") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Deaf") { return true; }

  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Drunk") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Drunk_inline0") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Drunk_inline1") { return true; }

  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Death") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Death_inline0") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Death_inline1") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Death_inline2") { return true; }

  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune_inline0") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune_inline1") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune_inline2") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune_inline3") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune_inline4") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune_inline5") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune_inline6") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune_inline7") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune_inline8") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune_inline9") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune_inline10") { return true; }
  if StatusEffectSystem.ObjectHasStatusEffect(p, t"WorkspotStatus.Immune_inline11") { return true; }

  return false;
}




// ------------------------------------------------------------
// Puppet event handlers (DelaySystem targets objects)
// ------------------------------------------------------------
@addMethod(NPCPuppet)
protected cb func OnTRIP_ForceEvt(e: ref<TRIP_ForceEvt>) -> Bool {
  this.QueueEvent(CreateForceRagdollEvent(n"TRIP_Bump"));
  return true;
}

@addMethod(NPCPuppet)
protected cb func OnTRIP_ImpulseEvt(e: ref<TRIP_ImpulseEvt>) -> Bool {
  TRIP_ApplyImpulse(this, e);
  return true;
}

@addMethod(NPCPuppet)
protected cb func OnTRIP_ResetCooldownEvt(e: ref<TRIP_ResetCooldownEvt>) -> Bool {
  let rc: ref<ReactionManagerComponent>;

  // This is the safe, public way. You already saw it in your class dump:
  // ScriptedPuppet has GetStimReactionComponent() -> ReactionManagerComponent
  rc = this.GetStimReactionComponent();

  if IsDefined(rc) {
    rc.trip_cd = false;
  }

  return true;
}

// ------------------------------------------------------------
// The hook that matters
// ------------------------------------------------------------
@wrapMethod(ReactionManagerComponent)
protected cb func OnBumpEvent(evt: ref<BumpEvent>) -> Bool {
  let res: Bool = wrappedMethod(evt);

  let s: ref<TRIP_Settings> = new TRIP_Settings();

  let ownerGO: wref<GameObject>;
  let npc: wref<NPCPuppet>;
  let ds: ref<DelaySystem>;

  let chance01: Float;
  let push: Float;
  let down: Float;

  let forceDelay: Float;
  let impulseDelay: Float;

  let imp: ref<TRIP_ImpulseEvt>;

  if !s.enabled { return res; }

  ownerGO = this.GetOwner();
  npc = ownerGO as NPCPuppet;

  if !IsDefined(npc) { return res; }

  // Cooldown (no time math)
  if this.trip_cd { return res; }
  this.trip_cd = true;

  ds = GameInstance.GetDelaySystem(npc.GetGame());
  if IsDefined(ds) {
    TRIP_Schedule(ds, npc, new TRIP_ResetCooldownEvt(), s.cooldownSec);
  }


  // Workspot gate: skip speed gating and use longer force retries when in a workspot
  let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(npc.GetGame());
  let inWorkspot: Bool = false;
  if IsDefined(ws) {
    if ws.IsActorInWorkspot(npc) {
      inWorkspot = true;
    }
  }

  // Speed gate
// NOTE: Some combat/aim/workspot targets report very low bump speed even when you are clearly body-checking them.
// When combatBypass is enabled, we relax this gate for alerted/in-combat/targeting-player states.
let combatOK: Bool = false;
if s.combatBypass {
  // Instance methods (available per your RTTI dump)
  if npc.IsPuppetInCombat() || npc.IsPuppetTargetingPlayer() {
    combatOK = true;
  } else {
    // Static method, must be called on type
    if NPCPuppet.IsInAlerted(npc) {
      combatOK = true;
    }
  }
}

if !inWorkspot {
if !combatOK {
  if evt.sourceSpeed < s.minBumpSpeed { return res; }
} else {
  if evt.sourceSpeed < s.combatMinBumpSpeed { return res; }
}
}

  // Chance gate
  chance01 = TRIP_Clamp01(s.chancePct / 100.0);
  if chance01 <= 0.0 { return res; }
  if chance01 < 1.0 {
    if RandF() >= chance01 { return res; }
  }

  // Compute push from base value only
  push = s.basePush;
  down = s.downZ;

  if s.extreme {
    push *= TRIP_Clamp(s.extremeMult, 1.0, 25.0);
    down *= TRIP_Clamp(s.extremeMult, 1.0, 25.0);
  }

  // Let the bump animation play first
  forceDelay = TRIP_ClampT(s.ragdollDelaySec);
  impulseDelay = TRIP_ClampT(s.ragdollDelaySec + s.impulseDelaySec);

  if !IsDefined(ds) {
    // Fallback if DelaySystem not available (rare)
    npc.QueueEvent(CreateForceRagdollEvent(n"TRIP_Bump"));
    imp = new TRIP_ImpulseEvt();
    imp.dir = evt.direction;
    imp.push = push;
    imp.down = down;
    imp.radius = s.radiusM;
    imp.zOff = s.zOffset;
    imp.localForwardScale = s.localForwardScale;
    imp.localSideScale = s.localSideScale;
    TRIP_ApplyImpulse(npc, imp);
    return res;
  }

  // Force ragdoll burst. Workspots and combat tasks can reassert control.
TRIP_Schedule(ds, npc, new TRIP_ForceEvt(), forceDelay);
TRIP_Schedule(ds, npc, new TRIP_ForceEvt(), forceDelay + 0.12);
TRIP_Schedule(ds, npc, new TRIP_ForceEvt(), forceDelay + 0.25);
TRIP_Schedule(ds, npc, new TRIP_ForceEvt(), forceDelay + 0.45);
TRIP_Schedule(ds, npc, new TRIP_ForceEvt(), forceDelay + 0.70);

  imp = new TRIP_ImpulseEvt();
  imp.dir = evt.direction;
  imp.push = push;
  imp.down = down;
  imp.radius = s.radiusM;
  imp.zOff = s.zOffset;
  imp.localForwardScale = s.localForwardScale;
  imp.localSideScale = s.localSideScale;

  if inWorkspot {
    TRIP_Schedule(ds, npc, imp, impulseDelay + 0.25);
  } else {
    TRIP_Schedule(ds, npc, imp, impulseDelay);
  }

  return res;
}

// ------------------------------------------------------------
