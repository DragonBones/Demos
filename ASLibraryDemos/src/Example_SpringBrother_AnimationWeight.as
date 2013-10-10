package  
{
	import flash.display.Sprite;
	
	import starling.core.Starling;
	
	[SWF(width="800", height="600", frameRate="60", backgroundColor="#cccccc")]
	public class Example_SpringBrother_AnimationWeight extends flash.display.Sprite 
	{
		public function Example_SpringBrother_AnimationWeight() 
		{
			starlingInit();
		}
		
		private function starlingInit():void 
		{
			var starling:Starling = new Starling(StarlingGame, stage);
			starling.showStats = true;
			starling.start();
		}
	}
}

import flash.events.Event;
import flash.geom.Point;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.animation.AnimationState;
import dragonBones.animation.WorldClock;
import dragonBones.display.StarlingDisplayBridge;
import dragonBones.events.AnimationEvent;
import dragonBones.events.FrameEvent;
import dragonBones.factorys.StarlingFactory;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.extensions.PDParticleSystem;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.HAlign;

class StarlingGame extends Sprite 
{
	[Embed(source = "../assets/SpringBrother.dbswf", mimeType = "application/octet-stream")]
	public static const ResourcesData:Class;
	
	private var _factory:StarlingFactory;
	private var _armature:Armature;
	private var _armatureDisplay:Sprite;
	
	private var _arm:Bone;
	
	private var _textField:TextField;
	private var _textField2:TextField;
	
	private var animationState:AnimationState;
	private var weight:Number = 0.5;
	
	public function StarlingGame() 
	{
		_factory = new StarlingFactory();
		_factory.parseData(new ResourcesData());
		_factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}
	
	private function textureCompleteHandler(e:Event):void 
	{
		_armature = _factory.buildArmature("SpringBrother/charactor");
		
		_armatureDisplay = _armature.display as Sprite;
		_armatureDisplay.x = 400;
		_armatureDisplay.y = 400;
		
		this.addChild(_armatureDisplay);
		WorldClock.clock.add(_armature);
		updateMovement();
		
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyEventHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyEventHandler);
		
		_textField = new TextField(700, 50, "Press A/D to move.\nPress W to increase animation weight. Press S to decrease animation weight.", "Verdana", 16, 0, true)
		_textField.hAlign = HAlign.LEFT;
		_textField.x = 60;
		_textField.y = 0;
		
		_textField2 = new TextField(700, 50, "Animation Weight: " + weight, "Verdana", 16, 0, true);
		_textField2.hAlign = HAlign.LEFT;
		_textField2.x = 60;
		_textField2.y = 55;
		this.addChild(_textField);
		this.addChild(_textField2);
	}
	
	private function enterFrameHandler(e:EnterFrameEvent):void 
	{
		updateSpeed();
		WorldClock.clock.advanceTime(-1);
	}
	
	private function keyEventHandler(e:KeyboardEvent):void 
	{
		switch (e.keyCode) 
		{
			case 37 :
			case 65 :
				_isLeftDown = e.type == KeyboardEvent.KEY_DOWN;
				move(-1);
				break;
			case 39 :
			case 68 :
				_isRightDown = e.type == KeyboardEvent.KEY_DOWN;
				move(1);
				break;
			case 38 :
			case 87 :
				if (e.type == KeyboardEvent.KEY_DOWN) 
				{
					increaseWeight();
				}
				break;
			case 83 :
			case 40 :
				if (e.type == KeyboardEvent.KEY_DOWN) 
				{
					decreaseWeight();
				}
				break;
		}
	}
	
	private function increaseWeight():void{
		trace("add");
		if(weight<1)
		{
			
		  weight+=0.1;
		  weight = Math.round(weight * 10)/10;
		 _textField2.text = "Animation Weight: " + weight.toString();
		}
	}
	
	private function decreaseWeight():void{
		trace("decrese");
		if(weight>0.5)
		{
			
			weight-=0.1;
			weight = Math.round(weight * 10)/10;
		    _textField2.text = "Animation Weight: " + weight.toString();
		}
	}
	
	private var _isLeftDown:Boolean;
	private var _isRightDown:Boolean;
	private var _moveDir:int;
	
	private var _speedX:Number = 0;
	private var _speedY:Number = 0;
	
	private function move(dir:int):void 
	{
		if (_isLeftDown && _isRightDown) 
		{
		}
		else if (_isLeftDown)
		{
			dir = -1;
		}
		else if (_isRightDown)
		{
			dir = 1;
		}
		else 
		{
			dir = 0;
		}
		
		if (_moveDir == dir) 
		{
			return;
		}
		_moveDir = dir;
		updateMovement();
	}

	private function updateMovement():void 
	{
		if (_moveDir == 0) 
		{
			_speedX = 0;
			animationState = _armature.animation.gotoAndPlay("stand");
			animationState.weight = weight;
		}
		else 
		{
			_speedX = _moveDir * 8 * weight;
			animationState = _armature.animation.gotoAndPlay("run");
			animationState.weight = weight;
			_armatureDisplay.scaleX = -_moveDir;
		}
	}
	
	private function updateSpeed():void 
	{
		if (_speedX != 0) 
		{
			_armatureDisplay.x += _speedX;
			if (_armatureDisplay.x < 0) 
			{
				_armatureDisplay.x = 0;
			}
			else if (_armatureDisplay.x > 800) 
			{
				_armatureDisplay.x = 800;
			}
		}
		
		if (_speedY != 0) 
		{
			_armatureDisplay.rotation = _speedY * 0.02 * _armatureDisplay.scaleX;
			_armatureDisplay.y += _speedY;
			if (_armatureDisplay.y > 400) 
			{
				_armatureDisplay.y = 400;
				_speedY = 0;
				_armatureDisplay.rotation = 0;
				updateMovement();
			}
		}
	}
}