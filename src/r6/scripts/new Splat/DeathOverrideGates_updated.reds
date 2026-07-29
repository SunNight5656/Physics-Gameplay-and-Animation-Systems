module RealisticPush

@addField(NPCPuppet) public let rfc_allowHeadFalls: Bool;
@addField(NPCPuppet) public let rfc_allowBodyForward: Bool;
@addField(NPCPuppet) public let rfc_allowBodyChest: Bool;
@addField(NPCPuppet) public let rfc_blockShoulderFalls: Bool;
@addField(NPCPuppet) public let rfc_blockButtFalls: Bool;

public func RFC_ApplyDeathOverrideGates(p: wref<NPCPuppet>, c: RFCConfig) -> Void {
  let overrideForward: Bool;
  let overrideChest: Bool;
  let overridePelvis: Bool;

  if !IsDefined(p) { return; }

  if c.vanillaMode || RFC_MasterDeathChanceBlocksImpulses(p) {
    p.rfc_allowBodyForward = false;
    p.rfc_allowBodyChest = false;
    p.rfc_blockShoulderFalls = true;
    p.rfc_blockButtFalls = true;
    p.rfc_allowHeadFalls = false;
    return;
  }

  overrideForward = GS_CurrentOverrideForward(p, c);
  overrideChest = GS_CurrentOverrideChest(p, c);
  overridePelvis = GS_CurrentOverridePelvis(p, c);

  // Selective ownership only: a Situational component replaces the matching
  // normal Body Falls component. Head Falls, Arcade, Jolts, Twitch, Tumble,
  // Settle, and unrelated body components are not disabled here.
  p.rfc_allowBodyForward = !overrideForward;
  p.rfc_allowBodyChest = !overrideChest;
  p.rfc_blockShoulderFalls = overrideChest;
  p.rfc_blockButtFalls = overridePelvis;
  p.rfc_allowHeadFalls = true;
}
