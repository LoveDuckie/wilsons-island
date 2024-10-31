class AGDGFxDebugText extends GFxMoviePlayer;

var AGDPlayerController PCGfx;

function Init( optional LocalPlayer LocPlay )
{
	super.Init(LocPlay);

	Start();
	Advance(0.0f);	
}

//Set movie controller
function SetPlayerController(AGDPlayerController gfxPlayerController)
{
	PCGfx = gfxPlayerController;
}

DefaultProperties
{
	
	bDisplayWithHudOff = false	
	bEnableGammaCorrection=false	
    bIgnoreMouseInput = false
    bPauseGameWhileActive = false
    bCaptureInput = false

	MovieInfo = SwfMovie'AGDHUD.DebugFlash'

}
