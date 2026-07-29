module RealisticPush

public enum RFCEnemyImpulseClass {
  Standard = 0,
  MaxTac = 1,
  Boss = 2,
  Mech = 3,
  Robot = 4
}

private func RFC_HasToken(s: String, a: String, b: String) -> Bool {
  if StrContains(s, a) { return true; }
  if StrContains(s, b) { return true; }
  return false;
}

public func RFC_EnemyImpulseClassOf(puppet: wref<NPCPuppet>) -> RFCEnemyImpulseClass {
  let idStr: String;

  if !IsDefined(puppet) {
    return RFCEnemyImpulseClass.Standard;
  }

  idStr = TDBID.ToStringDEBUG(puppet.GetRecordID());

  // Prevention/ship-drop elite police. Catch both base and 2nd-wave records.
  if RFC_HasToken(idStr, "maxtac", "MaxTac") {
    return RFCEnemyImpulseClass.MaxTac;
  }
  if RFC_HasToken(idStr, "max_tac", "Max_Tac") {
    return RFCEnemyImpulseClass.MaxTac;
  }
  if RFC_HasToken(idStr, "prevention_", "Prevention_") && RFC_HasToken(idStr, "2nd_wave", "2nd_Wave") {
    return RFCEnemyImpulseClass.MaxTac;
  }

  // Heavy synthetic / machine targets. Put these before Boss so heavy bosses
  // can be scaled like machines instead of like ordinary humanoid bosses.
  if RFC_HasToken(idStr, "mech", "Mech") {
    return RFCEnemyImpulseClass.Mech;
  }
  if RFC_HasToken(idStr, "exoskeleton", "Exoskeleton") {
    return RFCEnemyImpulseClass.Mech;
  }
  if RFC_HasToken(idStr, "chimera", "Chimera") {
    return RFCEnemyImpulseClass.Mech;
  }
  if RFC_HasToken(idStr, "tank", "Tank") {
    return RFCEnemyImpulseClass.Mech;
  }

  if RFC_HasToken(idStr, "robot", "Robot") {
    return RFCEnemyImpulseClass.Robot;
  }
  if RFC_HasToken(idStr, "android", "Android") {
    return RFCEnemyImpulseClass.Robot;
  }
  if RFC_HasToken(idStr, "drone", "Drone") {
    return RFCEnemyImpulseClass.Robot;
  }
  if RFC_HasToken(idStr, "cerberus", "Cerberus") {
    return RFCEnemyImpulseClass.Robot;
  }
  if RFC_HasToken(idStr, "spiderbot", "Spiderbot") {
    return RFCEnemyImpulseClass.Robot;
  }

  if RFC_HasToken(idStr, "boss", "Boss") {
    return RFCEnemyImpulseClass.Boss;
  }
  if RFC_HasToken(idStr, "smasher", "Smasher") {
    return RFCEnemyImpulseClass.Boss;
  }
  if RFC_HasToken(idStr, "oda", "Oda") {
    return RFCEnemyImpulseClass.Boss;
  }
  if RFC_HasToken(idStr, "kurt", "Kurt") {
    return RFCEnemyImpulseClass.Boss;
  }
  if RFC_HasToken(idStr, "hansen", "Hansen") {
    return RFCEnemyImpulseClass.Boss;
  }
  if RFC_HasToken(idStr, "placide", "Placide") {
    return RFCEnemyImpulseClass.Boss;
  }
  if RFC_HasToken(idStr, "sasquatch", "Sasquatch") {
    return RFCEnemyImpulseClass.Boss;
  }

  return RFCEnemyImpulseClass.Standard;
}

public func RFC_EnemyAllowsArcade(puppet: wref<NPCPuppet>, cfg: RFCConfig) -> Bool {
  if !cfg.enemyTypeFiltersEnabled {
    return true;
  }

  switch RFC_EnemyImpulseClassOf(puppet) {
    case RFCEnemyImpulseClass.MaxTac:
      return cfg.enemyArcadeAllowMaxTac;
    case RFCEnemyImpulseClass.Boss:
      return cfg.enemyArcadeAllowBosses;
    case RFCEnemyImpulseClass.Mech:
      return cfg.enemyArcadeAllowMechs;
    case RFCEnemyImpulseClass.Robot:
      return cfg.enemyArcadeAllowRobots;
  }

  return true;
}

public func RFC_EnemyAllowsBulletJolts(puppet: wref<NPCPuppet>, cfg: RFCConfig) -> Bool {
  if !cfg.enemyTypeFiltersEnabled {
    return true;
  }

  switch RFC_EnemyImpulseClassOf(puppet) {
    case RFCEnemyImpulseClass.MaxTac:
      return cfg.enemyJoltAllowMaxTac;
    case RFCEnemyImpulseClass.Boss:
      return cfg.enemyJoltAllowBosses;
    case RFCEnemyImpulseClass.Mech:
      return cfg.enemyJoltAllowMechs;
    case RFCEnemyImpulseClass.Robot:
      return cfg.enemyJoltAllowRobots;
  }

  return true;
}

public func RFC_EnemyArcadeScale(puppet: wref<NPCPuppet>, cfg: RFCConfig) -> Float {
  if !cfg.enemyTypeFiltersEnabled {
    return 1.0;
  }

  switch RFC_EnemyImpulseClassOf(puppet) {
    case RFCEnemyImpulseClass.MaxTac:
      return cfg.enemyArcadeScaleMaxTac;
    case RFCEnemyImpulseClass.Boss:
      return cfg.enemyArcadeScaleBosses;
    case RFCEnemyImpulseClass.Mech:
      return cfg.enemyArcadeScaleMechs;
    case RFCEnemyImpulseClass.Robot:
      return cfg.enemyArcadeScaleRobots;
  }

  return 1.0;
}

public func RFC_EnemyBulletJoltScale(puppet: wref<NPCPuppet>, cfg: RFCConfig) -> Float {
  if !cfg.enemyTypeFiltersEnabled {
    return 1.0;
  }

  switch RFC_EnemyImpulseClassOf(puppet) {
    case RFCEnemyImpulseClass.MaxTac:
      return cfg.enemyJoltScaleMaxTac;
    case RFCEnemyImpulseClass.Boss:
      return cfg.enemyJoltScaleBosses;
    case RFCEnemyImpulseClass.Mech:
      return cfg.enemyJoltScaleMechs;
    case RFCEnemyImpulseClass.Robot:
      return cfg.enemyJoltScaleRobots;
  }

  return 1.0;
}

public func RFC_EnemyCanBypassCanRagdoll(puppet: wref<NPCPuppet>, cfg: RFCConfig) -> Bool {
  if !cfg.enemyTypeFiltersEnabled || !cfg.enemyBypassCanRagdollGate {
    return false;
  }
  if !RFC_EnemyAllowsArcade(puppet, cfg) {
    return false;
  }

  switch RFC_EnemyImpulseClassOf(puppet) {
    case RFCEnemyImpulseClass.MaxTac:
      return true;
    case RFCEnemyImpulseClass.Boss:
      return cfg.enemyArcadeAllowBosses;
    case RFCEnemyImpulseClass.Mech:
      return cfg.enemyArcadeAllowMechs;
    case RFCEnemyImpulseClass.Robot:
      return cfg.enemyArcadeAllowRobots;
  }

  return false;
}

public func RFC_ScaleImpulse3(v: Vector4, scale: Float) -> Vector4 {
  return new Vector4(v.X * scale, v.Y * scale, v.Z * scale, 1.0);
}
