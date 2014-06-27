package
{
	import flash.display.Sprite;

	import starling.core.Starling;

	[SWF(width = "800", height = "600", frameRate = "60", backgroundColor = "#cccccc")]
	public class Example_Cyborg_SwitchWeapon extends flash.display.Sprite
	{

		public function Example_Cyborg_SwitchWeapon()
		{
			starlingInit();
		}

		private function starlingInit(): void
		{
			var starling: Starling = new Starling(StarlingGame, this.stage);
			starling.showStats = true;
			starling.start();
		}
	}
}

import flash.geom.Point;
import flash.events.Event;

import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.KeyboardEvent;
import starling.events.TouchEvent;
import starling.text.TextField;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.animation.WorldClock;
import dragonBones.factorys.StarlingFactory;

import dragonBones.events.AnimationEvent;

class StarlingGame extends Sprite
{
	[Embed(source = "../assets/Cyborg_output.swf", mimeType = "application/octet-stream")]
	public static const ResourcesData: Class;

	private var _textField: TextField;
	private var _factory: StarlingFactory;

	private var _armatureDisplay: Sprite;
	private var _armature: Armature;
	private var _body: Bone;
	private var _chest: Bone;
	private var _head: Bone;
	private var _armR: Bone;
	private var _armL: Bone;
	private var _weapon: Bone;

	private var _mousePoint: Point;
	private var _moveDir: int;
	private var _faceDir: int;

	private var _left: Boolean;
	private var _right: Boolean;

	private var _speedX: Number = 0;
	private var _speedY: Number = 0;

	private var _isJumping: Boolean;
	private var _isSquat: Boolean;

	private var _weaponID: int = -1;

	public function StarlingGame()
	{
		_factory = new StarlingFactory();
		_factory.parseData(new ResourcesData());
		_factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e: Event): void
	{
		_armature = _factory.buildArmature("cyborg");
		_body = _armature.getBone("body");
		_chest = _armature.getBone("chest");
		_head = _armature.getBone("head");
		_armR = _armature.getBone("armOutside");
		_armL = _armature.getBone("armInside");
		_weapon = _armature.getBone("weapon");
		_armatureDisplay = _armature.display as Sprite;
		_armatureDisplay.x = 400;
		_armatureDisplay.y = 500;


		WorldClock.clock.add(_armature);

		changeWeapon();

		_textField = new TextField(700, 30, "Press W/A/S/D to move. Press SPACE to switch weapens. Move mouse to aim.", "Verdana", 16, 0, true)
		_textField.x = 60;
		_textField.y = 5;

		this.addChild(_textField);
		this.addChild(_armatureDisplay);
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);
		this.stage.addEventListener(TouchEvent.TOUCH, mouseHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
	}

	private function keyHandler(e: KeyboardEvent): void
	{
		switch(e.keyCode)
		{
			case 37:
			case 65:
				_left = e.type == KeyboardEvent.KEY_DOWN;
				updateMove(-1);
				break;

			case 39:
			case 68:
				_right = e.type == KeyboardEvent.KEY_DOWN;
				updateMove(1);
				break;

			case 38:
			case 87:
				if(e.type == KeyboardEvent.KEY_DOWN)
				{
					jump();
				}
				break;

			case 83:
			case 40:
				squat(e.type == KeyboardEvent.KEY_DOWN);
				break;

			case 32:
				if(e.type == KeyboardEvent.KEY_UP)
				{
					changeWeapon();
				}
				break;
		}
	}

	private function updateMove(dir: int): void
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

	private function mouseHandler(e: TouchEvent): void
	{
		try
		{
			_mousePoint = e.getTouch(stage).getLocation(stage);
		}
		catch(err: Error)
		{}
	}

	private function enterFrameHandler(_e: EnterFrameEvent): void
	{
		updateSpeed();
		updateWeapon();
		WorldClock.clock.advanceTime(-1);
	}

	public function move(_dir: int): void
	{
		if(_moveDir == _dir)
		{
			return;
		}
		_moveDir = _dir;
		updateAnimation();
	}

	public function jump(): void
	{
		if(_isJumping)
		{
			return;
		}
		_speedY = -20;
		_isJumping = true;
		_armature.animation.gotoAndPlay("jump");
	}

	public function squat(_isDown: Boolean): void
	{
		if(_isSquat == _isDown)
		{
			return;
		}
		_isSquat = _isDown;
		updateAnimation();
	}

	public function changeWeapon(): void
	{
		_weaponID ++;
		if(_weaponID >= 4)
		{
			_weaponID -= 4;
		}
		var animationName: String = "weapon" + (_weaponID + 1);

		_armR.childArmature.animation.gotoAndPlay(animationName);
		_armL.childArmature.animation.gotoAndPlay(animationName);
	}

	private function updateAnimation(): void
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
				_speedX = 4 * _faceDir;
				_armature.animation.gotoAndPlay("run");
			}
			else
			{
				_speedX = -3 * _faceDir;
				_armature.animation.gotoAndPlay("runBack");
			}
		}
	}

	private function updateSpeed(): void
	{
		if(_isJumping)
		{
			if(_speedY <= 0 && _speedY + 1 > 0)
			{
				_armature.animation.gotoAndPlay("fall");
			}
			_speedY += 1;
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
				_armature.addEventListener(AnimationEvent.FADE_IN, animatonChangeHandler);
			}
		}
	}

	private function animatonChangeHandler(e: AnimationEvent): void
	{
		switch(e.animationName)
		{
			case "stand":
				_armature.removeEventListener(AnimationEvent.FADE_IN, animatonChangeHandler);
				updateAnimation();
				break;
		}
	}

	private function updateWeapon(): void
	{
		if(!_mousePoint)
		{
			return;
		}
		
		_faceDir = _mousePoint.x > _armatureDisplay.x ? 1 : -1;
		if(_armatureDisplay.scaleX * _faceDir < 0)
		{
			_armatureDisplay.scaleX *= -1;
			updateAnimation();
		}

		var r: Number;
		if(_faceDir > 0)
		{
			r = Math.atan2(_mousePoint.y - _armatureDisplay.y, _mousePoint.x - _armatureDisplay.x);
		}
		else
		{
			r = Math.PI - Math.atan2(_mousePoint.y - _armatureDisplay.y, _mousePoint.x - _armatureDisplay.x);
			if(r > Math.PI)
			{
				r -= Math.PI * 2;
			}
		}

		_body.offset.rotation = r * 0.25;
		_chest.offset.rotation = r * 0.25;

		if(r > 0)
		{
			_head.offset.rotation = r * 0.2;
		}
		else
		{
			_head.offset.rotation = r * 0.4;
		}

		_armR.offset.rotation = r * 0.5;
		if(r > 0)
		{
			_armL.offset.rotation = r * 0.8;
		}
		else
		{
			_armL.offset.rotation = r * 0.6;
		}

		_body.invalidUpdate();
	}
}