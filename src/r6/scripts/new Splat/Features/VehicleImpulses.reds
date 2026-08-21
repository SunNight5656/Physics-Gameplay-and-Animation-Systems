module RealisticPush

// Vehicle Impulses
// Standalone car shove layer using PhysicalImpulseEvent, based on the working CET vehicle-push test.
// It does not replace NPC arcade impulses. It only runs when a VehicleObject receives a valid hit.

@addField(VehicleObject) public let rfc_vehicleImpulseLastT: Float;
@addField(BikeObject) public let rfc_arcadeLeanToppleLatched: Bool;
@addField(PlayerPuppet) private let rfc_arcadeBikeLeanCheckScheduled: Bool;

// Repeated runtime kill event. Some native vehicle paths re-enable air/tilt
// stabilization after OnHit, so one immediate EnableAirControl(false) is not enough.
public class RFC_VehKillSelfRightingEvent extends Event {}
public class RFC_ArcadeBikeLeanCheckEvent extends Event {}

@addMethod(VehicleObject)
protected cb func OnRFC_VehKillSelfRightingEvent(evt: ref<RFC_VehKillSelfRightingEvent>) -> Bool {
  if RFC.Cfg().vanillaMode {
    return true;
  }
  RFC_VehKillSelfRightingControls(this);
  return true;
}


// Kill the game's vehicle self-righting helpers at runtime.
// This is separate from the TweakXL air-control record override below.
// Goal: cars/bikes hit by SPLAT vehicle impulses should not fight to land upright.
private func RFC_VehKillSelfRightingControls(vehicle: ref<VehicleObject>) -> Void {
  if !IsDefined(vehicle) { return; }

  vehicle.EnableAirControl(false);

  let bike: ref<BikeObject> = vehicle as BikeObject;
  if IsDefined(bike) {
    bike.EnableTiltControl(false);
  }
}


private func RFC_VehScheduleSelfRightingKill(vehicle: ref<VehicleObject>) -> Void {
  if !IsDefined(vehicle) { return; }
  RFC_VehKillSelfRightingControls(vehicle);

  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(vehicle.GetGame());
  if !IsDefined(ds) { return; }

  // Keep this short but repeated. It fights the car/bike auto-upright re-enable
  // window without permanently touching unrelated vehicles that were never hit.
  ds.DelayEvent(vehicle, new RFC_VehKillSelfRightingEvent(), 0.020, false);
  ds.DelayEvent(vehicle, new RFC_VehKillSelfRightingEvent(), 0.080, false);
  ds.DelayEvent(vehicle, new RFC_VehKillSelfRightingEvent(), 0.180, false);
  ds.DelayEvent(vehicle, new RFC_VehKillSelfRightingEvent(), 0.360, false);
  ds.DelayEvent(vehicle, new RFC_VehKillSelfRightingEvent(), 0.720, false);
}

// Use the same native actuator as motorcycle rider death/collision. The native
// event unparks the bike and disables tilt control. SPLAT supplies its own
// signed side impulse so the fall direction can be chosen instead of always
// using the bike's local-right direction.
private func RFC_VehToppleBikeSigned(
  bike: ref<BikeObject>,
  side: Float,
  strength: Float,
  cfg: RFCConfig
) -> Bool {
  if !IsDefined(bike) { return false; }
  if strength <= 0.0 { return false; }
  if RFC_TimeDilationBlocksImpulses(bike, cfg) { return false; }

  // Preserve the proven standalone-controller sequence. The native receiver
  // performs its own unpark and tilt-control shutdown when it handles this.
  let knockEvt: ref<KnockOverBikeEvent> = new KnockOverBikeEvent();
  knockEvt.forceKnockdown = true;
  knockEvt.applyDirectionalForce = false;
  bike.QueueEvent(knockEvt);

  let impulseEvt: ref<PhysicalImpulseEvent> = new PhysicalImpulseEvent();
  impulseEvt.radius = 1.0;

  let position: Vector4 = bike.GetWorldPosition();
  impulseEvt.worldPosition.X = position.X;
  impulseEvt.worldPosition.Y = position.Y;
  impulseEvt.worldPosition.Z = position.Z + 0.50;

  let direction: Vector4 = WorldTransform.GetRight(bike.GetWorldTransform());
  if side < 0.0 {
    direction *= -1.0;
  }
  // Do not flatten this vector. Its live bike-tilt component is what turns the
  // working actuator into a roll instead of merely translating the motorcycle.
  direction *= bike.GetTotalMass() * strength;
  impulseEvt.worldImpulse = Vector4.Vector4To3(direction);

  bike.PhysicsWakeUp();
  bike.QueueEvent(impulseEvt);
  RFC_VehScheduleSelfRightingKill(bike);
  return true;
}

// Select the bike-local side that points away from the shooter. A centered
// front/rear shot has no lateral shooter component, so use the actual hit side
// as the tie-breaker.
private func RFC_VehBikeShotToppleSide(
  bike: ref<BikeObject>,
  hitPos: Vector4,
  srcPos: Vector4
) -> Float {
  let bikePos: Vector4 = bike.GetWorldPosition();
  let right: Vector4 = WorldTransform.GetRight(bike.GetWorldTransform());
  let awayX: Float = bikePos.X - srcPos.X;
  let awayY: Float = bikePos.Y - srcPos.Y;
  let sideDot: Float = awayX * right.X + awayY * right.Y;

  if AbsF(sideDot) < 0.10 {
    sideDot = (hitPos.X - bikePos.X) * right.X
      + (hitPos.Y - bikePos.Y) * right.Y;
  }

  if sideDot < 0.0 { return -1.0; }
  return 1.0;
}

// Mirror the native motorcycle death pipeline's DriverDead/NoDriver signals.
// SPLAT skips the delayed vanilla knock-off animation, so it must send these
// explicitly or the traffic AI can continue driving an empty motorcycle.
public func RFC_VehStopDeadBikeDriverAI(bike: wref<BikeObject>) -> Void {
  if !IsDefined(bike) { return; }

  let driverDead: ref<AIEvent> = new AIEvent();
  driverDead.name = n"DriverDead";
  bike.QueueEvent(driverDead);

  let noDriver: ref<AIEvent> = new AIEvent();
  noDriver.name = n"NoDriver";
  bike.QueueEvent(noDriver);
}

// Do not feed the native collision-exit decision here. That path derives an
// opposite sideways rider impulse and adds a hard-coded upward launch. Unmount
// V instantly, activate one directionless ragdoll, and topple only the bike.
private func RFC_VehTopplePlayerBikeFromLean(
  bike: ref<BikeObject>,
  player: ref<PlayerPuppet>,
  side: Float,
  cfg: RFCConfig
) -> Bool {
  if !IsDefined(bike) || !IsDefined(player) { return false; }
  if RFC_TimeDilationBlocksImpulses(bike, cfg) { return false; }

  let toppled: Bool = RFC_VehToppleBikeSigned(
    bike,
    side,
    cfg.vehicleMotorcycleToppleStrength,
    cfg
  );
  if !toppled { return false; }

  let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(player.GetGame());
  if IsDefined(ws) {
    ws.UnmountFromVehicle(bike, player, true);
  }
  player.QueueEvent(CreateForceRagdollEvent(n"Splat_PlayerBikeLeanFall"));
  return true;
}

private func RFC_ArcadeBikeScheduleLeanCheck(player: ref<PlayerPuppet>, delay: Float) -> Void {
  if !IsDefined(player) || player.rfc_arcadeBikeLeanCheckScheduled { return; }

  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(player.GetGame());
  if !IsDefined(ds) { return; }

  player.rfc_arcadeBikeLeanCheckScheduled = true;
  ds.DelayEvent(player, new RFC_ArcadeBikeLeanCheckEvent(), delay, false);
}

@addMethod(PlayerPuppet)
protected cb func OnRFC_ArcadeBikeLeanCheckEvent(evt: ref<RFC_ArcadeBikeLeanCheckEvent>) -> Bool {
  this.rfc_arcadeBikeLeanCheckScheduled = false;

  let cfg: RFCConfig = RFC.Cfg();

  // HARD VANILLA BYPASS: stop this background loop entirely.
  if cfg.vanillaMode { return true; }

  let nextDelay: Float = 0.50;

  if cfg.vehicleImpulseEnabled
    && cfg.playerMotorcycleLeanToppleEnabled {
    nextDelay = 0.05;

    let vehicle: wref<VehicleObject> = RFC_GetMountedVehicle(this);
    let bike: ref<BikeObject> = vehicle as BikeObject;

    if IsDefined(bike)
      && VehicleComponent.IsDriver(this.GetGame(), this)
      && bike.IsTiltControlEnabled()
      && !RFC_TimeDilationBlocksImpulses(bike, cfg) {
      // The chassis transform can remain nearly upright while the controller
      // applies its full lean. BikeTilt is the controller's live signed value.
      let leanValue: Float = bike.GetBlackboard().GetFloat(
        GetAllBlackboardDefs().Vehicle.BikeTilt
      );
      let tiltAngle: Float = AbsF(leanValue);

      if tiltAngle < cfg.playerMotorcycleLeanToppleAngle - 4.0 {
        bike.rfc_arcadeLeanToppleLatched = false;
      }

      if !bike.rfc_arcadeLeanToppleLatched
        && tiltAngle >= cfg.playerMotorcycleLeanToppleAngle
        && AbsF(bike.GetCurrentSpeed()) <= cfg.playerMotorcycleLeanToppleMaxSpeed {
        let side: Float = 1.0;
        if leanValue < 0.0 { side = -1.0; }

        bike.rfc_arcadeLeanToppleLatched = true;
        RFC_VehTopplePlayerBikeFromLean(
          bike,
          this,
          side,
          cfg
        );
      }
    }
  }

  RFC_ArcadeBikeScheduleLeanCheck(this, nextDelay);
  return true;
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let result: Bool = wrappedMethod();
  if !RFC.Cfg().vanillaMode { RFC_ArcadeBikeScheduleLeanCheck(this, 0.25); }
  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(resolveInterface: EntityResolveComponentsInterface) -> Bool {
  let result: Bool = wrappedMethod(resolveInterface);
  if !RFC.Cfg().vanillaMode { RFC_ArcadeBikeScheduleLeanCheck(this, 0.25); }
  return result;
}

private func RFC_VehIsUpsideDown(vehicle: ref<VehicleObject>) -> Bool {
  if !IsDefined(vehicle) { return false; }
  let up: Vector4 = vehicle.GetWorldUp();
  return up.Z < 0.15;
}


// Mark every known passenger/driver on a vehicle so delayed NPC impulse lanes
// (body fall, head fall, grenade kick, death impulse, jolts) skip them even if
// hit-frame workspot/mount detection is missing later.

private func RFC_VehMarkAllOccupants(vehicle: ref<VehicleObject>, seconds: Float) -> Void {
  if !IsDefined(vehicle) { return; }

  let gi: GameInstance = vehicle.GetGame();
  if !GameInstance.IsValid(gi) { return; }

  // REDscript uses wref<T> here. The old passenger-array type was the compile
  // error. Keep the original GetAllPassengers path, but cap the
  // quarantine window so exited NPCs are not blocked from normal death/on-hit cleanup.
  let passengers: array<wref<GameObject>>;
  VehicleComponent.GetAllPassengers(gi, vehicle.GetEntityID(), true, passengers);

  let cfg: RFCConfig = RFC.Cfg();

  // Vehicle hits may arrive on windows/glass/cabin parts. Keep the VehicleObject
  // impulse active, but quarantine current occupants from SPLAT puppet impulses
  // for a short, configurable window.
  let dur: Float = RFC_VehClampF(cfg.vehicleOccupantShieldTime, 0.0, 3.0);
  let i: Int32 = 0;
  while i < ArraySize(passengers) {
    let np: wref<NPCPuppet> = passengers[i] as NPCPuppet;
    if IsDefined(np) {
      np.RFC_MarkVehSeen();
      if cfg.vehicleOccupantShieldEnabled {
        np.RFC_MarkVehicleSeatShield(dur);
        np.RFC_BlockRFC(dur);
      }
    }
    i += 1;
  }
}


private enum RFCVehicleHitSource {
  Explosion = 0,
  Bullet = 1,
  Melee = 2,
  Ignore = 3
}

private enum RFCVehicleWeaponGroup {
  None = 0,
  Handgun = 1,
  Magnum = 2,
  Shotgun = 3,
  Sniper = 4,
  SMG = 5,
  AR = 6,
  LMG = 7,
  Blunt = 8,
  Blade = 9,
  Gorilla = 10
}

private func RFC_VehClampF(x: Float, lo: Float, hi: Float) -> Float {
  if x < lo { return lo; }
  if x > hi { return hi; }
  return x;
}

private func RFC_VehLen2(dx: Float, dy: Float) -> Float {
  return SqrtF(dx * dx + dy * dy);
}

private func RFC_VehIsExplosion(ad: ref<AttackData>) -> Bool {
  if !IsDefined(ad) { return false; }
  let at: gamedataAttackType = ad.GetAttackType();
  if Equals(at, gamedataAttackType.Explosion) { return true; }
  if Equals(at, gamedataAttackType.PressureWave) { return true; }
  if AttackData.IsExplosion(at) { return true; }
  if AttackData.IsAreaOfEffect(at) { return true; }
  if ad.HasFlag(hitFlag.Explosion) { return true; }
  return false;
}

private func RFC_VehIsMelee(ad: ref<AttackData>) -> Bool {
  return RFC_ArcadeIsMeleeAttack(ad);
}

private func RFC_VehClassifySource(ad: ref<AttackData>) -> RFCVehicleHitSource {
  if !IsDefined(ad) { return RFCVehicleHitSource.Ignore; }
  if RFC_VehIsExplosion(ad) { return RFCVehicleHitSource.Explosion; }
  if RFC_VehIsMelee(ad) { return RFCVehicleHitSource.Melee; }

  // Some vehicle bullet hits do not expose a normal WeaponObject on AttackData.
  // Treat non-explosion, non-melee weapon damage as bullet fallback so bullets
  // still get a chance to move cars instead of silently doing nothing.
  if IsDefined(ad.GetWeapon() as WeaponObject) { return RFCVehicleHitSource.Bullet; }
  if !ad.HasFlag(hitFlag.VehicleImpact) { return RFCVehicleHitSource.Bullet; }

  // VehicleImpact is also present on a subset of legitimate bullet hits after
  // their WeaponObject has already been released. Only suppress this lane when
  // the actual attacker is a vehicle; otherwise keep the unknown-bullet fallback.
  let sourceVehicle: ref<VehicleObject> = ad.GetInstigator() as VehicleObject;
  if IsDefined(sourceVehicle) { return RFCVehicleHitSource.Ignore; }
  return RFCVehicleHitSource.Bullet;
}

private func RFC_VehIsBadPos(v: Vector4) -> Bool {
  return AbsF(v.X) < 0.001 && AbsF(v.Y) < 0.001 && AbsF(v.Z) < 0.001;
}

private func RFC_VehIsTooClose2D(a: Vector4, b: Vector4) -> Bool {
  return RFC_VehLen2(a.X - b.X, a.Y - b.Y) < 0.20;
}

private func RFC_VehChooseExplosionSource(vehicle: ref<VehicleObject>, ad: ref<AttackData>, fallback: Vector4) -> Vector4 {
  let p: Vector4 = fallback;
  if IsDefined(ad) {
    p = ad.GetAttackPosition();
  };

  // For explosions, the instigator/player position is usually the wrong radial
  // center. If AttackData loses the actual blast center, use the vehicle hit
  // point as the blast source instead of pushing cars away from the player.
  if RFC_VehIsBadPos(p) {
    p = fallback;
  }
  return p;
}

private func RFC_VehPassesPlayerOnly(vehicle: ref<VehicleObject>, ad: ref<AttackData>, source: RFCVehicleHitSource) -> Bool {
  if !IsDefined(vehicle) || !IsDefined(ad) { return false; }

  // V Only is a strict attack-source gate. Missing or non-player ownership does
  // not enter the custom vehicle push lane.
  return RFC_IsPlayerAttack(vehicle, ad);
}

private func RFC_VehSourceUsesInstigator(source: RFCVehicleHitSource) -> Bool {
  switch source {
    case RFCVehicleHitSource.Bullet: return true;
    case RFCVehicleHitSource.Melee: return true;
  }
  return false;
}

private func RFC_VehGroupIsNone(g: RFCVehicleWeaponGroup) -> Bool {
  switch g {
    case RFCVehicleWeaponGroup.None: return true;
  }
  return false;
}

private func RFC_VehWeaponGroup(ad: ref<AttackData>) -> RFCVehicleWeaponGroup {
  if !IsDefined(ad) { return RFCVehicleWeaponGroup.None; }

  let isMelee: Bool = RFC_VehIsMelee(ad);
  let w: ref<WeaponObject> = ad.GetWeapon() as WeaponObject;

  // Fists / Gorilla Arms often do not resolve like normal held weapons, so treat
  // no-weapon melee as the Gorilla/Fists bucket.
  if !IsDefined(w) {
    if isMelee { return RFCVehicleWeaponGroup.Gorilla; }
    return RFCVehicleWeaponGroup.None;
  }

  let id: TweakDBID = w.GetItemID().GetTDBID();
  if !TDBID.IsValid(id) {
    if isMelee { return RFCVehicleWeaponGroup.Gorilla; }
    return RFCVehicleWeaponGroup.None;
  }

  // Known Gorilla Arms / strong-arms records. The no-weapon melee fallback above
  // is still the important part for Gorilla Arms if the game does not expose a normal WeaponObject.
  if Equals(id, t"Items.StrongArmsLegendary") { return RFCVehicleWeaponGroup.Gorilla; }
  if Equals(id, t"Items.StrongArmsEpic") { return RFCVehicleWeaponGroup.Gorilla; }
  if Equals(id, t"Items.StrongArmsRare") { return RFCVehicleWeaponGroup.Gorilla; }
  if Equals(id, t"Items.StrongArmsUncommon") { return RFCVehicleWeaponGroup.Gorilla; }

  if RFC_ListHas(RFC_Arcade_List_Shotgun(), id) { return RFCVehicleWeaponGroup.Shotgun; }
  if RFC_ListHas(RFC_Arcade_List_Sniper(), id) { return RFCVehicleWeaponGroup.Sniper; }
  if RFC_ListHas(RFC_Arcade_List_Handgun(), id) { return RFCVehicleWeaponGroup.Handgun; }
  if RFC_ListHas(RFC_Arcade_List_Magnum(), id) { return RFCVehicleWeaponGroup.Magnum; }
  if RFC_ListHas(RFC_Arcade_List_SMG(), id) { return RFCVehicleWeaponGroup.SMG; }
  if RFC_ListHas(RFC_Arcade_List_AR(), id) { return RFCVehicleWeaponGroup.AR; }
  if RFC_ListHas(RFC_Arcade_List_LMG(), id) { return RFCVehicleWeaponGroup.LMG; }
  if RFC_ListHas(RFC_Arcade_List_Blunt(), id) { return RFCVehicleWeaponGroup.Blunt; }
  if RFC_ListHas(RFC_Arcade_List_Blade(), id) { return RFCVehicleWeaponGroup.Blade; }

  if isMelee { return RFCVehicleWeaponGroup.Gorilla; }
  return RFCVehicleWeaponGroup.None;
}

private func RFC_VehGroupAllowed(g: RFCVehicleWeaponGroup, cfg: RFCConfig) -> Bool {
  switch g {
    case RFCVehicleWeaponGroup.Handgun: return cfg.vehicleAllowHandgun;
    case RFCVehicleWeaponGroup.Magnum: return cfg.vehicleAllowMagnum;
    case RFCVehicleWeaponGroup.Shotgun: return cfg.vehicleAllowShotgun;
    case RFCVehicleWeaponGroup.Sniper: return cfg.vehicleAllowSniper;
    case RFCVehicleWeaponGroup.SMG: return cfg.vehicleAllowSMG;
    case RFCVehicleWeaponGroup.AR: return cfg.vehicleAllowAR;
    case RFCVehicleWeaponGroup.LMG: return cfg.vehicleAllowLMG;
    case RFCVehicleWeaponGroup.Blunt: return cfg.vehicleAllowBlunt;
    case RFCVehicleWeaponGroup.Blade: return cfg.vehicleAllowBlade;
    case RFCVehicleWeaponGroup.Gorilla: return cfg.vehicleAllowGorilla;
  }
  return false;
}

private func RFC_VehArcadeGroupAllowed(g: RFCVehicleWeaponGroup, cfg: RFCConfig) -> Bool {
  if !cfg.arcadeUseWeaponAllowList {
    return true;
  }
  switch g {
    case RFCVehicleWeaponGroup.Handgun: return cfg.arcadeAllowHandgun;
    case RFCVehicleWeaponGroup.Magnum: return cfg.arcadeAllowMagnum;
    case RFCVehicleWeaponGroup.Shotgun: return cfg.arcadeAllowShotgun;
    case RFCVehicleWeaponGroup.Sniper: return cfg.arcadeAllowSniper;
    case RFCVehicleWeaponGroup.SMG: return cfg.arcadeAllowSMG;
    case RFCVehicleWeaponGroup.AR: return cfg.arcadeAllowAR;
    case RFCVehicleWeaponGroup.LMG: return cfg.arcadeAllowLMG;
    case RFCVehicleWeaponGroup.Blunt: return cfg.arcadeAllowBlunt;
    case RFCVehicleWeaponGroup.Blade: return cfg.arcadeAllowBlade;
    case RFCVehicleWeaponGroup.Gorilla: return cfg.arcadeAllowBlunt;
  }
  return false;
}

private func RFC_VehGroupMul(g: RFCVehicleWeaponGroup, cfg: RFCConfig) -> Float {
  switch g {
    case RFCVehicleWeaponGroup.Handgun: return cfg.vehicleMulHandgun;
    case RFCVehicleWeaponGroup.Magnum: return cfg.vehicleMulMagnum;
    case RFCVehicleWeaponGroup.Shotgun: return cfg.vehicleMulShotgun;
    case RFCVehicleWeaponGroup.Sniper: return cfg.vehicleMulSniper;
    case RFCVehicleWeaponGroup.SMG: return cfg.vehicleMulSMG;
    case RFCVehicleWeaponGroup.AR: return cfg.vehicleMulAR;
    case RFCVehicleWeaponGroup.LMG: return cfg.vehicleMulLMG;
    case RFCVehicleWeaponGroup.Blunt: return cfg.vehicleMulBlunt;
    case RFCVehicleWeaponGroup.Blade: return cfg.vehicleMulBlade;
    case RFCVehicleWeaponGroup.Gorilla: return cfg.vehicleMulGorilla;
  }
  return 0.0;
}

private func RFC_VehArcadeGroupMul(g: RFCVehicleWeaponGroup, cfg: RFCConfig) -> Float {
  switch g {
    case RFCVehicleWeaponGroup.Handgun: return cfg.arcadeMulHandgun;
    case RFCVehicleWeaponGroup.Magnum: return cfg.arcadeMulMagnum;
    case RFCVehicleWeaponGroup.Shotgun: return cfg.arcadeMulShotgun;
    case RFCVehicleWeaponGroup.Sniper: return cfg.arcadeMulSniper;
    case RFCVehicleWeaponGroup.SMG: return cfg.arcadeMulSMG;
    case RFCVehicleWeaponGroup.AR: return cfg.arcadeMulAR;
    case RFCVehicleWeaponGroup.LMG: return cfg.arcadeMulLMG;
    case RFCVehicleWeaponGroup.Blunt: return cfg.arcadeMulBlunt;
    case RFCVehicleWeaponGroup.Blade: return cfg.arcadeMulBlade;
    case RFCVehicleWeaponGroup.Gorilla: return cfg.arcadeMulBlunt;
  }
  return 1.0;
}

private func RFC_VehExplosionMul(ad: ref<AttackData>, cfg: RFCConfig) -> Float {
  // VehicleObject explosions use the multiplier for the actual explosion
  // source. The old path always used explMulVehicle, but that field belongs to
  // vehicle-impact attacks affecting NPCs. In Realism Custom it could therefore
  // zero the entire vehicle blast while the named modes still worked.
  if !cfg.vehicleUseExplosionMultipliers { return 1.0; }
  if !IsDefined(ad) { return cfg.explMulGrenades; }

  let at: gamedataAttackType = ad.GetAttackType();
  let nativeExplosion: Bool = AttackData.IsExplosion(at)
    || AttackData.IsAreaOfEffect(at)
    || Equals(at, gamedataAttackType.PressureWave);
  let w: ref<WeaponObject> = ad.GetWeapon() as WeaponObject;

  if ad.HasFlag(hitFlag.Explosion) && !nativeExplosion && IsDefined(w) {
    return cfg.explMulBullet;
  }
  if IsDefined(w) {
    return cfg.explMulWeapon;
  }
  return cfg.explMulGrenades;
}

private func RFC_VehMassScale(vehicle: ref<VehicleObject>, cfg: RFCConfig) -> Float {
  if !IsDefined(vehicle) || !cfg.vehicleImpulseMassCompensation { return 1.0; }

  let mass: Float = vehicle.GetTotalMass();
  if mass <= 0.01 { return 1.0; }

  return RFC_VehClampF(mass / MaxF(1.0, cfg.vehicleImpulseReferenceMass), cfg.vehicleImpulseMinMassScale, cfg.vehicleImpulseMaxMassScale);
}

private func RFC_VehApplyPhysicalImpulse(
  vehicle: ref<VehicleObject>,
  hitPos: Vector4,
  srcPos: Vector4,
  strength: Float,
  lift: Float,
  radius: Float,
  cfg: RFCConfig
) -> Void {
  if !IsDefined(vehicle) { return; }
  if RFC_TimeDilationBlocksImpulses(vehicle, cfg) { return; }
  if strength == 0.0 && lift == 0.0 { return; }

  let vPos: Vector4 = vehicle.GetWorldPosition();
  let dx0: Float = vPos.X - srcPos.X;
  let dy0: Float = vPos.Y - srcPos.Y;
  let len: Float = RFC_VehLen2(dx0, dy0);

  let dx: Float = dx0;
  let dy: Float = dy0;
  if len < 0.001 {
    let fwd: Vector4 = vehicle.GetWorldForward();
    dx = fwd.X;
    dy = fwd.Y;
  } else {
    dx /= len;
    dy /= len;
  }

  let len2: Float = MaxF(0.001, RFC_VehLen2(dx, dy));
  dx /= len2;
  dy /= len2;

  let massScale: Float = RFC_VehMassScale(vehicle, cfg);
  let horizontal: Float = strength * massScale;
  let vertical: Float = lift * massScale;

  if cfg.vehicleImpulseClampEnabled {
    horizontal = MinF(horizontal, MaxF(0.0, cfg.vehicleImpulseMaxHorizontal));
    vertical = RFC_VehClampF(vertical, -MaxF(0.0, cfg.vehicleImpulseMaxLift), MaxF(0.0, cfg.vehicleImpulseMaxLift));
  }

  let impulse: Vector3;
  impulse.X = dx * horizontal;
  impulse.Y = dy * horizontal;
  impulse.Z = vertical;

  let pos: Vector3;
  pos.X = hitPos.X;
  pos.Y = hitPos.Y;
  pos.Z = hitPos.Z;

  RFC_VehScheduleSelfRightingKill(vehicle);

  let e: ref<PhysicalImpulseEvent> = new PhysicalImpulseEvent();
  e.worldImpulse = impulse;
  e.worldPosition = pos;
  e.radius = MaxF(0.05, radius);
  vehicle.QueueEvent(e);
}

private func RFC_VehApplyPhysicalImpulseVector(
  vehicle: ref<VehicleObject>,
  pos4: Vector4,
  ix: Float,
  iy: Float,
  iz: Float,
  radius: Float,
  cfg: RFCConfig
) -> Void {
  if !IsDefined(vehicle) { return; }
  if RFC_TimeDilationBlocksImpulses(vehicle, cfg) { return; }
  if ix == 0.0 && iy == 0.0 && iz == 0.0 { return; }

  let finalX: Float = ix;
  let finalY: Float = iy;
  let finalZ: Float = iz;

  let horizontal: Float = SqrtF(finalX * finalX + finalY * finalY);
  if cfg.vehicleImpulseClampEnabled {
    let maxH: Float = MaxF(0.0, cfg.vehicleImpulseMaxHorizontal);
    let maxZ: Float = MaxF(0.0, cfg.vehicleImpulseMaxLift);

    if horizontal > maxH && horizontal > 0.001 {
      let hScale: Float = maxH / horizontal;
      finalX *= hScale;
      finalY *= hScale;
    }
    finalZ = RFC_VehClampF(finalZ, -maxZ, maxZ);
  }

  let impulse: Vector3;
  impulse.X = finalX;
  impulse.Y = finalY;
  impulse.Z = finalZ;

  let pos: Vector3;
  pos.X = pos4.X;
  pos.Y = pos4.Y;
  pos.Z = pos4.Z;

  RFC_VehScheduleSelfRightingKill(vehicle);

  let e: ref<PhysicalImpulseEvent> = new PhysicalImpulseEvent();
  e.worldImpulse = impulse;
  e.worldPosition = pos;
  e.radius = MaxF(0.05, radius);
  vehicle.QueueEvent(e);
}

private func RFC_VehExplosionFallbackSource(vehicle: ref<VehicleObject>, hitPos: Vector4, srcPos: Vector4) -> Vector4 {
  if !IsDefined(vehicle) { return srcPos; }

  let center: Vector4 = vehicle.GetWorldPosition();
  if !RFC_VehIsBadPos(srcPos) && !RFC_VehIsTooClose2D(srcPos, hitPos) && !RFC_VehIsTooClose2D(srcPos, center) {
    return srcPos;
  }

  // If grenade/blast source collapses onto the vehicle/hit point, synthesize a
  // bullet-style source outside the car, behind the hit point. This gives the
  // same kind of off-center torque path that bullet hits get.
  let dx: Float = hitPos.X - center.X;
  let dy: Float = hitPos.Y - center.Y;
  let len: Float = RFC_VehLen2(dx, dy);

  if len < 0.001 {
    let fwd: Vector4 = vehicle.GetWorldForward();
    dx = fwd.X;
    dy = fwd.Y;
    len = RFC_VehLen2(dx, dy);
  }

  if len < 0.001 {
    dx = 0.0;
    dy = 1.0;
    len = 1.0;
  }

  dx /= len;
  dy /= len;

  let out: Vector4 = hitPos;
  out.X = hitPos.X + dx * 2.0;
  out.Y = hitPos.Y + dy * 2.0;
  out.Z = hitPos.Z;
  return out;
}

private func RFC_VehExplosionFlipBite(
  vehicle: ref<VehicleObject>,
  hitPos: Vector4,
  srcPos: Vector4,
  strength: Float,
  lift: Float,
  radius: Float,
  cfg: RFCConfig
) -> Void {
  if !IsDefined(vehicle) { return; }
  if RFC_TimeDilationBlocksImpulses(vehicle, cfg) { return; }
  if strength == 0.0 && lift == 0.0 { return; }

  let center: Vector4 = vehicle.GetWorldPosition();
  let dx: Float = center.X - srcPos.X;
  let dy: Float = center.Y - srcPos.Y;
  let len: Float = MaxF(0.001, RFC_VehLen2(dx, dy));
  let nx: Float = dx / len;
  let ny: Float = dy / len;

  let massScale: Float = RFC_VehMassScale(vehicle, cfg);
  let biteH: Float = strength * 0.55 * massScale;
  let biteZ: Float = lift * massScale;

  // Main off-center vertical bite. Up and Down are positive menu values;
  // Types stores their signed difference before this path runs.
  RFC_VehApplyPhysicalImpulseVector(vehicle, hitPos, nx * biteH, ny * biteH, biteZ, MaxF(radius, 3.0), cfg);

  // Add a small side bite at a nearby edge point to help flipped cars rotate.
  let fwd: Vector4 = vehicle.GetWorldForward();
  let sideX: Float = -fwd.Y;
  let sideY: Float = fwd.X;
  let sideLen: Float = MaxF(0.001, RFC_VehLen2(sideX, sideY));

  let edge: Vector4 = center;
  edge.X = center.X + (sideX / sideLen) * 1.15;
  edge.Y = center.Y + (sideY / sideLen) * 1.15;
  edge.Z = hitPos.Z;
  RFC_VehApplyPhysicalImpulseVector(vehicle, edge, nx * biteH * 0.35, ny * biteH * 0.35, biteZ * 0.55, MaxF(radius, 2.5), cfg);
}

private func RFC_VehApplyExplosionRadialImpulse(
  vehicle: ref<VehicleObject>,
  targetPos: Vector4,
  srcPos: Vector4,
  strength: Float,
  lift: Float,
  radius: Float,
  cfg: RFCConfig
) -> Void {
  if !IsDefined(vehicle) { return; }
  if RFC_TimeDilationBlocksImpulses(vehicle, cfg) { return; }
  if strength == 0.0 && lift == 0.0 { return; }

  // Ground-relative radial blast:
  //   X/Y = away from blast center across the ground plane.
  //   Z   = signed world vertical force from positive Up minus positive Down.
  // The previous 3D target-source vector could point downward when the car was
  // upside down or when the reported hit point was below the attack position.
  let rx: Float = targetPos.X - srcPos.X;
  let ry: Float = targetPos.Y - srcPos.Y;
  let planarLen: Float = RFC_VehLen2(rx, ry);

  if planarLen < 0.001 {
    let fwd: Vector4 = vehicle.GetWorldForward();
    rx = fwd.X;
    ry = fwd.Y;
    planarLen = RFC_VehLen2(rx, ry);
  }

  if planarLen < 0.001 {
    rx = 0.0;
    ry = 1.0;
    planarLen = 1.0;
  }

  rx /= planarLen;
  ry /= planarLen;

  let massScale: Float = RFC_VehMassScale(vehicle, cfg);
  let radial: Float = strength * massScale;
  let up: Float = lift * massScale;

  let finalX: Float = rx * radial;
  let finalY: Float = ry * radial;
  let finalZ: Float = up;

  let horizontal: Float = SqrtF(finalX * finalX + finalY * finalY);

  if cfg.vehicleImpulseClampEnabled {
    let maxH: Float = MaxF(0.0, cfg.vehicleImpulseMaxHorizontal);
    let maxZ: Float = MaxF(0.0, cfg.vehicleImpulseMaxLift);

    if horizontal > maxH && horizontal > 0.001 {
      let hScale: Float = maxH / horizontal;
      finalX *= hScale;
      finalY *= hScale;
    }

    finalZ = RFC_VehClampF(finalZ, -maxZ, maxZ);
  }

  let impulse: Vector3;
  impulse.X = finalX;
  impulse.Y = finalY;
  impulse.Z = finalZ;

  let pos: Vector3;
  pos.X = targetPos.X;
  pos.Y = targetPos.Y;
  pos.Z = targetPos.Z;

  RFC_VehScheduleSelfRightingKill(vehicle);

  let e: ref<PhysicalImpulseEvent> = new PhysicalImpulseEvent();
  e.worldImpulse = impulse;
  e.worldPosition = pos;
  e.radius = MaxF(0.05, radius);
  vehicle.QueueEvent(e);
}

private func RFC_VehApplyExplosionMultiPointImpulse(
  vehicle: ref<VehicleObject>,
  hitPos: Vector4,
  srcPos: Vector4,
  strength: Float,
  lift: Float,
  radius: Float,
  cfg: RFCConfig
) -> Void {
  if !IsDefined(vehicle) { return; }
  if RFC_TimeDilationBlocksImpulses(vehicle, cfg) { return; }
  if strength == 0.0 && lift == 0.0 { return; }

  let center: Vector4 = vehicle.GetWorldPosition();

  // Explosion direction is ground/world-relative, not car-local. This avoids
  // upside-down cars getting shoved down because their local up vector is flipped.
  let rx: Float = center.X - srcPos.X;
  let ry: Float = center.Y - srcPos.Y;
  let rLen: Float = RFC_VehLen2(rx, ry);

  let nx: Float = rx;
  let ny: Float = ry;
  if rLen < 0.001 {
    let fwd0: Vector4 = vehicle.GetWorldForward();
    nx = fwd0.X;
    ny = fwd0.Y;
  } else {
    nx /= rLen;
    ny /= rLen;
  }

  let nLen: Float = MaxF(0.001, RFC_VehLen2(nx, ny));
  nx /= nLen;
  ny /= nLen;

  // Build flat forward/right axes. Use world-space flattened vectors only.
  let fwd: Vector4 = vehicle.GetWorldForward();
  let fx: Float = fwd.X;
  let fy: Float = fwd.Y;
  let fLen: Float = RFC_VehLen2(fx, fy);
  if fLen < 0.001 {
    fx = nx;
    fy = ny;
  } else {
    fx /= fLen;
    fy /= fLen;
  }

  let sx: Float = -fy;
  let sy: Float = fx;

  let massScale: Float = RFC_VehMassScale(vehicle, cfg);
  let h: Float = strength * massScale;
  // Respect the user sliders exactly: strength controls horizontal and the signed
  // Up-minus-Down value controls Z. Do not add hidden vertical force from strength.
  let z: Float = lift * massScale;
  let r: Float = MaxF(0.05, radius);

  // Real bullet hits work because they hit off-center. For explosions, synthesize
  // several bullet-style off-center positions around the vehicle so flipped cars
  // get torque instead of a useless center-of-mass shove.
  let front: Vector4 = center;
  front.X = center.X + fx * 1.85;
  front.Y = center.Y + fy * 1.85;
  front.Z = hitPos.Z;

  let rear: Vector4 = center;
  rear.X = center.X - fx * 1.85;
  rear.Y = center.Y - fy * 1.85;
  rear.Z = hitPos.Z;

  let left: Vector4 = center;
  left.X = center.X + sx * 1.35;
  left.Y = center.Y + sy * 1.35;
  left.Z = hitPos.Z;

  let right: Vector4 = center;
  right.X = center.X - sx * 1.35;
  right.Y = center.Y - sy * 1.35;
  right.Z = hitPos.Z;

  // Split one slider-controlled explosion shove across off-center points.
  // Fractions sum to 1.0 so the vehicle explosion sliders remain predictable.
  RFC_VehApplyPhysicalImpulseVector(vehicle, hitPos, nx * h * 0.40, ny * h * 0.40, z * 0.40, r, cfg);
  RFC_VehApplyPhysicalImpulseVector(vehicle, front,  nx * h * 0.15, ny * h * 0.15, z * 0.15, r, cfg);
  RFC_VehApplyPhysicalImpulseVector(vehicle, rear,   nx * h * 0.15, ny * h * 0.15, z * 0.15, r, cfg);
  RFC_VehApplyPhysicalImpulseVector(vehicle, left,   nx * h * 0.15, ny * h * 0.15, z * 0.15, r, cfg);
  RFC_VehApplyPhysicalImpulseVector(vehicle, right,  nx * h * 0.15, ny * h * 0.15, z * 0.15, r, cfg);
}

private func RFC_VehCanFire(vehicle: ref<VehicleObject>, cfg: RFCConfig) -> Bool {
  if !IsDefined(vehicle) { return false; }
  if cfg.vehicleImpulseCooldown <= 0.0 { return true; }

  let nowT: Float = EngineTime.ToFloat(GameInstance.GetSimTime(vehicle.GetGame()));
  if vehicle.rfc_vehicleImpulseLastT <= 0.0 || nowT - vehicle.rfc_vehicleImpulseLastT >= cfg.vehicleImpulseCooldown {
    vehicle.rfc_vehicleImpulseLastT = nowT;
    return true;
  }
  return false;
}

private func RFC_VehTryApply(vehicle: ref<VehicleObject>, evt: ref<gameHitEvent>, cfg: RFCConfig) -> Void {
  if !IsDefined(vehicle) || !IsDefined(evt) || !IsDefined(evt.attackData) { return; }

  // SPLAT_BIKE_TOPPLE_INTERNAL_V8_9_ROUTE
  let smbtfBike: ref<BikeObject> = vehicle as BikeObject;
  if IsDefined(smbtfBike) {
    let smbtfSource: RFCVehicleHitSource = RFC_VehClassifySource(evt.attackData);
    switch smbtfSource {
      case RFCVehicleHitSource.Bullet:
        RFC_BikeBulletThresholdHandle(smbtfBike, evt, cfg);
        return;
    }
  }

  // Runtime kill for built-in air/tilt self-righting. This does not affect normal NPC bullet damage.
  RFC_VehScheduleSelfRightingKill(vehicle);

  // This is independent from whether vehicle impulses are enabled: even if the
  // car shove is off, SPLAT NPC impulse lanes must not launch mounted occupants.
  if cfg.killImpulsesVehiclesOnly {
    RFC_VehMarkAllOccupants(vehicle, 4.0);
  }

  if !cfg.vehicleImpulseEnabled { return; }

  let ad: ref<AttackData> = evt.attackData;
  let source: RFCVehicleHitSource = RFC_VehClassifySource(ad);

  switch source {
    case RFCVehicleHitSource.Bullet:
      if cfg.vehicleBulletPlayerOnly && !RFC_VehPassesPlayerOnly(vehicle, ad, source) {
        return;
      }
      break;

    case RFCVehicleHitSource.Explosion:
      if cfg.vehicleExplosionPlayerOnly && !RFC_VehPassesPlayerOnly(vehicle, ad, source) {
        return;
      }
      break;

    case RFCVehicleHitSource.Melee:
      if cfg.vehicleImpulsePlayerOnly && !RFC_VehPassesPlayerOnly(vehicle, ad, source) {
        return;
      }
      break;
  }

  if !RFC_VehCanFire(vehicle, cfg) { return; }

  let srcPos: Vector4 = ad.GetAttackPosition();
  let hitPos: Vector4 = evt.hitPosition;

  // For bullets and melee, push away from the attacker. For explosions, keep
  // the blast/attack position so grenades throw cars away from the blast center.
  if RFC_VehSourceUsesInstigator(source) {
    let inst: ref<GameObject> = ad.GetInstigator();
    if IsDefined(inst) {
      srcPos = inst.GetWorldPosition();
    }
  }

  // Bad/zero attack positions make blasts choose a useless direction. Fall back
  // to the actual hit point so the push still has a usable direction.
  if RFC_VehIsBadPos(srcPos) {
    srcPos = hitPos;
  }

  switch source {
    case RFCVehicleHitSource.Explosion:
      if RFC_GrenadeExceptionMatches(ad, cfg) { return; }
      if !cfg.vehicleExplosionEnabled { return; }
      if cfg.vehicleExplosionRadius <= 0.0 { return; }
      let eMul: Float = RFC_VehExplosionMul(ad, cfg);
      if eMul <= 0.0 { return; }

      // Explosions were too centered: upright cars moved, but upside-down cars
      // often failed to flip because the impulse hit the center of mass instead
      // of biting a wheel/door/hood point. Bullets work better because they use
      // PhysicalImpulseEvent at the actual hit point, creating torque. Do the
      // same first for grenades/explosions, then add a smaller center catch.
      let centerPos: Vector4 = vehicle.GetWorldPosition();
      srcPos = RFC_VehChooseExplosionSource(vehicle, ad, hitPos);

      // If the engine reports the blast source at/near the vehicle or hit point,
      // synthesize a bullet-style source outside the hit point. Do not fall back
      // to the player for grenades: that made the direction unrelated to the
      // actual blast and failed often on upside-down cars.
      srcPos = RFC_VehExplosionFallbackSource(vehicle, hitPos, srcPos);

      // Restore the true radial blast as the main vehicle explosion response.
      // Sixty percent catches and throws the whole vehicle away from the blast
      // center; forty percent stays in the existing off-center multipoint lane
      // to preserve wheel/door/roof torque. The two shares total 100 percent of
      // the configured force and lift, so the sliders remain predictable.
      RFC_VehApplyExplosionRadialImpulse(
        vehicle,
        centerPos,
        srcPos,
        cfg.vehicleExplosionStrength * eMul * 0.60,
        cfg.vehicleExplosionLift * eMul * 0.60,
        cfg.vehicleExplosionRadius,
        cfg
      );
      RFC_VehApplyExplosionMultiPointImpulse(
        vehicle,
        hitPos,
        srcPos,
        cfg.vehicleExplosionStrength * eMul * 0.40,
        cfg.vehicleExplosionLift * eMul * 0.40,
        cfg.vehicleExplosionRadius,
        cfg
      );

      // Extra off-center bite only when the car is actually flipped/sideways.
      // Uses the same strength/lift sliders; no hidden lift is added.
      if RFC_VehIsUpsideDown(vehicle) {
        RFC_VehExplosionFlipBite(vehicle, hitPos, srcPos, cfg.vehicleExplosionStrength * eMul, cfg.vehicleExplosionLift * eMul, cfg.vehicleExplosionRadius, cfg);
      }

      return;

    case RFCVehicleHitSource.Bullet:
      if !cfg.vehicleBulletEnabled { return; }
      let gB: RFCVehicleWeaponGroup = RFC_VehWeaponGroup(ad);
      let bMul: Float = 0.0;

      if RFC_VehGroupIsNone(gB) {
        // Vehicle bullet hits often lose the exact WeaponObject. This fallback
        // is why bullets can still move cars at all when the game strips the
        // weapon record from vehicle AttackData. Recognized weapons still use
        // their exact per-gun-group multipliers.
        if !cfg.vehicleAllowUnknownBullet { return; }
        bMul = cfg.vehicleMulUnknownBullet;
      } else {
        if !RFC_VehGroupAllowed(gB, cfg) { return; }
        if cfg.vehicleUseArcadeWeaponFilters && !RFC_VehArcadeGroupAllowed(gB, cfg) { return; }
        bMul = RFC_VehGroupMul(gB, cfg);
        if cfg.vehicleUseArcadeWeaponMultipliers { bMul *= RFC_VehArcadeGroupMul(gB, cfg); }
      }

      if bMul <= 0.0 { return; }
      let bulletLift: Float = cfg.vehicleBulletLift;
      let bulletBike: ref<BikeObject> = vehicle as BikeObject;
      if IsDefined(bulletBike)
        && cfg.vehicleMotorcycleToppleOnBullet
        && bulletLift > 0.0 {
        // The side-topple lane owns motorcycle rotation. Positive vehicle lift
        // here makes the bike and mounted rider hop before the ragdoll handoff.
        bulletLift = 0.0;
      }
      RFC_VehApplyPhysicalImpulse(vehicle, hitPos, srcPos, cfg.vehicleBulletStrength * bMul, bulletLift * bMul, cfg.vehicleBulletRadius, cfg);
      return;

    case RFCVehicleHitSource.Melee:
      if !cfg.vehicleMeleeEnabled { return; }
      let gM: RFCVehicleWeaponGroup = RFC_VehWeaponGroup(ad);
      if RFC_VehGroupIsNone(gM) { return; }
      if !RFC_VehGroupAllowed(gM, cfg) { return; }
      if cfg.vehicleUseArcadeWeaponFilters && !RFC_VehArcadeGroupAllowed(gM, cfg) { return; }
      let mMul: Float = RFC_VehGroupMul(gM, cfg);
      if cfg.vehicleUseArcadeWeaponMultipliers { mMul *= RFC_VehArcadeGroupMul(gM, cfg); }
      if mMul <= 0.0 { return; }
      RFC_VehApplyPhysicalImpulse(vehicle, hitPos, srcPos, cfg.vehicleMeleeStrength * mMul, cfg.vehicleMeleeLift * mMul, cfg.vehicleMeleeRadius, cfg);
      return;
  }
}

@wrapMethod(VehicleObject)
protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
  let cfg: RFCConfig = RFC.Cfg();

  if cfg.vanillaMode {
    return wrappedMethod(evt);
  }

  // SPLAT_BIKE_TOPPLE_INTERNAL_V8_7_WRAPPER_GATE
  let smbtfBikeBulletHit: Bool = false;
  let smbtfWrapperBike: ref<BikeObject> = this as BikeObject;
  if IsDefined(smbtfWrapperBike) && IsDefined(evt) && IsDefined(evt.attackData) {
    switch RFC_VehClassifySource(evt.attackData) {
      case RFCVehicleHitSource.Bullet:
        smbtfBikeBulletHit = true;
        break;
    }
  }

  // Kill built-in air/tilt correction before and after vanilla vehicle hit handling.
  // Some native bike/car paths re-enable these during collision handling.
  if !smbtfBikeBulletHit { RFC_VehScheduleSelfRightingKill(this); }

  // Mark current occupants before and after vanilla vehicle hit processing. This
  // catches delayed NPC impulse events that may fire after the vehicle hit frame.
  if cfg.killImpulsesVehiclesOnly {
    RFC_VehMarkAllOccupants(this, 4.0);
  }

  let res: Bool = wrappedMethod(evt);

  if !smbtfBikeBulletHit { RFC_VehScheduleSelfRightingKill(this); }

  if cfg.killImpulsesVehiclesOnly {
    RFC_VehMarkAllOccupants(this, 4.0);
  }

  RFC_VehTryApply(this, evt, cfg);
  return res;
}
