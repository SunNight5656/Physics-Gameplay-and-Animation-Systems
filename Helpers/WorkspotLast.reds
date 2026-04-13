

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
  let ws: ref<WorkspotGameSystem> = RFC_GetWS(p);
  if !IsDefined(ws) { return false; }
  if !ws.IsActorInWorkspot(p) { return false; }
  ws.StopNpcInWorkspot(p);
  return true;
}

// PopFix should be allowed even during vehicle/workspot transitions.
// Use this instead of RFC_AllowRFC() in PopFix hooks.
public func RFC_AllowPopFix(p: wref<ScriptedPuppet>) -> Bool {
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
    case RFC_WSKind.Sit:     return c.wsSit;
    case RFC_WSKind.Lean:    return c.wsLean;
    case RFC_WSKind.Ledge:   return c.wsLedge;
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
  let np: wref<NPCPuppet> = p as NPCPuppet;
  if !IsDefined(np) { return false; }
  if np.RFC_IsRFCBlocked() { return false; }

  // Hard quarantine near car enter/exit or car tags
  if RFC_IsCarContext(np) {
    np.RFC_MarkVehSeen();
    np.RFC_BlockRFC(2.5); // tune 2.0–3.0 if needed
    return false;
  }

  return true;
}

public func RFC_GetMountedVehicle(obj: wref<GameObject>) -> wref<VehicleObject> {
  if !IsDefined(obj) { return null; }
  let game: GameInstance = obj.GetGame();
  let mf: ref<IMountingFacility> = GameInstance.GetMountingFacility(game);
  let mi: MountingInfo = mf.GetMountingInfoSingleWithObjects(obj);
  let veh: wref<VehicleObject> = GameInstance.FindEntityByID(game, mi.parentId) as VehicleObject;
  return veh;
}

public func RFC_IsMountedToVehicle(p: wref<ScriptedPuppet>) -> Bool = IsDefined(RFC_GetMountedVehicle(p));

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

public func RFC_IsVehicleContext(p: wref<ScriptedPuppet>) -> Bool =
  RFC_IsMountedToVehicle(p) || RFC_IsCarContext_TagFallback(p);

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

