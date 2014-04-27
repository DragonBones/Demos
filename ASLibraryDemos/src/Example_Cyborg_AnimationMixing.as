package
{
	import flash.display.Sprite;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="60", backgroundColor="#cccccc")]
	public class Example_Cyborg_AnimationMixing extends flash.display.Sprite 
	{

		public function Example_Cyborg_AnimationMixing() 
		{
			starlingInit();
		}

		private function starlingInit():void 
		{
			var starling:Starling = new Starling(StarlingGame, this.stage);
			starling.showStats = true;
			starling.start();
		}
	}
}

import flash.geom.Point;
import flash.events.Event;

import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.TouchEvent;
import starling.events.KeyboardEvent;
import starling.text.TextField;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.animation.Animation;
import dragonBones.animation.AnimationState;
import dragonBones.animation.WorldClock;
import dragonBones.factorys.StarlingFactory;

import dragonBones.events.AnimationEvent;

class StarlingGame extends Sprite 
{
	[Embed(source = "../assets/Cyborg_AnimationMixing.dbswf", mimeType = "application/octet-stream")]
	private static const ResourcesData:Class;
	
	private static const WEAPON_ANIMATION_GROUP:String = "weaponAnimationGroup";
	private static const AIM_ANIMATION_GROUP:String = "aimAnimationGroup";

	private var _textField:TextField;
	private var _factory:StarlingFactory;

	private var _armatureDisplay:Sprite;
	private var _armature:Armature;
	private var _aimState:AnimationState;
	
	private var _mousePoint:Point;
	private var _aimDir:int = 0;
	private var _moveDir:int;
	private var _faceDir:int;

	private var _left:Boolean;
	private var _right:Boolean;
	
	private var _speedX:Number = 0;
	private var _speedY:Number = 0;

	private var _isJumping:Boolean;
	private var _isSquat:Boolean;

	private var _weaponID:int = -1;

	public function StarlingGame() 
	{
		_factory = new StarlingFactory();
		_factory.parseData(new ResourcesData());
		_factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e:Event):void 
	{
		_armature = _factory.buildArmature("cyborg");
		
		_armatureDisplay = _armature.display as Sprite;
		_armatureDisplay.x = 400;
		_armatureDisplay.y = 500;
		
		WorldClock.clock.add(_armature);
		
		updateAnimation();
		changeWeapon();
		
		_textField = new TextField(700, 30, "Press W/A/S/D to move. Press SPACE to switch weapens. Move mouse to aim.", "Verdana", 16, 0, true)
		_textField.x = 60;
		_textField.y = 5;
		
		this.addChild(_armatureDisplay);
		this.addChild(_textField);
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
		this.stage.addEventListener(TouchEvent.TOUCH, mouseHandler);
	}

	private function keyHandler(e:KeyboardEvent):void 
	{
		switch (e.keyCode) 
		{
			case 37 :
			case 65 :
				_left = e.type == KeyboardEvent.KEY_DOWN;
				updateMove(-1);
				break;
			
			case 39 :
			case 68 :
				_right = e.type == KeyboardEvent.KEY_DOWN;
				updateMove(1);
				break;
			
			case 38 :
			case 87 :
				if(e.type == KeyboardEvent.KEY_DOWN) 
				{
					jump();
				}
				break;
				
			case 83 :
			case 40 :
				squat(e.type == KeyboardEvent.KEY_DOWN);
				break;
			
			case 32 :
				if(e.type == KeyboardEvent.KEY_UP) 
				{
					changeWeapon();
				}
				break;
		}
	}

	private function updateMove(dir:int):void 
	{
		if(_left && _right) 
		{
			move(dir);
		}
		else if(_left)
		{
			move(-1);
		}
		else if(_right)
		{
			move(1);
		}
		else
		{
			move(0);
		}
	}

	private function mouseHandler(e:TouchEvent):void 
	{
		try
		{
			_mousePoint = e.getTouch(stage).getLocation(stage);
		}
		catch(err:Error)
		{
		}
	}

	private function enterFrameHandler(e:EnterFrameEvent):void 
	{
		updateSpeed();
		updateWeapon();
		WorldClock.clock.advanceTime(-1);
	}

	private function move(dir:int):void 
	{
		if(_moveDir == dir) 
		{
			return;
		}
		_moveDir = dir;
		updateAnimation();
	}

	private function jump():void 
	{
		if(_isJumping) 
		{
			return;
		}
		_speedY = -15;
		_isJumping = true;
		_armature.animation.gotoAndPlay("jump");
	}

	private function squat(isDown:Boolean):void
	{
		if(_isSquat == isDown) 
		{
			return;
		}
		_isSquat = isDown;
		updateAnimation();
	}

	private function changeWeapon():void 
	{
		_weaponID ++;
		if(_weaponID >= 4) 
		{
			_weaponID -= 4;
		}
		
		var animationName:String = "weapon" + (_weaponID + 1);
		
		_armature.getBone("weapon").displayController = animationName;
		//Animation Mixing
		_armature.animation.gotoAndPlay(
			animationName, 
			-1, -1, NaN, 0, 
			WEAPON_ANIMATION_GROUP, Animation.SAME_GROUP
		);
	}

	private function updateAnimation():void 
	{
		if(_isJumping) 
		{
			return;
		}
		
		if(_isSquat) 
		{
			_speedX = 0;
			_armature.animation.gotoAndPlay("squat");
			return;
		}

		if(_moveDir == 0) 
		{
			_speedX = 0;
			_armature.animation.gotoAndPlay("stand");
		}
		else 
		{
			if(_moveDir * _faceDir > 0) 
			{
				_speedX = 4* _faceDir;
				_armature.animation.gotoAndPlay("run");
			}
			else 
			{
				_speedX = -3 * _faceDir;
				_armature.animation.gotoAndPlay("runBack");
			}
		}
	}

	private function updateSpeed():void 
	{
		if(_isJumping) 
		{
			if(_speedY <= 0 && _speedY + 0.5 > 0 ) 
			{
				_armature.animation.gotoAndPlay("fall");
			}
			_speedY += 0.5;
		}
		if(_speedX != 0) 
		{
			_armatureDisplay.x += _speedX;
			if(_armatureDisplay.x < 0) 
			{
				_armatureDisplay.x = 0;
			}
			else if(_armatureDisplay.x > 800) 
			{
				_armatureDisplay.x = 800;
			}
		}
		if(_speedY != 0) 
		{
			_armatureDisplay.y += _speedY;
			if(_armatureDisplay.y > 500) 
			{
				_armatureDisplay.y = 500;
				_isJumping = false;
				_speedY = 0;
				_speedX = 0;
				_armature.animation.gotoAndPlay("fallEnd");
				_armature.addEventListener(AnimationEvent.FADE_IN, armatureAnimationChangeHandler);
			}
		}
	}

	private function armatureAnimationChangeHandler(e:AnimationEvent):void 
	{
		switch(e.animationName) 
		{
			case "stand":
				_armature.removeEventListener(AnimationEvent.FADE_IN, armatureAnimationChangeHandler);
				updateAnimation();
				break;
		}
	}

	private function updateWeapon():void 
	{
		if(!_mousePoint)
		{
			return;
		}
		
		_faceDir = _mousePoint.x > _armature.display.x?1: -1;
		if(_armature.display.scaleX * _faceDir < 0) 
		{
			_armature.display.scaleX *= -1;
			
			updateAnimation();
		}

		var r:Number;
		if(_faceDir > 0)
		{
			r = Math.atan2(_mousePoint.y - _armature.display.y, _mousePoint.x - _armature.display.x);
		}
		else
		{
			r = Math.PI - Math.atan2(_mousePoint.y - _armature.display.y, _mousePoint.x - _armature.display.x);
			if(r > Math.PI) 
			{
				r -= Math.PI * 2;
			}
		}
		
		var aimDir:int;
		if(r > 0) 
		{
			aimDir = -1;
		}
		else
		{
			aimDir = 1;
		}
		
		if(aimDir != _aimDir)
		{
			_aimDir = aimDir;
			
			//Animation Mixing
			if(_aimDir > 0)
			{
				_aimState = _armature.animation.gotoAndPlay("aimUp", 0, 0, 1, 0, AIM_ANIMATION_GROUP);
			}
			else
			{
				_aimState = _armature.animation.gotoAndPlay("aimDown", 0, 0, 1, 0, AIM_ANIMATION_GROUP);
			}
			//_aimState中，只有body以及其子骨骼有瞄准姿势的改变，过滤掉其他的无关的骨骼混合有利于性能
			_aimState.addMixingTransform("body");
		}
		
		_aimState.weight = Math.abs(r / Math.PI * 2);
		
		_armature.invalidUpdate();
	}
}