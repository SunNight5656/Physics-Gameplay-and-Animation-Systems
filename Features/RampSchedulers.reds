// r6/scripts/Splat/RampSchedulers.reds
module RealisticPush


private func RFC_USE_LEGACY_RAMP() -> Bool = false;

private func RFC_ApplyGravityBurst(
  ds: ref<DelaySystem>,
  p: wref<NPCPuppet>,
  pos: Vector4,
  baseVec: Vector4,
  radius: Float,
  tStart: Float,
  steps: Int32,
  stepTime: Float,
  reverse: Bool,
  altShape: Bool
) -> Void {
  if !IsDefined(p) || radius <= 0.0 {
    return;
  }

  let s: Int32 = steps < 1 ? 1 : steps;
  if s == 1 {
    let t0: Float = RFC_ClampT(MaxF(tStart, 0.0));
    if t0 <= 0.0 || !IsDefined(ds) {
      p.QueueEvent(CreateRagdollApplyImpulseEvent(pos, baseVec, radius));
    } else {
      ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(pos, baseVec, radius), t0, false);
    }
    return;
  }

  // Defensive: never allow 0 spacing when s > 1
  let dt: Float = stepTime < 0.001 ? 0.001 : stepTime;

  // Floor prevents "nothing then pop" when reverse is ON
  let floor: Float = 0.20;

  // Decay curves
  let decayXY: Float = 0.85;
  let decayZ:  Float = altShape ? 0.93 : 0.85;

  let i: Int32 = 0;
  while i < s {
    // Flip strength if reverse = true (small → big)
    let k: Int32 = reverse ? (s - 1 - i) : i;

    let scXY: Float = MaxF(PowF(decayXY, Cast<Float>(k)), floor);
    let scZ:  Float = MaxF(PowF(decayZ,  Cast<Float>(k)), floor);

    let v: Vector4 = Vector4(
      baseVec.X * scXY,
      baseVec.Y * scXY,
      baseVec.Z * scZ,
      baseVec.W
    );

    let t: Float = RFC_ClampT(MaxF(tStart + Cast<Float>(i) * dt, 0.0));
    if t <= 0.0 || !IsDefined(ds) {
      p.QueueEvent(CreateRagdollApplyImpulseEvent(pos, v, radius));
    } else {
      ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(pos, v, radius), t, false);
    }

    i += 1;
  }
}

private func RFC_Burst(
  ds: ref<DelaySystem>,
  p: wref<NPCPuppet>,
  pos: Vector4,
  vec: Vector4,
  radius: Float,
  tStart: Float,
  c: RFCConfig
) -> Void {
  // One-and-done if ramp disabled
  if !c.ramp.enabled {
    RFC_ApplyGravityBurst(ds, p, pos, vec, radius, tStart, 1, 0.0, false, false);
    return;
  }

  RFC_ApplyGravityBurst(
    ds, p, pos, vec, radius, tStart,
    c.ramp.steps,
    c.ramp.stepTime,
    c.ramp.reverse,
    c.ramp.altShape
  );
}

@addField(NPCPuppet)
public let rfc_runLastSeen: Float;

@addMethod(NPCPuppet)
public func RFC_WasRunningRecent(window: Float) -> Bool {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  return this.rfc_runLastSeen > 0.0 && (now - this.rfc_runLastSeen) <= window;
}

// Canonical ramp scheduler.
// Uses RFCConfig.ramp (global shaping) to smooth out impulse hits so it feels like "gravity" instead of 1 sharp pop.
//
// Behavior:
// - gravityEnabled OFF => single impulse only (steps forced to 1)
// - falloffMode:
//     0 = exponential (gravity-like)
//     1 = linear (more mechanical/jarring)
// - reverse:
//     false = start strong then fade
//     true  = start small then build (test option)
// - altShape:
//     true = XY fades faster than Z (less sideways drift, more vertical settle)

private func RFC_RampScale(stepIndex: Int32, steps: Int32, reverse: Bool, falloffMode: Int32) -> Float {
  if steps <= 1 {
    return 1.0;
  }

  let i: Int32 = stepIndex;
  if reverse {
    i = (steps - 1) - stepIndex; // invert
  }

  // 0 = exp, 1 = linear
  if falloffMode == 1 {
    // step0 = 1.0, last step ~= 1/steps
    return 1.0 - Cast<Float>(i) / Cast<Float>(steps);
  }

  // Exponential decay
  // 0.85 feels like "gravity" (fast first hit, then quick settling).
  return PowF(0.95, Cast<Float>(i));
}

private func RFC_ShapeVec(baseVec: Vector4, scale: Float, altShape: Bool) -> Vector4 {
  let v: Vector4;

  if !altShape {
    v.X = baseVec.X * scale;
    v.Y = baseVec.Y * scale;
    v.Z = baseVec.Z * scale;
    v.W = baseVec.W;
    return v;
  }

  // XY fades faster, Z fades slower (sell weight)
  let sXY: Float = scale * scale;
  let sZ: Float = SqrtF(scale);

  v.X = baseVec.X * sXY;
  v.Y = baseVec.Y * sXY;
  v.Z = baseVec.Z * sZ;
  v.W = baseVec.W;
  return v;
}

public func RFC_Burst(
  ds: ref<DelaySystem>,
  p: wref<GameObject>,
  pos: Vector4,
  vec: Vector4,
  radius: Float,
  tStart: Float,
  c: RFCConfig
) -> Void {
  if !IsDefined(ds) || !IsDefined(p) {
    return;
  }
  if radius <= 0.0 {
    return;
  }

  let steps: Int32 = c.ramp.enabled ? c.ramp.steps : 1;
  if steps < 1 {
    steps = 1;
  }

  // stepTime == 0 is allowed for "single impulse".
  // If steps > 1 we clamp to >= 0.001 so events don't stack on the same frame.
  let dt: Float = c.ramp.stepTime;
  if steps > 1 {
    dt = dt < 0.001 ? 0.001 : dt;
  } else {
    dt = 0.0;
  }

  let i: Int32 = 0;
  while i < steps {
    let scale: Float = RFC_RampScale(i, steps, c.ramp.reverse, c.ramp.falloffMode);
    let shaped: Vector4 = RFC_ShapeVec(vec, scale, c.ramp.altShape);

    let t: Float = RFC_ClampT(tStart + Cast<Float>(i) * dt);
    ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(pos, shaped, radius), t, false);

    i += 1;
  }
}
