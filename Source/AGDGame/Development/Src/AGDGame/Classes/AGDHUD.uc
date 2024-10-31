class AGDHUD extends UDKHUD;

//Class Variables
var AGDPlayerController AGDPCOwner;
var AGDPawn AGDPlayerPawn;
var AGDGFxHud AGDHudMovie;
var class<AGDGFxHud> AGDHudMovieClass;

var AGDGFxDebugText DebugFlash;

// GFxObject Vars
var GFxObject _debugText;

//GFxHud variables
var Vector2D HudGFxSize;

var AGDMinimap GameMinimap;
var MaterialInstanceConstant CompassOverlayInst;
var MaterialInstanceConstant MinimapInst;
var Float TileSize;
var Int MapDim;
var Int BoxSize;
var Color PlayerColors[2];

var AGDCoconut _tooltip;

// These variables are used in UTHUD:
var vector2d MapPosition;
/** Holds the full width and height of the viewport */
var float FullWidth, FullHeight;

// and UDKHUDBASE:
/** Holds the scaling factor given the current resolution.  This is calculated in PostRender() */
var float ResolutionScale, ResolutionScaleX;

//Textures
var const Texture2D MouseTexture;

//Mouse Position Variables
var bool bDrawTraces; //Hold exec console function switch to display debug of trace lines & Paths.

// Called when this event is destroyed
singular event Destroyed()
{
	if (self.DebugFlash != none)
	{
		DebugFlash.Close();
	}
}

//Called after game loaded - initialise things
simulated function PostBeginPlay()
{
	`Log("AGDHUD::PostBeginPlay() Begin");
	super.PostBeginPlay();

	_tooltip = Spawn(class'AGDCoconut');

	AGDPCOwner = AGDPlayerController(Owner);
	
	GameMinimap = AGDGame(WorldInfo.Game).GameMinimap;
	
	CompassOverlayInst = new(None) Class'MaterialInstanceConstant';
	CompassOverlayInst.SetParent(GameMinimap.CompassOverlay);
	GameMiniMap.CompassOverlay = CompassOverlayInst;
	
	MinimapInst = new(None) Class'MaterialInstanceConstant';
	MinimapInst.SetParent(GameMinimap.Minimap);
	GameMiniMap.Minimap = MinimapInst;
	
	InitialiseHudMovie();
	InitialiseDebug();
	
	self._debugText = DebugFlash.GetVariableObject("_root._debugtext");

	_debugText.SetText("Lenny is awesome");

	if (_debugText == none)
	{
		`log("AGDHUD::Debug text is a none also!");
	}

	if (AGDHudMovie == none)
	{
		`log("AGDHUD::HUD Move is a none!");
	}

	if (DebugFlash == none)
	{
		`log("AGDHUD::DebugFlash is a none!");
	}


	`Log("AGDHUD::PostBeginPlay() End");
}

// Initialises the debug movie
function InitialiseDebug()
{
	DebugFlash = new class'AGDGFxDebugText';
	DebugFlash.SetTimingMode(TM_Real);
	DebugFlash.Init();
	DebugFlash.SetPlayerController(AGDPCOwner);
	DebugFlash.SetPriority(10);
}

//Initialise HUD Movie to be played
function InitialiseHudMovie()
{
	//Setting Hud GFxMovie
	AGDHudMovie = new AGDHudMovieClass;
	AGDHudMovie.SetTimingMode(TM_Real);
	AGDHudMovie.SetAlignment(Align_TopCenter);
	AGDHudMovie.Init();
	AGDHudMovie.SetPlayerController(AGDPCOwner);
	AGDHudMovie.SetPriority(10);
}

//Called every tick the HUD should be updated
event PostRender()
{	
	local AGDCamera playerCam;
	super.PostRender();
	
	ResolutionScaleX = Canvas.ClipX/1024;
	ResolutionScale = Canvas.ClipY/768;
		
	FullWidth = Canvas.ClipX;
	FullHeight = Canvas.ClipY;
	
	//Screen Size Passed to the player controller
	AGDPCOwner.ScreenSize.X = Canvas.ClipX;
	AGDPCOwner.ScreenSize.Y = Canvas.ClipY;	
	
	//Deproject Mouse Coordinates
	Canvas.DeProject(AGDPCOwner.MousePosition, AGDPCOwner.MouseWorldLocation, AGDPCOwner.MouseWorldDirection);
	
	// Render the tooltip message to the screen
	self._debugText.SetText(_tooltip.GetMessage());

	//Get Player Camera (isometric)
	playerCam = AGDCamera(AGDPCOwner.PlayerCamera);

    //Set the ray direction as the MouseWorldDirection
    AGDPCOwner.RayDir = AGDPCOwner.MouseWorldDirection;

    //Start the trace at the player camera + offset in front of the camera (direction *10)
    AGDPCOwner.StartTrace = (PlayerCam.ViewTarget.POV.Location + vect(0,0,0)) + AGDPCOwner.RayDir * 10;

    //End this ray at start + the direction multiplied by a given distance (5000 unit is far enough generally)
    AGDPCOwner.EndTrace = AGDPCOwner.StartTrace + AGDPCOwner.RayDir * 5000;

    //Trace MouseHitWorldLocation each frame to world location to know where the player is clicking
	AGDPCOwner.TraceActor = Trace(AGDPCOwner.MouseHitWorldLocation, AGDPCOwner.MouseHitWorldNormal, AGDPCOwner.EndTrace, AGDPCOwner.StartTrace, true);
	if(AGDPCOwner.bPlayerHasObject)
	{
		while(AGDPCOwner.TraceActor.Tag != 'WorldInfo' && AGDPCOwner.TraceActor.Tag != 'Terrain')
		{
			AGDPCOwner.StartTrace = AGDPCOwner.MouseHitWorldLocation + AGDPCOwner.RayDir;
			AGDPCOwner.TraceActor = Trace(AGDPCOwner.MouseHitWorldLocation, AGDPCOwner.MouseHitWorldNormal, AGDPCOwner.EndTrace, AGDPCOwner.StartTrace, true);
			// If the new trace gives back an invalid value then backup
			if(AGDPCOwner.TraceActor == None)
			{
				AGDPCOwner.StartTrace = AGDPCOwner.MouseHitWorldLocation - AGDPCOwner.RayDir;
				AGDPCOwner.TraceActor = Trace(AGDPCOwner.MouseHitWorldLocation, AGDPCOwner.MouseHitWorldNormal, AGDPCOwner.EndTrace, AGDPCOwner.StartTrace, true);
				break;
			}
		}
	}

	//Debugging Purposes
    //Calculate the pawn eye location for debug ray and for checking obstacles on click.
    AGDPCOwner.PawnEyeLocation = Pawn(PlayerOwner.ViewTarget).Location + Pawn(PlayerOwner.ViewTarget).EyeHeight * vect(0,0,1);	
	if(bDrawTraces)
	{
		//Draws path finding and rays.
		super.DrawRoute(Pawn(PlayerOwner.ViewTarget));
		DrawTraceDebugRays();
	}
}

function DrawTraceDebugRays()
{
    //Draw Trace from the camera to the world using
    Draw3DLine(AGDPCOwner.StartTrace, AGDPCOwner.EndTrace, MakeColor(255,128,128,255));

    //Draw eye ray for collision and determine if a clear running is permitted(no obstacles between pawn && destination)
    Draw3DLine(AGDPCOwner.PawnEyeLocation, AGDPCOwner.MouseHitWorldLocation, MakeColor(0,200,255,255));
}

//Toggle Path finding/rays drawing (debug purpose).
exec function ToggleIsometricDebug()
{
    bDrawTraces = !bDrawTraces;
    if(bDrawTraces)
    {
		`Log("Showing debug line trace for mouse");
    }
    else
    {
		`Log("Disabling debug line trace for mouse");
    }
}
//Converts GFx Mouse Coordinates to
//in-game screen coordinates, compensating for differing viewport sizes
function Vector2D GetGFxMouseCoordinates(optional bool bRelative)
{
    local Vector2D MousePos;
    local float coordinateScaling;

	MousePos.X = AGDHudMovie.GetVariableNumber("cursor_mc._x");
	MousePos.Y = AGDHudMovie.GetVariableNumber("cursor_mc._y");

    coordinateScaling = FMin(SizeX / HudGFxSize.X, SizeY / HudGFxSize.Y);
    MousePos *= coordinateScaling;
    MousePos.X += (SizeX - (HudGFxSize.X * coordinateScaling)) / 2;
    MousePos.Y += (SizeY - (HudGFxSize.Y * coordinateScaling)) / 2;

    if (bRelative)
    {
        MousePos.X /= SizeX;
        MousePos.Y /= SizeY;
    }

    return MousePos;
}

function DrawHud()
{
	super.DrawHud();
	
	if(GameMinimap != none && AGDPCOwner.AGDPlayerCamera != None)
		DrawMap();
	
	if(!AGDPCOwner.bCanRotateCam)
	{
	}
}

//Draw 2D Cursor on screen
function DrawCursor()
{
	Canvas.SetPos(AGDPCOwner.MousePosition.X, AGDPCOwner.MousePosition.Y);	
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.DrawTexture(MouseTexture, 1.0);	
}

exec function MapSizeUp()
{
	MapDim *= 2;
	BoxSize *= 2;
}

exec function MapSizeDown()
{
	MapDim /= 2;
	BoxSize /= 2;
}

exec function MapZoomIn()
{
	TileSize = 1.0 / FClamp(Int((1.0 / TileSize) + 1.0) + 0.5,1.5,10.5);
}

exec function MapZoomOut()
{
	TileSize = 1.0 / FClamp(Int((1.0 / TileSize) - 1.0) + 0.5,1.5,10.5);
}

function float GetPlayerHeading()
{
	local Float PlayerHeading;
	local Rotator PlayerRotation;
	local Vector v;

	if (AGDPCOwner.AGDPlayerCamera != None)
	{
		PlayerRotation.Yaw = AGDPCOwner.AGDPlayerCamera.CamRot.Yaw;
		v = vector(PlayerRotation);
		PlayerHeading = GetHeadingAngle(v);
		PlayerHeading = UnwindHeading(PlayerHeading);

		while (PlayerHeading < 0)
			PlayerHeading += PI * 2.0f;
	}
	return PlayerHeading;
}

function DrawMap()
{
	local Float TrueNorth,PlayerHeading;
	local Float MapRotation,CompassRotation;
	local Vector PlayerPos, ClampedPlayerPos, RotPlayerPos, DisplayPlayerPos, StartPos;
	local LinearColor MapOffset;
	local Float ActualMapRange;
	local Controller C;

	//Set MapDim & BoxSize accounting for the current resolution 		
	MapDim = default.MapDim * ResolutionScale;
	BoxSize = default.BoxSize * ResolutionScale;
	MapPosition.X = FullWidth - MapDim;
	MapPosition.Y = default.MapPosition.Y * FullHeight;
	

	//Calculate map range values
	ActualMapRange = FMax(	GameMinimap.MapRangeMax.X - GameMinimap.MapRangeMin.X,
						GameMinimap.MapRangeMax.Y - GameMinimap.MapRangeMin.Y);

	//Calculate normalized player position
	PlayerPos.X = (AGDPCOwner.AGDPlayerCamera.CamLoc.Y - GameMinimap.MapCenter.Y) / ActualMapRange;
	PlayerPos.Y = (GameMinimap.MapCenter.X - AGDPCOwner.AGDPlayerCamera.CamLoc.X) / ActualMapRange;

	//Calculate clamped player position
	ClampedPlayerPos.X = FClamp(PlayerPos.X,-0.5 + (TileSize / 2.0),0.5 - (TileSize / 2.0));
	ClampedPlayerPos.Y = FClamp(PlayerPos.Y,-0.5 + (TileSize / 2.0),0.5 - (TileSize / 2.0));

	//Get north direction and player's heading
	TrueNorth = GameMinimap.GetRadianHeading();
	Playerheading = GetPlayerHeading();

	//Calculate rotation values
	if(GameMinimap.bForwardAlwaysUp)
	{
		MapRotation = PlayerHeading;
		CompassRotation = PlayerHeading - TrueNorth;
	}
	else
	{
		MapRotation = PlayerHeading - TrueNorth;
		CompassRotation = MapRotation;
	}

	//Calculate position for displaying the player in the map
	DisplayPlayerPos.X = VSize(PlayerPos) * Cos( ATan2(PlayerPos.Y, PlayerPos.X) - MapRotation);
	DisplayPlayerPos.Y = VSize(PlayerPos) * Sin( ATan2(PlayerPos.Y, PlayerPos.X) - MapRotation);

	//Calculate player location after rotation
	RotPlayerPos.X = VSize(ClampedPlayerPos) * Cos( ATan2(ClampedPlayerPos.Y, ClampedPlayerPos.X) - MapRotation);
	RotPlayerPos.Y = VSize(ClampedPlayerPos) * Sin( ATan2(ClampedPlayerPos.Y, ClampedPlayerPos.X) - MapRotation);

	//Calculate upper left UV coordinate
	StartPos.X = FClamp(RotPlayerPos.X + (0.5 - (TileSize / 2.0)),0.0,1.0 - TileSize);
	StartPos.Y = FClamp(RotPlayerPos.Y + (0.5 - (TileSize / 2.0)),0.0,1.0 - TileSize);
	//StartPos.X = FClamp(DisplayPlayerPos.X + (0.5 - (TileSize / 2.0)),TileSize/-2,1.0 - TileSize/2);
	//StartPos.Y = FClamp(DisplayPlayerPos.Y + (0.5 - (TileSize / 2.0)),TileSize/-2,1.0 - TileSize/2);

	//Calculate texture panning for alpha
	MapOffset.R =  FClamp(-1.0 * RotPlayerPos.X,-0.5 + (TileSize / 2.0),0.5 - (TileSize / 2.0));
	MapOffset.G =  FClamp(-1.0 * RotPlayerPos.Y,-0.5 + (TileSize / 2.0),0.5 - (TileSize / 2.0));
	//MapOffset.R =  FClamp(-1.0 * DisplayPlayerPos.X,-0.5,0.5);
	//MapOffset.G =  FClamp(-1.0 * DisplayPlayerPos.Y,-0.5,0.5);

	//Set the material parameter values
	MinimapInst.SetScalarParameterValue('MapRotation',MapRotation);
	MinimapInst.SetScalarParameterValue('TileSize',TileSize);
	MinimapInst.SetVectorParameterValue('MapOffset',MapOffset);
	CompassOverlayInst.SetScalarParameterValue('CompassRotation',CompassRotation);

	//Draw the map
	Canvas.SetPos(MapPosition.X,MapPosition.Y);
	Canvas.DrawMaterialTile(GameMinimap.Minimap,MapDim,MapDim,StartPos.X,StartPos.Y,TileSize,TileSize);

	//Draw the player's location
	Canvas.SetPos(	MapPosition.X + MapDim * (((DisplayPlayerPos.X + 0.5) - StartPos.X) / TileSize) - (BoxSize / 2),
				MapPosition.Y + MapDim * (((DisplayPlayerPos.Y + 0.5) - StartPos.Y) / TileSize) - (BoxSize / 2));
	Canvas.SetDrawColor(PlayerColors[0].R,
					PlayerColors[0].G,
					PlayerColors[0].B,
					PlayerColors[0].A);
	Canvas.DrawBox(BoxSize,BoxSize);
	
	/*****************************
	*  Draw Other Players
	*****************************/

	foreach WorldInfo.AllControllers(class'Controller',C)
	{
		if(PlayerController(C) != PlayerOwner)
		{
			//Calculate normalized player position
			PlayerPos.Y = (GameMinimap.MapCenter.X - C.Pawn.Location.X) / ActualMapRange;
			PlayerPos.X = (C.Pawn.Location.Y - GameMinimap.MapCenter.Y) / ActualMapRange;

			//Calculate position for displaying the player in the map
			DisplayPlayerPos.X = VSize(PlayerPos) * Cos( ATan2(PlayerPos.Y, PlayerPos.X) - MapRotation);
			DisplayPlayerPos.Y = VSize(PlayerPos) * Sin( ATan2(PlayerPos.Y, PlayerPos.X) - MapRotation);

			if(VSize(DisplayPlayerPos - RotPlayerPos) <= ((TileSize / 2.0) - (TileSize * Sqrt(2 * Square(BoxSize / 2)) / MapDim)))
			{
				//Draw the player's location
				Canvas.SetPos(	MapPosition.X + MapDim * (((DisplayPlayerPos.X + 0.5) - StartPos.X) / TileSize) - (BoxSize / 2),
							MapPosition.Y + MapDim * (((DisplayPlayerPos.Y + 0.5) - StartPos.Y) / TileSize) - (BoxSize / 2));
				Canvas.SetDrawColor(PlayerColors[1].R,
								PlayerColors[1].G,
								PlayerColors[1].B,
								PlayerColors[1].A);
				Canvas.DrawBox(BoxSize,BoxSize);
			}
		}
	}

	//Draw the compass overlay
	Canvas.SetPos(MapPosition.X,MapPosition.Y);
	Canvas.DrawMaterialTile(GameMinimap.CompassOverlay,MapDim,MapDim,0.0,0.0,1.0,1.0);
}

DefaultProperties
{
	MouseTexture = Texture2D'EngineResources.Cursors.Arrow'
	AGDHudMovieClass=class'AGDGFxHud'
	
	HudGFxSize = (X=1280, Y=720);

	MapDim=256
	BoxSize=12
	PlayerColors(0)=(R=255,G=255,B=255,A=255)
	PlayerColors(1)=(R=96,G=255,B=96,A=255)
	TileSize=0.4
	MapPosition=(X=0.000000,Y=0.000000)
}