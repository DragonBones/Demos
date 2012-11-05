package  {
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	
	import starling.core.Starling;
	
    [SWF(width="800", height="600", frameRate="30", backgroundColor="#999999")]
	public class Example_Knight_starling extends flash.display.Sprite {
		
		public function Example_Knight_starling() {
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
import dragonBones.factorys.StarlingFactory;

import dragonBones.events.Event;

class StarlingGame extends Sprite {
	[Embed(source = "../assets/Knight_output.png", mimeType = "application/octet-stream")]
	public static const ResourcesData:Class;
		
	public static var instance:StarlingGame;
	
	private var factory:StarlingFactory;
	private var armature:Armature;
	private var armatureClip:Sprite;
	
	public function StarlingGame() {
		instance = this;
		
		factory = new StarlingFactory();
		factory.fromRawData(new ResourcesData(), textureCompleteHandler);
	}
	
	private function textureCompleteHandler():void {
		armature = factory.buildArmature("knight");
		armatureClip = armature.display as Sprite;
		armatureClip.x = 400;
		armatureClip.y = 400;
		addChild(armatureClip);
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
		updateMovement();
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		updateSpeed();
		armature.update();
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
		_arm.childArmature.addEventListener(dragonBones.events.Event.MOVEMENT_CHANGE, childArmatureMovementChangeHandler);
		if (_weaponName == "bow") {
			_arm.childArmature.addEventListener(dragonBones.events.Event.MOVEMENT_EVENT_FRAME, childArmatureMovementEventFrameHandler);
		}
	}
	
	private function childArmatureMovementChangeHandler(e:dragonBones.events.Event):void 
	{
		e.target.removeEventListener(dragonBones.events.Event.MOVEMENT_CHANGE, childArmatureMovementChangeHandler);
		isAttacking = false;
	}
	
	private function childArmatureMovementEventFrameHandler(e:dragonBones.events.Event):void 
	{
		e.target.removeEventListener(dragonBones.events.Event.MOVEMENT_EVENT_FRAME, childArmatureMovementEventFrameHandler);
		trace("event:" + e.data);
		createArrow();
	}
	
	private var arrows:Array = [];
	private var localPoint:Point = new Point();
	private var resultPoint:Point = new Point();
	private function createArrow():void {
		
		var _arrowDisplay:Image = StarlingFactory.getTextureDisplay(factory.textureData, "knightFolder/arrow");
		var _bow:Armature = armature.getBone("armOutside").childArmature.getBone("bow").childArmature;
		_bow.display.localToGlobal(localPoint, resultPoint);
		
		var _r:Number;
		if (armatureClip.scaleX > 0) {
			_r = armatureClip.rotation + _bow.display.rotation;
		}else {
			_r = armatureClip.rotation - _bow.display.rotation + Math.PI;
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
			armatureClip.scaleX = moveDir;
		}
	}
	
	private function updateSpeed():void {
		if (isJumping) {
			speedY += 1;
		}
		
		if (speedX != 0) {
			armatureClip.x += speedX;
			if (armatureClip.x < 0) {
				armatureClip.x = 0;
			}else if (armatureClip.x > 800) {
				armatureClip.x = 800;
			}
		}
		
		if (speedY != 0) {
			armatureClip.rotation = speedY * 0.02 * armatureClip.scaleX;
			armatureClip.y += speedY;
			if (armatureClip.y > 400) {
				armatureClip.y = 400;
				isJumping = false;
				speedY = 0;
				armatureClip.rotation = 0;
				updateMovement();
			}
		}
	}
}