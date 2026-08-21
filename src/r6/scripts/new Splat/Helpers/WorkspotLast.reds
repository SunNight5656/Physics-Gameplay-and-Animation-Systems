

module RealisticPush

// ─────────────────────────────────────────────────────────────────────────────
// Per-kind Workspot support
// ─────────────────────────────────────────────────────────────────────────────

public enum RFC_WSKind {
  None = 0,
  Sit  = 1,
  Ledge = 2,
  Lean = 3,
  StandWS = 4,
  Car = 5,
  Moto = 6
}

@addField(NPCPuppet) private let rfc_wsKindLastSeen: Int32; // 0 = None
@addField(NPCPuppet) private let rfc_wsLastSeen: Float;
@addField(NPCPuppet) private let rfc_cowLastSeen: Float;
@addField(NPCPuppet) private let rfc_vehLastSeen: Float;

// v5: these are not a global "skip the whole hit pipeline" latch.
// They only tell SPLAT's extra ragdoll/impulse layers to stand down while the
// native vehicle seat/mount pipeline owns the visible puppet.
@addField(NPCPuppet) private let rfc_vehicleSeatShieldUntil: Float;
@addField(NPCPuppet) private let rfc_vehicleExitShieldUntil: Float;

private func RFC_WSClampF(x: Float, lo: Float, hi: Float) -> Float {
  if x < lo { return lo; }
  if x > hi { return hi; }
  return x;
}

// In any workspot?
private func RFC_InAnyWorkspot(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(p.GetGame());
  return IsDefined(ws) && ws.IsActorInWorkspot(p);
}

// Workspot helpers
private func RFC_IsInWorkspotSys(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(p.GetGame());
  if !IsDefined(ws) { return false; }
  return ws.IsActorInWorkspot(p);
}

// Workspot system access (cast) + force-exit helper.
// This is what makes the chair/stool toggle actually DO something.
private func RFC_GetWS(p: wref<ScriptedPuppet>) -> ref<WorkspotGameSystem> {
  if !IsDefined(p) { return null; }
  return GameInstance.GetWorkspotSystem(p.GetGame()) as WorkspotGameSystem;
}

// Try to force the NPC out of a chair/lean/ledge workspot right now.
// Returns true if we were in a workspot and we issued the stop.
public func RFC_TryStopWorkspot(p: wref<ScriptedPuppet>) -> Bool {
  if RFC.Cfg().vanillaMode { return false; }
  let ws: ref<WorkspotGameSystem> = RFC_GetWS(p);
  if !IsDefined(ws) { return false; }
  if !ws.IsActorInWorkspot(p) { return false; }
  ws.StopNpcInWorkspot(p);
  return true;
}

// PopFix should be allowed even during vehicle/workspot transitions.
// Use this instead of RFC_AllowRFC() in PopFix hooks.
public func RFC_AllowPopFix(p: wref<ScriptedPuppet>) -> Bool {
  if RFC.Cfg().vanillaMode { return false; }
  return IsDefined(p);
}

private func RFC_IsWorkspotOrPerch(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }

  let cmp: ref<ReactionManagerComponent> = p.GetStimReactionComponent();
  let hit_cmp: Bool = IsDefined(cmp) && cmp.GetWorkSpotReactionFlag();

  let hit_sys: Bool = RFC_IsInWorkspotSys(p);

  let seNames: array<CName>;
  ArrayPush(seNames, n"WorkspotStatus.SyncAnimation");
  ArrayPush(seNames, n"WorkspotStatus.InWorkspot");
  ArrayPush(seNames, n"GameplayRestriction.Workspot");
  ArrayPush(seNames, n"WorkspotStatus.Death");

  let hit_se: Bool = false;
  let i: Int32 = 0;
  while i < ArraySize(seNames) {
    if RFC_ObjectHasSE(p, seNames[i]) { hit_se = true; break; }
    i += 1;
  }

  let tags: array<CName>;
  ArrayPush(tags, n"sit");   ArrayPush(tags, n"stool");
  ArrayPush(tags, n"chair"); ArrayPush(tags, n"bench");
  ArrayPush(tags, n"perch"); ArrayPush(tags, n"ledge");
  ArrayPush(tags, n"lean");  ArrayPush(tags, n"bar_lean");
  let hit_tags: Bool = p.HasRuntimeAnimsetTags(tags);

  if hit_cmp || hit_sys || hit_se || hit_tags {
    let np: wref<NPCPuppet> = p as NPCPuppet;
    if IsDefined(np) { np.RFC_MarkWSSeen(); }
    return true;
  }
  return false;
}

// Map WS kind → config
public func RFC_WSConfigForKind(c: RFCConfig, k: RFC_WSKind) -> RFC_WSKindConfig {
  switch k {
    case RFC_WSKind.Car:     return c.wsCar;
    case RFC_WSKind.Moto:    return c.wsMoto;
    // The menu exposes one Workspot profile. Use it for every non-vehicle
    // workspot kind so seated, leaning, ledge, and standing NPCs all honor it.
    case RFC_WSKind.Sit:     return c.wsStand;
    case RFC_WSKind.Lean:    return c.wsStand;
    case RFC_WSKind.Ledge:   return c.wsStand;
    case RFC_WSKind.StandWS: return c.wsStand;
    default:                 return c.wsStand;
  }
}

private func RFC_DetectWSKind(p: wref<ScriptedPuppet>) -> RFC_WSKind {
  if !IsDefined(p) { return RFC_WSKind.None; }

  // If the NPC is literally mounted to a vehicle (bike or car), treat it as vehicle WS even if anim tags are missing.
  // This fixes "motorcycles ignored" cases where runtime anim tags don't show up at the moment of death.
  if RFC_IsMountedToVehicle(p) {
    // Prefer Moto if any moto/bike tags are present on the puppet.
    let motoMountTags: array<CName>;
    ArrayPush(motoMountTags, n"motorcycle"); ArrayPush(motoMountTags, n"moto"); ArrayPush(motoMountTags, n"bike");
    ArrayPush(motoMountTags, n"veh_moto");   ArrayPush(motoMountTags, n"veh_bike"); ArrayPush(motoMountTags, n"veh_motorcycle");
    ArrayPush(motoMountTags, n"moto_mount"); ArrayPush(motoMountTags, n"bike_mount");
    if RFC_HasAnyTag(p, motoMountTags) { return RFC_WSKind.Moto; }
    return RFC_WSKind.Car;
  }

  let moto: array<CName>;
  ArrayPush(moto, n"motorcycle"); ArrayPush(moto, n"moto"); ArrayPush(moto, n"bike");
  ArrayPush(moto, n"veh_bike"); ArrayPush(moto, n"veh_moto"); ArrayPush(moto, n"veh_motorcycle");

  let car:  array<CName>;
  ArrayPush(car,  n"vehicle"); ArrayPush(car,  n"car"); ArrayPush(car,  n"veh"); ArrayPush(car,  n"veh_car");
  ArrayPush(car, n"veh_driver"); ArrayPush(car, n"veh_passenger"); ArrayPush(car, n"veh_drive");

  let sit:   array<CName>;
  ArrayPush(sit, n"sit"); ArrayPush(sit, n"chair"); ArrayPush(sit, n"bench"); ArrayPush(sit, n"stool"); ArrayPush(sit, n"ws_sit");

  let lean:  array<CName>;
  ArrayPush(lean, n"lean"); ArrayPush(lean, n"bar_lean"); ArrayPush(lean, n"wall_lean");

  let stand: array<CName>;
  ArrayPush(stand, n"ws_stand"); ArrayPush(stand, n"stand_ws");

  let idle:  array<CName>;
  ArrayPush(idle, n"ws_idle");

  let ledge: array<CName>;
  ArrayPush(ledge, n"ledge"); ArrayPush(ledge, n"perch"); ArrayPush(ledge, n"rail");

  let cMoto:  Int32 = RFC_CountAnyTags(p, moto);
  let cCar:   Int32 = RFC_CountAnyTags(p, car);
  let cSit:   Int32 = RFC_CountAnyTags(p, sit);
  let cLean:  Int32 = RFC_CountAnyTags(p, lean);
  let cStand: Int32 = RFC_CountAnyTags(p, stand);
  let cIdle:  Int32 = RFC_CountAnyTags(p, idle);
  let cLedge: Int32 = RFC_CountAnyTags(p, ledge);

  if cMoto > 0 { return RFC_WSKind.Moto; }
  if cCar  > 0 { return RFC_WSKind.Car;  }
  if cSit  > 0 { return RFC_WSKind.Sit;  }
  if cLean > 0 { return RFC_WSKind.Lean; }
  if cLedge > 0 && cSit == 0 && cLean == 0 && cStand == 0 && cIdle == 0 { return RFC_WSKind.Ledge; }
  if cStand > 0 { return RFC_WSKind.StandWS; }
  if cIdle  > 0 { return RFC_WSKind.StandWS; }
  return RFC_WSKind.None;
}


// Vehicle transitions
private func RFC_IsVehTransition(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  let t: array<CName>;

  ArrayPush(t, n"ws_exit"); ArrayPush(t, n"ws_enter");
  ArrayPush(t, n"veh_exit"); ArrayPush(t, n"veh_enter");
  ArrayPush(t, n"veh_open"); ArrayPush(t, n"veh_close");
  ArrayPush(t, n"veh_door_out"); ArrayPush(t, n"veh_door_in");
  ArrayPush(t, n"veh_seat_exit"); ArrayPush(t, n"veh_seat_enter");
  ArrayPush(t, n"moto_mount"); ArrayPush(t, n"moto_dismount");
  ArrayPush(t, n"bike_mount"); ArrayPush(t, n"bike_dismount");
  ArrayPush(t, n"mount"); ArrayPush(t, n"dismount"); ArrayPush(t, n"enter"); ArrayPush(t, n"exit");

  let hit: Bool = RFC_HasAnyTag(p, t);
  if hit {
    let np: wref<NPCPuppet> = p as NPCPuppet;
    if IsDefined(np) { np.RFC_MarkVehSeen(); }
  }
  return hit;
}


// Are we in a car context right now?
private func RFC_IsCarContext(p: wref<ScriptedPuppet>) -> Bool {
  let np: wref<NPCPuppet> = p as NPCPuppet;
  if !IsDefined(np) { return false; }
  if RFC_HasCarTags(np) { return true; }
  if RFC_IsVehTransition(np) { return true; }
  if RFC_InAnyWorkspot(np) && np.RFC_WasVehRecent(2.0) { return true; }
  return false;
}

// Vehicle tag check using runtime animset tags
private func RFC_HasVehicleAnimTags(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  let t: array<CName>;
  ArrayPush(t, n"vehicle"); ArrayPush(t, n"car"); ArrayPush(t, n"veh"); ArrayPush(t, n"veh_car");
  ArrayPush(t, n"veh_driver"); ArrayPush(t, n"veh_passenger");
  ArrayPush(t, n"motorcycle"); ArrayPush(t, n"bike"); ArrayPush(t, n"veh_bike"); ArrayPush(t, n"veh_moto");
  return p.HasRuntimeAnimsetTags(t);
}

// Workspot system check for car/moto (no WorkspotData)
private func RFC_IsInCarOrMotoWS(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(p.GetGame());
  if !IsDefined(ws) || !ws.IsActorInWorkspot(p) { return false; }
  // Inside a workspot—now decide if it's a vehicle by runtime tags
  return RFC_HasVehicleAnimTags(p);
}

// Driver/passenger seats can report as plain workspots with no mounted parent and
// no veh_* runtime tags at the exact hit frame. This is the missing driver-side
// case: the NPC is still in a WorkspotGameSystem seat, but the old mounted/tag
// checks miss it, then arcade/jolt/death impulses ragdoll the driver through the
// car. Treat an active, unclassified workspot as a protected vehicle-seat style
// workspot unless it clearly looks like a normal chair/bench/lean/ledge workspot.
private func RFC_IsVehicleSeatWorkspotLoose(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }

  let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(p.GetGame());
  if !IsDefined(ws) || !ws.IsActorInWorkspot(p) { return false; }

  if RFC_HasVehicleAnimTags(p) { return true; }

  let nonVehicleWS: array<CName>;
  ArrayPush(nonVehicleWS, n"sit");       ArrayPush(nonVehicleWS, n"stool");
  ArrayPush(nonVehicleWS, n"chair");     ArrayPush(nonVehicleWS, n"bench");
  ArrayPush(nonVehicleWS, n"perch");     ArrayPush(nonVehicleWS, n"ledge");
  ArrayPush(nonVehicleWS, n"lean");      ArrayPush(nonVehicleWS, n"bar_lean");
  ArrayPush(nonVehicleWS, n"wall_lean"); ArrayPush(nonVehicleWS, n"ws_sit");
  ArrayPush(nonVehicleWS, n"ws_stand");  ArrayPush(nonVehicleWS, n"stand_ws");
  ArrayPush(nonVehicleWS, n"ws_idle");

  if RFC_HasAnyTag(p, nonVehicleWS) {
    return false;
  }

  let np: wref<NPCPuppet> = p as NPCPuppet;
  if IsDefined(np) { np.RFC_MarkVehSeen(); }
  return true;
}


private func RFC_HasCarTags(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  let t: array<CName>;
  ArrayPush(t, n"veh_driver"); ArrayPush(t, n"veh_passenger");
  ArrayPush(t, n"veh_car"); ArrayPush(t, n"car"); ArrayPush(t, n"vehicle");
  return p.HasRuntimeAnimsetTags(t);
}

private func RFC_IsCarTransition(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  let t: array<CName>;
  ArrayPush(t, n"veh_exit"); ArrayPush(t, n"veh_enter");
  ArrayPush(t, n"veh_door_out"); ArrayPush(t, n"veh_door_in");
  ArrayPush(t, n"veh_seat_exit"); ArrayPush(t, n"veh_seat_enter");
  ArrayPush(t, n"ws_exit"); ArrayPush(t, n"ws_enter");
  return p.HasRuntimeAnimsetTags(t) && RFC_HasCarTags(p);
}

// CAR-only tag check
private func RFC_HasCarAnimTags(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  let t: array<CName>;
  ArrayPush(t, n"vehicle"); ArrayPush(t, n"car"); ArrayPush(t, n"veh"); ArrayPush(t, n"veh_car");
  ArrayPush(t, n"veh_driver"); ArrayPush(t, n"veh_passenger");
  return p.HasRuntimeAnimsetTags(t);
}
private func RFC_AllowRFC(p: wref<ScriptedPuppet>) -> Bool {
  if RFC.Cfg().vanillaMode { return false; }
  let np: wref<NPCPuppet> = p as NPCPuppet;
  if !IsDefined(np) { return false; }

  // The old stabilization cleanup is mode-independent. Feature systems keep
  // their own vanillaMode gates; this helper only excludes live vehicle seats.
  // Important: do not use the old memory-only rfc_blockUntil as a full hard
  // block. That kept exited drivers/passengers from receiving normal hit/death
  // cleanup and could let the vehicle workspot pipeline pull them back in.
  // Only block while the NPC is currently in a vehicle/mount/seat context.
  if RFC_IsVehicleContext(np) {
    return false;
  }

  return true;
}

public func RFC_GetMountedVehicle(obj: wref<GameObject>) -> wref<VehicleObject> {
  if !IsDefined(obj) { return null; }

  let veh: wref<VehicleObject>;
  if VehicleComponent.GetVehicle(obj.GetGame(), obj, veh) && IsDefined(veh) {
    return veh;
  }

  let game: GameInstance = obj.GetGame();
  let mf: ref<IMountingFacility> = GameInstance.GetMountingFacility(game);
  if !IsDefined(mf) { return null; }
  let mi: MountingInfo = mf.GetMountingInfoSingleWithObjects(obj);
  if !EntityID.IsDefined(mi.parentId) { return null; }
  return GameInstance.FindEntityByID(game, mi.parentId) as VehicleObject;
}

private func RFC_IsVehicleSeatSlotName(slotName: CName) -> Bool {
  if !IsNameValid(slotName) { return false; }

  let s: String = NameToString(slotName);
  if StrContains(s, "seat_front_left") { return true; }
  if StrContains(s, "seat_front_right") { return true; }
  if StrContains(s, "seat_back_left") { return true; }
  if StrContains(s, "seat_back_right") { return true; }
  if StrContains(s, "seat_") { return true; }
  if StrContains(s, "driver") { return true; }
  if StrContains(s, "passenger") { return true; }
  return false;
}

// Native vehicle-occupant detector.
// This is the replacement for the failed generic workspot guesses. It uses the
// game's own VehicleComponent lane first, then a MountingInfo slot-name fallback.
// It should catch drivers/passengers while leaving normal sitting/workspot NPCs alone.
private func RFC_IsNativeVehicleOccupantRaw(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }

  let game: GameInstance = p.GetGame();
  if !GameInstance.IsValid(game) { return false; }

  if VehicleComponent.IsMountedToVehicle(game, p) {
    return true;
  }

  let veh: wref<VehicleObject>;
  if VehicleComponent.GetVehicle(game, p, veh) && IsDefined(veh) {
    return true;
  }

  let slotName: CName;
  if VehicleComponent.GetMountedSlotName(game, p, slotName) && RFC_IsVehicleSeatSlotName(slotName) {
    return true;
  }

  // Manual MountingInfo fallback. Keep the seat-slot requirement so this does
  // not turn every mounted/workspot object into a vehicle occupant.
  let mf: ref<IMountingFacility> = GameInstance.GetMountingFacility(game);
  if IsDefined(mf) {
    let mi: MountingInfo = mf.GetMountingInfoSingleWithObjects(p);
    if EntityID.IsDefined(mi.parentId) && RFC_IsVehicleSeatSlotName(mi.slotId.id) {
      return true;
    }
  }

  return false;
}

public func RFC_IsMountedToVehicle(p: wref<ScriptedPuppet>) -> Bool = RFC_IsNativeVehicleOccupantRaw(p);

func RFC_IsCarContext_TagFallback(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }

  let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(p.GetGame());
  if !IsDefined(ws) || !ws.IsActorInWorkspot(p) { return false; }

  let carTags: array<CName>;
  ArrayPush(carTags, n"veh");        ArrayPush(carTags, n"vehicle");
  ArrayPush(carTags, n"car");        ArrayPush(carTags, n"van");
  ArrayPush(carTags, n"truck");      ArrayPush(carTags, n"motorcycle");
  ArrayPush(carTags, n"driver");     ArrayPush(carTags, n"passenger");
  ArrayPush(carTags, n"veh_sit");    ArrayPush(carTags, n"veh_drive");
  ArrayPush(carTags, n"veh_back");   ArrayPush(carTags, n"veh_shoot");
  ArrayPush(carTags, n"door");       ArrayPush(carTags, n"door_van");
  ArrayPush(carTags, n"door_back");  ArrayPush(carTags, n"trunk");

  return (p as NPCPuppet).HasRuntimeAnimsetTags(carTags);
}

private func RFC_MarkVehicleSeatShieldNPC(np: wref<NPCPuppet>, seconds: Float) -> Bool {
  if !IsDefined(np) { return false; }
  let c: RFCConfig = RFC.Cfg();
  if !c.vehicleOccupantShieldEnabled { return false; }

  let dur: Float = RFC_WSClampF(seconds, 0.0, 3.0);
  np.RFC_MarkVehSeen();
  np.RFC_MarkVehicleSeatShield(dur);

  // Keep the legacy block latch in sync, but do not allow it to become a hard
  // standalone reason later. RFC_IsVehicleContext() below only honors it when
  // a live vehicle/transition hint is still present.
  np.RFC_BlockRFC(dur);
  return true;
}

private func RFC_MarkVehicleExitShieldNPC(np: wref<NPCPuppet>, seconds: Float) -> Bool {
  if !IsDefined(np) { return false; }
  let c: RFCConfig = RFC.Cfg();
  if !c.vehicleExitShieldEnabled { return false; }

  let dur: Float = RFC_WSClampF(seconds, 0.0, 3.0);
  np.RFC_MarkVehSeen();
  np.RFC_MarkVehicleExitShield(dur);
  np.RFC_BlockRFC(dur);
  return true;
}

private func RFC_VehicleSeatShieldWindow(c: RFCConfig) -> Float {
  return RFC_WSClampF(c.vehicleOccupantShieldTime, 0.0, 3.0);
}

private func RFC_VehicleExitShieldWindow(c: RFCConfig) -> Float {
  return RFC_WSClampF(c.vehicleExitShieldTime, 0.0, 3.0);
}

// Vehicle-occupant quarantine used only by SPLAT NPC impulse paths.
//
// Important philosophy for v5:
// - Do NOT disable the VehicleObject impulse path just because the car is occupied.
// - Do NOT use a stale memory latch by itself.
// - Do block SPLAT's extra puppet ragdoll/impulse/workspot-stop layers while the
//   native seat/mount/exit pipeline owns the driver/passenger.
public func RFC_IsVehicleContext(p: wref<ScriptedPuppet>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  if !c.killImpulsesVehiclesOnly {
    return false;
  }

  let np: wref<NPCPuppet> = p as NPCPuppet;
  if !IsDefined(np) {
    return false;
  }

  let seatWindow: Float = RFC_VehicleSeatShieldWindow(c);
  let exitWindow: Float = RFC_VehicleExitShieldWindow(c);

  // Strongest signal: the game says this puppet is actively mounted to a vehicle
  // or in a native vehicle seat slot. This should block SPLAT impulses while the
  // car itself remains free to react to bullets/windows/explosions.
  if RFC_IsNativeVehicleOccupantRaw(np) {
    np.RFC_MarkVehSeen();
    RFC_MarkVehicleSeatShieldNPC(np, seatWindow);
    return true;
  }

  // Enter/exit/pull-out/door animation. This is the ugly teleport window. Let
  // vanilla finish it, then release SPLAT again.
  if RFC_IsVehTransition(np) {
    np.RFC_MarkVehSeen();
    RFC_MarkVehicleExitShieldNPC(np, exitWindow);
    return true;
  }

  // Runtime tags and seat workspot hints. Treat these as transition/seat hints,
  // but only as SPLAT-impulse blocks, not as global hit cancellation.
  if RFC_HasVehicleAnimTags(np) || RFC_IsInCarOrMotoWS(np) || RFC_IsCarContext_TagFallback(np) {
    np.RFC_MarkVehSeen();
    RFC_MarkVehicleExitShieldNPC(np, exitWindow);
    return true;
  }

  // Loose workspot fallback is dangerous if used forever: chairs and benches are
  // also workspots. Only use it immediately after a vehicle hit marked this NPC.
  if np.RFC_WasVehRecent(0.45) && RFC_IsVehicleSeatWorkspotLoose(np) {
    return RFC_MarkVehicleSeatShieldNPC(np, seatWindow);
  }

  // Latch checks are only valid if a current vehicle hint remains or the latch is
  // still within the tiny window created by a vehicle hit. This prevents the old
  // "exited driver dies, then snaps back into the car" regression.
  if c.vehicleOccupantShieldEnabled && np.RFC_IsVehicleSeatShielded() {
    if RFC_HasVehicleAnimTags(np) || RFC_IsVehTransition(np) || np.RFC_WasVehRecent(seatWindow + 0.15) {
      return true;
    }
  }

  if c.vehicleExitShieldEnabled && np.RFC_IsVehicleExitShielded() {
    if RFC_HasVehicleAnimTags(np) || RFC_IsVehTransition(np) || np.RFC_WasVehRecent(exitWindow + 0.15) {
      return true;
    }
  }

  if np.RFC_IsRFCBlocked() && (RFC_HasVehicleAnimTags(np) || RFC_IsVehTransition(np)) {
    return true;
  }

  // Death can detach the puppet from its native seat before the death router
  // and delayed impulse lanes inspect it. The main vehicle kill toggle must
  // keep working even when the optional experimental shields are disabled.
  if np.RFC_WasVehRecent(MaxF(1.25, MaxF(seatWindow, exitWindow) + 0.15)) {
    return true;
  }

  return false;
}

@addMethod(NPCPuppet)
public func RFC_MarkWSKind(k: Int32) -> Void {
  this.rfc_wsKindLastSeen = k;
}

@addMethod(NPCPuppet)
public func RFC_GetWSKindLastSeen() -> Int32 = this.rfc_wsKindLastSeen;

@addMethod(NPCPuppet)
public func RFC_MarkWSSeen() -> Void {
  this.rfc_wsLastSeen = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
}

@addMethod(NPCPuppet)
public func RFC_GetWSLastSeen() -> Float = this.rfc_wsLastSeen;

@addMethod(NPCPuppet)
public func RFC_MarkVehSeen() -> Void {
  this.rfc_vehLastSeen = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
}

// Called only after vanilla has processed a death that was classified as
// vehicle context. Active native occupants/transitions stay protected. Once the
// game has detached a former driver/passenger, clear the stale workspot state
// that otherwise pulls or hovers the corpse back toward the old vehicle.
public func RFC_CleanupFormerVehicleOccupantAfterDeath(p: wref<NPCPuppet>) -> Void {
  if !IsDefined(p) {
    return;
  }

  if RFC_IsNativeVehicleOccupantRaw(p) || RFC_IsVehTransition(p) {
    return;
  }

  let ws: ref<WorkspotGameSystem> = RFC_GetWS(p);
  if IsDefined(ws) && ws.IsActorInWorkspot(p) {
    ws.StopNpcInWorkspot(p);
  }

  StatusEffectHelper.RemoveStatusEffect(p, t"WorkspotStatus.Death");
  StatusEffectHelper.RemoveStatusEffect(p, t"WorkspotStatus.SyncAnimation");
  StatusEffectHelper.RemoveStatusEffect(p, t"WorkspotStatus.InWorkspot");
  StatusEffectHelper.RemoveStatusEffect(p, t"GameplayRestriction.Workspot");

  p.rfc_vehicleSeatShieldUntil = 0.0;
  p.rfc_vehicleExitShieldUntil = 0.0;
  p.rfc_vehLastSeen = 0.0;
  p.RFC_ClearRFCBlock();

  if p.rfc_wsKindLastSeen == EnumInt(RFC_WSKind.Car)
    || p.rfc_wsKindLastSeen == EnumInt(RFC_WSKind.Moto) {
    p.rfc_wsKindLastSeen = EnumInt(RFC_WSKind.None);
    p.rfc_wsLastSeen = 0.0;
  }
}

@addMethod(NPCPuppet)
public func RFC_MarkVehicleSeatShield(seconds: Float) -> Void {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  this.rfc_vehicleSeatShieldUntil = MaxF(this.rfc_vehicleSeatShieldUntil, now + MaxF(0.0, seconds));
}

@addMethod(NPCPuppet)
public func RFC_MarkVehicleExitShield(seconds: Float) -> Void {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  this.rfc_vehicleExitShieldUntil = MaxF(this.rfc_vehicleExitShieldUntil, now + MaxF(0.0, seconds));
}

@addMethod(NPCPuppet)
public func RFC_IsVehicleSeatShielded() -> Bool {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  return now < this.rfc_vehicleSeatShieldUntil;
}

@addMethod(NPCPuppet)
public func RFC_IsVehicleExitShielded() -> Bool {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  return now < this.rfc_vehicleExitShieldUntil;
}

@addMethod(NPCPuppet)
public func RFC_WasVehRecent(window: Float) -> Bool {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  return this.rfc_vehLastSeen > 0.0 && (now - this.rfc_vehLastSeen) <= window;
}

@addMethod(NPCPuppet)
public func RFC_GetLastOrLiveKind() -> RFC_WSKind {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  let lastWS: Float = this.RFC_GetWSLastSeen();
  if lastWS > 0.0 && (now - lastWS) <= 1.25 && this.rfc_wsKindLastSeen != 0 {
    return IntEnum<RFC_WSKind>(this.rfc_wsKindLastSeen);
  }
  return RFC_DetectWSKind(this);
}
