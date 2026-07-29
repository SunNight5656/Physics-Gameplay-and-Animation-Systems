module RealisticPush

// Uses the game's grenade source and native grenade-record tags. This follows
// SPLAT's existing exception pattern: identify the source, then return early.
public func RFC_GrenadeExceptionMatches(ad: ref<AttackData>, cfg: RFCConfig) -> Bool {
  if !IsDefined(ad) {
    return false;
  }

  let grenade: ref<BaseGrenade> = ad.GetSource() as BaseGrenade;
  if !IsDefined(grenade) {
    return false;
  }

  let itemID: TweakDBID = ItemID.GetTDBID(grenade.GetItemID());
  if !TDBID.IsValid(itemID) {
    return false;
  }

  // Ozob's Nose carries frag behavior, so check its exact record first.
  if Equals(itemID, t"Items.GrenadeOzobsNose") {
    return cfg.grenadeExceptionOzob;
  }

  let grenadeRecord: wref<Grenade_Record> = TweakDBInterface.GetGrenadeRecord(itemID);
  if !IsDefined(grenadeRecord) {
    return false;
  }

  let tags: array<CName> = grenadeRecord.Tags();

  if cfg.grenadeExceptionFrag && ArrayContains(tags, n"FragGrenade") { return true; }
  if cfg.grenadeExceptionFlash && ArrayContains(tags, n"FlashGrenade") { return true; }
  if cfg.grenadeExceptionSmoke && ArrayContains(tags, n"SmokeGrenade") { return true; }
  if cfg.grenadeExceptionPiercing && ArrayContains(tags, n"PiercingGrenade") { return true; }
  if cfg.grenadeExceptionEMP && ArrayContains(tags, n"EMPGrenade") { return true; }
  if cfg.grenadeExceptionBiohazard && ArrayContains(tags, n"BiohazardGrenade") { return true; }
  if cfg.grenadeExceptionIncendiary && ArrayContains(tags, n"IncendiaryGrenade") { return true; }
  if cfg.grenadeExceptionRecon && ArrayContains(tags, n"ReconGrenade") { return true; }
  if cfg.grenadeExceptionCutting && ArrayContains(tags, n"CuttingGrenade") { return true; }
  if cfg.grenadeExceptionSonic && ArrayContains(tags, n"SonicGrenade") { return true; }

  return false;
}
