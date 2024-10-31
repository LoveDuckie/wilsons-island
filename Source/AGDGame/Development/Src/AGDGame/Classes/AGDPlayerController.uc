/*******************************************************************************
	AGDPlayerController
*******************************************************************************/

class AGDPlayerController extends UDKPlayerController;

enum GameState
{
	MainMenu,
	Playing,
};

var GameState CurrentGameState;

//Camera Variables
var AGDCamera AGDPlayerCamera;
var bool bUpdateCamPos;
var bool bCanRotateCam;
var float ScrollSpeed;
var const float MinCamDist;
var const float MaxCamDist;

//Audio stuff
var AudioComponent _audiocomponent;
var SoundCue _click;
//Mouse Variables
var AGDMeshMouseCursor MouseCursor;
var Vector2D MousePosition;
var Vector2D ScreenSize;  
var Vector2D MouseDelta;  

//Mouse Deprojection Variables
var Vector MouseWorldLocation;  //Hold deprojected mouse location in 3d world coordinates. 
var Vector MouseWorldDirection; //Hold deprojected mouse location normal (for direction). 

//Mouse Trace/Path Finding variables. 
//Calculation in AGDHUD Post Render 
var Vector MouseHitWorldLocation;  //Point where the mouse exist in 3D space
var Vector MouseHitWorldNormal;   
var vector StartTrace;                 //Hold calculated start of ray from camera
var Vector EndTrace;                   //Hold calculated end of ray from camera to ground
var vector RayDir;                     //Hold the direction for the ray query.
var Vector PawnEyeLocation;            //Hold location of pawn eye to detect obstacles
var Actor  TraceActor;                 //If an actor is found under mouse cursor when mouse moves, its going to end up here.

//Spawning function variables
var DynamicSMActor_Spawnable SpawningActor;		//Holds the information for spawning a new object
var float SpawningActorCollisionRadius;			//This is used for collision with other DynamicSMActor_Spawnable objects
var float SpawningActorCollisionHeight;			//This is used for collision with other DynamicSMActor_Spawnable objects
var bool bPlayerHasObject;						//This bool states if the player is "holding" an object
var bool bCanPlaceObject;						//This bool states if the player can place the "holding" object

//Mouse Selection variables (e.g. characters, buildings etc...)
var String ObjectName;

//GFx Variables
var AGDGFxStructure GFxObjectSelected;
var string MouseMovieState;

var array<AGDCHPawn> _selectedPawns;
var array<AGDMeshSelectedChar> _selectedMeshes;
var bool _multiclick;

var AGDStructure Structure;
var AGDStructureStorage HomeStorage;
var bool bShowObjectInfo;

var AGDGFxMainMenu GFxMainMenu;

var bool HasClicked;
var bool HasDoubleClicked;
var float DoubleClickTime;

//Called after game loaded - initialise things
simulated function PostBeginPlay()
{
	`Log("AGDPlayerController::PostBeginPlay() Begin");
	super.PostBeginPlay();

	_audiocomponent = new class'AudioComponent';
	_audiocomponent.SoundCue = _click;
	
	LoadEnvironment();

	
	
	`Log("AGDPlayerController::PostBeginPlay() End");
}

// Closes the main menu
function CloseMainMenu()
{
	GFxMainMenu.Close(true);
	GFxMainMenu = none;
}

// Shows the main menu
function ShowMainMenu()
{
	CloseMainMenu();

	GFxMainMenu = new class'AGDGFxMainMenu';
	GFxMainMenu.SetTimingMode(TM_Real);
	GFxMainMenu.Init();		
	GFxMainMenu.SetPriority(0);
}

event PlayerTick(float DeltaTime)
{
	local AGDEntity _entity;
	local AGDStructure tempStructure;
	if (HasClicked)
	{
		DoubleClickTime += DeltaTime;
		if (DoubleClickTime > 0.5f)
		{
			DoubleClickTime = 0;
			HasClicked = false;
			HasDoubleClicked = false;
		}
	}

	if (CurrentGameState == MainMenu)
	{
		if (GFxMainMenu == none)
			ShowMainMenu();
		else
			GFxMainMenu.Update(self);
	}
	else
	{
		if (GFxMainMenu != none)
			CloseMainMenu();

		UpdateCamera();	
	
		if(!bCanRotateCam)
			UpdateMouse();
		SpawningActorUpdate();		// When "holding" an object, update it's position until it is placed
		
		foreach AllActors(class'AGDStructure', tempStructure)
		{
			if (!tempStructure.Selected)
			{
				tempStructure.CloseSelection();
			}
		}
	}

	//look for entities that have had their resource sucked dry
	foreach AllActors(class'AGDEntity', _entity)
	{
		if (_entity._amount == 0)

		{
			//remove them
			_entity.Destroy();
		}
	}
}

exec function SkipMessageExec()
{
	`log("AGDPlayerController::SkipMessageExec was pressed.");


	if (AGDHUD(myHUD) != none)
	{
		`log("AGDPlayerController::Skipping message");

		if (AGDHUD(myHUD)._tooltip != none)
		{
			_audiocomponent.Play();
			AGDHUD(myHUD)._tooltip.SkipMessage();
		}		
	}
	else
	{
		`log("AGDPlayerController::Failing to skip message.");
	}
}

// Load in the environment based on EntityMarkers within the level
function LoadEnvironment()
{
	local AGDEntityMarker _marker;
	local AGDEntity _entity;
	local AGDStructureStorage _storage;
		
	local int _rand;
	
	foreach AllActors(class'AGDEntityMarker', _marker)
	{
		_entity = Spawn(class'AGDEntity');
		_entity.SetLocation(_marker.Location);

		_rand = Rand(3);
		
		// Has the marker been set to generate a random entity?

		// Yes
		if (_marker._random == true)
		{
			switch(_rand)
			{
				// Rocks
			case 0:
					_entity._type = 0;				
				break;

				// Trees
			case 1:
					_entity._type = 1;
				break;

				// Berries
			case 2:
					_entity._type = 2;
				break;
			
			default:

				break;
			}
		}
		else // No
		{
			_entity._type = _marker._type;
		}

		// The marker has been used, move on.
		_marker._assigned = true;
	}

	foreach AllActors(class'AGDStructureStorage', _storage)
	{
		HomeStorage = _storage;
	}
}

//Update MousePosition
function UpdateMouse()
{
	MousePosition = AGDHUD(myHUD).GetGFxMouseCoordinates(false);

	MousePosition.X = Clamp(MousePosition.X, 0, ScreenSize.X - 5);
	MousePosition.Y = Clamp(MousePosition.Y, 0, ScreenSize.Y - 5);
}

//Update the Position, Location, Rotation of the camera
function UpdateCamera()
{
	AGDPlayerCamera = AGDCamera(PlayerCamera);

	//If in rotation mode
	if(bCanRotateCam)
	{
		if(PlayerInput.aMouseX > 0)
			AGDPlayerCamera.CamRot.Yaw += ((5 * DegToRad) * RadToUnrRot);
		else if (PlayerInput.aMouseX < 0)
			AGDPlayerCamera.CamRot.Yaw -= ((5 * DegToRad) * RadToUnrRot);
	}
	else //If mouse is at the edges of the screen
	{		
		//Move Camera
		//Left
		if(MousePosition.X <= 5)
			AGDPlayerCamera.CalculateMovementLR(ScrollSpeed * -1);
		//Right
		else if(MousePosition.X >= ScreenSize.X - 5)
			AGDPlayerCamera.CalculateMovementLR(ScrollSpeed);
		//Up
		if(MousePosition.Y <= 5)
			AGDPlayerCamera.CalculateMovementFB(ScrollSpeed * -1);
		//Down
		else if(MousePosition.Y >= ScreenSize.Y - 5)
			AGDPlayerCamera.CalculateMovementFB(ScrollSpeed);
	}
}

// Deselects all characters
function DeselectAllCharacters()
{
	local AGDCHController tempController;

	foreach AllActors(class'AGDCHController', tempController)
			tempController.Selected = false;
}

// Deselects all characters
function DeselectAllStructures()
{
	local AGDStructure tempStruct;

	foreach AllActors(class'AGDStructure', tempStruct)
			tempStruct.Selected = false;
}


//Get Object under the mouse cursor
function GetObjectUnderMouse()
{
	if (!HasClicked)
		HasClicked = true;
	else
		HasDoubleClicked = true;

	if (AGDCHPawn(TraceActor) == none)
	{
		DeselectAllCharacters();
	}

	if (AGDStructure(TraceActor) == none)
	{
		DeselectAllStructures();
	}

	if (AGDCHPawn(TraceActor) != None)
	{
		
		// If multi-click is not set then disable all the characters.
		if (!self._multiclick)
		{
			DeselectAllCharacters();
		}
		
		AGDCHController(AGDCHPawn(TraceActor).Controller).Selected = true;

		if (HasDoubleClicked)
		{
			AGDCHController(AGDCHPawn(TraceActor).Controller).ShowInfo();
		}
		AGDHUD(myHUD)._tooltip.PushMessage("Actor added!",true);
	}
	else if (AGDStructure(TraceActor) != None)
	{
		DeselectAllStructures();

		_audiocomponent.Play();
		Structure = AGDStructure(TraceActor);
		Structure.Selected = true;
		Structure.SetPlayerController(self);
	}
	else if (AGDEntity(TraceActor) != None)
	{
		`Log(AGDEntity(TraceActor)._type);
		`Log(AGDEntity(TraceActor)._amount);
		_audiocomponent.Play();
	}
	else if (AGDFishEntity(TraceActor) != none)
	{
		`Log("AGDPlayerController::FishEntity has been selected with an amount of " $ AGDFishEntity(TraceActor)._amount);
		AGDHUD(myHUD)._tooltip.PushMessage("Fish Entity with " $ AGDFishEntity(TraceActor)._amount $ " was selected!",true);
		AGDFishEntity(TraceActor)._selected = true;	
		_audiocomponent.Play();
	}
	else
	{
		if (TraceActor.Tag != 'WorldInfo' && TraceActor.Tag != 'Terrain')
		{
			`Log("This is what you clicked on:");
			`Log("Object: " @ TraceActor);
			`Log("Tag: " @ TraceActor.Tag);
		}
	}
}
//Update the location of the SpawningActor (until it is placed)
function SpawningActorUpdate()
{
	local Rotator zeroRotation;		//empty rotator for setting the orientation of the spawned object
	local Vector newLocation;		//the spawned objects new location
	local Actor OtherActor;								//used for collisions
	local DynamicSMActor_Spawnable OtherSpawn;			//used for collisions
	local vector diffLoc;								//used for collisions
	
	if(bPlayerHasObject)
	{
		SpawningActor.SetRotation(zeroRotation);
		newLocation = MouseCursor.Location;
		
		bCanPlaceObject = false;
		
		if(TraceActor.Tag == 'WorldInfo' || TraceActor.Tag == 'Terrain')
		{
			bCanPlaceObject = true;
			
			// check for colliding actors
			foreach SpawningActor.TouchingActors(class'Actor', OtherActor)
			{
				//`Log("OtherActor: " @ OtherActor);
				// Ignore Terrain Collision for now
				if(OtherActor.Tag != 'Terrain')
				{
					bCanPlaceObject = false;
					break;
				}
			}
			// check for colliding "Spawnables"
			// TouchingActors didn't seem to work for DynamicSMActor_Spawnable and so I
			// created my own way of doing it (which isn't perfect right now)
			ForEach DynamicActors(class'DynamicSMActor_Spawnable', OtherSpawn)
			{
				if(OtherSpawn != SpawningActor)
				{
					diffLoc.X = Abs(OtherSpawn.Location.X - SpawningActor.Location.X);
					diffLoc.Y = Abs(OtherSpawn.Location.Y - SpawningActor.Location.Y);
					diffLoc.Z = Abs(OtherSpawn.Location.Z - SpawningActor.Location.Z);
					//`Log("OtherSpawn Found!");
					if(diffLoc.X < SpawningActorCollisionRadius &&
					   diffLoc.Y < SpawningActorCollisionRadius &&
					   diffLoc.Z < SpawningActorCollisionHeight)
					{
						bCanPlaceObject = false;
						break;
					}
				}
			}
		}
		
		// if the object cannot be placed add a red ambient light to the object
		if(!bCanPlaceObject)
		{
			SpawningActor.LightEnvironment.AmbientGlow.R = 1.0f;
		}
		else
		{
			SpawningActor.LightEnvironment.AmbientGlow.R = 0.0f;
		}

		SpawningActor.SetLocation(newLocation);
	}
}

//Place an object under the mouse cursor
function PlaceObjectUnderMouse()
{
	SpawningActor = Spawn(class'DynamicSMActor_Spawnable');
	SpawningActor.StaticMeshComponent.SetStaticMesh(StaticMesh'NEC_Pillars.SM.Mesh.S_NEC_Pillars_SM_Techpillar01a');
	SpawningActor.SetLocation(MouseCursor.Location);
	SpawningActor.bBlocksNavigation = true;
	SpawningActor.GetBoundingCylinder(SpawningActorCollisionRadius, SpawningActorCollisionHeight);
	SpawningActor.LightEnvironment.MinTimeBetweenFullUpdates = 0.0f;
}

//>>>>>>>>>>>>>>>>>>>>>>>>>>>//
// Camera command functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//>>>>>>>>>>>>>>>>>>>>>>>>>>//
exec function CamZoomIn()
{
	AGDCamera(PlayerCamera).FreeCamDistance -= 20;
	AGDCamera(PlayerCamera).FreeCamDistance = Clamp(AGDCamera(PlayerCamera).FreeCamDistance, MinCamDist, MaxCamDist);
}
exec function CamZoomOut()
{
	AGDCamera(PlayerCamera).FreeCamDistance += 20;
	AGDCamera(PlayerCamera).FreeCamDistance = Clamp(AGDCamera(PlayerCamera).FreeCamDistance, MinCamDist, MaxCamDist);
}
	
//Set Mouse Movement to Camera Rotation
exec function RotateCam()
{
	bCanRotateCam = true; 
}
//Unset Camera Rotation mode
exec function UnRotateCam()
{
	bCanRotateCam = false;
}
//Reset Camera to it's default state
exec function DefaultCamera()
{
	if(!bCanRotateCam)
	{
		AGDPlayerCamera.FreeCamDistance = AGDPlayerCamera.DefaultCamDist;
		AGDPlayerCamera.CamLoc = AGDPlayerCamera.DefaultCamLoc;
		AGDPlayerCamera.CamRot = AGDPlayerCamera.DefaultCamRot;
	}
}

//>>>>>>>>>>>>>>>>>>>>>>>>>>>//
// Mouse command functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//>>>>>>>>>>>>>>>>>>>>>>>>>>//
//Select object (LeftMouseButton)
exec function GetMouseSelection()
{
	if(MouseMovieState != "over")
	{
		if(!bPlayerHasObject)
		{
			GetObjectUnderMouse();
		}
		else if (bCanPlaceObject)
		{
			bPlayerHasObject = false;
			SpawningActor = None;
		}
	}
}
//Action command (RightMouseButton)
exec function DoActionCommand()
{	
	local AGDCHController tempController;

	if(MouseMovieState != "over")
	{
		foreach AllActors(class'AGDCHController', tempController)
		{
			if (tempController.Selected)
			{
				tempController.MoveToLocation(MouseHitWorldLocation, TraceActor);

				if (AGDEntity(tempController.CharacterTarget) != none)
				{
					`Log("Current Target of Pawn: " @ AGDEntity(tempController.CharacterTarget)._type);
				}
				if (AGDStructure(tempController.CharacterTarget) != none)
				{
					`Log("Current Target of Pawn: " @ AGDStructure(tempController.CharacterTarget));
				}
				else if (AGDFishEntity(tempController.CharacterTarget) != none)
				{
					`Log("Current Target of Pawn (Fish): " @ AGDFishEntity(tempController.CharacterTarget).Name);
				}
			}
		}
	}
}

//Add object (currently Key O)
exec function AddObjectTest()
{
	if(!bPlayerHasObject)
	{
		bPlayerHasObject = true;
		PlaceObjectUnderMouse();
	}
}
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//>>>>>>>>>>>>>>>>>>>>>>>>>>>//
// Debugging exec functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//>>>>>>>>>>>>>>>>>>>>>>>>>>//
//Set camera scroll speed
exec function SetScrollSpeed(float value)
{
	ScrollSpeed = value;
}

exec function MultiClick()
{
	local int i;

	`log("AGDPlayerController::MultiClick pressed");

	if (_multiclick)
	{
		_multiclick = false;


		`log("AGDPlayerController::MultiClick Disabled");

		// Clear out the selection
		for (i = 0; i < self._selectedPawns.Length; i++)
		{
			if (_selectedPawns[i] != none)
			{
				_selectedPawns.RemoveItem(_selectedPawns[i]);
			}

		}	

		`log("AGDPlayerController::Length of SelectedPawns: " $ _selectedPawns.Length);
		`log("AGDPlayerController::Length of SelectedMeshes: " $ _selectedMeshes.Length);
	}
	else
	{
		`log("AGDPlayerController::MultiClick Enabled");

		_multiclick = true;
	}
	
}

DefaultProperties
{
	CurrentGameState = MainMenu;

	CameraClass=class'AGDCamera'
	InputClass=class'AGDGame.AGDPlayerInput'
	ScrollSpeed = 30
	MousePosition = (X= 500, Y= 350);
	bHidden=true
	MinCamDist = 50;
	MaxCamDist = 600;
	bShowObjectInfo = false;
	_multiclick = false;

	// Clicking sound.
	_click = SoundCue'GameSounds.Misc.Click_Cue'
}
