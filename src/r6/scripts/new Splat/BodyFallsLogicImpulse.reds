module RealisticPush

private func RFC_SitOverrideBodyBlock(p: wref<NPCPuppet>, c: RFCConfig) -> Bool {
  if !IsDefined(p) { return false; }

  if p.gs_sitSnapValid {
    if p.gs_sitSnapWsStand && c.overrideWsStand && (c.wsStand_overrideGlobalForward || c.wsStand_overrideGlobalChest || c.wsStand_overrideGlobalPelvis || c.wsStand_overrideGlobalKnees) { return true; }
    if p.gs_sitSnapStairs && c.overrideStairs && (c.stair_overrideGlobalForward || c.stair_overrideGlobalChest || c.stair_overrideGlobalPelvis || c.stair_overrideGlobalKnees) { return true; }
    if p.gs_sitSnapCower && c.overrideCower && (c.cow_overrideGlobalForward || c.cow_overrideGlobalChest || c.cow_overrideGlobalPelvis || c.cow_overrideGlobalKnees) { return true; }
    if p.gs_sitSnapRun && c.overrideRun && (c.run_overrideGlobalForward || c.run_overrideGlobalChest || c.run_overrideGlobalPelvis || c.run_overrideGlobalKnees) { return true; }
    if p.gs_sitSnapStand && c.overrideStand && (c.st_overrideGlobalForward || c.st_overrideGlobalChest || c.st_overrideGlobalPelvis || c.st_overrideGlobalKnees) { return true; }
  }

  return false;
}

private func GS_OverrideForwardActive(
  isStand: Bool,
  isRun: Bool,
  isCower: Bool,
  isStairs: Bool,
  isWsStand: Bool,
  c: RFCConfig
) -> Bool {
  if isStairs && c.overrideStairs && c.stair_overrideGlobalForward { return true; }
  if isWsStand && c.overrideWsStand && c.wsStand_overrideGlobalForward { return true; }
  if isCower && c.overrideCower && c.cow_overrideGlobalForward { return true; }
  if isRun && c.overrideRun && c.run_overrideGlobalForward { return true; }
  if isStand && c.overrideStand && c.st_overrideGlobalForward { return true; }
  return false;
}

private func GS_OverrideChestActive(
  isStand: Bool,
  isRun: Bool,
  isCower: Bool,
  isStairs: Bool,
  isWsStand: Bool,
  c: RFCConfig
) -> Bool {
  if isStairs && c.overrideStairs && c.stair_overrideGlobalChest { return true; }
  if isWsStand && c.overrideWsStand && c.wsStand_overrideGlobalChest { return true; }
  if isCower && c.overrideCower && c.cow_overrideGlobalChest { return true; }
  if isRun && c.overrideRun && c.run_overrideGlobalChest { return true; }
  if isStand && c.overrideStand && c.st_overrideGlobalChest { return true; }
  return false;
}

private func GS_OverridePelvisActive(
  isStand: Bool,
  isRun: Bool,
  isCower: Bool,
  isStairs: Bool,
  isWsStand: Bool,
  c: RFCConfig
) -> Bool {
  if isStairs && c.overrideStairs && c.stair_overrideGlobalPelvis { return true; }
  if isWsStand && c.overrideWsStand && c.wsStand_overrideGlobalPelvis { return true; }
  if isCower && c.overrideCower && c.cow_overrideGlobalPelvis { return true; }
  if isRun && c.overrideRun && c.run_overrideGlobalPelvis { return true; }
  if isStand && c.overrideStand && c.st_overrideGlobalPelvis { return true; }
  return false;
}

private func GS_OverrideKneesActive(
  isStand: Bool,
  isRun: Bool,
  isCower: Bool,
  isStairs: Bool,
  isWsStand: Bool,
  c: RFCConfig
) -> Bool {
  if isStairs && c.overrideStairs && c.stair_overrideGlobalKnees { return true; }
  if isWsStand && c.overrideWsStand && c.wsStand_overrideGlobalKnees { return true; }
  if isCower && c.overrideCower && c.cow_overrideGlobalKnees { return true; }
  if isRun && c.overrideRun && c.run_overrideGlobalKnees { return true; }
  if isStand && c.overrideStand && c.st_overrideGlobalKnees { return true; }
  return false;
}

private func GS_OverrideHeadActive(
  isStand: Bool,
  isRun: Bool,
  isCower: Bool,
  isStairs: Bool,
  isWsStand: Bool,
  c: RFCConfig
) -> Bool {
  if isStairs && c.overrideStairs && c.stair_overrideGlobalHead { return true; }
  if isCower && c.overrideCower && c.cow_overrideGlobalHead { return true; }
  if isRun && c.overrideRun && c.run_overrideGlobalHead { return true; }
  if isStand && c.overrideStand && c.st_overrideGlobalHead { return true; }
  return false;
}

private func GS_IsWsStandCurrent(p: wref<NPCPuppet>) -> Bool {
  return RFC_IsWorkspotOrPerch(p);
}

private func GS_IsStairsCurrent(p: wref<NPCPuppet>) -> Bool {
  if GS_IsWsStandCurrent(p) { return false; }
  return RFC_IsOnStairs(p) || p.RFC_WasStairsRecent(1.25);
}

private func GS_IsCowerCurrent(p: wref<NPCPuppet>) -> Bool {
  if GS_IsWsStandCurrent(p) { return false; }
  if GS_IsStairsCurrent(p) { return false; }
  return RFC_IsCoweringStrict(p);
}

private func GS_IsRunCurrent(p: wref<NPCPuppet>) -> Bool {
  let nowT: Float;
  let vv: Vector4;
  let planar: Float;
  let isRunLive: Bool;
  let isWalkLive: Bool;

  if GS_IsWsStandCurrent(p) { return false; }
  if GS_IsStairsCurrent(p) { return false; }
  if GS_IsCowerCurrent(p) { return false; }

  nowT = EngineTime.ToFloat(GameInstance.GetSimTime(p.GetGame()));
  vv = p.GetVelocity();
  planar = SqrtF(vv.X * vv.X + vv.Y * vv.Y);

  if planar > 20.0 {
    planar *= 0.01;
  }

  isRunLive = planar > 1.55;
  isWalkLive = planar > 0.12 && planar <= 1.55;

  if RFC_IsRunning(p) || isRunLive {
    return true;
  }

  if RFC_IsClearlyWalking(p) || RFC_IsWalking(p) || isWalkLive {
    return true;
  }

  if p.RFC_WasRunningRecent(1.25) {
    return true;
  }

  if p.rfc_walkLastSeen > 0.0 && (nowT - p.rfc_walkLastSeen) <= 1.25 {
    return true;
  }

  return false;
}

private func GS_IsStandCurrent(p: wref<NPCPuppet>) -> Bool {
  if GS_IsWsStandCurrent(p) { return false; }
  if GS_IsStairsCurrent(p) { return false; }
  if GS_IsCowerCurrent(p) { return false; }
  if GS_IsRunCurrent(p) { return false; }
  return true;
}

public func GS_CurrentOverrideForward(p: wref<NPCPuppet>, c: RFCConfig) -> Bool {
  let isStand: Bool;
  let isRun: Bool;
  let isCower: Bool;
  let isStairs: Bool;
  let isWsStand: Bool;

  if p.gs_sitSnapValid {
    isStand = p.gs_sitSnapStand;
    isRun = p.gs_sitSnapRun;
    isCower = p.gs_sitSnapCower;
    isStairs = p.gs_sitSnapStairs;
    isWsStand = p.gs_sitSnapWsStand;
  } else {
    isStand = GS_IsStandCurrent(p);
    isRun = GS_IsRunCurrent(p);
    isCower = GS_IsCowerCurrent(p);
    isStairs = GS_IsStairsCurrent(p);
    isWsStand = GS_IsWsStandCurrent(p);
  }

  return GS_OverrideForwardActive(
    isStand,
    isRun,
    isCower,
    isStairs,
    isWsStand,
    c
  );
}

public func GS_CurrentOverrideChest(p: wref<NPCPuppet>, c: RFCConfig) -> Bool {
  let isStand: Bool;
  let isRun: Bool;
  let isCower: Bool;
  let isStairs: Bool;
  let isWsStand: Bool;

  if p.gs_sitSnapValid {
    isStand = p.gs_sitSnapStand;
    isRun = p.gs_sitSnapRun;
    isCower = p.gs_sitSnapCower;
    isStairs = p.gs_sitSnapStairs;
    isWsStand = p.gs_sitSnapWsStand;
  } else {
    isStand = GS_IsStandCurrent(p);
    isRun = GS_IsRunCurrent(p);
    isCower = GS_IsCowerCurrent(p);
    isStairs = GS_IsStairsCurrent(p);
    isWsStand = GS_IsWsStandCurrent(p);
  }

  return GS_OverrideChestActive(
    isStand,
    isRun,
    isCower,
    isStairs,
    isWsStand,
    c
  );
}

public func GS_CurrentOverridePelvis(p: wref<NPCPuppet>, c: RFCConfig) -> Bool {
  let isStand: Bool;
  let isRun: Bool;
  let isCower: Bool;
  let isStairs: Bool;
  let isWsStand: Bool;

  if p.gs_sitSnapValid {
    isStand = p.gs_sitSnapStand;
    isRun = p.gs_sitSnapRun;
    isCower = p.gs_sitSnapCower;
    isStairs = p.gs_sitSnapStairs;
    isWsStand = p.gs_sitSnapWsStand;
  } else {
    isStand = GS_IsStandCurrent(p);
    isRun = GS_IsRunCurrent(p);
    isCower = GS_IsCowerCurrent(p);
    isStairs = GS_IsStairsCurrent(p);
    isWsStand = GS_IsWsStandCurrent(p);
  }

  return GS_OverridePelvisActive(
    isStand,
    isRun,
    isCower,
    isStairs,
    isWsStand,
    c
  );
}

public func GS_CurrentOverrideKnees(p: wref<NPCPuppet>, c: RFCConfig) -> Bool {
  let isStand: Bool;
  let isRun: Bool;
  let isCower: Bool;
  let isStairs: Bool;
  let isWsStand: Bool;

  if p.gs_sitSnapValid {
    isStand = p.gs_sitSnapStand;
    isRun = p.gs_sitSnapRun;
    isCower = p.gs_sitSnapCower;
    isStairs = p.gs_sitSnapStairs;
    isWsStand = p.gs_sitSnapWsStand;
  } else {
    isStand = GS_IsStandCurrent(p);
    isRun = GS_IsRunCurrent(p);
    isCower = GS_IsCowerCurrent(p);
    isStairs = GS_IsStairsCurrent(p);
    isWsStand = GS_IsWsStandCurrent(p);
  }

  return GS_OverrideKneesActive(
    isStand,
    isRun,
    isCower,
    isStairs,
    isWsStand,
    c
  );
}

public func GS_CurrentOverrideHead(p: wref<NPCPuppet>, c: RFCConfig) -> Bool {
  let isStand: Bool;
  let isRun: Bool;
  let isCower: Bool;
  let isStairs: Bool;
  let isWsStand: Bool;

  if !IsDefined(p) { return false; }

  if p.gs_sitSnapValid {
    isStand = p.gs_sitSnapStand;
    isRun = p.gs_sitSnapRun;
    isCower = p.gs_sitSnapCower;
    isStairs = p.gs_sitSnapStairs;
    isWsStand = p.gs_sitSnapWsStand;
  } else {
    isStand = GS_IsStandCurrent(p);
    isRun = GS_IsRunCurrent(p);
    isCower = GS_IsCowerCurrent(p);
    isStairs = GS_IsStairsCurrent(p);
    isWsStand = GS_IsWsStandCurrent(p);
  }

  return GS_OverrideHeadActive(
    isStand,
    isRun,
    isCower,
    isStairs,
    isWsStand,
    c
  );
}

@addField(NPCPuppet) private let gs_sitSnapValid: Bool;
@addField(NPCPuppet) private let gs_sitSnapStand: Bool;
@addField(NPCPuppet) private let gs_sitSnapRun: Bool;
@addField(NPCPuppet) private let gs_sitSnapCower: Bool;
@addField(NPCPuppet) private let gs_sitSnapStairs: Bool;
@addField(NPCPuppet) private let gs_sitSnapWsStand: Bool;

public func GS_ClearSituationSnap(p: ref<NPCPuppet>) -> Void {
  if !IsDefined(p) { return; }
  p.gs_sitSnapValid = false;
  p.gs_sitSnapStand = false;
  p.gs_sitSnapRun = false;
  p.gs_sitSnapCower = false;
  p.gs_sitSnapStairs = false;
  p.gs_sitSnapWsStand = false;
}

public func GS_CaptureSituationSnap(p: ref<NPCPuppet>) -> Void {
  if !IsDefined(p) { return; }

  p.gs_sitSnapWsStand = GS_IsWsStandCurrent(p);
  p.gs_sitSnapStairs = !p.gs_sitSnapWsStand && GS_IsStairsCurrent(p);
  p.gs_sitSnapCower = !p.gs_sitSnapWsStand && !p.gs_sitSnapStairs && GS_IsCowerCurrent(p);
  p.gs_sitSnapRun = !p.gs_sitSnapWsStand && !p.gs_sitSnapStairs && !p.gs_sitSnapCower && GS_IsRunCurrent(p);
  p.gs_sitSnapStand = !p.gs_sitSnapWsStand && !p.gs_sitSnapStairs && !p.gs_sitSnapCower && !p.gs_sitSnapRun;
  p.gs_sitSnapValid = true;
}

private func GS_HardBlockImpulse(p: wref<NPCPuppet>) -> Bool {
  let gPos: Vector4;
  let gN: Vector4;
  let probe: Vector4;
  let h: Float;

  if !IsDefined(p) { return true; }
  if RFC_IsVehicleContext(p) { return true; }
  if RFC_Explode_IsRecent(p) { return true; }

  probe = p.GetWorldPosition();
  probe.Z += 0.45;

  if !RFC_RaycastDown_Ground(p.GetGame(), probe, 2.5, gPos, gN) {
    return true;
  }

  h = MaxF(0.0, probe.Z - gPos.Z);
  if h > 0.95 {
    return true;
  }

  return false;
}

private func GS_Clamp01(v: Float) -> Float {
  if v < 0.0 { return 0.0; }
  if v > 1.0 { return 1.0; }
  return v;
}

private func GS_Clamp(v: Float, lo: Float, hi: Float) -> Float {
  if v < lo { return lo; }
  if v > hi { return hi; }
  return v;
}

private func GS_RollChancePct(pct: Float) -> Bool {
  let c01: Float = GS_Clamp01(pct / 100.0);
  if c01 <= 0.0 { return false; }
  if c01 >= 1.0 { return true; }
  return RandF() < c01;
}

private func GS_StrengthToZ(pct: Float, s: ref<GS_Settings>) -> Float {
  let zBase: Float = GS_Pos(pct);

  if s.extremeMode {
    return zBase * GS_Pos(s.extremeMult);
  }

  return zBase;
}

private func GS_ApplyBodyOnlyMode(
  p: wref<NPCPuppet>,
  zMag: Float,
  radiusM: Float,
  zOffset: Float,
  s: ref<GS_Settings>
) -> Void {
  let imp: Vector4;

  if !IsDefined(p) { return; }

  imp = new Vector4(
    0.0,
    0.0,
    -GS_Pos(zMag),
    1.0
  );

  GS_ApplyImpulse(p, imp, radiusM, zOffset);
}

private func GS_StrengthToF(val: Float, s: ref<GS_Settings>) -> Float {
  return GS_Pos(val);
}

private func GS_EaseIn(t: Float) -> Float {
  let x: Float = GS_Clamp01(t);
  return x * x;
}

private func GS_ShouldRun(p: wref<NPCPuppet>, s: ref<GS_Settings>) -> Bool {
  let chance01: Float;
  let roll: Float;
  let c: RFCConfig;

  if !IsDefined(p) { return false; }
  c = RFC.Cfg();
  if !RFC_RandomAllowBody(p, c) { return false; }
  if !s.useChance { return true; }

  if p.gs_rollDone {
    return p.gs_rollOK;
  }

  p.gs_rollDone = true;

  chance01 = GS_Clamp01(s.chancePct / 100.0);
  if chance01 <= 0.0 { p.gs_rollOK = false; return false; }
  if chance01 >= 1.0 { p.gs_rollOK = true; return true; }

  roll = RandF();
  p.gs_rollOK = roll < chance01;
  return p.gs_rollOK;
}

private func GS_RollForwardBack(p: wref<NPCPuppet>, s: ref<GS_Settings>) -> Float {
  let c01: Float;
  if !IsDefined(p) { return 1.0; }

  if p.gs_fbDone {
    return p.gs_fbSign;
  }

  p.gs_fbDone = true;

  c01 = GS_Clamp01(s.forwardChancePct / 100.0);
  if RandF() < c01 {
    p.gs_fbSign = 1.0;
  } else {
    p.gs_fbSign = -1.0;
  }

  return p.gs_fbSign;
}

private func GS_GetForwardDirMode(
  p: wref<NPCPuppet>,
  useFacing: Bool,
  useCached: Bool,
  s: ref<GS_Settings>
) -> Vector4 {
  let dir: Vector4;
  let v: Vector4;
  let len: Float;

  if !IsDefined(p) {
    return new Vector4(0.0, 1.0, 0.0, 0.0);
  }

  if useFacing {
    dir = p.GetWorldForward();
  } else {
    if useCached && p.gs_vel2D > 0.05 {
      dir = p.gs_dir2D;
    } else {
      v = p.GetVelocity();
      v.Z = 0.0;
      len = Vector4.Length(v);
      if len > 0.05 {
        dir = v / len;
      } else {
        dir = p.GetWorldForward();
      }
    }
  }

  dir.Z = 0.0;
  len = Vector4.Length(dir);
  if len <= 0.001 {
    return new Vector4(0.0, 1.0, 0.0, 0.0);
  }

  return dir / len;
}

private func GS_GetForwardDir(p: wref<NPCPuppet>, s: ref<GS_Settings>) -> Vector4 {
  return GS_GetForwardDirMode(p, s.forwardUseFacing, s.forwardUseCached, s);
}

private func GS_CacheMomentum(p: wref<NPCPuppet>, s: ref<GS_Settings>) -> Void {
  let v: Vector4;
  let len: Float;
  if !IsDefined(p) { return; }

  v = p.GetVelocity();
  v.Z = 0.0;
  len = Vector4.Length(v);
  p.gs_vel2D = len;

  if len > 0.05 {
    p.gs_dir2D = v / len;
  } else {
    p.gs_dir2D = p.GetWorldForward();
    p.gs_dir2D.Z = 0.0;
    len = Vector4.Length(p.gs_dir2D);
    if len > 0.001 {
      p.gs_dir2D = p.gs_dir2D / len;
    } else {
      p.gs_dir2D = new Vector4(0.0, 1.0, 0.0, 0.0);
    }
  }
}

private func GS_MomentumScale(p: wref<NPCPuppet>, s: ref<GS_Settings>) -> Float {
  let v: Float;
  let sc: Float;
  if !s.momentumEnabled { return 1.0; }
  if !IsDefined(p) { return 1.0; }

  v = p.gs_vel2D;
  if v < 0.0 { v = 0.0; }
  sc = 1.0 + (v * GS_Pos(s.momentumMult));
  return sc;
}

private func GS_GetBodyChestPoint(p: wref<NPCPuppet>, fallbackHeight: Float, out pos: Vector4) -> Bool {
  let slotComponent: ref<SlotComponent>;
  let slotTransform: WorldTransform;

  if !IsDefined(p) { return false; }
  slotComponent = p.GetSlotComponent();
  if IsDefined(slotComponent) {
    if slotComponent.GetSlotTransform(n"Spine3", slotTransform) {
      pos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform));
      return true;
    }
    if slotComponent.GetSlotTransform(n"Chest", slotTransform) {
      pos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform));
      return true;
    }
  }

  pos = p.GetWorldPosition();
  pos.Z += fallbackHeight;
  return true;
}

private func GS_GetPointAtHeight(p: wref<NPCPuppet>, height: Float, forwardOffset: Float, s: ref<GS_Settings>) -> Vector4 {
  let pos: Vector4;
  let fDir: Vector4;

  pos = p.GetWorldPosition();
  pos.Z += height;

  fDir = GS_GetForwardDir(p, s);
  pos.X += fDir.X * forwardOffset;
  pos.Y += fDir.Y * forwardOffset;
  return pos;
}

private func GS_ApplyImpulseAtPoint(p: wref<NPCPuppet>, pos: Vector4, impulse: Vector4, radiusM: Float) -> Void {
  if RFC.Cfg().vanillaMode { return; }
  if !IsDefined(p) { return; }
  if RFC_TimeDilationBlocksImpulsesNow(p) { return; }
  if RFC_IsVehicleContext(p) { return; }
  p.QueueEvent(CreateRagdollApplyImpulseEvent(pos, impulse, radiusM));
}

private func GS_ApplyForwardAtPoint(
  p: wref<NPCPuppet>,
  pos: Vector4,
  fMag: Float,
  radiusM: Float,
  s: ref<GS_Settings>,
  reverseDir: Bool
) -> Void {
  let fbSign: Float;
  let fDir: Vector4;
  let imp: Vector4;

  if !IsDefined(p) { return; }

  fbSign = GS_RollForwardBack(p, s);
  if reverseDir {
    fbSign *= -1.0;
  }

  fDir = GS_GetForwardDir(p, s);
  imp = new Vector4(0.0, 0.0, 0.0, 1.0);
  imp.X = fDir.X * (fMag * fbSign);
  imp.Y = fDir.Y * (fMag * fbSign);

  GS_ApplyImpulseAtPoint(p, pos, imp, radiusM);
}

private func GS_ApplyForwardAtPointMode(
  p: wref<NPCPuppet>,
  pos: Vector4,
  fMag: Float,
  radiusM: Float,
  s: ref<GS_Settings>,
  useFacing: Bool,
  useCached: Bool
) -> Void {
  let fDir: Vector4;
  let imp: Vector4;

  if !IsDefined(p) { return; }
  if fMag <= 0.001 { return; }

  fDir = GS_GetForwardDirMode(p, useFacing, useCached, s);
  imp = new Vector4(0.0, 0.0, 0.0, 1.0);
  imp.X = fDir.X * fMag;
  imp.Y = fDir.Y * fMag;

  GS_ApplyImpulseAtPoint(p, pos, imp, radiusM);
}

private func GS_ApplyForwardOnlyMode(
  p: wref<NPCPuppet>,
  fMag: Float,
  radiusM: Float,
  zOffset: Float,
  s: ref<GS_Settings>,
  useFacing: Bool,
  useCached: Bool
) -> Void {
  let pos: Vector4;
  if !IsDefined(p) { return; }
  if !GS_GetBodyChestPoint(p, zOffset, pos) { return; }
  GS_ApplyForwardAtPointMode(p, pos, fMag, radiusM, s, useFacing, useCached);
}

private func GS_Abs(v: Float) -> Float {
  if v < 0.0 { return -v; }
  return v;
}

private func GS_Pos(v: Float) -> Float {
  return GS_Abs(v);
}

private func GS_Dot2(a: Vector4, b: Vector4) -> Float {
  return (a.X * b.X) + (a.Y * b.Y);
}

private func GS_GetRightDirFromForward(fwd: Vector4) -> Vector4 {
  let r: Vector4 = new Vector4(-fwd.Y, fwd.X, 0.0, 0.0);
  let len: Float = Vector4.Length(r);
  if len <= 0.001 {
    return new Vector4(1.0, 0.0, 0.0, 0.0);
  }
  return r / len;
}

private func GS_ApplyImpulse(p: wref<NPCPuppet>, impulse: Vector4, radiusM: Float, zOffset: Float) -> Void {
  let pos: Vector4;
  if !IsDefined(p) { return; }
  let bodyCfg: RFCConfig = RFC.Cfg();
  if bodyCfg.vanillaMode || RFC_TimeDilationBlocksImpulses(p, bodyCfg) { return; }
  if RFC_IsVehicleContext(p) { return; }
  if !GS_GetBodyChestPoint(p, zOffset, pos) { return; }
  p.QueueEvent(CreateRagdollApplyImpulseEvent(pos, impulse, radiusM));
}

private func GS_VertSign(s: ref<GS_Settings>) -> Float {
  return s.reverseGravity ? 1.0 : -1.0;
}

private func GS_ApplyVerticalAndForwardMode(
  p: wref<NPCPuppet>,
  zMag: Float,
  fMag: Float,
  radiusM: Float,
  zOffset: Float,
  s: ref<GS_Settings>,
  useFacing: Bool,
  useCached: Bool
) -> Void {
  let fDir: Vector4;
  let imp: Vector4;

  if !IsDefined(p) { return; }

  imp = new Vector4(0.0, 0.0, -GS_Pos(zMag), 1.0);

  if fMag > 0.001 {
    fDir = GS_GetForwardDirMode(p, useFacing, useCached, s);
    imp.X += fDir.X * fMag;
    imp.Y += fDir.Y * fMag;
  }

  GS_ApplyImpulse(p, imp, radiusM, zOffset);
}

private func GS_ScheduleRamp(
  ds: ref<DelaySystem>,
  p: wref<NPCPuppet>,
  steps: Int32,
  baseDelay: Float,
  rampSec: Float,
  isImpact: Bool
) -> Void {
  let n: Int32;
  let i: Int32;
  let e: ref<Event>;
  let tStep: Float;
  let when: Float;

  if !IsDefined(ds) || !IsDefined(p) { return; }

  n = steps;
  if n < 1 { return; }

  if rampSec <= 0.001 || n == 1 {
    if isImpact {
      e = new GS_ImpactStepEvt();
    } else {
      e = new GS_EarlyStepEvt();
    }
    ds.DelayEvent(p, e, MaxF(0.0, baseDelay), false);
    return;
  }

  tStep = rampSec / Cast<Float>(n);

  i = 0;
  while i < n {
    if isImpact {
      e = new GS_ImpactStepEvt();
    } else {
      e = new GS_EarlyStepEvt();
    }
    when = MaxF(0.0, baseDelay + (Cast<Float>(i) * tStep));
    ds.DelayEvent(p, e, when, false);
    i += 1;
  }
}

@addMethod(NPCPuppet)
protected cb func OnGS_ForwardEvt(e: ref<GS_ForwardEvt>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  let s: ref<GS_Settings> = SPLATSettingsRuntime.Body();
  let fMag: Float;
  let doForward: Bool;

  c = RFC_RandomizeConfig(this, c);
  if c.vanillaMode { return true; }
  
  if !s.enabled { return true; }
  if !s.forwardEnabled { return true; }
  // A matching Situational Forward override replaces only the normal Body
  // Falls forward lane. It does not affect Head Falls or unrelated systems.
  if !this.rfc_allowBodyForward { return true; }
  if !ScriptedPuppet.CanRagdoll(this) { return true; }
  if GS_HardBlockImpulse(this) { return true; }

  doForward = this.gs_forwardDo || s.forwardEnabled;
  if !doForward { return true; }

  fMag = GS_StrengthToF(RFC_RandomBodyValue(this, c, s.forwardStrengthPctMin, s.forwardStrengthPct), s);
  if s.showDebugSettings {
    fMag = GS_Pos(s.debugProofF);
  }

  GS_ApplyForwardOnlyMode(this, fMag, s.forwardRadiusM, 1.00, s, s.forwardUseFacing, s.forwardUseCached);
  return true;
}

@addMethod(NPCPuppet)
protected cb func OnGS_EarlyStepEvt(e: ref<GS_EarlyStepEvt>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  let s: ref<GS_Settings> = SPLATSettingsRuntime.Body();
  let zMagFull: Float;
  let fMagFull: Float;
  let t01: Float;
  let w: Float;
  let doBody: Bool;
  let doForward: Bool;
  let doShoulderWaist: Bool;
  let runMain: Bool;

  c = RFC_RandomizeConfig(this, c);
  if c.vanillaMode { return true; }
  
  runMain = s.enabled
    && s.earlyDropEnabled
    && ScriptedPuppet.CanRagdoll(this)
    && !GS_HardBlockImpulse(this)
    && GS_ShouldRun(this, s);
  doBody = runMain && this.rfc_allowBodyChest;
  doForward = runMain
    && (this.gs_earlyForwardDo || s.earlyDropForwardEnabled)
    && this.rfc_allowBodyForward;
  doShoulderWaist = c.shoulderHipEarlyFallEnabled
    && ((c.shoulderHipEarlyShoulderEnabled && !this.rfc_blockShoulderFalls)
      || (c.shoulderHipEarlyButtEnabled && !this.rfc_blockButtFalls));
  if !doBody && !doForward && !doShoulderWaist { return true; }

  if this.gs_earlyStepMax <= 0 {
    this.gs_earlyStepMax = s.earlyDropSteps;
    this.gs_earlyStepIdx = 0;
  }

  if this.gs_earlyStepMax < 1 { this.gs_earlyStepMax = 1; }

  t01 = 1.0;
  if this.gs_earlyStepMax > 1 {
    t01 = Cast<Float>(this.gs_earlyStepIdx) / Cast<Float>(this.gs_earlyStepMax - 1);
  }

  w = GS_EaseIn(t01);

  zMagFull = GS_StrengthToZ(RFC_RandomBodyValue(this, c, s.earlyDropStrengthPctMin, s.earlyDropStrengthPct), s);
  fMagFull = 0.0;

  if doForward {
    fMagFull = GS_StrengthToF(RFC_RandomBodyValue(this, c, s.earlyDropForwardStrengthPctMin, s.earlyDropForwardStrengthPct), s);
  }

  if s.showDebugSettings {
    zMagFull = GS_Pos(s.debugProofZ);
    if doForward {
      fMagFull = GS_Pos(s.debugProofF);
    }
  }

  w = w * GS_MomentumScale(this, s);

  if doBody {
    GS_ApplyVerticalAndForwardMode(this, zMagFull * w, 0.0, s.earlyDropRadiusM, 1.05, s, s.earlyDropForwardUseFacing, s.earlyDropForwardUseCached);
  }
  if doForward {
    GS_ApplyForwardOnlyMode(this, fMagFull * w, s.earlyDropForwardRadiusM, 1.05, s, s.earlyDropForwardUseFacing, s.earlyDropForwardUseCached);
  }

  if doShoulderWaist && this.gs_earlyStepIdx == 0 {
    RFC_ScheduleShoulderWaistFall(
      this,
      (c.shoulderHipEarlyShoulderEnabled && !this.rfc_blockShoulderFalls) ? c.shoulderHipEarlyShoulderStrength : 0.0,
      (c.shoulderHipEarlyButtEnabled && !this.rfc_blockButtFalls) ? c.shoulderHipEarlyHipStrength : 0.0,
      c.shoulderHipEarlyRadius,
      c.shoulderHipEarlyDelay
    );
  }

  this.gs_earlyStepIdx += 1;
  return true;
}

@addMethod(NPCPuppet)
protected cb func OnGS_ImpactStepEvt(e: ref<GS_ImpactStepEvt>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  let s: ref<GS_Settings> = SPLATSettingsRuntime.Body();
  let zMagFull: Float;
  let fMagFull: Float;
  let t01: Float;
  let w: Float;
  let fMagUse: Float;
  let doBody: Bool;
  let doForward: Bool;
  let runMain: Bool;

  c = RFC_RandomizeConfig(this, c);
  if c.vanillaMode { return true; }
  
  runMain = s.enabled
    && s.impactEnabled
    && ScriptedPuppet.CanRagdoll(this)
    && !GS_HardBlockImpulse(this)
    && GS_ShouldRun(this, s);
  doBody = runMain && this.rfc_allowBodyChest;
  doForward = runMain
    && (this.gs_impactForwardDo || s.impactForwardAlso)
    && this.rfc_allowBodyForward;
  if !doBody && !doForward { return true; }

  if this.gs_impactStepMax <= 0 {
    this.gs_impactStepMax = s.impactSteps;
    this.gs_impactStepIdx = 0;
  }

  if this.gs_impactStepMax < 1 { this.gs_impactStepMax = 1; }

  t01 = 1.0;
  if this.gs_impactStepMax > 1 {
    t01 = Cast<Float>(this.gs_impactStepIdx + 1) / Cast<Float>(this.gs_impactStepMax);
  }

  w = GS_EaseIn(t01);

  zMagFull = GS_StrengthToZ(RFC_RandomBodyValue(this, c, s.impactStrengthPctMin, s.impactStrengthPct), s);
  w = w * GS_MomentumScale(this, s);

  if doForward {
    fMagFull = GS_StrengthToF(RFC_RandomBodyValue(this, c, s.impactForwardStrengthPctMin, s.impactForwardStrengthPct), s);
    fMagUse = fMagFull;
  } else {
    fMagUse = 0.0;
  }

  if s.showDebugSettings && doForward {
    fMagUse = GS_Pos(s.debugProofF);
  }

  if doBody {
    GS_ApplyBodyOnlyMode(this, zMagFull * w, s.impactRadiusM, 0.95, s);
  }

  if doForward {
    GS_ApplyForwardOnlyMode(this, fMagUse, s.impactForwardRadiusM, 0.95, s, s.impactForwardUseFacing, s.impactForwardUseCached);
  }

  this.gs_impactStepIdx += 1;
  return true;
}
