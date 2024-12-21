package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxBasic;
import flixel.system.scaleModes.*;

class RPGAreaState extends FlxUIState
{
	private var controls(get, never):Controls;

	public var controlMode:String = 'Mouse';

	public static var rpgInstance:RPGAreaState;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		super.create();

		// Custom made Trans out
		if(!skip) {
			openSubState(new CustomFadeTransition(0.7, true));
		}
		FlxTransitionableState.skipNextTransOut = false;

		if (controlMode == "Mouse")
			FlxG.mouse.visible = true;
		else
			FlxG.mouse.visible = false;
	}
	
	#if (VIDEOS_ALLOWED && windows)
	override public function onFocus():Void
	{
		FlxVideo.onFocus();
		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		FlxVideo.onFocusLost();
		super.onFocusLost();
	}
	#end

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controlMode == 'Keyboard' && FlxG.mouse.justMoved && !FlxG.keys.justPressed.ANY) {
			controlMode = 'Mouse';
			FlxG.mouse.visible = true;
		}

		if (controlMode == 'Mouse' && !FlxG.mouse.justMoved && FlxG.keys.justPressed.ANY) {
			controlMode = 'Keyboard';
			FlxG.mouse.visible = false;
		}
	}

	public static function switchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:RPGAreaState = curState;
		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new CustomFadeTransition(0.7, false));
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		RPGAreaState.switchState(FlxG.state);
	}

	public static function getState():RPGAreaState {
		var curState:Dynamic = FlxG.state;
		var leState:RPGAreaState = curState;
		return leState;
	}
}
