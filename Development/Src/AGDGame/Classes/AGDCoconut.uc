class AGDCoconut extends Actor;

struct Message
{
	var string _message;
	var bool _skippable; // Is the message allowed to be skipped?
};

var array<string> _introLines;
var array<string> _messageQueue;

var array<Message> _structMessageQueue;

var array<Message> _introLinesStruct;

var AGDHUD _hud;
var AGDPlayerController _pc;

// If a message has to be pushed out without requiring input (spacebar), then
// this is the amount of time it'll take for each message.
var float _urgencytimer;

var GFxObject _coconutText;

var bool _enable; // Coconut tip is enabled

var int _charScroll; // How much of the message is being displayed i.e. only "happ" of "happiness" is 3 (starting from 0)

var int _queueIndex;

var string _currentMessage;

function string GetMessage()
{
	if (_enable == true)
	{
		if (_structMessageQueue.Length > _queueIndex)
		{
			return Mid(_structMessageQueue[_queueIndex]._message,0,_charScroll);
			//`log("AGDCoconut:: TempString is " $ _tempString);			
		}
		else
		{
			return "";
		}
	}
	else
	{
		// Don't return anything for the post render;
		return "";
	}
}

// Clear out the message queue.
function Clear()
{
	local int i;
	
	//`log("AGDCoconut::Clear() started");

	//`log("AGDCoconut::StructMessageQueue Length Before " $ _structMessageQueue.Length);

	for (i = 0; i < _structMessageQueue.Length; i++)
	{
		_structMessageQueue.Remove(i--,1);
	}

	//`log("AGDCoconut::StructmessageQueue Length After " $ _structMessageQueue.Length);
}

function ProcessMessage()
{
	if (_structMessageQueue.Length > 0)
	{
		if (_charScroll <= Len(_structMessageQueue[_queueIndex]._message))
		{
			_charScroll++;
		}
	}
}

function SkipMessage()
{
	// Skip the current message

	if (_structMessageQueue[_queueIndex]._skippable)
	{
		
		_charScroll = 0; // Reset character scroll to the beginning

		// If we have reached the end of the queue then head back to the beginning;
		if (_queueIndex != (_structMessageQueue.Length - 1))
		{
			_queueIndex++;
		}
		else
		{
			_queueIndex = 0;
			Clear(); // Clear the queue
		}
	}
}


function PushMessage(string _message, bool _skippable)
{
	local Message _newMessage;

	if (_message != "")
	{
		_newMessage._message = _message;

		_newMessage._skippable = _skippable;

		// Push the message to the back of the queue
		_structMessageQueue.AddItem(_newMessage);
	}
	

}

event PostBeginPlay()
{
	//local int i; // For debugging purposes.

	// Load up the default introduction lines.
	local Message _introMessageOne;
	local Message _introMessageTwo;
	local Message _introMessageThree;

	_pc = AGDPlayerController(WorldInfo.GetALocalPlayerController());

	_hud = AGDHUD(_pc.myHUD);

	if (_pc == none)
		`Log("AGDCoconut::PlayerController var is dead");

	if (_hud == none)
		`Log("AGDCoconut::HUD Var is dead");

	_introMessageOne._message = "Welcome to Wilsons Island!";
	_introMessageOne._skippable = true;


	_introMessageTwo._message = "5 of you have crash landed on a desert island.";
	_introMessageTwo._skippable = true; 


	_introMessageThree._message = "Find a way to survive :3";
	_introMessageThree._skippable = true;


	_structMessageQueue.AddItem(_introMessageOne);
	_structMessageQueue.AddItem(_introMessageTwo);
	_structMessageQueue.AddItem(_introMessageThree);

	//for (i = 0; i < _structMessageQueue.Length; i++)
	//{
	//	`log("AGDCoconut:: Message queue " $ i $ " says " $ _structMessageQueue[i]._message);
	//}

}

event Tick(float deltaTime)
{

	if (_structMessageQueue.Length != 0)
	{
		ProcessMessage();
		//`log("AGDCoconut:: MessageQueue Length is " $ _structMessageQueue.Length);
	}

	// Character scroll
	//`log("AGDCoconut:: CharacterScroll is " $ _charScroll);
	//`log("AGDCoconut:: QueueIndex is " $ _queueIndex);

	
}

DefaultProperties
{
	_enable = true;
	_queueIndex = 0; // At the beginning of the message loop
	_urgencyTimer = 5.0f;	
	
}
