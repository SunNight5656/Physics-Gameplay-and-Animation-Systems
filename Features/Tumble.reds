module RealisticPush

// Motion-based tumble side selection (no velocity APIs)
@addField(NPCPuppet) public let rfc_tmb_lastPos: Vector4;
@addField(NPCPuppet) public let rfc_tmb_lastT: Float;
@addField(NPCPuppet) public let rfc_tmb_lastSideSign: Float;

// Estimates movement direction using position delta since last call.
// Returns normalized 2D direction (mx,my). Updates trackers.
// If we don't have a prior sample yet, returns false.
private func RFC_TMB_EstimateMove2D(p: ref<NPCPuppet>, out mx: Float, out my: Float) -> Bool {
  let nowT: Float = EngineTime.ToFloat(GameInstance.GetSimTime(p.GetGame()));
  let curPos: Vector4 = p.GetWorldPosition();

  // First sample
  if p.rfc_tmb_lastT <= 0.0 {
    p.rfc_tmb_lastT = nowT;
    p.rfc_tmb_lastPos = curPos;
    mx = 0.0;
    my = 0.0;
    return false;
  }

  let dt: Float = MaxF(0.016, nowT - p.rfc_tmb_lastT);
  let dx: Float = curPos.X - p.rfc_tmb_lastPos.X;
  let dy: Float = curPos.Y - p.rfc_tmb_lastPos.Y;

  // Update trackers
  p.rfc_tmb_lastT = nowT;
  p.rfc_tmb_lastPos = curPos;

  let len: Float = SqrtF(dx * dx + dy * dy);
  if len < 0.01 {
    mx = 0.0;
    my = 0.0;
    return false;
  }

  mx = dx / len;
  my = dy / len;
  return true;
}


public struct RFC_TumbleCfg {
  public let enabled: Bool;
  public let steps: Int32;
  public let startDelay: Float;
  public let stepDelay: Float;
  public let baseForce: Float;
  public let sideRoll: Float;
  public let downBias: Float;
}

private func RFC_TumbleDefaults() -> RFC_TumbleCfg {
  let c: RFC_TumbleCfg;
  c.enabled = true;
  c.steps = 3;
  c.startDelay = 0.25;   
  c.stepDelay = 0.14;
  c.baseForce = 6.0;
  c.sideRoll = 0.55;
  c.downBias = 0.10;
  return c;
}

private func RFC_SafeNormalize(v: Vector4, fallback: Vector4) -> Vector4 {
  let len: Float = Vector4.Length(v);
  if len < 0.0001 { return fallback; };
  return v / len;
}

private func RFC_Up() -> Vector4 {
  return Vector4(0.0, 0.0, 1.0, 0.0);
}

private func RFC_ScheduleTumble_NoRaycast(
  puppet: ref<NPCPuppet>,
  cfg: RFC_TumbleCfg,
  pelvisPos: Vector4,
  chestPos: Vector4,
  headPos: Vector4
) -> Void {

  if puppet == null { return; };
  if !cfg.enabled { return; };

  let game: GameInstance = puppet.GetGame();
  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(game);

  // "Forward" approximation from pelvis->chest
  let fwd: Vector4 = RFC_SafeNormalize(chestPos - pelvisPos, Vector4(0.0, 1.0, 0.0, 0.0));

  // Side direction for rolling
  let side: Vector4 = RFC_SafeNormalize(Vector4.Cross(RFC_Up(), fwd), Vector4(1.0, 0.0, 0.0, 0.0));

  let i: Int32 = 0;
  let t0: Float = MaxF(0.001, cfg.startDelay);

  while i < cfg.steps {

    let alpha: Float = Cast<Float>(i) / MaxF(1.0, Cast<Float>(cfg.steps - 1));
    let decay: Float = LerpF(1.00, 0.25, alpha);

    // Alternate left/right
    let sgn: Float = (i % 2 == 0) ? 1.0 : -1.0;

    // Direction: mostly sideways roll, slight forward, tiny down
    let dir: Vector4 =
      RFC_SafeNormalize(
        (side * (cfg.sideRoll * sgn)) + (fwd * 0.35) + (new Vector4(0.0, 0.0, -cfg.downBias, 0.0)),
        fwd
      );

    let f: Float = cfg.baseForce * decay * RandRangeF(0.92, 1.10);

    let t: Float = t0 + (Cast<Float>(i) * MaxF(0.001, cfg.stepDelay));

    // Pelvis/chest heavy; head last
    ds.DelayEvent(puppet, CreateRagdollApplyImpulseEvent(pelvisPos, dir, f * 1.00), t,        false);
    ds.DelayEvent(puppet, CreateRagdollApplyImpulseEvent(chestPos,  dir, f * 0.75), t + 0.06, false);
    ds.DelayEvent(puppet, CreateRagdollApplyImpulseEvent(headPos,   dir, f * 0.35), t + 0.12, false);

    i += 1;
  };
}


private func RFC_RaycastDown_Ground(
  game: GameInstance,
  from: Vector4,
  downDist: Float,
  out hitPos: Vector4,
  out hitN: Vector4
) -> Bool {

  let sqs: ref<SpatialQueriesSystem> = GameInstance.GetSpatialQueriesSystem(game);
  let to: Vector4 = from + Vector4(0.0, 0.0, -downDist, 0.0);

  let tr: TraceResult;

  // This is the call you got compiling before (adjust group name ONLY if needed)
  if sqs.SyncRaycastByCollisionGroup(from, to, n"Static", tr) {
    hitPos = Vector4(tr.position.X, tr.position.Y, tr.position.Z, 1.0);
    hitN   = Vector4(tr.normal.X,   tr.normal.Y,   tr.normal.Z,   0.0);
    return true;
  };

  return false;
}

private func RFC_SafeNormalize(v: Vector4, fallback: Vector4) -> Vector4 {
  let len: Float = Vector4.Length(v);
  if len < 0.0001 { return fallback; };
  return v / len;
}

private func RFC_Up() -> Vector4 {
  return Vector4(0.0, 0.0, 1.0, 0.0);
}

// gravity projected onto ground plane = downhill
private func RFC_DownSlopeDirFromNormal(n: Vector4) -> Vector4 {
  let nn: Vector4 = RFC_SafeNormalize(n, RFC_Up());
  let g: Vector4 = Vector4(0.0, 0.0, -1.0, 0.0);

  // remove component along normal
  let dn: Float = Vector4.Dot(g, nn);
  let d: Vector4 = g - (nn * dn);

  return RFC_SafeNormalize(d, new Vector4(0.0, 1.0, 0.0, 0.0));
}


private func RFC_ScheduleSideTumble_Torque(
  ds: ref<DelaySystem>,
  p: ref<NPCPuppet>,
  pelvisPos: Vector4,
  chestPos: Vector4,
  headPos: Vector4,
  dirX: Float,
  dirY: Float,
  startDelay: Float,
  stepDelay: Float,
  steps: Int32,
  sideStrength: Float,
  downStrength: Float,
  fwdStrength: Float,
  radius: Float,
  c: RFCConfig
) -> Void {

  if !IsDefined(ds) || p == null { return; };
  if steps <= 0 || radius <= 0.0 { return; };

  let fx: Float = dirX;
  let fy: Float = dirY;
  if AbsF(fx) < 0.0001 && AbsF(fy) < 0.0001 {
    fx = 0.0; fy = 1.0;
  }

  // sideways axis (perpendicular to forward)
  let sx: Float = -fy;
  let sy: Float =  fx;

  // single roll direction (prevents jitter)
  // Choose side based on momentum / ramp downhill (not random)

  let sign: Float = 0.0;

  // 1) Prefer ramp downhill side if we can raycast a ground normal here
  let hitPos: Vector4;
  let hitN: Vector4;
  if RFC_RaycastDown_Ground(p.GetGame(), pelvisPos + Vector4(0.0, 0.0, 0.15, 0.0), 2.00, hitPos, hitN) {
    let downDir: Vector4 = RFC_DownSlopeDirFromNormal(hitN);
    let downhillDot: Float = (downDir.X * sx) + (downDir.Y * sy);
    if AbsF(downhillDot) > 0.05 {
      sign = (downhillDot >= 0.0) ? 1.0 : -1.0;
    }
  }

  // 2) If no clear downhill side, use recent movement relative to “right”
  if AbsF(sign) < 0.5 {
    let mx: Float;
    let my: Float;
    if RFC_TMB_EstimateMove2D(p, mx, my) {
      let mDot: Float = (mx * sx) + (my * sy);
      if AbsF(mDot) > 0.05 {
        sign = (mDot >= 0.0) ? 1.0 : -1.0;
      }
    }
  }

  // 3) Final fallback: reuse last sign, else default to +1
  if AbsF(sign) < 0.5 {
    if AbsF(p.rfc_tmb_lastSideSign) > 0.5 {
      sign = p.rfc_tmb_lastSideSign;
    } else {
      sign = 1.0;
    }
  } else {
    p.rfc_tmb_lastSideSign = sign;
  }

  let i: Int32 = 0;
  while i < steps {

    // ─────────────────────────
    // SMOOTH RAMP-IN (this is the fix)
    // ─────────────────────────
    let tNorm: Float = Cast<Float>(i) / MaxF(1.0, Cast<Float>(steps - 1));
    let ramp: Float = tNorm * tNorm;          // quadratic ease-in
    // let ramp: Float = tNorm * tNorm * tNorm; // cubic (even softer)

    let side: Float = sideStrength * ramp;
    let down: Float = downStrength * ramp;
    let fwd:  Float = fwdStrength  * ramp;

    // ─────────────────────────
    // Torque couple (pelvis vs chest/head)
    // ─────────────────────────
    let pv: Vector4 = Vector4(
      (sx * side * sign + fx * fwd),
      (sy * side * sign + fy * fwd),
      down,
      1.0
    );

    let cv: Vector4 = Vector4(
      (-sx * side * sign + fx * (fwd * 0.55)),
      (-sy * side * sign + fy * (fwd * 0.55)),
      down * 0.85,
      1.0
    );

    let hv: Vector4 = Vector4(
      (-sx * (side * 0.55) * sign + fx * (fwd * 0.35)),
      (-sy * (side * 0.55) * sign + fy * (fwd * 0.35)),
      down * 0.55,
      3.0
    );

    let t: Float = RFC_ClampT(startDelay + (Cast<Float>(i) * stepDelay));

RFC_ApplyGravityBurst(ds, p, pelvisPos, pv, radius, t,                 1, 0.0, false, false);
RFC_ApplyGravityBurst(ds, p, chestPos,  cv, radius, RFC_ClampT(t+0.06), 1, 0.0, false, false);
RFC_ApplyGravityBurst(ds, p, headPos,   hv, radius, RFC_ClampT(t+0.12), 1, 0.0, false, false);

    i += 1;
  }
}

private func RFC_ScheduleGravityRollResolve_Directional(
  ds: ref<DelaySystem>,
  p: ref<NPCPuppet>,
  pelvisPos: Vector4,
  chestPos: Vector4,
  headPos: Vector4,
  dirX: Float,
  dirY: Float,
  startDelay: Float,
  stepDelay: Float,
  steps: Int32,
  sideStrength: Float,
  downStrength: Float,
  radius: Float,
  c: RFCConfig
) -> Void {

  if !IsDefined(ds) || p == null { return; };

  let fx: Float = dirX;
  let fy: Float = dirY;

  let sx: Float = -fy;
  let sy: Float =  fx;

  // Choose side based on momentum (not random)

  let rollSign: Float = 0.0;

  // Use recent movement relative to the “right” axis derived from (dirX,dirY)
  let mx2: Float;
  let my2: Float;
  if RFC_TMB_EstimateMove2D(p, mx2, my2) {
    let mDot2: Float = (mx2 * sx) + (my2 * sy);
    if AbsF(mDot2) > 0.05 {
      rollSign = (mDot2 >= 0.0) ? 1.0 : -1.0;
    }
  }

  // Fallback: reuse last sign, else default to +1
  if AbsF(rollSign) < 0.5 {
    if AbsF(p.rfc_tmb_lastSideSign) > 0.5 {
      rollSign = p.rfc_tmb_lastSideSign;
    } else {
      rollSign = 1.0;
    }
  } else {
    p.rfc_tmb_lastSideSign = rollSign;
  }

  let i: Int32 = 0;
  while i < steps {

let n: Float = Cast<Float>(i) / MaxF(1.0, Cast<Float>(steps - 1));
let ramp: Float = n * n;               // ease-in
let decay: Float = LerpF(0.10, 1.0, ramp); // starts gentle, ends strong

    let pv: Vector4 = Vector4(
      sx * sideStrength * rollSign * decay,
      sy * sideStrength * rollSign * decay,
      downStrength * decay,
      1.0
    );

    let cv: Vector4 = Vector4(
      -sx * sideStrength * rollSign * decay,
      -sy * sideStrength * rollSign * decay,
      downStrength * 0.85 * decay,
      1.0
    );

    let t: Float = RFC_ClampT(startDelay + Cast<Float>(i) * stepDelay);

    RFC_Burst(ds, p, pelvisPos, pv, radius, t, c);
    RFC_Burst(ds, p, chestPos,  cv, radius, RFC_ClampT(t + 0.06), c);

    i += 1;
  }
}