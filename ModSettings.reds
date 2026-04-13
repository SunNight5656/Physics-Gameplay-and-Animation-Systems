// RFCModSettings.reds
// Menu: Splat Physics
module RealisticPush

public class RFCModSettings {

  // ───────────────────────────────────────────────────────────────────────────
  // 01) Groups (Enable / Override)  → ORDER 10
  // ───────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Splat Physics 10.0")
  @runtimeProperty("ModSettings.category.order", "0")
  @runtimeProperty("ModSettings.displayName", "showing")
  @runtimeProperty("ModSettings.dependency", "showing")
  @runtimeProperty("ModSettings.description", "")
  public let showing: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Splat Physics 10.0")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.id", "showLegacyCorpseImpulse")
  @runtimeProperty("ModSettings.displayName", "showLegacyCorpseImpulse")
  @runtimeProperty("ModSettings.dependency", "showing")
  @runtimeProperty("ModSettings.description", "")
  public let showLegacyCorpseImpulse: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Splat Physics 10.0")
  @runtimeProperty("ModSettings.category.order", "0")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let hide: Bool = false;

  // ───────────────────────────────────────────────────────────────────────────

  // 9) Situation Sliders

  // ───────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.id", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "Show Situation Sliders")
  @runtimeProperty("ModSettings.description", "Show the situation sliders.")
  public let showSituationSliders: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "ShowSituationLegacyFields")
  @runtimeProperty("ModSettings.description", "showSituationLegacyFields")
  public let showSituationLegacyFields: Bool = false;


  // ───────────────────────────────────────────────────────────────────────────

  // 10) Standing

  // ──────────────────────────────────────────────────────────────────────────


  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "Enable Standing")
  @runtimeProperty("ModSettings.description", "Turn on the Standing situation lane.")
  public let standEnabled: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "Enable Standing Sliders")
  @runtimeProperty("ModSettings.description", "Turn on the custom Standing sliders below.")
  public let overrideStand: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "overrideStand")
  @runtimeProperty("ModSettings.displayName", "Override Global New Forward")
  @runtimeProperty("ModSettings.description", "When Standing is active, this disables the Global New forward lane for this situation.")
  public let st_overrideGlobalForward: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "overrideStand")
  @runtimeProperty("ModSettings.displayName", "Forward Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "-10.00")
  @runtimeProperty("ModSettings.max", "110.00")
  @runtimeProperty("ModSettings.description", "Pushes the body forward or backward. Positive is forward. Negative is back.")
  public let st_forward: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "overrideStand")
  @runtimeProperty("ModSettings.displayName", "Forward Delay")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "Wait time before the forward push happens.")
  public let st_forwardDelay: Float = 0.020;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "overrideStand")
  @runtimeProperty("ModSettings.displayName", "Override Global New Chest")
  @runtimeProperty("ModSettings.description", "When Standing is active, this disables the Global New chest lane for this situation.")
  public let st_overrideGlobalChest: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "overrideStand")
  @runtimeProperty("ModSettings.displayName", "Chest Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "Down Chest")
  public let st_downChest: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "overrideStand")
  @runtimeProperty("ModSettings.displayName", "Chest Delay")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "Wait time before the chest push happens.")
  public let st_d_chestFall: Float = 0.020;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "overrideStand")
  @runtimeProperty("ModSettings.displayName", "Knee Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "Knee Down")
  public let st_kneeDown: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "overrideStand")
  @runtimeProperty("ModSettings.displayName", "Knee Delay")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "Wait time before the knee push happens.")
  public let st_d_knee: Float = 0.040;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let st_overrideGlobalKnees: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "st_downHead")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let st_downHead: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "st_d_headBias")
  @runtimeProperty("ModSettings.description", "")
  public let st_d_headBias: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "st_d_headSlam")
  @runtimeProperty("ModSettings.description", "")
  public let st_d_headSlam: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let st_d_headSnap: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let st_downPelvis: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let st_d_pelvisFall: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let st_shinDown: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let st_shinDelay1: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let st_shinDelay2: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let st_shinBack: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let st_shinRadius: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let st_footDown: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "footFwd")
  @runtimeProperty("ModSettings.description", "footFwd")
  public let st_footFwd: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "footDelay")
  @runtimeProperty("ModSettings.description", "footDelay")
  public let st_footDelay: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "footRadius")
  @runtimeProperty("ModSettings.description", "footRadius")
  public let st_footRadius: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "vSlamZ")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let st_vSlamZ: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let st_d_vSlam: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let st_antiTuckZ: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let st_antiTuckDelay: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let st_antiTuckRadius: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let showStandingAnchor: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let st_anchorFwd: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let st_anchorDown: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let st_anchorOffset: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let st_anchorRadius: Float = 0.00;

  // ───────────────────────────────────────────────────────────────────────────

  // 11) Running/Walking

  // ───────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "Enable Running/Walking")
  @runtimeProperty("ModSettings.description", "Turn on the Running and Walking situation lane.")
  public let runEnabled: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "Enable Running/Walking Sliders")
  @runtimeProperty("ModSettings.description", "Use the custom Running and Walking sliders below instead of the built in values.")
  public let overrideRun: Bool = false;


  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "overrideRun")
  @runtimeProperty("ModSettings.displayName", "anchorOffset (s)")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "200.000")
  @runtimeProperty("ModSettings.description", "")
  public let run_anchorOffset: Float = 50.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "overrideRun")
  @runtimeProperty("ModSettings.displayName", "anchorFwd")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "-20.00")
  @runtimeProperty("ModSettings.max", "20.00")
  @runtimeProperty("ModSettings.description", "Forward anchor offset for running and walking.")
  public let run_anchorFwd: Float = 2.00;


  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "overrideRun")
  @runtimeProperty("ModSettings.displayName", "anchorDown")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let run_anchorDown: Float = 0.00;


  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "overrideRun")
  @runtimeProperty("ModSettings.displayName", "anchorRadius")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.description", "Anchor radius for running and walking settling.")
  public let run_anchorRadius: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "overrideRun")
  @runtimeProperty("ModSettings.displayName", "Override Global New Forward")
  @runtimeProperty("ModSettings.description", "When Running or Walking is active, this disables the Global New forward lane for this situation.")
  public let run_overrideGlobalForward: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "overrideRun")
  @runtimeProperty("ModSettings.displayName", "Forward Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "-20.00")
  @runtimeProperty("ModSettings.max", "2000.00")
  @runtimeProperty("ModSettings.description", "Pushes the body forward or backward. Positive is forward. Negative is back.")
  public let run_forward: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "overrideRun")
  @runtimeProperty("ModSettings.displayName", "Forward Delay")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "Wait time before the forward push happens.")
  public let run_forwardDelay: Float = 0.020;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "overrideRun")
  @runtimeProperty("ModSettings.displayName", "Override Global New Chest")
  @runtimeProperty("ModSettings.description", "When Running or Walking is active, this disables the Global New chest lane for this situation.")
  public let run_overrideGlobalChest: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "overrideRun")
  @runtimeProperty("ModSettings.displayName", "Chest Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let run_downChest: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "overrideRun")
  @runtimeProperty("ModSettings.displayName", "Chest Delay")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "Wait time before the chest push happens.")
  public let run_d_chestFall: Float = 0.060;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "overrideRun")
  @runtimeProperty("ModSettings.displayName", "Knee Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let run_kneeDown: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "overrideRun")
  @runtimeProperty("ModSettings.displayName", "Knee Delay")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "Wait time before the knee push happens.")
  public let run_d_knee: Float = 0.120;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let run_overrideGlobalKnees: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let run_downHead: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let run_d_headSlam: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let run_d_headBias: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let run_downPelvis: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let run_d_pelvisFall: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let run_vSlamZ: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let run_d_vSlam: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let run_shinBack: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let run_shinDown: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let run_shinDelay1: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let run_shinDelay2: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "4")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let run_shinRadius: Float = 0.00;

  // ───────────────────────────────────────────────────────────────────────────

  // 20) Workspots

  // ───────────────────────────────────────────────────────────────────────────


  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "Enable Workspots")
  @runtimeProperty("ModSettings.description", "Turn on the Workspots situation lane.")
  public let wsStandEnabled: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "Enable Workspot Sliders")
  @runtimeProperty("ModSettings.description", "Turn on the custom Workspot sliders below.")
  public let overrideWorkSpots: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "overrideWorkSpots")
  @runtimeProperty("ModSettings.displayName", "Override Global New Forward")
  @runtimeProperty("ModSettings.description", "When Workspots is active, this disables the Global New forward lane for this situation.")
  public let wsStand_overrideGlobalForward: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "overrideWorkSpots")
  @runtimeProperty("ModSettings.displayName", "Forward Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "-3.00")
  @runtimeProperty("ModSettings.max", "3.00")
  @runtimeProperty("ModSettings.description", "Pushes the body forward or backward. Positive is forward. Negative is back.")
  public let wsStand_pelvisFwd: Float = 0.42;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "overrideWorkSpots")
  @runtimeProperty("ModSettings.displayName", "Override Global New Chest")
  @runtimeProperty("ModSettings.description", "When Workspots is active, this disables the Global New chest lane for this situation.")
  public let wsStand_overrideGlobalChest: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "overrideWorkSpots")
  @runtimeProperty("ModSettings.displayName", "Chest Forward")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "-50.00")
  @runtimeProperty("ModSettings.max", "50.00")
  @runtimeProperty("ModSettings.description", "Extra forward or backward push on the chest. Positive is forward. Negative is back.")
  public let wsStand_chestFwd: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "overrideWorkSpots")
  @runtimeProperty("ModSettings.displayName", "Chest Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_chestDown: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "overrideWorkSpots")
  @runtimeProperty("ModSettings.displayName", "Chest Delay")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "Wait time before the chest push happens.")
  public let wsStand_chestDelay: Float = 0.100;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "overrideWorkSpots")
  @runtimeProperty("ModSettings.displayName", "Chest Radius")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.description", "How wide the chest push reaches.")
  public let wsStand_chestRadius: Float = 0.80;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "overrideWorkSpots")
  @runtimeProperty("ModSettings.displayName", "Knee Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_kneeDown: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "overrideWorkSpots")
  @runtimeProperty("ModSettings.displayName", "Knee Delay")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "Wait time before the knee push happens.")
  public let wsStand_kneeDelay: Float = 0.120;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "overrideWorkSpots")
  @runtimeProperty("ModSettings.displayName", "Knee Radius")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.description", "How wide the knee push reaches.")
  public let wsStand_kneeRadius: Float = 0.45;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_overrideGlobalKnees: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_headFwd: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_headDown: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_headDelay: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_headRadius: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_pelvisDown: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_pelvisDelay: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_pelvisRadius: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_body_vSlamZ: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_body_vSlamDelay: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "5")
  @runtimeProperty("ModSettings.dependency", "hide")
  @runtimeProperty("ModSettings.displayName", "hide")
  @runtimeProperty("ModSettings.description", "")
  public let wsStand_body_vSlamRadius: Float = 0.00;

  // ───────────────────────────────────────────────────────────────────────────

  // 12) Cower

  // ───────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "Enable Cower")
  @runtimeProperty("ModSettings.description", "Turn on the Cower situation lane.")
  public let cowerEnabled: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "Enable Cower Sliders")
  @runtimeProperty("ModSettings.description", "Turn on the custom Cower sliders below.")
  public let overrideCower: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "overrideCower")
  @runtimeProperty("ModSettings.displayName", "Override Global New Chest")
  @runtimeProperty("ModSettings.description", "When Cower is active, this disables the Global New chest lane for this situation.")
  public let cow_overrideGlobalChest: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "overrideCower")
  @runtimeProperty("ModSettings.displayName", "Chest Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let cow_downChest: Float = 5.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "overrideCower")
  @runtimeProperty("ModSettings.displayName", "Chest Delay")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "Wait time before the chest push happens.")
  public let cow_chestDelay: Float = 0.060;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "overrideCower")
  @runtimeProperty("ModSettings.displayName", "Chest Radius")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.description", "How wide the chest push reaches.")
  public let cow_chestRadius: Float = 0.85;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "overrideCower")
  @runtimeProperty("ModSettings.displayName", "Knee Strength")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "200.000")
  @runtimeProperty("ModSettings.description", "")
  public let cow_kneeDown: Float = 2.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "overrideCower")
  @runtimeProperty("ModSettings.displayName", "Knee Delay")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "Wait time before the knee push happens.")
  public let cow_kneeDelay: Float = 0.120;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "overrideCower")
  @runtimeProperty("ModSettings.displayName", "Knee Radius")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "How wide the knee push reaches.")
  public let cow_kneeRadius: Float = 0.350;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "cow_overrideGlobalForward")
  @runtimeProperty("ModSettings.description", "")
  public let cow_overrideGlobalForward: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "cow_overrideGlobalKnees")
  @runtimeProperty("ModSettings.description", "")
  public let cow_overrideGlobalKnees: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "cow_downHead")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let cow_downHead: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "cow_headDelay")
  @runtimeProperty("ModSettings.description", "")
  public let cow_headDelay: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "cow_headRadius")
  @runtimeProperty("ModSettings.description", "")
  public let cow_headRadius: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "cow_downPelvis")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let cow_downPelvis: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "cow_pelvisDelay")
  @runtimeProperty("ModSettings.description", "")
  public let cow_pelvisDelay: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "cow_pelvisRadius")
  @runtimeProperty("ModSettings.description", "")
  public let cow_pelvisRadius: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "cow_antiTuckZ")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let cow_antiTuckZ: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "cow_antiTuckDelay")
  @runtimeProperty("ModSettings.description", "")
  public let cow_antiTuckDelay: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "cow_antiTuckRadius")
  @runtimeProperty("ModSettings.description", "")
  public let cow_antiTuckRadius: Float = 0.00;

  // ───────────────────────────────────────────────────────────────────────────

  // 13) Stairs

  // ───────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "Enable Stairs")
  @runtimeProperty("ModSettings.description", "Turn on the Stairs situation lane.")
  public let stairsEnabled: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationSliders")
  @runtimeProperty("ModSettings.displayName", "Enable Stairs Sliders")
  @runtimeProperty("ModSettings.description", "Turn on the custom Stairs sliders below.")
  public let overrideStairs: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "overrideStairs")
  @runtimeProperty("ModSettings.displayName", "Override Global New Forward")
  @runtimeProperty("ModSettings.description", "When Stairs is active, this disables the Global New forward lane for this situation.")
  public let stair_overrideGlobalForward: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "overrideStairs")
  @runtimeProperty("ModSettings.displayName", "Forward Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "-20.00")
  @runtimeProperty("ModSettings.max", "2000.00")
  @runtimeProperty("ModSettings.description", "Pushes the body forward or backward. Positive is forward. Negative is back.")
  public let stair_forward: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "overrideStairs")
  @runtimeProperty("ModSettings.displayName", "Override Global New Chest")
  @runtimeProperty("ModSettings.description", "When Stairs is active, this disables the Global New chest lane for this situation.")
  public let stair_overrideGlobalChest: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "overrideStairs")
  @runtimeProperty("ModSettings.displayName", "Chest Forward")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "-20.00")
  @runtimeProperty("ModSettings.max", "20.00")
  @runtimeProperty("ModSettings.description", "Extra forward or backward push on the chest. Positive is forward. Negative is back.")
  public let stair_chestFwd: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "overrideStairs")
  @runtimeProperty("ModSettings.displayName", "Chest Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let stair_downChest: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "overrideStairs")
  @runtimeProperty("ModSettings.displayName", "Knee Strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let stair_kneeDown: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "overrideStairs")
  @runtimeProperty("ModSettings.displayName", "Knee Delay")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "Wait time before the knee push happens.")
  public let stair_kneeDelay: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "overrideStairs")
  @runtimeProperty("ModSettings.displayName", "Knee Radius")
  @runtimeProperty("ModSettings.step", "0.001")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "5.000")
  @runtimeProperty("ModSettings.description", "How wide the knee push reaches.")
  public let stair_kneeRadius: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_overrideGlobalKnees")
  @runtimeProperty("ModSettings.description", "")
  public let stair_overrideGlobalKnees: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_headFwd")
  @runtimeProperty("ModSettings.description", "")
  public let stair_headFwd: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_downHead")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let stair_downHead: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_downPelvis")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let stair_downPelvis: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_vSlamZ")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let stair_vSlamZ: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_brakeFwd")
  @runtimeProperty("ModSettings.description", "")
  public let stair_brakeFwd: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_brakeDelay")
  @runtimeProperty("ModSettings.description", "")
  public let stair_brakeDelay: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_brakeRadius")
  @runtimeProperty("ModSettings.description", "")
  public let stair_brakeRadius: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_plankEnabled")
  @runtimeProperty("ModSettings.description", "")
  public let stair_plankEnabled: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_plankDownHead")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let stair_plankDownHead: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_plankDownChest")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let stair_plankDownChest: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_plankDownPelvis")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.description", "")
  public let stair_plankDownPelvis: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_plankFwd")
  @runtimeProperty("ModSettings.description", "")
  public let stair_plankFwd: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_plankDelay")
  @runtimeProperty("ModSettings.description", "")
  public let stair_plankDelay: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_plankRadius")
  @runtimeProperty("ModSettings.description", "")
  public let stair_plankRadius: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_plankBrakeFwd")
  @runtimeProperty("ModSettings.description", "")
  public let stair_plankBrakeFwd: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_plankBrakeDelay")
  @runtimeProperty("ModSettings.description", "")
  public let stair_plankBrakeDelay: Float = 0.000;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_plankBrakeRadius")
  @runtimeProperty("ModSettings.description", "")
  public let stair_plankBrakeRadius: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Situation Sliders")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showSituationLegacyFields")
  @runtimeProperty("ModSettings.displayName", "stair_runUseKnees")
  @runtimeProperty("ModSettings.description", "")
  public let stair_runUseKnees: Bool = false;

  // ───────────────────────────────────────────────────────────────────────────
  // GravityBurst settings (new system)
  // ───────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Gravity: For Situational Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.displayName","Show gravity options")
  public let showGravity: Bool = false;

  // Master enable (always visible when Gravity section is shown)
  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Gravity: For Situational Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "showGravity")
  @runtimeProperty("ModSettings.displayName","Enable gravity shaping (multi-step)")
  @runtimeProperty("ModSettings.description","OFF = single impulse only. ON = multi-step ramp pulses (Preset/Advanced).")
  public let gravityEnabled: Bool = true;

  // Override gate (single definition)
  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Gravity: For Situational Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "showGravity")
  @runtimeProperty("ModSettings.displayName","Customize gravity settings")
  @runtimeProperty("ModSettings.description","OFF = use built-in defaults. ON = use the Preset / Advanced controls below.")
  public let overrideGravity: Bool = false;

  // Mode (only matters when override is ON)
  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Gravity: For Situational Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "showGravity")
  @runtimeProperty("ModSettings.displayName","Gravity mode")
  @runtimeProperty("ModSettings.description","0 = Realistic (tight/subtle), 1 = Gravity+ (heavier), 2 = Cinematic (floatier/more pulses)")
  @runtimeProperty("ModSettings.min","0")
  @runtimeProperty("ModSettings.max","2")
  @runtimeProperty("ModSettings.step","1")
  public let gravityMode: Int32 = 0;

  // Falloff (only when override is ON)
  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Gravity: For Situational Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "showGravity")
  @runtimeProperty("ModSettings.displayName","Strength curve (per step)")
  @runtimeProperty("ModSettings.description","0 = Exponential (strong first hit, then quickly fades). 1 = Linear (even fade each step; more mechanical).")
  @runtimeProperty("ModSettings.min","0")
  @runtimeProperty("ModSettings.max","1")
  @runtimeProperty("ModSettings.step","1")
  public let gravityFalloffMode: Int32 = 0;

  // Manual steps toggle (only when override is ON)
  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Gravity: For Situational Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "showGravity")
  @runtimeProperty("ModSettings.displayName","Advanced: custom gravity steps")
  public let gravityBurstEnabled: Bool = false;

  // Steps (only when manual steps is ON)
  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Gravity: For Situational Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "gravityBurstEnabled")
  @runtimeProperty("ModSettings.displayName","Gravity steps")
  @runtimeProperty("ModSettings.min","1")
  @runtimeProperty("ModSettings.max","25")
  @runtimeProperty("ModSettings.step","1")
  public let gravityBurstSteps: Int32 = 3;

  // Step spacing (only when manual steps is ON)
  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Gravity: For Situational Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "gravityBurstEnabled")
  @runtimeProperty("ModSettings.displayName","Gravity step spacing (sec)")
  @runtimeProperty("ModSettings.description","0 = use the preset spacing from Gravity preset. >0 = use this exact spacing.")
  @runtimeProperty("ModSettings.min","0")
  @runtimeProperty("ModSettings.max","8.200")
  @runtimeProperty("ModSettings.step","0.001")
  public let gravityBurstStepTime: Float = 0.010;

  // Advanced toggle #1: flip ramp direction (small→big) (manual steps only)
  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Gravity: For Situational Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "gravityBurstEnabled")
  @runtimeProperty("ModSettings.displayName","Advanced: reverse ramp (small → big)")
  @runtimeProperty("ModSettings.description","OFF = strong first, then fade. ON = small first, then build.")
  public let gravityBurstReverse: Bool = false;

  // Advanced toggle #2: alternate shaping (XY fades faster than Z) (manual steps only)
  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Gravity: For Situational Sliders")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.dependency", "gravityBurstEnabled")
  @runtimeProperty("ModSettings.displayName","Advanced: Z holds longer (less sideways pop)")
  @runtimeProperty("ModSettings.description","OFF = all axes fade equally. ON = XY fades faster, Z fades slower.")
  public let gravityBurstAltShape: Bool = false;


  // ───────────────────────────────────────────────────────────────────────────
  // Global Settle → ORDER 6
  // ───────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Settle")
  @runtimeProperty("ModSettings.category.order", "10")
  @runtimeProperty("ModSettings.displayName", "Show Settle settings")
  @runtimeProperty("ModSettings.description", "Toggle to show or hide all Settle controls.")
  public let showSettle: Bool = false;

  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Settle")
  @runtimeProperty("ModSettings.category.order", "10")
  @runtimeProperty("ModSettings.dependency", "showSettle")
  @runtimeProperty("ModSettings.displayName","Enable Settle tail")
  @runtimeProperty("ModSettings.description","Adds a delayed, gentle settle push after the main fall (can reduce stiff poses).")
  public let settleEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Settle")
  @runtimeProperty("ModSettings.category.order", "10")
  @runtimeProperty("ModSettings.dependency", "showSettle")
  @runtimeProperty("ModSettings.displayName","Override Settle values")
  @runtimeProperty("ModSettings.description","OFF = use the mod defaults. ON = use the sliders below.")
  public let overrideSettle: Bool = false;


  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Settle")
  @runtimeProperty("ModSettings.category.order", "10")
  @runtimeProperty("ModSettings.displayName", "Settle strength")
  @runtimeProperty("ModSettings.dependency", "showSettle")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min", "0.0") @runtimeProperty("ModSettings.max", "5.0")
  public let settleStrength: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Settle")
  @runtimeProperty("ModSettings.category.order", "10")
  @runtimeProperty("ModSettings.displayName", "Settle delay")
  @runtimeProperty("ModSettings.dependency", "showSettle")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min", "0.0") @runtimeProperty("ModSettings.max", "10.0")
  public let settleDelay: Float = 2.26;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Settle")
  @runtimeProperty("ModSettings.category.order", "10")
  @runtimeProperty("ModSettings.displayName", "Settle forward")
  @runtimeProperty("ModSettings.dependency", "showSettle")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min", "-5.0") @runtimeProperty("ModSettings.max", "5.0")
  public let settleFwd: Float = 0.10;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Settle")
  @runtimeProperty("ModSettings.category.order", "10")
  @runtimeProperty("ModSettings.displayName", "Settle down")
  @runtimeProperty("ModSettings.dependency", "showSettle")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min", "-10.0") @runtimeProperty("ModSettings.max", "5.0")
  public let settleDown: Float = 0.60;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Settle")
  @runtimeProperty("ModSettings.category.order", "10")
  @runtimeProperty("ModSettings.displayName", "Settle radius")
  @runtimeProperty("ModSettings.dependency", "showSettle")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min", "0.0") @runtimeProperty("ModSettings.max", "5.0")
  public let settleRadius: Float = 0.80;


  // ─────────────────────────────────────────────────────────────────────────────
  // Twitch → ORDER 7
  // ─────────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Twitch")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.displayName", "Show Twitch settings")
  @runtimeProperty("ModSettings.description", "Show or hide Twitch sliders in the menu.")
  public let showTwitch: Bool = false;

  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Twitch")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.dependency", "showTwitch")
  @runtimeProperty("ModSettings.displayName","Enable Twitch system")
  @runtimeProperty("ModSettings.description","Adds occasional twitch / aftershock movement for realism.")
  public let twitchEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category","Twitch")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.dependency", "showTwitch")
  @runtimeProperty("ModSettings.displayName","Override Twitch values")
  @runtimeProperty("ModSettings.description","OFF = use the mod defaults. ON = use the sliders below.")
  public let overrideTwitch: Bool = false;


  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Twitch")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.displayName", "Twitch chance")
  @runtimeProperty("ModSettings.dependency", "showTwitch")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min", "0.0") @runtimeProperty("ModSettings.max", "1.0")
  public let twitchChance: Float = 1.0;

  //  @runtimeProperty("ModSettings.mod", "Splat Physics")
  // @runtimeProperty("ModSettings.category", "Twitch")
  @runtimeProperty("ModSettings.category.order", "11")
  // @runtimeProperty("ModSettings.displayName", "Twitch strength min")
  // @runtimeProperty("ModSettings.dependency", "showTwitch")
  // @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min", "0.0") @runtimeProperty("ModSettings.max", "10.0")
  // public let twitchStrengthMin: Float = 1.9;

  //@runtimeProperty("ModSettings.mod", "Splat Physics")
  //@runtimeProperty("ModSettings.category", "Twitch")
  @runtimeProperty("ModSettings.category.order", "11")
  //@runtimeProperty("ModSettings.displayName", "Twitch strength max")
  //@runtimeProperty("ModSettings.dependency", "showTwitch")
  //@runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min", "0.0") @runtimeProperty("ModSettings.max", "10.0")
  //public let twitchStrengthMax: Float = 1.9;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Twitch")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.displayName", "Twitch delay start")
  @runtimeProperty("ModSettings.dependency", "showTwitch")
  @runtimeProperty("ModSettings.step", "0.0") @runtimeProperty("ModSettings.min", "0.01") @runtimeProperty("ModSettings.max", "30.0")
  public let twitchDelayStart: Float = 3.2;

  //@runtimeProperty("ModSettings.mod", "Splat Physics")
  //@runtimeProperty("ModSettings.category", "Twitch")
  @runtimeProperty("ModSettings.category.order", "11")
  //@runtimeProperty("ModSettings.displayName", "Twitch delay step min")
  //@runtimeProperty("ModSettings.dependency", "showTwitch")
  //@runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min", "0.01") @runtimeProperty("ModSettings.max", "5.0")
  //public let twitchDelayStepMin: Float = 0.2;

  //@runtimeProperty("ModSettings.mod", "Splat Physics")
  //@runtimeProperty("ModSettings.category", "Twitch")
  @runtimeProperty("ModSettings.category.order", "11")
  //@runtimeProperty("ModSettings.displayName", "Twitch delay step max")
  //@runtimeProperty("ModSettings.dependency", "showTwitch")
  //@runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min", "0.01") @runtimeProperty("ModSettings.max", "5.0")
  //public let twitchDelayStepMax: Float = 0.5;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Twitch")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.displayName", "Twitch duration")
  @runtimeProperty("ModSettings.dependency", "showTwitch")
  @runtimeProperty("ModSettings.step", "0.1") @runtimeProperty("ModSettings.min", "0.0") @runtimeProperty("ModSettings.max", "120.0")
  public let twitchDuration: Float = 20.5;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Twitch")
  @runtimeProperty("ModSettings.category.order", "11")
  @runtimeProperty("ModSettings.displayName", "Twitch force")
  @runtimeProperty("ModSettings.dependency", "showTwitch")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min", "0.0") @runtimeProperty("ModSettings.max", "10.0")
  public let twitchForce: Float = 1.3;


  // ───────────────────────────────────────────────────────────────────────────
  // Z30) Legacy Corpse Impulse fields (hidden for compile compatibility)
  // ───────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category",":)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.dependency", "showing")
  @runtimeProperty("ModSettings.displayName", "corpseKickEnabled")
  @runtimeProperty("ModSettings.description","")
  public let corpseKickEnabled: Bool = false;

  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category",":)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.dependency", "showing")
  @runtimeProperty("ModSettings.displayName", "overrideBulletImpulse")
  @runtimeProperty("ModSettings.description","")
  public let overrideBulletImpulse: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", ":)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.dependency", "showing")
  @runtimeProperty("ModSettings.displayName", "bulletKickCallDelay")
  @runtimeProperty("ModSettings.description", "")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min","0.00") @runtimeProperty("ModSettings.max","5.00")
  public let bulletKickCallDelay: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", ":)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.dependency", "showing")
  @runtimeProperty("ModSettings.displayName", "bulletKickRadius")
  @runtimeProperty("ModSettings.description", "")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min","0.0") @runtimeProperty("ModSettings.max","5.0")
  public let bulletKickRadius: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", ":)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.dependency", "showing")
  @runtimeProperty("ModSettings.displayName", "bulletKickZ")
  @runtimeProperty("ModSettings.description", "")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min","-100.0") @runtimeProperty("ModSettings.max","100.0")
  public let bulletKickZ: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", ":)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.dependency", "showing")
  @runtimeProperty("ModSettings.displayName", "bulletKickStartDelay")
  @runtimeProperty("ModSettings.description", "")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min","0.00") @runtimeProperty("ModSettings.max","11.00")
  public let bulletKickStartDelay: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", ":)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.dependency", "showing")
  @runtimeProperty("ModSettings.displayName", "bulletKickDelay")
  @runtimeProperty("ModSettings.description", "")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min","0.00") @runtimeProperty("ModSettings.max","0.30")
  public let bulletKickDelay: Float = 0.00;

  // ───────────────────────────────────────────────────────────────────────────
  // zGlobal — Death & global behavior → ORDER 11 (last)
  // ───────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod","Splat Physics")
  @runtimeProperty("ModSettings.category", "Global")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.id","showGlobal")
  @runtimeProperty("ModSettings.displayName","Show Global settings")
  @runtimeProperty("ModSettings.description","Toggle to show or hide Global sliders.")
  public let showGlobal: Bool = false;

  // Toggle: skip vanilla cinematic death anims (ragdoll-only path)
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Global")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Skip cinematic death animations")
  @runtimeProperty("ModSettings.dependency", "showGlobal")
  @runtimeProperty("ModSettings.description", "ON = ragdoll-only. OFF = vanilla death animation plays first; impulses still run.")
  public let skipDeathAnim: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Global")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Show death animation controls")
  @runtimeProperty("ModSettings.dependency", "showGlobal")
  @runtimeProperty("ModSettings.description", "Advanced: tweak how often vanilla death animations play when Skip is OFF.")
  public let showDeathAnimControls: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Global")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Death animation chance (%)")
  @runtimeProperty("ModSettings.dependency", "showGlobal")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "100.0")
  @runtimeProperty("ModSettings.description", "Only used when 'Skip cinematic death animations' is OFF.")
  public let deathAnimChancePct: Float = 100.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Global")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Death animation cancellation delay (s)")
  @runtimeProperty("ModSettings.dependency", "showGlobal")
  @runtimeProperty("ModSettings.description", "When Skip is OFF, cancel death animation early")
  @runtimeProperty("ModSettings.step", "0.01") @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "5") 
  public let animCompatDelay: Float = 5;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Global")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Default mode Except for Rigs")
  @runtimeProperty("ModSettings.dependency", "showGlobal")
  @runtimeProperty("ModSettings.description", "Disable Splat features globally and let the game handle deaths with its rig only. If you want Death Animations back use the toggle above")
  public let vanillaMode: Bool = false;

  // ── Global → Respect Cinematics (stealth / finisher / Blackwall)
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Global")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Keep stealth/finisher/Blackwall cinematics")
  @runtimeProperty("ModSettings.dependency", "showGlobal")
  @runtimeProperty("ModSettings.description", "Let vanilla executions (stealth, finisher, Blackwall) play; disables Splat wake-taps/impulses during those only.")
  public let respectCinematics: Bool = false;

  // ── Global → Stealth ragdoll (delayed force-ragdoll after stealth/finisher begins)
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Global")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.id", "stealthRagdollsEnabled")
  @runtimeProperty("ModSettings.displayName", "Stealth ragdoll")
  @runtimeProperty("ModSettings.description", "Master toggle. When ON and Cinematics is OFF, Splat schedules force-ragdoll wake taps after a delay for stealth/finishers.")
  @runtimeProperty("ModSettings.dependency", "showGlobal")
  public let stealthRagdollsEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Global")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.id", "stealthRagdollDelay")
  @runtimeProperty("ModSettings.displayName", "Stealth ragdoll delay (s)")
  @runtimeProperty("ModSettings.description", "Seconds after the stealth/finisher starts before Splat forces ragdoll (wake taps).")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "showGlobal")
  public let stealthRagdollDelay: Float = 2.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Global")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.id", "blackwallCountsAsStealth")
  @runtimeProperty("ModSettings.displayName", "Blackwell")
  @runtimeProperty("ModSettings.description", "When ON, Blackwall-tag kills count as stealth/finishers for Cinematics + Stealth ragdoll rules.")
  @runtimeProperty("ModSettings.dependency", "showGlobal")
  public let blackwallCountsAsStealth: Bool = false;

  @runtimeProperty("ModSettings.dependency", "showGlobal")
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Global")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.id", "killImpulsesVehiclesOnly")
  @runtimeProperty("ModSettings.displayName", "Kills Splat Impulses in Cars")
  @runtimeProperty("ModSettings.description", "Zero out Splat impulses when the NPC is inside a vehicle. Keeps workspots normal.")
  public let killImpulsesVehiclesOnly: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Global")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.id", "killImpulsesEverywhere")
  @runtimeProperty("ModSettings.displayName", "Kill vanilla impulses ")
  @runtimeProperty("ModSettings.dependency", "showGlobal")
  @runtimeProperty(
  "ModSettings.description",
  "Kill all vanilla impulses & knock back animations."
  )
  public let killImpulsesEverywhere: Bool = true;

  // ─────────────────────────────────────────────────────────────────────────────
  // VANILLA IMPULSES AND PUSHBACK
  // ─────────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Toggle Orignal Game Impulse (Per Weapon)")
  @runtimeProperty("ModSettings.category.order", "75")
  @runtimeProperty("ModSettings.id", "showVanillaImpulseSection")
  @runtimeProperty("ModSettings.displayName", "Show Toggles for Orignal Game Impulses")
  @runtimeProperty("ModSettings.description", "Show or hide the vanilla impulse section.")
  public let showVanilla: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Toggle Orignal Game Impulse (Per Weapon)")
  @runtimeProperty("ModSettings.category.order", "75")
  @runtimeProperty("ModSettings.id", "vanillaImpulsesEnabled")
  @runtimeProperty("ModSettings.displayName", "Enable Vanilla Impulses & Pushback")
  @runtimeProperty("ModSettings.dependency", "showVanilla")
  @runtimeProperty(
  "ModSettings.description",
  "Turn on vanilla impulses and pushback From Vanilla game. If you want pushback animation back, enable DeathAnimtion in Global Settings."
  )
  public let vanillaImpulsesEnabled: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Toggle Orignal Game Impulse (Per Weapon)")
  @runtimeProperty("ModSettings.category.order", "75")
  @runtimeProperty("ModSettings.id", "showVanillaImpulseWeaponToggles")
  @runtimeProperty("ModSettings.displayName", "Show Weapon Toggles")
  @runtimeProperty("ModSettings.dependency", "showVanilla")
  @runtimeProperty(
  "ModSettings.description",
  "Show the weapon group toggles for vanilla impulses. If you want vanilla push back animations Enable Death Animations in Global."
  )
  public let showVanillaImpulseWeaponToggles: Bool = false;

  // Hidden legacy weapon toggles kept for compile/runtime compatibility
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Toggle Orignal Game Impulse (Per Weapon)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.id", "vanillaAllowHandgun")
  @runtimeProperty("ModSettings.displayName", "vanillaAllowHandgun")
  @runtimeProperty("ModSettings.dependency", "showVanillaImpulseWeaponToggles")
  public let vanillaAllowHandgun: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Toggle Orignal Game Impulse (Per Weapon)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.id", "vanillaAllowMagnum")
  @runtimeProperty("ModSettings.displayName", "vanillaAllowMagnum")
  @runtimeProperty("ModSettings.dependency", "showVanillaImpulseWeaponToggles")
  public let vanillaAllowMagnum: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Toggle Orignal Game Impulse (Per Weapon)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.id", "vanillaAllowSMG")
  @runtimeProperty("ModSettings.displayName", "vanillaAllowSMG")
  @runtimeProperty("ModSettings.dependency", "showVanillaImpulseWeaponToggles")
  public let vanillaAllowSMG: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Toggle Orignal Game Impulse (Per Weapon)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.id", "vanillaAllowAR")
  @runtimeProperty("ModSettings.displayName", "vanillaAllowAR")
  @runtimeProperty("ModSettings.dependency", "showVanillaImpulseWeaponToggles")
  public let vanillaAllowAR: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Toggle Orignal Game Impulse (Per Weapon)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.id", "vanillaAllowLMG")
  @runtimeProperty("ModSettings.displayName", "vanillaAllowLMG")
  @runtimeProperty("ModSettings.dependency", "showVanillaImpulseWeaponToggles")
  public let vanillaAllowLMG: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Toggle Orignal Game Impulse (Per Weapon)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.id", "vanillaAllowShotgun")
  @runtimeProperty("ModSettings.displayName", "vanillaAllowShotgun")
  @runtimeProperty("ModSettings.dependency", "showVanillaImpulseWeaponToggles")
  public let vanillaAllowShotgun: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Toggle Orignal Game Impulse (Per Weapon)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.id", "vanillaAllowSniper")
  @runtimeProperty("ModSettings.displayName", "vanillaAllowSniper")
  @runtimeProperty("ModSettings.dependency", "showVanillaImpulseWeaponToggles")
  public let vanillaAllowSniper: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Toggle Orignal Game Impulse (Per Weapon)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.id", "vanillaAllowBlunt")
  @runtimeProperty("ModSettings.displayName", "vanillaAllowBlunt")
  @runtimeProperty("ModSettings.dependency", "showVanillaImpulseWeaponToggles")
  public let vanillaAllowBlunt: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Toggle Orignal Game Impulse (Per Weapon)")
  @runtimeProperty("ModSettings.category.order", "999")
  @runtimeProperty("ModSettings.id", "vanillaAllowBlade")
  @runtimeProperty("ModSettings.displayName", "vanillaAllowBlade")
  @runtimeProperty("ModSettings.dependency", "showVanillaImpulseWeaponToggles")
  public let vanillaAllowBlade: Bool = true;

  // ─────────────────────────────────────────────────────────────────────────────
  // ARCADE (Weapon Pushback & Arcade Adjustment) 1
  // Basics only (master toggles + player-only + sliders)
  // ─────────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "showArcade")
  @runtimeProperty("ModSettings.displayName", "Show: Weapon Pushback & Arcade settings")
  @runtimeProperty("ModSettings.description", "Show Arcade settings (OnHit shove, weapon gating, multipliers).")
  public let showArcade: Bool = false;

  // Master toggles
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "arcadeBulletsEnabled")
  @runtimeProperty("ModSettings.displayName", "Weapon Pushback & Arcade: Enable")
  @runtimeProperty("ModSettings.description", "Master toggle for Weapon Pushback & Arcade bullet shove system.")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  public let arcadeBulletsEnabled: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "arcadeOnHitEnabled")
  @runtimeProperty("ModSettings.displayName", "Weapon Pushback & Arcade: OnHit")
  @runtimeProperty("ModSettings.description", "Allow Weapon Pushback & Arcade shove to trigger on hits (when weapon is allowed).")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  public let arcadeOnHitEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "arcadeOnDeathEnabled")
  @runtimeProperty("ModSettings.displayName", "Weapon Pushback & Arcade: OnDeath")
  @runtimeProperty("ModSettings.description", "Allow Weapon Pushback & Arcade behavior to run from death path when applicable.")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  public let arcadeOnDeathEnabled: Bool = true;

  // Player-only gate (NPC vs NPC off)
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "arcadePlayerOnly")
  @runtimeProperty("ModSettings.displayName", "Weapon Pushback & Arcade: Player only")
  @runtimeProperty("ModSettings.description", "If ON: Arcade shove only triggers from player hits. NPC vs NPC will not shove.")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  public let arcadePlayerOnly: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "showArcade")
  @runtimeProperty("ModSettings.displayName", "Show: Weapon Pushback & Arcade settings")
  @runtimeProperty("ModSettings.description", "Show Arcade settings (OnHit shove, weapon gating, multipliers).")
  @runtimeProperty("ModSettings.dependency", "showA")
  public let showA: Bool = false;

  // Sliders show/hide (kept, but SHOWARCADE must still hide everything)
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "showArcadeAdvanced")
  @runtimeProperty("ModSettings.displayName", "Show: Weapon Pushback & Arcade sliders")
  @runtimeProperty("ModSettings.description", "Shows Weapon Pushback & Arcade tuning sliders (strength, lift, radius, cooldown, delay, cower scale).")
  @runtimeProperty("ModSettings.dependency", "showA")
  public let showArcadeAdvanced: Bool = false;

  // Arcade tuning
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "arcadeBulletStrength")
  @runtimeProperty("ModSettings.displayName", "Strength")
  @runtimeProperty("ModSettings.description", "Horizontal shove strength.")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "40.0")
  @runtimeProperty("ModSettings.step", "0.5")
  public let arcadeBulletStrength: Float = 8.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "arcadeBulletUp")
  @runtimeProperty("ModSettings.displayName", "Up")
  @runtimeProperty("ModSettings.description", "Vertical lift added to shove impulse.")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "20.0")
  @runtimeProperty("ModSettings.step", "0.25")
  public let arcadeBulletUp: Float = 1.5;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "arcadeBulletRadius")
  @runtimeProperty("ModSettings.displayName", "Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius for ApplyImpulse.")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.min", "0.05")
  @runtimeProperty("ModSettings.max", "5.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let arcadeBulletRadius: Float = 0.60;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "arcadeBulletCooldown")
  @runtimeProperty("ModSettings.displayName", "Cooldown")
  @runtimeProperty("ModSettings.description", "Anti volleyball cooldown per target.")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "2.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let arcadeBulletCooldown: Float = 0.35;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "arcadeImpulseDelay")
  @runtimeProperty("ModSettings.displayName", "Impulse delay (s)")
  @runtimeProperty("ModSettings.description", "Delay before ApplyImpulse.")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "0.50")
  @runtimeProperty("ModSettings.step", "0.01")
  public let arcadeImpulseDelay: Float = 0.06;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 1")
  @runtimeProperty("ModSettings.category.order", "60")
  @runtimeProperty("ModSettings.id", "arcadeCowScale")
  @runtimeProperty("ModSettings.displayName", "Cower scale")
  @runtimeProperty("ModSettings.description", "Cower strength scale.")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "2.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let arcadeCowScale: Float = 1.0;


  // ─────────────────────────────────────────────────────────────────────────────
  // ARCADE (Weapon Pushback & Arcade Adjustment) 2
  // Weapon choice + group enables + multipliers
  // ─────────────────────────────────────────────────────────────────────────────

  // Weapon toggles show/hide
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "weaponchoice")
  @runtimeProperty("ModSettings.displayName", "Show: Allowed weapons")
  @runtimeProperty("ModSettings.description", "Show weapon group enables (handgun, SMG, etc).")
  public let weaponchoice: Bool = false;

  // Weapon multipliers toggle
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "showArcadeWeaponMuls")
  @runtimeProperty("ModSettings.displayName", "Show: Weapon multipliers")
  @runtimeProperty("ModSettings.description", "Per weapon group shove multipliers. 1.0 normal. 0.0 disables that group.")
  public let showArcadeWeaponMuls: Bool = false;

  // Weapon allow toggles
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeAllowHandgun")
  @runtimeProperty("ModSettings.displayName", "Allow handgun")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "weaponchoice")
  public let arcadeAllowHandgun: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeAllowMagnum")
  @runtimeProperty("ModSettings.displayName", "Allow magnum")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "weaponchoice")
  public let arcadeAllowMagnum: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeAllowShotgun")
  @runtimeProperty("ModSettings.displayName", "Allow shotgun")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "weaponchoice")
  public let arcadeAllowShotgun: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeAllowSniper")
  @runtimeProperty("ModSettings.displayName", "Allow sniper")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "weaponchoice")
  public let arcadeAllowSniper: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeAllowSMG")
  @runtimeProperty("ModSettings.displayName", "Allow SMG")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "weaponchoice")
  public let arcadeAllowSMG: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeAllowAR")
  @runtimeProperty("ModSettings.displayName", "Allow AR")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "weaponchoice")
  public let arcadeAllowAR: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeAllowLMG")
  @runtimeProperty("ModSettings.displayName", "Allow LMG")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "weaponchoice")
  public let arcadeAllowLMG: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeAllowBlunt")
  @runtimeProperty("ModSettings.displayName", "Allow blunt")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "weaponchoice")
  public let arcadeAllowBlunt: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeAllowBlade")
  @runtimeProperty("ModSettings.displayName", "Allow blade")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "weaponchoice")
  public let arcadeAllowBlade: Bool = true;

  // Multipliers
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeMulHandgun")
  @runtimeProperty("ModSettings.displayName", "Mul handgun")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "showArcadeWeaponMuls")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let arcadeMulHandgun: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeMulMagnum")
  @runtimeProperty("ModSettings.displayName", "Mul magnum")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "showArcadeWeaponMuls")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let arcadeMulMagnum: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeMulShotgun")
  @runtimeProperty("ModSettings.displayName", "Mul shotgun")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "showArcadeWeaponMuls")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let arcadeMulShotgun: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeMulSniper")
  @runtimeProperty("ModSettings.displayName", "Mul sniper")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "showArcadeWeaponMuls")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let arcadeMulSniper: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeMulSMG")
  @runtimeProperty("ModSettings.displayName", "Mul SMG")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "showArcadeWeaponMuls")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let arcadeMulSMG: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeMulAR")
  @runtimeProperty("ModSettings.displayName", "Mul AR")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "showArcadeWeaponMuls")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let arcadeMulAR: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeMulLMG")
  @runtimeProperty("ModSettings.displayName", "Mul LMG")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "showArcadeWeaponMuls")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let arcadeMulLMG: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeMulBlunt")
  @runtimeProperty("ModSettings.displayName", "Mul blunt")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "showArcadeWeaponMuls")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let arcadeMulBlunt: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Weapon Pushback & Arcade Adjustment 2")
  @runtimeProperty("ModSettings.category.order", "61")
  @runtimeProperty("ModSettings.id", "arcadeMulBlade")
  @runtimeProperty("ModSettings.displayName", "Mul blade")
  @runtimeProperty("ModSettings.dependency", "showArcade")
  @runtimeProperty("ModSettings.dependency", "showArcadeWeaponMuls")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  @runtimeProperty("ModSettings.step", "0.05")
  public let arcadeMulBlade: Float = 1.0;



  // ─────────────────────────────────────────────────────────────────────────────
  // Explosions (Grenades + other explosion sources)
  // ─────────────────────────────────────────────────────────────────────────────

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.displayName", "Show Explosions settings")
  @runtimeProperty("ModSettings.description", "Show or hide grenade/explosion corpse-impulse settings. Cancels Explode animation")
  public let showGrenadesExplosions: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Enable explosion corpse kick")
  @runtimeProperty("ModSettings.description", "Enables custom corpse kick behavior for explosions.")
  public let grenadeEnabled: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Override base values")
  @runtimeProperty("ModSettings.description", "OFF = use mod defaults. ON = use the sliders below.")
  public let overrideGrenade: Bool = false;

  // Explosions
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.displayName", "Explosions: Player only")
  @runtimeProperty("ModSettings.description", "If ON: Explosion corpse kicks only trigger from player-caused explosions. NPC vs NPC explosions won't kick corpses.")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  public let explPlayerOnly: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Radius")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "100.0")
  public let grenadeKickRadius: Float = 1.2;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Radial strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "-100.0")
  @runtimeProperty("ModSettings.max", "100.0")
  public let grenadeKickX: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Swirl strength")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "-100.0")
  @runtimeProperty("ModSettings.max", "100.0")
  public let grenadeKickY: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Vertical")
  @runtimeProperty("ModSettings.description", "Positive to pop bodies upward.")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "-100.0")
  @runtimeProperty("ModSettings.max", "100.0")
  public let grenadeKickZ: Float = 1000.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Call delay (s)")
  @runtimeProperty("ModSettings.description", "When to call the explosion corpse shove.")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "-10.0")
  @runtimeProperty("ModSettings.max", "100.0")
  public let grenadeKickCallDelay: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showExplosionsAdvanced")
  @runtimeProperty("ModSettings.displayName", "Show advanced source controls")
  @runtimeProperty("ModSettings.description", "Per-source toggles and multipliers (grenade vs weapon vs bullet vs vehicle).")
  public let showExplosionsAdvanced: Bool = false;

  // Per-source enables (simple, direct names)
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Grenades")
  public let explAffectGrenades: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Explosive rounds,")
  @runtimeProperty("ModSettings.description", "Examples: explosive rounds, explosive weapons, launchers if classified as weapon source.")
  public let explAffectWeapon: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Others: bullet explosions")
  @runtimeProperty("ModSettings.description", "Examples: explosive bullets if classified as bullet source.")
  public let explAffectBullet: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "explAffectVeh")
  @runtimeProperty("ModSettings.displayName", "Affect vehicle impacts")
  public let explAffectVeh: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "explAffectVeh")
  @runtimeProperty("ModSettings.displayName", "Affect vehicle impacts")
  public let explAffectVehicle: Bool = false;

  // Per-source multipliers (0 disables that source)
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Mul grenades")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  public let explMulGrenades: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Mul weapon explosions")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  public let explMulWeapon: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Mul bullet explosions")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  public let explMulBullet: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Explosions")
  @runtimeProperty("ModSettings.category.order", "62")
  @runtimeProperty("ModSettings.dependency", "showGrenadesExplosions")
  @runtimeProperty("ModSettings.displayName", "Mul vehicle impacts")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "3.0")
  public let explMulVehicle: Float = 1.0;




  // Grenade corpse kick
  // grenadeKickX is radial strength
  // grenadeKickY is sideways swirl strength
  // grenadeKickZ is vertical



  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "Show: Pop / Anim Fix WIP Doesn't work")
  @runtimeProperty("ModSettings.description", "Show Pop/Anim Fix settings (vehicle exit, bike death anim, stagger pop-down).")
  @runtimeProperty("ModSettings.dependency", "showPopFix")
  public let showPopFix: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "Override: Pop / Anim Fix")
  @runtimeProperty("ModSettings.description", "If OFF, Pop/Anim Fix settings are ignored (values remain as defaults).")
  @runtimeProperty("ModSettings.dependency", "showPopFix")
  public let overridePopFix: Bool = true;



  // ───────────────────────────────────────────────────────────────────────────
  // TUMBLES (kept at the very end)
  // ───────────────────────────────────────────────────────────────────────────
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.id", "showTumbles")
  @runtimeProperty("ModSettings.displayName", "Show Tumbles settings")
  @runtimeProperty("ModSettings.description", "Show/hide Ramp Settings.")
  public let showTumble: Bool = false;

  // Master enables
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.id", "tumbleEnabled")
  @runtimeProperty("ModSettings.displayName", "Enable stairs/ramp tumble")
  @runtimeProperty("ModSettings.description", "experimental: Master toggle for the stairs/ramp tumble behavior (used in the Stairs branch).")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let tumbleEnabled: Bool = true;

  // ── Tumbles → Stairs/Ramps (override)
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.id", "overrideTumbleStairs")
  @runtimeProperty("ModSettings.displayName", "Use manual ramp tumble settings")
  @runtimeProperty("ModSettings.description", "When OFF: use Splat hardcoded defaults. When ON: use the sliders below.")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let overrideTumbleStairs: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.displayName", "Start delay (s)")
  @runtimeProperty("ModSettings.description", "Delay before the first tumble impulse starts.")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let tumbleStairs_delay: Float = 0.08;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.displayName", "Down strength")
  @runtimeProperty("ModSettings.description", "Vertical push (down). Higher = harder slam into the steps/ground.")
  @runtimeProperty("ModSettings.step", "0.25")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "60.00")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let tumbleStairs_down: Float = 19.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.displayName", "Forward strength")
  @runtimeProperty("ModSettings.description", "Planar push along the stairs direction (forward). Higher = more slide/tumble down stairs.")
  @runtimeProperty("ModSettings.step", "0.25")
  @runtimeProperty("ModSettings.min", "-60.00")
  @runtimeProperty("ModSettings.max", "60.00")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let tumbleStairs_fwd: Float = 9.25;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.displayName", "Side strength")
  @runtimeProperty("ModSettings.description", "Lateral push (side). Use small values; big values cause sideways launches.")
  @runtimeProperty("ModSettings.step", "0.25")
  @runtimeProperty("ModSettings.min", "-60.00")
  @runtimeProperty("ModSettings.max", "60.00")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let tumbleStairs_side: Float = 2.80;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.displayName", "Down delay (s)")
  @runtimeProperty("ModSettings.description", "Extra delay added before the down impulse.")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let tumbleStairs_downDelay: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.displayName", "Forward delay (s)")
  @runtimeProperty("ModSettings.description", "Extra delay added before the forward impulse.")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let tumbleStairs_fwdDelay: Float = 0.04;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.displayName", "Side delay (s)")
  @runtimeProperty("ModSettings.description", "Extra delay added before the side impulse.")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let tumbleStairs_sideDelay: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.displayName", "Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius. Larger radius affects more of the body (less localized).")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.05")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let tumbleStairs_radius: Float = 1.35;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.displayName", "Yaw (deg)")
  @runtimeProperty("ModSettings.description", "Rotation around vertical axis for the tumble torque.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-180.0")
  @runtimeProperty("ModSettings.max", "180.0")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let tumbleStairs_yawDeg: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.displayName", "Pitch (deg)")
  @runtimeProperty("ModSettings.description", "Rotation around right axis for the tumble torque.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-180.0")
  @runtimeProperty("ModSettings.max", "180.0")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let tumbleStairs_pitchDeg: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Movie Tumbles: Ramps")
  @runtimeProperty("ModSettings.category.order", "100")
  @runtimeProperty("ModSettings.displayName", "Roll (deg)")
  @runtimeProperty("ModSettings.description", "Rotation around forward axis for the tumble torque.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "-180.0")
  @runtimeProperty("ModSettings.max", "180.0")
  @runtimeProperty("ModSettings.dependency", "showTumble")
  public let tumbleStairs_rollDeg: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Experimental Tumbles: Directional")
  @runtimeProperty("ModSettings.category.order", "99")
  @runtimeProperty("ModSettings.id", "showTumbles")
  @runtimeProperty("ModSettings.displayName", "Show Tumbles settings")
  @runtimeProperty("ModSettings.description", "Show/hide all tumble controls (stairs/ramp + directional tumble).")
  public let showTumblesD: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Experimental Tumbles: Directional")
  @runtimeProperty("ModSettings.category.order", "99")
  @runtimeProperty("ModSettings.id", "directionalTumbleEnabled")
  @runtimeProperty("ModSettings.displayName", "Enable directional tumble")
  @runtimeProperty("ModSettings.description", "experimental:  directional tumble helpers (used in run/workspot/cower/stand branches when enabled in code).")
  @runtimeProperty("ModSettings.dependency", "showTumblesD")
  public let directionalTumbleEnabled: Bool = false;

  // ── Tumbles → Directional (override)
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Experimental Tumbles: Directional")
  @runtimeProperty("ModSettings.category.order", "99")
  @runtimeProperty("ModSettings.id", "overrideTumbleDirectional")
  @runtimeProperty("ModSettings.displayName", "Use manual sliders TumblesD")
  @runtimeProperty("ModSettings.description", "When OFF: use Splat hardcoded defaults. When ON: use the sliders below.")
  @runtimeProperty("ModSettings.dependency", "showTumblesD")
  public let overrideTumbleDirectional: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Experimental Tumbles: Directional")
  @runtimeProperty("ModSettings.category.order", "99")
  @runtimeProperty("ModSettings.displayName", "Down strength")
  @runtimeProperty("ModSettings.description", "Vertical push (down). Higher = harder slam.")
  @runtimeProperty("ModSettings.step", "0.25")
  @runtimeProperty("ModSettings.min", "-60.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "showTumblesD")
  public let tumbleDir_down: Float = 19.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Experimental Tumbles: Directional")
  @runtimeProperty("ModSettings.category.order", "99")
  @runtimeProperty("ModSettings.displayName", "Forward strength")
  @runtimeProperty("ModSettings.description", "Planar push forward (based on movement/hit direction used by the branch).")
  @runtimeProperty("ModSettings.step", "0.25")
  @runtimeProperty("ModSettings.min", "-60.00")
  @runtimeProperty("ModSettings.max", "60.00")
  @runtimeProperty("ModSettings.dependency", "showTumblesD")
  public let tumbleDir_fwd: Float = 9.25;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Experimental Tumbles: Directional")
  @runtimeProperty("ModSettings.category.order", "99")
  @runtimeProperty("ModSettings.displayName", "Side strength")
  @runtimeProperty("ModSettings.description", "Lateral push. Small values only; big values cause sideways launches.")
  @runtimeProperty("ModSettings.step", "0.25")
  @runtimeProperty("ModSettings.min", "-60.00")
  @runtimeProperty("ModSettings.max", "60.00")
  @runtimeProperty("ModSettings.dependency", "showTumblesD")
  public let tumbleDir_side: Float = 2.80;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Experimental Tumbles: Directional")
  @runtimeProperty("ModSettings.category.order", "99")
  @runtimeProperty("ModSettings.displayName", "Down delay (s)")
  @runtimeProperty("ModSettings.description", "Extra delay before the down impulse.")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "showTumblesD")
  public let tumbleDir_downDelay: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Experimental Tumbles: Directional")
  @runtimeProperty("ModSettings.category.order", "99")
  @runtimeProperty("ModSettings.displayName", "Forward delay (s)")
  @runtimeProperty("ModSettings.description", "Extra delay before the forward impulse.")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "showTumblesD")
  public let tumbleDir_fwdDelay: Float = 0.04;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Experimental Tumbles: Directional")
  @runtimeProperty("ModSettings.category.order", "99")
  @runtimeProperty("ModSettings.displayName", "Side delay (s)")
  @runtimeProperty("ModSettings.description", "Extra delay before the side impulse.")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "showTumblesD")
  public let tumbleDir_sideDelay: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Experimental Tumbles: Directional")
  @runtimeProperty("ModSettings.category.order", "99")
  @runtimeProperty("ModSettings.displayName", "Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius. Larger radius affects more of the body.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.05")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "showTumblesD")
  public let tumbleDir_radius: Float = 1.35;


  // POP / ANIM FIX (DEFAULTS)

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] Enable")
  @runtimeProperty("ModSettings.description", "Master enable for Pop/Anim Fix behavior (workspot/vehicle/bike/stagger helpers).")
  @runtimeProperty("ModSettings.dependency", "showPopFix")
  public let popFix_enable: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] Kill bike death anim")
  @runtimeProperty("ModSettings.description", "For motorcycle riders: prefer ragdoll takeover instead of death animation timing.")
  @runtimeProperty("ModSettings.dependency", "hide")
  public let popFix_killBikeDeathAnim: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] Kill vehicle exit anim")
  @runtimeProperty("ModSettings.description", "For car occupants: suppress exit animation timing windows (reduces under-car / above-car glitches).")
  @runtimeProperty("ModSettings.dependency", "hide")
  public let popFix_killVehicleExitAnim: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] Stagger pop-down fix")
  @runtimeProperty("ModSettings.description", "Prevents the instant up then down or snap-down after stagger or incap states.")
  @runtimeProperty("ModSettings.dependency", "showPopFix")
  public let popFix_fixStaggerSnap: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] Workspot exit pop (experimental)")
  @runtimeProperty("ModSettings.description", "Attempts to mitigate chair or table workspot pop. Some workspots still teleport due to hard reset or teleport requests.")
  @runtimeProperty("ModSettings.dependency", "hide")
  public let popFix_tryWorkspotExitMitigation: Bool = true;

  // POPFIX ADVANCED (TIMINGS)

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "Show: Advanced PopFix sliders")
  @runtimeProperty("ModSettings.description", "Shows timing sliders for PopFix. If you don’t know what they do, leave this OFF.")
  @runtimeProperty("ModSettings.dependency", "hide")
  public let showPopFixAdvanced: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] How long to guard chair or stool deaths (sec)")
  @runtimeProperty("ModSettings.description", "After a chair or stool death, the game sometimes snaps the body. This is how long we keep PopFix active to stop that snap.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "hide")
  public let popFix_latchWorkspot: Float = 2.25;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] How long to guard vehicle or bike deaths (sec)")
  @runtimeProperty("ModSettings.description", "After vehicle or bike exits or deaths, the game can yank the body or force a death animation. This is how long PopFix stays active to prevent that.")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "hide")
  public let popFix_latchVehicle: Float = 1.60;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] How long to guard stagger snap-down (sec)")
  @runtimeProperty("ModSettings.description", "")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "5.00")
  @runtimeProperty("ModSettings.dependency", "hide")
  public let popFix_latchStagger: Float = 0.90;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] Delay before breaking chair or lean (sec)")
  @runtimeProperty("ModSettings.description", "If enabled, PopFix tries to break them out of the chair or lean state. This is a tiny delay before doing that. Usually keep at 0.")
  @runtimeProperty("ModSettings.step", "0.005")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "0.500")
  @runtimeProperty("ModSettings.dependency", "hide")
  public let popFix_wsPreemptDelay: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] Wake nudge #1 time (sec)")
  @runtimeProperty("ModSettings.description", "Tiny wake nudge time to prevent pops. 0 disables this nudge.")
  @runtimeProperty("ModSettings.step", "0.005")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "0.500")
  @runtimeProperty("ModSettings.dependency", "hide")
  public let popFix_pulse0: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] Wake nudge #2 time (sec)")
  @runtimeProperty("ModSettings.description", "Second wake nudge. Keep small (like 0.01 to 0.05).")
  @runtimeProperty("ModSettings.step", "0.005")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "0.500")
  @runtimeProperty("ModSettings.dependency", "hide")
  public let popFix_pulse1: Float = 0.02;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] Wake nudge #3 time (sec)")
  @runtimeProperty("ModSettings.description", "Third wake nudge.")
  @runtimeProperty("ModSettings.step", "0.005")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "0.500")
  @runtimeProperty("ModSettings.dependency", "hide")
  public let popFix_pulse2: Float = 0.05;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "101")
  @runtimeProperty("ModSettings.displayName", "[PopFix] Wake nudge #4 time (sec)")
  @runtimeProperty("ModSettings.description", "Fourth wake nudge. This is usually the last one.")
  @runtimeProperty("ModSettings.step", "0.005")
  @runtimeProperty("ModSettings.min", "0.000")
  @runtimeProperty("ModSettings.max", "0.500")
  @runtimeProperty("ModSettings.dependency", "hide")
  public let popFix_pulse3: Float = 0.14;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
        @runtimeProperty("ModSettings.category", "Enjoy the Splat!")
  @runtimeProperty("ModSettings.category.order", "1555")
  @runtimeProperty("ModSettings.id", "")
  @runtimeProperty("ModSettings.dependency", "showAD")
  @runtimeProperty("ModSettings.displayName", "showAD")
  @runtimeProperty("ModSettings.description", "")
  public let showAD: Bool = false;



}