// Handles the day night cycle in the game. Place one in the level. The location you place it is irrelevent.

class AGDTimeCycle extends DirectionalLight placeable;

var Rotator Angle;     // The angle of the light
var() float CycleTime;   // The length of time in seconds it takes to complete 1 24 hour cycle. Used for angle interpolation.
var() float CurrentTime; // The current time of the cycle, in 24 hour format e.g. 1743 = 43 past 5 pm
var bool PauseCycle;   // Can temporarily pause the cycle

// handling the pitch. 270 degrees = mid day. 90 degrees = mid night.

function PostBeginPlay()
{
	super.PostBeginPlay();
}

function Tick(float DeltaTime)
{   
	if (!PauseCycle)
		UpdateTime(DeltaTime);
}

function UpdateTime(float DeltaTime)
{
	local float Pitch;

	CurrentTime += 2400 / CycleTime * DeltaTime;

	if (CurrentTime >= 2400)
		CurrentTime = CurrentTime - 2400;

	Pitch = ((360 / 2400) * CurrentTime);
	Angle.Pitch = (Pitch + 90) * DegToRad * RadToUnrRot;

	SetRotation(Angle);
}

defaultproperties
{
	Begin Object Class=DominantDirectionalLightComponent Name=DominantDirectionalLightComponent0
	    LightAffectsClassification=LAC_DYNAMIC_AND_STATIC_AFFECTING

	    CastShadows=TRUE
	    CastStaticShadows=TRUE
	    CastDynamicShadows=TRUE
	    bForceDynamicLight=TRUE
	    UseDirectLightMap=FALSE
        bAllowPreShadow=TRUE

		WholeSceneDynamicShadowRadius = 10000;
		NumWholeSceneDynamicShadowCascades = 3;
		CascadeDistributionExponent = 3;

	    LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,bInitialized=TRUE)
        LightmassSettings=(LightSourceAngle=.2)
	End Object
	Components.Remove(DirectionalLightComponent0)
    LightComponent=DominantDirectionalLightComponent0
	Components.Add(DominantDirectionalLightComponent0)

	bMovable=TRUE
	bStatic=FALSE



	CycleTime = 10;
}