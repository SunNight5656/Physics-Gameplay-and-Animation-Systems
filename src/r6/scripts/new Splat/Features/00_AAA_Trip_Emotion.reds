module RealisticPush

// AAA Trip - 00 Emotion
// Menu section comes first by file/declaration order.
// This file contains the reaction/emotion layer. Normal mode auto-selects a reaction; Square/Reload cycling includes all tests plus Random.

public class AAT_EmotionSettings {
public let showEmotionSection: Bool = true;
  public let enabled: Bool = false;
  public let aggressionFirst: Bool = true;
  public let autoReactionMode: Int32 = 1;
  public let testingMode: Bool = false;
  public let showAdvanced: Bool = false;
  public let workspotBackOffFallbackEnabled: Bool = true;
  public let workspotBackOffFallbackDelaySec: Float = 3.00;
  public let showPushReactionPopup: Bool = true;

  // Advanced On Look reaction pool.
  public let allowAggressionCombat: Bool = true;
  public let allowWalkAway: Bool = true;
  public let allowFlee: Bool = true;
  public let allowCompleteSurrender: Bool = true;

  // Hidden defaults. The code still reads these, but they no longer clutter the menu.
  public let fallbackMode: Int32 = 1;
  public let useButtonCycle: Bool = true;
  public let cycleButtonMode: Int32 = 0;
  public let randomIncludesSurrender: Bool = true;
  public let showCyclePopup: Bool = true;
  public let cycleCooldown: Float = 0.25;
  public let popupDuration: Float = 1.50;
  public let cancelVanillaNoise: Bool = true;
  public let fearAnimWrapper: Int32 = 0;
  public let fearLocomotionWrapper: Int32 = 0;
}

private func AAT_EmotionCfg() -> ref<AAT_EmotionSettings> {
  let settings: ref<AAT_EmotionSettings> = new AAT_EmotionSettings();
  let menu: ref<RFCModSettings> = SPLATSettingsRuntime.Menu();
  let mode: Int32 = EnumInt(menu.splatPresetMode);
  if mode == EnumInt(RFCSplatPresetMode.Realism) {
    settings.showEmotionSection = menu.customTripEmotion_showEmotionSection;
    settings.enabled = menu.customTripEmotion_enabled;
    settings.aggressionFirst = menu.customTripEmotion_aggressionFirst;
    settings.autoReactionMode = menu.customTripEmotion_autoReactionMode;
    settings.testingMode = menu.customTripEmotion_testingMode;
    settings.showAdvanced = menu.customTripEmotion_showAdvanced;
    settings.workspotBackOffFallbackEnabled = menu.customTripEmotion_workspotBackOffFallbackEnabled;
    settings.workspotBackOffFallbackDelaySec = menu.customTripEmotion_workspotBackOffFallbackDelaySec;
    settings.showPushReactionPopup = menu.customTripEmotion_showPushReactionPopup;
    settings.allowAggressionCombat = menu.customTripEmotion_allowAggressionCombat;
    settings.allowWalkAway = menu.customTripEmotion_allowWalkAway;
    settings.allowFlee = menu.customTripEmotion_allowFlee;
    settings.allowCompleteSurrender = menu.customTripEmotion_allowCompleteSurrender;
  }
  else if mode == EnumInt(RFCSplatPresetMode.RealismPlus) {
    settings.showEmotionSection = menu.realismPlusTripEmotion_showEmotionSection;
    settings.enabled = menu.realismPlusTripEmotion_enabled;
    settings.aggressionFirst = menu.realismPlusTripEmotion_aggressionFirst;
    settings.autoReactionMode = menu.realismPlusTripEmotion_autoReactionMode;
    settings.testingMode = menu.realismPlusTripEmotion_testingMode;
    settings.showAdvanced = menu.realismPlusTripEmotion_showAdvanced;
    settings.workspotBackOffFallbackEnabled = menu.realismPlusTripEmotion_workspotBackOffFallbackEnabled;
    settings.workspotBackOffFallbackDelaySec = menu.realismPlusTripEmotion_workspotBackOffFallbackDelaySec;
    settings.showPushReactionPopup = menu.realismPlusTripEmotion_showPushReactionPopup;
    settings.allowAggressionCombat = menu.realismPlusTripEmotion_allowAggressionCombat;
    settings.allowWalkAway = menu.realismPlusTripEmotion_allowWalkAway;
    settings.allowFlee = menu.realismPlusTripEmotion_allowFlee;
    settings.allowCompleteSurrender = menu.realismPlusTripEmotion_allowCompleteSurrender;
  }
  else if mode == EnumInt(RFCSplatPresetMode.DirtyHarry) {
    settings.showEmotionSection = menu.dirtyTripEmotion_showEmotionSection;
    settings.enabled = menu.dirtyTripEmotion_enabled;
    settings.aggressionFirst = menu.dirtyTripEmotion_aggressionFirst;
    settings.autoReactionMode = menu.dirtyTripEmotion_autoReactionMode;
    settings.testingMode = menu.dirtyTripEmotion_testingMode;
    settings.showAdvanced = menu.dirtyTripEmotion_showAdvanced;
    settings.workspotBackOffFallbackEnabled = menu.dirtyTripEmotion_workspotBackOffFallbackEnabled;
    settings.workspotBackOffFallbackDelaySec = menu.dirtyTripEmotion_workspotBackOffFallbackDelaySec;
    settings.showPushReactionPopup = menu.dirtyTripEmotion_showPushReactionPopup;
    settings.allowAggressionCombat = menu.dirtyTripEmotion_allowAggressionCombat;
    settings.allowWalkAway = menu.dirtyTripEmotion_allowWalkAway;
    settings.allowFlee = menu.dirtyTripEmotion_allowFlee;
    settings.allowCompleteSurrender = menu.dirtyTripEmotion_allowCompleteSurrender;
  }
  else if mode == EnumInt(RFCSplatPresetMode.Arnold) {
    settings.showEmotionSection = menu.arnoldTripEmotion_showEmotionSection;
    settings.enabled = menu.arnoldTripEmotion_enabled;
    settings.aggressionFirst = menu.arnoldTripEmotion_aggressionFirst;
    settings.autoReactionMode = menu.arnoldTripEmotion_autoReactionMode;
    settings.testingMode = menu.arnoldTripEmotion_testingMode;
    settings.showAdvanced = menu.arnoldTripEmotion_showAdvanced;
    settings.workspotBackOffFallbackEnabled = menu.arnoldTripEmotion_workspotBackOffFallbackEnabled;
    settings.workspotBackOffFallbackDelaySec = menu.arnoldTripEmotion_workspotBackOffFallbackDelaySec;
    settings.showPushReactionPopup = menu.arnoldTripEmotion_showPushReactionPopup;
    settings.allowAggressionCombat = menu.arnoldTripEmotion_allowAggressionCombat;
    settings.allowWalkAway = menu.arnoldTripEmotion_allowWalkAway;
    settings.allowFlee = menu.arnoldTripEmotion_allowFlee;
    settings.allowCompleteSurrender = menu.arnoldTripEmotion_allowCompleteSurrender;
  }
  return settings;
}



@addField(PlayerPuppet) private let aat_reactionMode: Int32;
@addField(PlayerPuppet) private let aat_nextReactionCycleTime: Float;

public class AAT_EmotionEvt extends Event {
  public let target: wref<GameObject>;
}

public class AAT_WorkspotBackOffFallbackEvt extends Event {
  public let target: wref<GameObject>;
  public let token: Int32;
  public let closeDistance: Float;
}

@addField(NPCPuppet) private let aat_wsBackOffFallbackToken: Int32;

@addMethod(PlayerPuppet)
private final func AAT_Now() -> Float {
  return EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
}

@addMethod(PlayerPuppet)
private final func AAT_InitReactionMode(settings: ref<AAT_EmotionSettings>) -> Void {
  if !IsDefined(settings) { return; }
  if this.aat_reactionMode < 1 || this.aat_reactionMode > 25 {
    this.aat_reactionMode = settings.fallbackMode;
  };
  if this.aat_reactionMode < 1 || this.aat_reactionMode > 25 {
    this.aat_reactionMode = 1;
  };
}

@addMethod(PlayerPuppet)
public final func AAT_GetEnabledOnLookReactionMode(
  settings: ref<AAT_EmotionSettings>,
  includeAggressionCombat: Bool
) -> Int32 {
  let commonCount: Int32 = 0;
  let pick: Int32;

  if !IsDefined(settings) {
    return 0;
  };

  if includeAggressionCombat && settings.allowAggressionCombat {
    commonCount += 1;
  };

  if settings.allowWalkAway {
    commonCount += 1;
  };

  if settings.allowFlee {
    commonCount += 1;
  };

  // Complete Surrender stays rare while another reaction is available.
  // If it is the only enabled reaction, use it every time.
  if settings.allowCompleteSurrender {
    if commonCount <= 0 {
      return 27;
    };

    if RandF() >= 0.99 {
      return 27;
    };
  };

  if commonCount <= 0 {
    return 0;
  };

  pick = RandRange(1, commonCount + 1);

  if includeAggressionCombat && settings.allowAggressionCombat {
    if pick == 1 {
      return 29;
    };
    pick -= 1;
  };

  if settings.allowWalkAway {
    if pick == 1 {
      return 5;
    };
    pick -= 1;
  };

  if settings.allowFlee {
    return 6;
  };

  return 0;
}

@addMethod(PlayerPuppet)
public final func AAT_GetRandomReactionMode(
  settings: ref<AAT_EmotionSettings>
) -> Int32 {
  // Draw only from reactions enabled in Advanced On Look.
  return this.AAT_GetEnabledOnLookReactionMode(
    settings,
    true
  );
}

@addMethod(PlayerPuppet)
public final func AAT_GetReactionMode(settings: ref<AAT_EmotionSettings>) -> Int32 {
  if !IsDefined(settings) {
    return 2;
  };

  if settings.testingMode && settings.useButtonCycle {
    this.AAT_InitReactionMode(settings);
    return this.aat_reactionMode;
  };

  if settings.autoReactionMode == 2 {
    return 2; // BackOff only
  };

  if settings.autoReactionMode == 3 {
    if settings.allowWalkAway {
      return 5;
    };
    return this.AAT_GetRandomReactionMode(settings);
  };

  if settings.autoReactionMode == 4 {
    if settings.allowFlee {
      return 6;
    };
    return this.AAT_GetRandomReactionMode(settings);
  };

  if settings.autoReactionMode == 5 {
    if settings.allowCompleteSurrender {
      return 27;
    };
    return this.AAT_GetRandomReactionMode(settings);
  };

  if settings.autoReactionMode == 6 {
    return settings.fallbackMode;
  };

  // Auto Reaction 1 = Random.
  return this.AAT_GetRandomReactionMode(settings);
}

@addMethod(PlayerPuppet)
private final func AAT_CycleReactionMode(settings: ref<AAT_EmotionSettings>) -> Int32 {
  this.AAT_InitReactionMode(settings);
  this.aat_reactionMode += 1;
  if this.aat_reactionMode > 25 {
    this.aat_reactionMode = 1;
  };
  return this.aat_reactionMode;
}

@addMethod(PlayerPuppet)
private final func AAT_IsCycleAction(actionName: CName, settings: ref<AAT_EmotionSettings>) -> Bool {
  if !IsDefined(settings) { return false; }
  if settings.cycleButtonMode == 0 {
    return Equals(actionName, n"Reload");
  };
  if settings.cycleButtonMode == 1 {
    return Equals(actionName, n"Choice1");
  };
  return Equals(actionName, n"Reload") || Equals(actionName, n"Choice1");
}

@addMethod(PlayerPuppet)
private final func AAT_ReactionModeName(mode: Int32) -> String {
  switch mode {
    case 1:
      return "WS Test: BackOff false + timed WalkAway/Flee/Test16/Test21 fallback";
    case 2:
      return "WS Test: BackOff / init true";
    case 3:
      return "WS Test: Aggression only";
    case 4:
      return "WS Test: BackOff false -> Aggression";
    case 5:
      return "WS Test: BackOff true -> Aggression";
    case 6:
      return "WS Test: Aggression -> BackOff true";

    case 7:
      return "WS Test: Surrender only / init false";
    case 8:
      return "WS Test: Surrender only / init true";

    case 9:
      return "WS Test: Fear 1 -> Surrender false";
    case 10:
      return "WS Test: Fear 1 -> Surrender true";
    case 11:
      return "WS Test: Fear 2 -> Surrender false";
    case 12:
      return "WS Test: Fear 2 -> Surrender true";
    case 13:
      return "WS Test: Fear 3 -> Surrender false";
    case 14:
      return "WS Test: Fear 3 -> Surrender true";

    case 15:
      return "WS Test: Surrender false -> Fear 1";
    case 16:
      return "WS Test: Surrender true -> Fear 1";
    case 17:
      return "WS Test: Surrender false -> Fear 2";
    case 18:
      return "WS Test: Surrender true -> Fear 2";
    case 19:
      return "WS Test: Surrender false -> Fear 3";
    case 20:
      return "WS Test: Surrender true -> Fear 3";

    case 21:
      return "WS Test: Fear 3 + SpreadFear -> Surrender false";
    case 22:
      return "WS Test: Fear 3 + SpreadFear -> Surrender true";

    case 23:
      return "WS Test: WalkAway";
    case 24:
      return "WS Test: Flee";
    case 25:
      return "Random - show exact result when push triggers";

    default:
      return "WS Test: BackOff false + timed WalkAway/Flee/Test16/Test21 fallback";
  };
}

@addMethod(PlayerPuppet)
private final func AAT_ShowReactionPopup(settings: ref<AAT_EmotionSettings>, mode: Int32) -> Void {
  let msg: SimpleScreenMessage;
  if !IsDefined(settings) || !settings.showCyclePopup { return; }
  msg.isShown = true;
  msg.duration = settings.popupDuration;
  msg.isInstant = true;
  msg.type = SimpleMessageType.Neutral;
  msg.message = "AAA Trip Reaction Test " + ToString(mode) + ": " + this.AAT_ReactionModeName(mode);
  GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(msg), true);
}

@addMethod(PlayerPuppet)
public final func AAT_ShowPushReactionPopup(
  settings: ref<AAT_EmotionSettings>,
  reactionName: String
) -> Void {
  let msg: SimpleScreenMessage;

  if !IsDefined(settings) || !settings.showPushReactionPopup {
    return;
  };

  msg.isShown = true;
  msg.duration = settings.popupDuration;
  msg.isInstant = true;
  msg.type = SimpleMessageType.Neutral;
  msg.message = "AAA On Look Push: " + reactionName;

  GameInstance.GetBlackboardSystem(this.GetGame())
    .Get(GetAllBlackboardDefs().UI_Notifications)
    .SetVariant(
      GetAllBlackboardDefs().UI_Notifications.WarningMessage,
      ToVariant(msg),
      true
    );
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let res: Bool = wrappedMethod();
  if RFC.Cfg().vanillaMode { return res; }
  this.RegisterInputListener(this, n"Reload");
  this.RegisterInputListener(this, n"Choice1");
  return res;
}

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
  let res: Bool = wrappedMethod(ri);
  if RFC.Cfg().vanillaMode { return res; }
  this.RegisterInputListener(this, n"Reload");
  this.RegisterInputListener(this, n"Choice1");
  return res;
}

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
  let result: Bool = wrappedMethod(action, consumer);
  let settings: ref<AAT_EmotionSettings> = AAT_EmotionCfg();
  let actionName: CName;
  let actionType: gameinputActionType;
  let now: Float;
  let mode: Int32;

  if RFC.Cfg().vanillaMode {
    return result;
  };

  if !IsDefined(settings) || !settings.enabled || !settings.testingMode || !settings.useButtonCycle {
    return result;
  };

  actionName = ListenerAction.GetName(action);
  actionType = ListenerAction.GetType(action);

  if !this.AAT_IsCycleAction(actionName, settings) {
    return result;
  };
  if NotEquals(actionType, gameinputActionType.BUTTON_PRESSED) {
    return result;
  };

  now = this.AAT_Now();
  if now < this.aat_nextReactionCycleTime {
    return result;
  };

  this.aat_nextReactionCycleTime = now + settings.cycleCooldown;
  mode = this.AAT_CycleReactionMode(settings);
  this.AAT_ShowReactionPopup(settings, mode);
  return result;
}

@addMethod(ReactionManagerComponent)
private final func AAT_Emotion_CancelNoise(owner: ref<GameObject>, settings: ref<AAT_EmotionSettings>) -> Void {
  let delaySystem: ref<DelaySystem>;
  if !IsDefined(owner) || !IsDefined(settings) || !settings.cancelVanillaNoise {
    return;
  };
  delaySystem = GameInstance.GetDelaySystem(owner.GetGame());
  if IsDefined(delaySystem) {
    delaySystem.CancelDelay(this.m_proximityLookatEventId);
    delaySystem.CancelDelay(this.m_disturbComfortZoneEventId);
    delaySystem.CancelDelay(this.m_checkComfortZoneEventId);
    delaySystem.CancelDelay(this.m_disturbComfortZoneAggressiveEventId);
  };
  this.m_playerProximity = false;
  this.m_lookatRepeat = false;
  this.m_disturbingComfortZoneInProgress = false;
  this.m_backOffInProgress = false;
  this.m_inPendingBehavior = false;
  this.DeactiveLookAt();
  this.ResetFacial(0.00);
}

@addMethod(ReactionManagerComponent)
private final func AAT_Emotion_PhaseToStage(phase: Int32) -> gameFearStage {
  if phase <= 0 { return gameFearStage.Relaxed; };
  if phase == 1 { return gameFearStage.Stressed; };
  if phase == 2 { return gameFearStage.Alarmed; };
  return gameFearStage.Panic;
}

@addMethod(ReactionManagerComponent)
private final func AAT_Emotion_WrapperName(animWrapper: Int32, phase: Int32) -> CName {
  if animWrapper == 1 { return n"disturbed"; };
  if animWrapper == 2 { return n"fear"; };
  if animWrapper == 3 { return n"panic"; };
  if animWrapper == 4 { return n"default"; };
  return this.GetFearAnimWrapper(phase);
}

@addMethod(ReactionManagerComponent)
private final func AAT_Emotion_LocoWrapperName(locoWrapper: Int32, phase: Int32) -> CName {
  if locoWrapper == 1 { return n"FearLocomotion1"; };
  if locoWrapper == 2 { return n"FearLocomotion2"; };
  if locoWrapper == 3 { return n"FearLocomotion3"; };
  if locoWrapper == 4 { return n"FearLocomotion4"; };
  return this.GetRandomFearLocomotionAnimWrapper(phase);
}

@addMethod(ReactionManagerComponent)
private final func AAT_Emotion_ApplyFearWrappers(owner: ref<GameObject>, settings: ref<AAT_EmotionSettings>, phase: Int32) -> Void {
  let animWrapper: CName;
  let locoWrapper: CName;
  if !IsDefined(owner) || !IsDefined(settings) { return; }
  animWrapper = this.AAT_Emotion_WrapperName(settings.fearAnimWrapper, phase);
  if NotEquals(animWrapper, n"default") {
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, animWrapper, 1.00);
  };
  if settings.fearLocomotionWrapper > 0 {
    locoWrapper = this.AAT_Emotion_LocoWrapperName(settings.fearLocomotionWrapper, phase);
    AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(owner, locoWrapper, 1.00);
    this.m_fearLocomotionWrapper = true;
  };
}

@addMethod(ReactionManagerComponent)
private final func AAT_Emotion_SetFearPhase(owner: ref<GameObject>, target: ref<GameObject>, settings: ref<AAT_EmotionSettings>, phase: Int32) -> Void {
  let crowd: ref<CrowdMemberBaseComponent>;
  let puppet: ref<ScriptedPuppet>;
  if !IsDefined(owner) || !IsDefined(target) || !IsDefined(settings) { return; }
  puppet = owner as ScriptedPuppet;
  NPCPuppet.ChangeHighLevelState(owner, gamedataNPCHighLevelState.Fear);
  this.m_previousFearPhase = phase;
  this.m_desiredFearPhase = phase;
  this.m_inPendingBehavior = false;
  this.m_crowdFearStage = this.AAT_Emotion_PhaseToStage(phase);
  this.TriggerFearFacial(phase);
  if phase > 0 {
    this.AAT_Emotion_ApplyFearWrappers(owner, settings, phase);
  };
  if IsDefined(puppet) && IsDefined(puppet.GetCrowdMemberComponent()) {
    crowd = puppet.GetCrowdMemberComponent();
    crowd.SetThreatLastKnownPosition(target.GetWorldPosition());
    crowd.AllowWorkspotsUsage(false);
    crowd.TryStopTrafficMovement();
    crowd.ChangeFearStage(this.m_crowdFearStage, false);
    if phase >= 3 {
      crowd.ChangeMoveType(n"panic");
    };
  };
}

@addMethod(ReactionManagerComponent)
private final func AAT_Emotion_TriggerOutput(target: ref<GameObject>, output: gamedataOutput, initAnimInWorkspot: Bool) -> Void {
  if !IsDefined(target) { return; }
  this.TriggerReactionBehaviorForCrowd(target, output, initAnimInWorkspot, target.GetWorldPosition());
}

@addMethod(ReactionManagerComponent)
private final func AAT_Emotion_TryAggression(owner: ref<GameObject>, target: ref<GameObject>) -> Bool {
  let aiEvent: ref<AIEvent>;
  let puppet: ref<ScriptedPuppet>;
  let npc: ref<NPCPuppet>;
  let started: Bool = false;

  if !IsDefined(owner) || !IsDefined(target) { return false; }

  puppet = owner as ScriptedPuppet;
  npc = owner as NPCPuppet;
  if !IsDefined(puppet) || !IsDefined(npc) { return false; }

  if npc.IsAggressive() || npc.IsHostile() {
    started = true;
  } else {
    if AIActionHelper.TryChangingAttitudeToHostile(puppet, target) {
      started = true;
    };
  };

  if !started { return false; }

  owner.GetSensesComponent().IgnoreLODChange(true);
  owner.GetSensesComponent().Toggle(true);
  owner.GetTargetTrackerComponent().Toggle(true);
  TargetTrackingExtension.InjectThreat(puppet, target);
  npc.SetWasAggressiveCrowd(true);
  AIActionHelper.TryStartCombatWithTarget(puppet, target);
  aiEvent = new AIEvent();
  aiEvent.name = n"TriggerCombatReaction";
  owner.QueueEvent(aiEvent);
  return true;
}

@addMethod(ReactionManagerComponent)
private final func AAT_Emotion_GetMode(target: ref<GameObject>, settings: ref<AAT_EmotionSettings>) -> Int32 {
  let player: ref<PlayerPuppet>;
  if !IsDefined(settings) { return 1; }
  if settings.useButtonCycle {
    player = target as PlayerPuppet;
    if IsDefined(player) {
      return player.AAT_GetReactionMode(settings);
    };
  };
  return settings.fallbackMode;
}

@addMethod(ReactionManagerComponent)
private final func AAT_Emotion_ScheduleWorkspotBackOffFallback(
  owner: ref<GameObject>,
  target: ref<GameObject>,
  delaySec: Float,
  closeDistance: Float
) -> Void {
  let npc: ref<NPCPuppet>;
  let ds: ref<DelaySystem>;
  let evt: ref<AAT_WorkspotBackOffFallbackEvt>;

  if !IsDefined(owner) || !IsDefined(target) {
    return;
  };

  npc = owner as NPCPuppet;
  if !IsDefined(npc) {
    return;
  };

  ds = GameInstance.GetDelaySystem(owner.GetGame());
  if !IsDefined(ds) {
    return;
  };

  // Token prevents an older On Look activation from firing after a newer one.
  npc.aat_wsBackOffFallbackToken += 1;

  evt = new AAT_WorkspotBackOffFallbackEvt();
  evt.target = target;
  evt.token = npc.aat_wsBackOffFallbackToken;
  evt.closeDistance = MaxF(0.10, closeDistance);

  ds.DelayEvent(
    npc,
    evt,
    MaxF(0.01, delaySec),
    false
  );
}

@addMethod(ReactionManagerComponent)
public final func AAT_Emotion_ApplyWorkspotBackOffFallback(
  target: ref<GameObject>
) -> Void {
  let owner: ref<GameObject> = this.GetOwner();
  let settings: ref<AAT_EmotionSettings> = AAT_EmotionCfg();
  let player: ref<PlayerPuppet> = target as PlayerPuppet;
  let mode: Int32;

  if RFC.Cfg().vanillaMode
    || !IsDefined(owner)
    || !IsDefined(target)
    || !IsDefined(settings)
    || !settings.enabled {
    return;
  };

  this.AAT_Emotion_CancelNoise(owner, settings);

  if !IsDefined(player) {
    return;
  };

  // A delayed workspot fallback uses the enabled noncombat pool:
  // WalkAway, Flee, and rare Complete Surrender.
  // Aggression / Combat is intentionally Random-only because this check
  // runs after the player has already moved outside the close distance.
  mode = player.AAT_GetEnabledOnLookReactionMode(
    settings,
    false
  );

  if mode == 5 {
    player.AAT_ShowPushReactionPopup(
      settings,
      "Fallback: WalkAway"
    );

    this.AAT_Emotion_SetFearPhase(owner, target, settings, 1);
    this.AAT_Emotion_TriggerOutput(
      target,
      gamedataOutput.WalkAway,
      false
    );
    return;
  };

  if mode == 6 {
    player.AAT_ShowPushReactionPopup(
      settings,
      "Fallback: Flee"
    );

    this.AAT_Emotion_SetFearPhase(owner, target, settings, 3);
    this.SetCrowdRunningAwayAnimFeature(gamedataStimType.SpreadFear);
    this.AAT_Emotion_TriggerOutput(
      target,
      gamedataOutput.Flee,
      true
    );
    return;
  };

  if mode == 27 {
    player.AAT_ShowPushReactionPopup(
      settings,
      "Fallback: Complete Surrender"
    );

    this.AAT_Emotion_SetFearPhase(
      owner,
      target,
      settings,
      3
    );
    this.SetCrowdRunningAwayAnimFeature(
      gamedataStimType.SpreadFear
    );
    this.AAT_Emotion_TriggerOutput(
      target,
      gamedataOutput.Surrender,
      false
    );
    return;
  };

  player.AAT_ShowPushReactionPopup(
    settings,
    "Fallback: No Reaction Enabled"
  );
}

@addMethod(ReactionManagerComponent)
private final func AAT_Emotion_AppliedModeName(
  mode: Int32,
  settings: ref<AAT_EmotionSettings>
) -> String {
  switch mode {
    case 1:
      return "BackOff + Fear 1";
    case 2:
      return "BackOff";
    case 3:
      return "Surrender + Fear 2";
    case 4:
      return "Surrender";
    case 5:
      return "WalkAway";
    case 6:
      return "Flee";

    case 7:
      if IsDefined(settings) && settings.workspotBackOffFallbackEnabled {
        return "BackOff - fallback in " + ToString(settings.workspotBackOffFallbackDelaySec) + " sec";
      };
      return "BackOff - fallback disabled";

    case 8:
      return "BackOff / Workspot Init";
    case 9:
      return "Aggression";
    case 10:
      return "BackOff false -> Aggression";
    case 11:
      return "BackOff true -> Aggression";
    case 12:
      return "Aggression -> BackOff true";

    case 13:
      return "Test 7 - Surrender false";
    case 14:
      return "Test 8 - Surrender true";
    case 15:
      return "Test 9 - Fear 1 -> Surrender false";
    case 16:
      return "Test 10 - Fear 1 -> Surrender true";
    case 17:
      return "Test 11 - Fear 2 -> Surrender false";
    case 18:
      return "Test 12 - Fear 2 -> Surrender true";
    case 19:
      return "Test 13 - Fear 3 -> Surrender false";
    case 20:
      return "Test 14 - Fear 3 -> Surrender true";
    case 21:
      return "Test 15 - Surrender false -> Fear 1";
    case 22:
      return "Test 16 - Hands Up Then Run";
    case 23:
      return "Test 17 - Surrender false -> Fear 2";
    case 24:
      return "Test 18 - Surrender true -> Fear 2";
    case 25:
      return "Test 19 - Bad Combo";
    case 26:
      return "Test 20 - Surrender true -> Fear 3";
    case 27:
      return "Test 21 - Complete Surrender";
    case 28:
      return "Test 22 - SpreadFear -> Surrender true";
    case 29:
      return "Aggression / Combat";

    default:
      return "Unknown Reaction " + ToString(mode);
  };
}

@addMethod(ReactionManagerComponent)
private final func AAT_Emotion_ResolveWorkspotMode(mode: Int32, testingMode: Bool) -> Int32 {
  // Testing Mode / Square cycle:
  //
  //  1-6  -> BackOff/aggression test cases 7-12
  //  7-22 -> complete surrender test matrix 13-28
  //  23   -> WalkAway
  //  24   -> Flee
  if testingMode {
    if mode >= 1 && mode <= 6 {
      return mode + 6;
    };

    if mode >= 7 && mode <= 22 {
      return mode + 6;
    };

    if mode == 23 {
      return 5;
    };

    if mode == 24 {
      return 6;
    };

    return 7;
  };

  // Exact normal-workspot reactions selected by Random or Auto Reaction.
  // Mode 29 is Random-only Aggression / Combat.
  // Mode 27 is complete surrender.
  if mode == 29 || mode == 27 {
    return mode;
  };

  // Explicit Auto Reaction choices remain available.
  if mode >= 3 && mode <= 6 {
    return mode;
  };

  // Legacy BackOff requests are still converted to a confirmed workspot
  // breaker. BackOff remains available only through Square testing.
  if RandF() < 0.50 {
    return 5;
  };

  return 6;
}

@addMethod(ReactionManagerComponent)
public final func AAT_Emotion_Apply(target: ref<GameObject>) -> Void {
  let owner: ref<GameObject> = this.GetOwner();
  let settings: ref<AAT_EmotionSettings> = AAT_EmotionCfg();
  let puppet: ref<ScriptedPuppet>;
  let mode: Int32;
  let wasInWorkspot: Bool;
  let selectedSquareRandom: Bool = false;
  let onLookSettings: ref<AAT_OnLookSettings>;
  let player: ref<PlayerPuppet>;

  if RFC.Cfg().vanillaMode || !IsDefined(owner) || !IsDefined(target) || !IsDefined(settings) || !settings.enabled {
    return;
  };

  puppet = owner as ScriptedPuppet;
  if !IsDefined(puppet) {
    return;
  };

  player = target as PlayerPuppet;

  // Capture this before CancelNoise / fear setup changes workspot state.
  wasInWorkspot = RFC_IsWorkspotOrPerch(puppet);

  this.AAT_Emotion_CancelNoise(owner, settings);

  // During workspot Square testing, do not let the global aggression-first
  // shortcut swallow the selected reaction before we can test it.
  //
  // Everywhere else, keep the existing aggression-first behavior unchanged.
  if settings.allowAggressionCombat
    && settings.aggressionFirst
    && settings.autoReactionMode != 1
    && !(wasInWorkspot && settings.testingMode) {
    if this.AAT_Emotion_TryAggression(owner, target) {
      if IsDefined(player) {
        player.AAT_ShowPushReactionPopup(
          settings,
          "Aggression / Combat"
        );
      };
      return;
    };
  };

  mode = this.AAT_Emotion_GetMode(target, settings);

  // Square mode 25 restores Random testing. It uses the exact regular
  // Random pool, but still reports the concrete reaction selected on push.
  if settings.testingMode && mode == 25 && IsDefined(player) {
    mode = player.AAT_GetRandomReactionMode(settings);
    selectedSquareRandom = true;
  };

  if wasInWorkspot {
    mode = this.AAT_Emotion_ResolveWorkspotMode(
      mode,
      settings.testingMode && !selectedSquareRandom
    );
  } else {
    // The expanded Square matrix is specifically for workspot testing.
    // Outside workspots, keep the existing normal reaction mapping.
    if settings.testingMode {
      if mode == 23 {
        mode = 5;
      } else {
        if mode == 24 {
          mode = 6;
        };
      };
    };
  };

  // Random-only Aggression / Combat.
  // This is separate from Square test 3.
  if mode == 29 {
    if this.AAT_Emotion_TryAggression(owner, target) {
      if IsDefined(player) {
        player.AAT_ShowPushReactionPopup(
          settings,
          "Aggression / Combat"
        );
      };
      return;
    };

    // Some civilians cannot enter combat. Choose another enabled
    // noncombat reaction instead of forcing a disabled one.
    if IsDefined(player) {
      mode = player.AAT_GetEnabledOnLookReactionMode(
        settings,
        false
      );
    } else {
      mode = 0;
    };
  };

  if mode == 0 {
    if IsDefined(player) {
      player.AAT_ShowPushReactionPopup(
        settings,
        "No On Look Reaction Enabled"
      );
    };
    return;
  };

  // Report the final concrete reaction after Random/test/workspot resolution.
  if IsDefined(player) {
    player.AAT_ShowPushReactionPopup(
      settings,
      this.AAT_Emotion_AppliedModeName(mode, settings)
    );
  };

  switch mode {
    case 1:
      // Existing non-workspot behavior remains unchanged.
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 1);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.BackOff, false);
      break;

    case 2:
      // Existing non-workspot behavior remains unchanged.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.BackOff, false);
      break;

    case 3:
      // Confirmed workspot breaker: Surrender + fear.
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 2);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, true);
      break;

    case 4:
      // Confirmed workspot breaker: Surrender only.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, true);
      break;

    case 5:
      // Confirmed workspot breaker: WalkAway.
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 1);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.WalkAway, false);
      break;

    case 6:
      // Confirmed workspot breaker: Flee.
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 3);
      this.SetCrowdRunningAwayAnimFeature(gamedataStimType.SpreadFear);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Flee, true);
      break;

    case 7:
      // Workspot Square mode 1:
      // BackOff with workspot initialization disabled.
      //
      // This is the close-result test:
      // - if the player stays close, BackOff can transition into the shove /
      //   aggression behavior naturally;
      // - if the player is outside the On Look contact distance after the timer,
      //   use WalkAway or Flee, with a rare test 21 complete surrender, so
      //   the NPC does not return to the original workspot.
      onLookSettings = AAT_OnLookCfg();

      this.AAT_Emotion_TriggerOutput(
        target,
        gamedataOutput.BackOff,
        false
      );

      if settings.workspotBackOffFallbackEnabled {
        if IsDefined(onLookSettings) {
          this.AAT_Emotion_ScheduleWorkspotBackOffFallback(
            owner,
            target,
            settings.workspotBackOffFallbackDelaySec,
            onLookSettings.contactDistM
          );
        } else {
          this.AAT_Emotion_ScheduleWorkspotBackOffFallback(
            owner,
            target,
            settings.workspotBackOffFallbackDelaySec,
            0.85
          );
        };
      };
      break;

    case 8:
      // Workspot Square mode 2:
      // Plain BackOff with workspot animation initialization enabled.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.BackOff, true);
      break;

    case 9:
      // Workspot Square mode 3:
      // Aggression only. No BackOff output and no fallback.
      this.AAT_Emotion_TryAggression(owner, target);
      break;

    case 10:
      // Workspot Square mode 4:
      // BackOff first with workspot initialization disabled, then aggression.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.BackOff, false);
      this.AAT_Emotion_TryAggression(owner, target);
      break;

    case 11:
      // Workspot Square mode 5:
      // BackOff first with workspot initialization enabled, then aggression.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.BackOff, true);
      this.AAT_Emotion_TryAggression(owner, target);
      break;

    case 12:
      // Workspot Square mode 6:
      // Aggression first, then BackOff with workspot initialization enabled.
      this.AAT_Emotion_TryAggression(owner, target);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.BackOff, true);
      break;


    case 13:
      // Square 7: surrender only, no workspot init.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, false);
      break;

    case 14:
      // Square 8: surrender only, workspot init enabled.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, true);
      break;

    case 15:
      // Square 9: fear phase 1 first, then surrender/init false.
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 1);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, false);
      break;

    case 16:
      // Square 10: fear phase 1 first, then surrender/init true.
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 1);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, true);
      break;

    case 17:
      // Square 11: fear phase 2 first, then surrender/init false.
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 2);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, false);
      break;

    case 18:
      // Square 12: fear phase 2 first, then surrender/init true.
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 2);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, true);
      break;

    case 19:
      // Square 13: panic phase first, then surrender/init false.
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 3);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, false);
      break;

    case 20:
      // Square 14: panic phase first, then surrender/init true.
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 3);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, true);
      break;

    case 21:
      // Square 15: surrender/init false first, then fear phase 1.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, false);
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 1);
      break;

    case 22:
      // Square 16: surrender/init true first, then fear phase 1.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, true);
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 1);
      break;

    case 23:
      // Square 17: surrender/init false first, then fear phase 2.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, false);
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 2);
      break;

    case 24:
      // Square 18: surrender/init true first, then fear phase 2.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, true);
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 2);
      break;

    case 25:
      // Square 19: surrender/init false first, then panic phase.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, false);
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 3);
      break;

    case 26:
      // Square 20: surrender/init true first, then panic phase.
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, true);
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 3);
      break;

    case 27:
      // Square 21: panic + SpreadFear first, then surrender/init false.
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 3);
      this.SetCrowdRunningAwayAnimFeature(gamedataStimType.SpreadFear);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, false);
      break;

    case 28:
      // Square 22: panic + SpreadFear first, then surrender/init true.
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 3);
      this.SetCrowdRunningAwayAnimFeature(gamedataStimType.SpreadFear);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.Surrender, true);
      break;

    default:
      this.AAT_Emotion_SetFearPhase(owner, target, settings, 1);
      this.AAT_Emotion_TriggerOutput(target, gamedataOutput.BackOff, false);
  };
}

@addMethod(NPCPuppet)
protected cb func OnAAT_WorkspotBackOffFallbackEvt(
  e: ref<AAT_WorkspotBackOffFallbackEvt>
) -> Bool {
  let rc: ref<ReactionManagerComponent>;
  let settings: ref<AAT_EmotionSettings> = AAT_EmotionCfg();
  let dist: Float;

  if RFC.Cfg().vanillaMode
    || !IsDefined(e)
    || !IsDefined(e.target)
    || !IsDefined(settings)
    || !settings.enabled
    || !settings.workspotBackOffFallbackEnabled
    || this.IsDead() {
    return true;
  };

  // Ignore stale fallback events from older On Look activations.
  if e.token != this.aat_wsBackOffFallbackToken {
    return true;
  };

  dist = Vector4.Length(
    this.GetWorldPosition() - e.target.GetWorldPosition()
  );

  // Player remained close: preserve BackOff's shove/aggression behavior.
  if dist <= e.closeDistance {
    return true;
  };

  // If BackOff already succeeded in starting the fight, do not replace it
  // just because the player moved away before the three-second check.
  if this.IsPuppetInCombat() || this.IsPuppetTargetingPlayer() {
    return true;
  };

  // Player stayed or moved outside the contact range for 3 seconds:
  // force one of the confirmed workspot-breaking fallback reactions.
  rc = this.GetStimReactionComponent();
  if IsDefined(rc) {
    rc.AAT_Emotion_ApplyWorkspotBackOffFallback(e.target);
  };

  return true;
}

@addMethod(NPCPuppet)
protected cb func OnAAT_EmotionEvt(e: ref<AAT_EmotionEvt>) -> Bool {
  let rc: ref<ReactionManagerComponent>;
  if RFC.Cfg().vanillaMode || !IsDefined(e) || !IsDefined(e.target) {
    return true;
  };
  rc = this.GetStimReactionComponent();
  if IsDefined(rc) {
    rc.AAT_Emotion_Apply(e.target);
  };
  return true;
}
