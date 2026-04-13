module RealisticPush


// ------------------------------------------------------------
// Cancel horizontal momentum (used by DeathRouterHelpers)
// ------------------------------------------------------------
public func RFC_CancelPlanarMomentum(
  ds: ref<DelaySystem>,
  p: wref<NPCPuppet>,
  chestPos: Vector4,
  pelvisPos: Vector4,
  dirX: Float,
  dirY: Float
) -> Void {

  if !IsDefined(ds) || !IsDefined(p) { return; }

  let v: Vector4 = p.GetVelocity();
  let mag: Float = SqrtF(v.X * v.X + v.Y * v.Y);

  if mag < 0.05 { return; }

  let cx: Float = -v.X;
  let cy: Float = -v.Y;

  ds.DelayEvent(
    p,
    CreateRagdollApplyImpulseEvent(
      chestPos,
      Vector4(cx, cy, 0.0, 1.0),
      0.85
    ),
    0.000,
    false
  );

  ds.DelayEvent(
    p,
    CreateRagdollApplyImpulseEvent(
      pelvisPos,
      Vector4(cx * 0.6, cy * 0.6, 0.0, 1.0),
      0.85
    ),
    0.006,
    false
  );
}

// ─────────────────────────────────────────────
// SPEED (shared)
// ─────────────────────────────────────────────
private func RFC_GetPlanarSpeed(p: wref<ScriptedPuppet>) -> Float {
  let v: Vector4 = p.GetVelocity();
  let s: Float = Vector4.Length(Vector4(v.X, v.Y, 0.0, 0.0));

  // normalize if it looks like cm/s-ish
  if s > 20.0 { s *= 0.01; }

  return s;
}

// ─────────────────────────────────────────────
// WALKING (single definition)
// ─────────────────────────────────────────────

@addMethod(NPCPuppet)
public func RFC_WasWalkingRecent(window: Float) -> Bool {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  return this.rfc_walkLastSeen > 0.0 && (now - this.rfc_walkLastSeen) <= window;
}

// NOTE: Uses HasRuntimeAnimsetTags(array) ONLY (no HasRuntimeAnimsetTag calls).
private func RFC_IsClearlyWalking(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }

  let t: array<CName>;

  // generic loco tags
  ArrayPush(t, n"walk");
  ArrayPush(t, n"loco_walk");
  ArrayPush(t, n"loco_move");
  ArrayPush(t, n"loco_move_slow");
  ArrayPush(t, n"loco_move_fast");

  // crowd walk patterns (from your screenshot)
  ArrayPush(t, n"Crowds.WalkMovement");
  ArrayPush(t, n"Crowds.WalkMovementPattern");
  ArrayPush(t, n"Crowds.ManCivilianWalkMovementPattern");
  ArrayPush(t, n"Crowds.ManBigCivilianWalkMovementPattern");
  ArrayPush(t, n"Crowds.ManHomelessWalkMovementPattern");
  ArrayPush(t, n"Crowds.WomanCivilianWalkMovementPattern");
  ArrayPush(t, n"Crowds.StoopKingWalkMovementPattern");
  ArrayPush(t, n"Crowds.StoopQueenWalkMovementPattern");

  return p.HasRuntimeAnimsetTags(t);
}

// Walking = non-workspot, and MUST NOT steal RUN.
public func RFC_IsWalking(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  if RFC_IsWorkspotOrPerch(p) { return false; }

  // Don’t let walk steal run
  if RFC_IsRunning(p) { return false; }

  // Tag-first (handles root motion cases where velocity reads low)
  if RFC_IsClearlyWalking(p) { return true; }

  // Fallback: speed band
  let planar: Float = RFC_GetPlanarSpeed(p);
  if planar < 0.12 { return false; }  // idle-ish
  if planar > 1.55 { return false; }  // run-ish
  return true;
}

// ─────────────────────────────────────────────
// RUNNING (kept consistent with your “tag first, then speed” style)
// ─────────────────────────────────────────────
private func RFC_IsClearlyRunning(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  let t: array<CName>;
  ArrayPush(t, n"run");
  ArrayPush(t, n"sprint");
  ArrayPush(t, n"jog");
  ArrayPush(t, n"dash");
  ArrayPush(t, n"loco_run");
  ArrayPush(t, n"loco_sprint");
  return p.HasRuntimeAnimsetTags(t);
}

public func RFC_IsRunning(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }

  let planar: Float = RFC_GetPlanarSpeed(p);

  // 1) Hard run tags always win
  if RFC_IsClearlyRunning(p) { return true; }

  // 2) If it looks like WALK by tags and speed isn't clearly run, don't classify as run
  if RFC_IsClearlyWalking(p) && planar < 1.55 {
    return false;
  }

  // 3) Reaction / flee tags only count if speed is also run-ish
  let flee: array<CName>;
  ArrayPush(flee, n"Flee"); ArrayPush(flee, n"PanicFlee"); ArrayPush(flee, n"Escape");
  ArrayPush(flee, n"Run");  ArrayPush(flee, n"Sprint");    ArrayPush(flee, n"Evade");
  if RFC_StimHasAnyTags(p, flee) {
    return planar > 1.55;
  }

  // 4) Pure speed fallback
  return planar > 1.75;
}


// ─────────────────────────────────────────────────────────────────────────────
// STANDING CHECK
// ─────────────────────────────────────────────────────────────────────────────


// ------------------------------------------------------------
// Shared helpers
// ------------------------------------------------------------
public func RFC_GetPlanarSpeed(p: wref<ScriptedPuppet>) -> Float {
  if !IsDefined(p) { return 0.0; }

  let v: Vector4 = p.GetVelocity();
  let s: Float = SqrtF(v.X * v.X + v.Y * v.Y);

  // normalize if cm/s-ish
  if s > 20.0 { s *= 0.01; }
  return s;
}

// ------------------------------------------------------------
// MOVE DIRECTION (uses current velocity, then cached planar velocity)
// This makes run/walk direction reliable even when velocity is ~0 at death.
// ------------------------------------------------------------
public func RFC_GetMoveDirCached(p: wref<NPCPuppet>, out dirX: Float, out dirY: Float, fallbackX: Float, fallbackY: Float) -> Void {
  if !IsDefined(p) {
    dirX = fallbackX;
    dirY = fallbackY;
    return;
  };

  let vx: Float = p.GetVelocity().X;
  let vy: Float = p.GetVelocity().Y;
  let sp: Float = SqrtF(vx * vx + vy * vy);

  // Convert cm/s → m/s if needed (same heuristic as RFC_GetPlanarSpeed)
  if sp > 20.0 {
    vx *= 0.01;
    vy *= 0.01;
    sp *= 0.01;
  };

  // If death velocity is basically zero, fall back to cached planar velocity
  if sp < 0.05 {
    vx = p.rfc_lastPlanarVX;
    vy = p.rfc_lastPlanarVY;
    sp = SqrtF(vx * vx + vy * vy);
  };

  if sp > 0.05 {
    dirX = vx / sp;
    dirY = vy / sp;
  } else {
    dirX = fallbackX;
    dirY = fallbackY;
  };
}


// ------------------------------------------------------------
// WALK DETECTION — DIRECTION AGNOSTIC
// ------------------------------------------------------------
public func RFC_IsWalking(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }

  // workspots are never walk
  if RFC_IsWorkspotOrPerch(p) { return false; }

  // run always wins
  if RFC_IsRunning(p) { return false; }

  let planar: Float = RFC_GetPlanarSpeed(p);

  // walk band (wide on purpose)
  return planar > 0.12 && planar <= 1.55;
}

// ------------------------------------------------------------
// CLEAR WALK (anim-driven, root-motion safe)
// ------------------------------------------------------------
public func RFC_IsClearlyWalking(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }

  let t: array<CName>;

  // generic locomotion
  ArrayPush(t, n"walk");
  ArrayPush(t, n"loco_walk");
  ArrayPush(t, n"loco_move");
  ArrayPush(t, n"loco_move_slow");
  ArrayPush(t, n"loco_move_fast");

  // crowd walk patterns
  ArrayPush(t, n"Crowds.WalkMovement");
  ArrayPush(t, n"Crowds.WalkMovementPattern");
  ArrayPush(t, n"Crowds.ManCivilianWalkMovementPattern");
  ArrayPush(t, n"Crowds.ManBigCivilianWalkMovementPattern");
  ArrayPush(t, n"Crowds.ManHomelessWalkMovementPattern");
  ArrayPush(t, n"Crowds.WomanCivilianWalkMovementPattern");
  ArrayPush(t, n"Crowds.StoopKingWalkMovementPattern");
  ArrayPush(t, n"Crowds.StoopQueenWalkMovementPattern");

  return p.HasRuntimeAnimsetTags(t);
}

// ------------------------------------------------------------
// MOVEMENT DIRECTION (forward / back / strafe safe)
// ------------------------------------------------------------
public func RFC_GetMoveDirXY(
  p: wref<ScriptedPuppet>,
  fallbackX: Float,
  fallbackY: Float,
  out dirX: Float,
  out dirY: Float
) -> Void {

  dirX = fallbackX;
  dirY = fallbackY;

  if !IsDefined(p) { return; }

  let mx: Float = 0.0;
  let my: Float = 0.0;

  let npc: ref<NPCPuppet> = p as NPCPuppet;
  if IsDefined(npc) {
    if AbsF(npc.rfc_lastPlanarVX) > 0.001 || AbsF(npc.rfc_lastPlanarVY) > 0.001 {
      mx = npc.rfc_lastPlanarVX;
      my = npc.rfc_lastPlanarVY;
    }
  }

  if AbsF(mx) <= 0.001 && AbsF(my) <= 0.001 {
    let v: Vector4 = p.GetVelocity();
    mx = v.X;
    my = v.Y;
  }

  let len: Float = SqrtF(mx * mx + my * my);
  if len > 0.05 {
    dirX = mx / len;
    dirY = my / len;
  }
}

private func RFC_IsClearlyStanding(p: wref<ScriptedPuppet>) -> Bool {
  if !IsDefined(p) { return false; }

  let standTags: array<CName>;
  ArrayPush(standTags, n"idle");
  ArrayPush(standTags, n"stand");
  ArrayPush(standTags, n"locomotion_idle");
  ArrayPush(standTags, n"loco_idle");

  // If any explicit standing/idle tags, accept.
  if RFC_HasAnyTag(p, standTags) { return true; }

  // Otherwise: low planar speed counts as standing.
  return RFC_GetPlanarSpeed(p) < 0.12;
}


private func RFC_HasAnyTag(p: wref<ScriptedPuppet>, tags: array<CName>) -> Bool {
  if !IsDefined(p) { return false; }
  let i: Int32 = 0;
  while i < ArraySize(tags) {
    let one: array<CName>;
    ArrayPush(one, tags[i]);
    if p.HasRuntimeAnimsetTags(one) { return true; }
    i += 1;
  }
  return false;
}

public func RFC_CountAnyTags(p: wref<ScriptedPuppet>, tags: array<CName>) -> Int32 {
  if !IsDefined(p) { return 0; }
  let count: Int32 = 0;
  let i: Int32 = 0;
  while i < ArraySize(tags) {
    let one: array<CName>;
    ArrayPush(one, tags[i]);
    if p.HasRuntimeAnimsetTags(one) { count += 1; }
    i += 1;
  }
  return count;
}


public func RFC_GetAIData(p: wref<ScriptedPuppet>) -> ref<AIReactionData> {
  return null;
}

public func RFC_ObjectHasSE(obj: wref<GameObject>, seName: CName) -> Bool {
  return false;
}


public func RFC_StimHasAnyTags(p: wref<ScriptedPuppet>, tags: array<CName>) -> Bool {
  if !IsDefined(p) { return false; }
  let i: Int32 = 0;
  while i < ArraySize(tags) {
    let one: array<CName>;
    ArrayPush(one, tags[i]);
    if p.HasRuntimeAnimsetTags(one) { return true; }
    i += 1;
  }
  return false;
}
