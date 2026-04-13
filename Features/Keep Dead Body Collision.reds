module RealisticPush

public class DCSConfig extends IScriptable {
  public let enabled: Bool;
}

public class DCSSettings extends ScriptableSystem {
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Keep NPC Post Dead Collision On EXPERIMENTAL")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Keep NPC Collision On")
  @runtimeProperty("ModSettings.description", "ON means the game is not allowed to turn this NPC's collision off through this function. OFF means normal game behavior.")
  public let keepNPCollisionOn: Bool = true;
}

public class DCS extends IScriptable {
  public static func Cfg(game: GameInstance) -> ref<DCSConfig> {
    let c: ref<DCSConfig> = new DCSConfig();
    let s: ref<DCSSettings>;

    s = GameInstance.GetScriptableSystemsContainer(game).Get(n"RealisticPush.DCSSettings") as DCSSettings;

    if IsDefined(s) {
      c.enabled = s.keepNPCollisionOn;
    } else {
      c.enabled = true;
    };

    return c;
  }
}

@wrapMethod(NPCPuppet)
public final func DisableCollision() -> Void {
  let c: ref<DCSConfig> = DCS.Cfg(this.GetGame());

  if IsDefined(c) && c.enabled {
    this.m_disableCollisionRequested = false;
    this.UpdateCollisionState();
    return;
  };

  wrappedMethod();
}
