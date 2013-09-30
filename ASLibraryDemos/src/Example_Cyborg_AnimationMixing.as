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
			var starling:Starling = new Starling(StarlingGame, stage);
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
import dragonBones.animation.WorldClock;
import dragonBones.factorys.StarlingFactory;

import dragonBones.events.AnimationEvent;

class StarlingGame extends Sprite 
{
	[Embed(source = "../assets/Cyborg_AnimationMixing.dbswf", mimeType = "application/octet-stream")]
	private static const ResourcesData:Class;
	
	private static const WEAPON_ANIMATION_GROUP:String = "weaponAnimationGroup";

	private var _textField:TextField;
	private var _factory:StarlingFactory;
	private var _armature:Armature;
	private var _armatureDisplay:Sprite;

	private var _body:Bone;
	private var _chest:Bone;
	private var _head:Bone;
	private var _armR:Bone;
	private var _armL:Bone;
	private var _weapon:Bone;

	private var _left:Boolean;
	private var _right:Boolean;

	private var _mouseX:Number = 0;
	private var _mouseY:Number = 0;
	private var _isJumping:Boolean;
	private var _isSquat:Boolean;
	private var _moveDir:int;
	private var _face:int;

	private var _weaponID:int = -1;

	private var _speedX:Number = 0;
	private var _speedY:Number = 0;

	public function StarlingGame() 
	{
		_factory = new StarlingFactory();
		_factory.parseData(new ResourcesData());
		_factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e:Event):void 
	{
		_armature = _factory.buildArmature("cyborg");
		_body = _armature.getBone("body");
		_chest = _armature.getBone("chest");
		_head = _armature.getBone("head");
		_armR = _armature.getBone("upperarmR");
		_armL = _armature.getBone("upperarmL");
		_weapon = _armature.getBone("weapon");
		
		_armatureDisplay = _armature.display as Sprite;
		_armatureDisplay.x = 400;
		_armatureDisplay.y = 500;
		
		WorldClock.clock.add(_armature);
		
		changeWeapon();
		
		_textField = new TextField(700, 30, "Press W/A/S/D to move. Press SPACE to switch weapens. Move mouse to aim.", "Verdana", 16, 0, true)
		_textField.x = 60;
		_textField.y = 5;
		
		this.addChild(_armatureDisplay);
		this.addChild(_textField);
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyEventHandler);
	}

	private function onKeyEventHandler(e:KeyboardEvent):void 
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

	private function onMouseMoveHandler(e:TouchEvent):void 
	{
		try
		{
			var p:Point = e.getTouch(stage).getLocation(stage);
			_mouseX = p.x;
			_mouseY = p.y;
		}
		catch(e:Error)
		{
		}
	}

	private function onEnterFrameHandler(e:EnterFrameEvent):void 
	{
		if(stage && !stage.hasEventListener(TouchEvent.TOUCH)) 
		{
			stage.addEventListener(TouchEvent.TOUCH, onMouseMoveHandler);
		}
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
		updateMovement();
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
		updateMovement();
	}

	private function changeWeapon():void 
	{
		_weaponID ++;
		if(_weaponID >= 4) 
		{
			_weaponID -= 4;
		}
		
		var animationName:String = "weapon" + (_weaponID + 1);
		
		
		_weapon.displayController = animationName;
		//Animation Mixing
		_armature.animation.gotoAndPlay(animationName, -1, -1, NaN, 0, WEAPON_ANIMATION_GROUP, "sameGroup");
	}

	private function updateMovement():void 
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
			if(_moveDir * _face > 0) 
			{
				_speedX = 4* _face;
				_armature.animation.gotoAndPlay("run");
			}
			else 
			{
				_speedX = -3 * _face;
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
				_armature.addEventListener(AnimationEvent.MOVEMENT_CHANGE, armatureMovementChangeHandler);
			}
		}
	}

	private function armatureMovementChangeHandler(e:AnimationEvent):void 
	{
		switch(e.movementID) 
		{
			case "stand":
				_armature.removeEventListener(AnimationEvent.MOVEMENT_CHANGE, armatureMovementChangeHandler);
				updateMovement();
				break;
		}
	}

	private function updateWeapon():void 
	{
		_face = _mouseX > _armatureDisplay.x?1: -1;
		if(_armatureDisplay.scaleX * _face < 0) 
		{
			_armatureDisplay.scaleX *= -1;
			updateMovement();
		}

		var r:Number;
		if(_face>0)
		{
			r = Math.atan2(_mouseY - _armatureDisplay.y, _mouseX - _armatureDisplay.x);
		}
		else
		{
			r = Math.PI - Math.atan2(_mouseY - _armatureDisplay.y, _mouseX - _armatureDisplay.x);
			if(r > Math.PI) 
			{
				r -= Math.PI * 2;
			}
		}
		
		_body.node.rotation = r * 0.25;
		_chest.node.rotation = r * 0.25;
		if(r > 0) 
		{
			_head.node.rotation = r * 0.2;
		}
		else
		{
			_head.node.rotation = r * 0.4;
		}

		_armR.node.rotation = r * 0.5;
		if(r > 0) 
		{
			_armL.node.rotation = r * 0.8;
		}
		else
		{
			_armL.node.rotation = r * 0.6;
		}
		
		_armature.invalidUpdate();
	}
}