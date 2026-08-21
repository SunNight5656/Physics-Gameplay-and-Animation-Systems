module RealisticPush

// AAA Trip - 02 On Look
// Separate look-at/contact path.
// Menu cleanup: basic controls stay visible; center trim, hit position, body area, and timing controls live under Advanced.

public class AAT_OnLookSettings {
public let showOnLookSection: Bool = true;
  public let enabled: Bool = false;
  public let aggressiveOnly: Bool = true;
  public let requireCenterScreen: Bool = true;
  public let showAdvancedOnLook: Bool = false;
  public let contactDistM: Float = 0.85;
  public let minSpeedMps: Float = 6.90;
  public let pushXY: Float = 28.00;
  public let downZ: Float = 11.00;
  public let centerAimTightness: Float = 0.90;
  public let centerLaneWidth: Float = 0.35;
  public let sideXY: Float = 9.00;
  public let liftZ: Float = 1.00;
  public let radius: Float = 1.20;
  public let zOffset: Float = 0.50;
  public let cooldownSec: Float = 0.80;
  public let intervalSec: Float = 0.05;
  public let impactPauseSec: Float = 0.03;
  public let impulseDelaySec: Float = 0.03;
  public let emotionDelayAfterRagdoll: Float = 0.20;
}

private func AAT_OnLookCfg() -> ref<AAT_OnLookSettings> {
  let settings: ref<AAT_OnLookSettings> = new AAT_OnLookSettings();
  let menu: ref<RFCModSettings> = SPLATSettingsRuntime.Menu();
  let mode: Int32 = EnumInt(menu.splatPresetMode);
  if mode == EnumInt(RFCSplatPresetMode.Realism) {
    settings.showOnLookSection = menu.customTripOnLook_showOnLookSection;
    settings.enabled = menu.customTripOnLook_enabled;
    settings.aggressiveOnly = menu.customTripOnLook_aggressiveOnly;
    settings.requireCenterScreen = menu.customTripOnLook_requireCenterScreen;
    settings.showAdvancedOnLook = menu.customTripOnLook_showAdvancedOnLook;
    settings.contactDistM = menu.customTripOnLook_contactDistM;
    settings.minSpeedMps = menu.customTripOnLook_minSpeedMps;
    settings.pushXY = menu.customTripOnLook_pushXY;
    settings.downZ = menu.customTripOnLook_downZ;
    settings.centerAimTightness = menu.customTripOnLook_centerAimTightness;
    settings.centerLaneWidth = menu.customTripOnLook_centerLaneWidth;
    settings.sideXY = menu.customTripOnLook_sideXY;
    settings.liftZ = menu.customTripOnLook_liftZ;
    settings.radius = menu.customTripOnLook_radius;
    settings.zOffset = menu.customTripOnLook_zOffset;
    settings.cooldownSec = menu.customTripOnLook_cooldownSec;
    settings.intervalSec = menu.customTripOnLook_intervalSec;
    settings.impactPauseSec = menu.customTripOnLook_impactPauseSec;
    settings.impulseDelaySec = menu.customTripOnLook_impulseDelaySec;
    settings.emotionDelayAfterRagdoll = menu.customTripOnLook_emotionDelayAfterRagdoll;
  }
  else if mode == EnumInt(RFCSplatPresetMode.RealismPlus) {
    settings.showOnLookSection = menu.realismPlusTripOnLook_showOnLookSection;
    settings.enabled = menu.realismPlusTripOnLook_enabled;
    settings.aggressiveOnly = menu.realismPlusTripOnLook_aggressiveOnly;
    settings.requireCenterScreen = menu.realismPlusTripOnLook_requireCenterScreen;
    settings.showAdvancedOnLook = menu.realismPlusTripOnLook_showAdvancedOnLook;
    settings.contactDistM = menu.realismPlusTripOnLook_contactDistM;
    settings.minSpeedMps = menu.realismPlusTripOnLook_minSpeedMps;
    settings.pushXY = menu.realismPlusTripOnLook_pushXY;
    settings.downZ = menu.realismPlusTripOnLook_downZ;
    settings.centerAimTightness = menu.realismPlusTripOnLook_centerAimTightness;
    settings.centerLaneWidth = menu.realismPlusTripOnLook_centerLaneWidth;
    settings.sideXY = menu.realismPlusTripOnLook_sideXY;
    settings.liftZ = menu.realismPlusTripOnLook_liftZ;
    settings.radius = menu.realismPlusTripOnLook_radius;
    settings.zOffset = menu.realismPlusTripOnLook_zOffset;
    settings.cooldownSec = menu.realismPlusTripOnLook_cooldownSec;
    settings.intervalSec = menu.realismPlusTripOnLook_intervalSec;
    settings.impactPauseSec = menu.realismPlusTripOnLook_impactPauseSec;
    settings.impulseDelaySec = menu.realismPlusTripOnLook_impulseDelaySec;
    settings.emotionDelayAfterRagdoll = menu.realismPlusTripOnLook_emotionDelayAfterRagdoll;
  }
  else if mode == EnumInt(RFCSplatPresetMode.DirtyHarry) {
    settings.showOnLookSection = menu.dirtyTripOnLook_showOnLookSection;
    settings.enabled = menu.dirtyTripOnLook_enabled;
    settings.aggressiveOnly = menu.dirtyTripOnLook_aggressiveOnly;
    settings.requireCenterScreen = menu.dirtyTripOnLook_requireCenterScreen;
    settings.showAdvancedOnLook = menu.dirtyTripOnLook_showAdvancedOnLook;
    settings.contactDistM = menu.dirtyTripOnLook_contactDistM;
    settings.minSpeedMps = menu.dirtyTripOnLook_minSpeedMps;
    settings.pushXY = menu.dirtyTripOnLook_pushXY;
    settings.downZ = menu.dirtyTripOnLook_downZ;
    settings.centerAimTightness = menu.dirtyTripOnLook_centerAimTightness;
    settings.centerLaneWidth = menu.dirtyTripOnLook_centerLaneWidth;
    settings.sideXY = menu.dirtyTripOnLook_sideXY;
    settings.liftZ = menu.dirtyTripOnLook_liftZ;
    settings.radius = menu.dirtyTripOnLook_radius;
    settings.zOffset = menu.dirtyTripOnLook_zOffset;
    settings.cooldownSec = menu.dirtyTripOnLook_cooldownSec;
    settings.intervalSec = menu.dirtyTripOnLook_intervalSec;
    settings.impactPauseSec = menu.dirtyTripOnLook_impactPauseSec;
    settings.impulseDelaySec = menu.dirtyTripOnLook_impulseDelaySec;
    settings.emotionDelayAfterRagdoll = menu.dirtyTripOnLook_emotionDelayAfterRagdoll;
  }
  else if mode == EnumInt(RFCSplatPresetMode.Arnold) {
    settings.showOnLookSection = menu.arnoldTripOnLook_showOnLookSection;
    settings.enabled = menu.arnoldTripOnLook_enabled;
    settings.aggressiveOnly = menu.arnoldTripOnLook_aggressiveOnly;
    settings.requireCenterScreen = menu.arnoldTripOnLook_requireCenterScreen;
    settings.showAdvancedOnLook = menu.arnoldTripOnLook_showAdvancedOnLook;
    settings.contactDistM = menu.arnoldTripOnLook_contactDistM;
    settings.minSpeedMps = menu.arnoldTripOnLook_minSpeedMps;
    settings.pushXY = menu.arnoldTripOnLook_pushXY;
    settings.downZ = menu.arnoldTripOnLook_downZ;
    settings.centerAimTightness = menu.arnoldTripOnLook_centerAimTightness;
    settings.centerLaneWidth = menu.arnoldTripOnLook_centerLaneWidth;
    settings.sideXY = menu.arnoldTripOnLook_sideXY;
    settings.liftZ = menu.arnoldTripOnLook_liftZ;
    settings.radius = menu.arnoldTripOnLook_radius;
    settings.zOffset = menu.arnoldTripOnLook_zOffset;
    settings.cooldownSec = menu.arnoldTripOnLook_cooldownSec;
    settings.intervalSec = menu.arnoldTripOnLook_intervalSec;
    settings.impactPauseSec = menu.arnoldTripOnLook_impactPauseSec;
    settings.impulseDelaySec = menu.arnoldTripOnLook_impulseDelaySec;
    settings.emotionDelayAfterRagdoll = menu.arnoldTripOnLook_emotionDelayAfterRagdoll;
  }
  return settings;
}




public class AAT_OnLookTickEvt extends Event {}
public class AAT_OnLookResetCdEvt extends Event {}
public class AAT_OnLookRagdollEvt extends Event {
  public let target: wref<NPCPuppet>;
}
public class AAT_OnLookImpulseEvt extends Event {
  public let target: wref<NPCPuppet>;
  public let pos: Vector4;
  public let imp: Vector4;
  public let radius: Float;
}

@addField(PlayerPuppet) private let aatOnLookActive: Bool;
@addField(PlayerPuppet) private let aatOnLookCd: Bool;
@addField(PlayerPuppet) private let aatOnLookLastPosValid: Bool;
@addField(PlayerPuppet) private let aatOnLookLastPos: Vector4;

private func AAT_OnLookDelay(t: Float) -> Float {
  if t <= 0.00 {
    return 0.01;
  };
  return t;
}

private func AAT_IsAggressiveNPC(p: wref<NPCPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  if p.IsAggressive() { return true; }
  if p.IsHostile() { return true; }
  if p.IsPuppetInCombat() { return true; }
  if p.IsPuppetTargetingPlayer() { return true; }
  if NPCPuppet.IsInAlerted(p) { return true; }
  return false;
}

private func AAT_OnLookSched(go: wref<GameObject>, e: ref<Event>, t: Float) -> Void {
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

private func AAT_GetLookAtNPC(p: wref<PlayerPuppet>) -> wref<NPCPuppet> {
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

@addMethod(PlayerPuppet)
protected cb func OnAAT_OnLookResetCdEvt(e: ref<AAT_OnLookResetCdEvt>) -> Bool {
  this.aatOnLookCd = false;
  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnAAT_OnLookRagdollEvt(e: ref<AAT_OnLookRagdollEvt>) -> Bool {
  let cfg: RFCConfig = RFC.Cfg();
  if cfg.vanillaMode { return true; }
  if IsDefined(e)
    && IsDefined(e.target)
    && !RFC_AnyDeathAnimationOwnsLifecycle(e.target)
    && !RFC_IsStealthOrFinisher(e.target)
    && !RFC_TimeDilationBlocksImpulses(e.target, cfg) {
    e.target.QueueEvent(CreateForceRagdollEvent(n"AAA_Trip_OnLook"));
  };
  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnAAT_OnLookImpulseEvt(e: ref<AAT_OnLookImpulseEvt>) -> Bool {
  let cfg: RFCConfig = RFC.Cfg();
  if cfg.vanillaMode { return true; }
  if IsDefined(e)
    && IsDefined(e.target)
    && !RFC_IsStealthOrFinisher(e.target)
    && !RFC_TimeDilationBlocksImpulses(e.target, cfg) {
    e.target.QueueEvent(CreateRagdollApplyImpulseEvent(e.pos, e.imp, e.radius));
  };
  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnAAT_OnLookTickEvt(e: ref<AAT_OnLookTickEvt>) -> Bool {
  let s: ref<AAT_OnLookSettings> = AAT_OnLookCfg();
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
  let playerForward: Vector4;
  let rightDir: Vector4;
  let aimDot: Float;
  let absSideAim: Float;
  let sideDot: Float;
  let sidePush: Float;
  let kickZ: Float;
  let pos: Vector4;
  let forwardDot: Float;
  let effectiveSpeed: Float;
  let re: ref<AAT_OnLookRagdollEvt>;
  let ie: ref<AAT_OnLookImpulseEvt>;
  let emotionEvt: ref<AAT_EmotionEvt>;

  if RFC.Cfg().vanillaMode {
    this.aatOnLookActive = false;
    return true;
  };

  if !s.enabled {
    this.aatOnLookActive = false;
    return true;
  };

  if !this.aatOnLookActive {
    AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
    return true;
  };

  ppos = this.GetWorldPosition();

  pspd = 0.0;
  moveLen = 0.0;

  if this.aatOnLookLastPosValid {
    moveVec = ppos - this.aatOnLookLastPos;
    moveLen = Vector4.Length(moveVec);
    pspd = moveLen / AAT_OnLookDelay(s.intervalSec);
  } else {
    this.aatOnLookLastPosValid = true;
    this.aatOnLookLastPos = ppos;
    AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
    return true;
  };

  this.aatOnLookLastPos = ppos;

  if this.aatOnLookCd {
    AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
    return true;
  };

  npc = AAT_GetLookAtNPC(this);
  if !IsDefined(npc) || !ScriptedPuppet.CanRagdoll(npc) {
    AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
    return true;
  };

  // Never start Trip On Look against an NPC currently owned by a stealth kill
  // or finisher. Keep the player monitor alive for later targets.
  if RFC_IsStealthOrFinisher(npc) {
    AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
    return true;
  };

  if s.aggressiveOnly && !AAT_IsAggressiveNPC(npc) {
    AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
    return true;
  };

  npos = npc.GetWorldPosition();
  toNPC = npos - ppos;
  dist = Vector4.Length(toNPC);

  if s.contactDistM > 0.00 && dist > s.contactDistM {
    AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
    return true;
  };

  dirToNPC = Vector4.Normalize(toNPC);

  if s.requireCenterScreen {
    playerForward = Vector4.Normalize(this.GetWorldForward());
    rightDir = Vector4.Normalize(this.GetWorldRight());
    aimDot = Vector4.Dot(playerForward, dirToNPC);
    absSideAim = AbsF(Vector4.Dot(rightDir, dirToNPC));

    if aimDot < s.centerAimTightness {
      AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
      return true;
    };

    if absSideAim > s.centerLaneWidth {
      AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
      return true;
    };
  };

  if moveLen <= 0.001 {
    AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
    return true;
  };

  moveDir = Vector4.Normalize(moveVec);
  forwardDot = Vector4.Dot(moveDir, dirToNPC);

  if forwardDot <= 0.0 {
    AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
    return true;
  };

  effectiveSpeed = pspd * forwardDot;
  if s.minSpeedMps > 0.00 && effectiveSpeed < s.minSpeedMps {
    AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
    return true;
  };

  rightDir = Vector4.Normalize(this.GetWorldRight());
  sideDot = Vector4.Dot(dirToNPC, rightDir);
  sidePush = sideDot * s.sideXY;
  kickZ = s.liftZ - s.downZ;

  pos = npos;
  pos.Z += s.zOffset;

  re = new AAT_OnLookRagdollEvt();
  re.target = npc;
  AAT_OnLookSched(this, re, s.impactPauseSec);

  ie = new AAT_OnLookImpulseEvt();
  ie.target = npc;
  ie.pos = pos;
  ie.imp = new Vector4(
    moveDir.X * s.pushXY + rightDir.X * sidePush,
    moveDir.Y * s.pushXY + rightDir.Y * sidePush,
    kickZ,
    1.0
  );
  ie.radius = s.radius;
  AAT_OnLookSched(this, ie, s.impactPauseSec + s.impulseDelaySec);

  emotionEvt = new AAT_EmotionEvt();
  emotionEvt.target = this;
  AAT_OnLookSched(npc, emotionEvt, s.emotionDelayAfterRagdoll);

  if s.cooldownSec > 0.00 {
    this.aatOnLookCd = true;
    AAT_OnLookSched(this, new AAT_OnLookResetCdEvt(), s.cooldownSec);
  };

  AAT_OnLookSched(this, new AAT_OnLookTickEvt(), AAT_OnLookDelay(s.intervalSec));
  return true;
}

private func AAT_OnLookStart(p: wref<PlayerPuppet>) -> Void {
  if !IsDefined(p) || RFC.Cfg().vanillaMode {
    return;
  };
  p.aatOnLookActive = true;
  AAT_OnLookSched(p, new AAT_OnLookTickEvt(), 0.10);
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let res: Bool = wrappedMethod();
  if !RFC.Cfg().vanillaMode { AAT_OnLookStart(this); }
  return res;
}

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
  let res: Bool = wrappedMethod(ri);
  if !RFC.Cfg().vanillaMode { AAT_OnLookStart(this); }
  return res;
}

@wrapMethod(ReactionManagerComponent)
protected cb func OnProximityLookatEvent(evt: ref<ProximityLookatEvent>) -> Bool {
  if RFC.Cfg().vanillaMode {
    return wrappedMethod(evt);
  }
  return false;
}
