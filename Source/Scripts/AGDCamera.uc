class AGDCamera extends Camera;

var float Dist;

//Default Camera Variables
var const Vector DefaultCamLoc;
var const Rotator DefaultCamRot;
var const float DefaultCamDist;

//Adjustable Camera Variables
var Vector CamLoc;
var Rotator CamRot;

function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	local vector            Loc, Pos;
	local rotator           Rot;

	switch( CameraStyle )
	{			
		case 'AGDIsometric': 
			Rot.Pitch = (-55.0f * DegToRad) * RadToUnrRot;
			Rot.Yaw = CamRot.Yaw;

			Loc.X = CamLoc.X;
			Loc.Y = CamLoc.Y;
			Loc.Z = PCOwner.Pawn.Location.Z + 156;

			Pos = Loc - Vector(Rot) * FreeCamDistance;

			OutVT.POV.Location = Pos;
			OutVT.POV.Rotation = Rot;
			
		break;

		default: 
			OutVT.Target.GetActorEyesViewPoint(OutVT.POV.Location, OutVT.POV.Rotation);
		break;
	}		
}

//Calculate Camera Movement left/right according to the rotation of the camera
function CalculateMovementLR(float  value)
{
	CamLoc.X += (value * -Sin(CamRot.Yaw * UnrRotToRad));
	CamLoc.Y += (value * Cos(CamRot.Yaw * UnrRotToRad));
}
//Calculate Camera Movement forward/backward according to the rotation of the camera
function CalculateMovementFB(float value)
{
	CamLoc.X += (value * -Cos(CamRot.Yaw * UnrRotToRad));
	CamLoc.Y += (value * -Sin(CamRot.Yaw * UnrRotToRad));
}

DefaultProperties
{
	DefaultFOV = 90.f
	DefaultCamDist = 300.f
	FreeCamDistance = 300.f
	CamLoc = (X = -7050, Y=-882)
}