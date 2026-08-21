module RealisticPush

public class AAT_TripSettings {
public let showTripAnimationSection: Bool = true;
  public let enabled: Bool = false;
  public let showTripAnimationAdvanced: Bool = false;

  // Hidden legacy gate. Kept at 0.00 so this restore does not silently block OnBump testing.
  public let minBumpSpeed: Float = 0.00;
  public let chancePct: Float = 100.00;
  public let forwardPush: Float = 4.00;
  public let downwardForce: Float = 3.00;
  public let ragdollDelaySec: Float = 1.15;
  public let bodyArea: Float = 5.00;
  public let hitHeight: Float = 0.55;
  public let lockoutSec: Float = 3.00;

  // Hidden defaults. The code still reads these, but they no longer clutter the menu.
  public let impulseDelayAfterRagdoll: Float = 0.05;
  public let impulsePasses: Int32 = 2;
  public let impulsePassInterval: Float = 0.08;
  public let impulseDeliveryMode: Int32 = 1;
  public let emotionDelayAfterRagdoll: Float = 0.20;
  public let maxTripUsesPerNPC: Int32 = 99;
}

private func AAT_TripCfg() -> ref<AAT_TripSettings> {
  let settings: ref<AAT_TripSettings> = new AAT_TripSettings();
  let menu: ref<RFCModSettings> = SPLATSettingsRuntime.Menu();
  let mode: Int32 = EnumInt(menu.splatPresetMode);
  if mode == EnumInt(RFCSplatPresetMode.Realism) {
    settings.showTripAnimationSection = menu.customTripAnimation_showTripAnimationSection;
    settings.enabled = menu.customTripAnimation_enabled;
    settings.showTripAnimationAdvanced = menu.customTripAnimation_showTripAnimationAdvanced;
    settings.chancePct = menu.customTripAnimation_chancePct;
    settings.forwardPush = menu.customTripAnimation_forwardPush;
    settings.downwardForce = menu.customTripAnimation_downwardForce;
    settings.ragdollDelaySec = menu.customTripAnimation_ragdollDelaySec;
    settings.bodyArea = menu.customTripAnimation_bodyArea;
    settings.hitHeight = menu.customTripAnimation_hitHeight;
    settings.lockoutSec = menu.customTripAnimation_lockoutSec;
  }
  else if mode == EnumInt(RFCSplatPresetMode.RealismPlus) {
    settings.showTripAnimationSection = menu.realismPlusTripAnimation_showTripAnimationSection;
    settings.enabled = menu.realismPlusTripAnimation_enabled;
    settings.showTripAnimationAdvanced = menu.realismPlusTripAnimation_showTripAnimationAdvanced;
    settings.chancePct = menu.realismPlusTripAnimation_chancePct;
    settings.forwardPush = menu.realismPlusTripAnimation_forwardPush;
    settings.downwardForce = menu.realismPlusTripAnimation_downwardForce;
    settings.ragdollDelaySec = menu.realismPlusTripAnimation_ragdollDelaySec;
    settings.bodyArea = menu.realismPlusTripAnimation_bodyArea;
    settings.hitHeight = menu.realismPlusTripAnimation_hitHeight;
    settings.lockoutSec = menu.realismPlusTripAnimation_lockoutSec;
  }
  else if mode == EnumInt(RFCSplatPresetMode.DirtyHarry) {
    settings.showTripAnimationSection = menu.dirtyTripAnimation_showTripAnimationSection;
    settings.enabled = menu.dirtyTripAnimation_enabled;
    settings.showTripAnimationAdvanced = menu.dirtyTripAnimation_showTripAnimationAdvanced;
    settings.chancePct = menu.dirtyTripAnimation_chancePct;
    settings.forwardPush = menu.dirtyTripAnimation_forwardPush;
    settings.downwardForce = menu.dirtyTripAnimation_downwardForce;
    settings.ragdollDelaySec = menu.dirtyTripAnimation_ragdollDelaySec;
    settings.bodyArea = menu.dirtyTripAnimation_bodyArea;
    settings.hitHeight = menu.dirtyTripAnimation_hitHeight;
    settings.lockoutSec = menu.dirtyTripAnimation_lockoutSec;
  }
  else if mode == EnumInt(RFCSplatPresetMode.Arnold) {
    settings.showTripAnimationSection = menu.arnoldTripAnimation_showTripAnimationSection;
    settings.enabled = menu.arnoldTripAnimation_enabled;
    settings.showTripAnimationAdvanced = menu.arnoldTripAnimation_showTripAnimationAdvanced;
    settings.chancePct = menu.arnoldTripAnimation_chancePct;
    settings.forwardPush = menu.arnoldTripAnimation_forwardPush;
    settings.downwardForce = menu.arnoldTripAnimation_downwardForce;
    settings.ragdollDelaySec = menu.arnoldTripAnimation_ragdollDelaySec;
    settings.bodyArea = menu.arnoldTripAnimation_bodyArea;
    settings.hitHeight = menu.arnoldTripAnimation_hitHeight;
    settings.lockoutSec = menu.arnoldTripAnimation_lockoutSec;
  }
  return settings;
}




@addField(NPCPuppet)
private let aatTripLocked: Bool;

@addField(NPCPuppet)
private let aatTripLaneKilled: Bool;

@addField(NPCPuppet)
private let aatTripUseCount: Int32;

@addField(NPCPuppet)
private let aatTripGen: Int32;

public class AAT_TripResetEvt extends Event {
  public let tripGen: Int32;
}

public class AAT_TripImpulseEvt extends Event {
  public let pos: Vector4;
  public let imp: Vector4;
  public let radius: Float;
}

public class AAT_TripRagdollEvt extends Event {}

@addMethod(NPCPuppet)
private cb func OnAAT_TripImpulseEvt(e: ref<AAT_TripImpulseEvt>) -> Bool {
  let cfg: RFCConfig = RFC.Cfg();
  if cfg.vanillaMode
    || RFC_IsStealthOrFinisher(this)
    || RFC_TimeDilationBlocksImpulses(this, cfg) {
    return true;
  };
  if IsDefined(e) {
    this.QueueEvent(CreateRagdollApplyImpulseEvent(e.pos, e.imp, e.radius));
  };
  return true;
}

@addMethod(NPCPuppet)
private cb func OnAAT_TripRagdollEvt(e: ref<AAT_TripRagdollEvt>) -> Bool {
  let cfg: RFCConfig = RFC.Cfg();
  if cfg.vanillaMode
    || RFC_IsStealthOrFinisher(this)
    || RFC_TimeDilationBlocksImpulses(this, cfg) {
    return true;
  };

  this.QueueEvent(CreateForceRagdollEvent(n"AAA_Trip_OnBumpHandoff"));
  return true;
}

@addMethod(NPCPuppet)
private cb func OnAAT_TripResetEvt(evt: ref<AAT_TripResetEvt>) -> Bool {
  if !IsDefined(evt) || evt.tripGen == this.aatTripGen {
    this.aatTripLocked = false;
  };
  return true;
}

@addMethod(NPCPuppet)
private final func AAT_TripScheduleOneImpulse(ds: ref<DelaySystem>, pos: Vector4, impulse: Vector4, radius: Float, delay: Float, mode: Int32) -> Void {
  let bridgeEvt: ref<AAT_TripImpulseEvt>;

  if RFC.Cfg().vanillaMode || RFC_IsStealthOrFinisher(this) { return; }

  if !IsDefined(ds) || RFC_TimeDilationBlocksImpulsesNow(this) {
    return;
  };

  // Always use the guarded bridge so a stealth kill or finisher that starts
  // after the trip was scheduled can still cancel the delayed impulse.
  bridgeEvt = new AAT_TripImpulseEvt();
  bridgeEvt.pos = pos;
  bridgeEvt.imp = impulse;
  bridgeEvt.radius = radius;
  ds.DelayEvent(this, bridgeEvt, delay, false);
}

@addMethod(NPCPuppet)
private final func AAT_TripScheduleImpulseBurst(ds: ref<DelaySystem>, pos: Vector4, impulse: Vector4, radius: Float, startDelay: Float, passes: Int32, interval: Float, mode: Int32) -> Void {
  if !IsDefined(ds) {
    return;
  };

  if passes < 1 {
    passes = 1;
  };
  if passes > 5 {
    passes = 5;
  };
  if interval < 0.03 {
    interval = 0.03;
  };
  if interval > 0.50 {
    interval = 0.50;
  };

  this.AAT_TripScheduleOneImpulse(ds, pos, impulse, radius, startDelay, mode);

  if passes >= 2 {
    this.AAT_TripScheduleOneImpulse(ds, pos, impulse, radius, startDelay + interval, mode);
  };
  if passes >= 3 {
    this.AAT_TripScheduleOneImpulse(ds, pos, impulse, radius, startDelay + interval + interval, mode);
  };
  if passes >= 4 {
    this.AAT_TripScheduleOneImpulse(ds, pos, impulse, radius, startDelay + interval + interval + interval, mode);
  };
  if passes >= 5 {
    this.AAT_TripScheduleOneImpulse(ds, pos, impulse, radius, startDelay + interval + interval + interval + interval, mode);
  };
}

@addMethod(NPCPuppet)
private final func AAT_TripSafeDir(rawDir: Vector4) -> Vector4 {
  let dir: Vector4;
  let fallback: Vector4;
  let len: Float;

  dir = new Vector4(rawDir.X, rawDir.Y, 0.0, 0.0);
  len = Vector4.Length(dir);

  if len > 0.01 {
    return Vector4.Normalize(dir);
  };

  fallback = this.GetWorldForward();
  fallback.Z = 0.0;
  len = Vector4.Length(fallback);

  if len > 0.01 {
    return Vector4.Normalize(fallback);
  };

  return new Vector4(0.0, 1.0, 0.0, 0.0);
}

@addMethod(NPCPuppet)
private final func AAT_TripFire(playerTarget: ref<GameObject>, rawDir: Vector4, s: ref<AAT_TripSettings>) -> Void {
  let ds: ref<DelaySystem>;
  let pos: Vector4;
  let dir: Vector4;
  let impulse: Vector4;
  let forceEvt: ref<AAT_TripRagdollEvt>;
  let resetEvt: ref<AAT_TripResetEvt>;
  let emotionEvt: ref<AAT_EmotionEvt>;
  let impulseDelay: Float;
  let emotionDelay: Float;

  if RFC.Cfg().vanillaMode
    || RFC_IsStealthOrFinisher(this)
    || !IsDefined(s) {
    return;
  };

  if !ScriptedPuppet.CanRagdoll(this) {
    this.aatTripLocked = false;
    return;
  };

  this.aatTripUseCount += 1;
  if this.aatTripUseCount >= s.maxTripUsesPerNPC {
    this.aatTripLaneKilled = true;
  };

  dir = this.AAT_TripSafeDir(rawDir);

  pos = this.GetWorldPosition();
  pos.Z += s.hitHeight;

  impulse = new Vector4(
    dir.X * s.forwardPush,
    dir.Y * s.forwardPush,
    -s.downwardForce,
    1.00
  );

  forceEvt = new AAT_TripRagdollEvt();
  resetEvt = new AAT_TripResetEvt();
  resetEvt.tripGen = this.aatTripGen;

  impulseDelay = s.ragdollDelaySec + s.impulseDelayAfterRagdoll;
  emotionDelay = s.ragdollDelaySec + s.emotionDelayAfterRagdoll;

  ds = GameInstance.GetDelaySystem(this.GetGame());
  if IsDefined(ds) {
    ds.DelayEvent(this, forceEvt, s.ragdollDelaySec, false);
    this.AAT_TripScheduleImpulseBurst(ds, pos, impulse, s.bodyArea, impulseDelay, s.impulsePasses, s.impulsePassInterval, s.impulseDeliveryMode);
    ds.DelayEvent(this, resetEvt, s.lockoutSec, false);

    if IsDefined(playerTarget) {
      emotionEvt = new AAT_EmotionEvt();
      emotionEvt.target = playerTarget;
      ds.DelayEvent(this, emotionEvt, emotionDelay, false);
    };
  } else {
    this.QueueEvent(forceEvt);
    this.QueueEvent(CreateRagdollApplyImpulseEvent(pos, impulse, s.bodyArea));
    this.QueueEvent(resetEvt);
  };
}

@wrapMethod(ReactionManagerComponent)
protected cb func OnBumpEvent(evt: ref<BumpEvent>) -> Bool {
  let res: Bool = wrappedMethod(evt);
  let s: ref<AAT_TripSettings> = AAT_TripCfg();
  let ownerGO: wref<GameObject>;
  let npc: wref<NPCPuppet>;
  let playerTarget: ref<GameObject>;
  let chance01: Float;

  if !IsDefined(evt) || !IsDefined(s) {
    return res;
  };

  if RFC.Cfg().vanillaMode {
    return res;
  };

  if !s.enabled {
    return res;
  };

  ownerGO = this.GetOwner();
  npc = ownerGO as NPCPuppet;

  if !IsDefined(npc) {
    return res;
  };

  // Stealth kills / finishers own the target completely. Trip Animation must
  // not lock, ragdoll, impulse, or consume a trip use during that window.
  if RFC_IsStealthOrFinisher(npc) {
    return res;
  };

  if npc.aatTripUseCount >= s.maxTripUsesPerNPC {
    npc.aatTripLaneKilled = true;
    return res;
  };

  if npc.aatTripLocked {
    return true;
  };

  if evt.sourceSpeed < s.minBumpSpeed {
    return res;
  };

  chance01 = s.chancePct / 100.0;
  if chance01 < 0.0 {
    chance01 = 0.0;
  };
  if chance01 > 1.0 {
    chance01 = 1.0;
  };
  if chance01 <= 0.0 {
    return res;
  };

  if chance01 < 1.0 {
    if RandF() >= chance01 {
      return res;
    };
  };

  playerTarget = GameInstance.GetPlayerSystem(npc.GetGame()).GetLocalPlayerControlledGameObject();

  npc.aatTripLocked = true;
  npc.aatTripGen += 1;
  npc.AAT_TripFire(playerTarget, evt.direction, s);

  return true;
}
