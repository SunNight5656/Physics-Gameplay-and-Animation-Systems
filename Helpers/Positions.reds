module RealisticPush

public struct RFC_RigOffsets {
  public let headZ: Float;
  public let chestZ: Float;
  public let pelvisZ: Float;
  public let kneeZ: Float;
  public let shinZ: Float;
  public let footZ: Float;

  public let headForwardXY: Float;
  public let chestForwardXY: Float;
  public let pelvisForwardXY: Float;
}

public class RFC_RigNeutral {
  public static func Offsets() -> RFC_RigOffsets {
    let R: RFC_RigOffsets;
    R.headZ = 1.30;
    R.chestZ = 1.12;
    R.pelvisZ = 0.95;
    R.kneeZ = 0.52;
    R.shinZ = 0.40;
    R.footZ = 0.16;

R.headForwardXY   = 0.06;
R.chestForwardXY  = 0.04;
R.pelvisForwardXY = 0.02;

    return R;
  }
}

public func RFC_GetFlatForward(puppet: ref<NPCPuppet>, out dirX: Float, out dirY: Float) -> Void {
  let fwd: Vector4 = puppet.GetWorldForward();
  let flat: Vector4 = Vector4.Normalize(Vector4(fwd.X, fwd.Y, 0.0, 0.0));
  dirX = flat.X;
  dirY = flat.Y;
}

public func RFC_BuildPositions(
  puppet: ref<NPCPuppet>,
  dirX: Float,
  dirY: Float,
  R: RFC_RigOffsets,
  out headPos: Vector4,
  out chestPos: Vector4,
  out pelvisPos: Vector4,
  out leftKneePos: Vector4,
  out rightKneePos: Vector4,
  out leftShinPos: Vector4,
  out rightShinPos: Vector4,
  out leftFootPos: Vector4,
  out rightFootPos: Vector4
) -> Void {
  let base: Vector4 = puppet.GetWorldPosition();

  headPos   = base; headPos.Z   += R.headZ;   headPos.X   += dirX * R.headForwardXY;   headPos.Y   += dirY * R.headForwardXY;
  chestPos  = base; chestPos.Z  += R.chestZ;  chestPos.X  += dirX * R.chestForwardXY;  chestPos.Y  += dirY * R.chestForwardXY;
  pelvisPos = base; pelvisPos.Z += R.pelvisZ; pelvisPos.X += dirX * R.pelvisForwardXY; pelvisPos.Y += dirY * R.pelvisForwardXY;

  leftKneePos  = base; leftKneePos.Z  += R.kneeZ;
  rightKneePos = base; rightKneePos.Z += R.kneeZ;

  leftShinPos  = base; leftShinPos.Z  += R.shinZ;
  rightShinPos = base; rightShinPos.Z += R.shinZ;

  leftFootPos  = base; leftFootPos.Z  += R.footZ;
  rightFootPos = base; rightFootPos.Z += R.footZ;
}
