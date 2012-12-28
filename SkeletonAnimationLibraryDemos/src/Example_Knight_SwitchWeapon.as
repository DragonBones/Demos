package  {
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="30", backgroundColor="#cccccc")]
	public class Example_Knight_SwitchWeapon extends flash.display.Sprite {

		public function Example_Knight_SwitchWeapon() {
			starlingInit();
		}

		private function starlingInit():void {
			var _starling:Starling = new Starling(StarlingGame, stage);
			//_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();

			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyEventHandler);
		}

		private var left:Boolean;
		private var right:Boolean;

		private function onKeyEventHandler(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case 37 :
				case 65 :
					left = e.type == KeyboardEvent.KEY_DOWN;
					updateMove(-1);
					break;
				case 39 :
				case 68 :
					right = e.type == KeyboardEvent.KEY_DOWN;
					updateMove(1);
					break;
				case 38 :
				case 87 :
					if (e.type == KeyboardEvent.KEY_DOWN) {
						StarlingGame.instance.jump();
					}
					break;
				case 83 :
				case 40 :
					if (e.type == KeyboardEvent.KEY_UP) {
						StarlingGame.instance.changeWeapon();
					}
					break;
				case 32 :
					if (e.type == KeyboardEvent.KEY_UP) {
						StarlingGame.instance.attack();
					}
					break;
			}
		}

		private function updateMove(_dir:int):void {
			if (left && right) {
				StarlingGame.instance.move(_dir);
			}else if (left){
				StarlingGame.instance.move(-1);
			}else if (right){
				StarlingGame.instance.move(1);
			}else {
				StarlingGame.instance.move(0);
			}
		}
	}
}

import flash.geom.Point;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.animation.WorldClock;
import dragonBones.factorys.StarlingFactory;

import dragonBones.events.AnimationEvent;
import dragonBones.events.FrameEvent;
import flash.events.Event;

class StarlingGame extends Sprite {
	[Embed(source = "../assets/Knight_output.png", mimeType = "application/octet-stream")]
	public static const ResourcesData:Class;

	public static var instance:StarlingGame;

	private var factory:StarlingFactory;
	private var armature:Armature;
	private var armatureDisplay:Sprite;

	public function StarlingGame() {
		instance = this;

		factory = new StarlingFactory();
		factory.parseData(new ResourcesData());
		factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e:Event):void {
		armature = factory.buildArmature("knight");
		armatureDisplay = armature.display as Sprite;
		armatureDisplay.x = 400;
		armatureDisplay.y = 400;
		addChild(armatureDisplay);
		WorldClock.clock.add(armature);
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
		updateMovement();
	}

	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		updateSpeed();
		WorldClock.update();
		updateArrows();
	}

	private var isJumping:Boolean;
	private var moveDir:int;

	private var speedX:Number = 0;
	private var speedY:Number = 0;

	public function move(_dir:int):void {
		if (moveDir == _dir) {
			return;
		}
		moveDir = _dir;
		updateMovement();
	}

	public function jump():void {
		if (isJumping) {
			return;
		}
		speedY = -20;
		isJumping = true;
		armature.animation.gotoAndPlay("jump");
	}

	private var weaponID:int = 0;
	private const weaponNames:Array = ["sword", "pike", "axe", "bow"];
	public function changeWeapon():void {
		weaponID ++;
		if (weaponID >= 4) {
			weaponID -= 4;
		}

		var _weaponName:String = weaponNames[weaponID];
		var _movementName:String = "ready_" + _weaponName;

		var _arm:Bone = armature.getBone("armOutside");
		_arm.childArmature.animation.gotoAndPlay(_movementName);
	}


	private var isAttacking:Boolean;
	public function attack():void {
		if (isAttacking) {
			return;
		}
		isAttacking = true;
		var _weaponName:String = weaponNames[weaponID];
		var _movementName:String = "attack_" + _weaponName;

		var _arm:Bone = armature.getBone("armOutside");
		_arm.childArmature.animation.gotoAndPlay(_movementName);
		_arm.childArmature.addEventListener(AnimationEvent.MOVEMENT_CHANGE, childArmatureMovementChangeHandler);
		if (_weaponName == "bow") {
			_arm.childArmature.addEventListener(FrameEvent.MOVEMENT_FRAME_EVENT, childArmatureMovementEventFrameHandler);
		}
	}

	private function childArmatureMovementChangeHandler(e:AnimationEvent):void 
	{
		e.target.removeEventListener(AnimationEvent.MOVEMENT_CHANGE, childArmatureMovementChangeHandler);
		isAttacking = false;
	}

	private function childArmatureMovementEventFrameHandler(e:FrameEvent):void 
	{
		e.target.removeEventListener(FrameEvent.MOVEMENT_FRAME_EVENT, childArmatureMovementEventFrameHandler);
		trace("event:" + e.frameLabel);
		createArrow();
	}

	private var arrows:Array = [];
	private var localPoint:Point = new Point();
	private var resultPoint:Point = new Point();
	private function createArrow():void {

		var _arrowDisplay:Image = factory.getTextureDisplay("knightFolder/arrow") as Image;
		var _bow:Bone = armature.getBone("armOutside").childArmature.getBone("bow");
		_bow.display.localToGlobal(localPoint, resultPoint);

		var _r:Number;
		if (armatureDisplay.scaleX > 0) {
			_r = armatureDisplay.rotation + _bow.global.rotation;
		}else {
			_r = armatureDisplay.rotation - _bow.global.rotation + Math.PI;
		}

		_arrowDisplay.x = resultPoint.x;
		_arrowDisplay.y = resultPoint.y;
		_arrowDisplay.rotation = _r;

		var _vx:Number = Math.cos(_r) * 40;
		var _vy:Number = Math.sin(_r) * 40;
		var _arrow:Object = { display:_arrowDisplay, vx:_vx, vy:_vy };
		arrows.push(_arrow);
		addChild(_arrowDisplay);
	}

	private function updateArrows():void {
		var _arrow:Object;
		var _length:uint = arrows.length;
		for (var _i:int = _length - 1; _i >= 0; _i --) {
			_arrow = arrows[_i];
			_arrow.vy += 1;
			_arrow.display.x += _arrow.vx;
			_arrow.display.y += _arrow.vy;
			_arrow.display.rotation = Math.atan2(_arrow.vy, _arrow.vx);
			if (_arrow.display.y > 850) {
				arrows.splice(_i, 1);
				removeChild(_arrow.display);
				_arrow.display.dispose();
				_arrow.display = null;
			}
		}
	}

	private function updateMovement():void {
		if (isJumping) {
			return;
		}

		if (moveDir == 0) {
			speedX = 0;
			armature.animation.gotoAndPlay("stand");
		}else {
			speedX = moveDir * 6;
			armature.animation.gotoAndPlay("run");
			armatureDisplay.scaleX = moveDir;
		}
	}

	private function updateSpeed():void {
		if (isJumping) {
			speedY += 1;
		}

		if (speedX != 0) {
			armatureDisplay.x += speedX;
			if (armatureDisplay.x < 0) {
				armatureDisplay.x = 0;
			}else if (armatureDisplay.x > 800) {
				armatureDisplay.x = 800;
			}
		}

		if (speedY != 0) {
			armatureDisplay.rotation = speedY * 0.02 * armatureDisplay.scaleX;
			armatureDisplay.y += speedY;
			if (armatureDisplay.y > 400) {
				armatureDisplay.y = 400;
				isJumping = false;
				speedY = 0;
				armatureDisplay.rotation = 0;
				updateMovement();
			}
		}
	}
}