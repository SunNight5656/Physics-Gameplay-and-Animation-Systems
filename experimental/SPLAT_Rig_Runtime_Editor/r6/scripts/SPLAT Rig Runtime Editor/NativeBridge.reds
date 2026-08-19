// Native declaration for the in-memory CET -> REDscript -> RED4ext Apply path.
// The implementation is registered by SPLATRigRuntimeNative.dll.
public static native func SPLATRigRuntimeNativeApply(configText: String) -> Bool

// Small gameplay popup used by the controller tuner.
public static func SPLATRigRuntimeShowPopup(message: String) -> Void {
  let player: ref<GameObject> = GameInstance.GetPlayerSystem(GetGameInstance()).GetLocalPlayerControlledGameObject();
  let notification: SimpleScreenMessage;

  if !IsDefined(player) {
    return;
  };

  notification.isShown = true;
  notification.duration = 2.0;
  notification.message = message;
  notification.isInstant = true;

  GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(
    GetAllBlackboardDefs().UI_Notifications.WarningMessage,
    ToVariant(notification),
    true
  );
}
