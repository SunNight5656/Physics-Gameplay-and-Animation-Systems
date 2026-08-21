module RealisticPush


@addField(NPCPuppet) private let shhjm_lastHitValid: Bool;
@addField(NPCPuppet) private let shhjm_lastHitPos: Vector4;
@addField(NPCPuppet) private let shhjm_lastSrcPos: Vector4;
@addField(NPCPuppet) private let shhjm_lastAnchorPos: Vector4;
@addField(NPCPuppet) private let shhjm_lastBodyPart: Int32;
@addField(NPCPuppet) private let shhjm_lastBoneIndex: Int32;
@addField(NPCPuppet) private let shhjm_lastGroundImpactTime: Float;
@addField(NPCPuppet) private let shhjm_hasGroundImpact: Bool;


public class SHHJM_Settings {

public let showHeadSection: Bool = true;

  public let headEnabled: Bool = true;

  public let headForwardStrength: Float = 27.000000;

  public let headUpStrength: Float = 0.000000;

  public let headDownStrength: Float = 6.000000;

  public let headRadius: Float = 0.071400;

  public let headApplyOffset: Float = 0.550000;

  public let headHitDelaySec: Float = 3.200000;

  // ---------------------------------------------------------------------------
  // TORSO
  // ---------------------------------------------------------------------------

public let showTorsoSection: Bool = true;

  public let torsoEnabled: Bool = true;

  public let torsoForwardStrength: Float = 10.000000;

  public let torsoUpStrength: Float = 0.000000;

  public let torsoDownStrength: Float = 0.000000;

  public let torsoRadius: Float = 5.000000;

  public let torsoApplyOffset: Float = 0.250000;

  public let torsoHitDelaySec: Float = 2.600000;


  // ---------------------------------------------------------------------------
  // LEFT ARM
  // ---------------------------------------------------------------------------

public let showLeftArmSection: Bool = true;

  public let leftArmEnabled: Bool = true;

  public let leftArmForwardStrength: Float = 71.000000;

  public let leftArmUpStrength: Float = 0.000000;

  public let leftArmDownStrength: Float = 0.000000;

  public let leftArmRadius: Float = 0.079600;

  public let leftArmApplyOffset: Float = 0.350000;

  public let leftArmHitDelaySec: Float = 2.500000;


  // ---------------------------------------------------------------------------
  // RIGHT ARM
  // ---------------------------------------------------------------------------

public let showRightArmSection: Bool = true;

  public let rightArmEnabled: Bool = true;

  public let rightArmForwardStrength: Float = 70.000000;

  public let rightArmUpStrength: Float = 0.000000;

  public let rightArmDownStrength: Float = 0.000000;

  public let rightArmRadius: Float = 0.075000;

  public let rightArmApplyOffset: Float = 0.350000;

  public let rightArmHitDelaySec: Float = 2.400000;


  // ---------------------------------------------------------------------------
  // LEFT LEG
  // ---------------------------------------------------------------------------

public let showLeftLegSection: Bool = true;

  public let leftLegEnabled: Bool = true;

  public let leftLegForwardStrength: Float = 26.000000;

  public let leftLegUpStrength: Float = 0.000000;

  public let leftLegDownStrength: Float = 0.000000;

  public let leftLegRadius: Float = 0.104200;

  public let leftLegApplyOffset: Float = 0.350000;

  public let leftLegHitDelaySec: Float = 2.400000;


  // ---------------------------------------------------------------------------
  // RIGHT LEG
  // ---------------------------------------------------------------------------

public let showRightLegSection: Bool = true;

  public let rightLegEnabled: Bool = true;

  public let rightLegForwardStrength: Float = 26.000000;

  public let rightLegUpStrength: Float = 0.000000;

  public let rightLegDownStrength: Float = 0.000000;

  public let rightLegRadius: Float = 0.108900;

  public let rightLegApplyOffset: Float = 0.350000;

  public let rightLegHitDelaySec: Float = 2.800000;

}

// Legacy death/wait-for-ground timing removed.
public class SHHJM_ApplyImpulseEvt extends Event {
  public let pos: Vector4;
  public let imp: Vector4;
  public let srcPos: Vector4;
  public let radius: Float;
  public let part: Int32;
  public let boneIndex: Int32;
  public let targetWasAlreadyDead: Bool;
}

public class SHHJM_WaitForGroundEvt extends Event {
  public let srcPos: Vector4;
  public let anchorPos: Vector4;
  public let part: Int32;
  public let boneIndex: Int32;
  public let targetWasAlreadyDead: Bool;
  public let fireDelay: Float;
  public let expireAt: Float;
  public let armedAt: Float;
}

public class SHHJM_OnDeathApplyEvt extends Event {}
public class SHHJM_ForceRagdollEvt extends Event {
  public let allowWhileDeathAnimationOwned: Bool;
}
